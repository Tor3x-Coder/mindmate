# MindMate handoff for a new chat

**Last updated:** 2 September 2026

## Read these first

1. `MINDMATE_STATUS.md` — current implementation, validation, deployment state, and exact next action.
2. `MINDMATE_CODING_GUIDE.md` — collaboration, coding, UI, safety, and documentation rules.
3. `MINDMATE_REMAINING_BATCHES.md` — full ordered plan, guided-audio decision, competitive grade, strengths, and weaknesses.
4. This file — product direction, decisions, and broader context.
5. `worker/README.md` before changing or deploying the AI Worker.

Do not use an old chat transcript as the status source. The repository documents must be updated in the same batch as every implementation or fix.

## User working style

- Speak casually and plainly (“bro”), but explain programming terms in brackets.
- Do not make new app-code edits without explicit approval.
- For a screen redesign, create two strong UI options and mark the preferred one with `[RECOMMENDED]` before implementation.
- User prefers exact small-edit instructions:
  - file path;
  - exact text to find with Ctrl+F;
  - exact replacement or exact text to paste below it;
  - why the fix is needed;
  - how to test it.
- Do not ask for the whole project. Request only the relevant file when it is not already in the repository.
- Do not treat pasted indentation as a bug if the actual app compiles.
- After every fix, update `MINDMATE_STATUS.md` and all relevant Markdown documentation so the next chat can continue immediately.

## Product direction

MindMate is a real-world, action-first mental-wellness companion, not a school-project app.

Core promise:

> Help a person move from “I do not know what to do right now” to one small, personalised, safe next step.

Core loop:

```text
Mood check-in
  -> understand the need
  -> recommend one action
  -> user tries it
  -> ask whether it helped
  -> offer another approach or human support
```

MindMate is not a diagnostic tool, therapist, doctor, medical device, or emergency service.

## AI direction

Keep AI, but make the product AI-supported rather than AI-first.

- The Flutter app calls a Cloudflare Worker; provider credentials do not belong in Flutter.
- AI supports conversation, reflection, and small plans.
- It must not diagnose, prescribe, claim to replace a professional, or treat crisis content as normal chat.
- Journal reflection remains future work and must be opt-in.
- Chat history is currently memory-only; persistent sessions and a past-chat screen are not implemented.

Implemented in the repository:

- structured modes: `listen`, `calm`, and `make_plan`;
- Flutter and Worker history sanitization/limits;
- rejection of client-injected system roles;
- deterministic crisis-keyword routing before normal generation;
- generic user-safe errors and server-side structured logs;
- friendly quota fallback;
- final local default `@cf/meta/llama-3.3-70b-instruct-fp8-fast` with `AI_MODEL` override;
- strict message/body/mode/history validation on Worker and Flutter sides;
- crisis route before limiter/model generation;
- current Cloudflare Rate Limiting binding API and friendly fallback;
- versioned `/health`, no-store headers, request IDs, and length-only logs;
- safe quota/provider/missing-binding responses;
- 12/12 local Worker tests; 4 Flutter ChatService tests added (9/9 total tests passing, 0 analyzer errors);
- live Worker deployed to `mindmate-ai-chat.tor3x-akachukwu.workers.dev`;
- `/health` confirmed returning version `2026-08-23-batch10` with model `@cf/meta/llama-3.3-70b-instruct-fp8-fast`;
- live plan, calm, and crisis safety routes verified.

## Frontend decisions and current implementation

Selected/implemented directions:

- Quiet Tide palette.
- Home: Option A — Today, One Step.
- Practice: Option A — Practice Map.
- Journal: Option A — Private Diary.
- Breathing: the rejected Sanctuary redesign was removed; the former breathing screen was restored.
- Meditation: Option A — Meditation Journey.
- CBT: Option A — Guided Path with 9-category branching.
- Progress: Option A — Your Story.
- Achievements: Option A — Wins Shelf.
- Chat: Option A — Guided Conversation.
- Me/Settings: Option A — Personal Space.
- Emergency: Option A — Immediate Help, now with explicit trusted-contact actions and location choices.
- Professional directory: Option A — Find the Right Person.
- Professional detail: Option A — Profile & Request.
- Appointment request: Option A — Request in Steps.
- My Requests: Option A — Request Tracker.
- Admin appointment review: Option A — Review Queue.
- Admin professionals: Option A — Directory Manager.
- Professional form: Option A — Guided Listing Setup.
- Terms/Privacy: Option A — Readable Legal.
- Wellness Check: Option A — Daily Snapshot.
- Wellness Result: Option A — Reflection & Next Step.
- Learn: Option B — Home featured card, four situation-based shelves, clean reader, sixteen core reads, eight bundled Explore more reads, and article-scoped AI questions.
- The illustration onboarding carousel is confirmed.
- Splash/illustration-first screens are excluded from further redesign.
- Existing Login/Register screens are intentionally left as-is unless a functional bug is found.

## Important implementation details

- **Guided audio is competition-critical and Batch 7A–7D is complete.** All 3 breathing patterns (Box, 4-7-8, Simple Calm) and all 18 meditation sessions have unique offline narration with matching written captions: meditation gets intro + 4 main prompts (reading the session's guiding lines) + 4 short reassurance cues at `0.88x`; breathing gets intro + phase cues verified to fit each phase length + completion at `0.92x`. Daily Snapshot plays one short guide once per stage (Body/Mind/Routine/Review) with replay/mute above the Continue bar, and the Wellness Result screen plays one safe band narration on entry (steady >= 70 / mixed 40-69 / heavier < 40; no score read-out, no diagnosis) with replay/mute and stop-on-exit. The 15 pilot clips were re-voiced with the newly approved narrator so the app uses one consistent voice. **184 MP3s total about 3.75 MB; asset audit passed 184/184.** One Wind Down reassurance line was reworded after a content-filter rejection ("A little slower with each breath"); its caption matches the audio. Only 7E (Chrome/device playback matrix) remains.
- **Approved full audio scope:** one consistent natural narrator with unique words for all 18 meditation sessions, segmented prompts for 1/3/5-minute choices, unique guidance for all 3 breathing patterns, one short guide per Daily Snapshot stage, and 3 safe Wellness Result band narrations. Keep intentional quiet between concise cues. Literal breathing loops are rejected for now; future calm ambience must be optional, licensed, loop-safe, independently volume-controlled, and duck under narration.
- **Floating Tide Orb navigation is implemented, polished, and Chrome-validated:** four lower-positioned destinations, slower 520ms-base glide, restrained hop, visible labels, semantics, reduced-motion support, and existing IndexedStack state preservation.
- **First-use guide is implemented and Chrome-validated:** four coach marks for Home, Practice, Chat, and Me with Skip/Next/Got it, `tourVersion = 1` persistence, Settings replay, and a lightweight Flutter-drawn 2D figure. Automatic display is requested only after new-user onboarding; Login/Splash do not force it. It never appears on Emergency Support or autoplays speech. Fresh-account and physical-device release checks remain.
- **Quiet Tide Modern shell is focused, not a full redesign:** global app bars use consistent height/spacing and no scroll tint/elevation. The user confirmed the combined shell works; child-screen polish remains intentionally deferred.
- **Learn Option B is expanded locally:** Home places the featured Learn card between the Wellness card and Quick starts. The Learn screen groups sixteen core reads (the six foundational articles plus ten approved scenarios) into Everyday life, Love and people, Understanding difficult moments, and Getting help. Explore more contains eight additional bundled scenario reads with search and local Add to Learn persistence. Each article has a readable scroll view, safety boundary, an existing-tool next step, and article-scoped Ask MindMate context. Content lives in `lib/utils/learn_articles.dart` and uses no Firestore or personal reading-history collection. The selected article context is bounded in Flutter and the Worker; the Worker source is versioned `2026-09-02-learn-context`, while its deployment is intentionally deferred because deployment was not part of this code-only batch. The live Worker remains the previously verified Batch 10 deployment. Developer-PC automated validation is complete: analyzer 0 errors/0 warnings with 29 informational notices, focused Learn 2/2, catalogue/Chat 6/6, and full Flutter 43/43. Android/Web/Chrome/device validation and articles 3–4 health-literate skim remain open; live Worker context smoke is only needed after a separately approved deployment.
- **Demo account seed is implemented, applied, and app-verified:** `scripts/demo_seed/` contains a dry-run-first Node/Firebase Admin SDK seeder that writes 50 deterministic, synthetic documents across the existing personal-history collections only after `--apply --confirm-demo`. It resolves the account by registered email or UID, never deletes data or writes the profile, and keeps service-account JSON outside the repo. Pure script tests pass 4/4; the developer successfully applied the 50-document seed and confirmed the seeded history in Progress, Journal, Achievements, and the app's history views.
- **Approved landing direction:** use the supplied Spouse Finder page only as visual/interaction inspiration. Build a separate lightweight informational MindMate site, not a hosted Flutter version of the app. It must include a functional `/delete-account` request resource for Google Play, plus truthful product/safety/privacy information, screenshots, FAQ, and a signed release APK download—not the debug APK.
- **Light is the validated first-run/reset default.** Dark and System remain optional user choices.
- **Registration contrast is Chrome-validated:** Name/Email/Password match Login's dark 16px style; setup choices use readable surface text.
- **Daily Snapshot is Chrome-validated with 8 real units:** Body, 5 Mind questions, Routine, Review. Mind 5/5 shows Step 6 of 8 / 75%.
- Mood impact uses words: A little, Somewhat, A lot, Overwhelming, Not sure yet.
- CBT branches: Relationship, School/work, Mistake/regret, Future worry, Self-doubt, Sad/low, Angry/frustrated, Hurt/disappointed, Something else.
- `Something else` uses a neutral fallback path.
- Post-activity feedback: Much worse, A little worse, About the same, A little better, Much better, Not sure yet.
- Journal is private first; optional AI reflection requires explicit consent.
- Trusted contacts store name, relationship, and phone. The app opens `tel:` or `sms:` only after the user taps and never contacts anyone silently.
- Home has a “Need help right now?” route to Emergency Support.
- Emergency resources include Nigeria state choices, nationwide 112 fallback, international choices, and Find a Helpline. Every resource must be authoritatively re-verified before public release.
- Appointments are requests, not instant bookings. Statuses are pending, approved, and declined.

## Backend/integration batches already implemented in code

See `MINDMATE_STATUS.md` for exact files and status.

1. **Firestore rules/admin support** — stricter user/admin rules, UID preservation, thought-record rule, appointment admin service/UI support.
2. **Mood impact/feedback** — mood impact and post-activity feedback persistence with `feedback_records`.
3. **Appointment duplicate guard** — blocks another pending request to the same professional in the normal app flow.
4. **AI Worker** — modes, limits, crisis route, rate-limit hook, logging, quota fallback, and model configuration.
5. **Trusted contacts/support events** — owner-only contact storage, explicit call/message actions, follow-up events, and expanded emergency UI.
6. **Batch 8 Firestore integrity (validated and deployed)** — pending-only appointment creation, admin status-only updates, user/admin profile protection, trusted/support schemas, service guards, 13/13 emulator cases, Flutter gates, and successful release to `mindmate-app-fcf2d` on 23 August 2026.
7. **Batch 9A account deletion/recovery (happy path validated)** — Spark-compatible in-app deletion, password reauthentication, repeatable owned-data batches, retry marker/routing, missing-profile recovery, registration rollback, no password trimming, 13/13 rules tests, deployed profile-delete rule, and confirmed disposable-account deletion.
8. **Batch 9B runtime reliability (validated)** — bounded wellness scoring, 4/4 model tests, mounted-safe appointment/dashboard async handling, friendly My Requests errors, intentional ISO-string migration deferral, 5/5 total tests, and Flutter 0 errors/0 warnings.
9. **Batch 10 AI Worker hardening (validated, deployed, verified)** — transparent AI identity, final Llama 3.3 70B model, strict payload/mode/history limits, crisis-first routing, fixed rate-limit API, health/version endpoint, safe fallbacks/logging, 12/12 Worker tests, 9/9 Flutter tests, live deployment to `mindmate-ai-chat`, and confirmed live `/health` and chat/crisis responses on 25 August 2026.

## Remaining backend/release work

Immediate prototype path:

1. Run 12 Worker tests plus Flutter analyze/tests for the 4 new client cases.
2. Deploy Batch 10 Worker source, explicit Llama 3.3 model, and recommended limiter.
3. Verify `/health` and the complete live mode/crisis/error matrix.
4. Keep deletion retry/recovery and external `/delete-account` in the release matrix.
5. Verify emergency resources and sensitive content — **Batch 11 part 1 done (26 Aug 2026):** all 36 states + FCT verified against the NEMSAS list of 19 Aug 2026 (15 added), 112 + international lines confirmed, demo-data banner added, full table in `docs/emergency_resource_verification.md`; device pass + re-verification before public release remain.
6. Run the complete device/release test matrix and build the signed candidate APK.

See `MINDMATE_REMAINING_BATCHES.md` for tasks and exit criteria for Batches 6–13.

Known backend/product limitations that may be deferred beyond the competition prototype:

- the one-pending-appointment check is a client/service guard, not authoritative server-side uniqueness enforcement;
- real professional accounts, roles, provider inboxes, notifications, and calendars;
- persistent AI chats;
- opt-in journal AI reflection;
- privacy data export controls;
- trusted-backend deletion after a future Blaze upgrade;
- production moderation and operational review.

## Known code issues already logged

- Account deletion happy path is proven; retry/recovery evidence remains.
- Critical async/error paths are fixed locally in Batch 9B; broader device/network testing remains.
- ISO date strings are intentionally frozen for the prototype; migrate only with dual-read/backfill planning.
- Wellness caps/tests and My Requests friendly errors are validated; broader weak-network/device checks remain.
- Some screens still have hardcoded legacy colours.
- Current analyzer debt is non-blocking: 2 deprecated onboarding Radio API notices and 19 optional `const` notices.
- Post-audio `flutter pub get` reports 27 newer package versions outside current constraints; avoid major upgrades before the competition unless required and tested.
- Some service comments are stale and can be cleaned during a controlled pass.

## Competition

- **Competition: 21 September 2026** (corrected 1 September 2026 — 11 September is when school starts, not the competition).
- Full-team build window: **1–10 September 2026** (after school starts, the team only has evenings).
- **Target feature freeze: ~13–14 September 2026.** After that, critical fixes only.
- Rehearsal window: 11–21 September (demo script, live crisis-route moment, airplane-mode fallback, team drilling the five hard questions in pairs).
- Current handoff date: 1 September 2026.
- The competition accepts prototypes. Prioritise one polished, reliable demo journey over extra features.

Demo journey:

```text
Check in
  -> personalised next step
  -> complete/try activity
  -> save feedback
  -> alternate action or human-support route
```

## Immediate next action

**Read the "Session handoff — 1 September 2026" block at the top of `MINDMATE_STATUS.md` first** — it carries the date correction (competition 21 September, school from 11 September), the four locked decisions (expanded Learn, script-based demo seeding, professionals directory stays demo data by explicit decision, and tier-two features in scope), the mandatory safety boundaries, and the build order.

State as of 1 September 2026: Batches 1–10 done and verified; Batch 7 complete (184 clips, Chrome matrix confirmed); Batch 11 part 1 done (all 36 states + FCT verified against the 19 Aug 2026 NEMSAS list, table in `docs/emergency_resource_verification.md`); Batch 12 automated tests done (39 passing, user-confirmed); Batch 13A live at `tor3x-coder.github.io/mindmate` (logo, favicon, working /delete-account form); Batch 13 underway — signed release APK v1.0.0 built and running on real phones after the `1fc3ef8` identity fix.

Build order for 1–10 September: **Learn section → demo seeding script → weekly insight (Progress) → daily local-notification reminder → multi-phone device matrix + 4 landing screenshots → honest-limits slide + five-question answer sheet.** Verify-or-complete: GitHub Release upload of the final APK and the landing `config.js` live-download flip (see the handoff block in `MINDMATE_STATUS.md`).
