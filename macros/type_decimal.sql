{% macro type_decimal(precision, scale) -%}
  {{ return(adapter.dispatch('type_decimal')(precision, scale)) }}
{%- endmacro %}

{% macro default__type_decimal(precision, scale) -%}
  number({{ precision }},{{ scale }})
{%- endmacro %}

{% macro snowflake__type_decimal(precision, scale) -%}
  number({{ precision }},{{ scale }})
{%- endmacro %}

{% macro databricks__type_decimal(precision, scale) -%}
  decimal({{ precision }},{{ scale }})
{%- endmacro %}