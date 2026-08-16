{{ config(
    materialized = 'view'
) }}

with event_categories as (
    select *
    from {{ ref('stg_event_categories') }}
),

enriched as (
    select
        event_name,
        event_category,
        funnel_stage,
        case
            when event_name in (
                'passkey-suggestion-accepted',
                'passkey-save-success',
                'passkey-fill-success'
            ) then true
            else false
        end as is_success,
        case
            when event_name in (
                'passkey-suggestion-dismissed'
            ) or event_name like 'passkey-save-failure_%'
              or event_name like 'passkey-fill-failure_%'
            then true
            else false
        end as is_failure
    from event_categories
)

select * from enriched
