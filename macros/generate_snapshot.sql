{% macro generate_snapshot(snapshot_name, source_name, table_name, strategy='timestamp', target_schema='snapshots', optional_args=False) %}

{% set snapshot_model_sql %}

{% raw %}
{{
    config(
{% endraw %}
        target_schema='{{target_schema}}',
        strategy='{{strategy}}',
        {% if strategy == 'timestamp' -%}
        updated_at = "",
        {% else -%}
        check_cols = "",
        {% endif -%}
        unique_key = "",
        {% if optional_args -%}
        invalidate_hard_deletes = True, 
        target_database = "",
        {% endif -%}
{% raw %}
    )
}}
{% endraw %}

{{ '{% snapshot ' ~ snapshot_name  ~ ' %}' }}

    select * from {% raw %}{{ source({% endraw %}'{{ source_name }}', '{{ table_name }}'{% raw %}) }}{% endraw %}

{% raw -%}{% endsnapshot %} {% endraw %}

{% endset %}

{% if execute %}

{{ log(snapshot_model_sql, info=True) }}
{% do return(snapshot_model_sql) %}

{% endif %}

{% endmacro %}
