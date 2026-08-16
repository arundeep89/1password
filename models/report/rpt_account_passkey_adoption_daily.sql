{{ config(
    materialized = 'view'
) }}

with account_daily as (
    select *
    from {{ ref('fct_passkey_account_daily') }}
)

select
    event_date,
    account_uuid,
    users_with_fill_success as count_users_passkey_active,
    users_with_authentication as count_users_authenticated,
    users_with_save_success as count_users_saved,
    case 
        when users_with_authentication > 0 
        then users_with_fill_success::float / users_with_authentication::float
        else null
    end as passkey_active_rate
from account_daily
