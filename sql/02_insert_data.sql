-- Exemplo de carga via COPY no PostgreSQL
COPY customers(customer_id, customer_name, age, account_age_days, home_country, email_domain, is_vip)
FROM 'C:/caminho/completo/para/seu/projeto/fraud-detection-analytics-case/data/raw/customers.csv'
DELIMITER ','
CSV HEADER;

COPY transactions(transaction_id, customer_id, transaction_date, amount, merchant_id, merchant_category,
payment_method, device_type, device_id, ip_address, transaction_country, chargeback, is_fraud)
FROM 'C:/caminho/completo/para/seu/projeto/fraud-detection-analytics-case/data/raw/transactions.csv'
DELIMITER ','
CSV HEADER;