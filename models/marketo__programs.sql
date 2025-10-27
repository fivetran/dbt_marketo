{{ config(enabled=var('marketo__enable_campaigns', True) and var('marketo__enable_programs', True)) }}

with programs as (

    select *
    from {{ ref('stg_marketo__program') }}

), email_stats as (

    select *
    from {{ ref('marketo__email_stats__by_program') }}

), joined as (

    select
        programs.*,
        coalesce(email_stats.count_sends, 0) as count_sends,
        coalesce(email_stats.count_opens, 0) as count_opens,
        coalesce(email_stats.count_bounces, 0) as count_bounces,
        coalesce(email_stats.count_clicks, 0) as count_clicks,
        coalesce(email_stats.count_deliveries, 0) as count_deliveries,
        coalesce(email_stats.count_unsubscribes, 0) as count_unsubscribes,
        coalesce(email_stats.count_unique_opens, 0) as count_unique_opens,
        coalesce(email_stats.count_unique_clicks, 0) as count_unique_clicks
    from programs
    left join email_stats
        on programs.source_relation = email_stats.source_relation
        and programs.program_id = email_stats.program_id

)

select *
from joined