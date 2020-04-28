with base as (

    select *
    from {{ var('lead_describe') }}

), fields as (

    select
        id,
        restname 
    from base

)

select *
from fields