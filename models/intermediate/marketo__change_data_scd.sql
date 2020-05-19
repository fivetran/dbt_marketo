{%- set lead_columns = adapter.get_columns_in_relation(ref('marketo__lead_adapter')) -%}
{%- set change_data_columns = adapter.get_columns_in_relation(ref('marketo__change_data_pivot')) -%}
{%- set change_data_columns_xf = change_data_columns|map(attribute='name')|list %}

{% set coalesce_value = {
 'STRING': "'DUMMY_STRING'",
 'BOOLEAN': 'null',
 'INT64': 999999999,
 'FLOAT64': 999999999.99,
 'TIMESTAMP': 'cast("2099-12-31" as timestamp)',

} %}
    
with unioned as (

    {{ dbt_utils.union_relations(relations=[
        ref('marketo__lead_adapter'),
        ref('marketo__change_data_pivot')
    ]) }}

), details as (

    select *
    from {{ ref('marketo__change_data_details') }}

), today as (

    select 
        coalesce(unioned.date_day, current_date) as valid_to, 
        unioned.lead_id,
        {% for col in lead_columns if col.name not in  ['lead_id','_fivetran_synced'] and col.name in var('lead_history_columns') %} 
        {% if col.name not in change_data_columns_xf %}
        last_value(unioned.{{ col.name }}) over (partition by unioned.lead_id order by unioned.date_day asc) as {{ col.name }}
        {% else %}
        case
            when coalesce(details.{{ col.name }}, True) then unioned.{{ col.name }}
            else nullif(

                first_value(case when coalesce(details.{{ col.name }}, True) then coalesce(unioned.{{ col.name}}, {{ coalesce_value[col.data_type] }}) end ignore nulls) over (
                    partition by unioned.lead_id 
                    order by coalesce(unioned.date_day, current_date) asc 
                    rows between 1 following and unbounded following), 
                    
                    {{ coalesce_value[col.data_type] }})
        end as {{ col.name }}
        {% endif %}
        {% if not loop.last %},{% endif %}
        {% endfor %}

    from unioned
    left join details
        on unioned.date_day = details.date_day
        and unioned.lead_id = details.lead_id

)

select *
from today