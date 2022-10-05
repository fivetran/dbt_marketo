# dbt_marketo v0.8.0
PR [#22](https://github.com/fivetran/dbt_marketo/pull/22) incorporates the following updates:
## 🚨 Breaking Changes 🚨
Some of the more complex transformation logic has been moved from the Marketo source package to the transform package. This was done so the delineation between staging and intermediate models is in line with Fivetran's other packages. This does not affect the final tables created by the transform package, but this will affect the staging tables as outlined below. 
- Model `stg_marketo__lead_base` from `dbt_marketo_source` has been rolled into [`stg_marketo__lead`](https://github.com/fivetran/dbt_marketo_source/blob/main/models/stg_marketo__lead.sql).
- Parts from model `stg_marketo__lead` from `dbt_marketo_source` have been moved to a new model [`int_marketo__lead`](https://github.com/fivetran/dbt_marketo/blob/feature/create-intermediates/models/intermediate/int_marketo__lead.sql) in `dbt_marketo`.
- Because of the above changes, model `marketo__lead_adapter` is now redundant and has been removed. 
## Features
- 🎉 Databricks compatibility 🎉
- The starting date of the date range for the leads data can now be adjusted (see [README](https://github.com/fivetran/dbt_marketo/blob/main/README.md#changing-the-lead-date-range) for instructions).
- Ability to disable `activity_delete_lead` model if necessary (see [README](https://github.com/fivetran/dbt_marketo/blob/main/README.md#step-4-enablingdisabling-models) for instructions). 
- Updated structure of config default variables for enabling `campaigns` and `program` models to avoid conflicting with a user's settings. 

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
