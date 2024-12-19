#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools
pip install -r integration_tests/requirements.txt
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests
dbt deps
dbt seed --target "$db" --full-refresh
dbt run --target "$db" --full-refresh
dbt test --target "$db"
## UPDATE FOR VARS HERE, IF NO VARS, PLEASE REMOVE
dbt run --vars '{lead_history_columns: ['first_name', 'lead_status', 'urgency', 'priority', 'relative_score', 'relative_urgency', 'demographic_score_marketing', 'behavior_score_marketing'], marketo__enable_campaigns: false, marketo__enable_programs: false, marketo__activity_delete_lead_enabled: false}' --target "$db" --full-refresh
dbt test --target "$db" --vars '{lead_history_columns: ['first_name', 'lead_status', 'urgency', 'priority', 'relative_score', 'relative_urgency', 'demographic_score_marketing', 'behavior_score_marketing'], marketo__enable_campaigns: false, marketo__enable_programs: false, marketo__activity_delete_lead_enabled: false}' --target "$db"
### END VARS CHUNK, REMOVE IF NOT USING
dbt run-operation fivetran_utils.drop_schemas_automation --target "$db"
