-- Question 3: Quality
-- Where do failures happen (timeout, bad input, missing item)?
--
-- This query uses the enriched event categories table to analyze failure
-- patterns, providing both high-level categorization and specific failure
-- subtypes broken down by date and failure type.

WITH failure_events AS (
    SELECT
        event_date,
        event_name,
        user_uuid,
        account_uuid,
        -- Use the enriched failure classification from int_event_categories_enriched
        CASE
            WHEN event_name LIKE 'passkey-save-failure_%' THEN 'save'
            WHEN event_name LIKE 'passkey-fill-failure_%' THEN 'fill'
            ELSE 'other'
        END as failure_type,
        CASE
            WHEN event_name LIKE '%timeout%' THEN 'timeout'
            WHEN event_name LIKE '%bad_input%' THEN 'bad input'
            WHEN event_name LIKE '%missing_item%' THEN 'missing item'
            WHEN event_name LIKE '%validation%' THEN 'validation error'
            WHEN event_name LIKE '%network%' THEN 'network error'
            WHEN event_name LIKE '%auth%' THEN 'authentication error'
            ELSE 'other'
        END as failure_subtype,
        -- Get the enriched category and funnel stage for context
        CASE
            WHEN event_name LIKE 'passkey-save-failure_%' THEN 'registration'
            WHEN event_name LIKE 'passkey-fill-failure_%' THEN 'usage'
            ELSE 'other'
        END as failure_category
    FROM {{ ref('int_events_deduped') }}
    WHERE
        event_name LIKE 'passkey-save-failure_%'
        OR event_name LIKE 'passkey-fill-failure_%'
)

SELECT
    event_date,
    failure_type,
    failure_subtype,
    COUNT(*) as failure_count,
    COUNT(DISTINCT user_uuid) as users_affected,
    COUNT(DISTINCT account_uuid) as accounts_affected,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY event_date), 2) as daily_failure_percentage,
    -- Add funnel stage context for trend analysis
    CASE
        WHEN failure_type = 'save' THEN 'registration funnel'
        WHEN failure_type = 'fill' THEN 'usage funnel'
        ELSE 'other'
    END as funnel_stage
FROM failure_events
GROUP BY
    event_date,
    failure_type,
    failure_subtype,
    -- For daily_percentage we need to use window function
ORDER BY
    event_date DESC,
    failure_count DESC;

-- Optional: Add a second query for aggregated daily summary

WITH daily_failure_summary AS (
    SELECT
        event_date,
        failure_type,
        COUNT(*) as daily_failures
    FROM failure_events
    GROUP BY event_date, failure_type
)

SELECT
    event_date,
    SUM(daily_failures) as total_daily_failures,
    COUNT(DISTINCT CASE WHEN failure_type = 'save' THEN 1 END) as days_with_save_failure,
    COUNT(DISTINCT CASE WHEN failure_type = 'fill' THEN 1 END) as days_with_fill_failure,
    ROUND(SUM(daily_failures) * 100.0 / NULLIF(SUM(SUM(daily_failures)) OVER (), 0), 2) as overall_failure_rate
FROM daily_failure_summary
GROUP BY event_date
ORDER BY event_date;

-- Optional: Detailed failure breakdown with authentication context
WITH detailed_failures AS (
    SELECT
        fe.event_date,
        fe.failure_type,
        fe.failure_subtype,
        fe.users_affected,
        -- Join to auth_users to see if failures happened on authenticated days only
        CASE
            WHEN a.auth_date IS NOT NULL THEN 'authenticated'
            ELSE 'unauthenticated'
        END as auth_context,
        COUNT(*) as failure_instances
    FROM failure_events fe
    LEFT JOIN {{ ref('stg_auth_users') }} a
        ON fe.user_uuid = a.user_uuid AND fe.event_date = a.auth_date
)

SELECT
    event_date,
    auth_context,
    failure_type,
    failure_subtype,
    SUM(failure_instances) as failure_count,
    COUNT(DISTINCT users_affected) as unique_users_impacted
FROM detailed_failures
GROUP BY event_date, auth_context, failure_type, failure_subtype
ORDER BY event_date, auth_context, failure_count DESC;