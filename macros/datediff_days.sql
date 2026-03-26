{% macro datediff_days(start_date, end_date) -%}
  {{ return(adapter.dispatch('datediff_days')(start_date, end_date)) }}
{%- endmacro %}

{% macro default__datediff_days(start_date, end_date) -%}
  datediff(day, {{ start_date }}, {{ end_date }})
{%- endmacro %}

{% macro snowflake__datediff_days(start_date, end_date) -%}
  datediff(day, {{ start_date }}, {{ end_date }})
{%- endmacro %}

{% macro databricks__datediff_days(start_date, end_date) -%}
  datediff({{ end_date }}, {{ start_date }})
{%- endmacro %}