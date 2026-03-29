import random
from datetime import datetime, timedelta
import pandas as pd
import numpy as np
from faker import Faker

fake = Faker("pt_BR")
random.seed(42)
np.random.seed(42)

NUM_CUSTOMERS = 1000
NUM_TRANSACTIONS = 15000

countries = ["BR", "US", "AR", "PY", "CL", "MX"]
device_types = ["mobile", "desktop", "tablet"]
merchant_categories = [
    "electronics", "gaming", "fashion", "food", "travel",
    "digital_services", "marketplace", "pharmacy"
]
payment_methods = ["credit_card", "debit_card", "pix", "bank_transfer"]

def random_date(start, end):
    return start + timedelta(
        seconds=random.randint(0, int((end - start).total_seconds()))
    )

def create_customers(n):
    customers = []
    for customer_id in range(1, n + 1):
        age = random.randint(18, 70)
        account_age_days = random.randint(1, 3650)
        customers.append({
            "customer_id": customer_id,
            "customer_name": fake.name(),
            "age": age,
            "account_age_days": account_age_days,
            "home_country": random.choices(
                ["BR", "BR", "BR", "BR", "US", "AR"], k=1
            )[0],
            "email_domain": random.choice(["gmail.com", "hotmail.com", "outlook.com", "yahoo.com"]),
            "is_vip": random.choice([0, 0, 0, 1])
        })
    return pd.DataFrame(customers)

def create_transactions(customers_df, n):
    transactions = []
    start_date = datetime(2025, 1, 1)
    end_date = datetime(2025, 12, 31)

    suspicious_customers = set(random.sample(list(customers_df["customer_id"]), 50))

    for transaction_id in range(1, n + 1):
        customer_id = random.choice(list(customers_df["customer_id"]))
        customer = customers_df.loc[customers_df["customer_id"] == customer_id].iloc[0]

        transaction_date = random_date(start_date, end_date)
        amount = round(np.random.lognormal(mean=4.2, sigma=0.9), 2)
        amount = min(amount, 25000)

        merchant_category = random.choice(merchant_categories)
        payment_method = random.choice(payment_methods)
        device_type = random.choice(device_types)
        country = random.choice(countries)

        ip_address = fake.ipv4_public()
        device_id = f"DEV-{random.randint(1000, 9999)}"
        merchant_id = f"MER-{random.randint(100, 999)}"

        chargeback = 0
        is_fraud = 0

        risk_points = 0

        if customer_id in suspicious_customers:
            risk_points += 2

        if amount > 3000:
            risk_points += 2

        if country != customer["home_country"]:
            risk_points += 2

        if merchant_category in ["electronics", "gaming", "digital_services"]:
            risk_points += 1

        if transaction_date.hour >= 0 and transaction_date.hour <= 5:
            risk_points += 2

        if customer["account_age_days"] < 30:
            risk_points += 2

        if payment_method == "credit_card":
            risk_points += 1

        if random.random() < min(risk_points / 12, 0.75):
            is_fraud = 1

        if is_fraud == 1 and random.random() < 0.55:
            chargeback = 1

        transactions.append({
            "transaction_id": transaction_id,
            "customer_id": customer_id,
            "transaction_date": transaction_date,
            "amount": round(amount, 2),
            "merchant_id": merchant_id,
            "merchant_category": merchant_category,
            "payment_method": payment_method,
            "device_type": device_type,
            "device_id": device_id,
            "ip_address": ip_address,
            "transaction_country": country,
            "chargeback": chargeback,
            "is_fraud": is_fraud
        })

    return pd.DataFrame(transactions)

def main():
    customers_df = create_customers(NUM_CUSTOMERS)
    transactions_df = create_transactions(customers_df, NUM_TRANSACTIONS)

    customers_df.to_csv("data/raw/customers.csv", index=False)
    transactions_df.to_csv("data/raw/transactions.csv", index=False)

    print("Arquivos gerados com sucesso:")
    print("- data/raw/customers.csv")
    print("- data/raw/transactions.csv")

if __name__ == "__main__":
    main()