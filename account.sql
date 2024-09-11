SELECT
    account_id,
    NULLIF(customer_name, '') AS customer_name, -- Handle empty strings
    NULLIF(email, '') AS email,
    NULLIF(phone_number, '') AS phone_number,
    NULLIF(subscription_type, '') AS subscription_type,
    TO_DATE(NULLIF(subscription_start_date, ''), 'YYYY-MM-DD') AS subscription_start_date, -- Convert to proper date
    TO_DATE(NULLIF(subscription_end_date, ''), 'YYYY-MM-DD') AS subscription_end_date, -- Convert to proper date
    NULLIF(status, '') AS status,
    created_at,
    updated_at
FROM
    {{ source('name_source', 'raw_accounts') }}
WHERE
    status IS NOT NULL; -- Ensure there is a valid account status
Key Columns:
