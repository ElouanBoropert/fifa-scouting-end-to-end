# Recommendations

## Recommendation 1 — Use a 3-step scouting workflow (position → constraints → score)
Action:
1) Filter **primary_position** (or position_code) to the target role.
2) Apply constraints (example guardrails):
   - age <= 25 (or a range by role),
   - potential_gap >= 15,
   - value_euro <= budget,
   - wage_euro <= wage ceiling.
3) Rank by **scouting_score** and review top 20.

Expected impact:
- Fast, repeatable shortlists aligned with upside and budget constraints.

How to operationalize:
- This is exactly the logic implemented on the **Shortlist** page using slicers + rank_score_pos.

## Recommendation 2 — Add role-fit checks using percentiles (avoid “one-metric” scouting)
Action:
- After shortlisting, validate role fit with percentiles in **Player Profile**:
  - For ST/CF: finishing + dribbling
  - For CM/CAM: short_passing + dribbling
  - For CDM/CB: interceptions + standing_tackle

Expected impact:
- Reduces false positives (players with good global score but poor role fit).

Guardrails:
- Require at least 2 key percentiles above a threshold (e.g., >= 70th percentile) for the role.

## Recommendation 3 — Improve the scoring model to be position-aware and explainable
Action (next iteration):
- Create position-specific weights for scouting_score instead of a single global formula.
- Example:
  - ST: emphasize finishing/dribbling percentiles
  - CDM: emphasize interceptions/tackles percentiles
  - CM/CAM: emphasize passing/dribbling percentiles

Expected impact:
- Rankings become more realistic per role and easier to justify to stakeholders.

How to validate:
- Back-test by comparing top-ranked players to percentile profiles (do top STs also rank highly in finishing percentile?).

## Recommendation 4 — Productionize the pipeline (tests + reproducibility)
Action:
- Add data quality checks:
  - unique player_key,
  - non-null key fields,
  - value/wage non-negative,
  - positions parsed correctly.
- Add a “one command” rebuild script (PowerShell) for schema → load → transform → views.

Expected impact:
- Makes the project portfolio-grade and closer to real analytics engineering practices.