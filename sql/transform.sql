-- Load dimensions and fact tables from staging (robust to duplicates)

-- 1) dim_player
TRUNCATE TABLE fifa.dim_player CASCADE;

INSERT INTO fifa.dim_player (
  player_key, full_name, birth_date, age, height_cm, weight_kgs,
  preferred_foot, body_type, nationality, national_team
)
SELECT DISTINCT ON (player_key)
  player_key, full_name, birth_date, age, height_cm, weight_kgs,
  preferred_foot, body_type, nationality, national_team
FROM fifa.stg_players_clean
WHERE player_key IS NOT NULL
ORDER BY player_key;

-- 2) dim_position
TRUNCATE TABLE fifa.dim_position CASCADE;

INSERT INTO fifa.dim_position (position_code, position_group)
SELECT DISTINCT
  pos AS position_code,
  CASE
    WHEN pos = 'GK' THEN 'GK'
    WHEN pos IN ('CB','LB','RB','LWB','RWB') THEN 'DEF'
    WHEN pos IN ('CDM','CM','CAM','LM','RM') THEN 'MID'
    WHEN pos IN ('LW','RW','CF','ST') THEN 'FWD'
    ELSE 'OTHER'
  END AS position_group
FROM (
  SELECT DISTINCT primary_position AS pos
  FROM fifa.stg_players_clean
  WHERE primary_position IS NOT NULL
) t;

-- 3) bridge_player_position (use DISTINCT to avoid duplicates)
TRUNCATE TABLE fifa.bridge_player_position CASCADE;

INSERT INTO fifa.bridge_player_position (player_key, position_code, is_primary)
SELECT DISTINCT
  s.player_key,
  trim(pos) AS position_code,
  (trim(pos) = s.primary_position) AS is_primary
FROM fifa.stg_players_clean s
CROSS JOIN LATERAL unnest(string_to_array(replace(s.positions, ' ', ''), ',')) AS pos
WHERE s.player_key IS NOT NULL
  AND s.positions IS NOT NULL
  AND trim(pos) <> '';

-- 4) fact_player_snapshot
TRUNCATE TABLE fifa.fact_player_snapshot CASCADE;

INSERT INTO fifa.fact_player_snapshot (
  player_key,
  overall_rating, potential, value_euro, wage_euro, release_clause_euro,
  crossing, finishing, heading_accuracy, short_passing, volleys,
  dribbling, curve, freekick_accuracy, long_passing, ball_control,
  acceleration, sprint_speed, agility, reactions, balance, shot_power,
  jumping, stamina, strength, long_shots, aggression, interceptions,
  positioning, vision, penalties, composure, marking, standing_tackle, sliding_tackle
)
SELECT DISTINCT ON (player_key)
  player_key,
  overall_rating, potential, value_euro, wage_euro, release_clause_euro,
  crossing, finishing, heading_accuracy, short_passing, volleys,
  dribbling, curve, freekick_accuracy, long_passing, ball_control,
  acceleration, sprint_speed, agility, reactions, balance, shot_power,
  jumping, stamina, strength, long_shots, aggression, interceptions,
  positioning, vision, penalties, composure, marking, standing_tackle, sliding_tackle
FROM fifa.stg_players_clean
WHERE player_key IS NOT NULL
ORDER BY player_key;
