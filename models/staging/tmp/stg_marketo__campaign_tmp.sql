{{ config(enabled=var('marketo__enable_campaigns', True)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='marketo_sources',
        single_source_name='marketo',
        single_table_name='campaign'
    )
}}
