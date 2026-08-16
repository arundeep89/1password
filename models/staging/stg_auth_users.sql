{{ config(
    materialized = 'view'
) }}

WITH source AS (
    SELECT *
    FROM {{ ref('auth_users') }}
),

stg AS (
    SELECT
        user_uuid,
        account_uuid,
        auth_date
    FROM source
)

SELECT *
FROM stg