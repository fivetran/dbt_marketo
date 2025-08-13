with activity as (

    select *
    from {{ ref('stg_marketo__activity_unsubscribe_email') }}

), aggregate as (

    select 
        email_send_id,
        count(*) as count_unsubscribes
    from activity
    group by 1

)

select * 
from aggregate

