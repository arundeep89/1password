{{ config(
    materialized = 'view'
) }}

with source as (
    select *
    from {{ source('events', 'events') }}
),

stg_events as (
    select
        event_id,
        event_date,
        event_at,
        account_uuid,
        user_uuid,
        event_name
    from source
)

select * from stg_events