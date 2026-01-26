-- Supabase Schema for Walkup MVP
-- Run this in your Supabase SQL editor to set up the database

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Teams table
CREATE TABLE IF NOT EXISTS teams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_user_id UUID NOT NULL,
  name TEXT NOT NULL,
  join_code TEXT UNIQUE NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Team members table (for sharing teams)
CREATE TABLE IF NOT EXISTS team_members (
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  role TEXT NOT NULL DEFAULT 'viewer', -- 'owner', 'editor', 'viewer'
  PRIMARY KEY (team_id, user_id)
);

-- Players table
CREATE TABLE IF NOT EXISTS players (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  team_id UUID REFERENCES teams(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  number INTEGER NOT NULL,
  batting_order INTEGER NOT NULL,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Walkup assignments table
CREATE TABLE IF NOT EXISTS assignments (
  player_id UUID PRIMARY KEY REFERENCES players(id) ON DELETE CASCADE,
  source_type TEXT NOT NULL, -- 'youtube', 'localFile', 'builtIn'
  youtube_video_id TEXT,
  start_sec INTEGER,
  duration_sec INTEGER,
  local_uri TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Announcements table
CREATE TABLE IF NOT EXISTS announcements (
  player_id UUID PRIMARY KEY REFERENCES players(id) ON DELETE CASCADE,
  mode TEXT NOT NULL, -- 'recorded', 'tts'
  local_uri TEXT,
  tts_template TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_players_team_id ON players(team_id);
CREATE INDEX IF NOT EXISTS idx_players_batting_order ON players(batting_order);
CREATE INDEX IF NOT EXISTS idx_team_members_user_id ON team_members(user_id);

-- Enable Row Level Security
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Teams
-- Users can see teams they own or are members of
CREATE POLICY "Users can view their teams" ON teams
  FOR SELECT
  USING (
    owner_user_id = auth.uid() OR
    id IN (
      SELECT team_id FROM team_members WHERE user_id = auth.uid()
    )
  );

-- Users can create teams
CREATE POLICY "Users can create teams" ON teams
  FOR INSERT
  WITH CHECK (owner_user_id = auth.uid());

-- Users can update teams they own
CREATE POLICY "Owners can update teams" ON teams
  FOR UPDATE
  USING (owner_user_id = auth.uid())
  WITH CHECK (owner_user_id = auth.uid());

-- Users can delete teams they own
CREATE POLICY "Owners can delete teams" ON teams
  FOR DELETE
  USING (owner_user_id = auth.uid());

-- RLS Policies for Team Members
-- Users can view team members for teams they're part of
CREATE POLICY "Users can view team members" ON team_members
  FOR SELECT
  USING (
    team_id IN (
      SELECT id FROM teams WHERE owner_user_id = auth.uid()
    ) OR
    team_id IN (
      SELECT team_id FROM team_members WHERE user_id = auth.uid()
    )
  );

-- Team owners can add members
CREATE POLICY "Owners can add team members" ON team_members
  FOR INSERT
  WITH CHECK (
    team_id IN (
      SELECT id FROM teams WHERE owner_user_id = auth.uid()
    )
  );

-- Team owners can remove members
CREATE POLICY "Owners can remove team members" ON team_members
  FOR DELETE
  USING (
    team_id IN (
      SELECT id FROM teams WHERE owner_user_id = auth.uid()
    )
  );

-- RLS Policies for Players
-- Users can view players for teams they're part of
CREATE POLICY "Users can view players" ON players
  FOR SELECT
  USING (
    team_id IN (
      SELECT id FROM teams WHERE owner_user_id = auth.uid()
    ) OR
    team_id IN (
      SELECT team_id FROM team_members WHERE user_id = auth.uid()
    )
  );

-- Team owners and editors can create players
CREATE POLICY "Editors can create players" ON players
  FOR INSERT
  WITH CHECK (
    team_id IN (
      SELECT id FROM teams WHERE owner_user_id = auth.uid()
    ) OR
    team_id IN (
      SELECT team_id FROM team_members 
      WHERE user_id = auth.uid() AND role IN ('owner', 'editor')
    )
  );

-- Team owners and editors can update players
CREATE POLICY "Editors can update players" ON players
  FOR UPDATE
  USING (
    team_id IN (
      SELECT id FROM teams WHERE owner_user_id = auth.uid()
    ) OR
    team_id IN (
      SELECT team_id FROM team_members 
      WHERE user_id = auth.uid() AND role IN ('owner', 'editor')
    )
  );

-- Team owners can delete players
CREATE POLICY "Owners can delete players" ON players
  FOR DELETE
  USING (
    team_id IN (
      SELECT id FROM teams WHERE owner_user_id = auth.uid()
    )
  );

-- RLS Policies for Assignments
-- Same access as players (assignments are tied to players)
CREATE POLICY "Users can view assignments" ON assignments
  FOR SELECT
  USING (
    player_id IN (
      SELECT p.id FROM players p
      WHERE p.team_id IN (
        SELECT id FROM teams WHERE owner_user_id = auth.uid()
      ) OR p.team_id IN (
        SELECT team_id FROM team_members WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Editors can manage assignments" ON assignments
  FOR ALL
  USING (
    player_id IN (
      SELECT p.id FROM players p
      WHERE p.team_id IN (
        SELECT id FROM teams WHERE owner_user_id = auth.uid()
      ) OR p.team_id IN (
        SELECT team_id FROM team_members 
        WHERE user_id = auth.uid() AND role IN ('owner', 'editor')
      )
    )
  );

-- RLS Policies for Announcements
-- Same access as players/assignments
CREATE POLICY "Users can view announcements" ON announcements
  FOR SELECT
  USING (
    player_id IN (
      SELECT p.id FROM players p
      WHERE p.team_id IN (
        SELECT id FROM teams WHERE owner_user_id = auth.uid()
      ) OR p.team_id IN (
        SELECT team_id FROM team_members WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Editors can manage announcements" ON announcements
  FOR ALL
  USING (
    player_id IN (
      SELECT p.id FROM players p
      WHERE p.team_id IN (
        SELECT id FROM teams WHERE owner_user_id = auth.uid()
      ) OR p.team_id IN (
        SELECT team_id FROM team_members 
        WHERE user_id = auth.uid() AND role IN ('owner', 'editor')
      )
    )
  );

-- Function to generate unique join codes
CREATE OR REPLACE FUNCTION generate_join_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; -- No confusing chars
  result TEXT := '';
  i INTEGER;
BEGIN
  FOR i IN 1..6 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate join code for new teams
CREATE OR REPLACE FUNCTION set_team_join_code()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.join_code IS NULL THEN
    NEW.join_code := generate_join_code();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER team_join_code_trigger
  BEFORE INSERT ON teams
  FOR EACH ROW
  EXECUTE FUNCTION set_team_join_code();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers to auto-update updated_at
CREATE TRIGGER update_teams_updated_at
  BEFORE UPDATE ON teams
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_players_updated_at
  BEFORE UPDATE ON players
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_assignments_updated_at
  BEFORE UPDATE ON assignments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_announcements_updated_at
  BEFORE UPDATE ON announcements
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
