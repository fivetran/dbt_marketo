<p align="center">
    <a alt="License"
        href="https://github.com/fivetran/dbt_marketo/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.0.0_,<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
</p>

# Marketo Transformation dbt Package ([docs](https://fivetran.github.io/dbt_marketo/))
# 📣 What does this dbt package do?
- Produces modeled tables that leverage Marketo data from [Fivetran's connector](https://fivetran.com/docs/applications/marketo) in the format described by [this ERD](https://fivetran.com/docs/applications/marketo#schema) and builds off the output of our [Marketo source package](https://github.com/fivetran/dbt_marketo_source).
- Enables you to better understand your Marketo email performance and how your leads change over time. The output includes models with enriched email metrics for leads, programs, email templates, and campaigns. It also includes a lead history table that shows the state of leads on every day, for a set of columns that you define.
- Generates a comprehensive data dictionary of your source and modeled Marketo data through the [dbt docs site](https://fivetran.github.io/dbt_marketo/).

The following table provides a detailed list of all models materialized within this package by default.

> TIP: See more details about these models in the package's [dbt docs site](https://fivetran.github.io/dbt_marketo/).

| **Model**                | **Description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [marketo__campaigns](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__campaigns)       | Each record represents a Marketo campaign, enriched with metrics about email performance.                                                      |
| [marketo__email_sends](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__email_sends)     | Each record represents the send of a Marketo email, enriched with metrics about email performance.                                                   |
| [marketo__email_templates](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__email_templates) | Each record represents a Marketo email template, enriched with metrics about email performance.                                                |
| [marketo__lead_history](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__lead_history)    | Each record represents the state of a lead on a specific day. The columns in this model are specified with the `lead_history_columns` variable. |
| [marketo__leads](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__leads)           | Each record represents a Marketo lead, enriched with metrics about email performance.                                                          |
| [marketo__programs](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__programs)         | Each record represents a Marketo program, enriched with metrics about email performance.                                                       |

https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.stg_marketo__activity_change_data_value
# 🎯 How do I use the dbt package?

## Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Marketo connector syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

## Step 2: Install the package
Include the following Marketo package version in your `packages.yml` file.

> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

```yml
packages:
  - package: fivetran/marketo
    version: [">=0.8.0", "<0.9.0"]
```

## Step 3: Define database and schema variables
By default, this package runs using your destination and the `marketo` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). If this is not where your Marketo data is (for example, if your Marketo schema is named `marketo_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  marketo_database: your_database_name
  marketo_schema: your_schema_name 
```

For additional configurations for the source models, please visit the [Marketo source package](https://github.com/fivetran/dbt_marketo_source).

## Step 4: Enabling/Disabling Models
This package takes into consideration tables that may not be synced due to slowness caused by the Marketo API.  By default the `campaign` and `program` related-models are disabled.  If you sync these tables, enable the modeling done by adding the following to your `dbt_project.yml` file:

```yml
vars:
    marketo__enable_campaigns:   true      # Enable if Fivetran is syncing the campaign table
    marketo__enable_programs:    true      # Enable if Fivetran is syncing the program table
```

Alternatively, you may need to disable certain models. The below models can be disabled by adding them to your `dbt_project.yml` file:
```yml
vars:
    marketo__activity_delete_lead_enabled:  false     # Disable if you do not have the activity_delete_lead table 
```
## (Optional) Step 5: Additional configurations

### Tracking Different Lead History Columns
The `marketo__lead_history` model generates historical data for the columns specified by the `lead_history_columns` variable. By default, the columns tracked are `lead_status`, `urgency`, `priority`, `relative_score`, `relative_urgency`, `demographic_score_marketing`, and `behavior_score_marketing`.  If you would like to change these columns, add the following configuration to your `dbt_project.yml` file.  After adding the columns to your `dbt_project.yml` file, run the `dbt run --full-refresh` command to fully refresh any existing models.

```yml
vars:
  marketo:
    lead_history_columns: ['the','list','of','column','names']
```

### Changing the Build Schema
By default this package will build the Marketo staging models within a schema titled (<target_schema> + `marketo_source`) and Marketo final models within a schema titled (<target_schema> + `marketo`) in your target database. If this is not where you would like your modeled Marketo data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
models:
    marketo:
      +schema: my_new_schema_name # leave blank for just the target_schema
    marketo_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```

### Changing the Lead Date Range
Because of the typical volume of lead data, you may want to limit this package's models to work with a recent date range of your Marketo data (however, note that all final models are materialized as incremental tables).

By default, the package looks at all events since the earliest lead record, so do not include this variable unless you want to limit your data. To change this start date, add the following variable to your `dbt_project.yml` file:

```yml
models:
    marketo:
      marketo__first_date: "yyyy-mm-dd" 
```

## (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>
    
Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
</details>

# 🔍 Does this package have dependencies?
This dbt package is dependent on the following dbt packages. Please be aware that these dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.
    
```yml
packages:
    - package: fivetran/marketo_source
      version: [">=0.8.0", "<0.9.0"]

    - package: fivetran/fivetran_utils
      version: [">=0.3.0", "<0.4.0"]

    - package: dbt-labs/dbt_utils
      version: [">=0.8.0", "<0.9.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```

# 🙌 How is this package maintained and can I contribute?
## Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/marketo/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_marketo/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

## Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions! 

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package!

# 🏪 Are there any resources available?
- If you have questions or want to reach out for help, please refer to the [GitHub Issue](https://github.com/fivetran/dbt_marketo/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
- Have questions or want to just say hi? Book a time during our office hours [on Calendly](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or email us at solutions@fivetran.com.