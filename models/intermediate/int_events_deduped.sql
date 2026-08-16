{{ config(
    materialized = 'view'
) }}

-- This model deduplicates events and filters to authenticated users only.
-- Events are deduplicated per user per event_name per hour (keeping first occurrence).
-- Events are only included if the user was authenticated on that date.
-- This ensures we analyze genuine user behavior from authenticated sessions,
-- excluding test data, system events, or unauthenticated activity.

with events as (
    select *
    from {{ ref('stg_events') }}
),

auth_users as (
    select 
        user_uuid,
        auth_date
    from {{ ref('stg_auth_users') }}
),

deduped as (
    select
        event_id,
        event_date,
        event_at,
        account_uuid,
        user_uuid,
        event_name,
        row_number() over (
            partition by user_uuid, event_name, date_trunc('hour', event_at)
            order by event_at
        ) as rn
    from events
),

final as (
    select
        d.event_id,
        d.event_date,
        d.event_at,
        d.account_uuid,
        d.user_uuid,
        d.event_name
    from deduped d
    inner join auth_users a
        on d.user_uuid = a.user_uuid
        and d.event_date = a.auth_date
    where d.rn = 1
)

select * from final
