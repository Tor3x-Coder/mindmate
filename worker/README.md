# MindMate AI Worker

This folder is the source code for the Cloudflare Worker that backs the
MindMate AI chat.

- `index.js` — the Worker code.
- `worker/README.md` — this file.

The Worker is deployed on Cloudflare at:
```
https://mindmate-ai-chat.tor3x-akachukwu.workers.dev
```

The Flutter app calls this URL from `lib/services/chat_service.dart`.

## What the Worker does

1. Receives `{ message, history, mode }` from the app.
2. Validates + limits the message and chat history.
3. Checks for crisis keywords first (deterministic safety route).
4. If safe, prepends a mode-aware prompt (`listen`, `calm`, `make_plan`).
5. Sends the conversation to the configured AI model.
6. Returns `{ reply }` to the app.

## Switching the AI model (free option)

By default the Worker uses `@cf/meta/llama-3.1-8b-instruct-fast`.

You can switch it without editing code by setting an environment variable
called `AI_MODEL` in the Cloudflare dashboard:

- **Stronger (more neurons, slightly slower):**
  `@cf/meta/llama-3.3-70b-instruct-fp8-fast`
- **Smaller/cheaper (less neurons, lower quality):**
  `@cf/meta/llama-3.2-3b-instruct`

To set it: Cloudflare → Worker → Settings → Variables and Secrets →
Add → `AI_MODEL` → put the model ID as a **plain text variable** → Save →
Redeploy.

## Monitoring / server-side logging

The Worker writes structured JSON logs on every request and on every error.
They appear in Cloudflare **Workers Logs**:

> Worker dashboard → **Logs** tab (or **Observability → Workers Logs**).

Each log line looks like:
```
{"service":"mindmate-ai-chat","level":"info","event":"chat_reply","mode":"listen","messageLength":34,...}
```

You can also add a **KV namespace binding** named `MINDMATE_METRICS` to get a
simple `usage:YYYY-MM-DD` counter of how many AI messages were handled today.

## Rate limiting (optional)

To turn on rate limiting, add a Cloudflare **Rate Limiting** binding named
`MINDMATE_RATE_LIMIT`. If the binding is missing, this is safely skipped.

## Fallback on daily limit

If Cloudflare returns a quota / rate-limit style error, the Worker returns a
friendly message that nudges the user toward guided practices instead of a
raw technical error.

## Deploy after you change this file

The file is stored in this repo, but it is deployed from the Cloudflare
dashboard (there is no `wrangler.toml` here yet).

1. Go to Cloudflare → Workers & Pages → `mindmate-ai-chat`.
2. Click **Edit code**.
3. Replace the code in the editor with the content of `worker/index.js`.
4. Click **Deploy**.

Automatic deployment on upload is already enabled in the dashboard, so
the new version goes live after you click Deploy.

## Why a deterministic crisis route exists

The AI model should never be the thing that decides how to handle a clear
crisis message. If someone says something like "I want to kill myself",
this Worker returns a fixed, warm response that points them to Emergency
Support before the model is ever called.
