{% macro type_string() -%}
  {{ return(adapter.dispatch('type_string')()) }}
{%- endmacro %}

{% macro default__type_string() -%}
  varchar
{%- endmacro %}

{% macro snowflake__type_string() -%}
  varchar
{%- endmacro %}

{% macro databricks__type_string() -%}
  string
{%- endmacro %}