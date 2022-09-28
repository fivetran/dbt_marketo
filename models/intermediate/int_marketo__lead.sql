with leads as(
    select * 
    from {{ ref('int_marketo__lead') }} --check the name

), activity_merge_leads as (
    select * 
    from {{ var('activity_merge_lead') }} --check the name

--If you use activity_delete_lead tags this will be included, if not it will be ignored.
{% if var('marketo__activity_delete_lead_enabled', True) %}
), deleted_leads as (

    select *
    from {{ var('activity_delete_lead') }}
{% endif %}

), unique_merges as (

    select 
        cast(lead_id as {{ dbt_utils.type_int() }}) as lead_id,
        {{ fivetran_utils.string_agg('distinct merged_lead_id', "', '") }} as merged_into_lead_id

    from activity_merge_leads
    group by lead_id 

), joined as (

    select 
        leads.*,

        --If you use activity_delete_lead tags this will be included, if not it will be ignored.
        {% if var('marketo__activity_delete_lead_enabled', True) %}
        case when deleted_leads.lead_id is not null then True else False end as is_deleted,
        {% endif %}

        unique_merges.merged_into_lead_id,
        case when unique_merges.merged_into_lead_id is not null then True else False end as is_merged
    from leads

    --If you use activity_delete_lead tags this will be included, if not it will be ignored.
    {% if var('marketo__activity_delete_lead_enabled', True) %}
    left join deleted_leads on leads.lead_id = deleted_leads.lead_id
    {% endif %}

    left join unique_merges on leads.lead_id = unique_merges.lead_id 
)

select *
from joined