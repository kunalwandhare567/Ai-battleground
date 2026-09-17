import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Read .env
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

if (!supabaseUrl || !supabaseKey) {
  console.error('Error: VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY missing in .env');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

const newQuestions = [
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🧠🏗️',
    options: ["Deep Learning","Brain Builder","Smart Architecture","Neural Storage"],
    correct_option: 'Deep Learning',
    explanation: 'Brain + Construction = Deep Learning, where layered neural networks learn complex patterns.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🧠📖🤖',
    options: ["Large Language Model","AI Dictionary","Digital Library","Smart Reader"],
    correct_option: 'Large Language Model',
    explanation: 'Brain + Book + Robot = Large Language Model, trained on vast amounts of text.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '⚙️🤖✨',
    options: ["Generative AI","AI Automation","Robot Factory","Creative Machine"],
    correct_option: 'Generative AI',
    explanation: 'Machine + Robot + Sparkles = Generative AI, which creates new content such as text, images, audio, and video.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🔤✂️🤖',
    options: ["Tokenization","Text Editing","Word Processor","Code Parsing"],
    correct_option: 'Tokenization',
    explanation: 'Letters + Cutting + Robot = Tokenization, breaking text into smaller pieces called tokens.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🔗🧠',
    options: ["Embeddings","Brain Link","Semantic Search","Data Connection"],
    correct_option: 'Embeddings',
    explanation: 'Connected symbols + Brain = Embeddings, representing words or data as numerical vectors.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🗄️🔢🧠',
    options: ["Vector Database","Number Storage","AI Database","Cloud Storage"],
    correct_option: 'Vector Database',
    explanation: 'Storage + Numbers + Brain = Vector Database, designed to store and search vector representations.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🧠🔄⚡',
    options: ["Transformer Model","Power Transformer","Model Switching","Neural Circuit"],
    correct_option: 'Transformer Model',
    explanation: 'Brain + Transformation + Energy = Transformer Model, a neural architecture widely used in modern AI.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '👥🤖🎨',
    options: ["Generative Adversarial Network","AI Art Team","Robot Competition","Creative Network"],
    correct_option: 'Generative Adversarial Network',
    explanation: 'Two AI sides + Robot + Art = Generative Adversarial Network, where competing networks generate and evaluate content.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🌫️🖼️🤖',
    options: ["Diffusion Model","Image Blur","Cloud Rendering","Visual Noise"],
    correct_option: 'Diffusion Model',
    explanation: 'Cloud + Image + Robot = Diffusion Model, a popular approach for generating images from noise.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🎯❓🤖',
    options: ["Zero-Shot Learning","Random Guessing","Target Training","AI Testing"],
    correct_option: 'Zero-Shot Learning',
    explanation: 'Target + Question + Robot = Zero-Shot Learning, where an AI performs a task without task-specific examples.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🎯👥🤖',
    options: ["Few-Shot Learning","Small Dataset","Limited Training","Mini Model"],
    correct_option: 'Few-Shot Learning',
    explanation: 'Target + Small Group + Robot = Few-Shot Learning, where a model learns from only a few examples.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🖼️🎵📝🤖',
    options: ["Multimodal AI","Media Player AI","Content Mixer","Digital Media"],
    correct_option: 'Multimodal AI',
    explanation: 'Image + Music + Text + Robot = Multimodal AI, which can work with multiple types of data.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '⚖️🤖',
    options: ["AI Bias","AI Fairness","Algorithm Scale","Model Balance"],
    correct_option: 'AI Bias',
    explanation: 'Balance scale + Robot = AI Bias, referring to systematic unfairness or skewed outcomes in AI systems.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🛡️⚖️🤖',
    options: ["AI Ethics","Cybersecurity","Digital Law","AI Governance"],
    correct_option: 'AI Ethics',
    explanation: 'Shield + Balance + Robot = AI Ethics, concerning responsible and fair development and use of AI.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🔍🧠💡',
    options: ["Explainable AI","AI Search","Transparent Model","Smart Diagnosis"],
    correct_option: 'Explainable AI',
    explanation: 'Magnifying Glass + Brain + Lightbulb = Explainable AI, focused on making AI decisions easier to understand.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '📱🤖⚡',
    options: ["Edge AI","Mobile AI","Fast Computing","Device Learning"],
    correct_option: 'Edge AI',
    explanation: 'Mobile device + Robot + Lightning = Edge AI, running AI processing closer to where data is generated.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🤝📱🌐🤖',
    options: ["Federated Learning","Social AI","Distributed Chatbot","Network Training"],
    correct_option: 'Federated Learning',
    explanation: 'Connected devices + Globe + Robot = Federated Learning, where models learn across devices without centralizing raw data.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '📦📊🤖',
    options: ["Synthetic Data","Data Packaging","Artificial Dataset","Data Compression"],
    correct_option: 'Synthetic Data',
    explanation: 'Package + Data + Robot = Synthetic Data, artificially generated data used for AI training and testing.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '👁️📄🔤',
    options: ["Optical Character Recognition","Document Scanner","Text Vision","Image Reader"],
    correct_option: 'Optical Character Recognition',
    explanation: 'Eye + Document + Letters = Optical Character Recognition, converting text in images into machine-readable text.',
    is_active: true
  },
  {
    round: 3,
    question_type: 'emoji_mcq',
    prompt_text: '🚨💉🤖',
    options: ["AI Medical Diagnosis","Health Monitor","Robot Doctor","Medical Imaging"],
    correct_option: 'AI Medical Diagnosis',
    explanation: 'Warning + Medical Symbol + Robot = AI-assisted medical diagnosis and detection of health conditions.',
    is_active: true
  }
];

async function insertQuestions() {
  console.log('Inserting 20 Round 3 questions into Supabase...');

  const recordsToInsert = newQuestions.map((q) => ({
    id: crypto.randomUUID(),
    round: q.round,
    question_type: q.question_type,
    prompt_text: q.prompt_text,
    real_image_url: null,
    ai_image_url: null,
    logo_url: null,
    options: q.options,
    correct_option: q.correct_option,
    explanation: q.explanation,
    is_active: true,
    created_at: new Date().toISOString()
  }));

  const { data, error } = await supabase.from('questions').insert(recordsToInsert).select();

  if (error) {
    console.error('❌ Error inserting questions into Supabase:', error.message);
    process.exit(1);
  }

  console.log(`✅ Successfully inserted ${data.length} questions into Supabase!`);

  // Append to data/questions_rows.csv
  const csvPath = path.resolve(__dirname, '../data/questions_rows.csv');
  let csvContent = fs.readFileSync(csvPath, 'utf8').trim();

  recordsToInsert.forEach((q) => {
    const optionsStr = JSON.stringify(q.options).replace(/"/g, '""');
    const promptStr = q.prompt_text.includes(',') ? `"${q.prompt_text}"` : q.prompt_text;
    const explanationStr = `"${q.explanation.replace(/"/g, '""')}"`;
    const row = `${q.id},${q.round},${q.question_type},${promptStr},,,,"[${optionsStr.slice(1, -1)}]","${q.correct_option}",${explanationStr},true,${q.created_at}`;
    csvContent += '\n' + row;
  });

  fs.writeFileSync(csvPath, csvContent + '\n', 'utf8');
  console.log('✅ Updated data/questions_rows.csv');

  // Verify count from Supabase
  const { count, error: countErr } = await supabase.from('questions').select('*', { count: 'exact', head: true });
  if (!countErr) {
    console.log(`📊 Total questions count in Supabase now: ${count}`);
  }
}

insertQuestions().catch(console.error);
