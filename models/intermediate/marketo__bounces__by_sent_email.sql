with activity as (

    select *
    from {{ ref('stg_marketo__activity_email_bounced') }}

), aggregate as (

    select
        source_relation,
        email_send_id,
        count(*) as count_bounces
    from activity
    group by 1, 2

)

select * 
from aggregate

