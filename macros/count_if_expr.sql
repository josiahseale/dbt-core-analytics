{% macro count_if_expr(condition) -%}
  {{ return(adapter.dispatch('count_if_expr')(condition)) }}
{%- endmacro %}

{% macro default__count_if_expr(condition) -%}
  count_if({{ condition }})
{%- endmacro %}

{% macro snowflake__count_if_expr(condition) -%}
  count_if({{ condition }})
{%- endmacro %}

{% macro databricks__count_if_expr(condition) -%}
  sum(case when {{ condition }} then 1 else 0 end)
{%- endmacro %}