{{ config(
    materialized = 'view'
) }}

with events as (
    select *
    from {{ ref('int_events_deduped') }}
),

user_milestones as (
    select
        user_uuid,
        min(case when event_name = 'passkey-suggestion-shown' then event_at end) as first_suggestion_at,
        min(case when event_name = 'passkey-save-success' then event_at end) as first_save_success_at,
        min(case when event_name = 'passkey-fill-success' then event_at end) as first_fill_success_at,
        max(case when event_name = 'passkey-save-success' then 1 else 0 end) as has_ever_saved,
        max(case when event_name = 'passkey-fill-success' then 1 else 0 end) as has_ever_filled
    from events
    group by user_uuid
),

final as (
    select
        user_uuid,
        first_suggestion_at,
        first_save_success_at,
        first_fill_success_at,
        case
            when first_suggestion_at is not null and first_save_success_at is not null
            then datediff('day', first_suggestion_at, first_save_success_at)
            else null
        end as days_suggestion_to_save,
        case
            when first_save_success_at is not null and first_fill_success_at is not null
            then datediff('day', first_save_success_at, first_fill_success_at)
            else null
        end as days_save_to_first_fill,
        case when has_ever_saved = 1 then true else false end as has_ever_saved,
        case when has_ever_filled = 1 then true else false end as has_ever_filled
    from user_milestones
)

select * from final
