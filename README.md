# Marketo dbt Package ([docs](https://fivetran.github.io/dbt_marketo/))

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_marketo/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0_,<2.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/dbt/quickstart">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

## What does this dbt package do?
- Produces modeled tables that leverage Marketo data from [Fivetran's connector](https://fivetran.com/docs/applications/marketo) in the format described by [this ERD](https://fivetran.com/docs/applications/marketo#schema).
- Enables you to better understand your Marketo email performance and how your leads change over time. The output includes models with enriched email metrics for leads, programs, email templates, and campaigns. It also includes a lead history table that shows the state of leads on every day, for a set of columns that you define.
- Generates a comprehensive data dictionary of your source and modeled Marketo data through the [dbt docs site](https://fivetran.github.io/dbt_marketo/).

<!--section="marketo_transformation_model-->
The following table provides a detailed list of all tables materialized within this package by default.

> TIP: See more details about these tables in the package's [dbt docs site](https://fivetran.github.io/dbt_marketo/).

| **Table**                | **Description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [marketo__campaigns](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__campaigns)       | Each record represents a Marketo campaign, enriched with metrics about email performance.                                                      |
| [marketo__email_sends](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__email_sends)     | Each record represents the send of a Marketo email, enriched with metrics about email performance.                                                   |
| [marketo__email_templates](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__email_templates) | Each record represents a Marketo email template, enriched with metrics about email performance.                                                |
| [marketo__lead_history](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__lead_history)    | Each record represents the state of a lead on a specific day. The columns in this model are specified with the `lead_history_columns` variable. The start date is configured by the `marketo__first_date` variable, which by default, for dbt Core™ users, is the date of the earliest lead record, and for Fivetran Quickstart Data Model users, is 18 months in the past. There is currently no way to adjust this within the Quickstart environment, though incremental model runs will slowly look further and further in the past. However, please be aware that a full refresh will reset the clock and limit data to 18 months prior. |
| [marketo__leads](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__leads)           | Each record represents a Marketo lead, enriched with metrics about email performance.                                                          |
| [marketo__programs](https://fivetran.github.io/dbt_marketo/#!/model/model.marketo.marketo__programs)         | Each record represents a Marketo program, enriched with metrics about email performance.                                                       |

### Materialized Models
Each Quickstart transformation job run materializes 40 models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.
<!--section-end-->

## How do I use the dbt package?

### Step 1: Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Marketo connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.

#### Databricks Dispatch Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Step 2: Install the package
Include the following Marketo package version in your `packages.yml` file.

> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

```yml
packages:
  - package: fivetran/marketo
    version: [">=1.1.0", "<1.2.0"]
```
> All required sources and staging models are now bundled into this transformation package. Do not include `fivetran/marketo_source` in your `packages.yml` since this package has been deprecated.

### Step 3: Define database and schema variables

#### Option A: Single connection
By default, this package runs using your [destination](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile) and the `marketo` schema. If this is not where your Marketo data is (for example, if your Marketo schema is named `marketo_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
  marketo:
    marketo_database: your_database_name
    marketo_schema: your_schema_name
```

#### Option B: Union multiple connections
If you have multiple Marketo connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. For each source table, the package will union all of the data together and pass the unioned table into the transformations. The `source_relation` column in each model indicates the origin of each record.

To use this functionality, you will need to set the `marketo_sources` variable in your root `dbt_project.yml` file:

```yml
# dbt_project.yml

vars:
  marketo:
    marketo_sources:
      - database: connection_1_destination_name # Required
        schema: connection_1_schema_name # Required
        name: connection_1_source_name # Required only if following the step in the following subsection

      - database: connection_2_destination_name
        schema: connection_2_schema_name
        name: connection_2_source_name
```

##### Recommended: Incorporate unioned sources into DAG
> *If you are running the package through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore), the below step is necessary in order to synchronize model runs with your Marketo connections. Alternatively, you may choose to run the package through Fivetran [Quickstart](https://fivetran.com/docs/transformations/quickstart), which would create separate sets of models for each Marketo source rather than one set of unioned models.*

By default, this package defines one single-connection source, called `marketo`, which will be disabled if you are unioning multiple connections. This means that your DAG will not include your Marketo sources, though the package will run successfully.

To properly incorporate all of your Marketo connections into your project's DAG:
1. Define each of your sources in a `.yml` file in the models directory of your project. Utilize the following template for the `source`-level configurations, and, **most importantly**, copy and paste the table and column-level definitions from the package's `src_marketo.yml` [file](https://github.com/fivetran/dbt_marketo/blob/main/models/staging/src_marketo.yml).

```yml
# a .yml file in your root project

version: 2

sources:
  - name: <name> # ex: Should match name in marketo_sources
    schema: <schema_name>
    database: <database_name>
    loader: fivetran
    config:
      loaded_at_field: _fivetran_synced
      freshness: # feel free to adjust to your liking
        warn_after: {count: 72, period: hour}
        error_after: {count: 168, period: hour}

    tables: # copy and paste from marketo/models/staging/src_marketo.yml - see https://support.atlassian.com/bitbucket-cloud/docs/yaml-anchors/ for how to use anchors to only do so once
```

> **Note**: If there are source tables you do not have (see [Step 4](https://github.com/fivetran/dbt_marketo?tab=readme-ov-file#step-4-enablingdisabling-models)), you may still include them, as long as you have set the right variables to `False`.

2. Set the `has_defined_sources` variable (scoped to the `marketo` package) to `True`, like such:
```yml
# dbt_project.yml
vars:
  marketo:
    has_defined_sources: true
```

### Step 4: Enabling/Disabling Models
This package takes into consideration tables that may not be synced due to slowness caused by the Marketo API. By default the `campaign`, `program`, and `activity_delete_lead` tables are enabled. If you do not sync these tables, disable the related models or fields by adding the following to your `dbt_project.yml` file:
```yml
vars:
    marketo__enable_campaigns:   False      # Disable if Fivetran is not syncing the campaign table. This will disable the marketo__campaigns, marketo__programs, marketo__email_stats__by_campaign, marketo__email_stats__by_program models.
    marketo__enable_programs:    False      # Disable if Fivetran is not syncing the program table. This will disable the marketo__programs and marketo__email_stats__by_program models.
    marketo__activity_delete_lead_enabled:  false     # Disable if Fivetran is not syncing the activity_delete_lead table
```

### (Optional) Step 5: Additional configurations
<details open><summary>Expand/Collapse details</summary>
<br>

#### Passing Through Additional Columns
This package includes all source columns defined in this package's [staging macros folder](https://github.com/fivetran/dbt_marketo/tree/main/macros/staging). If you would like to pass through additional columns to the staging models, add the following configurations to your `dbt_project.yml` file. These variables allow for the pass-through fields to be aliased (`alias`) and casted (`transform_sql`) if desired, but not required. Datatype casting is configured via a sql snippet within the `transform_sql` key. You may add the desired sql while omitting the `as field_name` at the end and your custom pass-though fields will be casted accordingly. Use the below format for declaring the respective pass-through variables in your root `dbt_project.yml`.
```yml
vars:
    marketo__activity_send_email_passthrough_columns: 
      - name: "new_custom_field"
        alias: "custom_field_name"
        transform_sql:  "cast(custom_field_name as int64)"
      - name: "a_second_field"
        transform_sql:  "cast(a_second_field as string)"
    # a similar pattern can be applied to the rest of the following variables.
    marketo__program_passthrough_columns:
```

#### Tracking Different Lead History Columns
The `marketo__lead_history` model generates historical data for the columns specified by the `lead_history_columns` variable. By default, the columns tracked are `lead_status`, `urgency`, `priority`, `relative_score`, `relative_urgency`, `demographic_score_marketing`, and `behavior_score_marketing`.  If you would like to change these columns, add the following configuration to your `dbt_project.yml` file.  After adding the columns to your `dbt_project.yml` file, run the `dbt run --full-refresh` command to fully refresh any existing models.

```yml
vars:
  marketo:
    lead_history_columns: ['the','list','of','column','names']
```

#### Changing the Build Schema
By default this package will build the Marketo staging models within a schema titled (<target_schema> + `_marketo_source`) and Marketo final models within a schema titled (<target_schema> + `marketo`) in your target database. If this is not where you would like your modeled Marketo data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
models:
    marketo:
      +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
      staging:
        +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
```

#### Change the source table references
If an individual source table has a different name than what the package expects, add the table name as it appears in your destination to the respective variable:
> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_marketo/blob/main/dbt_project.yml) variable declarations to see the expected names.
    
```yml
vars:
    marketo_<default_source_table_name>_identifier: "your_table_name"
```

#### Changing the Lead Date Range
Because of the typical volume of lead data, you may want to limit this package's models to work with a recent date range of your Marketo data (however, note that all final models are materialized as incremental tables).

By default, for dbt Core™ users, the package looks at all events since the earliest lead record, so do not include this variable unless you want to limit your `marketo__lead_history` data. To change this start date, add the following variable to your `dbt_project.yml` file:

```yml
models:
    marketo:
      marketo__first_date: "yyyy-mm-dd" 
```

> For Fivetran Quickstart Data Model users, the package will look 18 months in the past. There is currently no way to adjust this within the Quickstart environment, though incremental runs will slowly look further and further in the past. However, please be aware that a full refresh will reset the clock and limit data to 18 months prior.

</details>

### (Optional) Step 6: Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for details</summary>
<br>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt#setupguide).
</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```

## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package _only_ maintains the latest version of the package. We highly recommend you stay consistent with the [latest version](https://hub.getdbt.com/fivetran/marketo/latest/) of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_marketo/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Check out [this dbt Discourse article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_marketo/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
