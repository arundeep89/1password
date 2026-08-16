{{ config(
    materialized = 'view'
) }}

with events as (
    select *
    from {{ ref('int_events_deduped') }}
),

account_daily_aggregates as (
    select
        event_date,
        account_uuid,
        count(distinct case when event_name = 'passkey-save-success' then user_uuid end) as users_with_save_success,
        count(distinct case when event_name = 'passkey-fill-success' then user_uuid end) as users_with_fill_success,
        count(distinct user_uuid) as users_with_authentication
    from events
    group by event_date, account_uuid
)

select * from account_daily_aggregates
