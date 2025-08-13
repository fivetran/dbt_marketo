{{ config(enabled=var('marketo__enable_campaigns', True)) }}

select *
from {{ var('campaign') }}
