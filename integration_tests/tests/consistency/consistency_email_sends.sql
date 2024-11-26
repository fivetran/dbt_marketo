{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select {{ dbt_utils.star(
        from=ref('marketo__email_sends'), 
        except=['activity_id'] + var('consistency_test_exclude_metrics', [])) }} -- marketo__email_sends_deduped does not create a consistent activity_id
    from {{ target.schema }}_marketo_prod.marketo__email_sends
),

dev as (
    select {{ dbt_utils.star(
        from=ref('marketo__email_sends'),
        except=['activity_id'] + var('consistency_test_exclude_metrics', [])) }}
    from {{ target.schema }}_marketo_dev.marketo__email_sends
), 

prod_not_in_dev as (
    -- rows from prod not found in dev
    select * from prod
    except distinct
    select * from dev
),

dev_not_in_prod as (
    -- rows from dev not found in prod
    select * from dev
    except distinct
    select * from prod
),

final as (
    select
        *,
        'from prod' as source
    from prod_not_in_dev

    union all -- union since we only care if rows are produced

    select
        *,
        'from dev' as source
    from dev_not_in_prod
)

select *
from final