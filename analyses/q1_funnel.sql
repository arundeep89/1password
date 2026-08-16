-- Question 1: Funnel
-- Of users who see a passkey suggestion, how many register (save) and how many
-- use (fill/autofill) passkeys successfully?

-- This answer is provided by the pre‑built report model `rpt_passkey_funnel_daily`.
-- The query below simply pulls the three core funnel numbers (and the two
-- conversion rates) from that model.  Adjust the `SELECT` list if you only
-- need the raw counts.

SELECT
    event_date,
    users_with_suggestions   AS users_who_saw_suggestion,
    users_with_save_success  AS users_registered,
    users_with_fill_success  AS users_used_passkey,
    /* optional conversion rates – kept for completeness */
    suggestion_to_save_conversion_rate,
    save_to_fill_conversion_rate
FROM {{ ref('rpt_passkey_funnel_daily') }}
ORDER BY event_date;