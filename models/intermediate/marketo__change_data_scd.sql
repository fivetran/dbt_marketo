{# {{
    config(
        materialized='incremental',
        partition_by = {'field': 'valid_to', 'data_type': 'date'} if target.type not in ['spark','databricks'] else ['valid_to'],
        unique_key='lead_day_id',
        incremental_strategy='merge' if target.type not in ['postgres', 'redshift'] else 'delete+insert',
        file_format='delta'
        ) 
}} #}

{{
    config(
        materialized='table') }}

{%- set lead_columns = adapter.get_columns_in_relation(ref('int_marketo__lead')) -%}
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
    from {{ ref('int_marketo__lead') }}

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
            relations=[ref('int_marketo__lead'), ref('marketo__change_data_pivot')],
            aliases=['leads','change_data']
            ) 
    }}

), field_partitions as (

    select
        coalesce(unioned.date_day, current_date) as valid_to,
        unioned.date_day,
        unioned.lead_id
        
        {% for col in lead_columns if col.name|lower not in ['lead_id','_fivetran_synced'] 
            and col.name|lower in var('lead_history_columns') %} 
        , unioned.{{ col.name }}
        -- create a batch/partition once a new value is provided
        , sum(case when unioned.{{ col.name }} is null then 0 
            else 1 end) over (partition by unioned.lead_id
            order by coalesce(unioned.date_day, current_date) desc 
            rows unbounded preceding)
            as {{ col.name }}_field_partition
        {% endfor %}

    from unioned
    left join details
        on unioned.date_day = details.date_day
        and unioned.lead_id = details.lead_id

), today as (

    -- For each day where a change occurred for each lead, we backfill the values from the subsequent change, 
    -- going back in time. In order to account for changes that occur to or from null values, we need to do a coalesce
    -- with dummy values, which we nullif() at the end.
    -- The 'details' table is joined in for exactly this purpose. It tells us, even if a value is null, whether that null
    -- value is because no change occurred on that day, or because there was a change and the change involved the null value.

    select 
        field_partitions.valid_to, 
        field_partitions.lead_id
        {% for col in lead_columns if col.name|lower not in ['lead_id','_fivetran_synced'] 
            and col.name|lower in var('lead_history_columns') %} 
        ,
        {% if col.name not in change_data_columns_xf %}

        {# If the column does not exist in the change data, grab the value from the current state of the record. #}
        last_value(field_partitions.{{ col.name }}) over (
            partition by field_partitions.lead_id, {{ col.name }}_field_partition 
            order by field_partitions.valid_to asc 
            rows between unbounded preceding and current row) 
            as {{ col.name }}

        {% else %}

        case
            {# if there was a change on the day, as specified by the details table, use that value #}
            when coalesce(details.{{ col.name }}, True) then field_partitions.{{ col.name }} 

            {# otherwise, grab the most recent value from a day where a change did occur #} 
            else nullif(
                last_value(
                    case when coalesce(details.{{ col.name }}, True) 
                        then coalesce(field_partitions.{{ col.name}}, {{ marketo.dummy_coalesce_value(col) }}) end) 
                    over(partition by field_partitions.lead_id, {{ col.name }}_field_partition
                        order by valid_to asc
                        rows between 1 following and unbounded following),
                {{ marketo.dummy_coalesce_value(col) }})
        end as {{ col.name }}
        {% endif %}
        {% endfor %}

    from field_partitions
    left join details
        on field_partitions.date_day = details.date_day
        and field_partitions.lead_id = details.lead_id

), surrogate_key as (

    select 
        *,
        {{ dbt_utils.generate_surrogate_key(['lead_id','valid_to'])}} as lead_day_id
    from today

)

select *
from surrogate_key