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

const newRound2Raw = [
  {
    logo_url: '/images/round2/adobe-express.svg',
    prompt_text: 'Which AI design tool is represented by this logo?',
    options: ['Adobe Express', 'Adobe Firefly', 'Canva', 'Figma'],
    correct_option: 'Adobe Express',
    explanation: "Adobe Express is Adobe's creative design platform for quickly creating and editing visual content."
  },
  {
    logo_url: '/images/round2/adobe-firefly.svg',
    prompt_text: 'Which Adobe generative AI platform is represented by this logo?',
    options: ['Adobe Firefly', 'Adobe Express', 'Midjourney', 'DALL-E'],
    correct_option: 'Adobe Firefly',
    explanation: "Adobe Firefly is Adobe's generative AI family for creating and editing images and creative content."
  },
  {
    logo_url: '/images/round2/anthropic.svg',
    prompt_text: 'Which AI company is represented by this logo?',
    options: ['Anthropic', 'OpenAI', 'Cohere', 'Mistral AI'],
    correct_option: 'Anthropic',
    explanation: 'Anthropic is the AI company behind Claude.'
  },
  {
    logo_url: '/images/round2/apple-intelligence.svg',
    prompt_text: 'Which Apple AI brand is represented by this logo?',
    options: ['Apple Intelligence', 'Siri', 'Apple AI', 'iCloud'],
    correct_option: 'Apple Intelligence',
    explanation: "Apple Intelligence is Apple's AI system integrated into supported Apple devices and software."
  },
  {
    logo_url: '/images/round2/azureai.svg',
    prompt_text: 'Which Microsoft AI service is represented by this logo?',
    options: ['Azure AI', 'Microsoft Copilot', 'Azure DevOps', 'Power BI'],
    correct_option: 'Azure AI',
    explanation: "Azure AI is Microsoft's collection of cloud AI services and tools on Azure."
  },
  {
    logo_url: '/images/round2/claude.svg',
    prompt_text: 'Which AI assistant is represented by this logo?',
    options: ['Claude', 'ChatGPT', 'Grok', 'Gemini'],
    correct_option: 'Claude',
    explanation: "Claude is Anthropic's AI assistant and language model family."
  },
  {
    logo_url: '/images/round2/cline.svg',
    prompt_text: 'Which AI coding tool is represented by this logo?',
    options: ['Cline', 'Cursor', 'GitHub Copilot', 'Codex'],
    correct_option: 'Cline',
    explanation: 'Cline is an AI coding agent designed to work with developers inside a coding environment.'
  },
  {
    logo_url: '/images/round2/codex.svg',
    prompt_text: 'Which AI coding model or tool is represented by this logo?',
    options: ['Codex', 'Cline', 'Claude', 'Copilot'],
    correct_option: 'Codex',
    explanation: "Codex refers to OpenAI's code-focused AI technology and coding agents."
  },
  {
    logo_url: '/images/round2/databricks.svg',
    prompt_text: 'Which data and AI platform is represented by this logo?',
    options: ['Databricks', 'Snowflake', 'Dataiku', 'Palantir'],
    correct_option: 'Databricks',
    explanation: 'Databricks provides a data and AI platform used for analytics, machine learning, and AI workloads.'
  },
  {
    logo_url: '/images/round2/deepseek.svg',
    prompt_text: 'Which AI company is represented by this logo?',
    options: ['DeepSeek', 'DeepMind', 'Mistral AI', 'Qwen'],
    correct_option: 'DeepSeek',
    explanation: 'DeepSeek is an AI company known for its large language models and AI research.'
  },
  {
    logo_url: '/images/round2/elevenlabs.svg',
    prompt_text: 'Which AI voice generation platform is represented by this logo?',
    options: ['ElevenLabs', 'Suno', 'HeyGen', 'Murf'],
    correct_option: 'ElevenLabs',
    explanation: 'ElevenLabs specializes in AI voice generation, speech synthesis, and voice cloning technology.'
  },
  {
    logo_url: '/images/round2/github-copilot.svg',
    prompt_text: 'Which AI coding assistant brand is represented by this logo?',
    options: ['GitHub Copilot', 'GitHub Actions', 'Codex', 'Cline'],
    correct_option: 'GitHub Copilot',
    explanation: 'GitHub Copilot is an AI-powered coding assistant integrated into developer workflows.'
  },
  {
    logo_url: '/images/round2/grok-(xai).svg',
    prompt_text: 'Which AI assistant from xAI is represented by this logo?',
    options: ['Grok', 'Claude', 'Gemini', 'Perplexity'],
    correct_option: 'Grok',
    explanation: 'Grok is the AI assistant developed by xAI.'
  },
  {
    logo_url: '/images/round2/heygen.svg',
    prompt_text: 'Which AI video generation platform is represented by this logo?',
    options: ['HeyGen', 'Runway', 'Pika', 'Synthesia'],
    correct_option: 'HeyGen',
    explanation: 'HeyGen is an AI video platform used for avatar-based and generative video creation.'
  },
  {
    logo_url: '/images/round2/hugging-face.svg',
    prompt_text: 'Which open-source AI community platform is represented by this logo?',
    options: ['Hugging Face', 'GitHub', 'LangChain', 'Replicate'],
    correct_option: 'Hugging Face',
    explanation: 'Hugging Face hosts AI models, datasets, and machine learning tools used by the AI community.'
  },
  {
    logo_url: '/images/round2/langchain.svg',
    prompt_text: 'Which framework for building applications with language models is represented by this logo?',
    options: ['LangChain', 'LangGraph', 'LlamaIndex', 'TensorFlow'],
    correct_option: 'LangChain',
    explanation: 'LangChain is a framework for building applications and workflows around language models.'
  },
  {
    logo_url: '/images/round2/lovable.svg',
    prompt_text: 'Which AI app-building platform is represented by this logo?',
    options: ['Lovable', 'Bolt', 'Vercel', 'Replit'],
    correct_option: 'Lovable',
    explanation: 'Lovable is an AI-powered platform for building applications through natural-language interaction.'
  },
  {
    logo_url: '/images/round2/midjourney.svg',
    prompt_text: 'Which AI image-generation platform is represented by this logo?',
    options: ['Midjourney', 'DALL-E', 'Stable Diffusion', 'Adobe Firefly'],
    correct_option: 'Midjourney',
    explanation: 'Midjourney is a generative AI platform focused on creating images from text prompts.'
  },
  {
    logo_url: '/images/round2/mistral-ai.svg',
    prompt_text: 'Which AI company is represented by this logo?',
    options: ['Mistral AI', 'Anthropic', 'Cohere', 'DeepSeek'],
    correct_option: 'Mistral AI',
    explanation: 'Mistral AI develops open and commercial large language models and AI systems.'
  },
  {
    logo_url: '/images/round2/nvidia.svg',
    prompt_text: 'Which technology company is represented by this logo and is known for AI chips and GPUs?',
    options: ['NVIDIA', 'AMD', 'Intel', 'Qualcomm'],
    correct_option: 'NVIDIA',
    explanation: 'NVIDIA is a technology company widely known for GPUs and computing hardware used extensively in AI workloads.'
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

  // Keep Round 1 and Round 3 questions
  const nonRound2 = existingQuestions.filter((q) => Number(q.round) !== 2);

  // Generate formatted Round 2 questions
  const newRound2 = newRound2Raw.map((q) => ({
    id: deterministicUUID(`round2_${q.logo_url}`),
    round: 2,
    question_type: 'logo_mcq',
    prompt_text: q.prompt_text,
    real_image_url: '',
    ai_image_url: '',
    logo_url: q.logo_url,
    options: JSON.stringify(q.options),
    correct_option: q.correct_option,
    explanation: q.explanation,
    is_active: 'true',
    created_at: new Date().toISOString()
  }));

  const allUpdated = [...nonRound2, ...newRound2];
  allUpdated.sort((a, b) => Number(a.round) - Number(b.round));

  // Write back to questions_rows.csv
  const header = 'id,round,question_type,prompt_text,real_image_url,ai_image_url,logo_url,options,correct_option,explanation,is_active,created_at';
  const csvLines = [header];
  allUpdated.forEach((q) => {
    const row = [
      q.id,
      q.round,
      q.question_type,
      `"${q.prompt_text.replace(/"/g, '""')}"`,
      q.real_image_url || '',
      q.ai_image_url || '',
      q.logo_url || '',
      `"${(typeof q.options === 'string' ? q.options : JSON.stringify(q.options)).replace(/"/g, '""')}"`,
      `"${q.correct_option.replace(/"/g, '""')}"`,
      `"${q.explanation.replace(/"/g, '""')}"`,
      q.is_active,
      q.created_at
    ];
    csvLines.push(row.join(','));
  });

  fs.writeFileSync(csvPath, csvLines.join('\n'), 'utf8');
  console.log(`✅ Updated ${csvPath} with 20 new Round 2 questions (Total: ${allUpdated.length} questions)`);

  // Delete old Round 2 questions in Supabase and push new Round 2 questions
  console.log('Pushing updated Round 2 questions to Supabase...');
  await supabase.from('questions').delete().eq('round', 2);

  const payload = newRound2.map((q) => ({
    id: q.id,
    round: 2,
    question_type: 'logo_mcq',
    prompt_text: q.prompt_text,
    real_image_url: null,
    ai_image_url: null,
    logo_url: q.logo_url,
    options: JSON.parse(q.options),
    correct_option: q.correct_option,
    explanation: q.explanation,
    is_active: true,
    created_at: q.created_at
  }));

  const { error } = await supabase.from('questions').upsert(payload, { onConflict: 'id' });
  if (error) {
    console.error('❌ Supabase error:', error.message);
  } else {
    console.log('✅ Successfully pushed all 20 new Round 2 Logo questions to Supabase!');
  }
}

run().catch(console.error);
