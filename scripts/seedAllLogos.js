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

const allRound2Logos = [
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
    logo_url: '/images/round2/alexa.svg',
    prompt_text: 'Which Amazon voice AI service is represented by this logo?',
    options: ['Alexa', 'Siri', 'Cortana', 'Bixby'],
    correct_option: 'Alexa',
    explanation: 'Alexa is Amazon cloud-based voice AI assistant powering Echo and smart devices.'
  },
  {
    logo_url: '/images/round2/anthropic.svg',
    prompt_text: 'Which AI company is represented by this logo?',
    options: ['Anthropic', 'OpenAI', 'Cohere', 'Mistral AI'],
    correct_option: 'Anthropic',
    explanation: 'Anthropic is the AI safety and research company behind Claude.'
  },
  {
    logo_url: '/images/round2/apple-intelligence.svg',
    prompt_text: 'Which Apple AI brand is represented by this logo?',
    options: ['Apple Intelligence', 'Siri', 'Apple AI', 'iCloud'],
    correct_option: 'Apple Intelligence',
    explanation: "Apple Intelligence is Apple's personal intelligence system integrated across iOS, iPadOS, and macOS."
  },
  {
    logo_url: '/images/round2/apple.svg',
    prompt_text: 'Which global tech giant behind Apple Intelligence uses this logo?',
    options: ['Apple', 'Microsoft', 'Google', 'Meta'],
    correct_option: 'Apple',
    explanation: 'Apple is the creator of iOS, macOS, Siri, and Apple Intelligence.'
  },
  {
    logo_url: '/images/round2/azureai.svg',
    prompt_text: 'Which Microsoft AI cloud service is represented by this logo?',
    options: ['Azure AI', 'Microsoft Copilot', 'Azure DevOps', 'Power BI'],
    correct_option: 'Azure AI',
    explanation: "Azure AI is Microsoft's portfolio of AI and machine learning services on Azure cloud."
  },
  {
    logo_url: '/images/round2/chatgpt.svg',
    prompt_text: 'Which groundbreaking conversational AI platform is represented by this logo?',
    options: ['ChatGPT', 'Claude', 'Gemini', 'Perplexity'],
    correct_option: 'ChatGPT',
    explanation: 'ChatGPT is OpenAI conversational AI that kicked off the generative AI boom.'
  },
  {
    logo_url: '/images/round2/claude.svg',
    prompt_text: 'Which AI assistant is represented by this logo?',
    options: ['Claude', 'ChatGPT', 'Grok', 'Gemini'],
    correct_option: 'Claude',
    explanation: "Claude is Anthropic's AI assistant and frontier language model family."
  },
  {
    logo_url: '/images/round2/cline.svg',
    prompt_text: 'Which autonomous AI coding agent is represented by this logo?',
    options: ['Cline', 'Cursor', 'GitHub Copilot', 'Codex'],
    correct_option: 'Cline',
    explanation: 'Cline is an autonomous AI coding agent that can create/edit files and run commands in your IDE.'
  },
  {
    logo_url: '/images/round2/codex.svg',
    prompt_text: 'Which OpenAI code-generation AI model family is represented by this logo?',
    options: ['Codex', 'Cline', 'Claude', 'Copilot'],
    correct_option: 'Codex',
    explanation: "Codex is OpenAI's foundational code-generation AI system."
  },
  {
    logo_url: '/images/round2/copilot.svg',
    prompt_text: 'Which Microsoft AI assistant is represented by this ribbon logo?',
    options: ['Microsoft Copilot', 'Cortana', 'Azure AI', 'Bing Chat'],
    correct_option: 'Microsoft Copilot',
    explanation: 'Microsoft Copilot is the AI companion integrated across Microsoft 365, Windows, and Edge.'
  },
  {
    logo_url: '/images/round2/databricks.svg',
    prompt_text: 'Which data and AI platform is represented by this logo?',
    options: ['Databricks', 'Snowflake', 'Dataiku', 'Palantir'],
    correct_option: 'Databricks',
    explanation: 'Databricks provides a unified Data and AI platform powered by Apache Spark and lakehouse architecture.'
  },
  {
    logo_url: '/images/round2/deepseek.svg',
    prompt_text: 'Which AI company is represented by this logo?',
    options: ['DeepSeek', 'DeepMind', 'Mistral AI', 'Qwen'],
    correct_option: 'DeepSeek',
    explanation: 'DeepSeek is an AI research company renowned for its open-weight reasoning and coding models.'
  },
  {
    logo_url: '/images/round2/elevenlabs.svg',
    prompt_text: 'Which AI voice generation platform is represented by this logo?',
    options: ['ElevenLabs', 'Suno', 'HeyGen', 'Murf'],
    correct_option: 'ElevenLabs',
    explanation: 'ElevenLabs specializes in realistic AI voice cloning, text-to-speech, and audio synthesis.'
  },
  {
    logo_url: '/images/round2/figma.svg',
    prompt_text: 'Which collaborative design and AI prototyping tool uses this logo?',
    options: ['Figma', 'Canva', 'Sketch', 'Adobe XD'],
    correct_option: 'Figma',
    explanation: 'Figma is the leading collaborative interface design tool with generative AI features.'
  },
  {
    logo_url: '/images/round2/gemini.svg',
    prompt_text: 'Which Google flagship multimodal AI is represented by this star logo?',
    options: ['Gemini', 'Bard', 'PaLM', 'DeepMind'],
    correct_option: 'Gemini',
    explanation: "Gemini is Google's state-of-the-art multimodal AI model family."
  },
  {
    logo_url: '/images/round2/github-copilot.svg',
    prompt_text: 'Which AI pair programmer is represented by this logo?',
    options: ['GitHub Copilot', 'GitHub Actions', 'Codex', 'Cline'],
    correct_option: 'GitHub Copilot',
    explanation: 'GitHub Copilot is the AI pair programmer supporting millions of software developers.'
  },
  {
    logo_url: '/images/round2/grok-(xai).svg',
    prompt_text: 'Which AI assistant from xAI is represented by this logo?',
    options: ['Grok', 'Claude', 'Gemini', 'Perplexity'],
    correct_option: 'Grok',
    explanation: 'Grok is the AI assistant developed by Elon Musk’s xAI.'
  },
  {
    logo_url: '/images/round2/heygen.svg',
    prompt_text: 'Which AI video and avatar generation platform is represented by this logo?',
    options: ['HeyGen', 'Runway', 'Pika', 'Synthesia'],
    correct_option: 'HeyGen',
    explanation: 'HeyGen is an AI video generator specializing in photorealistic avatars and multilingual translation.'
  },
  {
    logo_url: '/images/round2/hugging-face.svg',
    prompt_text: 'Which open-source AI community platform is represented by this emoji logo?',
    options: ['Hugging Face', 'GitHub', 'LangChain', 'Replicate'],
    correct_option: 'Hugging Face',
    explanation: 'Hugging Face is the central hub for open-source AI models, datasets, and Spaces.'
  },
  {
    logo_url: '/images/round2/langchain.svg',
    prompt_text: 'Which framework for building LLM applications and agents is represented by this logo?',
    options: ['LangChain', 'LangGraph', 'LlamaIndex', 'TensorFlow'],
    correct_option: 'LangChain',
    explanation: 'LangChain is a popular open-source framework for building context-aware reasoning applications.'
  },
  {
    logo_url: '/images/round2/llama.svg',
    prompt_text: 'Which open-weight model family from Meta is represented by this logo?',
    options: ['Llama', 'Mistral', 'Falcon', 'Vicuna'],
    correct_option: 'Llama',
    explanation: 'Llama is Meta foundational open-weight AI model family.'
  },
  {
    logo_url: '/images/round2/lovable.svg',
    prompt_text: 'Which AI full-stack web app builder is represented by this logo?',
    options: ['Lovable', 'Bolt', 'Vercel', 'Replit'],
    correct_option: 'Lovable',
    explanation: 'Lovable is an AI-powered development tool that builds full-stack applications from prompts.'
  },
  {
    logo_url: '/images/round2/midjourney.svg',
    prompt_text: 'Which AI image-generation platform is represented by this sailboat logo?',
    options: ['Midjourney', 'DALL-E', 'Stable Diffusion', 'Adobe Firefly'],
    correct_option: 'Midjourney',
    explanation: 'Midjourney is an independent research lab creating popular text-to-image synthesis models.'
  },
  {
    logo_url: '/images/round2/mistral-ai.svg',
    prompt_text: 'Which European open-weight AI powerhouse is represented by this logo?',
    options: ['Mistral AI', 'Anthropic', 'Cohere', 'DeepSeek'],
    correct_option: 'Mistral AI',
    explanation: 'Mistral AI is a Paris-based company known for frontier open-weights models like Mixtral and Mistral Large.'
  },
  {
    logo_url: '/images/round2/notion-ai.svg',
    prompt_text: 'Which connected workspace with built-in AI assistant uses this logo?',
    options: ['Notion AI', 'Coda', 'Obsidian', 'Evernote'],
    correct_option: 'Notion AI',
    explanation: 'Notion AI enhances documents, wikis, and project management with automated writing and search.'
  },
  {
    logo_url: '/images/round2/nvidia.svg',
    prompt_text: 'Which technology company powers global AI hardware and GPUs with this green logo?',
    options: ['NVIDIA', 'AMD', 'Intel', 'Qualcomm'],
    correct_option: 'NVIDIA',
    explanation: 'NVIDIA is the world leader in AI acceleration GPUs, CUDA software, and AI supercomputing.'
  },
  {
    logo_url: '/images/round2/ollama.svg',
    prompt_text: 'Which tool allows running open LLMs locally on your computer with this llama logo?',
    options: ['Ollama', 'LM Studio', 'Jan', 'LocalAI'],
    correct_option: 'Ollama',
    explanation: 'Ollama enables running Llama, Mistral, and other open models locally on macOS, Windows, and Linux.'
  },
  {
    logo_url: '/images/round2/perplexity.svg',
    prompt_text: 'Which conversational AI search engine is represented by this logo?',
    options: ['Perplexity', 'You.com', 'Bing AI', 'Kagi'],
    correct_option: 'Perplexity',
    explanation: 'Perplexity AI is an AI search and answer engine that delivers real-time answers with source citations.'
  },
  {
    logo_url: '/images/round2/runway.svg',
    prompt_text: 'Which AI video research and creativity platform is represented by this logo?',
    options: ['Runway', 'Pika', 'Sora', 'Kaiber'],
    correct_option: 'Runway',
    explanation: 'Runway ML pioneered AI video generation tools including Gen-1, Gen-2, and Gen-3 Alpha.'
  },
  {
    logo_url: '/images/round2/siri.svg',
    prompt_text: 'Which Apple built-in voice assistant is represented by this colorful orb logo?',
    options: ['Siri', 'Alexa', 'Google Assistant', 'Bixby'],
    correct_option: 'Siri',
    explanation: 'Siri is Apple intelligent voice assistant integrated into Apple devices.'
  },
  {
    logo_url: '/images/round2/sora.svg',
    prompt_text: 'Which OpenAI photorealistic text-to-video model is represented by this logo?',
    options: ['Sora', 'Runway', 'Luma', 'Kling'],
    correct_option: 'Sora',
    explanation: 'Sora is OpenAI diffusion model capable of generating high-definition video from text instructions.'
  },
  {
    logo_url: '/images/round2/stability.svg',
    prompt_text: 'Which open-source AI company created Stable Diffusion with this logo?',
    options: ['Stability AI', 'Midjourney', 'OpenAI', 'Flux'],
    correct_option: 'Stability AI',
    explanation: 'Stability AI is the creator of the groundbreaking open-source Stable Diffusion image and audio models.'
  },
  {
    logo_url: '/images/round2/suno.svg',
    prompt_text: 'Which viral AI song and music generator is represented by this logo?',
    options: ['Suno', 'Udio', 'AIVA', 'Boomy'],
    correct_option: 'Suno',
    explanation: 'Suno AI generates full broadcast-quality songs with vocals, lyrics, and instruments from text prompts.'
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

  // Generate formatted Round 2 questions for all 35 logos
  const newRound2 = allRound2Logos.map((q) => ({
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
  console.log(`✅ Updated ${csvPath} with ${newRound2.length} Round 2 Logo questions (Total Questions: ${allUpdated.length})`);

  // Delete old Round 2 questions in Supabase and push all new Round 2 questions
  console.log(`Pushing ${newRound2.length} Round 2 Logo questions to Supabase...`);
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
    console.log(`✅ Successfully pushed all ${newRound2.length} Round 2 Logo questions to Supabase!`);
  }
}

run().catch(console.error);
