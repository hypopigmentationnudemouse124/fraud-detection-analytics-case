import pandas as pd

def apply_fraud_rules(df: pd.DataFrame, customers_df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    customers_df = customers_df.copy()

    merged = df.merge(customers_df, on="customer_id", how="left")

    merged["high_amount_flag"] = (merged["amount"] > 3000).astype(int)
    merged["cross_border_flag"] = (merged["transaction_country"] != merged["home_country"]).astype(int)
    merged["late_night_flag"] = merged["transaction_date"].dt.hour.between(0, 5).astype(int)
    merged["new_account_flag"] = (merged["account_age_days"] < 30).astype(int)
    merged["high_risk_merchant_flag"] = merged["merchant_category"].isin(
        ["electronics", "gaming", "digital_services"]
    ).astype(int)

    merged["risk_score"] = (
        merged["high_amount_flag"] * 20 +
        merged["cross_border_flag"] * 25 +
        merged["late_night_flag"] * 15 +
        merged["new_account_flag"] * 20 +
        merged["high_risk_merchant_flag"] * 10
    )

    merged["risk_level"] = pd.cut(
        merged["risk_score"],
        bins=[-1, 19, 39, 59, 100],
        labels=["low", "medium", "high", "critical"]
    )

    return merged

def main():
    customers = pd.read_csv("data/raw/customers.csv")
    transactions = pd.read_csv("data/raw/transactions.csv", parse_dates=["transaction_date"])

    scored = apply_fraud_rules(transactions, customers)
    scored.to_csv("data/processed/transactions_scored.csv", index=False)

    print("Arquivo gerado: data/processed/transactions_scored.csv")
    print(scored[["transaction_id", "customer_id", "amount", "risk_score", "risk_level"]].head())

if __name__ == "__main__":
    main()