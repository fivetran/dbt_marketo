# dbt_marketo v1.2.0

[PR #53](https://github.com/fivetran/dbt_marketo/pull/53) includes the following updates:

## Features
  - Increases the required dbt version upper limit to v3.0.0

# dbt_marketo v1.1.0

[PR #52](https://github.com/fivetran/dbt_marketo/pull/52) includes the following updates:

## Schema/Data Change
**5 total changes • 4 possible breaking changes**

| Data Model(s) | Change type | Old | New | Notes |
| ------------- | ----------- | ----| --- | ----- |
| All models | New column | | `source_relation` | Identifies the source connection when using multiple Marketo connections |
| `marketo__lead_history` | Updated surrogate key | `lead_history_id` = `lead_id` + `date_day` | `lead_history_id` = `source_relation` + `lead_id` + `date_day` |  |
| `marketo__email_templates`<br>`stg_marketo__email_template_history` | Updated surrogate key | `email_template_history_id` = `email_template_id` + `inferred_version` | `email_template_history_id` = `source_relation` + `email_template_id` + `inferred_version` |  |
|`marketo__email_sends`<br>`stg_marketo__activity_click_email`<br>`stg_marketo__activity_email_bounced`<br>`stg_marketo__activity_email_delivered`<br>`stg_marketo__activity_open_email`<br>`stg_marketo__activity_send_email`<br>`stg_marketo__activity_unsubscribe_email` | Updated surrogate key | `email_send_id` = `primary_attribute_value_id` + `campaign_id` + `campaign_run_id` + `lead_id` | `email_send_id` = `source_relation` + `primary_attribute_value_id` + `campaign_id` + `campaign_run_id` + `lead_id` |  |
| `marketo__change_data_details`<br>`marketo__change_data_pivot`<br>`marketo__change_data_scd`<br>`marketo__lead_calendar_spine` | Updated surrogate key | `lead_day_id` = `lead_id` + `date_day` | `lead_day_id` = `source_relation` + `lead_id` + `date_day` |  |

## Feature Update
- **Union Data Functionality**: This release supports running the package on multiple Marketo source connections. See the [README](https://github.com/fivetran/dbt_marketo/tree/main?tab=readme-ov-file#step-3-define-database-and-schema-variables) for details on how to leverage this feature.

## Tests Update
- Removes uniqueness tests. The new unioning feature requires combination-of-column tests to consider the new `source_relation` column in addition to the existing primary key, but this is not supported across dbt versions.
- These tests will be reintroduced once a version-agnostic solution is available.

# dbt_marketo v1.0.1

[PR #51](https://github.com/fivetran/dbt_marketo/pull/51) includes the following updates:

## Under the Hood
- Resolved a dbt Fusion error around `{% set abc = abc.append(...) %}` in [marketo__change_data_scd](https://github.com/fivetran/dbt_marketo/blob/main/models/intermediate/marketo__change_data_scd.sql), as this syntax is valid only in dbt Core. We have opted for `do` instead of `set`.

# dbt_marketo v1.0.0

[PR #47](https://github.com/fivetran/dbt_marketo/pull/47) includes the following updates:

## Breaking Changes

### Source Package Consolidation
- Removed the dependency on the `fivetran/marketo_source` package.
  - All functionality from the source package has been merged into this transformation package for improved maintainability and clarity.
  - If you reference `fivetran/marketo_source` in your `packages.yml`, you must remove this dependency to avoid conflicts.
  - Any source overrides referencing the `fivetran/marketo_source` package will also need to be removed or updated to reference this package.
  - Update any marketo_source-scoped variables to be scoped to only under this package. See the [README](https://github.com/fivetran/dbt_marketo/blob/main/README.md) for how to configure the build schema of staging models.
- As part of the consolidation, vars are no longer used to reference staging models, and only sources are represented by vars. Staging models are now referenced directly with `ref()` in downstream models.

### dbt Fusion Compatibility Updates
- Updated package to maintain compatibility with dbt-core versions both before and after v1.10.6, which introduced a breaking change to multi-argument test syntax (e.g., `unique_combination_of_columns`).
- Temporarily removed unsupported tests to avoid errors and ensure smoother upgrades across different dbt-core versions. These tests will be reintroduced once a safe migration path is available.
  - Removed all `dbt_utils.unique_combination_of_columns` tests.

## Under the Hood
- Updated conditions in `.github/workflows/auto-release.yml`.
- Added `.github/workflows/generate-docs.yml`.

## Documentation
- Added Quickstart model counts to README. ([#45](https://github.com/fivetran/dbt_marketo/pull/45))
- Corrected references to connectors and connections in the README. ([#45](https://github.com/fivetran/dbt_marketo/pull/45))

# dbt_marketo v0.13.1
[PR #44](https://github.com/fivetran/dbt_marketo/pull/44) includes the following updates:

## Quickstart Fix
- For Quickstart users, the recently updated `marketo__campaigns` and `marketo__programs` models have been added to the `public_models` list in `quickstart.yml` to ensure these models are captured by default.

# dbt_marketo v0.13.0
[PR #43](https://github.com/fivetran/dbt_marketo/pull/43) includes the following updates:

## Breaking Change
- Updated the default configuration for the `marketo__enable_campaigns` and `marketo__enable_programs` variables from disabled to enabled.

- Each following variable will enable the listed models by default:
  - `marketo__enable_campaigns`:
    - the end models `marketo__campaigns` and `marketo__email_stats__by_campaign`
    - the upstream staging model `stg_marketo__campaigns`
  - `marketo__enable_campaigns` and `marketo__enable_programs`:
    - the end models `marketo__programs` and `marketo__email_stats__by_program`
    - the upstream staging model `stg_marketo__program`

- Additionally, the [`marketo__email_sends`](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__email_sends) model will now output the following fields which were previously skipped by default now that `marketo__enable_campaigns` is enabled at onset:
  - `campaign_type`
  - `program_id`

- Quickstart dynamically manages these settings, but non-Quickstart users or those not syncing `campaign` or `program` tables should adjust the variables accordingly. Refer to the [README](https://github.com/fivetran/dbt_marketo?tab=readme-ov-file#step-4-enablingdisabling-models) for details.

## Under the Hood
- Updated the `run_models.sh` script to now test for when `marketo__enable_campaigns` and `marketo__enable_programs` is disabled.
- Added validation tests for `marketo__campaigns` (`consistency_campaigns`) and `marketo__programs` (`consistency_campaigns`) now that they are enabled by default.

# dbt_marketo v0.12.1
[PR #42](https://github.com/fivetran/dbt_marketo/pull/42) includes the following updates:

## Documentation
- Updated README formatting.

## Internal Updates (Maintainers Only)
- Removed `marketo__campaigns` and `marketo__programs` from the public models list in `quickstart.yml` since they are disabled by default. This serves as a temporary measure until the models and the upstream sources are updated to be enabled by default.

# dbt_marketo v0.12.0
[PR #39](https://github.com/fivetran/dbt_marketo/pull/39) includes the following updates:

## Breaking Changes:
- The `action_result` field is now included in the following models, allowing users to filter records based on the `action_result` value.
    - `stg_marketo__activity_send_email`
    - `marketo__email_sends_deduped`
    - `marketo__email_sends`
  - *Note:* If you have previously added this field via the `marketo__activity_send_email_passthrough_columns` variable, remove or alias it there to prevent duplicate column errors.
- To minimize customer impact, we limited adding `action_result` to models where it does not alter the grain. Users needing `action_result` in aggregate models can derive it from the `marketo__email_sends` model using custom aggregation logic. For more details, refer to the [DECISIONLOG entry](https://github.com/fivetran/dbt_marketo/blob/main/DECISIONLOG.md#action-result-field-introduction).

## Documentation updates:
- Added missing definitions to dbt documentation.

## Under the Hood:
- Added consistency integration tests for the models listed above.
- Removed all tests from intermediate models as they were unnecessary and to optimize resource usage.
- Updated seed data to include `action_result`.

# dbt_marketo v0.11.0
[PR #33](https://github.com/fivetran/dbt_marketo/pull/33) includes the following updates:
## Bug Fix
- Removed the use of `ignore nulls` statements in `marketo__lead_history` and `marketo__change_data_scd`, which was incompatible with PostgreSQL and Databricks Runtime. The logic has been updated with a new approach but produces the same results as before.
- Updated model `marketo__change_data_pivot` to use the `activity_id` as a tie-breaker to remove randomness when ordering events having the same `activity_timestamp`. 
  - Previously if two events happened at the same timestamp, results would be inconsistent, which propagated to downstream models. Now, this model will produce consistent results.

## Under the hood
- Added additional variable configurations to integration tests to account for a wider range of situations.

---

[PR #32](https://github.com/fivetran/dbt_marketo/pull/32) and Marketo Source [PR #35](https://github.com/fivetran/dbt_marketo_source/pull/35) include the following updates:

## Feature Updates (includes 🚨 breaking changes 🚨)
- Ensures that `stg_marketo__lead` (and therefore `marketo__leads`) has and documents the below columns, all [standard](https://developers.marketo.com/rest-api/lead-database/fields/list-of-standard-fields/) fields from Marketo. Previously, peristed all fields found in your `LEAD` source table but only _ensured_ that the `id`, `created_at`, `updated_at`, `email`, `first_name`, `last_name`, and `_fivetran_synced` fields were included. If any of the following default columns are missing from your `LEAD` table, `stg_marketo__lead` will create a NULL version with the proper data type:
  - `phone`
  - `main_phone`
  - `mobile_phone`
  - `company`
  - `inferred_company`
  - `address_lead`
  - `address`
  - `city`
  - `state`
  - `state_code`
  - `country`
  - `country_code`
  - `postal_code`
  - `billing_street`
  - `billing_city`
  - `billing_state`
  - `billing_state_code`
  - `billing_country`
  - `billing_country_code`
  - `billing_postal_code`
  - `inferred_city`
  - `inferred_state_region`
  - `inferred_country`
  - `inferred_postal_code`
  - `inferred_phone_area_code`
  - `anonymous_ip`
  - `unsubscribed` -> aliased as `is_unsubscribed` (🚨 breaking change 🚨)
  - `email_invalid` -> aliased as `is_email_invalid` (🚨 breaking change 🚨)
  - `do_not_call`

## Under the Hood
- Updated the maintainer PR template to resemble the most up to date format.
- Included auto-releaser GitHub Actions workflow to automate future releases.

# dbt_marketo v0.10.0

## 🚨 Breaking Changes 🚨  (recommend --full-refresh):
[PR #28](https://github.com/fivetran/dbt_marketo/pull/28) includes the following updates:
- The source package was updated in connection with the Fivetran Marketo connector's [June 2023](https://fivetran.com/docs/applications/marketo/changelog#june2023) and [May 2023](https://fivetran.com/docs/applications/marketo/changelog#may2023) releases. This affects the columns created for the following tables:
  - marketo__campaigns
  - marketo__email_sends
  - marketo__programs
  - marketo__leads
- See the [source package changelog](https://github.com/fivetran/dbt_marketo_source/blob/main/CHANGELOG.md) for more details. 
- We recommend using `dbt run --full-refresh` the next time you run your project due to changes affecting incremental models.
 ## 🚘 Under the Hood:
 [PR #28](https://github.com/fivetran/dbt_marketo/pull/28) includes the following updates:
- Update documentation and testing seed data

[PR #27](https://github.com/fivetran/dbt_marketo/pull/27) includes the following updates:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request [templates](/.github).

# dbt_marketo v0.9.1

## Bug Fix
[PR #26](https://github.com/fivetran/dbt_marketo/pull/26) includes the following non-breaking change:
- Due to a "system glitch" within Marketo, the same `lead_id` can be deleted more than once. This may introduce multiple records for the same `lead_id` in the `int_marketo__lead` which can cause the downstream test `marketo__leads.lead_id.unique` to fail.  The bug fix adds a `distinct lead_id` to the `deleted_leads` CTE in the `int_marketo__lead` model (https://github.com/fivetran/dbt_marketo/issues/25). 

## Contributors
 - [@m-feeser](https://github.com/m-feeser) ([#26](https://github.com/fivetran/dbt_marketo/pull/26))

# dbt_marketo v0.9.0

## 🚨 Breaking Changes 🚨:
[PR #24](https://github.com/fivetran/dbt_marketo/pull/24) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- `dbt_utils.surrogate_key` has also been updated to `dbt_utils.generate_surrogate_key`. Since the method for creating surrogate keys differ, we suggest all users do a `full-refresh` for the most accurate data. For more information, please refer to dbt-utils [release notes](https://github.com/dbt-labs/dbt-utils/releases) for this update.
- `packages.yml` has been updated to reflect new default `fivetran/fivetran_utils` version, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

# dbt_marketo v0.8.0
PR [#22](https://github.com/fivetran/dbt_marketo/pull/22) incorporates the following updates:
## 🚨 Breaking Changes 🚨
Some of the more complex transformation logic has been moved from the Marketo source package to the transform package. This was done so the delineation between staging and intermediate models is in line with Fivetran's other packages. This does not affect the final tables created by the transform package, but this will affect the staging tables as outlined below.
- Model `stg_marketo__lead_base` from `dbt_marketo_source` has been rolled into [`stg_marketo__lead`](https://github.com/fivetran/dbt_marketo_source/blob/main/models/stg_marketo__lead.sql).
- Parts from model `stg_marketo__lead` from `dbt_marketo_source` have been moved to a new model [`int_marketo__lead`](https://github.com/fivetran/dbt_marketo/blob/feature/create-intermediates/models/intermediate/int_marketo__lead.sql) in `dbt_marketo`.
- Because of the above changes, model `marketo__lead_adapter` is now redundant and has been removed. 
## Features
- 🎉 Databricks and Postgres compatibility 🎉
- The starting date of the date range for the leads data can now be adjusted (see [README](https://github.com/fivetran/dbt_marketo/blob/main/README.md#changing-the-lead-date-range) for instructions).
- Ability to disable `activity_delete_lead` model if necessary (see [README](https://github.com/fivetran/dbt_marketo/blob/main/README.md#step-4-enablingdisabling-models) for instructions). 
## Under the Hood
- Updates structure of config default variables for enabling `campaigns` and `program` models to avoid conflicting with a user's settings. 
- Updates the incremental strategy used by Postgres and Redshift adapters to `delete+insert`.

# dbt_marketo v0.7.0

## Bug Fixes
- Previously, `merged_into_lead_id` and `lead_id` were erroneously switched in `stg_marketo__lead`. This release switches them back, appropriately casting `merged_into_lead_id` as a string (it can have multiple comma-separated values) and `lead_id` as an integer (https://github.com/fivetran/dbt_marketo/issues/17). 

This is a **BREAKING CHANGE** as you will need to run a full refresh due to the columns' differing data types. 

# dbt_marketo v0.6.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_marketo_source`. Additionally, the latest `dbt_marketo_source` package has a dependency on the latest `dbt_fivetran_utils`. Further, the latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

## Under the Hood 
- Redshift recently included pivot as a reserved word within the warehouse. As such, the `pivot` CTE within the `marketo__change_data_pivot` and `marketo__change_data_details` models have been changed to `pivots` to avoid the Redshift error.

# dbt_marketo_source v0.1.0 -> v0.5.0
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
