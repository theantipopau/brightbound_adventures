/**
 * BrightBound Adventures — AI Question Generator Worker
 *
 * Model: @cf/meta/llama-3.1-8b-instruct (Workers AI free tier)
 *
 * Deploy:
 *   cd workers/question-gen
 *   npx wrangler deploy
 *
 * The deployed URL (e.g. https://brightbound-question-gen.<subdomain>.workers.dev)
 * must be pasted into lib/core/services/ai_question_service.dart → workerUrl.
 */

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

const SYSTEM_PROMPT = `You are an educational question generator for Australian primary school children (ages 4–12).
Generate engaging, factually accurate multiple-choice questions aligned to the Australian Curriculum.
ALWAYS return ONLY a valid JSON array. No markdown, no prose, no code fences — just the raw JSON array.`;

const ZONE_CONTEXTS = {
  word_woods:
    'English literacy: phonics, spelling, reading comprehension, grammar, punctuation, vocabulary, sentence structure',
  number_nebula:
    'Mathematics: counting, place value, addition, subtraction, multiplication, division, fractions, decimals, measurement, geometry, time, money',
  story_springs:
    'Creative writing and storytelling: narrative structure, characters, plot, setting, figurative language, poetry, descriptive writing',
  puzzle_peaks:
    'Logic and reasoning: number patterns, letter sequences, analogies, spatial reasoning, logical deduction, critical thinking, "odd one out"',
  science_explorers:
    'Australian primary science: biological sciences (living things, ecosystems, animal classification, life cycles, food chains, human body), earth and space sciences (weather, seasons, water cycle, solar system), physical sciences (forces, materials and properties, energy, light, sound)',
  creative_corner:
    'Visual arts and music: colour theory, elements of art (line, shape, colour, texture, form), famous artists (Monet, Van Gogh, Picasso, indigenous Australian artists), musical notes and instruments, creative techniques',
  adventure_arena:
    'General knowledge: Australian geography and landmarks, sport rules, health and wellbeing, teamwork, community and civic life',
};

const DIFF_LABELS = ['very easy', 'easy', 'medium', 'hard', 'very hard'];

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: CORS_HEADERS });
    }

    if (request.method !== 'POST') {
      return new Response('Method not allowed', {
        status: 405,
        headers: CORS_HEADERS,
      });
    }

    let body;
    try {
      body = await request.json();
    } catch {
      return jsonError(400, 'Invalid JSON body');
    }

    const { zone, skill, difficulty = 3, count = 5, ageGroup = '6-9' } = body;

    if (!zone || !skill) {
      return jsonError(400, 'zone and skill are required');
    }

    const clampedCount = Math.min(Math.max(1, Number(count)), 10);
    const clampedDiff = Math.min(Math.max(1, Number(difficulty)), 5);
    const context = ZONE_CONTEXTS[zone] ?? 'Australian primary school curriculum';
    const diffLabel = DIFF_LABELS[clampedDiff - 1];
    const skillLabel = String(skill).replace(/skill_/g, '').replace(/_/g, ' ');

    const prompt = buildPrompt(context, skillLabel, diffLabel, clampedCount, String(ageGroup));

    try {
      const aiResponse = await env.AI.run('@cf/meta/llama-3.1-8b-instruct', {
        messages: [
          { role: 'system', content: SYSTEM_PROMPT },
          { role: 'user', content: prompt },
        ],
        max_tokens: 2000,
        temperature: 0.85,
      });

      const text = aiResponse?.response ?? '';
      const questions = parseQuestions(text);

      return new Response(
        JSON.stringify({ questions }),
        { headers: { 'Content-Type': 'application/json', ...CORS_HEADERS } }
      );
    } catch (err) {
      return jsonError(500, String(err));
    }
  },
};

// ─── Prompt builder ───────────────────────────────────────────────────────────

function buildPrompt(context, skillLabel, diffLabel, count, ageGroup) {
  return `Generate exactly ${count} multiple-choice questions for Australian children aged ${ageGroup}.

Topic: ${skillLabel}
Curriculum area: ${context}
Difficulty: ${diffLabel}

Return ONLY a JSON array in this exact format (no text outside the array):
[
  {
    "question": "...",
    "options": ["A", "B", "C", "D"],
    "correctIndex": 0,
    "hint": "...",
    "explanation": "..."
  }
]

Rules:
- correctIndex is 0-based: 0 = first option, 1 = second, etc.
- questions[i].options must have exactly 4 items
- All 4 options must be plausible — no obviously wrong distractors
- Every answer must be factually correct
- Use Australian English spelling (colour, behaviour, maths, recognise)
- Vary question types: what/why/how/which/scenario/true-false
- For difficulty very easy / easy: simple recall, concrete examples, short sentences
- For difficulty medium: application and understanding, use context clues
- For difficulty hard / very hard: inference, analysis, multi-step reasoning
- Use emojis occasionally to make questions fun 🎉
- Questions must not be identical or repetitive`;
}

// ─── JSON parser / validator ──────────────────────────────────────────────────

function parseQuestions(text) {
  const start = text.indexOf('[');
  const end = text.lastIndexOf(']');
  if (start === -1 || end === -1 || end <= start) return [];

  try {
    const arr = JSON.parse(text.slice(start, end + 1));
    if (!Array.isArray(arr)) return [];

    return arr
      .filter(
        (q) =>
          q &&
          typeof q.question === 'string' &&
          Array.isArray(q.options) &&
          q.options.length === 4 &&
          typeof q.correctIndex === 'number' &&
          q.correctIndex >= 0 &&
          q.correctIndex <= 3
      )
      .map((q) => ({
        question: String(q.question).trim(),
        options: q.options.map((o) => String(o).trim()),
        correctIndex: Math.round(q.correctIndex),
        hint: q.hint ? String(q.hint).trim() : 'Think carefully about all the options.',
        explanation: q.explanation ? String(q.explanation).trim() : '',
      }));
  } catch {
    return [];
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

function jsonError(status, message) {
  return new Response(JSON.stringify({ error: message, questions: [] }), {
    status,
    headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
  });
}
