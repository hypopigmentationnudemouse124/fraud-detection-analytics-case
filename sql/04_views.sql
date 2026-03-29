CREATE OR REPLACE VIEW vw_fraud_summary AS
SELECT
    t.transaction_id,
    t.customer_id,
    c.customer_name,
    c.account_age_days,
    c.home_country,
    t.transaction_date,
    t.amount,
    t.merchant_category,
    t.payment_method,
    t.device_type,
    t.transaction_country,
    t.chargeback,
    t.is_fraud,
    CASE
        WHEN t.amount > 3000 THEN 1 ELSE 0
    END AS high_amount_flag,
    CASE
        WHEN t.transaction_country <> c.home_country THEN 1 ELSE 0
    END AS cross_border_flag,
    CASE
        WHEN EXTRACT(HOUR FROM t.transaction_date) BETWEEN 0 AND 5 THEN 1 ELSE 0
    END AS late_night_flag,
    CASE
        WHEN c.account_age_days < 30 THEN 1 ELSE 0
    END AS new_account_flag
FROM transactions t
JOIN customers c
    ON t.customer_id = c.customer_id;

CREATE OR REPLACE VIEW vw_customer_risk AS
SELECT
    customer_id,
    customer_name,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_fraud_transactions,
    ROUND(SUM(amount), 2) AS total_amount,
    SUM(high_amount_flag) AS high_amount_count,
    SUM(cross_border_flag) AS cross_border_count,
    SUM(late_night_flag) AS late_night_count,
    SUM(new_account_flag) AS new_account_count,
    (
        SUM(high_amount_flag) * 2 +
        SUM(cross_border_flag) * 3 +
        SUM(late_night_flag) * 2 +
        SUM(new_account_flag) * 2 +
        SUM(is_fraud) * 5
    ) AS risk_score
FROM vw_fraud_summary
GROUP BY customer_id, customer_name;