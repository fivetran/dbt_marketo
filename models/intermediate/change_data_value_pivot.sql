{% set results = run_query('select restname from ' ~ ref('stg_lead_describe')) %}

{% if execute %}
{# Return the first column #}
{% set results_list = results.columns[0].values() %}
{% else %}
{% set results_list = [] %}
{% endif %}

with change_data as (

    select *
    from {{ ref('stg_activity_change_data_value') }}

), lead_describe as (

    select *
    from {{ ref('stg_lead_describe') }}

), joined as (

    select 
        change_data.*,
        lead_describe.restname as primary_attribute_column
    from change_data
    left join lead_describe
        on change_data.primary_attribute_value_id = lead_describe.id

), event_order as (

    select 
        *,
        row_number() over (
            partition by cast(activity_date as date), lead_id, primary_attribute_value_id
            order by activity_date asc
            ) as row_num
    from joined

), filtered as (

    select *
    from event_order
    where row_num = 1

), pivot as (

    select 
        cast(activity_date as date) as date_day,
        lead_id,

        {% for col in results_list %}
        {% set col_xf = col|lower|replace("__c","_c") %}
        min(case when lower(primary_attribute_column) = '{{ col_xf }}' then new_value end) as {{ col_xf }}
        {% if not loop.last %} , {% endif %}
        {% endfor %}
    
    from filtered
    group by 1,2

)

select *
from pivot