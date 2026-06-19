-- ============================================================
-- Next Stride — Seed: FAQs
-- These appear in the app as tappable question chips that
-- expand into chat bubbles. Edit answers to match AdaptX's voice.
-- ============================================================

INSERT INTO faqs (question, answer, category, display_order, is_active) VALUES

  -- General
  ('What is Next Stride?',
   'Next Stride is an app built by AdaptX for the amputee community. It brings together events, training programs, nonprofit resources, and a direct line to the AdaptX team — all in one place.',
   'general', 1, true),

  ('How do I contact the AdaptX team?',
   'Tap the Messages tab and start a new conversation. Sam and the team typically respond within 24 hours. For urgent questions during an event, look for an AdaptX staff member on-site.',
   'general', 2, true),

  ('Is Next Stride free to use?',
   'Yes — the app is completely free. Training programs on TrainHeroic have their own pricing set by AdaptX, but browsing everything in the app costs nothing.',
   'general', 3, true),

  -- Events
  ('How do I register for an event?',
   'Tap any event to open its detail page, then tap "Register" to go to the RunSignUp registration page. You''ll complete your registration there. Once registered, come back and tap "I''m Going" in the app to track it on your profile.',
   'events', 10, true),

  ('What kinds of events are on Next Stride?',
   'We list races (5Ks, 10Ks, half marathons), adaptive sports clinics, community meetups, firetruck pulls, and more. Use the filter bar on the Events tab to find what you''re looking for.',
   'events', 11, true),

  ('Can I participate in races with a prosthetic?',
   'Absolutely. Most events listed on Next Stride are adaptive-friendly or specifically designed for amputees. Check the event description for details on division categories and accommodations.',
   'events', 12, true),

  ('What is a firetruck pull?',
   'A firetruck pull is a competitive event where participants use a rope to pull a full-size firetruck as fast as possible. It''s a fan favorite at AdaptX events — a test of raw strength and determination.',
   'events', 13, true),

  -- Training
  ('Where do the training programs come from?',
   'All training programs are created by AdaptX coaches and hosted on TrainHeroic. You can browse and filter programs right here in the app. When you''re ready to start one, tap "Purchase on TrainHeroic" to buy and access it there.',
   'training', 20, true),

  ('What if I''m a beginner?',
   'We have programs specifically designed for beginners. Filter by "Beginner" difficulty on the Training tab to see programs built for people who are just starting their adaptive fitness journey.',
   'training', 21, true),

  ('Do I need special equipment for the training programs?',
   'It depends on the program. Each program page describes what equipment is recommended. Many programs are designed to be done with minimal gear.',
   'training', 22, true),

  -- Grants
  ('How do I apply for a grant?',
   'Tap the Resources tab, then open Nonprofits & Grants. Any organization offering grants will show a "Grant Available" badge. Tap the organization to read the grant details, then tap "Apply for Grant" to go directly to their application.',
   'grants', 30, true),

  ('What can grants help pay for?',
   'Grants from organizations in our resources section can help cover costs like prosthetics, adaptive sports equipment (racing chairs, handcycles, running blades), competition entry fees, and training expenses. Eligibility and amounts vary by organization.',
   'grants', 31, true),

  ('Will AdaptX help me with my grant application?',
   'We''re happy to help point you in the right direction. Send us a message through the app and Sam or a team member will follow up with guidance.',
   'grants', 32, true),

  -- Community
  ('How do I earn badges?',
   'Badges are awarded automatically when you hit milestones — like attending your first event, your fifth event, your first race, and more. Tap your profile to see badges you''ve earned and which ones are coming up next.',
   'general', 40, true),

  ('How often is the app updated with new events?',
   'Events are synced from RunSignUp every week. If you notice a missing event, send us a message and we''ll look into it.',
   'events', 14, true);
