with base as (

    select *
    from {{ source('marketo','lead') }}
    -- where id = 29616

), fields as (

    select
        id as lead_id,
        {{ dbt_utils.star(from=source('marketo','lead'), except=['id']) }}
    from base

)

select *
from fields
