// MindMate AI Companion — Cloudflare Worker
// Receives a chat message from the app, sends it to a mode-aware AI model
// that keeps responses safe and supportive, and returns the reply.
// The AI never has direct access to the app — this Worker is the only
// thing that talks to it.
//
// What this version adds:
//   - Friendly "daily limit reached" fallback instead of a raw error.
//   - Server-side structured logging for monitoring on Cloudflare.
//   - Optional usage counter in a KV binding (if you add one).
//   - Switchable AI model via an `AI_MODEL` environment variable.
//
// Existing safety features:
//   - Structured modes (listen / calm / make_plan).
//   - Deterministic crisis route BEFORE any AI generation.
//   - History validation (roles, length, per-message size).
//   - Message size limits.
//   - Optional rate limiting (enable the binding to turn it on).
//   - Provider errors are logged but never returned to the app user.

const SYSTEM_PROMPT = `You are a warm, genuine, and down-to-earth human companion inside MindMate, a mental wellness app. Your goal is to be an authentic, supportive sounding board that people actually enjoy talking to.

Guidelines:
- Talk like a real, empathetic person — warm, conversational, and natural. Match the user's energy and way of speaking without forcing it.
- NEVER use robotic therapy formulas like "It sounds like you're feeling...", "I hear that you...", or repeating what they just said back to them.
- Focus on real comfort, validation, or gentle perspective first. Do not immediately grill them with standard interview questions.
- Keep responses concise and easy to read (around 2 to 4 sentences).
- Do not claim to be a licensed therapist or doctor, and do not give rigid clinical advice.
- Do not diagnose or prescribe.
- If strong clinical or emergency needs are clear, gently point to Emergency Support in the app or local emergency services. Do not try to handle a crisis as a normal conversation.
- If the user expresses thoughts of self-harm, suicide, or immediate danger, respond with genuine warmth and immediately direct them to the Emergency Support resources in the app or local emergency services.`;

function modePrompt(mode) {
  switch (mode) {
    case 'listen':
      return `Current intent: LISTEN.
- Prioritise genuine listening and validation first.
- Keep it short (1-3 sentences). Mirror their feeling without copying their words.
- Do not jump into solutions, advice, or a list of questions unless they ask.
- End by inviting them to say more only if it feels natural.`;
    case 'calm':
      return `Current intent: CALM.
- Help them slow down in the moment.
- Use a warm, grounding tone. You may suggest one simple calming action (e.g. slow breathing, naming the feeling, gentle body scan).
- Keep it short (1-3 sentences).
- Do not use clinical language or claim anything is a diagnosis.`;
    case 'make_plan':
      return `Current intent: MAKE A SMALL PLAN.
- Help them choose ONE small, realistic next step for right now or today.
- Ask at most ONE simple question if you genuinely need it.
- Avoid giving a long checklist or over-planning.
- End with a tiny, doable action.`;
    default:
      return `Current intent: SUPPORTIVE CONVERSATION.
- Be natural and present. Focus on what the person shared and only offer one gentle next step if it helps.
- Keep it short (2-4 sentences).`;
  }
}

// Keywords that should ALWAYS take the deterministic safety route before
// the AI model is allowed to respond.
function isCrisis(message) {
  const text = (message || '').toLowerCase();
  const patterns = [
    // Self-harm / suicide
    'kill myself', 'killing myself',
    'suicide', 'suicidal', 'suicid',
    'end my life', 'end it all',
    'don\'t want to live', 'do not want to live', 'no reason to live',
    'want to die', 'wish i was dead', 'i should die',
    'hurt myself', 'harm myself', 'self harm', 'self-harm',
    // Immediate danger / violence toward self or others
    'emergency', 'i\'m going to hurt myself', 'i am going to hurt myself',
    'i want to hurt someone', 'going to hurt someone',
    'save me', 'help me right now',
  ];
  return patterns.some((pattern) => text.includes(pattern));
}

const CRISIS_REPLY = `I am really glad you reached out right now. What you shared is serious, and you should not carry it alone.

Please open the Emergency Support section in the MindMate app now, or call a local emergency line. You deserve immediate, human support.`;

const QUOTA_FALLBACK = `You have reached today\'s free chat limit for the AI companion. No worries — MindMate still has gentle guided practices you can use right now.

Come back tomorrow, or try a breathing, meditation, or journaling exercise from the Practice tab in the meantime.`;

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
  };
}

function jsonResponse(data, status) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', ...corsHeaders() },
  });
}

// Structured logging for Cloudflare Workers Logs. Keeping it as a JSON
// string makes it easy to read in the dashboard and to filter later.
function log(level, event, fields) {
  const line = {
    service: 'mindmate-ai-chat',
    ts: new Date().toISOString(),
    level,
    event,
    ...fields,
  };
  const message = JSON.stringify(line);
  if (level === 'error') {
    console.error(message);
  } else if (level === 'warn') {
    console.warn(message);
  } else {
    console.log(message);
  }
}

// Validate and clean history sent by the app.
// Only user/assistant roles are allowed, content is trimmed and capped,
// and the whole list is capped to the most recent 16 turns.
function cleanHistory(history) {
  if (!Array.isArray(history)) return [];

  const cleaned = [];
  for (const item of history) {
    if (!item || typeof item !== 'object') continue;
    const role = item.role;
    if (role !== 'user' && role !== 'assistant') continue;
    const content = typeof item.content === 'string'
      ? item.content.trim().slice(0, 4000)
      : '';
    if (!content) continue;
    cleaned.push({ role, content });
  }

  return cleaned.length > 16 ? cleaned.slice(cleaned.length - 16) : cleaned;
}

// Decide whether an AI error is really a quota/limit hit so we can give
// the user the friendly fallback instead of a scary error.
function looksLikeQuotaError(err) {
  const message = `${err && err.message ? err.message : ''}`.toLowerCase();
  const hints = [
    'quota',
    'limit',
    'exceed',
    'billing',
    'out of',
    'insufficient',
    '429',
    'rate',
    'capacity',
  ];
  return hints.some((hint) => message.includes(hint));
}

// Optionally count today's requests in a KV namespace. If the binding is
// missing this is silently skipped, so the Worker still runs fine.
async function countUsage(env) {
  if (!env.MINDMATE_METRICS) return;

  try {
    const today = new Date().toISOString().slice(0, 10);
    const key = `usage:${today}`;
    const current = Number(await env.MINDMATE_METRICS.get(key)) || 0;
    await env.MINDMATE_METRICS.put(key, String(current + 1), {
      expirationTtl: 60 * 60 * 24 * 2,
    });
    return { date: today, count: current + 1 };
  } catch (err) {
    log('warn', 'metric_write_failed', { reason: err.message });
    return null;
  }
}

export default {
  async fetch(request, env, ctx) {
    const startedAt = Date.now();

    // Browsers send a preflight OPTIONS request before the real POST —
    // this just approves it so the real request can go through.
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders() });
    }

    if (request.method !== 'POST') {
      return new Response('Send a POST request with a message.', {
        status: 405,
        headers: corsHeaders(),
      });
    }

    try {
      const body = await request.json();

      if (!body || typeof body !== 'object') {
        return jsonResponse({ error: 'Invalid request body.' }, 400);
      }

      const userMessage = (body.message || '').toString().trim().slice(0, 4000);
      if (!userMessage) {
        return jsonResponse({ error: 'No message provided.' }, 400);
      }

      const mode = (body.mode || '').toString().trim();
      const history = cleanHistory(body.history);

      // Optional: simple per-day usage counter (needs the KV binding).
      ctx.waitUntil(countUsage(env));

      // Optional rate limiting using a Cloudflare Rate Limiting binding.
      // Add a binding named MINDMATE_RATE_LIMIT in the dashboard to enable it.
      if (env.MINDMATE_RATE_LIMIT) {
        const { success } = await env.MINDMATE_RATE_LIMIT.limit({
          name: 'mindmate_ai_chat',
          key: request.headers.get('cf-connecting-ip') || 'unknown',
        });
        if (!success) {
          log('warn', 'rate_limited', { messageLength: userMessage.length });
          return jsonResponse({
            error: 'You are sending messages too quickly. Please slow down and try again in a moment.',
          }, 429);
        }
      }

      // Deterministic safety route BEFORE the AI model runs.
      if (isCrisis(userMessage)) {
        log('warn', 'crisis_route', {
          mode,
          messageLength: userMessage.length,
        });
        return jsonResponse({ reply: CRISIS_REPLY }, 200);
      }

      const messages = [
        { role: 'system', content: SYSTEM_PROMPT },
        ...history,
        { role: 'user', content: userMessage },
      ];

      if (mode) {
        messages.splice(1, 0, { role: 'user', content: modePrompt(mode) });
      }

      // The model is configurable through the AI_MODEL env variable so you
      // can switch free models without editing this file. The default keeps
      // the current, budget-friendly model.
      const model = env.AI_MODEL || '@cf/meta/llama-3.1-8b-instruct-fast';

      const aiResponse = await env.AI.run(model, { messages });

      const reply = (aiResponse.response || '').trim();
      if (!reply) {
        log('warn', 'empty_reply', { model });
        return jsonResponse({
          error: 'The AI companion returned an empty reply. Please try again.',
        }, 502);
      }

      const durationMs = Date.now() - startedAt;
      log('info', 'chat_reply', {
        model,
        mode,
        messageLength: userMessage.length,
        historyLength: history.length,
        replyLength: reply.length,
        durationMs,
      });

      return jsonResponse({ reply }, 200);
    } catch (err) {
      const durationMs = Date.now() - startedAt;
      log('error', 'worker_error', {
        durationMs,
        reason: err && err.message ? err.message : 'unknown',
      });

      // If this looks like a daily quota / rate limit hit, return the
      // friendly fallback instead of a scary technical message.
      if (looksLikeQuotaError(err)) {
        return jsonResponse({ reply: QUOTA_FALLBACK }, 200);
      }

      // Generic friendly failure. Real provider details stay server-side.
      return jsonResponse({
        error: 'The AI companion is unavailable right now. Please try again in a moment.',
      }, 500);
    }
  },
};
