-- migrate:up
CREATE TABLE users (
  id text PRIMARY KEY,
  name text NOT NULL,
  role text NOT NULL CHECK (role IN ('user', 'creator', 'admin'))
);

CREATE TABLE champions (
  id text PRIMARY KEY,
  name text NOT NULL,
  cost int NOT NULL CHECK (cost >= 0)
);

CREATE TABLE items (
  id text PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE patches (
  id text PRIMARY KEY,
  is_current boolean NOT NULL DEFAULT false
);

CREATE UNIQUE INDEX patches_one_current ON patches (is_current) WHERE is_current;

CREATE TABLE tactics (
  id text PRIMARY KEY,
  author_id text NOT NULL REFERENCES users (id),
  title text NOT NULL,
  description text NOT NULL,
  carry_id text NOT NULL REFERENCES champions (id),
  status text NOT NULL CHECK (status IN ('draft', 'published', 'hidden', 'archived')),
  status_at timestamptz,
  hidden_reason text,
  hidden_by text REFERENCES users (id),
  updated_at timestamptz NOT NULL,
  variants jsonb NOT NULL,
  CONSTRAINT tactics_hidden_with_reason CHECK (
    (status = 'hidden') = (hidden_reason IS NOT NULL AND hidden_by IS NOT NULL)
  ),
  CONSTRAINT tactics_status_at CHECK ((status = 'draft') = (status_at IS NULL))
);

CREATE INDEX tactics_by_author ON tactics (author_id);

CREATE TABLE tier_placements (
  patch_id text NOT NULL REFERENCES patches (id),
  tactic_id text NOT NULL REFERENCES tactics (id) ON DELETE CASCADE,
  tier text NOT NULL CHECK (tier IN ('s', 'a', 'b', 'c', 'situational')),
  position int NOT NULL,
  PRIMARY KEY (patch_id, tactic_id)
);

-- migrate:down
DROP TABLE tier_placements;
DROP TABLE tactics;
DROP TABLE patches;
DROP TABLE items;
DROP TABLE champions;
DROP TABLE users;
