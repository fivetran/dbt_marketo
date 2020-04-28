with base as (

    select *
    from {{ var('activity_change_data_value') }}
    where lead_id = 29616

), fields as (

    select 
        id,
        activity_date,
        lead_id,
        new_value,
        old_value,
        primary_attribute_value,
        primary_attribute_value_id
    from base

)

select *
from fields