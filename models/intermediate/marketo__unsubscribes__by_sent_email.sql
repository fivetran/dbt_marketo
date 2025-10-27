with activity as (

    select *
    from {{ ref('stg_marketo__activity_unsubscribe_email') }}

), aggregate as (

    select
        source_relation,
        email_send_id,
        count(*) as count_unsubscribes
    from activity
    group by 1, 2

)

select * 
from aggregate

