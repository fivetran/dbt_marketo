{{
    config(
        materialized='incremental',
        partition_by = {{ ['date_day'] if target.type = 'databricks' else {'field': 'date_day', 'data_type': 'date'} }},
        unique_key='lead_day_id'
    )
}}

with calendar as (

    select *
    from {{ ref('marketo__calendar_spine') }}
    {% if is_incremental() %}
    where date_day >= (select max(date_day) from {{ this }})
    {% endif %}

), leads as (

    select *
    from {{ var('lead') }}
    
), joined as (

    select 
        calendar.date_day,
        leads.lead_id
    from calendar
    inner join leads
        on calendar.date_day >= cast(leads.created_timestamp as date)

), surrogate_key as (

    select
        *,
        {{ dbt_utils.surrogate_key(['date_day','lead_id']) }} as lead_day_id
    from joined

)

select *
from surrogate_key