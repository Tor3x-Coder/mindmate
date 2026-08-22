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
5. Sends the conversation to the Workers AI model.
6. Returns `{ reply }` to the app.

## Deploy after you change this file

The file is stored in this repo, but it is deployed from the Cloudflare
dashboard (there is no `wrangler.toml` here yet).

1. Go to Cloudflare → Workers & Pages → `mindmate-ai-chat`.
2. Click **Edit code**.
3. Replace the code in the editor with the content of `worker/index.js`.
4. Click **Deploy**.

Automatic deployment on upload is already enabled in the dashboard, so
the new version will go live after you click Deploy.

## Why a deterministic crisis route exists

The AI model should never be the thing that decides how to handle a clear
crisis message. If someone says something like "I want to kill myself",
this Worker returns a fixed, warm response that points them to Emergency
Support before the model is ever called.
