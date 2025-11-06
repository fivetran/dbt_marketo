{{ config(enabled=var('marketo__enable_campaigns', True) and var('marketo__enable_programs', True)) }}

{{
    marketo.marketo_union_connections(
        connection_dictionary='marketo_sources',
        single_source_name='marketo',
        single_table_name='program'
    )
}}
