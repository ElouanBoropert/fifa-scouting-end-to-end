-- Schema for FIFA scouting end-to-end project
-- Star-ish model + bridge table for multi-positions

CREATE SCHEMA IF NOT EXISTS fifa;

-- Players dimension
DROP TABLE IF EXISTS fifa.dim_player CASCADE;
CREATE TABLE fifa.dim_player (
  player_key TEXT PRIMARY KEY,
  full_name TEXT,
  birth_date DATE,
  age NUMERIC,
  height_cm NUMERIC,
  weight_kgs NUMERIC,
  preferred_foot TEXT,
  body_type TEXT,
  nationality TEXT,
  national_team TEXT
);

-- Positions dimension
DROP TABLE IF EXISTS fifa.dim_position CASCADE;
CREATE TABLE fifa.dim_position (
  position_code TEXT PRIMARY KEY,
  position_group TEXT
);

-- Bridge: player <-> positions (many-to-many)
DROP TABLE IF EXISTS fifa.bridge_player_position CASCADE;
CREATE TABLE fifa.bridge_player_position (
  player_key TEXT REFERENCES fifa.dim_player(player_key),
  position_code TEXT REFERENCES fifa.dim_position(position_code),
  is_primary BOOLEAN DEFAULT FALSE,
  PRIMARY KEY (player_key, position_code)
);

-- Snapshot fact table (ratings, finance, skills)
DROP TABLE IF EXISTS fifa.fact_player_snapshot CASCADE;
CREATE TABLE fifa.fact_player_snapshot (
  player_key TEXT PRIMARY KEY REFERENCES fifa.dim_player(player_key),

  overall_rating NUMERIC,
  potential NUMERIC,
  value_euro NUMERIC,
  wage_euro NUMERIC,
  release_clause_euro NUMERIC,

  -- Technical/physical/mental attributes (keep numeric)
  crossing NUMERIC,
  finishing NUMERIC,
  heading_accuracy NUMERIC,
  short_passing NUMERIC,
  volleys NUMERIC,
  dribbling NUMERIC,
  curve NUMERIC,
  freekick_accuracy NUMERIC,
  long_passing NUMERIC,
  ball_control NUMERIC,
  acceleration NUMERIC,
  sprint_speed NUMERIC,
  agility NUMERIC,
  reactions NUMERIC,
  balance NUMERIC,
  shot_power NUMERIC,
  jumping NUMERIC,
  stamina NUMERIC,
  strength NUMERIC,
  long_shots NUMERIC,
  aggression NUMERIC,
  interceptions NUMERIC,
  positioning NUMERIC,
  vision NUMERIC,
  penalties NUMERIC,
  composure NUMERIC,
  marking NUMERIC,
  standing_tackle NUMERIC,
  sliding_tackle NUMERIC
);
