{{
    config(
        materialized='incremental',
        partition_by = {{ ['date_day'] if target.type = 'databricks' else {'field': 'date_day', 'data_type': 'date'} }},
        unique_key='lead_day_id'
        ) 
}}

{%- set lead_columns = adapter.get_columns_in_relation(ref('marketo__lead_adapter')) -%}
{%- set change_data_columns = adapter.get_columns_in_relation(ref('marketo__change_data_pivot')) -%}
{%- set change_data_columns_xf = change_data_columns|map(attribute='name')|list %}
    
with change_data as (

    select *
    from {{ ref('marketo__change_data_pivot') }}
    {% if is_incremental() %}
    where date_day >= (select max(valid_to) from {{ this }})
    {% endif %}

), leads as (

    select *
    from {{ ref('marketo__lead_adapter') }}

), details as (

    select *
    from {{ ref('marketo__change_data_details') }}
    {% if is_incremental() %}
    where date_day >= (select max(valid_to) from {{ this }})
    {% endif %}

), unioned as (

    -- unions together the current state of leads and their history changes. 
    -- we need the current state to work backwards from to backfill the slowly changing dimension model

    {{ 
        fivetran_utils.union_relations(
            relations=[ref('marketo__lead_adapter'), ref('marketo__change_data_pivot')],
            aliases=['leads','change_data']
            ) 
    }}

), today as (

    -- For each day where a change occurred for each lead, we backfill the values from the subsequent change, 
    -- going back in time. In order to account for changes that occur to or from null values, we need to do a coalesce
    -- with dummy values, which we nullif() at the end.
    -- The 'details' table is joined in for exactly this purpose. It tells us, even if a value is null, whether that null
    -- value is because no change occurred on that day, or because there was a change and the change involved the null value.

    select 
        coalesce(unioned.date_day, current_date) as valid_to, 
        unioned.lead_id
        {% for col in lead_columns if col.name|lower not in ['lead_id','_fivetran_synced'] and col.name|lower in var('lead_history_columns') %} 
        ,
        {% if col.name not in change_data_columns_xf %}

        {# If the column does not exist in the change data, grab the value from the current state of the record. #}
        last_value(unioned.{{ col.name }}) over (
            partition by unioned.lead_id 
            order by unioned.date_day asc 
            rows between unbounded preceding and current row) as {{ col.name }}

        {% else %}

        case
        
            {# if there was a change on the day, as specified by the details table, use that value #}
            when coalesce(details.{{ col.name }}, True) then unioned.{{ col.name }}

            {# otherwise, grab the most recent value from a day where a change did occur #} 
            else nullif(

                first_value(case when coalesce(details.{{ col.name }}, True) then coalesce(unioned.{{ col.name}}, {{ fivetran_utils.dummy_coalesce_value(col) }}) end ignore nulls) over (
                    partition by unioned.lead_id 
                    order by coalesce(unioned.date_day, current_date) asc 
                    rows between 1 following and unbounded following), 
                    
                    {{ fivetran_utils.dummy_coalesce_value(col) }})
        end as {{ col.name }}
        {% endif %}
        {% endfor %}

    from unioned
    left join details
        on unioned.date_day = details.date_day
        and unioned.lead_id = details.lead_id

), surrogate_key as (

    select 
        *,
        {{ dbt_utils.surrogate_key(['lead_id','valid_to'])}} as lead_day_id
    from today

)

select *
from surrogate_key