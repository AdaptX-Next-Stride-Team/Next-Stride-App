-- ============================================================
-- Next Stride — Migration 001: Initial Schema
-- Run this first in the Supabase SQL Editor
-- ============================================================

-- Profiles (extends Supabase Auth users)
CREATE TABLE profiles (
  id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name      TEXT,
  avatar_url        TEXT,
  amputation_level  TEXT,            -- 'below_knee' | 'above_knee' | 'upper_limb' | 'bilateral' | 'other'
  location          TEXT,
  runsignup_user_id TEXT,            -- future: RunSignUp OAuth linking
  created_at        TIMESTAMPTZ DEFAULT now()
);

-- Auto-create a profile row when a new user signs up
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, avatar_url)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'avatar_url');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Events (synced from RunSignUp weekly)
CREATE TABLE events (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  runsignup_id     TEXT UNIQUE,
  title            TEXT NOT NULL,
  category         TEXT CHECK (category IN ('race','clinic','community','firetruck_pull','other')),
  description      TEXT,
  location         TEXT,
  address          TEXT,
  event_date       TIMESTAMPTZ,
  registration_url TEXT,
  image_url        TEXT,
  is_featured      BOOLEAN DEFAULT false,
  raw_data         JSONB,
  synced_at        TIMESTAMPTZ DEFAULT now(),
  created_at       TIMESTAMPTZ DEFAULT now()
);

-- User event intent ("I'm Going") — drives badges, profile stats, event history
CREATE TABLE event_attendances (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE,
  event_id    UUID REFERENCES events(id) ON DELETE CASCADE,
  status      TEXT CHECK (status IN ('going','attended')) DEFAULT 'going',
  attended_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, event_id)
);

-- Badge definitions (team-designed, seeded — not user-generated)
CREATE TABLE badges (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug        TEXT UNIQUE NOT NULL,
  name        TEXT NOT NULL,
  description TEXT,
  icon_url    TEXT,
  category    TEXT CHECK (category IN ('attendance','race','clinic','community','streak')),
  threshold   INT
);

-- Badges a user has earned
CREATE TABLE user_badges (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id   UUID REFERENCES profiles(id) ON DELETE CASCADE,
  badge_id  UUID REFERENCES badges(id),
  earned_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, badge_id)
);

-- eBooks (Sam's book and any future additions)
CREATE TABLE ebooks (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title       TEXT NOT NULL,
  author      TEXT,
  description TEXT,
  pdf_url     TEXT NOT NULL,     -- Supabase Storage URL
  cover_url   TEXT,
  is_active   BOOLEAN DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- Nonprofits that support amputees
CREATE TABLE nonprofits (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name            TEXT NOT NULL,
  description     TEXT,
  website_url     TEXT,
  logo_url        TEXT,
  grant_available BOOLEAN DEFAULT false,
  grant_details   TEXT,
  grant_url       TEXT,
  is_featured     BOOLEAN DEFAULT false,
  created_at      TIMESTAMPTZ DEFAULT now(),
  updated_at      TIMESTAMPTZ DEFAULT now()
);

-- Videos (synced from YouTube playlist weekly)
CREATE TABLE videos (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  youtube_id    TEXT UNIQUE NOT NULL,
  title         TEXT NOT NULL,
  description   TEXT,
  thumbnail_url TEXT,
  published_at  TIMESTAMPTZ,
  duration      TEXT,
  tags          TEXT[],
  view_count    INT,
  is_featured   BOOLEAN DEFAULT false,
  synced_at     TIMESTAMPTZ DEFAULT now()
);

-- Training programs (scraped from TrainHeroic weekly)
CREATE TABLE training_programs (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  trainheroic_id    TEXT UNIQUE,
  title             TEXT NOT NULL,
  coach_name        TEXT,
  description       TEXT,
  sport_type        TEXT,
  difficulty        TEXT CHECK (difficulty IN ('beginner','intermediate','advanced')),
  duration_weeks    INT,
  sessions_per_week INT,
  price_usd         NUMERIC(8,2),
  purchase_url      TEXT NOT NULL,
  image_url         TEXT,
  is_active         BOOLEAN DEFAULT true,
  is_featured       BOOLEAN DEFAULT false,
  scraped_at        TIMESTAMPTZ DEFAULT now(),
  created_at        TIMESTAMPTZ DEFAULT now()
);

-- Message threads (one row per user <-> admin conversation)
CREATE TABLE message_threads (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES profiles(id) ON DELETE CASCADE,
  admin_id        UUID REFERENCES profiles(id),
  subject         TEXT,
  last_message_at TIMESTAMPTZ DEFAULT now(),
  created_at      TIMESTAMPTZ DEFAULT now()
);

-- Individual messages within a thread
CREATE TABLE messages (
  id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id UUID REFERENCES message_threads(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  content   TEXT NOT NULL,
  is_read   BOOLEAN DEFAULT false,
  sent_at   TIMESTAMPTZ DEFAULT now()
);

-- FAQ entries (written by admin team, displayed as chat-style chips in the app)
CREATE TABLE faqs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question      TEXT NOT NULL,
  answer        TEXT NOT NULL,
  category      TEXT,
  display_order INT DEFAULT 0,
  is_active     BOOLEAN DEFAULT true,
  created_at    TIMESTAMPTZ DEFAULT now()
);

-- Cron job run history
CREATE TABLE sync_logs (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_name       TEXT NOT NULL,
  status         TEXT CHECK (status IN ('pending','running','success','failed')),
  records_synced INT,
  error_message  TEXT,
  scheduled_for  TIMESTAMPTZ,
  started_at     TIMESTAMPTZ,
  finished_at    TIMESTAMPTZ,
  created_at     TIMESTAMPTZ DEFAULT now()
);

-- Post-MVP: implicit signals for recommendation system
-- Schema included now — app does NOT write to this table in the MVP
CREATE TABLE content_views (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content_type TEXT CHECK (content_type IN ('event','video','program','nonprofit')),
  content_id   UUID NOT NULL,
  viewed_at    TIMESTAMPTZ DEFAULT now()
);
