-- ============================================================
-- Next Stride — Migration 002: Realtime + Row Level Security
-- Run this AFTER 001_initial_schema.sql
-- ============================================================

-- Enable Realtime on messaging tables
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE message_threads;

-- ============================================================
-- Enable Row Level Security on all user-facing tables
-- ============================================================
ALTER TABLE profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_attendances ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges       ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages          ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_threads   ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_views     ENABLE ROW LEVEL SECURITY;

-- Public tables (readable by anyone, including unauthenticated):
-- events, videos, training_programs, ebooks, nonprofits, faqs, badges

-- ============================================================
-- profiles policies
-- ============================================================
CREATE POLICY "Users can read their own profile"
  ON profiles FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Users can update their own profile"
  ON profiles FOR UPDATE
  USING (id = auth.uid());

-- Admin can read all profiles
CREATE POLICY "Admins can read all profiles"
  ON profiles FOR SELECT
  USING (auth.jwt() -> 'app_metadata' ->> 'role' = 'admin');

-- ============================================================
-- event_attendances policies
-- ============================================================
CREATE POLICY "Users can read their own attendances"
  ON event_attendances FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own attendances"
  ON event_attendances FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own attendances"
  ON event_attendances FOR UPDATE
  USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own attendances"
  ON event_attendances FOR DELETE
  USING (user_id = auth.uid());

-- ============================================================
-- user_badges policies
-- ============================================================
CREATE POLICY "Users can read their own badges"
  ON user_badges FOR SELECT
  USING (user_id = auth.uid());

-- Only the Edge Function (service role) inserts badges — no user insert policy needed

-- ============================================================
-- messages policies
-- ============================================================
CREATE POLICY "Users can read messages in their threads"
  ON messages FOR SELECT
  USING (
    thread_id IN (
      SELECT id FROM message_threads WHERE user_id = auth.uid()
    )
    OR sender_id = auth.uid()
  );

CREATE POLICY "Users can send messages"
  ON messages FOR INSERT
  WITH CHECK (sender_id = auth.uid());

CREATE POLICY "Admins can read all messages"
  ON messages FOR SELECT
  USING (auth.jwt() -> 'app_metadata' ->> 'role' = 'admin');

CREATE POLICY "Admins can send messages"
  ON messages FOR INSERT
  WITH CHECK (auth.jwt() -> 'app_metadata' ->> 'role' = 'admin');

-- ============================================================
-- message_threads policies
-- ============================================================
CREATE POLICY "Users can read their own threads"
  ON message_threads FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can create threads"
  ON message_threads FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Admins can read all threads"
  ON message_threads FOR SELECT
  USING (auth.jwt() -> 'app_metadata' ->> 'role' = 'admin');

CREATE POLICY "Admins can update threads"
  ON message_threads FOR UPDATE
  USING (auth.jwt() -> 'app_metadata' ->> 'role' = 'admin');

-- ============================================================
-- content_views policies (post-MVP table)
-- ============================================================
CREATE POLICY "Users can insert their own views"
  ON content_views FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can read their own views"
  ON content_views FOR SELECT
  USING (user_id = auth.uid());

-- ============================================================
-- Badge award Edge Function (Supabase DB Function)
-- Triggered when a user marks "I'm Going" on an event
-- Awards any badge whose threshold the user just crossed
-- ============================================================
CREATE OR REPLACE FUNCTION award_badges_on_attendance()
RETURNS TRIGGER AS $$
DECLARE
  total_count   INT;
  race_count    INT;
  clinic_count  INT;
  community_count INT;
  badge_rec     RECORD;
BEGIN
  -- Count total attendances for this user
  SELECT COUNT(*) INTO total_count
  FROM event_attendances
  WHERE user_id = NEW.user_id;

  -- Count by category
  SELECT COUNT(*) INTO race_count
  FROM event_attendances ea
  JOIN events e ON e.id = ea.event_id
  WHERE ea.user_id = NEW.user_id AND e.category = 'race';

  SELECT COUNT(*) INTO clinic_count
  FROM event_attendances ea
  JOIN events e ON e.id = ea.event_id
  WHERE ea.user_id = NEW.user_id AND e.category = 'clinic';

  SELECT COUNT(*) INTO community_count
  FROM event_attendances ea
  JOIN events e ON e.id = ea.event_id
  WHERE ea.user_id = NEW.user_id AND e.category = 'community';

  -- Award attendance-based badges
  FOR badge_rec IN
    SELECT * FROM badges WHERE category = 'attendance' AND threshold <= total_count
  LOOP
    INSERT INTO user_badges (user_id, badge_id)
    VALUES (NEW.user_id, badge_rec.id)
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- Award race badge
  IF race_count >= 1 THEN
    INSERT INTO user_badges (user_id, badge_id)
    SELECT NEW.user_id, id FROM badges WHERE slug = 'first_race'
    ON CONFLICT DO NOTHING;
  END IF;

  -- Award clinic badge
  IF clinic_count >= 1 THEN
    INSERT INTO user_badges (user_id, badge_id)
    SELECT NEW.user_id, id FROM badges WHERE slug = 'first_clinic'
    ON CONFLICT DO NOTHING;
  END IF;

  -- Award community badge
  IF community_count >= 1 THEN
    INSERT INTO user_badges (user_id, badge_id)
    SELECT NEW.user_id, id FROM badges WHERE slug = 'first_community'
    ON CONFLICT DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER award_badges_trigger
  AFTER INSERT ON event_attendances
  FOR EACH ROW EXECUTE FUNCTION award_badges_on_attendance();

-- ============================================================
-- Update last_message_at on message_threads when a message is sent
-- ============================================================
CREATE OR REPLACE FUNCTION update_thread_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE message_threads
  SET last_message_at = now()
  WHERE id = NEW.thread_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_message_sent
  AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION update_thread_last_message();
