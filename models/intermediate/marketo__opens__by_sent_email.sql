with activity as (

    select *
    from {{ ref('stg_marketo__activity_open_email') }}

), aggregate as (

    select
        source_relation,
        email_send_id,
        count(*) as count_opens
    from activity
    group by 1, 2

)

select * 
from aggregate

