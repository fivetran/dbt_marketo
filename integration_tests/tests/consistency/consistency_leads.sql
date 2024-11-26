{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select count(*) as prod_row_count
    from {{ target.schema }}_marketo_prod.marketo__leads
),

dev as (
    select count(*) as dev_row_count
    from {{ target.schema }}_marketo_dev.marketo__leads
), 

count_check as (
    select *
    from prod
    join dev
        on prod.prod_row_count != dev.dev_row_count
)

select *
from count_check