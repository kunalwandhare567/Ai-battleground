import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { fileURLToPath } from 'url';
import { createClient } from '@supabase/supabase-js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Read .env file
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
const supabase = createClient(supabaseUrl, supabaseKey);

const newRound1Questions = [
  {
    prompt_text: 'Which snowman photo is AI-generated?',
    real_image_url: '/images/round1/q21_real.jpg',
    ai_image_url: '/images/round1/q21_ai.jpg',
    correct_option: 'ai',
    explanation: "The snowman's facial details, arms, and body proportions contain subtle AI-generated inconsistencies."
  },
  {
    prompt_text: 'Which colorful frog photo is AI-generated?',
    real_image_url: '/images/round1/q22_real.jpg',
    ai_image_url: '/images/round1/q22_ai.jpg',
    correct_option: 'ai',
    explanation: "The frog's skin pattern, eyes, and leg details show subtle AI-generation artifacts."
  },
  {
    prompt_text: 'Which Titanic ship photo is AI-generated?',
    real_image_url: '/images/round1/q23_real.jpg',
    ai_image_url: '/images/round1/q23_ai.jpg',
    correct_option: 'ai',
    explanation: "The ship's structure, deck details, and fine architectural elements contain generated inconsistencies."
  },
  {
    prompt_text: 'Which Mount Fuji photo is AI-generated?',
    real_image_url: '/images/round1/q24_real.jpg',
    ai_image_url: '/images/round1/q24_ai.jpg',
    correct_option: 'ai',
    explanation: 'The mountain shape, clouds, reflections, and lighting contain subtle AI-generated inconsistencies.'
  },
  {
    prompt_text: 'Which rocket launch photo is AI-generated?',
    real_image_url: '/images/round1/q25_real.jpg',
    ai_image_url: '/images/round1/q25_ai.jpg',
    correct_option: 'ai',
    explanation: 'The rocket, exhaust flame, and smoke shapes show subtle artificial blending.'
  },
  {
    prompt_text: 'Which city skyline photo is AI-generated?',
    real_image_url: '/images/round1/q26_real.jpg',
    ai_image_url: '/images/round1/q26_ai.jpg',
    correct_option: 'ai',
    explanation: 'The building shapes, windows, and lighting patterns contain subtle generated inconsistencies.'
  },
  {
    prompt_text: 'Which northern lights photo is AI-generated?',
    real_image_url: '/images/round1/q27_real.jpg',
    ai_image_url: '/images/round1/q27_ai.jpg',
    correct_option: 'ai',
    explanation: 'The aurora shapes, sky details, and reflections contain subtle AI-generated artifacts.'
  },
  {
    prompt_text: 'Which Statue of Liberty photo is AI-generated?',
    real_image_url: '/images/round1/q28_real.jpg',
    ai_image_url: '/images/round1/q28_ai.jpg',
    correct_option: 'ai',
    explanation: 'The statue proportions, surroundings, and background details contain subtle generated inconsistencies.'
  },
  {
    prompt_text: 'Which Egyptian pyramid photo is AI-generated?',
    real_image_url: '/images/round1/q29_real.jpg',
    ai_image_url: '/images/round1/q29_ai.jpg',
    correct_option: 'ai',
    explanation: 'The pyramid surface, perspective, lighting, and surrounding landscape show subtle AI artifacts.'
  },
  {
    prompt_text: 'Which ice cream cone photo is AI-generated?',
    real_image_url: '/images/round1/q30_real.jpg',
    ai_image_url: '/images/round1/q30_ai.jpg',
    correct_option: 'ai',
    explanation: 'The waffle pattern, cone edges, and texture contain subtle AI-generated irregularities.'
  },
  {
    prompt_text: 'Which dog photo is AI-generated?',
    real_image_url: '/images/round1/q31_real.jpg',
    ai_image_url: '/images/round1/q31_ai.jpg',
    correct_option: 'ai',
    explanation: "The dog's fur texture, facial details, and body edges contain subtle AI-generation artifacts."
  },
  {
    prompt_text: 'Which daisy flower photo is AI-generated?',
    real_image_url: '/images/round1/q32_real.jpg',
    ai_image_url: '/images/round1/q32_ai.jpg',
    correct_option: 'ai',
    explanation: 'The petal shapes, flower center, and fine textures show subtle generated inconsistencies.'
  },
  {
    prompt_text: 'Which Venice canal photo is AI-generated?',
    real_image_url: '/images/round1/q33_real.jpg',
    ai_image_url: '/images/round1/q33_ai.jpg',
    correct_option: 'ai',
    explanation: 'The buildings, canal details, gondola, and architectural elements contain subtle AI artifacts.'
  },
  {
    prompt_text: 'Which Italian lakeside photo is AI-generated?',
    real_image_url: '/images/round1/q34_real.jpg',
    ai_image_url: '/images/round1/q34_ai.jpg',
    correct_option: 'ai',
    explanation: 'The buildings, shoreline, mountain background, and lighting contain subtle generated inconsistencies.'
  },
  {
    prompt_text: 'Which iguana photo is AI-generated?',
    real_image_url: '/images/round1/q35_real.jpg',
    ai_image_url: '/images/round1/q35_ai.jpg',
    correct_option: 'ai',
    explanation: 'The scales, spikes, eye details, and body texture show subtle AI-generated artifacts.'
  },
  {
    prompt_text: 'Which sushi photo is AI-generated?',
    real_image_url: '/images/round1/q36_real.jpg',
    ai_image_url: '/images/round1/q36_ai.jpg',
    correct_option: 'ai',
    explanation: 'The sushi pieces, fish texture, rice details, and arrangement contain subtle generated inconsistencies.'
  }
];

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

function deterministicUUID(str) {
  const hash = crypto.createHash('sha256').update(str).digest('hex');
  return `${hash.substring(0, 8)}-${hash.substring(8, 12)}-4${hash.substring(13, 16)}-a${hash.substring(17, 20)}-${hash.substring(20, 32)}`;
}

async function run() {
  const dataDir = path.resolve(__dirname, '../data');
  const csvPath = path.join(dataDir, 'questions_rows.csv');
  const existingQuestions = parseCsv(fs.readFileSync(csvPath, 'utf8'));

  // Keep existing non-duplicate questions
  const existingR1Urls = new Set(existingQuestions.filter((q) => Number(q.round) === 1).map((q) => q.real_image_url));

  const newR1Formatted = [];
  newRound1Questions.forEach((q) => {
    if (!existingR1Urls.has(q.real_image_url)) {
      newR1Formatted.push({
        id: deterministicUUID(`round1_${q.real_image_url}`),
        round: 1,
        question_type: 'image_comparison',
        prompt_text: q.prompt_text,
        real_image_url: q.real_image_url,
        ai_image_url: q.ai_image_url,
        logo_url: '',
        options: '',
        correct_option: q.correct_option,
        explanation: q.explanation,
        is_active: 'true',
        created_at: new Date().toISOString()
      });
    }
  });

  const allQuestions = [...existingQuestions, ...newR1Formatted];
  allQuestions.sort((a, b) => Number(a.round) - Number(b.round));

  // Write back to questions_rows.csv
  const header = 'id,round,question_type,prompt_text,real_image_url,ai_image_url,logo_url,options,correct_option,explanation,is_active,created_at';
  const csvLines = [header];
  allQuestions.forEach((q) => {
    const row = [
      q.id,
      q.round,
      q.question_type,
      `"${q.prompt_text.replace(/"/g, '""')}"`,
      q.real_image_url || '',
      q.ai_image_url || '',
      q.logo_url || '',
      q.options ? `"${(typeof q.options === 'string' ? q.options : JSON.stringify(q.options)).replace(/"/g, '""')}"` : '',
      `"${q.correct_option.replace(/"/g, '""')}"`,
      `"${q.explanation.replace(/"/g, '""')}"`,
      q.is_active,
      q.created_at
    ];
    csvLines.push(row.join(','));
  });

  fs.writeFileSync(csvPath, csvLines.join('\n'), 'utf8');
  console.log(`✅ Updated ${csvPath} with ${newR1Formatted.length} new Round 1 questions (Total: ${allQuestions.length})`);

  // Push new Round 1 questions to Supabase
  const payload = newR1Formatted.map((q) => ({
    id: q.id,
    round: 1,
    question_type: 'image_comparison',
    prompt_text: q.prompt_text,
    real_image_url: q.real_image_url,
    ai_image_url: q.ai_image_url,
    logo_url: null,
    options: null,
    correct_option: q.correct_option,
    explanation: q.explanation,
    is_active: true,
    created_at: q.created_at
  }));

  console.log(`Pushing ${payload.length} new Round 1 questions to Supabase...`);
  const { error } = await supabase.from('questions').upsert(payload, { onConflict: 'id' });
  if (error) {
    console.error('❌ Supabase error:', error.message);
  } else {
    console.log(`✅ Successfully pushed all ${payload.length} new Round 1 questions to Supabase!`);
  }
}

run().catch(console.error);
