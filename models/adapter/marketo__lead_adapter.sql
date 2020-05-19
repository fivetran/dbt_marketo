{{ config(materialized='ephemeral') }}

select * from {{ var('lead') }}