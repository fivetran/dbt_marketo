# Marketo 

This package models Marketo data from [Fivetran's connector](https://fivetran.com/docs/applications/marketo). It uses data in the format described by [this ERD](https://docs.google.com/presentation/d/1TauFmnr89QV1KV_Un7kJ-KJWOQt1fbp59a1xJLUdDDY/edit).

This package enables you to better understand your Marketo email performance and how your leads change over time. The output includes models with enriched email metrics for leads, programs, email_templates, and campaigns. It also includes a lead history table that shows the state of leads on every day, for a set of columns that you define.

## Models

This package contains transformation models, designed to work simultaneously with our [Marketo source package](https://github.com/fivetran/dbt_marketo_source). A depenedency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below. Intermediate models are used to create these output models.

| **model**                | **description**                                                                                                                                |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| marketo__campaigns       | Each record represents a Marketo campaign, enriched with metrics about email performance.                                                      |
| marketo__email_sends     | Each record represents the send of a Marketo email, enriched with metrics about email performance.                                                   |
| marketo__email_templates | Each record represents a Marketo email template, enriched with metrics about email performance.                                                |
| marketo__lead_history    | Each record represents the state of a lead on a specific day. The columns in this model are specified with the `lead_history_columns` variable. |
| marketo__leads           | Each record represents a Marketo lead, enriched with metrics about email performance.                                                          |
| marketo__program         | Each record represents a Marketo program, enriched with metrics about email performance.                                                       |


## Installation Instructions
Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

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

The `marketo__lead_history` model generates historical data for the columns specified by the `lead_history_columns` variable. By default, the columns tracked are `lead_status`, `urgency`, `priority`, `relative_score`, `relative_urgency`, `demographic_score_marketing`, and `behavior_score_marketing`.  If you would like to change these columns, add the following configuration to your `dbt_project.yml` file.  After adding the columns to your `dbt_project.yml` file, run the `dbt run --full-refresh` command to fully refresh any existing models.

```yml
# dbt_project.yml

...
config-version: 2

vars:
  marketo:
    lead_history_columns: ['the','list','of','column','names']
```

## Contributions

Additional contributions to this package are very welcome! Please create issues
or open PRs against `master`. Check out 
[this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) 
on the best workflow for contributing to a package.

## Resources:
- Learn more about Fivetran [here](https://fivetran.com/docs)
- Check out [Fivetran's blog](https://fivetran.com/blog)
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
