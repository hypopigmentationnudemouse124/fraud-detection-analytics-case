-- 1. Taxa geral de fraude
SELECT
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_frauds,
    ROUND(100.0 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM transactions;

-- 2. Chargeback rate
SELECT
    COUNT(*) AS total_transactions,
    SUM(chargeback) AS total_chargebacks,
    ROUND(100.0 * SUM(chargeback) / COUNT(*), 2) AS chargeback_rate_pct
FROM transactions;

-- 3. Fraude por categoria de merchant
SELECT
    merchant_category,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_frauds,
    ROUND(100.0 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM transactions
GROUP BY merchant_category
ORDER BY fraud_rate_pct DESC, total_frauds DESC;

-- 4. Fraude por país da transação
SELECT
    transaction_country,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_frauds,
    ROUND(100.0 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM transactions
GROUP BY transaction_country
ORDER BY fraud_rate_pct DESC;

-- 5. Fraude por método de pagamento
SELECT
    payment_method,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_frauds,
    ROUND(100.0 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM transactions
GROUP BY payment_method
ORDER BY fraud_rate_pct DESC;

-- 6. Ticket médio de fraude vs não fraude
SELECT
    is_fraud,
    ROUND(AVG(amount), 2) AS avg_amount,
    MAX(amount) AS max_amount,
    MIN(amount) AS min_amount
FROM transactions
GROUP BY is_fraud;

-- 7. Clientes com maior volume de fraude
SELECT
    t.customer_id,
    c.customer_name,
    COUNT(*) AS total_transactions,
    SUM(t.is_fraud) AS fraud_transactions,
    ROUND(SUM(t.amount), 2) AS total_amount,
    ROUND(SUM(CASE WHEN t.is_fraud = 1 THEN t.amount ELSE 0 END), 2) AS fraud_amount
FROM transactions t
JOIN customers c
    ON t.customer_id = c.customer_id
GROUP BY t.customer_id, c.customer_name
HAVING SUM(t.is_fraud) > 0
ORDER BY fraud_transactions DESC, fraud_amount DESC
LIMIT 20;

-- 8. Fraude por faixa horária
SELECT
    EXTRACT(HOUR FROM transaction_date) AS transaction_hour,
    COUNT(*) AS total_transactions,
    SUM(is_fraud) AS total_frauds,
    ROUND(100.0 * SUM(is_fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM transactions
GROUP BY EXTRACT(HOUR FROM transaction_date)
ORDER BY transaction_hour;

-- 9. Fraude em contas novas
SELECT
    CASE
        WHEN c.account_age_days < 30 THEN 'new_account'
        WHEN c.account_age_days BETWEEN 30 AND 180 THEN 'mid_account'
        ELSE 'mature_account'
    END AS account_age_group,
    COUNT(*) AS total_transactions,
    SUM(t.is_fraud) AS total_frauds,
    ROUND(100.0 * SUM(t.is_fraud) / COUNT(*), 2) AS fraud_rate_pct
FROM transactions t
JOIN customers c
    ON t.customer_id = c.customer_id
GROUP BY
    CASE
        WHEN c.account_age_days < 30 THEN 'new_account'
        WHEN c.account_age_days BETWEEN 30 AND 180 THEN 'mid_account'
        ELSE 'mature_account'
    END
ORDER BY fraud_rate_pct DESC;

-- 10. Detecção de múltiplas transações em curto intervalo por cliente
SELECT
    customer_id,
    DATE_TRUNC('hour', transaction_date) AS transaction_hour,
    COUNT(*) AS transactions_in_hour,
    ROUND(SUM(amount), 2) AS total_amount_in_hour,
    SUM(is_fraud) AS frauds_in_hour
FROM transactions
GROUP BY customer_id, DATE_TRUNC('hour', transaction_date)
HAVING COUNT(*) >= 5
ORDER BY transactions_in_hour DESC, total_amount_in_hour DESC;

-- 11. Detecção de clientes transacionando em país diferente do país de origem
SELECT
    t.customer_id,
    c.customer_name,
    c.home_country,
    t.transaction_country,
    COUNT(*) AS total_transactions,
    SUM(t.is_fraud) AS total_frauds
FROM transactions t
JOIN customers c
    ON t.customer_id = c.customer_id
WHERE t.transaction_country <> c.home_country
GROUP BY t.customer_id, c.customer_name, c.home_country, t.transaction_country
ORDER BY total_frauds DESC, total_transactions DESC;

-- 12. Ranking de risco por cliente
SELECT
    t.customer_id,
    c.customer_name,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN t.amount > 3000 THEN 1 ELSE 0 END) AS high_value_txns,
    SUM(CASE WHEN t.transaction_country <> c.home_country THEN 1 ELSE 0 END) AS cross_border_txns,
    SUM(CASE WHEN EXTRACT(HOUR FROM t.transaction_date) BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS night_txns,
    SUM(t.is_fraud) AS fraud_txns
FROM transactions t
JOIN customers c
    ON t.customer_id = c.customer_id
GROUP BY t.customer_id, c.customer_name
ORDER BY fraud_txns DESC, cross_border_txns DESC, high_value_txns DESC
LIMIT 30;