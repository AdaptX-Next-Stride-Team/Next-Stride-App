-- ============================================================
-- Next Stride — Seed: Badges
-- ============================================================
-- icon_url will be updated once badge images are uploaded to
-- Supabase Storage at: storage/badges/<slug>.png

INSERT INTO badges (slug, name, description, category, threshold, icon_url) VALUES
  ('first_event',    'First Step',          'Marked your first event — the journey begins!',          'attendance', 1,  null),
  ('five_events',    'Getting Momentum',    'You''ve shown up to 5 events. Keep going!',               'attendance', 5,  null),
  ('ten_events',     'Unstoppable',         '10 events attended. You are an inspiration.',             'attendance', 10, null),
  ('first_race',     'Race Day',            'Took the starting line at your first race.',              'race',       null, null),
  ('first_clinic',   'Clinic Grad',         'Completed your first adaptive sports clinic.',           'clinic',     null, null),
  ('first_community','Community Builder',   'Showed up for the community at your first local event.', 'community',  null, null);
