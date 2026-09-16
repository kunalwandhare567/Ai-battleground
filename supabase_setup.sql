-- ==============================================================================
-- ⚔️ IAE AI-BATTLEGROUND COMPLETE SUPABASE SETUP (SCHEMA + VALIDATED CSV DATA) ⚔️
-- Run this complete script in Supabase SQL Editor (Dashboard -> SQL Editor -> New Query)
-- ==============================================================================

-- 1. Create Question Bank Table
CREATE TABLE IF NOT EXISTS questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  round INT NOT NULL,
  question_type VARCHAR(50) NOT NULL,
  prompt_text TEXT NOT NULL,
  real_image_url TEXT,
  ai_image_url TEXT,
  logo_url TEXT,
  options JSONB,
  correct_option TEXT NOT NULL,
  explanation TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create Match Sessions Table
CREATE TABLE IF NOT EXISTS matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  room_code VARCHAR(10) UNIQUE NOT NULL,
  host_id VARCHAR(50) DEFAULT 'host',
  status VARCHAR(30) DEFAULT 'lobby',
  current_round INT DEFAULT 0,
  round_started_at TIMESTAMPTZ,
  round_duration_seconds INT DEFAULT 15,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create Match Players Table
CREATE TABLE IF NOT EXISTS match_players (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  display_name VARCHAR(50) NOT NULL,
  device_token VARCHAR(100) NOT NULL,
  has_completed_session BOOLEAN DEFAULT false,
  has_left BOOLEAN DEFAULT false,
  joined_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Create Match Round Questions Assignment Table
CREATE TABLE IF NOT EXISTS match_round_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID REFERENCES match_players(id) ON DELETE CASCADE,
  round INT NOT NULL,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  position INT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE match_round_questions ADD COLUMN IF NOT EXISTS player_id UUID REFERENCES match_players(id) ON DELETE CASCADE;
ALTER TABLE match_round_questions ADD COLUMN IF NOT EXISTS position INT;

-- 5. Create Match Answers Table
CREATE TABLE IF NOT EXISTS match_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  player_id UUID REFERENCES match_players(id) ON DELETE CASCADE,
  round INT NOT NULL,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  selected_option TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  points_earned INT DEFAULT 0,
  response_time_ms INT NOT NULL,
  answered_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Dynamic Leaderboard View
CREATE OR REPLACE VIEW match_leaderboard AS
SELECT 
  p.id AS player_id,
  p.match_id,
  p.display_name,
  p.device_token,
  COALESCE(SUM(a.points_earned), 0)::INT AS total_score,
  COALESCE(SUM(CASE WHEN a.round = 1 THEN a.points_earned ELSE 0 END), 0)::INT AS round1_score,
  COALESCE(SUM(CASE WHEN a.round = 2 THEN a.points_earned ELSE 0 END), 0)::INT AS round2_score,
  COALESCE(SUM(CASE WHEN a.round = 3 THEN a.points_earned ELSE 0 END), 0)::INT AS round3_score,
  COUNT(CASE WHEN a.is_correct = true THEN 1 END)::INT AS correct_count,
  COUNT(a.id)::INT AS total_answers,
  p.joined_at
FROM match_players p
LEFT JOIN match_answers a ON p.id = a.player_id AND p.match_id = a.match_id
WHERE p.has_left = false
GROUP BY p.id, p.match_id, p.display_name, p.device_token, p.joined_at;

-- 7. Row Level Security & Public Policies
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_players ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_round_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_answers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public access questions" ON questions;
CREATE POLICY "Public access questions" ON questions FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public access matches" ON matches;
CREATE POLICY "Public access matches" ON matches FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public access match_players" ON match_players;
CREATE POLICY "Public access match_players" ON match_players FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public access match_round_questions" ON match_round_questions;
CREATE POLICY "Public access match_round_questions" ON match_round_questions FOR ALL TO public USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Public access match_answers" ON match_answers;
CREATE POLICY "Public access match_answers" ON match_answers FOR ALL TO public USING (true) WITH CHECK (true);

-- 8. Enable Realtime Publications
DO $$
BEGIN
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE matches;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE match_players;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE match_round_questions;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE match_answers;
  EXCEPTION WHEN OTHERS THEN NULL;
  END;
END $$;

-- ==============================================================================
-- 9. POPULATE ALL 60 QUESTIONS (data/questions_rows.csv)
-- ==============================================================================
INSERT INTO questions (id, round, question_type, prompt_text, real_image_url, ai_image_url, logo_url, options, correct_option, explanation, is_active)
VALUES
(
  '040bc733-e444-4d95-9a90-d44a953cf55c',
  1,
  'image_comparison',
  'Which cat and dog photo is AI-generated?',
  '/images/round1/q20_real.jpg',
  '/images/round1/q20_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Fur blending between the two animals looks unnaturally smooth.',
  true
),
(
  '0463a4a2-50f0-482f-971a-22e359942d64',
  1,
  'image_comparison',
  'Which portrait photo is AI-generated?',
  '/images/round1/q17_real.jpg',
  '/images/round1/q17_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Skin texture and hair strand blending look artificially smooth.',
  true
),
(
  '07d42e9c-d78c-4b1a-8f81-ba479bb64edd',
  1,
  'image_comparison',
  'Which countryside path photo is AI-generated?',
  '/images/round1/q09_real.jpg',
  '/images/round1/q09_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Tree spacing and shadow direction are physically inconsistent.',
  true
),
(
  '0d17802f-64cb-43d7-b801-c3d8b566da40',
  1,
  'image_comparison',
  'Which bird photo is AI-generated?',
  '/images/round1/q18_real.jpg',
  '/images/round1/q18_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Feather detail and leg positioning look physically inconsistent.',
  true
),
(
  '0f5f25a2-d54d-48fc-abfd-067fad2df7ff',
  1,
  'image_comparison',
  'Which apartment building photo is AI-generated?',
  '/images/round1/q03_real.jpg',
  '/images/round1/q03_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Window patterns and balcony structures repeat unnaturally.',
  true
),
(
  '1a13fa30-752c-44d6-9ad1-64b3898bd2a6',
  1,
  'image_comparison',
  'Which ocean sunset photo is AI-generated?',
  '/images/round1/q13_real.jpg',
  '/images/round1/q13_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Wave reflections don''t match the light source direction.',
  true
),
(
  '3bba083c-ae4f-405b-8732-d904bae2f299',
  1,
  'image_comparison',
  'Which version of the Mona Lisa is AI-generated?',
  '/images/round1/q08_real.jpg',
  '/images/round1/q08_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Brushstroke patterns and facial proportions are subtly altered.',
  true
),
(
  '6748eac1-d121-4522-9897-6ac603ec771e',
  1,
  'image_comparison',
  'Which bridge/tunnel photo is AI-generated?',
  '/images/round1/q19_real.jpg',
  '/images/round1/q19_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Structural symmetry and lighting look artificially perfect.',
  true
),
(
  '76f59b49-2933-4d17-a018-ec3398e94698',
  1,
  'image_comparison',
  'Which photo of Earth from space is AI-generated?',
  '/images/round1/q07_real.jpg',
  '/images/round1/q07_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Cloud formations and coastline details don''t match real geography.',
  true
),
(
  '85a0a9ff-0c61-4289-8dbb-e585861cabbf',
  1,
  'image_comparison',
  'Which hibiscus flower photo is AI-generated?',
  '/images/round1/q06_real.jpg',
  '/images/round1/q06_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Petal edges show unnatural smoothing and color gradients.',
  true
),
(
  '85cb4dbb-77e4-474d-90ad-5eeb69b04e48',
  1,
  'image_comparison',
  'Which colorful door photo is AI-generated?',
  '/images/round1/q02_real.jpg',
  '/images/round1/q02_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Notice inconsistent wood grain texture and hardware details.',
  true
),
(
  '870ead56-b92e-45fc-9bfb-c852f64088c9',
  1,
  'image_comparison',
  'Which tiger photo is AI-generated?',
  '/images/round1/q05_real.jpg',
  '/images/round1/q05_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Stripe patterns are asymmetrical and don''t align naturally.',
  true
),
(
  '926918a8-aa91-45c5-a226-203c87dfd4c4',
  1,
  'image_comparison',
  'Which photo of a person with a camera is AI-generated?',
  '/images/round1/q01_real.jpg',
  '/images/round1/q01_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Look closely at hand positioning and camera details for unnatural blending.',
  true
),
(
  '9fff14db-911c-4ec5-abca-50f082cadfff',
  1,
  'image_comparison',
  'Which close-up eye photo is AI-generated?',
  '/images/round1/q15_real.jpg',
  '/images/round1/q15_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Iris pattern and eyelash placement look artificially symmetrical.',
  true
),
(
  'aa5ea55b-56c2-4828-824c-110e1ffa1392',
  1,
  'image_comparison',
  'Which pizza photo is AI-generated?',
  '/images/round1/q16_real.jpg',
  '/images/round1/q16_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Topping placement and cheese melt patterns look unnaturally uniform.',
  true
),
(
  'bbd23faa-ad76-4653-b871-8f6876cf02cc',
  1,
  'image_comparison',
  'Which sunflower photo is AI-generated?',
  '/images/round1/q12_real.jpg',
  '/images/round1/q12_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Petal count and center seed pattern are irregular.',
  true
),
(
  'c1b8ea0b-512d-46ac-b9fe-8a0c40dcea2a',
  1,
  'image_comparison',
  'Which strawberry photo is AI-generated?',
  '/images/round1/q10_real.jpg',
  '/images/round1/q10_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Seed patterns on the surface repeat unnaturally.',
  true
),
(
  'c3eaade7-c12a-40bb-8f90-67a74480702c',
  1,
  'image_comparison',
  'Which parrot photo is AI-generated?',
  '/images/round1/q11_real.jpg',
  '/images/round1/q11_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Feather texture blending looks artificially smooth.',
  true
),
(
  'c91b3106-5017-499d-bb2c-1070ec5d033d',
  1,
  'image_comparison',
  'Which mountain landscape photo is AI-generated?',
  '/images/round1/q14_real.jpg',
  '/images/round1/q14_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Rock formations and snow patterns repeat unnaturally.',
  true
),
(
  'ed8918ea-be0e-4d21-b90a-27074f4192e9',
  1,
  'image_comparison',
  'Which teddy bear photo is AI-generated?',
  '/images/round1/q04_real.jpg',
  '/images/round1/q04_ai.jpg',
  NULL,
  NULL,
  'ai',
  'Fur texture blends unnaturally into the background.',
  true
),
(
  'a0a3e05e-3ca3-4548-a03f-aec0c1fa15cc',
  1,
  'image_comparison',
  'Which snowman photo is AI-generated?',
  '/images/round1/q21_real.jpg',
  '/images/round1/q21_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The snowman''s facial details, arms, and body proportions contain subtle AI-generated inconsistencies.',
  true
),
(
  '0ca4bc4e-27e5-487a-aef4-2efd81a2f40f',
  1,
  'image_comparison',
  'Which colorful frog photo is AI-generated?',
  '/images/round1/q22_real.jpg',
  '/images/round1/q22_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The frog''s skin pattern, eyes, and leg details show subtle AI-generation artifacts.',
  true
),
(
  'fece2cda-71cf-4ead-a088-dba5c32b06dd',
  1,
  'image_comparison',
  'Which Titanic ship photo is AI-generated?',
  '/images/round1/q23_real.jpg',
  '/images/round1/q23_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The ship''s structure, deck details, and fine architectural elements contain generated inconsistencies.',
  true
),
(
  'cc7949d0-995c-444b-a550-2b4a63c350c3',
  1,
  'image_comparison',
  'Which Mount Fuji photo is AI-generated?',
  '/images/round1/q24_real.jpg',
  '/images/round1/q24_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The mountain shape, clouds, reflections, and lighting contain subtle AI-generated inconsistencies.',
  true
),
(
  'ee882656-de2f-4eb6-aee2-4e42a7b3d9dc',
  1,
  'image_comparison',
  'Which rocket launch photo is AI-generated?',
  '/images/round1/q25_real.jpg',
  '/images/round1/q25_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The rocket, exhaust flame, and smoke shapes show subtle artificial blending.',
  true
),
(
  '440eabed-2282-4142-a692-00304b02f086',
  1,
  'image_comparison',
  'Which city skyline photo is AI-generated?',
  '/images/round1/q26_real.jpg',
  '/images/round1/q26_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The building shapes, windows, and lighting patterns contain subtle generated inconsistencies.',
  true
),
(
  'cf463a69-6d51-40ef-abf4-385447f41dea',
  1,
  'image_comparison',
  'Which northern lights photo is AI-generated?',
  '/images/round1/q27_real.jpg',
  '/images/round1/q27_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The aurora shapes, sky details, and reflections contain subtle AI-generated artifacts.',
  true
),
(
  '4064c1e9-633a-45f4-a4bf-1be703891ba3',
  1,
  'image_comparison',
  'Which Statue of Liberty photo is AI-generated?',
  '/images/round1/q28_real.jpg',
  '/images/round1/q28_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The statue proportions, surroundings, and background details contain subtle generated inconsistencies.',
  true
),
(
  '70e30bd4-2252-49aa-a21b-7e5530a8f50b',
  1,
  'image_comparison',
  'Which Egyptian pyramid photo is AI-generated?',
  '/images/round1/q29_real.jpg',
  '/images/round1/q29_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The pyramid surface, perspective, lighting, and surrounding landscape show subtle AI artifacts.',
  true
),
(
  'cc855b48-94c3-4207-a267-3ec5403b12d8',
  1,
  'image_comparison',
  'Which ice cream cone photo is AI-generated?',
  '/images/round1/q30_real.jpg',
  '/images/round1/q30_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The waffle pattern, cone edges, and texture contain subtle AI-generated irregularities.',
  true
),
(
  '1d505209-f8a4-4a34-a7ef-b12c16835da6',
  1,
  'image_comparison',
  'Which dog photo is AI-generated?',
  '/images/round1/q31_real.jpg',
  '/images/round1/q31_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The dog''s fur texture, facial details, and body edges contain subtle AI-generation artifacts.',
  true
),
(
  'bd734832-31ce-4840-aa65-a97eb87ac8f4',
  1,
  'image_comparison',
  'Which daisy flower photo is AI-generated?',
  '/images/round1/q32_real.jpg',
  '/images/round1/q32_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The petal shapes, flower center, and fine textures show subtle generated inconsistencies.',
  true
),
(
  'c5283f43-2fe3-4693-a88f-09e428dead23',
  1,
  'image_comparison',
  'Which Venice canal photo is AI-generated?',
  '/images/round1/q33_real.jpg',
  '/images/round1/q33_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The buildings, canal details, gondola, and architectural elements contain subtle AI artifacts.',
  true
),
(
  '46eaddf9-cecc-4c5f-ab64-c5df93069ff6',
  1,
  'image_comparison',
  'Which Italian lakeside photo is AI-generated?',
  '/images/round1/q34_real.jpg',
  '/images/round1/q34_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The buildings, shoreline, mountain background, and lighting contain subtle generated inconsistencies.',
  true
),
(
  '30c10bab-1c5e-4897-ad19-c3142dcacc7b',
  1,
  'image_comparison',
  'Which iguana photo is AI-generated?',
  '/images/round1/q35_real.jpg',
  '/images/round1/q35_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The scales, spikes, eye details, and body texture show subtle AI-generated artifacts.',
  true
),
(
  '26e09182-ebf7-48b9-a35a-bcba566bb726',
  1,
  'image_comparison',
  'Which sushi photo is AI-generated?',
  '/images/round1/q36_real.jpg',
  '/images/round1/q36_ai.jpg',
  NULL,
  NULL,
  'ai',
  'The sushi pieces, fish texture, rice details, and arrangement contain subtle generated inconsistencies.',
  true
),
(
  'dd1d5e18-45f9-4154-a20e-71066205252c',
  2,
  'logo_mcq',
  'Which AI design tool is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/adobe-express.svg',
  '["Adobe Express","Adobe Firefly","Canva","Figma"]'::JSONB,
  'Adobe Express',
  'Adobe Express is Adobe''s creative design platform for quickly creating and editing visual content.',
  true
),
(
  '5103a0de-e81d-41b7-ad05-7a06ae7ee3bf',
  2,
  'logo_mcq',
  'Which Adobe generative AI platform is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/adobe-firefly.svg',
  '["Adobe Firefly","Adobe Express","Midjourney","DALL-E"]'::JSONB,
  'Adobe Firefly',
  'Adobe Firefly is Adobe''s generative AI family for creating and editing images and creative content.',
  true
),
(
  'b74ba0ef-cc9b-4eaf-a6fe-b51141511902',
  2,
  'logo_mcq',
  'Which Amazon voice AI service is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/alexa.svg',
  '["Alexa","Siri","Cortana","Bixby"]'::JSONB,
  'Alexa',
  'Alexa is Amazon cloud-based voice AI assistant powering Echo and smart devices.',
  true
),
(
  'ad61dcca-0796-4c8a-ad40-1cc222a19457',
  2,
  'logo_mcq',
  'Which AI company is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/anthropic.svg',
  '["Anthropic","OpenAI","Cohere","Mistral AI"]'::JSONB,
  'Anthropic',
  'Anthropic is the AI safety and research company behind Claude.',
  true
),
(
  '121efa8a-aee7-472c-a096-0c67ba6fd4db',
  2,
  'logo_mcq',
  'Which Apple AI brand is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/apple-intelligence.svg',
  '["Apple Intelligence","Siri","Apple AI","iCloud"]'::JSONB,
  'Apple Intelligence',
  'Apple Intelligence is Apple''s personal intelligence system integrated across iOS, iPadOS, and macOS.',
  true
),
(
  '4f5636f2-ae94-44d0-a6f9-5e769d49d38f',
  2,
  'logo_mcq',
  'Which global tech giant behind Apple Intelligence uses this logo?',
  NULL,
  NULL,
  '/images/round2/apple.svg',
  '["Apple","Microsoft","Google","Meta"]'::JSONB,
  'Apple',
  'Apple is the creator of iOS, macOS, Siri, and Apple Intelligence.',
  true
),
(
  '14bd6b79-bc4e-4fe2-a0f2-1483234c2ec3',
  2,
  'logo_mcq',
  'Which Microsoft AI cloud service is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/azureai.svg',
  '["Azure AI","Microsoft Copilot","Azure DevOps","Power BI"]'::JSONB,
  'Azure AI',
  'Azure AI is Microsoft''s portfolio of AI and machine learning services on Azure cloud.',
  true
),
(
  '1d012172-8cf0-4d8d-a7d2-94c06b35c26e',
  2,
  'logo_mcq',
  'Which groundbreaking conversational AI platform is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/chatgpt.svg',
  '["ChatGPT","Claude","Gemini","Perplexity"]'::JSONB,
  'ChatGPT',
  'ChatGPT is OpenAI conversational AI that kicked off the generative AI boom.',
  true
),
(
  '640ac63f-5712-42e8-a25d-efd1673a6b6e',
  2,
  'logo_mcq',
  'Which AI assistant is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/claude.svg',
  '["Claude","ChatGPT","Grok","Gemini"]'::JSONB,
  'Claude',
  'Claude is Anthropic''s AI assistant and frontier language model family.',
  true
),
(
  'd50af36a-70d9-4344-aef3-1bcf7f0d426d',
  2,
  'logo_mcq',
  'Which autonomous AI coding agent is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/cline.svg',
  '["Cline","Cursor","GitHub Copilot","Codex"]'::JSONB,
  'Cline',
  'Cline is an autonomous AI coding agent that can create/edit files and run commands in your IDE.',
  true
),
(
  'ac3fcd6f-5ac9-4e56-abf5-3d8719e9da52',
  2,
  'logo_mcq',
  'Which OpenAI code-generation AI model family is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/codex.svg',
  '["Codex","Cline","Claude","Copilot"]'::JSONB,
  'Codex',
  'Codex is OpenAI''s foundational code-generation AI system.',
  true
),
(
  '7650a06d-fe20-4e6b-aa50-3ad214c10ca3',
  2,
  'logo_mcq',
  'Which Microsoft AI assistant is represented by this ribbon logo?',
  NULL,
  NULL,
  '/images/round2/copilot.svg',
  '["Microsoft Copilot","Cortana","Azure AI","Bing Chat"]'::JSONB,
  'Microsoft Copilot',
  'Microsoft Copilot is the AI companion integrated across Microsoft 365, Windows, and Edge.',
  true
),
(
  '5feced45-f7e5-4cc9-a128-a4abaf00bebc',
  2,
  'logo_mcq',
  'Which data and AI platform is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/databricks.svg',
  '["Databricks","Snowflake","Dataiku","Palantir"]'::JSONB,
  'Databricks',
  'Databricks provides a unified Data and AI platform powered by Apache Spark and lakehouse architecture.',
  true
),
(
  '47f9fa87-e289-4d67-a282-aa3c0c655949',
  2,
  'logo_mcq',
  'Which AI company is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/deepseek.svg',
  '["DeepSeek","DeepMind","Mistral AI","Qwen"]'::JSONB,
  'DeepSeek',
  'DeepSeek is an AI research company renowned for its open-weight reasoning and coding models.',
  true
),
(
  '27867f35-caff-4834-ae90-ada8878cbe74',
  2,
  'logo_mcq',
  'Which AI voice generation platform is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/elevenlabs.svg',
  '["ElevenLabs","Suno","HeyGen","Murf"]'::JSONB,
  'ElevenLabs',
  'ElevenLabs specializes in realistic AI voice cloning, text-to-speech, and audio synthesis.',
  true
),
(
  'e2a0456a-7e62-4e57-afa1-be7519158a30',
  2,
  'logo_mcq',
  'Which collaborative design and AI prototyping tool uses this logo?',
  NULL,
  NULL,
  '/images/round2/figma.svg',
  '["Figma","Canva","Sketch","Adobe XD"]'::JSONB,
  'Figma',
  'Figma is the leading collaborative interface design tool with generative AI features.',
  true
),
(
  '20665f4a-8403-4b0f-a304-7957221431b2',
  2,
  'logo_mcq',
  'Which Google flagship multimodal AI is represented by this star logo?',
  NULL,
  NULL,
  '/images/round2/gemini.svg',
  '["Gemini","Bard","PaLM","DeepMind"]'::JSONB,
  'Gemini',
  'Gemini is Google''s state-of-the-art multimodal AI model family.',
  true
),
(
  '20018de2-7c49-42b4-ad5e-325e4b80bc32',
  2,
  'logo_mcq',
  'Which AI pair programmer is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/github-copilot.svg',
  '["GitHub Copilot","GitHub Actions","Codex","Cline"]'::JSONB,
  'GitHub Copilot',
  'GitHub Copilot is the AI pair programmer supporting millions of software developers.',
  true
),
(
  '12e37199-5f99-4477-a977-4b71b3a6a895',
  2,
  'logo_mcq',
  'Which AI assistant from xAI is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/grok-(xai).svg',
  '["Grok","Claude","Gemini","Perplexity"]'::JSONB,
  'Grok',
  'Grok is the AI assistant developed by Elon Musk’s xAI.',
  true
),
(
  '3d7285a4-1972-4226-a3de-1e4abcf8b808',
  2,
  'logo_mcq',
  'Which AI video and avatar generation platform is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/heygen.svg',
  '["HeyGen","Runway","Pika","Synthesia"]'::JSONB,
  'HeyGen',
  'HeyGen is an AI video generator specializing in photorealistic avatars and multilingual translation.',
  true
),
(
  'a9b20d10-97dd-4ed3-a7d6-a24708727b42',
  2,
  'logo_mcq',
  'Which open-source AI community platform is represented by this emoji logo?',
  NULL,
  NULL,
  '/images/round2/hugging-face.svg',
  '["Hugging Face","GitHub","LangChain","Replicate"]'::JSONB,
  'Hugging Face',
  'Hugging Face is the central hub for open-source AI models, datasets, and Spaces.',
  true
),
(
  '05db69d8-b998-4f8f-a9f8-93f5fb840a24',
  2,
  'logo_mcq',
  'Which framework for building LLM applications and agents is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/langchain.svg',
  '["LangChain","LangGraph","LlamaIndex","TensorFlow"]'::JSONB,
  'LangChain',
  'LangChain is a popular open-source framework for building context-aware reasoning applications.',
  true
),
(
  'c9e144d5-18b8-4fe6-a72f-cdc6dc14f5d0',
  2,
  'logo_mcq',
  'Which open-weight model family from Meta is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/llama.svg',
  '["Llama","Mistral","Falcon","Vicuna"]'::JSONB,
  'Llama',
  'Llama is Meta foundational open-weight AI model family.',
  true
),
(
  '0d13d5ed-7151-4470-a4c4-2603a69a018a',
  2,
  'logo_mcq',
  'Which AI full-stack web app builder is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/lovable.svg',
  '["Lovable","Bolt","Vercel","Replit"]'::JSONB,
  'Lovable',
  'Lovable is an AI-powered development tool that builds full-stack applications from prompts.',
  true
),
(
  '401bdb43-a31c-485c-ab20-a291544c6210',
  2,
  'logo_mcq',
  'Which AI image-generation platform is represented by this sailboat logo?',
  NULL,
  NULL,
  '/images/round2/midjourney.svg',
  '["Midjourney","DALL-E","Stable Diffusion","Adobe Firefly"]'::JSONB,
  'Midjourney',
  'Midjourney is an independent research lab creating popular text-to-image synthesis models.',
  true
),
(
  'd11f6507-20b8-447e-a559-623eabf1667d',
  2,
  'logo_mcq',
  'Which European open-weight AI powerhouse is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/mistral-ai.svg',
  '["Mistral AI","Anthropic","Cohere","DeepSeek"]'::JSONB,
  'Mistral AI',
  'Mistral AI is a Paris-based company known for frontier open-weights models like Mixtral and Mistral Large.',
  true
),
(
  'e8bc81ce-88b2-49bc-aa90-12c7761b66dd',
  2,
  'logo_mcq',
  'Which connected workspace with built-in AI assistant uses this logo?',
  NULL,
  NULL,
  '/images/round2/notion-ai.svg',
  '["Notion AI","Coda","Obsidian","Evernote"]'::JSONB,
  'Notion AI',
  'Notion AI enhances documents, wikis, and project management with automated writing and search.',
  true
),
(
  '5e1ceacd-0afe-4fa1-a9e4-d3d2cbc730b0',
  2,
  'logo_mcq',
  'Which technology company powers global AI hardware and GPUs with this green logo?',
  NULL,
  NULL,
  '/images/round2/nvidia.svg',
  '["NVIDIA","AMD","Intel","Qualcomm"]'::JSONB,
  'NVIDIA',
  'NVIDIA is the world leader in AI acceleration GPUs, CUDA software, and AI supercomputing.',
  true
),
(
  '618d8162-47d4-4986-a68e-1b923d298fcf',
  2,
  'logo_mcq',
  'Which tool allows running open LLMs locally on your computer with this llama logo?',
  NULL,
  NULL,
  '/images/round2/ollama.svg',
  '["Ollama","LM Studio","Jan","LocalAI"]'::JSONB,
  'Ollama',
  'Ollama enables running Llama, Mistral, and other open models locally on macOS, Windows, and Linux.',
  true
),
(
  'a1e2268d-3cd9-45fb-ab64-a2de41b7dbb1',
  2,
  'logo_mcq',
  'Which conversational AI search engine is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/perplexity.svg',
  '["Perplexity","You.com","Bing AI","Kagi"]'::JSONB,
  'Perplexity',
  'Perplexity AI is an AI search and answer engine that delivers real-time answers with source citations.',
  true
),
(
  'd4b92756-3824-4991-ab57-ff1ebc8a9413',
  2,
  'logo_mcq',
  'Which AI video research and creativity platform is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/runway.svg',
  '["Runway","Pika","Sora","Kaiber"]'::JSONB,
  'Runway',
  'Runway ML pioneered AI video generation tools including Gen-1, Gen-2, and Gen-3 Alpha.',
  true
),
(
  '38a3e178-58a7-423a-aa15-d29df257331f',
  2,
  'logo_mcq',
  'Which Apple built-in voice assistant is represented by this colorful orb logo?',
  NULL,
  NULL,
  '/images/round2/siri.svg',
  '["Siri","Alexa","Google Assistant","Bixby"]'::JSONB,
  'Siri',
  'Siri is Apple intelligent voice assistant integrated into Apple devices.',
  true
),
(
  '0ad825c1-8295-438a-a1a8-80380a4a35db',
  2,
  'logo_mcq',
  'Which OpenAI photorealistic text-to-video model is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/sora.svg',
  '["Sora","Runway","Luma","Kling"]'::JSONB,
  'Sora',
  'Sora is OpenAI diffusion model capable of generating high-definition video from text instructions.',
  true
),
(
  'b59b1995-c511-4eca-a126-720a5fe8998e',
  2,
  'logo_mcq',
  'Which open-source AI company created Stable Diffusion with this logo?',
  NULL,
  NULL,
  '/images/round2/stability.svg',
  '["Stability AI","Midjourney","OpenAI","Flux"]'::JSONB,
  'Stability AI',
  'Stability AI is the creator of the groundbreaking open-source Stable Diffusion image and audio models.',
  true
),
(
  'c3187197-6058-407f-ac1a-3458b2753e4e',
  2,
  'logo_mcq',
  'Which viral AI song and music generator is represented by this logo?',
  NULL,
  NULL,
  '/images/round2/suno.svg',
  '["Suno","Udio","AIVA","Boomy"]'::JSONB,
  'Suno',
  'Suno AI generates full broadcast-quality songs with vocals, lyrics, and instruments from text prompts.',
  true
),
(
  '17d07c46-832b-4fed-8d14-5c6ff33381cb',
  3,
  'emoji_mcq',
  '🤖🎬',
  NULL,
  NULL,
  NULL,
  '["AI Video Generation", "Movie Sci-Fi", "CGI VFX", "Film Director"]'::JSONB,
  'AI Video Generation',
  'Robot + Clapperboard = AI Video Generators (Sora / Runway).',
  true
),
(
  '333be725-ce08-4f8a-ac8d-ef8e16a09409',
  3,
  'emoji_mcq',
  '🤖🧩',
  NULL,
  NULL,
  NULL,
  '["Fine-Tuning / RAG", "Jigsaw Puzzle", "Pattern Matching", "System Integration"]'::JSONB,
  'Fine-Tuning / RAG',
  'Robot + Puzzle piece = Retrieval Augmented Generation & Fine-tuning.',
  true
),
(
  '46382010-ff53-4803-a883-8c46d29f01e4',
  3,
  'emoji_mcq',
  '🤖🌐',
  NULL,
  NULL,
  NULL,
  '["AGI (Artificial General Intelligence)", "Web Crawler", "Global Network", "Internet Bot"]'::JSONB,
  'AGI (Artificial General Intelligence)',
  'Robot + Globe = Human-level worldwide general intelligence.',
  true
),
(
  '491bd851-637b-4861-ac7c-7ee9074f3a26',
  3,
  'emoji_mcq',
  '🧠⚡',
  NULL,
  NULL,
  NULL,
  '["Neural Network", "Brainstorming", "Electric Shock", "Mind Reading"]'::JSONB,
  'Neural Network',
  'Brain + Lightning = Artificial Neural Network & Deep Learning.',
  true
),
(
  '533f554b-c14f-4c4c-b61c-f8fab9c1ac86',
  3,
  'emoji_mcq',
  '🤖🕹️',
  NULL,
  NULL,
  NULL,
  '["Reinforcement Learning", "Gaming Bot", "VR Headset", "Arcade Game"]'::JSONB,
  'Reinforcement Learning',
  'Robot + Joystick = AI training via RL rewards & gaming bots.',
  true
),
(
  '5ba8fb1a-5342-4e59-b819-6b101c8ad3a9',
  3,
  'emoji_mcq',
  '🗣️🤖',
  NULL,
  NULL,
  NULL,
  '["Voice Assistant", "Robot Singer", "Podcast Host", "Audiobook"]'::JSONB,
  'Voice Assistant',
  'Speaking head + Robot = Voice Assistant (Siri / Alexa).',
  true
),
(
  '6ceb370b-0a49-429b-bd13-bc61b51acf12',
  3,
  'emoji_mcq',
  '🎵🤖',
  NULL,
  NULL,
  NULL,
  '["AI Music Generator", "Robo DJ", "Electronic Music", "Auto-Tune"]'::JSONB,
  'AI Music Generator',
  'Music note + Robot = AI Song Creators (Suno / Udio).',
  true
),
(
  '77e5cd8c-4eba-4b69-9d9d-f048cb9179cc',
  3,
  'emoji_mcq',
  '🤖💬',
  NULL,
  NULL,
  NULL,
  '["Chatbot", "Robocop", "Cyberpunk", "Smart Speaker"]'::JSONB,
  'Chatbot',
  'Robot + Speech Bubble = Conversational AI Chatbot!',
  true
),
(
  '791d445f-3889-4c28-8209-a471b2d254a6',
  3,
  'emoji_mcq',
  '🤖🤖',
  NULL,
  NULL,
  NULL,
  '["Multi-Agent System", "Twins", "Clone Wars", "Robotics Club"]'::JSONB,
  'Multi-Agent System',
  'Multiple Robots = Multi-Agent LLM Orchestration.',
  true
),
(
  '830ddbd3-0ff3-4c8d-bf7c-05b548e24e9d',
  3,
  'emoji_mcq',
  '🤖🕵️',
  NULL,
  NULL,
  NULL,
  '["AI Hallucination Detector", "Cyber Detective", "Spyware", "Fact Checker"]'::JSONB,
  'AI Hallucination Detector',
  'Robot + Detective = Detecting AI fabrications & hallucinations.',
  true
),
(
  '959cf20b-d846-427a-b517-7a85c4e92272',
  3,
  'emoji_mcq',
  '👁️🤖',
  NULL,
  NULL,
  NULL,
  '["Computer Vision", "Cyber Eye", "Surveillance", "Optical Sensor"]'::JSONB,
  'Computer Vision',
  'Eye + Robot = Computer Vision & Image Recognition.',
  true
),
(
  '979f7aee-460a-4876-ad4f-e86bab5ddcae',
  3,
  'emoji_mcq',
  '🤖💊',
  NULL,
  NULL,
  NULL,
  '["AI Drug Discovery", "Robotic Surgery", "Smart Medicine", "Biohacking"]'::JSONB,
  'AI Drug Discovery',
  'Robot + Pill = AI accelerating molecular & pharmaceutical discovery.',
  true
),
(
  'ac8e4eee-98d9-48f9-8818-166e1aa78fd7',
  3,
  'emoji_mcq',
  '🔍🤖',
  NULL,
  NULL,
  NULL,
  '["AI Search Engine", "Magnifying Glass", "Deep Web", "Data Mining"]'::JSONB,
  'AI Search Engine',
  'Search + Robot = AI Answer Engines (Perplexity).',
  true
),
(
  'b3f1a2c5-3752-4055-89cf-f868d44d6c94',
  3,
  'emoji_mcq',
  '🤖📊',
  NULL,
  NULL,
  NULL,
  '["Data Analytics AI", "Stock Market Bot", "Spreadsheet Automation", "Infographic"]'::JSONB,
  'Data Analytics AI',
  'Robot + Chart = AI powered data analysis & insights.',
  true
),
(
  'b74cca07-f5e9-48a7-81e2-6f7971a4d6a2',
  3,
  'emoji_mcq',
  '🤖🛡️',
  NULL,
  NULL,
  NULL,
  '["AI Safety & Alignment", "Cybersecurity", "Firewall", "Robo Guard"]'::JSONB,
  'AI Safety & Alignment',
  'Robot + Shield = Guardrails, Constitutional AI, and Safety.',
  true
),
(
  'd45edb8b-d191-4fe8-b1f8-e07733a57928',
  3,
  'emoji_mcq',
  '🤖📝',
  NULL,
  NULL,
  NULL,
  '["AI Copywriter", "Auto Essay", "Spellcheck", "Blogging"]'::JSONB,
  'AI Copywriter',
  'Robot + Memo = AI content writing and draft generation.',
  true
),
(
  'd9f1ec25-b5cd-4395-884a-b106c310e7cb',
  3,
  'emoji_mcq',
  '🤖🚗',
  NULL,
  NULL,
  NULL,
  '["Autonomous Driving", "Robot Car", "Electric Vehicle", "GPS Navigation"]'::JSONB,
  'Autonomous Driving',
  'Robot + Car = Self-Driving Vehicles (Tesla FSD / Waymo).',
  true
),
(
  'df9e2fcf-7a77-4caa-b821-dcb795858d44',
  3,
  'emoji_mcq',
  '🎨🤖',
  NULL,
  NULL,
  NULL,
  '["AI Image Generator", "Digital Painting", "Graphic Designer", "NFT Art"]'::JSONB,
  'AI Image Generator',
  'Palette + Robot = AI Image Generation (Midjourney / DALL-E).',
  true
),
(
  'f1d92b64-bb86-4e77-93e5-8b5cc03cae5b',
  3,
  'emoji_mcq',
  '📜🤖',
  NULL,
  NULL,
  NULL,
  '["Prompt Engineering", "Robot History", "Terms of Service", "Smart Contract"]'::JSONB,
  'Prompt Engineering',
  'Scroll + Robot = Crafting Prompts / Text Instructions.',
  true
),
(
  'fcc9a388-7489-4348-a707-3e8357065607',
  3,
  'emoji_mcq',
  '💻🤖',
  NULL,
  NULL,
  NULL,
  '["AI Code Assistant", "Hackathon", "Robotic Laptop", "Software Engineer"]'::JSONB,
  'AI Code Assistant',
  'Laptop + Robot = Coding Copilots (GitHub Copilot / Cursor).',
  true
)
ON CONFLICT (id) DO UPDATE SET
  round = EXCLUDED.round,
  question_type = EXCLUDED.question_type,
  prompt_text = EXCLUDED.prompt_text,
  real_image_url = EXCLUDED.real_image_url,
  ai_image_url = EXCLUDED.ai_image_url,
  logo_url = EXCLUDED.logo_url,
  options = EXCLUDED.options,
  correct_option = EXCLUDED.correct_option,
  explanation = EXCLUDED.explanation,
  is_active = EXCLUDED.is_active;

-- ==============================================================================
-- 10. POPULATE MATCHES (data/matches_rows.csv)
-- ==============================================================================
INSERT INTO matches (id, room_code, host_id, status, current_round, round_started_at, round_duration_seconds, created_at)
VALUES
(
  '00d28983-7122-4446-8521-20d968b095c2',
  'O6MGW4',
  'host',
  'archived',
  3,
  '2026-09-15 16:17:44.299+00',
  15,
  '2026-09-16T21:21:48.254Z'
),
(
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'N8WKZL',
  'host',
  'final_results',
  3,
  '2026-09-16 11:53:30.205+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '1d656a24-a6d3-4e9d-a6ce-293e1f039e85',
  '6PKSY5',
  'host',
  'final_results',
  3,
  '2026-09-15 20:32:58.896+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '1e944440-9340-4761-b5aa-712424f84244',
  'HW409Z',
  'host',
  'archived',
  0,
  NULL,
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  'PMDD3Y',
  'host',
  'archived',
  3,
  '2026-09-15 18:06:26.613+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '35219079-e23f-49f2-a64d-c8b3bf714ee9',
  'HIPC3K',
  'host',
  'final_results',
  3,
  '2026-09-16 17:44:15.075+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  '1BPGVH',
  'host',
  'final_results',
  3,
  '2026-09-16 07:35:34.621+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '47ed4afa-bc9e-436f-a9ec-8a6779f2b8dc',
  '7P6MEP',
  'host',
  'final_results',
  3,
  '2026-09-16 17:47:15.456+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'K71SSP',
  'host',
  'archived',
  3,
  '2026-09-15 17:05:16.355+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '4f68b92f-e276-4630-a250-9c6c1cf1e6f8',
  'LJ2QOX',
  'host',
  'final_results',
  3,
  '2026-09-15 19:27:06.443+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '62492d4b-cec1-42d7-ac95-35d1b7595022',
  'W1SCFB',
  'host',
  'final_results',
  3,
  '2026-09-15 18:52:10.326+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '8203b2f9-5954-4281-ac8a-c3a4014c0314',
  '4TYXQV',
  'host',
  'final_results',
  3,
  '2026-09-16 10:29:41.478+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '8c68c517-c8f0-435e-a131-71045d26b67f',
  'F6HIUJ',
  'host',
  'final_results',
  3,
  '2026-09-16 17:12:25.379+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'NPQDRB',
  'host',
  'final_results',
  3,
  '2026-09-16 08:23:39.262+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '9ceeff7d-2096-416d-8e0a-679e1e8d9ba9',
  'MXKL1A',
  'host',
  'archived',
  3,
  '2026-09-15 16:32:48.348+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  'NZ6N6E',
  'host',
  'final_results',
  3,
  '2026-09-15 18:16:08.197+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  'a463d15d-0e6c-41cd-b251-deeb87d8c85c',
  '3UIXS3',
  'host',
  'archived',
  3,
  '2026-09-15 17:18:28.187+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '308XFX',
  'host',
  'archived',
  3,
  '2026-09-15 17:32:29.309+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  'bccc8621-3497-4d8e-9ef0-32bb32796873',
  'EM353B',
  'host',
  'final_results',
  3,
  '2026-09-15 19:20:15.735+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  'e257ee3e-ae1e-47b1-a783-eb01dfe7f755',
  'AN47SK',
  'host',
  'round2_results',
  2,
  '2026-09-16 17:48:48.013+00',
  15,
  '2026-09-16T21:21:48.256Z'
),
(
  'e73ffce7-e431-4e8a-9865-6b786403be63',
  'XJZI90',
  'host',
  'archived',
  3,
  '2026-09-15 17:23:11.997+00',
  15,
  '2026-09-16T21:21:48.256Z'
)
ON CONFLICT (id) DO UPDATE SET
  room_code = EXCLUDED.room_code,
  status = EXCLUDED.status,
  current_round = EXCLUDED.current_round;

-- ==============================================================================
-- 11. POPULATE MATCH PLAYERS (data/match_players_rows.csv)
-- ==============================================================================
INSERT INTO match_players (id, match_id, display_name, device_token, has_completed_session, joined_at, has_left)
VALUES
(
  '036530a2-4609-4f94-af08-c493566c98f1',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  'A',
  'dev_l4pldalvdt',
  false,
  '2026-09-15 18:12:05.272147+00',
  false
),
(
  '068f5a6c-3f7f-4bb4-8237-7da7a3c4097b',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'A',
  'dev_rg5x30frz1',
  false,
  '2026-09-15 17:30:07.158199+00',
  false
),
(
  '08d8c459-a697-4d19-bd36-6fb5c57f947d',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Swayam',
  'dev_f74mffohq1',
  false,
  '2026-09-16 08:20:06.756352+00',
  false
),
(
  '09ab726a-b749-42b1-b54c-db394f500dda',
  '8203b2f9-5954-4281-ac8a-c3a4014c0314',
  'Kaju katli',
  'dev_mbddusq8fp',
  false,
  '2026-09-16 10:26:35.199465+00',
  false
),
(
  '0bf4019d-3d8f-48fc-a6a5-2630c94bce00',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'Rex',
  'dev_lx6wsly1vx',
  false,
  '2026-09-15 17:28:04.580418+00',
  false
),
(
  '0c341f78-64c5-4249-91e6-fa467fdc3908',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  'Moryaa',
  'dev_ym0dviepgb',
  false,
  '2026-09-15 18:12:11.357433+00',
  false
),
(
  '0f47e77e-3ae0-49b1-a483-29f02ba9ec18',
  '8203b2f9-5954-4281-ac8a-c3a4014c0314',
  'Pradip',
  'dev_maa8blrilx',
  false,
  '2026-09-16 10:23:36.21617+00',
  false
),
(
  '0f573e4f-c8c8-4a18-bfaf-f17235dc448c',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'nakichet',
  'dev_r2j6k6vbja',
  false,
  '2026-09-15 16:54:45.256352+00',
  false
),
(
  '0fb7cef2-63e6-4d7b-a22a-4bf684a3a195',
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  'Master Bruice',
  'dev_q0bhpm9hgr',
  false,
  '2026-09-15 17:59:32.322869+00',
  false
),
(
  '126b991a-fe3b-4605-b4dc-d8244f570615',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  'Harsh',
  'dev_2mxsc6h5sc',
  false,
  '2026-09-16 07:30:44.709219+00',
  false
),
(
  '139ea937-3fae-4041-bc8d-9afad6d73069',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'Safety First',
  'dev_fnr1fgst4n',
  false,
  '2026-09-16 11:48:00.692992+00',
  false
),
(
  '14ade3ad-a060-4528-962d-9ac680798dc1',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'https://iae-squ',
  'dev_fddifngd7v',
  false,
  '2026-09-15 17:28:08.798076+00',
  false
),
(
  '165d6d71-f2d0-4a64-8590-e8c0f35022d4',
  '00d28983-7122-4446-8521-20d968b095c2',
  'Vik',
  'dev_vlx3n7rg7t',
  false,
  '2026-09-15 16:13:58.484531+00',
  false
),
(
  '16680d52-5f04-484d-90a7-edf5fde24d65',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  'Deepak Ratnani',
  'dev_0o7zw4vqrf',
  false,
  '2026-09-16 07:30:11.020425+00',
  false
),
(
  '1777f439-c252-418f-9a87-772e9adcea94',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'ET',
  'dev_8fb5r19k33',
  false,
  '2026-09-15 17:27:55.836682+00',
  false
),
(
  '1a343685-d27e-4332-a0e2-84ceb0924cb5',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Anshuman',
  'dev_33027pv9ss',
  false,
  '2026-09-16 08:19:58.41912+00',
  false
),
(
  '1a8f7e7e-a68e-42e6-8bc6-a219eaa73af9',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  'Nakli gopal',
  'dev_lx6wsly1vx',
  false,
  '2026-09-15 18:12:14.860364+00',
  false
),
(
  '1af4b67b-a028-48e5-92bf-9e02640ae117',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  'Manish',
  'dev_wgfpntxk7a',
  false,
  '2026-09-16 07:32:37.303153+00',
  false
),
(
  '225fd83a-3774-4351-8528-4e4da935134e',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'Tomy',
  'dev_4o7yuhi8hp',
  false,
  '2026-09-16 11:49:32.720781+00',
  false
),
(
  '2272f83f-5031-4f70-8667-d5179d012bbb',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  'Vi',
  'dev_opy5hidmh8',
  false,
  '2026-09-15 18:12:27.688475+00',
  false
),
(
  '250adf3d-9d17-47ad-8add-9edbb97e86ab',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  'Luffy',
  'dev_uyrffxtmbm',
  false,
  '2026-09-16 07:31:31.584625+00',
  false
),
(
  '264cc996-313f-4180-b4df-ca7394c096de',
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  'A',
  'dev_l4pldalvdt',
  false,
  '2026-09-15 17:59:54.36335+00',
  false
),
(
  '26586f6d-077b-4340-9873-dbc7bdcd18fd',
  'bccc8621-3497-4d8e-9ef0-32bb32796873',
  'Niii',
  'dev_l5bo4lv0il',
  false,
  '2026-09-15 18:57:13.402941+00',
  false
),
(
  '293dfec9-988b-4727-b59a-02593eaa8951',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'SayaliVairagade',
  'dev_6uae0cu3wa',
  false,
  '2026-09-16 11:47:36.910821+00',
  false
),
(
  '29436d90-d292-4fa5-ac2a-3b22fbc90db0',
  '8203b2f9-5954-4281-ac8a-c3a4014c0314',
  'Tuneer Tarane',
  'dev_1i6fhgfqjk',
  false,
  '2026-09-16 10:22:51.715812+00',
  false
),
(
  '2bb29b3e-1cba-4b71-973f-7a1075d061cc',
  '00d28983-7122-4446-8521-20d968b095c2',
  'Naina',
  'dev_l5bo4lv0il',
  false,
  '2026-09-15 16:12:20.522835+00',
  false
),
(
  '2c1ac76f-f076-4d45-8995-889013ca4226',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'Kartik-k',
  'dev_1swt58ross',
  false,
  '2026-09-15 16:55:22.51082+00',
  false
),
(
  '2c9311f2-a0c0-4384-931c-c75df00a3256',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Asad',
  'dev_yk2wc9xwan',
  false,
  '2026-09-16 08:19:44.694117+00',
  false
),
(
  '2e431faf-f302-4d93-a698-a10170dfbcc7',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'Viki',
  'dev_5kakz7nf0g',
  false,
  '2026-09-15 17:27:18.087623+00',
  false
),
(
  '2e99d416-b3b0-42a9-8ab8-31e151ece4b7',
  '35219079-e23f-49f2-a64d-c8b3bf714ee9',
  'Kunal',
  'dev_uumzlz1hpf',
  false,
  '2026-09-16 17:40:49.423016+00',
  false
),
(
  '2e9b0586-40a1-4f5f-8480-8249b5ae2e2a',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Kunal z',
  'dev_9pac2ghlyb',
  false,
  '2026-09-16 08:20:38.679609+00',
  false
),
(
  '2ff1728f-d092-4401-a3e0-d302a5e84da5',
  'e73ffce7-e431-4e8a-9865-6b786403be63',
  'Rex',
  'dev_lx6wsly1vx',
  false,
  '2026-09-15 17:19:07.087984+00',
  false
),
(
  '307f93c2-89d4-4343-8330-d022fd6231b5',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Priyanka P',
  'dev_q985vie78u',
  false,
  '2026-09-16 08:20:52.227827+00',
  false
),
(
  '31f9a0ac-6ef9-4255-8811-cfd46988d2a2',
  '9ceeff7d-2096-416d-8e0a-679e1e8d9ba9',
  'Harshad',
  'dev_n03crenp2v',
  false,
  '2026-09-15 16:30:11.138963+00',
  false
),
(
  '3224bbf1-a3aa-4190-a5fe-a2e498866fad',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  'Amit',
  'dev_evkmnr8stj',
  false,
  '2026-09-16 07:30:45.022264+00',
  false
),
(
  '3306d56e-e5d6-4c7d-a7f0-1a39e1c5ab95',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  'Vaish',
  'dev_zdweyefwmc',
  false,
  '2026-09-15 18:11:50.096893+00',
  false
),
(
  '3367e59f-9e64-42e3-a4d1-64ef5afcaed1',
  'a463d15d-0e6c-41cd-b251-deeb87d8c85c',
  'N',
  'dev_l5bo4lv0il',
  false,
  '2026-09-15 17:15:58.38585+00',
  false
),
(
  '36cc7195-31e6-4ad5-8d9c-20f76988aeae',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'Vik',
  'dev_opy5hidmh8',
  false,
  '2026-09-15 17:27:42.91278+00',
  false
),
(
  '37418e51-3eb5-41ae-903a-3e6ad4dcc7bb',
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  'Vaish',
  'dev_zdweyefwmc',
  false,
  '2026-09-15 17:59:16.524168+00',
  false
),
(
  '37887cf6-42e1-460a-9c6a-638282068b6f',
  '00d28983-7122-4446-8521-20d968b095c2',
  'Kunal',
  'dev_rkd4zfya89',
  false,
  '2026-09-15 16:13:10.868451+00',
  false
),
(
  '37be48f3-546e-4ffb-803f-653088727118',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'Kartik-k',
  'dev_yuqdoooky9',
  false,
  '2026-09-15 17:29:58.76645+00',
  false
),
(
  '3830f71b-70ae-4113-a11f-8f5d22092e54',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  'Vishal',
  'dev_afqdi17nku',
  false,
  '2026-09-16 07:30:16.473496+00',
  false
),
(
  '389c6f89-994d-4b35-8617-c76ae79b63aa',
  '8203b2f9-5954-4281-ac8a-c3a4014c0314',
  'Jyotiraditya',
  'dev_anx8t0q6ww',
  false,
  '2026-09-16 10:22:39.947207+00',
  false
),
(
  '391c1b46-4561-4c15-b864-a0028f2dec88',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Akash',
  'dev_4j1phm1nc9',
  false,
  '2026-09-16 08:19:40.896152+00',
  false
),
(
  '3b74d600-e6c2-48fa-a152-681f713825cb',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Katil kalua',
  'dev_v5d60hk8m1',
  false,
  '2026-09-16 08:20:58.128621+00',
  false
),
(
  '3d66a586-3454-4437-b897-97d5858f4da5',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'A',
  'dev_cgtf656z3l',
  false,
  '2026-09-15 16:54:47.250611+00',
  false
),
(
  '3fac041a-7fa3-4e7e-ae44-bfb533bcc090',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  'Harshal🍁',
  'dev_7n526rqplm',
  false,
  '2026-09-16 07:31:19.643734+00',
  false
),
(
  '3fb948bb-52a1-4303-a014-238fbf16d523',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'JK',
  'dev_46bpqluvd1',
  false,
  '2026-09-16 11:47:42.194486+00',
  false
),
(
  '3ff6b5ca-39fe-444d-8332-b52ce6dcb77d',
  '4f68b92f-e276-4630-a250-9c6c1cf1e6f8',
  'Vik',
  'dev_vlx3n7rg7t',
  false,
  '2026-09-15 19:21:49.196809+00',
  false
),
(
  '452cf2a7-49e1-4bb8-a535-86b1d7c0e473',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  'Suraj Patel',
  'dev_7aie530za1',
  false,
  '2026-09-16 07:30:51.676303+00',
  false
),
(
  '4957c8f1-3943-4749-8a87-2307b7478984',
  'e73ffce7-e431-4e8a-9865-6b786403be63',
  'Kunal',
  'dev_glp8vpdif1',
  false,
  '2026-09-15 17:19:47.586388+00',
  false
),
(
  '4adb7b5c-72cd-4a58-b2e2-def6e258b9c7',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  'Himanshu',
  'dev_3gpglqjwdw',
  false,
  '2026-09-16 07:30:17.808741+00',
  false
),
(
  '4b212827-d516-411f-b4b5-906a58c4617b',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  'V',
  'dev_rg5x30frz1',
  false,
  '2026-09-15 18:11:36.555163+00',
  false
),
(
  '4d349418-f511-41e9-b371-9f80fdfa5935',
  '62492d4b-cec1-42d7-ac95-35d1b7595022',
  'Naa',
  'dev_l5bo4lv0il',
  false,
  '2026-09-15 18:49:04.169976+00',
  false
),
(
  '4f6d1aa2-d59b-407a-aa4b-f859443e6d25',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'Niraj',
  'dev_7g5j79i5uy',
  false,
  '2026-09-16 11:50:20.094811+00',
  false
),
(
  '4fc47b95-9353-4b44-8586-6bb262d09910',
  '9ceeff7d-2096-416d-8e0a-679e1e8d9ba9',
  'Kartik-k',
  'dev_1swt58ross',
  false,
  '2026-09-15 16:30:26.532505+00',
  false
),
(
  '50392e0a-a2b4-4781-b906-cfe37a875b02',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'Dove',
  'dev_yvlcytgd41',
  false,
  '2026-09-16 11:47:47.98983+00',
  false
),
(
  '505c323c-dcfe-437f-b307-3df2c6f02d9d',
  '1d656a24-a6d3-4e9d-a6ce-293e1f039e85',
  'V',
  'dev_qh8ony6wwn',
  false,
  '2026-09-15 20:30:55.363272+00',
  false
),
(
  '53d90035-9071-46e2-80eb-045bdcada7a3',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'Santoshkumar',
  'dev_lemji1z5kb',
  false,
  '2026-09-16 11:47:56.251216+00',
  false
),
(
  '53eb4d14-758e-4c9e-85f7-10e652dee8b4',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'Preet',
  'dev_69wcdlq1yf',
  false,
  '2026-09-16 11:49:15.021005+00',
  false
),
(
  '542c9e33-1c81-45af-ac86-b87f4b537681',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'Tanvi',
  'dev_vtqvmuv4ei',
  false,
  '2026-09-16 11:50:44.906974+00',
  false
),
(
  '61382c64-6aff-4f8b-9c34-588b19bb3ee2',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'Rex',
  'dev_bgshkdn7w4',
  false,
  '2026-09-15 17:28:00.669909+00',
  false
),
(
  '6202ad9f-7b8a-416e-9c73-b82b2fa9298d',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'Vi',
  'dev_wxu8mbbbqx',
  false,
  '2026-09-15 17:29:51.279689+00',
  false
),
(
  '62a7049a-58b9-4cf0-b212-e0725d53e408',
  '9ceeff7d-2096-416d-8e0a-679e1e8d9ba9',
  'Nick',
  'dev_mo9pfdnezw',
  false,
  '2026-09-15 16:28:43.841216+00',
  false
),
(
  '63af4b6a-430d-473b-9076-69202388ef9c',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Vaibhav',
  'dev_50gix258zs',
  false,
  '2026-09-16 08:20:13.186985+00',
  false
),
(
  '65097808-5af0-4b45-b901-60b432335e3e',
  '1d656a24-a6d3-4e9d-a6ce-293e1f039e85',
  'Kunal',
  'dev_rkd4zfya89',
  false,
  '2026-09-15 20:30:15.00252+00',
  false
),
(
  '66b077b0-39a9-4e2f-a763-fd3af7b7704c',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  'AsH',
  'dev_sbignvmi7l',
  false,
  '2026-09-16 07:30:12.466884+00',
  false
),
(
  '68d34553-6d6e-4cb4-88ae-188ed47859fe',
  '9ceeff7d-2096-416d-8e0a-679e1e8d9ba9',
  'Niku',
  'dev_l5bo4lv0il',
  false,
  '2026-09-15 16:27:53.513099+00',
  false
),
(
  '6b62e577-fb26-4f23-b7ed-762f3c5e0d68',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Rolex',
  'dev_03ljzvqi15',
  false,
  '2026-09-16 08:19:42.993851+00',
  false
),
(
  '6c803b0a-d4f5-4e6d-a083-5ee08c7d6bad',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'PlzzNo',
  'dev_3i9fjqg0g7',
  false,
  '2026-09-15 17:27:19.268277+00',
  false
),
(
  '6ce386b0-8111-4fd0-8cca-7f246e32f801',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'V',
  'dev_zdweyefwmc',
  false,
  '2026-09-15 17:27:53.716857+00',
  false
),
(
  '6d18c58b-cf3b-4b85-b54f-be4beb7cb567',
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  'Gopal',
  'dev_25urcadjdd',
  false,
  '2026-09-15 17:58:52.434537+00',
  false
),
(
  '6d71b134-bab1-4415-9755-41c96c31ca8f',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'Pawan',
  'dev_w1ypnztxke',
  false,
  '2026-09-15 16:54:27.264931+00',
  false
),
(
  '6eff57af-4564-4ba8-9776-5d3e11000f9b',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Jack',
  'dev_fuqb9qcxtr',
  false,
  '2026-09-16 08:20:54.545083+00',
  false
),
(
  '704895b2-b1d8-42e2-aa15-6ec66bc6680d',
  'e73ffce7-e431-4e8a-9865-6b786403be63',
  'N',
  'dev_3i9fjqg0g7',
  false,
  '2026-09-15 17:19:01.154161+00',
  false
),
(
  '729f3163-fe78-445d-84c7-bb6f6106bd7a',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'n',
  'dev_5fsvactmz1',
  false,
  '2026-09-15 17:07:47.947216+00',
  false
),
(
  '7329cda1-368b-422b-841f-44b3e45bb17f',
  'e73ffce7-e431-4e8a-9865-6b786403be63',
  'Viki',
  'dev_5kakz7nf0g',
  false,
  '2026-09-15 17:19:12.848057+00',
  false
),
(
  '74523567-984e-4522-a5da-312df890f7ca',
  '9ceeff7d-2096-416d-8e0a-679e1e8d9ba9',
  'Rex',
  'dev_uqljavj6qw',
  false,
  '2026-09-15 16:27:38.754899+00',
  false
),
(
  '7681187d-0939-4ba2-82b8-d2c206d919fd',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  'Nii',
  'dev_3i9fjqg0g7',
  false,
  '2026-09-15 18:11:25.395082+00',
  false
),
(
  '77107f8f-c46c-4759-968a-1d7aa1e011ca',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'Nick',
  'dev_vah29cctgm',
  false,
  '2026-09-15 16:55:51.488835+00',
  false
),
(
  '7a298265-1dd8-4eaf-aec8-bc0e7049e952',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'Vaish',
  'dev_qh8ony6wwn',
  false,
  '2026-09-15 16:54:09.708499+00',
  false
),
(
  '7b1d3b10-ae4e-4eeb-8aa8-0496296f04a3',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Raju',
  'dev_iadwka9e01',
  false,
  '2026-09-16 08:20:46.1734+00',
  false
),
(
  '7bfe5e68-6355-48d9-b6cc-68b0f5e81db5',
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  'Gopal',
  'dev_lx6wsly1vx',
  false,
  '2026-09-15 17:59:35.715399+00',
  false
),
(
  '7e7ea678-fba6-41cc-a725-2675500ceead',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  'Komal',
  'dev_il4iwch6pb',
  false,
  '2026-09-16 08:20:59.284246+00',
  false
),
(
  '829a31b1-612f-4fbd-b188-c7cdbd05149b',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'Sudhanshu',
  'dev_udfct5vdrb',
  false,
  '2026-09-16 11:49:06.428733+00',
  false
),
(
  '834f9d22-0ac3-488a-ab95-fc0724dce78e',
  '9ceeff7d-2096-416d-8e0a-679e1e8d9ba9',
  'Kunal',
  'dev_rkd4zfya89',
  false,
  '2026-09-15 16:27:58.481578+00',
  false
),
(
  '84209831-7152-4284-9ed5-269812642bcc',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'nachiket',
  'dev_wb5hkt8f6h',
  false,
  '2026-09-15 16:55:59.88474+00',
  false
),
(
  '854f81ba-baf0-4548-a056-f0e1eacd366a',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'Omm',
  'dev_i4nql7m80p',
  false,
  '2026-09-15 16:54:10.060599+00',
  false
),
(
  '86a4c86b-5dc3-44ff-83cf-8e8a4b855910',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'Sheetal',
  'dev_9miyz7d8x7',
  false,
  '2026-09-16 11:49:22.963941+00',
  false
),
(
  '86f6cb83-ba69-4059-9025-2b3f500ebf81',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'Nick',
  'dev_l5bo4lv0il',
  false,
  '2026-09-15 16:40:04.740196+00',
  false
),
(
  '8d517b7c-a588-4286-8a35-10dec02717b0',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'Liv',
  'dev_vtb65edhed',
  false,
  '2026-09-15 17:29:02.606695+00',
  false
),
(
  '8e1d2076-a8b9-4f4e-9924-59e7ddfbf9f9',
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  'Chiku',
  'dev_5kakz7nf0g',
  false,
  '2026-09-15 17:59:05.911147+00',
  false
),
(
  '8e9a892b-7b12-4f34-8d89-fde7112dcd1a',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  'Gayatri',
  'dev_nxrei88koo',
  false,
  '2026-09-16 11:49:03.893804+00',
  false
),
(
  '90e34ae7-f6ff-4eff-a004-9d1cce0c653b',
  '8203b2f9-5954-4281-ac8a-c3a4014c0314',
  'Shrikant',
  'dev_o8i82oldb5',
  false,
  '2026-09-16 10:22:44.006291+00',
  false
),
(
  '94f5606d-9099-46a6-ad3d-7ca22fe09547',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  'Radhe Bhaiya',
  'dev_ew9bdebvso',
  false,
  '2026-09-16 07:30:27.135921+00',
  false
),
(
  '98a3eb01-ef22-4f83-ac46-223a12430d21',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  'V',
  'dev_ezq1xuvkct',
  false,
  '2026-09-15 16:54:03.194589+00',
  false
),
(
  '99e21e52-c37f-45f7-8f55-0709bc729110',
  '8203b2f9-5954-4281-ac8a-c3a4014c0314',
  'Nachiket',
  'dev_fddifngd7v',
  false,
  '2026-09-16 10:24:25.124323+00',
  false
),
(
  '99e88460-705d-49a1-aef0-0e8984623e17',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  'test3',
  'dev_fyzqhgl6br',
  false,
  '2026-09-15 18:13:59.921076+00',
  false
),
(
  '9e73b632-2e07-4b8a-b42f-37d373250efd',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  'CD',
  'dev_chenvw87s6',
  false,
  '2026-09-15 17:28:52.228336+00',
  false
),
(
  '9f868879-9020-4cf3-a041-a51a8ce6d715',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  'test2',
  'dev_92m3eu940t',
  false,
  '2026-09-15 18:14:01.32492+00',
  false
)
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  device_token = EXCLUDED.device_token,
  has_left = EXCLUDED.has_left;

-- ==============================================================================
-- 12. POPULATE MATCH ROUND QUESTIONS (Validated FK Rows)
-- ==============================================================================
INSERT INTO match_round_questions (id, match_id, player_id, round, question_id, position)
VALUES
(
  '00696213-53c1-4389-9dcc-ffbc06c7f401',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  '250adf3d-9d17-47ad-8add-9edbb97e86ab',
  1,
  'c1b8ea0b-512d-46ac-b9fe-8a0c40dcea2a',
  1
),
(
  '00a96594-705c-4371-90ba-5146cec778e3',
  '1d656a24-a6d3-4e9d-a6ce-293e1f039e85',
  '505c323c-dcfe-437f-b307-3df2c6f02d9d',
  3,
  'fcc9a388-7489-4348-a707-3e8357065607',
  2
),
(
  '00c7f354-a6be-4508-8b44-2b2a2924b5b5',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  '94f5606d-9099-46a6-ad3d-7ca22fe09547',
  3,
  '6ceb370b-0a49-429b-bd13-bc61b51acf12',
  3
),
(
  '00f6dd99-9066-4527-9c73-f9728cd43d9c',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  '391c1b46-4561-4c15-b864-a0028f2dec88',
  3,
  '5ba8fb1a-5342-4e59-b819-6b101c8ad3a9',
  4
),
(
  '014ee1f8-03b1-4961-a805-0fe6da7a5617',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  '98a3eb01-ef22-4f83-ac46-223a12430d21',
  3,
  '5ba8fb1a-5342-4e59-b819-6b101c8ad3a9',
  5
),
(
  '01b5a6d2-e754-4099-aadf-c9b158b7c0d7',
  'e73ffce7-e431-4e8a-9865-6b786403be63',
  '2ff1728f-d092-4401-a3e0-d302a5e84da5',
  3,
  'd45edb8b-d191-4fe8-b1f8-e07733a57928',
  6
),
(
  '01d950da-0cc5-4f85-99cb-b7e3bf4cd885',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  '2e9b0586-40a1-4f5f-8480-8249b5ae2e2a',
  3,
  '46382010-ff53-4803-a883-8c46d29f01e4',
  7
),
(
  '02002bb3-efe9-4566-92ff-c8deb1009442',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '1777f439-c252-418f-9a87-772e9adcea94',
  1,
  '3bba083c-ae4f-405b-8732-d904bae2f299',
  8
),
(
  '0221bc6d-98bb-43df-b08f-25dfa77e765d',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  '4f6d1aa2-d59b-407a-aa4b-f859443e6d25',
  3,
  'd9f1ec25-b5cd-4395-884a-b106c310e7cb',
  9
),
(
  '02a423c2-a458-430e-823e-2bdfe1571104',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  '50392e0a-a2b4-4781-b906-cfe37a875b02',
  3,
  '830ddbd3-0ff3-4c8d-bf7c-05b548e24e9d',
  10
),
(
  '02e97f6d-da82-47e7-9f53-554afe3670e1',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  '2c9311f2-a0c0-4384-931c-c75df00a3256',
  3,
  '791d445f-3889-4c28-8209-a471b2d254a6',
  1
),
(
  '0359dc58-071f-4e06-874b-f1c79161d8ae',
  '8203b2f9-5954-4281-ac8a-c3a4014c0314',
  '09ab726a-b749-42b1-b54c-db394f500dda',
  3,
  '533f554b-c14f-4c4c-b61c-f8fab9c1ac86',
  2
),
(
  '0376e87c-b2fa-43c8-9ba7-dafb25414151',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  '1a8f7e7e-a68e-42e6-8bc6-a219eaa73af9',
  3,
  'd9f1ec25-b5cd-4395-884a-b106c310e7cb',
  3
),
(
  '03ae9c6c-e502-4038-9706-d3fa15c485b1',
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  '37418e51-3eb5-41ae-903a-3e6ad4dcc7bb',
  1,
  '1a13fa30-752c-44d6-9ad1-64b3898bd2a6',
  4
),
(
  '0498497b-47d1-4559-86b4-22d1755cb59d',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  '84209831-7152-4284-9ed5-269812642bcc',
  3,
  '46382010-ff53-4803-a883-8c46d29f01e4',
  5
),
(
  '049d3e8a-f3e1-42aa-8d60-6a81e936d8be',
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  '0fb7cef2-63e6-4d7b-a22a-4bf684a3a195',
  3,
  '533f554b-c14f-4c4c-b61c-f8fab9c1ac86',
  6
),
(
  '04e20324-5763-4f48-9a1d-247cb1a73074',
  '4f68b92f-e276-4630-a250-9c6c1cf1e6f8',
  '3ff6b5ca-39fe-444d-8332-b52ce6dcb77d',
  3,
  '533f554b-c14f-4c4c-b61c-f8fab9c1ac86',
  7
),
(
  '05337126-f399-4461-a265-b8fe927cb247',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  '3830f71b-70ae-4113-a11f-8f5d22092e54',
  1,
  'c1b8ea0b-512d-46ac-b9fe-8a0c40dcea2a',
  8
),
(
  '05a09c1d-adfd-4508-9f6e-de2214589d2b',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  '4f6d1aa2-d59b-407a-aa4b-f859443e6d25',
  3,
  'fcc9a388-7489-4348-a707-3e8357065607',
  9
),
(
  '05ce3439-d7cf-47a0-87b5-425d45e5eb2e',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  '854f81ba-baf0-4548-a056-f0e1eacd366a',
  1,
  '0d17802f-64cb-43d7-b801-c3d8b566da40',
  10
),
(
  '0674ed2c-5e9b-4e4c-b83e-7c71b62d8b7a',
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  '0fb7cef2-63e6-4d7b-a22a-4bf684a3a195',
  3,
  '5ba8fb1a-5342-4e59-b819-6b101c8ad3a9',
  1
),
(
  '069de18d-9c12-4d98-a56f-5aede5f99d1a',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  '63af4b6a-430d-473b-9076-69202388ef9c',
  1,
  '0f5f25a2-d54d-48fc-abfd-067fad2df7ff',
  2
),
(
  '06d26549-0a35-49a5-9fa0-044861ff5012',
  '4e72a59c-7f70-498a-9b1e-bf1fdc8ca57a',
  '86f6cb83-ba69-4059-9025-2b3f500ebf81',
  1,
  '1a13fa30-752c-44d6-9ad1-64b3898bd2a6',
  3
),
(
  '0720e657-a681-4cd1-aa3f-55ffa0da0d9f',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  '3fac041a-7fa3-4e7e-ae44-bfb533bcc090',
  1,
  'c1b8ea0b-512d-46ac-b9fe-8a0c40dcea2a',
  4
),
(
  '073c3e52-655e-4116-ba71-b05079f2599e',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  '3306d56e-e5d6-4c7d-a7f0-1a39e1c5ab95',
  1,
  '85cb4dbb-77e4-474d-90ad-5eeb69b04e48',
  5
),
(
  '0891c2f4-0968-498e-b650-bd5e6278d229',
  '1d656a24-a6d3-4e9d-a6ce-293e1f039e85',
  '65097808-5af0-4b45-b901-60b432335e3e',
  1,
  'ed8918ea-be0e-4d21-b90a-27074f4192e9',
  6
)
ON CONFLICT (id) DO NOTHING;

-- ==============================================================================
-- 13. POPULATE MATCH ANSWERS (Validated FK Rows)
-- ==============================================================================
INSERT INTO match_answers (id, match_id, player_id, round, question_id, selected_option, is_correct, points_earned, response_time_ms, answered_at)
VALUES
(
  '00b3a2fa-0f56-427b-80f9-1568f5d1a95f',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  '3306d56e-e5d6-4c7d-a7f0-1a39e1c5ab95',
  3,
  'fcc9a388-7489-4348-a707-3e8357065607',
  'AI Code Assistant',
  true,
  136,
  2716,
  '2026-09-16T21:21:48.257Z'
),
(
  '00cdfa24-e520-440b-8925-0a582997e6f3',
  '8203b2f9-5954-4281-ac8a-c3a4014c0314',
  '90e34ae7-f6ff-4eff-a004-9d1cce0c653b',
  1,
  '040bc733-e444-4d95-9a90-d44a953cf55c',
  'real',
  false,
  0,
  7944,
  '2026-09-16T21:21:48.257Z'
),
(
  '0109bfee-48aa-48c1-9b8a-2f3e954e16a9',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  '2c9311f2-a0c0-4384-931c-c75df00a3256',
  3,
  '791d445f-3889-4c28-8209-a471b2d254a6',
  'Multi-Agent System',
  true,
  133,
  3350,
  '2026-09-16T21:21:48.257Z'
),
(
  '012102b7-00ca-4003-832e-bb346d38d13f',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '2e431faf-f302-4d93-a698-a10170dfbcc7',
  3,
  '6ceb370b-0a49-429b-bd13-bc61b51acf12',
  'AI Music Generator',
  true,
  123,
  5311,
  '2026-09-16T21:21:48.257Z'
),
(
  '012810d4-f866-4701-981e-10d33cb96c7b',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '6ce386b0-8111-4fd0-8cca-7f246e32f801',
  1,
  '926918a8-aa91-45c5-a226-203c87dfd4c4',
  'ai',
  true,
  122,
  5554,
  '2026-09-16T21:21:48.257Z'
),
(
  '01a18cae-d921-45f4-919e-7edef25600c0',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  '3fb948bb-52a1-4303-a014-238fbf16d523',
  1,
  '85cb4dbb-77e4-474d-90ad-5eeb69b04e48',
  'real',
  false,
  0,
  2875,
  '2026-09-16T21:21:48.257Z'
),
(
  '02562e69-9e1f-4e19-a060-ac8672907d4d',
  '00d28983-7122-4446-8521-20d968b095c2',
  '37887cf6-42e1-460a-9c6a-638282068b6f',
  1,
  'ed8918ea-be0e-4d21-b90a-27074f4192e9',
  'real',
  false,
  0,
  1663,
  '2026-09-16T21:21:48.257Z'
),
(
  '029b69c3-6fb1-4aea-b3c2-7c8921d1df55',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  '53eb4d14-758e-4c9e-85f7-10e652dee8b4',
  1,
  'ed8918ea-be0e-4d21-b90a-27074f4192e9',
  'ai',
  true,
  117,
  6547,
  '2026-09-16T21:21:48.257Z'
),
(
  '029e0164-1055-4e09-b558-669cf8714060',
  '9d097fb9-b5a4-49ea-9ac1-54fd1e169179',
  '3306d56e-e5d6-4c7d-a7f0-1a39e1c5ab95',
  1,
  'c3eaade7-c12a-40bb-8f90-67a74480702c',
  'ai',
  true,
  139,
  2151,
  '2026-09-16T21:21:48.257Z'
),
(
  '02c58885-f263-4c01-8003-5c3dae714de5',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '61382c64-6aff-4f8b-9c34-588b19bb3ee2',
  3,
  '17d07c46-832b-4fed-8d14-5c6ff33381cb',
  'Movie Sci-Fi',
  false,
  0,
  4730,
  '2026-09-16T21:21:48.257Z'
),
(
  '037245ea-8153-4f55-ad56-1e6e624ffef6',
  'e73ffce7-e431-4e8a-9865-6b786403be63',
  '2ff1728f-d092-4401-a3e0-d302a5e84da5',
  3,
  'd45edb8b-d191-4fe8-b1f8-e07733a57928',
  'AI Copywriter',
  true,
  128,
  4401,
  '2026-09-16T21:21:48.257Z'
),
(
  '03917d62-7c92-45fc-ac07-e10bfb66fa68',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '9e73b632-2e07-4b8a-b42f-37d373250efd',
  1,
  '3bba083c-ae4f-405b-8732-d904bae2f299',
  'ai',
  true,
  139,
  2243,
  '2026-09-16T21:21:48.257Z'
),
(
  '039edc1d-5444-4f27-af72-1631a63c21a8',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '6202ad9f-7b8a-416e-9c73-b82b2fa9298d',
  1,
  '0463a4a2-50f0-482f-971a-22e359942d64',
  'ai',
  true,
  139,
  2266,
  '2026-09-16T21:21:48.257Z'
),
(
  '03d470de-6c91-411a-a275-86aebf860bdd',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  '3fb948bb-52a1-4303-a014-238fbf16d523',
  1,
  'c3eaade7-c12a-40bb-8f90-67a74480702c',
  'ai',
  true,
  142,
  1540,
  '2026-09-16T21:21:48.257Z'
),
(
  '045e61a0-d942-4e4a-8928-7a0a76d10ee9',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  '66b077b0-39a9-4e2f-a763-fd3af7b7704c',
  1,
  '07d42e9c-d78c-4b1a-8f81-ba479bb64edd',
  'ai',
  true,
  113,
  7312,
  '2026-09-16T21:21:48.257Z'
),
(
  '048a7f88-1c8d-444e-a54a-3f5e9b7dd5a1',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '6c803b0a-d4f5-4e6d-a083-5ee08c7d6bad',
  3,
  '17d07c46-832b-4fed-8d14-5c6ff33381cb',
  'AI Video Generation',
  true,
  127,
  4658,
  '2026-09-16T21:21:48.257Z'
),
(
  '04a2ada0-66e6-4971-b7a9-086a6f65b9c9',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  '3fb948bb-52a1-4303-a014-238fbf16d523',
  1,
  'ed8918ea-be0e-4d21-b90a-27074f4192e9',
  'ai',
  true,
  138,
  2362,
  '2026-09-16T21:21:48.257Z'
),
(
  '04de496e-654f-47f9-8324-4f3fb297a93c',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '37be48f3-546e-4ffb-803f-653088727118',
  3,
  '77e5cd8c-4eba-4b69-9d9d-f048cb9179cc',
  'Chatbot',
  true,
  143,
  1462,
  '2026-09-16T21:21:48.257Z'
),
(
  '056dfcd3-e150-427c-9a1b-6b8492ee98b9',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  '4f6d1aa2-d59b-407a-aa4b-f859443e6d25',
  3,
  '491bd851-637b-4861-ac7c-7ee9074f3a26',
  'Neural Network',
  true,
  134,
  3208,
  '2026-09-16T21:21:48.257Z'
),
(
  '059c4115-3c4a-4763-b5b8-45ef690783e5',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  '8e9a892b-7b12-4f34-8d89-fde7112dcd1a',
  1,
  'c3eaade7-c12a-40bb-8f90-67a74480702c',
  'ai',
  true,
  143,
  1454,
  '2026-09-16T21:21:48.257Z'
),
(
  '05e99eb6-343c-4979-ae47-165c245eb773',
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  '8e1d2076-a8b9-4f4e-9924-59e7ddfbf9f9',
  3,
  '791d445f-3889-4c28-8209-a471b2d254a6',
  'Multi-Agent System',
  true,
  137,
  2699,
  '2026-09-16T21:21:48.257Z'
),
(
  '063a586d-a75f-4948-b3e8-d03b72ee83b4',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  '3fb948bb-52a1-4303-a014-238fbf16d523',
  3,
  '979f7aee-460a-4876-ad4f-e86bab5ddcae',
  'Smart Medicine',
  false,
  0,
  3959,
  '2026-09-16T21:21:48.257Z'
),
(
  '066bcf35-ab33-45d1-a36a-761ed6ca317a',
  '144cd33d-4b84-4fab-9d50-e39ca3e1821d',
  '225fd83a-3774-4351-8528-4e4da935134e',
  1,
  'c3eaade7-c12a-40bb-8f90-67a74480702c',
  'ai',
  true,
  139,
  2104,
  '2026-09-16T21:21:48.257Z'
),
(
  '0690aa1b-7ba2-4614-8612-fb1d9506f096',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  '3b74d600-e6c2-48fa-a152-681f713825cb',
  3,
  '17d07c46-832b-4fed-8d14-5c6ff33381cb',
  'AI Video Generation',
  true,
  117,
  6653,
  '2026-09-16T21:21:48.257Z'
),
(
  '06c0ac05-f981-4404-b7c7-e8128e038f7a',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  '2e9b0586-40a1-4f5f-8480-8249b5ae2e2a',
  1,
  'c91b3106-5017-499d-bb2c-1070ec5d033d',
  'ai',
  true,
  129,
  4226,
  '2026-09-16T21:21:48.257Z'
),
(
  '06d5755d-738c-45ca-9524-581ce9e65967',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  '6b62e577-fb26-4f23-b7ed-762f3c5e0d68',
  3,
  '791d445f-3889-4c28-8209-a471b2d254a6',
  'Multi-Agent System',
  true,
  121,
  5833,
  '2026-09-16T21:21:48.257Z'
),
(
  '071580b8-7ec4-4862-a27d-557f95f84623',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '6c803b0a-d4f5-4e6d-a083-5ee08c7d6bad',
  1,
  '0463a4a2-50f0-482f-971a-22e359942d64',
  'ai',
  true,
  144,
  1233,
  '2026-09-16T21:21:48.257Z'
),
(
  '07b51f41-70e8-4a80-aff4-765bac47377c',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '2e431faf-f302-4d93-a698-a10170dfbcc7',
  1,
  'c91b3106-5017-499d-bb2c-1070ec5d033d',
  'ai',
  true,
  133,
  3367,
  '2026-09-16T21:21:48.257Z'
),
(
  '07cb9515-28a4-41d8-b2a2-5d142446fd65',
  'e73ffce7-e431-4e8a-9865-6b786403be63',
  '4957c8f1-3943-4749-8a87-2307b7478984',
  3,
  'd9f1ec25-b5cd-4395-884a-b106c310e7cb',
  'Autonomous Driving',
  true,
  104,
  9248,
  '2026-09-16T21:21:48.257Z'
),
(
  '08388877-8ccf-4520-9481-7fd635a8a901',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '61382c64-6aff-4f8b-9c34-588b19bb3ee2',
  1,
  '0463a4a2-50f0-482f-971a-22e359942d64',
  'real',
  false,
  0,
  4149,
  '2026-09-16T21:21:48.257Z'
),
(
  '09298340-c7b2-476f-ac15-269942e44f12',
  '8c94b08a-6f86-4e05-816f-78fe60450f4b',
  '2e9b0586-40a1-4f5f-8480-8249b5ae2e2a',
  1,
  '85a0a9ff-0c61-4289-8dbb-e585861cabbf',
  'ai',
  true,
  113,
  7429,
  '2026-09-16T21:21:48.257Z'
),
(
  '09726ba1-d0e1-41ad-836c-d458d8a7955b',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '1777f439-c252-418f-9a87-772e9adcea94',
  3,
  '333be725-ce08-4f8a-ac8d-ef8e16a09409',
  'Jigsaw Puzzle',
  false,
  0,
  1381,
  '2026-09-16T21:21:48.257Z'
),
(
  '09db4052-e22b-4ee1-9e33-89803ee363ac',
  'e73ffce7-e431-4e8a-9865-6b786403be63',
  '704895b2-b1d8-42e2-aa15-6ec66bc6680d',
  3,
  'b74cca07-f5e9-48a7-81e2-6f7971a4d6a2',
  'AI Safety & Alignment',
  true,
  116,
  6788,
  '2026-09-16T21:21:48.257Z'
),
(
  '0a3d5fd2-1dab-4a2e-b62e-9345a9e4db35',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '6ce386b0-8111-4fd0-8cca-7f246e32f801',
  1,
  '3bba083c-ae4f-405b-8732-d904bae2f299',
  'ai',
  true,
  141,
  1838,
  '2026-09-16T21:21:48.257Z'
),
(
  '0b527690-930a-46e3-b90b-a225dfa948bb',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '8d517b7c-a588-4286-8a35-10dec02717b0',
  3,
  '6ceb370b-0a49-429b-bd13-bc61b51acf12',
  'AI Music Generator',
  true,
  127,
  4543,
  '2026-09-16T21:21:48.257Z'
),
(
  '0bc58cb8-85fe-418c-82df-66dd225d9822',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '61382c64-6aff-4f8b-9c34-588b19bb3ee2',
  3,
  '6ceb370b-0a49-429b-bd13-bc61b51acf12',
  'AI Music Generator',
  true,
  121,
  5720,
  '2026-09-16T21:21:48.257Z'
),
(
  '0ca92ac4-8200-43e0-b0b1-df32758e93db',
  '37fe6f52-f258-4eea-b8e6-3a8b4ae4f9a1',
  '94f5606d-9099-46a6-ad3d-7ca22fe09547',
  1,
  'c1b8ea0b-512d-46ac-b9fe-8a0c40dcea2a',
  'real',
  false,
  0,
  5854,
  '2026-09-16T21:21:48.257Z'
),
(
  '0cf9d215-d9f5-481b-8342-f7690bb5bb84',
  '264bc89b-c05e-418b-8581-e7ef030090b9',
  '7bfe5e68-6355-48d9-b6cc-68b0f5e81db5',
  1,
  '1a13fa30-752c-44d6-9ad1-64b3898bd2a6',
  'ai',
  true,
  133,
  3382,
  '2026-09-16T21:21:48.257Z'
),
(
  '0dbffc29-8f5a-488d-9282-e52ea4bbdad3',
  '1d656a24-a6d3-4e9d-a6ce-293e1f039e85',
  '505c323c-dcfe-437f-b307-3df2c6f02d9d',
  1,
  '9fff14db-911c-4ec5-abca-50f082cadfff',
  'ai',
  true,
  142,
  1689,
  '2026-09-16T21:21:48.257Z'
),
(
  '0dda1cb2-426b-4a07-ba79-ea1e8f82c891',
  'bc52c02f-c108-46d4-b4b3-5d895228e21a',
  '36cc7195-31e6-4ad5-8d9c-20f76988aeae',
  3,
  '6ceb370b-0a49-429b-bd13-bc61b51acf12',
  'AI Music Generator',
  true,
  132,
  3549,
  '2026-09-16T21:21:48.257Z'
)
ON CONFLICT (id) DO NOTHING;