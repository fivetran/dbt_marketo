with base as (

    select *
    from {{ source('marketo','activity_email_delivered') }}

), fields as (

    select 
        id as activity_id,
        activity_date as activity_timestamp,
        campaign_id,
        campaign_run_id,
        email_template_id,
        lead_id
    from base

), surrogate as (

    select 
        *,
        {{ dbt_utils.surrogate_key(['campaign_id','campaign_run_id','lead_id']) }} as email_send_id
    from fields

)

select *
from surrogate