# MindMate AI Worker

**Last updated:** 2 September 2026

This folder is the source for MindMate's Cloudflare Workers AI backend.
Flutter calls the Worker; it never contains a model/provider secret.

## Current checkpoint

- Source hardening: implemented locally in `worker/index.js`.
- Learn article context: implemented locally; the selected approved article is bounded and passed to the AI as reference context.
- Worker tests: **13/13 passed** with Node's built-in test runner.
- Flutter client sanitization: updated locally; Flutter validation pending.
- Selected default model: `@cf/meta/llama-3.3-70b-instruct-fp8-fast`.
- Live Worker deployment: Batch 10 is live; the `2026-09-02-learn-context` source is implemented locally, and deployment is intentionally deferred until separately approved.
- Live endpoint currently configured in Flutter:

```text
https://mindmate-ai-chat.tor3x-akachukwu.workers.dev
```

The existing Batch 10 deployment is live. Do not call the Learn-context
Worker update deployed until the live `/health` endpoint reports the new
version and the live POST matrix passes.

## Why Llama 3.3 70B FP8 Fast

Cloudflare still lists this model as supported, with a 24,000-token context
window. MindMate keeps only 12 recent turns, caps each turn, and limits output
to 220 tokens. This makes the stronger model a quality-first competition
choice while preserving concise replies.

Cloudflare Workers AI provides a free allocation of 10,000 neurons per day.
If usage exceeds the available service quota, MindMate returns a friendly
Practice fallback instead of provider details.

`AI_MODEL` remains a plain-text emergency override. If the selected model is
retired or temporarily unavailable, the Worker can switch without a Flutter
release.

## What this version enforces

1. Accepts POST JSON shaped like `{ message, history, mode, learnContext? }`.
2. Treats the optional Learn context as bounded reference text, not instructions.
3. Rejects malformed, non-text, empty, oversized message/body input.
4. Accepts only `listen`, `calm`, and `make_plan`; unknown modes become general support.
5. Keeps at most 12 recent `user`/`assistant` turns and rejects injected roles.
6. Routes explicit crisis language to fixed human-support guidance before rate limiting or AI generation.
7. Uses one trusted system message containing the selected mode instructions.
8. Never describes the AI as human, a therapist, a doctor, or emergency help.
9. Limits model output and keeps provider failures server-side.
10. Returns friendly quota/rate-limit fallbacks.
11. Logs request IDs, model/mode, lengths, and timing—never message text.
12. Adds no-store/security headers.
13. Exposes a safe deployment check:

```text
GET /health
```

Expected after deployment:

```json
{
  "service": "mindmate-ai-chat",
  "status": "ok",
  "version": "2026-09-02-learn-context",
  "defaultModel": "@cf/meta/llama-3.3-70b-instruct-fp8-fast"
}
```

## Local source tests

From the repository:

```powershell
cd T:\Dev\mindmate\worker
npm test
```

Expected:

```text
12 passed
0 failed
```

The suite covers modes/history, prompt injection, malformed/oversized input,
crisis-before-rate-limit behavior, current rate-limit API shape, final model,
model override, quota/provider failures, missing bindings, empty replies,
health/version output, and no user text in request logs.

## Required Cloudflare bindings/settings

### AI binding — required

The Worker must have a Workers AI binding named:

```text
AI
```

Without it, the Worker returns a safe 503 response.

### AI model variable — recommended explicit setting

Add this plain-text variable:

```text
AI_MODEL=@cf/meta/llama-3.3-70b-instruct-fp8-fast
```

This is not a secret. Do not add any provider API key to Flutter.

### Rate limiting — recommended before release

Create a Workers Rate Limiting binding named:

```text
MINDMATE_RATE_LIMIT
```

Recommended prototype configuration:

```text
20 requests per 60 seconds
```

Use a namespace ID unique to the Cloudflare account. The code calls the
current API as `limit({ key })`. Crisis responses bypass this limiter because
they do not call the model.

The current fallback key is Cloudflare's connecting IP because the Worker does
not yet verify Firebase identity. Shared mobile networks can share an IP, so
this remains a prototype abuse-control trade-off—not user authentication.

### Metrics KV — optional and deferred

A KV binding named `MINDMATE_METRICS` enables the basic daily request counter.
Structured Cloudflare logs are enough for the competition, so do not add KV
only for vanity analytics.

## Deploy from the Cloudflare dashboard

1. Cloudflare → Workers & Pages → `mindmate-ai-chat`.
2. Open **Edit code**.
3. Replace the Worker source with the complete `worker/index.js` file.
4. Confirm the `AI` binding.
5. Set the explicit `AI_MODEL` variable above.
6. Add the recommended `MINDMATE_RATE_LIMIT` binding if available.
7. Click **Deploy**.
8. Open:

```text
https://mindmate-ai-chat.tor3x-akachukwu.workers.dev/health
```

Confirm version `2026-09-02-learn-context` and the model before testing normal chat and article-context chat.

## Live PowerShell smoke matrix

Use non-sensitive test messages only.

```powershell
$endpoint = "https://mindmate-ai-chat.tor3x-akachukwu.workers.dev"

Invoke-RestMethod "$endpoint/health"

Invoke-RestMethod $endpoint -Method Post -ContentType "application/json" -Body '{"message":"I had a hard day and want one small next step.","history":[],"mode":"make_plan"}'

Invoke-RestMethod $endpoint -Method Post -ContentType "application/json" -Body '{"message":"Help me slow down for a moment.","history":[],"mode":"calm"}'

Invoke-RestMethod $endpoint -Method Post -ContentType "application/json" -Body '{"message":"What should I take from this read?","history":[],"learnContext":"Learn article title: When your usual coping stops helping\nArticle summary: A coping pattern can become a problem when it causes harm or makes your world smaller."}'

Invoke-RestMethod $endpoint -Method Post -ContentType "application/json" -Body '{"message":"I want to kill myself","history":[],"mode":"listen"}'
```

The crisis response must point to immediate human support and must not depend
on model output. Complete invalid/oversized/rate-limit tests from the checklist
in `MINDMATE_STATUS.md` after deployment.
