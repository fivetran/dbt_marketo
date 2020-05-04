with spine as (

{{
    dbt_utils.date_spine(
        "day",
        "'2016-01-01'",
        dbt_utils.dateadd("week", 1, "current_date")
    )   
}}

), recast as (

    select cast(date_day as date) as date_day
    from spine

)

select *
from recast