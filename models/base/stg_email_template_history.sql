with base as (

    select *
    from {{ source('marketo','email_template_history') }}

), fields as (

    select 
        id as email_template_id,
        updated_at as updated_timestamp,
        created_at as created_timestamp,
        description,
        operational as is_operational
    from base

), versions as (

    select  
        *,
        row_number() over (partition by email_template_id order by updated_timestamp) as inferred_version
    from fields

), valid as (

    select
        *,
        case
            when inferred_version = 1 then created_timestamp
            else updated_timestamp
        end as valid_from,
        lead(updated_timestamp) over (partition by email_template_id order by updated_timestamp) as valid_to
    from versions

)

select *
from valid
