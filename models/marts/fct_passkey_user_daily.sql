{{ config(
    materialized = 'view'
) }}

with events as (
    select *
    from {{ ref('int_events_deduped') }}
),

daily_aggregates as (
    select
        user_uuid,
        event_date,
        count(case when event_name = 'passkey-suggestion-shown' then 1 end) as count_suggestions_shown,
        count(case when event_name = 'passkey-save-success' then 1 end) as count_save_success,
        count(case when event_name = 'passkey-fill-success' then 1 end) as count_fill_success,
        count(case when event_name like 'passkey-save-failure_%' then 1 end) as count_save_failure,
        count(case when event_name like 'passkey-fill-failure_%' then 1 end) as count_fill_failure,
        true as had_passkey_activity,
        case 
            when count(case when event_name = 'passkey-fill-success' then 1 end) >= 1 then true
            else false
        end as is_passkey_active_user
    from events
    group by user_uuid, event_date
)

select * from daily_aggregates
