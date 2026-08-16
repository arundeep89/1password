-- Question 4: Account Adoption (B2B)
-- On paying accounts, what share of active users has used a
-- passkey in the last 30 days?
--
-- This query uses the pre-built report model `rpt_account_passkey_adoption_daily`
-- which already aggregates daily passkey activity per account.
-- Since all users are considered "paying" (per the requirement), we aggregate
-- across all accounts without filtering on a payment flag.

SELECT
    account_uuid,
    SUM(count_users_passkey_active)   AS passkey_users,
    SUM(count_users_authenticated)    AS active_users,
    ROUND(
        100.0 * SUM(count_users_passkey_active) /
        NULLIF(SUM(count_users_authenticated), 0),
        2
    ) AS adoption_share_pct
FROM {{ ref('rpt_account_passkey_adoption_daily') }}
WHERE event_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY account_uuid
ORDER BY adoption_share_pct DESC;