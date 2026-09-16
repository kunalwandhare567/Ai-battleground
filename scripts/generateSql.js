import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function parseCsv(content) {
  const lines = content.split('\n').filter((l) => l.trim().length > 0);
  if (lines.length === 0) return [];
  const header = parseCsvLine(lines[0]);
  const rows = [];
  for (let i = 1; i < lines.length; i++) {
    const values = parseCsvLine(lines[i]);
    if (values.length === header.length) {
      const row = {};
      header.forEach((h, idx) => {
        row[h] = values[idx];
      });
      rows.push(row);
    }
  }
  return rows;
}

function parseCsvLine(line) {
  const result = [];
  let cur = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    if (char === '"') {
      if (inQuotes && line[i + 1] === '"') {
        cur += '"';
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char === ',' && !inQuotes) {
      result.push(cur);
      cur = '';
    } else {
      cur += char;
    }
  }
  result.push(cur);
  return result;
}

function sqlVal(v) {
  if (v === undefined || v === null || v === '') return 'NULL';
  return `'${String(v).replace(/'/g, "''")}'`;
}

function sqlJson(v) {
  if (!v || v === '') return 'NULL';
  return `'${String(v).replace(/'/g, "''")}'::JSONB`;
}

// Read CSV files
const dataDir = path.resolve(__dirname, '../data');
const questionsRows = parseCsv(fs.readFileSync(path.join(dataDir, 'questions_rows.csv'), 'utf8'));
const matchesRows = parseCsv(fs.readFileSync(path.join(dataDir, 'matches_rows.csv'), 'utf8'));
const matchPlayersRows = parseCsv(fs.readFileSync(path.join(dataDir, 'match_players_rows.csv'), 'utf8'));
const matchRoundQuestionsRows = parseCsv(fs.readFileSync(path.join(dataDir, 'match_round_questions_rows.csv'), 'utf8'));
const matchAnswersRows = parseCsv(fs.readFileSync(path.join(dataDir, 'match_answers_rows.csv'), 'utf8'));

const validQuestionIds = new Set(questionsRows.map((q) => q.id));
const validMatchIds = new Set(matchesRows.map((m) => m.id));
const validPlayerRows = matchPlayersRows.filter((p) => validMatchIds.has(p.match_id));
const validPlayerIds = new Set(validPlayerRows.map((p) => p.id));

const validMRQ = matchRoundQuestionsRows.filter(
  (r) => validMatchIds.has(r.match_id) && validPlayerIds.has(r.player_id) && validQuestionIds.has(r.question_id)
);

const validAnswers = matchAnswersRows.filter(
  (r) => validMatchIds.has(r.match_id) && validPlayerIds.has(r.player_id) && validQuestionIds.has(r.question_id)
);

let sql = `-- ==============================================================================
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
` + questionsRows.map((r) => `(
  '${r.id}',
  ${r.round},
  ${sqlVal(r.question_type)},
  ${sqlVal(r.prompt_text)},
  ${sqlVal(r.real_image_url)},
  ${sqlVal(r.ai_image_url)},
  ${sqlVal(r.logo_url)},
  ${sqlJson(r.options)},
  ${sqlVal(r.correct_option)},
  ${sqlVal(r.explanation)},
  ${r.is_active === 'true' || r.is_active === true}
)`).join(',\n') + `
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
` + matchesRows.map((r) => `(
  '${r.id}',
  ${sqlVal(r.room_code)},
  ${sqlVal(r.host_id || 'host')},
  ${sqlVal(r.status || 'lobby')},
  ${r.current_round ? Number(r.current_round) : 0},
  ${sqlVal(r.round_started_at)},
  ${r.round_duration_seconds ? Number(r.round_duration_seconds) : 15},
  ${sqlVal(r.created_at || new Date().toISOString())}
)`).join(',\n') + `
ON CONFLICT (id) DO UPDATE SET
  room_code = EXCLUDED.room_code,
  status = EXCLUDED.status,
  current_round = EXCLUDED.current_round;

-- ==============================================================================
-- 11. POPULATE MATCH PLAYERS (data/match_players_rows.csv)
-- ==============================================================================
INSERT INTO match_players (id, match_id, display_name, device_token, has_completed_session, joined_at, has_left)
VALUES
` + validPlayerRows.map((r) => `(
  '${r.id}',
  '${r.match_id}',
  ${sqlVal(r.display_name)},
  ${sqlVal(r.device_token)},
  ${r.has_completed_session === 'true' || r.has_completed_session === true},
  ${sqlVal(r.joined_at || new Date().toISOString())},
  ${r.has_left === 'true' || r.has_left === true}
)`).join(',\n') + `
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  device_token = EXCLUDED.device_token,
  has_left = EXCLUDED.has_left;

-- ==============================================================================
-- 12. POPULATE MATCH ROUND QUESTIONS (Validated FK Rows)
-- ==============================================================================
` + (validMRQ.length > 0 ? `INSERT INTO match_round_questions (id, match_id, player_id, round, question_id, position)
VALUES
` + validMRQ.map((r, idx) => `(
  '${r.id}',
  '${r.match_id}',
  '${r.player_id}',
  ${Number(r.round) || 1},
  '${r.question_id}',
  ${Number(r.position) || (idx % 10) + 1}
)`).join(',\n') + `
ON CONFLICT (id) DO NOTHING;` : '-- No additional round questions') + `

-- ==============================================================================
-- 13. POPULATE MATCH ANSWERS (Validated FK Rows)
-- ==============================================================================
` + (validAnswers.length > 0 ? `INSERT INTO match_answers (id, match_id, player_id, round, question_id, selected_option, is_correct, points_earned, response_time_ms, answered_at)
VALUES
` + validAnswers.map((r) => `(
  '${r.id}',
  '${r.match_id}',
  '${r.player_id}',
  ${Number(r.round) || 1},
  '${r.question_id}',
  ${sqlVal(r.selected_option || 'A')},
  ${r.is_correct === 'true' || r.is_correct === true},
  ${Number(r.points_earned || 0)},
  ${Number(r.response_time_ms || 0)},
  ${sqlVal(r.answered_at || new Date().toISOString())}
)`).join(',\n') + `
ON CONFLICT (id) DO NOTHING;` : '-- No additional match answers');

const outputPath = path.resolve(__dirname, '../supabase_setup.sql');
fs.writeFileSync(outputPath, sql, 'utf8');
console.log('✅ Generated validated supabase_setup.sql successfully!');
