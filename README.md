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
- trusted contacts, support-event tracking, and expanded emergency-resource UI.

They are **not yet considered release-complete**. The final Batch #5 Firestore rules compiled and were released successfully to Firebase project `mindmate-app-fcf2d` on 22 August 2026. Local dependency resolution and static analysis also passed with 0 errors, 0 warnings, and 21 non-blocking informational notices.

A repository audit confirmed a major missing experience: **there is currently no guided audio**. There are no audio assets or playback/TTS dependency; Meditation uses timed written guidance, Breathing uses visual/text cues, and the Sound setting is a placeholder. The guided-audio MVP is now competition-critical in `MINDMATE_REMAINING_BATCHES.md`.

Flutter tests/builds, Firestore denial tests, live Worker deployment, end-to-end device testing, and emergency-resource verification remain pending or unconfirmed. See `MINDMATE_STATUS.md` for the exact status table.

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

- Firebase email/password registration and login;
- password visibility and password reset;
- Terms and Privacy acknowledgement during registration;
- illustration onboarding carousel;
- goals and preferred check-in window;
- session persistence through Firebase Auth;
- light/dark/system theme, text-size, and animation preferences;
- bottom navigation: Home, Practice, Chat, and Me.

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
- activity feedback is saved to owner-only `feedback_records`.

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

Current limitation: meditation and breathing have no spoken guidance or ambient audio. Captions/timers exist, but the Sound preference does not yet control a real audio system.

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

- Cloudflare Worker shields the AI provider binding from Flutter;
- structured modes: Listen, Calm me, and Make a plan;
- recent-history role validation and size limits in Flutter and the Worker;
- deterministic crisis route before AI generation;
- friendly unavailable and quota states;
- generic client-safe errors with structured server logs;
- optional Cloudflare rate-limit binding;
- optional KV usage counter;
- environment-variable AI model selection.

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

## Planned beyond the immediate prototype

- authoritative server-side one-pending-appointment enforcement;
- stricter appointment field validation in Firestore rules, including pending-only creation and restricted mutable fields;
- professional Firebase accounts and provider roles;
- provider inboxes, notifications, verified identity, availability, and calendars;
- persistent chat sessions and history;
- opt-in journal AI reflection;
- account profile recovery/registration rollback;
- privacy export and deletion controls;
- notification scheduling;
- clinician/wellness review of CBT, meditation, breathing, AI, and crisis wording;
- community features only after a moderation plan exists.

## Release gates

Before a public or competition build:

- keep the currently clean Flutter analysis result and run tests plus Android builds;
- implement and real-device-test the approved guided-audio MVP;
- test the deployed Firestore rules and redeploy after any rule change;
- confirm/deploy the current Worker source;
- test all owner/admin denial cases;
- test every AI mode, safety route, limit, and failure state;
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
  illustrations/ Onboarding and app illustrations
  models/        3D meditation guide assets
worker/
  index.js       Cloudflare AI Worker source
  README.md      Worker setup and deployment guide
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

The final Batch #5 `firestore.rules` file compiled and was released successfully to Firebase project `mindmate-app-fcf2d` on 22 August 2026. Emulator/denial testing is still required, and every future rule change must be redeployed.

Review and test `firestore.rules`, then deploy changes with:

```bash
firebase deploy --only firestore:rules
```

Queries combining `where()` and `orderBy()` may need composite indexes. Known examples include user appointment history (`uid`, `requestedAt`) and thought-record history (`uid`, `date`). Follow the Firebase error link to create the exact required index when testing.

Do not mark a future rule revision as deployed until the command succeeds against the intended Firebase project. Deployment alone does not replace owner/admin denial tests.

## Cloudflare Worker

The Worker source is `worker/index.js`. See `worker/README.md` for:

- the endpoint;
- `AI`, `AI_MODEL`, `MINDMATE_RATE_LIMIT`, and `MINDMATE_METRICS` configuration;
- manual deployment steps;
- logging and fallback behavior;
- the final model decision still pending.

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
