# MindMate

MindMate is an action-first mental-wellness companion that helps a person move from:

> “I do not know what to do right now.”

…to one small, personalised, safe next step.

Users can check in, receive a suitable guided activity, reflect privately, see patterns, talk with an AI companion, and connect with human support when self-guided tools are not enough.

MindMate is currently a competition prototype/private beta. It is not a diagnostic tool, clinical service, medical device, therapist, doctor, or emergency service.

## Project continuity documents

Read these before making changes:

1. [`MINDMATE_STATUS.md`](MINDMATE_STATUS.md) — current implementation, validation/deployment state, and exact next action.
2. [`MINDMATE_CODING_GUIDE.md`](MINDMATE_CODING_GUIDE.md) — collaboration, code, UI, safety, and documentation rules.
3. [`MINDMATE_REMAINING_BATCHES.md`](MINDMATE_REMAINING_BATCHES.md) — remaining Batches 6–17, guided-audio options, competitive audit, strengths, and weaknesses.
4. [`MINDMATE_HANDOFF.md`](MINDMATE_HANDOFF.md) — product decisions and broader handoff context.
5. [`worker/README.md`](worker/README.md) — Cloudflare AI Worker configuration and deployment.

The status file is the single source of truth. Do not infer current progress from an older chat transcript.

## Current checkpoint

Backend/integration batches 1–5 are implemented in the repository:

- Firestore owner/admin rule hardening and appointment admin support;
- qualitative mood-impact and activity-feedback persistence;
- normal-flow prevention of multiple pending requests to one professional;
- mode-aware AI Worker validation, safety routing, logging, and fallbacks;
- trusted contacts, support-event tracking, and expanded emergency-resource UI;
- local Batch 8 Firestore hardening with pending-only appointments, status-only admin updates, strict trusted/support schemas, and 13 emulator authorization tests.

They are **not yet considered release-complete**. Batch 8 passes all 13 Firestore Emulator cases, Flutter analysis has 0 errors/0 warnings, the smoke test passes, and the rules/live normal flows work on `mindmate-app-fcf2d`.

Batch 9A account deletion/recovery passes 13/13 rules tests, Flutter gates, deployed profile-delete rules, and a successful disposable-account deletion. It reauthenticates, deletes every UID-owned collection in repeatable batches, deletes profile/Auth last, preserves a retry route, repairs missing profiles, rolls back failed registration, and never trims passwords. Interruption/recovery proof and Google Play's external web deletion-request resource remain.

Batch 10 AI hardening is **deployed and verified live**: 12/12 Worker tests passed, 9/9 Flutter tests passed with 0 analyzer errors, the Worker is live at `https://mindmate-ai-chat.tor3x-akachukwu.workers.dev`, live `GET /health` reports version `2026-08-23-batch10` with default model `@cf/meta/llama-3.3-70b-instruct-fp8-fast`, and live plan, calm, and crisis safety smoke checks passed.

Guided audio has a controlled pilot: one shared offline player, separate Quick Reset welcome, 4 main prompts, 4 midpoint reassurance cues, and 6 Box assets. The 15 MP3s total about 370 KB and the user confirmed the pilot works in Chrome. Literal breathing loops are not included, and later ambience must be optional/licensed with separate volume and voice ducking.

The Quiet Tide Modern shell includes a lower/slower Floating Tide bar, consistent app-bar behavior, lightweight 2D guide, four-step first-use tour, persisted completion, and Settings replay. The user confirmed the combined shell, navigation, tour controls/replay, and 8-cue Quick Reset work in Chrome. Physical-device and fresh-registration release checks remain. See `assets/audio/README.md` and `MINDMATE_REMAINING_BATCHES.md`.

Post-audio builds/Chrome pilot, Batch 8 authorization, and Batch 9's implemented account/runtime work pass. Batch 9B has 5/5 tests and Flutter 0 errors/0 warnings. Retry/recovery and weak-network evidence remain in the release matrix; live Worker deployment, broader device testing, and emergency-resource verification are next. See `MINDMATE_STATUS.md` for exact status.

## Core experience

```text
Mood check-in
  -> understand the current need
  -> recommend one next step
  -> breathing / meditation / journaling / CBT / chat / support
  -> ask whether it helped
  -> offer another approach or human support
```

## Safety boundary

MindMate does not:

- diagnose mental-health conditions;
- prescribe medication or treatment;
- claim to be a therapist, doctor, or emergency service;
- decide whether a person is safe;
- replace qualified professional or emergency care;
- silently call or message a trusted contact.

The AI companion is for supportive conversation and reflection. Clear crisis phrases are routed through a deterministic Worker response before normal AI generation, but this implementation still requires adversarial and qualified human safety review.

## Current product features

### Account and personalisation

- Firebase email/password registration and login with matching dark, readable input text;
- readable theme-aware post-registration setup choices;
- password visibility and password reset;
- Terms and Privacy acknowledgement during registration;
- illustration onboarding carousel;
- goals and preferred check-in window;
- session persistence through Firebase Auth;
- light/dark/system theme, text-size, and animation preferences;
- custom slower/lower Floating Tide Orb navigation for Home, Practice, Chat, and Me, preserving tab state with `IndexedStack`;
- first-use four-step contextual tour with a Flutter-drawn 2D MindMate guide and Settings replay;
- Batch 9A in-app deletion/retry and missing-profile recovery with tested/deployed rules and successful disposable-account deletion;

### Mood and next-step flow

- shared mood choices and mood-aware copy;
- qualitative impact choices:
  - A little;
  - Somewhat;
  - A lot;
  - Overwhelming;
  - Not sure yet;
- one recommended action plus a small set of alternatives;
- post-activity feedback:
  - Much worse;
  - A little worse;
  - About the same;
  - A little better;
  - Much better;
  - Not sure yet;
- mood impact is saved with mood logs;
- activity feedback is saved to owner-only `feedback_records`;
- Daily Snapshot uses Body + 5 Mind questions + Routine + Review, with accurate 8-unit progress;
- wellness reflection scores are always bounded to 0–100 and remain explicitly non-clinical;
- Light is the first-run/reset default; Dark and System remain optional settings.

The current recommendation layer is still rule-based. Saved feedback does not yet train or automatically personalise an AI model.

### Guided practices

- breathing patterns: Box Breathing, 4-7-8 Breathing, and Simple Calm;
- adjustable 1, 3, and 5-minute breathing sessions;
- animated breathing figure and progress display;
- meditation journey grouped by Stress Relief, Sleep, Focus, Anxiety, Gratitude, and Morning;
- three guided sessions per meditation category;
- 3D meditation guide through `model_viewer_plus`;
- meditation history logging;
- CBT thought-reframe wizard with nine branching categories and a neutral fallback path;
- before/after thought-intensity reflection;
- owner-only CBT thought-record persistence.

Current limitation: natural spoken guidance is a pilot only—Quick Reset and Box Breathing are integrated, while the remaining sessions and Wellness flow are not. No ambient audio is included.

### Reflection and progress

- private journal create, edit, and delete;
- optional journal prompts;
- diary-style recent entries;
- effort-focused progress and achievement screens;
- rule-based mood and wellness pattern insights.

Journal AI reflection is not implemented. If added later, it must be explicitly opt-in and must not send a user's full journal history automatically.

### Human support

- professional-support directory and filters;
- professional profiles with contact and consultation details;
- request-based appointment flow;
- user request tracker;
- admin review queue with approve/decline actions;
- normal app-flow guard against another pending request to the same professional;
- Emergency Support entry point from Home;
- Nigeria nationwide/state and international location choices;
- worldwide helpline-directory link;
- owner-only trusted-contact add/edit/delete;
- user-triggered call/message actions;
- owner-only support-action and “Did you connect?” event writes.

The duplicate-appointment guard is not authoritative server-side uniqueness enforcement. The current professional directory is also not yet a full provider platform.

### AI companion

- Cloudflare Worker shields the AI binding from Flutter;
- transparently identifies as AI, never human/therapist/emergency care;
- structured modes: Listen, Calm me, and Make a plan;
- strict body/message/mode/history validation in Flutter and Worker;
- deterministic crisis route before rate limits and AI generation;
- Llama 3.3 70B FP8 Fast final default with `AI_MODEL` override;
- concise 220-token maximum model output;
- friendly unavailable, rate-limit, and quota states;
- request IDs and structured length/timing logs with no message text;
- versioned `/health` deployment verification;
- optional KV counter intentionally deferred.

Chat messages currently remain in memory while the session is open. Persistent chat sessions and a past-chat screen are future work.

## Backend collections

Current Firestore collection constants include:

- `users`
- `mood_logs`
- `journal_entries`
- `wellness_assessments`
- `meditation_history`
- `breathing_sessions`
- `professionals`
- `appointments`
- `thought_records`
- `feedback_records`
- `trusted_contacts`
- `support_events`

Personal collections must remain owner-only. Updates must preserve the original UID. Admin access must be enforced in Firestore rules, not only by hiding UI.

Prototype date storage remains ISO-8601 strings. A Firestore Timestamp migration is intentionally deferred and must later use dual-read compatibility plus a verified backfill before writes/queries switch.

## Planned beyond the immediate prototype

- authoritative server-side one-pending-appointment enforcement;
- professional Firebase accounts and provider roles;
- provider inboxes, notifications, verified identity, availability, and calendars;
- persistent chat sessions and history;
- opt-in journal AI reflection;
- privacy data export controls;
- trusted-backend deletion after a future Blaze upgrade;
- notification scheduling;
- clinician/wellness review of CBT, meditation, breathing, AI, and crisis wording;
- community features only after a moderation plan exists.

## Release gates

Before a public or competition build:

- keep the currently clean Flutter analysis result and run tests plus Android builds;
- implement and real-device-test the approved guided-audio MVP;
- verify Batch 9A interruption/retry and missing-profile restoration without risking the real/admin account;
- keep Batch 9 weak-network/retry evidence in the release matrix;
- publish a functional external `/delete-account` request resource for Google Play;
- pass Worker/Flutter AI tests, deploy Batch 10, verify `/health`, and enable the 20/60 limiter;
- test all owner/admin denial cases;
- test every live AI mode, safety route, limit, and failure state;
- verify every emergency number and external support resource against authoritative current sources;
- test `tel:`, `sms:`, and external links on a real Android device;
- complete accessibility, loading/error/empty-state, privacy, and adversarial-safety passes;
- produce and install a release candidate APK.

## Technical stack

- Flutter / Dart
- Firebase Authentication
- Cloud Firestore
- Provider
- SharedPreferences
- HTTP
- Cloudflare Workers AI
- `model_viewer_plus`
- `just_audio` for bundled guided narration
- `url_launcher`

No AI provider key belongs in the Flutter app. The app talks only to the Cloudflare Worker, where the AI binding/model is configured.

## Project structure

```text
lib/
  models/        Data classes with fromMap/toMap methods
  screens/       User flows and feature screens
  services/      Auth, Firestore, settings, and chat services
  utils/         Theme, constants, and pattern logic
assets/
  audio/         Offline guided narration and transcript/readme
  illustrations/ Onboarding and app illustrations
  models/        3D meditation guide assets
worker/
  index.js       Cloudflare AI Worker source
  README.md      Worker setup and deployment guide
firestore_tests/ Firebase Emulator authorization suite
web/
  index.html     Flutter Web and model-viewer setup
firestore.rules  Firestore authorization rules
```

## Development setup

Install Flutter and inspect the environment:

```bash
flutter doctor
```

Install dependencies:

```bash
flutter pub get
```

Configure Firebase for the intended project using FlutterFire. Review `lib/firebase_options.dart` for the target environment.

Run validation:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

Run the web app:

```bash
flutter run -d chrome --no-web-resources-cdn
```

The `--no-web-resources-cdn` flag can help when the environment cannot reach Google's CanvasKit/font CDN.

Build Android APKs:

```bash
flutter build apk --debug
flutter build apk --release
```

Typical output:

```text
build/app/outputs/flutter-apk/app-debug.apk
build/app/outputs/flutter-apk/app-release.apk
```

## Firebase deployment

Batch 8 and Batch 9A's tested owner-profile-delete delta are live on `mindmate-app-fcf2d`. Re-run emulator/Flutter gates before future rules changes, then deploy with:

```bash
firebase deploy --only firestore:rules
```

Queries combining `where()` and `orderBy()` may need composite indexes. Known examples include user appointment history (`uid`, `requestedAt`) and thought-record history (`uid`, `date`). Follow the Firebase error link to create the exact required index when testing.

Do not mark a future rule revision as deployed until the command succeeds against the intended Firebase project. Deployment alone does not replace owner/admin denial tests.

## Cloudflare Worker

The Worker source is `worker/index.js`. See `worker/README.md` for:

- the endpoint;
- `AI`, `AI_MODEL`, `MINDMATE_RATE_LIMIT`, and `MINDMATE_METRICS` configuration;
- manual deployment steps and `/health` verification;
- logging and fallback behavior;
- final Llama 3.3 model and recommended 20/60 limiter;
- the 12-case local Worker test suite.

## Web 3D model setup

For the meditation guide on Web, confirm `web/index.html` includes the required `model_viewer_plus` script:

```html
<script type="module" src="./assets/packages/model_viewer_plus/assets/model-viewer.min.js" defer></script>
```

Test the model in the actual browser/device used for the competition.

## Competition target

- Competition: 11 September 2026
- Target feature freeze: 28 August 2026

The immediate goal is one polished, reliable journey:

```text
Check in
  -> personalised next step
  -> complete/try activity
  -> save feedback
  -> alternate action or human-support route
```

Reliability is more important than adding another feature.

## Documentation rule

Every code batch or fix must update `MINDMATE_STATUS.md` and all relevant documentation in the same batch. Record:

- what changed;
- checks and results;
- deployment state;
- unresolved risks;
- the exact next action.

See `MINDMATE_CODING_GUIDE.md` for the full continuity rule.

## Brand and attribution

MindMate is currently a working name. Before public launch, check app-store names, domains, social handles, and trademarks.

Third-party model, icon, illustration, font, and asset credits must be completed before release.

