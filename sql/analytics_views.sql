-- Analytics views for Power BI
CREATE SCHEMA IF NOT EXISTS fifa_bi;

-- 1) Player base view (join dims + fact + primary position)
CREATE OR REPLACE VIEW fifa_bi.vw_player_base AS
SELECT
  p.player_key,
  p.full_name,
  p.birth_date,
  p.age,
  p.height_cm,
  p.weight_kgs,
  p.preferred_foot,
  p.body_type,
  p.nationality,
  p.national_team,
  bp.position_code AS primary_position,

  f.overall_rating,
  f.potential,
  (f.potential - f.overall_rating) AS potential_gap,
  f.value_euro,
  f.wage_euro,
  f.release_clause_euro,

  -- Simple efficiency metrics
  CASE WHEN f.value_euro > 0 AND f.overall_rating IS NOT NULL THEN f.value_euro / NULLIF(f.overall_rating,0) END AS value_per_overall,
  CASE WHEN f.wage_euro > 0 AND f.overall_rating IS NOT NULL THEN f.wage_euro / NULLIF(f.overall_rating,0) END AS wage_per_overall

FROM fifa.dim_player p
JOIN fifa.fact_player_snapshot f
  ON f.player_key = p.player_key
LEFT JOIN fifa.bridge_player_position bp
  ON bp.player_key = p.player_key AND bp.is_primary = TRUE;

-- 2) Bargains view (rank by value_per_overall, lower is better)
CREATE OR REPLACE VIEW fifa_bi.vw_bargains AS
SELECT
  *,
  dense_rank() OVER (PARTITION BY primary_position ORDER BY value_per_overall ASC NULLS LAST) AS rank_value_per_overall_pos,
  dense_rank() OVER (PARTITION BY primary_position ORDER BY wage_per_overall ASC NULLS LAST)  AS rank_wage_per_overall_pos
FROM fifa_bi.vw_player_base
WHERE value_euro IS NOT NULL AND value_euro > 0;

-- 3) High potential gap view (who can grow the most)
CREATE OR REPLACE VIEW fifa_bi.vw_high_potential_gap AS
SELECT
  *,
  dense_rank() OVER (PARTITION BY primary_position ORDER BY potential_gap DESC NULLS LAST) AS rank_potential_gap_pos
FROM fifa_bi.vw_player_base
WHERE potential_gap IS NOT NULL;

-- 4) Percentiles for selected attributes by primary position
-- Note: percent_rank gives 0..1, multiply by 100 for percentile
CREATE OR REPLACE VIEW fifa_bi.vw_position_percentiles AS
SELECT
  b.player_key,
  b.full_name,
  b.primary_position,

  f.finishing,
  100 * percent_rank() OVER (PARTITION BY b.primary_position ORDER BY f.finishing) AS finishing_pct,

  f.short_passing,
  100 * percent_rank() OVER (PARTITION BY b.primary_position ORDER BY f.short_passing) AS short_passing_pct,

  f.interceptions,
  100 * percent_rank() OVER (PARTITION BY b.primary_position ORDER BY f.interceptions) AS interceptions_pct,

  f.standing_tackle,
  100 * percent_rank() OVER (PARTITION BY b.primary_position ORDER BY f.standing_tackle) AS standing_tackle_pct,

  f.dribbling,
  100 * percent_rank() OVER (PARTITION BY b.primary_position ORDER BY f.dribbling) AS dribbling_pct

FROM fifa_bi.vw_player_base b
JOIN fifa.fact_player_snapshot f
  ON f.player_key = b.player_key;

-- 5) Simple scouting score (explainable)
-- Score components: potential_gap (growth) + overall (level) - log(value) penalty
CREATE OR REPLACE VIEW fifa_bi.vw_scouting_score AS
SELECT
  b.*,
  -- Log penalty: higher value reduces score
  (0.6 * COALESCE(b.overall_rating,0)
   + 1.2 * COALESCE(b.potential_gap,0)
   - 0.0000002 * COALESCE(b.value_euro,0)
  ) AS scouting_score
FROM fifa_bi.vw_player_base b;

-- 6) Shortlist view (filters for practical scouting)
CREATE OR REPLACE VIEW fifa_bi.vw_shortlist AS
SELECT
  *,
  dense_rank() OVER (PARTITION BY primary_position ORDER BY scouting_score DESC NULLS LAST) AS rank_score_pos
FROM fifa_bi.vw_scouting_score
WHERE overall_rating IS NOT NULL
  AND value_euro IS NOT NULL
  AND value_euro > 0
  AND potential_gap IS NOT NULL;
