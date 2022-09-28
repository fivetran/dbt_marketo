{{ config(materialized='view')}}

select * from {{ ref('int_marketo__lead') }}