CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE user_sessions (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  device_token  VARCHAR(255) UNIQUE NOT NULL,
  created_at    TIMESTAMP DEFAULT NOW(),
  last_seen_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE wheels (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  share_code    VARCHAR(6) UNIQUE NOT NULL,
  name          VARCHAR(100) NOT NULL,
  session_id    UUID REFERENCES user_sessions(id),
  spin_count    INT DEFAULT 0,
  created_at    TIMESTAMP DEFAULT NOW(),
  expires_at    TIMESTAMP DEFAULT NOW() + INTERVAL '30 days'
);

CREATE TABLE segments (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wheel_id      UUID REFERENCES wheels(id) ON DELETE CASCADE,
  label         VARCHAR(100) NOT NULL,
  color         VARCHAR(7) NOT NULL,
  position      INT NOT NULL
);

CREATE TABLE spin_logs (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wheel_id      UUID REFERENCES wheels(id) ON DELETE CASCADE,
  result_label  VARCHAR(100) NOT NULL,
  result_color  VARCHAR(7) NOT NULL,
  spun_at       TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_wheels_share_code ON wheels(share_code);
CREATE INDEX idx_wheels_expires_at ON wheels(expires_at);
CREATE INDEX idx_segments_wheel_id ON segments(wheel_id);
