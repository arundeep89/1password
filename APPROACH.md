# Data Modeling Approach

## Architecture Overview

This project follows a four-layer dbt architecture: **Staging → Intermediate → Marts → Reports**.

### Layer Definitions

#### 1. Staging Layer (`stg_*`)
- **Purpose**: Direct 1:1 mapping from source data
- **Transformations**: Simple type conversions and basic data cleaning
- **Rules**: 
  - No business logic or aggregations
  - No joins between different sources
  - All models materialized as views

#### 2. Intermediate Layer (`int_*`)
- **Purpose**: Business logic, joins, and transformations
- **Transformations**: 
  - Joins across staging tables
  - Filtering and deduplication logic
  - Enrichment with additional attributes
- **Models**:
  - `int_events_deduped`: Deduplicates events and filters to authenticated users
  - `int_event_categories_enriched`: Adds success/failure flags to event categories

#### 3. Marts Layer (`dim_*`, `fct_*`)
- **Purpose**: Consumer-ready analytics models
- **Types**:
  - **Dimensions (`dim_*`)**: Descriptive attributes and user milestones
  - **Facts (`fct_*`)**: Measurable metrics and events

#### 4. Report Layer (`rpt_*`)
- **Purpose**: Aggregated reporting tables for BI tools


## Key Assumptions

### Active User Definition
An **active user** is defined as any user who encountered any passkey-related event after logging in (authenticating). 

- Users must have an authentication record (`stg_auth_users`) for the date of the event
- Only events occurring on days when the user authenticated are counted
- This ensures all analyzed activity represents genuine authenticated user sessions

### Paying Users:
In all passkey adoption analyses we explicitly assume that all users with authentication records (`auth_users`) are considered 'paying' for the purpose of analysis.

### Event Deduplication and Authentication Filtering
The `int_events_deduped` model performs two critical data quality functions:

**Deduplication**: Events are deduplicated per user per event_name per hour, keeping only the first occurrence within each 1-hour window. This prevents duplicate counting of events that may be generated multiple times due to system behavior.

**Authentication Filtering**: Events are filtered to only include those where the user was authenticated on the event date (inner join with `stg_auth_users` on `user_uuid` and `auth_date`).


### Per-Day Metric Calculation
All metrics are calculated "per day" not "ever" (cumulative). This applies to both user-level and account-level metrics, providing daily snapshots rather than cumulative totals.

### `step_passkey_events`
The exact model does not exist but intermdiate models perform similar operation

### Syntax
Some of the syntax is not validated. Eg: `data_tests` should be used in place of `tests`

### Incremental
Incremental approach was not looked into but could be used to reduce loading volume. For example, tables can use load date to only process new records per day using `insert_overwrite`, in cases where latest record is needed `merge` coould be used. For SCD type 2, `snapshots` on source could be used

## Questions
1. Funnel: Of users who see a passkey suggestion, how many register (save) and how many
use (fill/autofill) passkeys successfully?
- Refer analyses/q1_funnel.sql
2. Engagement: How many users per day (and per account) are actively using passkeys?
- Refer analyses/q2_engagement.sql
3. Quality: Where do failures happen (timeout, bad input, missing item)?
- Refer analyses/q3_quality.sql
4. Account adoption (B2B): On paying accounts, what share of active users has used a
passkey in the last 30 days?
- Refer analyses/q4_account_adoption.sql
