{{ config(
    materialized = 'view'
) }}

with daily_user_activity as (
    select *
    from {{ ref('fct_passkey_user_daily') }}
),

daily_funnel as (
    select
        event_date,
        count(distinct case when count_suggestions_shown >= 1 then user_uuid end) as users_with_suggestions,
        count(distinct case when count_save_success >= 1 then user_uuid end) as users_with_save_success,
        count(distinct case when count_fill_success >= 1 then user_uuid end) as users_with_fill_success
    from daily_user_activity
    group by event_date
),

final as (
    select
        event_date,
        users_with_suggestions,
        users_with_save_success,
        users_with_fill_success,
        case 
            when users_with_suggestions > 0 
            then users_with_save_success::float / users_with_suggestions::float
            else null
        end as suggestion_to_save_conversion_rate,
        case 
            when users_with_save_success > 0 
            then users_with_fill_success::float / users_with_save_success::float
            else null
        end as save_to_fill_conversion_rate
    from daily_funnel
)

select * from final
