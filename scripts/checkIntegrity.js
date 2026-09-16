import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

function parseCsv(content) {
  const lines = content.split('\n').filter((l) => l.trim().length > 0);
  if (lines.length === 0) return [];
  const header = lines[0].split(',').map((h) => h.trim().replace(/^"|"$/g, ''));
  const rows = [];
  for (let i = 1; i < lines.length; i++) {
    const values = lines[i].split(',').map((v) => v.trim().replace(/^"|"$/g, ''));
    const row = {};
    header.forEach((h, idx) => {
      row[h] = values[idx];
    });
    rows.push(row);
  }
  return rows;
}

const dataDir = path.resolve(__dirname, '../data');
const questions = parseCsv(fs.readFileSync(path.join(dataDir, 'questions_rows.csv'), 'utf8'));
const matches = parseCsv(fs.readFileSync(path.join(dataDir, 'matches_rows.csv'), 'utf8'));
const matchPlayers = parseCsv(fs.readFileSync(path.join(dataDir, 'match_players_rows.csv'), 'utf8'));
const matchRoundQuestions = parseCsv(fs.readFileSync(path.join(dataDir, 'match_round_questions_rows.csv'), 'utf8'));
const matchAnswers = parseCsv(fs.readFileSync(path.join(dataDir, 'match_answers_rows.csv'), 'utf8'));

const questionIds = new Set(questions.map((q) => q.id));
const matchIds = new Set(matches.map((m) => m.id));
const playerIds = new Set(matchPlayers.map((p) => p.id));

console.log('Matches:', matches.length);
console.log('Players:', matchPlayers.length);
console.log('Round questions:', matchRoundQuestions.length);
console.log('Answers:', matchAnswers.length);

// Check match_players match_id
const missingPlayerMatches = matchPlayers.filter((p) => !matchIds.has(p.match_id));
console.log('match_players with missing match_id:', missingPlayerMatches.length);

// Check match_round_questions
const missingMRQMatches = matchRoundQuestions.filter((r) => !matchIds.has(r.match_id));
const missingMRQPlayers = matchRoundQuestions.filter((r) => !playerIds.has(r.player_id));
const missingMRQQuestions = matchRoundQuestions.filter((r) => !questionIds.has(r.question_id));
console.log('match_round_questions missing match_id:', missingMRQMatches.length);
console.log('match_round_questions missing player_id:', missingMRQPlayers.length);
console.log('match_round_questions missing question_id:', missingMRQQuestions.length);

// Check match_answers
const missingAnsMatches = matchAnswers.filter((a) => !matchIds.has(a.match_id));
const missingAnsPlayers = matchAnswers.filter((a) => !playerIds.has(a.player_id));
const missingAnsQuestions = matchAnswers.filter((a) => !questionIds.has(a.question_id));
console.log('match_answers missing match_id:', missingAnsMatches.length);
console.log('match_answers missing player_id:', missingAnsPlayers.length);
console.log('match_answers missing question_id:', missingAnsQuestions.length);
