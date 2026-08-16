{{ config(
    materialized = 'view'
) }}

with source as (
    select *
    from {{ ref('event_categories') }}
),

stg as (
    select
        event_name,
        event_category,
        case
            when funnel_stage = '1 - top of funnel' then '1a'
            when funnel_stage = '1b - negative' then '1b'
            when funnel_stage = '1c - intent' then '1c'
            when funnel_stage = '2 - converted' then '2a'
            when funnel_stage = '2b - failed' then '2b'
            when funnel_stage = '3 - active use' then '3a'
            when funnel_stage = '3b - failed' then '3b'
            else funnel_stage
        end as funnel_stage
    from source
)

select *
from stg
