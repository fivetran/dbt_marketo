## Decision Log

### `action_result` Field Introduction
We added the `action_result` field to capture email action outcomes in the following tables:

- `stg_marketo__activity_send_email`
- `marketo__email_sends_deduped`
- `marketo__email_sends`

Initially, we considered adding `action_result` to further downstream models, such as `marketo__email_stats__by_email_template`, `marketo__email_stats__by_lead`, `marketo__email_templates`, and `marketo__leads`. However, this would require a finer grain, potentially doubling the size of these tables.

To minimize customer impact, we limited adding `action_result` to models where it does not alter data grain. Users needing `action_result` in aggregate models can derive it from the `marketo__email_sends` model using custom aggregation logic.
