import re
import os
import numpy as np
import pandas as pd

def to_numeric_safe(s: pd.Series) -> pd.Series:
    # Convert to numeric, forcing errors to NaN
    return pd.to_numeric(s, errors="coerce")

def make_player_key(full_name: str, birth_date: pd.Timestamp) -> str:
    # Create a stable surrogate key from name + birth_date
    name = str(full_name).strip().lower()
    bd_str = birth_date.strftime("%Y-%m-%d") if pd.notna(birth_date) else "unknown"
    return re.sub(r"[^a-z0-9]+", "-", f"{name}-{bd_str}").strip("-")

def clean_players(input_csv: str, output_csv: str, output_parquet: str) -> pd.DataFrame:
    df_raw = pd.read_csv(input_csv)
    df = df_raw.copy()
    df.columns = [c.strip() for c in df.columns]

    # Positions cleanup
    df["positions"] = df["positions"].astype(str).str.strip()
    df["positions_list"] = (
        df["positions"]
        .str.replace(r"\s+", "", regex=True)
        .str.split(",")
    )
    df["primary_position"] = df["positions_list"].apply(lambda x: x[0] if isinstance(x, list) and len(x) > 0 else np.nan)
    df["positions_count"] = df["positions_list"].apply(lambda x: len(x) if isinstance(x, list) else 0)

    # Parse birth_date + age
    df["birth_date"] = pd.to_datetime(df["birth_date"], errors="coerce")
    today = pd.Timestamp.today().normalize()
    df["age"] = ((today - df["birth_date"]).dt.days / 365.25).round(1)

    # Numeric fields
    num_cols = [
        "height_cm", "weight_kgs",
        "overall_rating", "potential",
        "value_euro", "wage_euro", "release_clause_euro",
    ]
    for c in num_cols:
        if c in df.columns:
            df[c] = to_numeric_safe(df[c])

    # Quality flags (kept as columns)
    df["flag_missing_birth_date"] = df["birth_date"].isna()
    df["flag_overall_gt_potential"] = (df["overall_rating"] > df["potential"]) & df["overall_rating"].notna() & df["potential"].notna()
    df["flag_non_positive_value"] = (df["value_euro"] <= 0) & df["value_euro"].notna()
    df["flag_non_positive_wage"] = (df["wage_euro"] <= 0) & df["wage_euro"].notna()

    # Drop duplicates
    if {"full_name", "birth_date"}.issubset(df.columns):
        df = df.drop_duplicates(subset=["full_name", "birth_date"], keep="first").copy()

    # Surrogate key
    df["player_key"] = df.apply(lambda r: make_player_key(r.get("full_name", ""), r.get("birth_date", pd.NaT)), axis=1)

    # Export
    os.makedirs(os.path.dirname(output_csv), exist_ok=True)
    df.to_csv(output_csv, index=False)
    df.to_parquet(output_parquet, index=False)

    return df

if __name__ == "__main__":
    # Example usage (adjust paths as needed)
    repo_dir = "/content/fifa-scouting-end-to-end"
    input_csv = os.path.join(repo_dir, "data", "raw", "fifa_players.csv")
    out_dir = os.path.join(repo_dir, "data", "processed")
    output_csv = os.path.join(out_dir, "players_clean.csv")
    output_parquet = os.path.join(out_dir, "players_clean.parquet")

    df_clean = clean_players(input_csv, output_csv, output_parquet)
    print("Done. Clean rows:", len(df_clean))
