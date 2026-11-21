-- migrate:up
CREATE TABLE matches (
  id text PRIMARY KEY,
  patch text NOT NULL,
  played_at timestamptz NOT NULL,
  data jsonb NOT NULL
);

-- migrate:down
DROP TABLE matches;
