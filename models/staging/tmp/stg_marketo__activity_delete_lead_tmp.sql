{{ config(enabled=var('marketo__activity_delete_lead_enabled', True)) }}

{{
    fivetran_utils.union_connections(
        connection_dictionary='marketo_sources',
        single_source_name='marketo',
        single_table_name='activity_delete_lead'
    )
}}
