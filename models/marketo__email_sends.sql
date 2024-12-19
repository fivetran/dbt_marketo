with sends as (

    select *
    from {{ ref('marketo__email_sends_deduped') }}

), opens as (

    select *
    from {{ ref('marketo__opens__by_sent_email') }}

), bounces as (

    select *
    from {{ ref('marketo__bounces__by_sent_email') }}

), clicks as (

    select *
    from {{ ref('marketo__clicks__by_sent_email') }}

), deliveries as (

    select *
    from {{ ref('marketo__deliveries__by_sent_email') }}

), unsubscribes as (

    select *
    from {{ ref('marketo__unsubscribes__by_sent_email') }}

{% if var('marketo__enable_campaigns', True) %}

), campaigns as (

    select *
    from {{ var('campaigns') }}

{% endif %}

), email_templates as (

    select *
    from {{ var('email_tempate_history') }}

), metrics as (

    select
        sends.*,
        coalesce(opens.count_opens, 0) as count_opens,
        coalesce(bounces.count_bounces, 0) as count_bounces,
        coalesce(clicks.count_clicks, 0) as count_clicks,
        coalesce(deliveries.count_deliveries, 0) as count_deliveries,
        coalesce(unsubscribes.count_unsubscribes, 0) as count_unsubscribes
    from sends
    left join opens using (email_send_id)
    left join bounces using (email_send_id)
    left join clicks using (email_send_id)
    left join deliveries using (email_send_id)
    left join unsubscribes using (email_send_id)

), booleans as (

    select
        *,
        count_opens > 0 as was_opened,
        count_bounces > 0 as was_bounced,
        count_clicks > 0 as was_clicked,
        count_deliveries > 0 as was_delivered,
        count_unsubscribes > 0 as was_unsubscribed
    from metrics

), joined as (

    select 
        booleans.*,
        {% if var('marketo__enable_campaigns', True) %}
        campaigns.campaign_type,
        campaigns.program_id,
        {% endif %}
        email_templates.is_operational
    from booleans
    {% if var('marketo__enable_campaigns', True) %}
    left join campaigns using (campaign_id)
    {% endif %}
    left join email_templates
        on booleans.email_template_id = email_templates.email_template_id
        and booleans.activity_timestamp 
            between email_templates.valid_from
            and coalesce(email_templates.valid_to, cast('2099-01-01' as timestamp))

)

select *
from joined