{{ config(materialized='view')}}

select * from {{ var('lead') }}