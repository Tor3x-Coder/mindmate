# MindMate handoff for a new chat

**Last updated:** 23 August 2026

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
- optional rate-limit and metrics bindings;
- environment-variable model switching.

Still required:

- confirm/deploy the live Worker version;
- test every mode and failure path;
- complete adversarial and qualified human safety review;
- make the final AI model choice after testing.

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
- The illustration onboarding carousel is confirmed.
- Splash/illustration-first screens are excluded from further redesign.
- Existing Login/Register screens are intentionally left as-is unless a functional bug is found.

## Important implementation details

- **Guided audio is competition-critical and now has a pilot.** Quick Reset has a separate welcome, 4 main prompts, and 4 short reassurance cues with matching captions; Box has an intro, 4 concise phase cues, and completion. Meditation plays at `0.88x`, Breathing at `0.92x`, and all 15 MP3s total about 370 KB. The new 8-cue timeline needs Chrome confirmation.
- **Approved full audio scope:** one consistent natural narrator with unique words for all 18 meditation sessions, segmented prompts for 1/3/5-minute choices, unique guidance for all 3 breathing patterns, one short guide per Daily Snapshot stage, and 3 safe Wellness Result band narrations. Keep intentional quiet between concise cues. Literal breathing loops are rejected for now; future calm ambience must be optional, licensed, loop-safe, independently volume-controlled, and duck under narration.
- **Floating Tide Orb navigation is implemented, polished, and Chrome-validated:** four lower-positioned destinations, slower 520ms-base glide, restrained hop, visible labels, semantics, reduced-motion support, and existing IndexedStack state preservation.
- **First-use guide is implemented and Chrome-validated:** four coach marks for Home, Practice, Chat, and Me with Skip/Next/Got it, `tourVersion = 1` persistence, Settings replay, and a lightweight Flutter-drawn 2D figure. Automatic display is requested only after new-user onboarding; Login/Splash do not force it. It never appears on Emergency Support or autoplays speech. Fresh-account and physical-device release checks remain.
- **Quiet Tide Modern shell is focused, not a full redesign:** global app bars use consistent height/spacing and no scroll tint/elevation. The user confirmed the combined shell works; child-screen polish remains intentionally deferred.
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
8. **Batch 9B runtime reliability (local, validation pending)** — bounded wellness scoring + 4 tests, mounted-safe appointment/dashboard async handling, friendly My Requests errors, and intentional ISO-string migration deferral.

Important: deletion interruption/retry and missing-profile restoration evidence remain. The project is on Spark, so a trusted Cloud Function is deferred unless billing is upgraded.

## Remaining backend/release work

Immediate prototype path:

1. Run Batch 9B Flutter analyze/tests and verify the new model tests pass.
2. Keep deletion interruption/retry and missing-profile restoration in the release matrix.
3. Keep the external `/delete-account` web request path as a Google Play blocker.
4. Confirm/deploy `worker/index.js`, configure required bindings, test the live endpoint, and make the final AI model decision.
5. Verify emergency resources and sensitive content.
6. Run meaningful automated tests plus the complete device test matrix.
7. Build a release candidate APK and freeze nonessential features.

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
- Wellness caps/tests and My Requests friendly errors are implemented locally; Flutter validation is pending.
- Some screens still have hardcoded legacy colours.
- Current analyzer debt is non-blocking: 2 deprecated onboarding Radio API notices and 19 optional `const` notices.
- Post-audio `flutter pub get` reports 27 newer package versions outside current constraints; avoid major upgrades before the competition unless required and tested.
- Some service comments are stale and can be cleaned during a controlled pass.

## Competition

- Competition: 11 September 2026.
- Target feature freeze: 28 August 2026.
- Current handoff date: 23 August 2026.
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

Batch 9B reliability fixes are implemented locally. Run Flutter analyze/tests and confirm all 5 tests pass (the original smoke test plus 4 wellness-boundary tests). Keep deletion retry/recovery and the landing site's `/delete-account` request path open.
