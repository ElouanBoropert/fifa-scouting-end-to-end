# FIFA Player Scouting & Valuation — End-to-End (SQL + Power BI)

## Project Goal
Build a comprehensive analytics pipeline from raw FIFA data. The workflow covers:
**Data Cleaning** (Python/Colab) → **Relational Modeling** (PostgreSQL/Docker) → **BI Layer** (SQL Views) → **Visualization** (Power BI) for advanced scouting and player profiling.

---

## Key Features
* **Dynamic Scouting:** Filter by position, age, nationality, and budget constraints.
* **Explainable Scoring:** Generate "Top-N" shortlists using a custom scouting algorithm.
* **Role-Fit Analysis:** Player profile views featuring position-based percentiles.

---

## Tech Stack
* **Python (Google Colab):** Data audit, cleaning, and export.
* **PostgreSQL (Docker):** Schema design, staging, and transformation.
* **Power BI Desktop:** Interactive dashboarding and data storytelling.

---

## Repository Structure
```text
├── sql/
│   ├── schema.sql           # Tables (dim/fact/bridge)
│   ├── staging.sql          # Staging area for raw CSV
│   ├── transform.sql        # ETL: Staging → Dims/Fact
│   └── analytics_views.sql  # BI-ready views (fifa_bi schema)
├── src/                     # Python cleaning scripts
├── notebooks/               # Google Colab notebooks
├── docs/                    # Data quality reports & insights
├── powerbi/
│   ├── exports/             # PDF versions of the report
│   └── screenshots/         # UI/UX previews
└── data/
    ├── raw/                 # Source .csv (git-ignored)
    └── processed/           # Cleaned .csv (local only)
```

---

## Installation & Setup (Windows PowerShell)

### 0) Prerequisites
* [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running.
* [Power BI Desktop](https://powerbi.microsoft.com/desktop/) (for report viewing).

### 1) Start PostgreSQL (Docker)
Open PowerShell in the root directory:
```powershell
docker compose up -d
docker ps
# Expected: a running container named 'fifa_postgres'
```

### 2) Create Schema + Staging Tables
```powershell
Get-Content .\sql\schema.sql -Raw  | docker exec -i fifa_postgres psql -U fifa_user -d fifa_db
Get-Content .\sql\staging.sql -Raw | docker exec -i fifa_postgres psql -U fifa_user -d fifa_db
```

### 3) Generate Cleaned CSV
1. In **Google Colab**, run the cleaning notebook.
2. Export the file: `players_for_postgres.csv`.
3. Place it locally at: `data\processed\players_for_postgres.csv`.

### 4) Load Data into PostgreSQL
```powershell
# Copy the file into the container
docker cp .\data\processed\players_for_postgres.csv fifa_postgres:/tmp/players_for_postgres.csv

# Load into the staging table
docker exec -it fifa_postgres psql -U fifa_user -d fifa_db -c "\copy fifa.stg_players_clean FROM '/tmp/players_for_postgres.csv' WITH (FORMAT csv, HEADER true)"
```

### 5) Transform & BI Views
```powershell
# Transform staging → dim/fact/bridge
Get-Content .\sql\transform.sql -Raw | docker exec -i fifa_postgres psql -U fifa_user -d fifa_db

# Create Power BI-friendly views
Get-Content .\sql\analytics_views.sql -Raw | docker exec -i fifa_postgres psql -U fifa_user -d fifa_db
```

### 6) Verify the Load
```powershell
docker exec -it fifa_postgres psql -U fifa_user -d fifa_db -c "SELECT COUNT(*) FROM fifa.dim_player;"
docker exec -it fifa_postgres psql -U fifa_user -d fifa_db -c "SELECT COUNT(*) FROM fifa.fact_player_snapshot;"
docker exec -it fifa_postgres psql -U fifa_user -d fifa_db -c "\dv fifa_bi.*"
```

---

## Power BI Setup
1. Open Power BI Desktop.
2. **Home -> Get data -> PostgreSQL database**.
3. Use the following credentials:
   * **Server:** `localhost`
   * **Database:** `fifa_db`
   * **User:** `fifa_user`
   * **Password:** `fifa_pass`
4. Build visuals using the `fifa_bi.*` views or the merged `player_enriched` table.

---

## Deliverables & Documentation
* **Dashboard PDFs:** Available in `powerbi/exports/`.
* **Data Quality Report:** Found in `docs/DATA_QUALITY_REPORT.md`.
* **Analysis & Insights:** See `docs/INSIGHTS.md` and `docs/RECOMMENDATIONS.md`.
