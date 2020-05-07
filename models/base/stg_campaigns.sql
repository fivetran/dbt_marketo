with base as (

    select *
    from {{ source('marketo','campaign') }}

), fields as (

    select 
        id as campaign_id,
        active as is_active,
        created_at as created_timestamp,
        description,
        name as campaign_name,
        program_id,
        program_name,
        type as campaign_type,
        workspace_name
    from base

)

select *
from fields