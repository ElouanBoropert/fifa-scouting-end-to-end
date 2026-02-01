# FIFA Player Scouting & Valuation — End-to-End (SQL + Power BI)

## Goal
Build an end-to-end analytics project (data cleaning → PostgreSQL modeling → BI views → Power BI dashboard) to support scouting shortlists and player profiling.

## What the dashboard enables
- Search/filter players by position, age, nationality, preferred foot, budget constraints
- Generate Top-N shortlists per position using an explainable scouting score
- Drill into a player profile with position-based percentiles (role-fit)

## Dataset
- Source file: `fifa_players.csv`
- Current warehouse load: **17,954 players**, **15 positions**, **29,534 player-position links**

## Tech Stack
- Python (Google Colab): cleaning + export to `players_for_postgres.csv`
- PostgreSQL (Docker): star-ish schema + transformations + BI views
- Power BI Desktop: report built on `fifa_bi.*` views

## Repository Structure
- `data/raw/` — raw dataset (optional in repo)
- `data/processed/` — cleaned outputs (e.g., `players_for_postgres.csv`)
- `sql/`
  - `schema.sql` — tables
  - `staging.sql` — staging tables
  - `transform.sql` — load dims/facts/bridge
  - `analytics_views.sql` — BI-facing views (e.g., `vw_shortlist`)
- `powerbi/`
  - `exports/` — PDF exports of the report
  - `screenshots/` — optional PNG screenshots
- `docs/` — insights and recommendations
- `src/` / `notebooks/` — Python logic / Colab notebooks