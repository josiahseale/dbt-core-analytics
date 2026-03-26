{% macro type_timestamp() -%}
  {{ return(adapter.dispatch('type_timestamp')()) }}
{%- endmacro %}

{% macro default__type_timestamp() -%}
  timestamp
{%- endmacro %}

{% macro snowflake__type_timestamp() -%}
  timestamp
{%- endmacro %}

{% macro databricks__type_timestamp() -%}
  timestamp
{%- endmacro %}