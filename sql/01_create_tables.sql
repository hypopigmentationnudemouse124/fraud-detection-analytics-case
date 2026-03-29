CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(150),
    age INT,
    account_age_days INT,
    home_country VARCHAR(5),
    email_domain VARCHAR(50),
    is_vip INT
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    transaction_date TIMESTAMP,
    amount NUMERIC(12,2),
    merchant_id VARCHAR(20),
    merchant_category VARCHAR(50),
    payment_method VARCHAR(50),
    device_type VARCHAR(50),
    device_id VARCHAR(50),
    ip_address VARCHAR(50),
    transaction_country VARCHAR(5),
    chargeback INT,
    is_fraud INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);