import pandas as pd

def main():
    df = pd.read_csv("data/processed/transactions_scored.csv", parse_dates=["transaction_date"])

    kpis = pd.DataFrame({
        "metric": [
            "total_transactions",
            "total_fraud_cases",
            "fraud_rate_pct",
            "total_amount",
            "fraud_amount"
        ],
        "value": [
            len(df),
            int(df["is_fraud"].sum()),
            round(df["is_fraud"].mean() * 100, 2),
            round(df["amount"].sum(), 2),
            round(df.loc[df["is_fraud"] == 1, "amount"].sum(), 2)
        ]
    })

    fraud_by_category = (
        df.groupby("merchant_category")
        .agg(
            total_transactions=("transaction_id", "count"),
            total_frauds=("is_fraud", "sum"),
            total_amount=("amount", "sum")
        )
        .reset_index()
    )
    fraud_by_category["fraud_rate_pct"] = round(
        fraud_by_category["total_frauds"] / fraud_by_category["total_transactions"] * 100, 2
    )

    fraud_by_country = (
        df.groupby("transaction_country")
        .agg(
            total_transactions=("transaction_id", "count"),
            total_frauds=("is_fraud", "sum")
        )
        .reset_index()
    )
    fraud_by_country["fraud_rate_pct"] = round(
        fraud_by_country["total_frauds"] / fraud_by_country["total_transactions"] * 100, 2
    )

    risk_distribution = (
        df.groupby("risk_level")
        .agg(
            total_transactions=("transaction_id", "count"),
            total_amount=("amount", "sum")
        )
        .reset_index()
    )

    df.to_csv("data/processed/final_transactions_for_bi.csv", index=False)
    kpis.to_csv("data/processed/kpis.csv", index=False)
    fraud_by_category.to_csv("data/processed/fraud_by_category.csv", index=False)
    fraud_by_country.to_csv("data/processed/fraud_by_country.csv", index=False)
    risk_distribution.to_csv("data/processed/risk_distribution.csv", index=False)

    print("Arquivos exportados para BI com sucesso.")

if __name__ == "__main__":
    main()