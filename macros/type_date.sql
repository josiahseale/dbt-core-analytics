{% macro type_date(expr) -%}
  {{ return(adapter.dispatch('type_date')(expr)) }}
{%- endmacro %}

{% macro default__type_date(expr) -%}
  case
    when {{ expr }} is null then null
    when length(cast({{ expr }} as varchar)) = 8
      then to_date(cast({{ expr }} as varchar), 'YYYYMMDD')
    else null
  end
{%- endmacro %}

{% macro snowflake__type_date(expr) -%}
  case
    when {{ expr }} is null then null
    when length(cast({{ expr }} as varchar)) = 8
      then to_date(cast({{ expr }} as varchar), 'YYYYMMDD')
    else null
  end
{%- endmacro %}

{% macro databricks__type_date(expr) -%}
  case
    when {{ expr }} is null then null
    when length(cast({{ expr }} as string)) = 8
      then to_date(cast({{ expr }} as string), 'yyyyMMdd')
    else null
  end
{%- endmacro %}