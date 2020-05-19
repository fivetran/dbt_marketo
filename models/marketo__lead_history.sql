{%- set change_data_columns = adapter.get_columns_in_relation(ref('marketo__change_data_scd')) -%}

{% set coalesce_value = {
 'STRING': "'DUMMY_STRING'",
 'BOOLEAN': 'null',
 'INT64': 999999999,
 'FLOAT64': 999999999.99,
 'TIMESTAMP': 'cast("2099-12-31" as timestamp)',
} %}

with change_data as (

    select *
    from {{ ref('marketo__change_data_scd') }}

), calendar as (

    select *
    from {{ ref('marketo__lead_calendar_spine') }}

), joined as (

    select 
        calendar.date_day,
        calendar.lead_id,
        change_data.lead_id is not null as new_values_present,
        {% for col in change_data_columns if col.name not in ['lead_id','valid_to'] %} 
        {{ col.name }} {% if not loop.last %},{% endif %}
        {% endfor %}
    from calendar
    left join change_data
        on calendar.lead_id = change_data.lead_id
        and calendar.date_day = change_data.valid_to

), backfill as (

    select
        date_day,
        lead_id,        
        {% for col in change_data_columns if col.name not in ['lead_id','valid_to'] %} 
        nullif(
            first_value(case when new_values_present then coalesce({{ col.name }}, {{ coalesce_value[col.data_type] }}) end ignore nulls) over (
                partition by lead_id 
                order by date_day asc 
                rows between current row and unbounded following),  
            {{ coalesce_value[col.data_type] }})
        as {{ col.name }}
        {% if not loop.last %},{% endif %}
        {% endfor %}
    from joined

)

select *
from backfill