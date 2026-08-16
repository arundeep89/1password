{{ config(
    materialized = 'view'
) }}

WITH source AS (
    SELECT *
    FROM {{ ref('accounts') }}
),

stg AS (
    SELECT
        account_uuid,
        account_type,
        tier_name, 
        created_at
    FROM source
)

SELECT *
FROM stg