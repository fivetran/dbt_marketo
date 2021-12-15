[![Apache License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) ![dbt Logo and Version](https://img.shields.io/static/v1?logo=dbt&label=dbt-version&message=>=1.0.0,<2.0.0&color=orange)
# Marketo ([docs](https://fivetran-dbt-marketo.netlify.app/#!/overview))

This package models Marketo data from [Fivetran's connector](https://fivetran.com/docs/applications/marketo). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/marketo#schema).

This package enables you to better understand your Marketo email performance and how your leads change over time. The output includes models with enriched email metrics for leads, programs, email templates, and campaigns. It also includes a lead history table that shows the state of leads on every day, for a set of columns that you define.

## Models

This package contains transformation models, designed to work simultaneously with our [Marketo source package](https://github.com/fivetran/dbt_marketo_source). A dependency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below. Intermediate models are used to create these output models.

| **model**                | **description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| [marketo__campaigns](models/marketo__campaigns.sql)       | Each record represents a Marketo campaign, enriched with metrics about email performance.                                                      |
| [marketo__email_sends](models/marketo__email_sends.sql)     | Each record represents the send of a Marketo email, enriched with metrics about email performance.                                                   |
| [marketo__email_templates](models/marketo__email_templates.sql) | Each record represents a Marketo email template, enriched with metrics about email performance.                                                |
| [marketo__lead_history](models/marketo__lead_history.sql)    | Each record represents the state of a lead on a specific day. The columns in this model are specified with the `lead_history_columns` variable. |
| [marketo__leads](models/marketo__leads.sql)           | Each record represents a Marketo lead, enriched with metrics about email performance.                                                          |
| [marketo__programs](models/marketo__programs.sql)         | Each record represents a Marketo program, enriched with metrics about email performance.                                                       |


## Installation Instructions
`dbt_marketo` currently supports `dbt 0.20.x`.

Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

Include in your `packages.yml`

```yaml
packages:
  - package: fivetran/marketo
    version: [">=0.6.0", "<0.7.0"]
```

## Configuration
By default, this package will look for your Marketo data in the `marketo` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). If this is not where your Marketo data is , please add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
config-version: 2

vars:
  marketo_source:
    marketo_database: your_database_name
    marketo_schema: your_schema_name 
```

For additional configurations for the source models, please visit the [Marketo source package](https://github.com/fivetran/dbt_marketo_source).

### Tracking Different Lead History Columns
The `marketo__lead_history` model generates historical data for the columns specified by the `lead_history_columns` variable. By default, the columns tracked are `lead_status`, `urgency`, `priority`, `relative_score`, `relative_urgency`, `demographic_score_marketing`, and `behavior_score_marketing`.  If you would like to change these columns, add the following configuration to your `dbt_project.yml` file.  After adding the columns to your `dbt_project.yml` file, run the `dbt run --full-refresh` command to fully refresh any existing models.

```yml
# dbt_project.yml

...
config-version: 2

vars:
  marketo:
    lead_history_columns: ['the','list','of','column','names']
```

### Changing the Build Schema
By default this package will build the Marketo staging models within a schema titled (<target_schema> + `_stg_marketo`) and Marketo final models within a schema titled (<target_schema> + `marketo`) in your target database. If this is not where you would like your modeled Marketo data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
models:
    marketo:
      +schema: my_new_schema_name # leave blank for just the target_schema
    marketo_source:
      +schema: my_new_schema_name # leave blank for just the target_schema
```

### Enabling Models
This package takes into consideration tables that may not be synced due to slowness caused by the Marketo API.  By default the `campaign` and `program` related-models are disabled.  If you sync these tables, enable the modeling done by adding the following to your `dbt_project.yml` file:
```yml
# dbt_project.yml

...
vars:
    marketo__enable_campaigns:  True         #Enable if Fivetran is syncing the campaign table
    marketo__enable_programs:   True         #Enable if Fivetran is syncing the program table
```

## Contributions
Additional contributions to this package are very welcome! Please create issues
or open PRs against `main`. Check out 
[this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package.

## Database Support
This package has been tested on BigQuery, Snowflake and Redshift.

## Resources:
- Provide [feedback](https://www.surveymonkey.com/r/DQ7K7WW) on our existing dbt packages or what you'd like to see next
- Have questions, feedback, or need help? Book a time during our office hours [using Calendly](https://calendly.com/fivetran-solutions-team/fivetran-solutions-team-office-hours) or email us at solutions@fivetran.com
- Find all of Fivetran's pre-built dbt packages in our [dbt hub](https://hub.getdbt.com/fivetran/)
- Learn how to orchestrate [dbt transformations with Fivetran](https://fivetran.com/docs/transformations/dbt)
- Learn more about Fivetran overall [in our docs](https://fivetran.com/docs)
- Check out [Fivetran's blog](https://fivetran.com/blog)
- Learn more about dbt [in the dbt docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the dbt blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
