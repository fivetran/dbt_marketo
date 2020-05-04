with calendar as (

    select *
    from {{ ref('calendar_spine') }}

), leads as (

    select *
    from {{ ref('stg_lead') }}
    
), joined as (

    select 
        calendar.date_day,
        leads.lead_id
    from calendar
    inner join leads
        on calendar.date_day >= cast(leads.created_at as date)

)

select *
from joined