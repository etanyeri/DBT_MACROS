{% macro create_share(local) %}

    {# List of ANALYTICS_PROD_INGEST schemas to be shared. UPDATE AS REQUIRED. #}
    {%- set schemas_to_share = ['JIRA', 'SFDC', 'ZUORA'] -%}
    {% set db_to_share = target.database %}
    {% set share_name = 'COMPANYNAME_' + db_to_share %}
    {%- set schema_grants_list = [] %}
    {%- set table_grants_list = [] %}

    {%- if execute %}
        {%- set share_exist_query %}
            SHOW SHARES LIKE '{{share_name}}';
        {%- endset %}
        {%- set share_exist_result = run_query(share_exist_query) %} 

        {%- set sql %}
            {# If the share doesn't exist, create it #}
            {%- if share_exist_result|length == 0 %}
                {{ log('Share does not exist. Creating share ' ~ share_name, true)}}
                CREATE SHARE IF NOT EXISTS {{share_name}};
                GRANT USAGE ON DATABASE {{db_to_share}} TO SHARE {{share_name}};
            {# If it does exist, query the existing grants to the share #}
            {%- else %}
                {%- set share_grants_query %}
                    SHOW GRANTS TO SHARE {{share_name}};
                {%- endset %}
                {%- set share_grants_result = run_query(share_grants_query) %}                
                {# Create lists of the schemas and tables/views currently granted to the share for more straightforward comparison #}
                {%- set share_grants_rows = share_grants_result.rows %}
                {%- for row in share_grants_rows %}
                    {%- if row[2]|upper == 'SCHEMA' %}
                        {%- do schema_grants_list.append(row[3]) %}
                    {%- elif row[2]|upper == 'TABLE' or row[2]|upper == 'VIEW' %}
                        {%- do table_grants_list.append(row[3]) %}
                    {%- endif %}
                {%- endfor %}
            {% endif %}
            {# Write grants for anything that isn't granted to the share but should be #}
            {%- for schema in schemas_to_share %}
                {%- if (db_to_share ~ '.' ~ schema) not in schema_grants_list %}
                    GRANT USAGE ON SCHEMA {{db_to_share}}.{{schema}} TO SHARE {{share_name}};
                {%- endif -%}
                {# Query information schema for list of tables #}
                {%- set table_list_query %}
                    SELECT TABLE_NAME, TABLE_TYPE FROM {{db_to_share}}.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '{{schema}}';
                {%- endset %}
                {%- set table_list_results = run_query(table_list_query) %}
                {%- set table_list_rows = table_list_results.rows %}
                {%- for row in table_list_rows -%}
                    {%- if (db_to_share ~ '.' ~ schema ~ '.' ~ row[0]) not in table_grants_list %}
                        {%- if row[1] == 'BASE TABLE' %}
                            GRANT SELECT ON TABLE {{db_to_share}}.{{schema}}."{{row[0]}}" TO SHARE {{share_name}};
                        {%- elif row[1] == 'VIEW' %}
                            GRANT SELECT ON VIEW {{db_to_share}}.{{schema}}."{{row[0]}}" TO SHARE {{share_name}};
                        {%- endif %}
                    {%- endif -%}
                {%- endfor -%}
            {%- endfor -%}
            {# If a schema is removed from the list, revoke access to the share #}
            {%- for schema in schema_grants_list %}
                {%- if schema.split('.')[1] not in schemas_to_share -%}
                    REVOKE USAGE ON SCHEMA {{schema}} FROM SHARE {{share_name}};
                    {# Revoke all the table level objects in that schema as well #}
                    {%- set table_revoke_query %}
                        SELECT TABLE_NAME, TABLE_TYPE FROM {{db_to_share}}.INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '{{schema.split('.')[1]}}';
                    {%- endset %}
                    {%- set table_revoke_list = run_query(table_revoke_query) %}
                    {%- set table_revoke_rows = table_revoke_list.rows %}
                    {%- for row in table_revoke_rows %}
                        {%- if row[1] == 'BASE TABLE' %}
                            REVOKE SELECT ON TABLE {{db_to_share}}.{{schema.split('.')[1]}}."{{row[0]}}" FROM SHARE {{share_name}};
                        {%- elif row[1] == 'VIEW' %}
                            REVOKE SELECT ON VIEW {{db_to_share}}.{{schema.split('.')[1]}}."{{row[0]}}" FROM SHARE {{share_name}};
                        {%- endif %}
                    {%- endfor %}
                {%- endif %}
            {%- endfor %}
        {% endset %}

        {%- if sql|trim %}
            {%- if not local %}
                {{ log('SQL executed:\n' ~ sql|trim, true) }}
                {%- set table = run_query(sql) %}
            {%- else %}
                {{ log('Script created:\n' ~ sql|trim, true)}}
            {%- endif %}
        {%- else %}
            {{ log('There are no changes to be made to the share.', true)}}
        {%- endif %}

    {% endif %}

{% endmacro %}
