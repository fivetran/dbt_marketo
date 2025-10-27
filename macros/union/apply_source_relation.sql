{% macro apply_source_relation() -%}

{{ adapter.dispatch('apply_source_relation', 'marketo') () }}

{%- endmacro %}

{% macro default__apply_source_relation() -%}

{% if var('marketo_sources', []) != [] %}
, _dbt_source_relation as source_relation
{% else %}
, '{{ var("marketo_database", target.database) }}' || '.'|| '{{ var("marketo_schema", "marketo") }}' as source_relation
{% endif %}

{%- endmacro %}