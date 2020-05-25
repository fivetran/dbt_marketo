{{ config(materialized='table') }}

{% if execute -%}
    {% set results = run_query('select restname from ' ~ var('lead_describe')) %}
    {% set results_list = results.columns[0].values() %}
{% endif -%}

with change_data as (

    select *
    from {{ var('change_data_value') }}

), lead_describe as (

    select *
    from {{ var('lead_describe') }}

), joined as (

    select 
        change_data.*,
        lead_describe.restname as primary_attribute_column
    from change_data
    left join lead_describe
        on change_data.primary_attribute_value_id = lead_describe.id

), pivot as (

    select 
        lead_id,
        cast({{ dbt_utils.dateadd('day', -1, 'activity_date') }} as date) as date_day,

        {% for col in results_list if col|lower|replace("__c","_c") in var('lead_history_columns') %}
        {% set col_xf = col|lower|replace("__c","_c") %}
        max(case when lower(primary_attribute_column) = '{{ col|lower }}' then True else False end) as {{ col_xf }}
        {% if not loop.last %} , {% endif %}
        {% endfor %}
    
    from joined
    where cast(activity_date as date) < current_date
    group by 1,2

)

select *
from pivot