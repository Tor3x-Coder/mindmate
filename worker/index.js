// MindMate AI Companion — Cloudflare Worker
//
// Safety and operations boundary:
//   - Flutter never talks directly to the model.
//   - The companion is always described as AI, never as a human/therapist.
//   - Explicit crisis language takes a deterministic route before rate limits
//     or model generation.
//   - Client history/modes are treated as untrusted input.
//   - Logs contain request metadata and lengths, never message text.

const WORKER_VERSION = '2026-08-23-batch10';
const DEFAULT_MODEL = '@cf/meta/llama-3.3-70b-instruct-fp8-fast';
const ALLOWED_MODES = new Set(['listen', 'calm', 'make_plan']);
const MAX_BODY_CHARS = 64_000;
const MAX_MESSAGE_CHARS = 4_000;
const MAX_HISTORY_TURNS = 12;
const MAX_HISTORY_TURN_CHARS = 4_000;

const SYSTEM_PROMPT = `You are MindMate's AI companion inside a mental wellness app. Be warm, natural, concise, and transparent that you are AI-supported software, not a person.

Safety and scope:
- Never claim to be human, conscious, a therapist, a doctor, or an emergency service.
- Do not diagnose, prescribe, or present guesses as clinical facts.
- Do not invent assumptions about the user's location, budget, relationships, identity, or preferences.
- Focus on supportive conversation, reflection, grounding, and one small realistic next step.
- Avoid robotic therapy formulas and avoid simply repeating the user's words.
- Keep replies easy to read, usually 2 to 4 sentences.
- Ask at most one question unless the user clearly asks for a deeper exercise.
- If urgent danger or self-harm becomes clear, point to Emergency Support and immediate human help instead of treating it as normal chat.`;

function modePrompt(mode) {
  switch (mode) {
    case 'listen':
      return `Current intent: LISTEN.
- Prioritise genuine listening and validation.
- Keep it to 1 to 3 sentences.
- Do not jump into solutions or a checklist unless asked.
- Invite the user to continue only if it feels natural.`;
    case 'calm':
      return `Current intent: CALM.
- Help the user slow down in the present moment.
- Offer at most one simple grounding or breathing action.
- Keep it to 1 to 3 sentences and avoid clinical claims.`;
    case 'make_plan':
      return `Current intent: MAKE A SMALL PLAN.
- Help choose one small, realistic action for now or today.
- Ask at most one short question only if necessary.
- Avoid long checklists and end with a tiny doable step.`;
    default:
      return `Current intent: SUPPORTIVE CONVERSATION.
- Respond naturally to what was shared.
- Offer at most one gentle next step when useful.
- Keep it to 2 to 4 sentences.`;
  }
}

function normalizeMode(value) {
  if (typeof value !== 'string') return '';
  const mode = value.trim();
  return ALLOWED_MODES.has(mode) ? mode : '';
}

function isCrisis(message) {
  const text = typeof message === 'string' ? message.toLowerCase() : '';
  const patterns = [
    'kill myself',
    'killing myself',
    'going to kill myself',
    'plan to kill myself',
    'take my own life',
    'suicide',
    'suicidal',
    'suicid',
    'end my life',
    'end it all',
    "don't want to live",
    'do not want to live',
    'no reason to live',
    'want to die',
    'wish i was dead',
    'i should die',
    'hurt myself',
    'harm myself',
    'self harm',
    'self-harm',
    "i'm going to hurt myself",
    'i am going to hurt myself',
    "can't keep myself safe",
    'cannot keep myself safe',
    'not safe with myself',
    'i want to hurt someone',
    'going to hurt someone',
    'kill someone',
  ];
  return patterns.some((pattern) => text.includes(pattern));
}

const CRISIS_REPLY = `I’m really glad you reached out. I’m an AI companion and cannot provide emergency help, but you deserve immediate human support right now.

Please open Emergency Support in MindMate or call your local emergency service. If you can, move near someone you trust and tell them you need help staying safe.`;

const QUOTA_FALLBACK = `The AI companion has reached today’s service limit. MindMate’s guided breathing, meditation, journaling, and human-support options are still available.

Please try the Practice tab for now and come back later.`;

const RATE_LIMIT_FALLBACK = `Let’s pause for a moment — messages are arriving too quickly. Take one slow breath, then try again shortly or use a guided Practice while you wait.`;

function responseHeaders(requestId) {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Cache-Control': 'no-store',
    'X-Content-Type-Options': 'nosniff',
    'X-Request-ID': requestId,
  };
}

function jsonResponse(data, status, requestId) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      ...responseHeaders(requestId),
    },
  });
}

function requestIdFor(request) {
  const cloudflareRay = request.headers.get('cf-ray');
  if (cloudflareRay) return cloudflareRay;
  if (globalThis.crypto && typeof globalThis.crypto.randomUUID === 'function') {
    return globalThis.crypto.randomUUID();
  }
  return `local-${Date.now()}-${Math.random().toString(16).slice(2)}`;
}

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

// Keep history cleaning explicit: client roles and values are untrusted, and
// this function is directly unit tested.
function sanitizeHistory(history) {
  if (!Array.isArray(history)) return [];

  const cleaned = [];
  for (const item of history) {
    if (!item || typeof item !== 'object' || Array.isArray(item)) continue;
    if (item.role !== 'user' && item.role !== 'assistant') continue;
    if (typeof item.content !== 'string') continue;

    const content = item.content.trim().slice(0, MAX_HISTORY_TURN_CHARS);
    if (!content) continue;
    cleaned.push({ role: item.role, content });
  }

  return cleaned.length > MAX_HISTORY_TURNS
    ? cleaned.slice(cleaned.length - MAX_HISTORY_TURNS)
    : cleaned;
}

// Backward-compatible name used in earlier documentation/tests.
const cleanHistory = sanitizeHistory;

function looksLikeQuotaError(error) {
  const message = `${error && error.message ? error.message : ''}`.toLowerCase();
  const hints = [
    'quota',
    'daily limit',
    'rate limit',
    'too many requests',
    'exceeded',
    'billing',
    'insufficient',
    'capacity',
    'status 429',
    'error 429',
  ];
  return hints.some((hint) => message.includes(hint));
}

async function countUsage(env) {
  if (!env.MINDMATE_METRICS) return null;

  try {
    const today = new Date().toISOString().slice(0, 10);
    const key = `usage:${today}`;
    const current = Number(await env.MINDMATE_METRICS.get(key)) || 0;
    await env.MINDMATE_METRICS.put(key, String(current + 1), {
      expirationTtl: 60 * 60 * 24 * 2,
    });
    return { date: today, count: current + 1 };
  } catch (error) {
    log('warn', 'metric_write_failed', {
      reason: error && error.message ? error.message : 'unknown',
    });
    return null;
  }
}

const worker = {
  async fetch(request, env, ctx) {
    const startedAt = Date.now();
    const requestId = requestIdFor(request);

    if (request.method === 'OPTIONS') {
      return new Response(null, {
        status: 204,
        headers: responseHeaders(requestId),
      });
    }

    const { pathname } = new URL(request.url);
    if (request.method === 'GET' && pathname === '/health') {
      return jsonResponse(
        {
          service: 'mindmate-ai-chat',
          status: 'ok',
          version: WORKER_VERSION,
          defaultModel: DEFAULT_MODEL,
        },
        200,
        requestId,
      );
    }

    if (request.method !== 'POST') {
      return jsonResponse(
        { error: 'Send a POST request with a message.' },
        405,
        requestId,
      );
    }

    try {
      const declaredLength = Number(request.headers.get('content-length')) || 0;
      if (declaredLength > MAX_BODY_CHARS) {
        return jsonResponse({ error: 'Request body is too large.' }, 413, requestId);
      }

      const rawBody = await request.text();
      if (rawBody.length > MAX_BODY_CHARS) {
        return jsonResponse({ error: 'Request body is too large.' }, 413, requestId);
      }

      let body;
      try {
        body = JSON.parse(rawBody);
      } catch (_) {
        return jsonResponse({ error: 'Invalid JSON body.' }, 400, requestId);
      }

      if (!body || typeof body !== 'object' || Array.isArray(body)) {
        return jsonResponse({ error: 'Invalid request body.' }, 400, requestId);
      }
      if (typeof body.message !== 'string') {
        return jsonResponse({ error: 'Message must be text.' }, 400, requestId);
      }

      const userMessage = body.message.trim();
      if (!userMessage) {
        return jsonResponse({ error: 'No message provided.' }, 400, requestId);
      }
      if (userMessage.length > MAX_MESSAGE_CHARS) {
        return jsonResponse({ error: 'Message is too long.' }, 413, requestId);
      }

      const mode = normalizeMode(body.mode);
      const history = sanitizeHistory(body.history);
      if (ctx && typeof ctx.waitUntil === 'function') {
        ctx.waitUntil(countUsage(env));
      }

      // Explicit crisis language always gets the fixed response before rate
      // limiting and before any model call. This path consumes no AI neurons.
      if (isCrisis(userMessage)) {
        log('warn', 'crisis_route', {
          requestId,
          mode,
          messageLength: userMessage.length,
        });
        return jsonResponse({ reply: CRISIS_REPLY }, 200, requestId);
      }

      if (env.MINDMATE_RATE_LIMIT) {
        const key = request.headers.get('cf-connecting-ip') || 'unknown';
        const { success } = await env.MINDMATE_RATE_LIMIT.limit({ key });
        if (!success) {
          log('warn', 'rate_limited', {
            requestId,
            mode,
            messageLength: userMessage.length,
          });
          return jsonResponse({ reply: RATE_LIMIT_FALLBACK }, 200, requestId);
        }
      }

      if (!env.AI || typeof env.AI.run !== 'function') {
        log('error', 'missing_ai_binding', { requestId });
        return jsonResponse(
          { error: 'The AI companion is unavailable right now.' },
          503,
          requestId,
        );
      }

      const messages = [
        {
          role: 'system',
          content: `${SYSTEM_PROMPT}\n\n${modePrompt(mode)}`,
        },
        ...history,
        { role: 'user', content: userMessage },
      ];

      const configuredModel = typeof env.AI_MODEL === 'string'
        ? env.AI_MODEL.trim()
        : '';
      const model = configuredModel || DEFAULT_MODEL;

      const aiResponse = await env.AI.run(model, {
        messages,
        max_tokens: 220,
        temperature: 0.65,
      });

      const reply = aiResponse && typeof aiResponse.response === 'string'
        ? aiResponse.response.trim()
        : '';
      if (!reply) {
        log('warn', 'empty_reply', { requestId, model });
        return jsonResponse(
          { error: 'The AI companion returned an empty reply. Please try again.' },
          502,
          requestId,
        );
      }

      log('info', 'chat_reply', {
        requestId,
        model,
        mode,
        messageLength: userMessage.length,
        historyLength: history.length,
        replyLength: reply.length,
        durationMs: Date.now() - startedAt,
      });

      return jsonResponse({ reply }, 200, requestId);
    } catch (error) {
      log('error', 'worker_error', {
        requestId,
        durationMs: Date.now() - startedAt,
        reason: error && error.message ? error.message : 'unknown',
      });

      if (looksLikeQuotaError(error)) {
        return jsonResponse({ reply: QUOTA_FALLBACK }, 200, requestId);
      }

      return jsonResponse(
        { error: 'The AI companion is unavailable right now. Please try again in a moment.' },
        500,
        requestId,
      );
    }
  },
};

export {
  ALLOWED_MODES,
  DEFAULT_MODEL,
  MAX_HISTORY_TURN_CHARS,
  MAX_HISTORY_TURNS,
  WORKER_VERSION,
  cleanHistory,
  isCrisis,
  looksLikeQuotaError,
  modePrompt,
  normalizeMode,
  sanitizeHistory,
};

export default worker;
