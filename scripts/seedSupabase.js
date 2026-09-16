import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Read .env file manually
const envPath = path.resolve(__dirname, '../.env');
const envContent = fs.readFileSync(envPath, 'utf8');

const env = {};
envContent.split('\n').forEach((line) => {
  const clean = line.trim();
  if (clean && !clean.startsWith('#')) {
    const idx = clean.indexOf('=');
    if (idx !== -1) {
      const key = clean.substring(0, idx).trim();
      const val = clean.substring(idx + 1).trim();
      env[key] = val;
    }
  }
});

const supabaseUrl = env['VITE_SUPABASE_URL'];
const supabaseKey = env['VITE_SUPABASE_ANON_KEY'];

console.log('Target Supabase URL:', supabaseUrl);

if (!supabaseUrl || !supabaseKey) {
  console.error('Error: VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY missing in .env');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

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

async function seedAll() {
  const dataDir = path.resolve(__dirname, '../data');

  // 1. Seed Questions (Primary Requirement)
  console.log('--- 1. Seeding Questions ---');
  const qRows = parseCsv(fs.readFileSync(path.join(dataDir, 'questions_rows.csv'), 'utf8'));
  const formattedQ = qRows.map((r) => ({
    id: r.id,
    round: Number(r.round),
    question_type: r.question_type,
    prompt_text: r.prompt_text,
    real_image_url: r.real_image_url || null,
    ai_image_url: r.ai_image_url || null,
    logo_url: r.logo_url || null,
    options: r.options ? (typeof r.options === 'string' && r.options.startsWith('[') ? JSON.parse(r.options) : r.options) : null,
    correct_option: r.correct_option,
    explanation: r.explanation || null,
    is_active: r.is_active === 'true' || r.is_active === true,
    created_at: r.created_at || new Date().toISOString()
  }));
  const { error: qErr } = await supabase.from('questions').upsert(formattedQ, { onConflict: 'id' });
  if (qErr) console.error('❌ Questions error:', qErr.message);
  else console.log(`✅ Successfully seeded ${formattedQ.length} questions into questions table!`);

  // 2. Seed Matches
  console.log('--- 2. Seeding Matches ---');
  const mRows = parseCsv(fs.readFileSync(path.join(dataDir, 'matches_rows.csv'), 'utf8'));
  const formattedM = mRows.map((r) => ({
    id: r.id,
    room_code: r.room_code,
    host_id: r.host_id || 'host',
    status: r.status || 'lobby',
    current_round: r.current_round ? Number(r.current_round) : 0,
    round_started_at: r.round_started_at || null,
    round_duration_seconds: r.round_duration_seconds ? Number(r.round_duration_seconds) : 15,
    created_at: r.created_at || new Date().toISOString()
  }));
  const { error: mErr } = await supabase.from('matches').upsert(formattedM, { onConflict: 'id' });
  if (mErr) console.error('❌ Matches error:', mErr.message);
  else console.log(`✅ Successfully seeded ${formattedM.length} matches into matches table!`);

  const validMatchIds = new Set(formattedM.map((m) => m.id));

  // 3. Seed Match Players
  console.log('--- 3. Seeding Match Players ---');
  const pRows = parseCsv(fs.readFileSync(path.join(dataDir, 'match_players_rows.csv'), 'utf8'));
  const formattedP = pRows
    .filter((r) => validMatchIds.has(r.match_id))
    .map((r) => ({
      id: r.id,
      match_id: r.match_id,
      display_name: r.display_name,
      device_token: r.device_token,
      has_completed_session: r.has_completed_session === 'true' || r.has_completed_session === true,
      joined_at: r.joined_at || new Date().toISOString(),
      has_left: r.has_left === 'true' || r.has_left === true
    }));
  const { error: pErr } = await supabase.from('match_players').upsert(formattedP, { onConflict: 'id' });
  if (pErr) console.error('❌ Match players error:', pErr.message);
  else console.log(`✅ Successfully seeded ${formattedP.length} players into match_players table!`);

  const validPlayerIds = new Set(formattedP.map((p) => p.id));
  const validQuestionIds = new Set(formattedQ.map((q) => q.id));

  // 4. Seed Match Round Questions (valid foreign keys only)
  console.log('--- 4. Seeding Match Round Questions ---');
  const mrqRows = parseCsv(fs.readFileSync(path.join(dataDir, 'match_round_questions_rows.csv'), 'utf8'));
  const formattedMRQ = mrqRows
    .filter((r) => validMatchIds.has(r.match_id) && validPlayerIds.has(r.player_id) && validQuestionIds.has(r.question_id))
    .map((r, idx) => ({
      id: r.id,
      match_id: r.match_id,
      player_id: r.player_id,
      round: Number(r.round) || 1,
      question_id: r.question_id,
      position: Number(r.position) || (idx % 10) + 1
    }));
  if (formattedMRQ.length > 0) {
    const { error: mrqErr } = await supabase.from('match_round_questions').upsert(formattedMRQ, { onConflict: 'id' });
    if (mrqErr) console.error('❌ Match round questions error:', mrqErr.message);
    else console.log(`✅ Successfully seeded ${formattedMRQ.length} valid rows into match_round_questions table!`);
  }

  // 5. Seed Match Answers (valid foreign keys only)
  console.log('--- 5. Seeding Match Answers ---');
  const ansRows = parseCsv(fs.readFileSync(path.join(dataDir, 'match_answers_rows.csv'), 'utf8'));
  const formattedAns = ansRows
    .filter((r) => validMatchIds.has(r.match_id) && validPlayerIds.has(r.player_id) && validQuestionIds.has(r.question_id))
    .map((r) => ({
      id: r.id,
      match_id: r.match_id,
      player_id: r.player_id,
      round: Number(r.round) || 1,
      question_id: r.question_id,
      selected_option: r.selected_option || 'A',
      is_correct: r.is_correct === 'true' || r.is_correct === true,
      points_earned: Number(r.points_earned) || 0,
      response_time_ms: Number(r.response_time_ms) || 0,
      answered_at: r.answered_at || new Date().toISOString()
    }));
  if (formattedAns.length > 0) {
    const { error: ansErr } = await supabase.from('match_answers').upsert(formattedAns, { onConflict: 'id' });
    if (ansErr) console.error('❌ Match answers error:', ansErr.message);
    else console.log(`✅ Successfully seeded ${formattedAns.length} valid rows into match_answers table!`);
  }

  console.log('\n🎉 ALL TABLES SEEDED SUCCESSFULLY!');
}

seedAll().catch(console.error);
