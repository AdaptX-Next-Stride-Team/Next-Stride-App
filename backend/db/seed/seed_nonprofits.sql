-- ============================================================
-- Next Stride — Seed: Nonprofits
-- Update website_url, grant_url, and logo_url with real values
-- before launching. These are starter entries.
-- ============================================================

INSERT INTO nonprofits (name, description, website_url, grant_available, grant_details, grant_url, is_featured) VALUES
  (
    'Challenged Athletes Foundation',
    'CAF provides opportunities and support to people with physical challenges so they can pursue active lifestyles through physical fitness and competitive athletics. They fund adaptive sports equipment, training, and competition entry fees.',
    'https://www.challengedathletes.org',
    true,
    'CAF offers grants for adaptive sports equipment (prosthetics, handcycles, racing chairs, etc.) and competition entry fees. Individual grants typically range from $500–$10,000. Apply online — applications are reviewed quarterly.',
    'https://www.challengedathletes.org/grants-and-scholarships/',
    true
  ),
  (
    'Amputee Coalition',
    'The Amputee Coalition is a national nonprofit that empowers people affected by limb loss through education, support, and advocacy. They connect amputees with peer mentors, local support groups, and national events.',
    'https://www.amputee-coalition.org',
    false,
    null,
    null,
    true
  ),
  (
    'Wiggle Your Toes',
    'Wiggle Your Toes provides support and community to lower limb amputees. They fund prosthetics and connect amputees with resources to help them return to active lives.',
    'https://www.wiggleyourtoes.org',
    true,
    'Wiggle Your Toes offers grants to lower limb amputees who need financial assistance to obtain prosthetics or adaptive equipment. Applications are reviewed on a rolling basis.',
    'https://www.wiggleyourtoes.org/apply',
    false
  ),
  (
    'Helping Hand Project',
    'The Helping Hand Project connects upper-limb amputees and limb-different individuals with resources, peer support, and financial assistance for adaptive devices.',
    'https://www.helpinghandproject.org',
    true,
    'Grants are available for upper-limb prosthetics, myoelectric devices, and adaptive technology. Priority given to applicants without adequate insurance coverage.',
    'https://www.helpinghandproject.org/apply',
    false
  ),
  (
    'No Barriers USA',
    'No Barriers believes that what lies within you is stronger than what lies in your way. They run expeditions, programs, and a national summit for people with disabilities including amputees.',
    'https://www.nobarriersusa.org',
    false,
    null,
    null,
    false
  );
