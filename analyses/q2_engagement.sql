-- Question 2: Engagement
-- How many users per day (and per account) are actively using passkeys?
--
-- This answer comes directly from the pre-built report model
-- `rpt_account_passkey_adoption_daily`, which already aggregates the
-- daily count of active passkey users per account.

SELECT
    event_date,
    account_uuid,
    count_users_passkey_active AS active_passkey_users
FROM {{ ref('rpt_account_passkey_adoption_daily') }}
ORDER BY event_date, account_uuid;