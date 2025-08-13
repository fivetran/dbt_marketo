{{ config(enabled=var('marketo__enable_campaigns', True) and var('marketo__enable_programs', True)) }}

select *
from {{ var('program') }}
