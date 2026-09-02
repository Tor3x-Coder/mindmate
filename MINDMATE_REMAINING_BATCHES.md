# MindMate remaining batches and competitive audit

**Last updated:** 2 September 2026
**Status:** Planning document; no app-code change is approved by this document.  
**Source of current implementation status:** `MINDMATE_STATUS.md`

## Why this document exists

This file divides the remaining work into controlled batches, records the guided-audio gap, and gives future chats one ordered plan. It should be updated whenever a batch changes, starts, or finishes.

The immediate objective is not to copy every mature wellness app. It is to deliver one polished, safe, reliable competition journey:

```text
Check in
  -> understand the need
  -> recommend one small action
  -> guide the action
  -> ask whether it helped
  -> offer another action or human support
```

## Confirmed guided-audio gap

Repository inspection on 22 August 2026 confirmed:

- there are no `.mp3`, `.wav`, `.m4a`, `.aac`, `.ogg`, or `.flac` assets;
- `pubspec.yaml` has no audio playback or text-to-speech package;
- Meditation currently rotates written guidance on a timer;
- Breathing currently provides animation, text, and countdown cues;
- the saved Sound preference is only a placeholder and says guided audio will be available later;
- the app therefore has no spoken meditation, breathing cues, ambient audio, pause/resume playback, or audio lifecycle handling.

Guided audio is now a **competition-critical gap**, not an optional post-competition item.

## Competition-critical batches

Do these in order. Do not start several batches at once.

### Batch 6 — Baseline test and build gate — compile gate passed

**Purpose:** Prove the recovered app works before adding audio or changing backend behavior.

Current result: `flutter test` passed its single smoke test and `flutter build apk --debug` created the debug APK successfully on 22 August 2026. Emulator and physical-device runtime checks remain pending.

Tasks:

1. Pull the current active branch.
2. Run `flutter test`.
3. Run `flutter build apk --debug`.
4. Open the app in an Android emulator if the PC can support one.
5. Fix only blocking test/build/startup problems.

Already complete:

- `flutter pub get` succeeded;
- `flutter analyze` completed with 0 errors, 0 warnings, and 21 informational notices;
- `flutter test` passed its single smoke test;
- `flutter build apk --debug` completed successfully in 159.6 seconds.

Current device constraint:

- the developer does not have a physical Android phone. Chrome can cover broad UI/Firestore behavior, and an Android emulator can cover most Android startup/runtime checks. Real-device-only behavior must be tested later on a borrowed or competition device.

Exit criteria for moving to Batch 7:

- debug APK builds;
- app opens in an Android emulator if one is practical;
- if no emulator is practical, the APK build passes and the runtime/device risk is explicitly documented;
- results are recorded in `MINDMATE_STATUS.md`.

Release still requires a physical-device check; this constraint is deferred, not waived.

### Batch 7 — Full natural-voice guidance

**Status (26 Aug 2026):** Sub-batches 7A–7D are complete — all 3 breathing patterns, all 18 meditation sessions, 4 Daily Snapshot stage guides, and 3 Wellness Result band narrations have unique offline narration (184 MP3s, one consistent narrator, pilot 15 re-voiced), wired with matching captions and replay/mute controls, and the asset audit passed 184/184. Only 7E (playback matrix) remains.

**Purpose:** Turn Meditation, Breathing, and Daily Snapshot from mainly visual/text experiences into consistently voiced guidance.

#### Approved direction

The user selected:

- one consistent natural MindMate narrator across the app;
- unique words/scripts for every meditation session and breathing pattern;
- segmented meditation prompts that remain correctly spaced for 1, 3, and 5-minute choices;
- short voice guidance for each major Daily Snapshot step;
- one of three safe Wellness Result narrations selected by the existing steady/mixed/heavier score bands;
- written captions, replay, and mute controls throughout.

Natural pre-recorded audio will not read an arbitrary score or generated insight word-for-word. Result narration must avoid diagnosis and fake precision. The screen still displays the actual reflection; audio gives a short band-appropriate response and next-step invitation.

#### Current pilot checkpoint

Implemented for validation before mass generation:

- shared offline `just_audio` service/provider;
- real Sound preference behavior in supported sessions;
- one approved calm feminine narrator;
- Quick Reset welcome, 4 main prompts, and 4 unique midpoint reassurance cues scheduled across 1/3/5 minutes;
- Box Breathing introduction, separate concise inhale/full-hold/exhale/empty-hold cues, and completion;
- preview, pause/resume, replay, mute, text fallback, source serialization, and stop-on-exit controls;
- 15 MP3s totaling 379,299 bytes (about 370 KB).

Do not generate the remaining narration until the new 8-cue timeline passes analyzer/build and Chrome timing checks.

#### Sub-batch 7A — Audio foundation and voice identity — Chrome-validated; physical-device check pending

- audition and approve one narrator;
- add the chosen local audio-playback dependency;
- define an audio service/controller with one active playback source;
- connect the existing Sound preference to real behavior;
- add replay/mute/play-pause controls where appropriate;
- stop and dispose audio on exit, completion, navigation, and interruption;
- keep all narration assets offline for reliable demos.

#### Sub-batch 7B — Three unique breathing guides — COMPLETE (26 Aug 2026)

Each breathing pattern gets its own wording and pacing rather than a recycled cue set:

- Box Breathing;
- 4-7-8 Breathing;
- Simple Calm.

Phase cues must stay synchronized with the timer. Guidance should be calm and concise so repeated cycles do not become noisy or annoying.

Result: all three patterns recorded with unique intro/phase/completion cues; phase cue durations verified against timer intervals (Box 4s phases 2.0–3.4s raw; 4-7-8 3.2–3.9s raw; Simple Calm 2.6–3.5s raw); wired into the breathing screen; asset audit passed.

#### Sub-batch 7C — All 18 meditation sessions — COMPLETE (26 Aug 2026)

- every existing meditation session gets its own natural-voice prompt set;
- each prompt set follows that session's existing purpose and written guidance;
- segmented prompts are scheduled across 1, 3, or 5 minutes with natural quiet between them;
- a single session never overlaps or restarts another clip accidentally;
- selecting a different session uses different words, not a generic narration reused under another title.

This means 18 distinct narrated experiences, not only one flagship session per category.

#### Sub-batch 7D — Daily Snapshot and Wellness Result — COMPLETE (26 Aug 2026)

Implemented: one short guide per stage (Body/Mind/Routine/Review) played once per stage entry; replay + mute icon controls above the snapshot Continue bar; one safe band narration for steady (>= 70), mixed (40–69), and heavier (< 40) on the result screen with replay/mute, stop-on-exit, and no score read-out or diagnosis language.

Original scope:

When Sound is enabled:

- play one short guide once for each major Daily Snapshot stage: Body, Mind, Routine, and Review;
- do not automatically read every answer choice or repeat audio after every tap;
- provide a replay and mute control;
- after Save, play one safe result narration for:
  - steady day;
  - mixed day;
  - heavier day.

The result voice must not say the score is a diagnosis, medical assessment, or certainty. It should thank the user, reflect the broad band gently, and point to the displayed next step.

#### Sub-batch 7E — Audio validation — Chrome COMPLETE (26 Aug 2026); physical device remains a release gate

Completed:

- all 184 assets are declared and included in successful Android/Web builds (dev machine: 0 analyzer errors/warnings, 9/9 tests);
- the full Chrome playback matrix passed (user-confirmed 26 Aug 2026): new meditation timing/captions/replay-mute, 4-7-8 phase-cue sync, Daily Snapshot stage guides, and Wellness Result band narrations.

Still required:

- test with an Android emulator later;
- test physical-device interruption/routing when a device becomes available;
- record any behavior that remains unverified because no phone is available.

#### Exit criteria

- Sound setting controls real behavior;
- all 18 meditations have distinct natural narration;
- all 3 breathing patterns have distinct synchronized guidance;
- all 4 Daily Snapshot stages and 3 result bands have appropriate guidance;
- only one clip/source plays at once;
- leaving a screen stops/disposes playback correctly;
- captions and silent use still work;
- analyzer/tests/build pass;
- Chrome check passes;
- emulator check passes when available;
- physical-device audio remains a documented release gate until tested.

#### Later ambience expansion

Calm background music/ambience is approved only as a later optional layer. It must be licensed for distribution, loop seamlessly, have a separate volume/off control, duck under spoken guidance, and never be required. Literal human breathing loops are rejected for now because they can feel intrusive and complicate phase timing. Multiple narrator choices, localization, and longer recordings remain post-competition work.

### Batch 7.5 — Floating navigation + contextual guide

#### Floating Tide Orb — implemented and Chrome-validated

- replaces the standard Material NavigationBar without changing the four destinations;
- glides/hops softly between Home, Practice, Chat, and Me;
- keeps visible labels and selected icon changes rather than relying only on colour;
- preserves tab state through the existing IndexedStack;
- honors browser/device reduced-motion settings and app animation intensity;
- includes semantics, keyboard focus, hover, and responsive segment positioning;
- uses pure Flutter drawing and adds no image asset weight.

#### Contextual first-use guide — implemented and Chrome-validated

**Purpose:** Help new users understand the app without adding another long onboarding carousel or a distracting permanent mascot.

Implemented behavior:

- four small contextual coach marks: Home, Practice, Chat, and Me;
- one message at a time with clear `Got it`, `Next`, and `Skip tour` actions;
- spotlight the relevant tab/action without blocking normal navigation;
- store a local `tourVersion` so the tour runs once for new users and can be intentionally reset after major navigation changes;
- add `Replay app tour` in Settings;
- use a lightweight 2D MindMate figure drawn with Flutter widgets/CustomPainter, adding effectively no image-asset weight;
- honor reduced-animation/animation-intensity preferences;
- provide accessible semantics and keep text usable without animation;
- never auto-show on Emergency Support;
- never autoplay spoken guidance; a future tap-to-hear control is optional.

Exit criteria:

- existing users are not forced into the tour;
- new users can skip immediately;
- completed/skipped state persists;
- replay works from Settings;
- coach marks do not cover their target or critical controls at supported widths;
- analyzer/tests/Web and Android builds pass.

Validation status:

- user confirmed the lower/slower navigation, labels, tab behavior, tour controls, Settings replay, and combined shell work in Chrome;
- keep a fresh registration/onboarding trigger check and physical-device layout in the release matrix;
- keep child-screen redesign deferred until higher-priority integrity/reliability work is complete.

### Batch 8 — Firestore integrity and authorization tests — validated and deployed; live smoke pending

**Purpose:** Close the most important prototype security gaps without touching live data until authorization tests pass.

Implemented:

1. Appointment creation requires an exact known schema, caller-owned UID, and `status == 'pending'`.
2. Allowed statuses are pending/approved/declined.
3. Appointment details are immutable; admins may change status only; owners cannot self-approve.
4. User profile rules handle missing `isAdmin` safely and prevent self-promotion/email changes.
5. Trusted contacts have strict fields and immutable UID/createdAt.
6. Support events are owner-only and append-only (owners may read/delete, not rewrite).
7. Service methods reject non-pending creates and invalid status values before contacting Firestore.
8. A 13-case Firebase Emulator suite covers owner, cross-user, self-admin, pending-only, status-only, trusted-contact, and support-event behavior.

Validation result:

- Java 21 Firestore Emulator suite: **13/13 passing in 12 seconds**;
- expected attack writes produced `PERMISSION_DENIED` and counted as passing denials;
- `flutter analyze`: 0 errors, 0 warnings, 4 informational notices;
- `flutter test`: 1 smoke test passed.

Deployment result:

- `firestore.rules` compiled successfully;
- rules were released to Cloud Firestore;
- Firebase CLI reported `Deploy complete` for `mindmate-app-fcf2d`.

Pending:

1. Live-smoke normal profile/contact/request/admin flows.
2. Confirm no expected user flow receives permission denied.
3. Close Batch 8 and move to Batch 9.

Deferred limitation:

- authoritative one-pending-request uniqueness needs a trusted backend transaction/Cloud Function or deterministic key design. The current read-then-write client guard is not authoritative.

Exit criteria:

- rule tests pass;
- changed rules compile and deploy;
- denial cases are manually confirmed against the intended project.

### Batch 9 — Account and runtime reliability — implemented work validated

**Purpose:** Fix account lifecycle failures and provide permanent user-controlled deletion.

#### Sub-batch 9A — deletion and account recovery

Implemented locally for the Firebase Spark plan:

- in-app Settings → Privacy and data → Delete account path;
- type `DELETE`, password reauthentication, and irreversible confirmation;
- repeatable 200-document batches for all UID-owned collections;
- profile deletion last in Firestore and Firebase Auth deletion last overall;
- local pending marker and Splash retry route after interruption;
- missing-profile screen with Restore setup or Delete account;
- Login/Splash checks for missing/incomplete profiles;
- registration rollback if profile creation fails;
- passwords are never trimmed;
- local preferences clear only after confirmed deletion;
- owner-profile-delete rule and emulator allow/deny coverage.

Architecture note:

- trusted Cloud Function deletion remains preferable but needs Blaze;
- Spark-compatible client deletion is repeatable, not falsely described as atomic;
- Google Play requires both the in-app path and a functional external web deletion request resource.

Sub-batch 9A validation result:

- updated Firestore Emulator suite: **13/13 passing**;
- owner profile deletion allowed and cross-user deletion denied;
- Flutter analysis: 0 errors, 0 warnings, 4 informational notices;
- smoke test passed.

Deployment/runtime result:

- Firebase compiled/released the tested owner-profile-delete rule delta;
- a disposable account successfully deleted its stored data/profile/Auth login and returned to onboarding.

Sub-batch 9A pending:

1. Keep interruption/retry behavior in the release matrix; do not deliberately use the real/admin account.
2. Confirm missing-profile restoration and incomplete-onboarding routes.
3. Keep the external deletion-request web resource as a release blocker.

#### Registration contrast + Daily Snapshot/light-default reliability fix — Chrome-validated

- registration Name/Email/Password match Login's dark 16px input style;
- onboarding goals/reminder choices use readable theme surface text;
- first-run and post-deletion reset default to Light; Dark/System remain optional;
- wellness screens use theme-aware ink/surfaces instead of mixed hardcoded colours;
- progress is 8 real units: Body + 5 Mind questions + Routine + Review;
- user confirmed Mind 5/5 displays Step 6 of 8 / 75% and the full flow works.

#### Sub-batch 9B — runtime reliability — implemented locally

- clamps wellness sleep/stress components and final score to 0–100;
- adds 4 focused score tests, including malformed extreme values;
- moves appointment duplicate-check network failure into the mounted-safe friendly handler and disables double submission while checking;
- catches legacy Dashboard profile/admin loading failures;
- replaces raw Firestore error output in My Requests with a private friendly state;
- uses theme surfaces in My Requests;
- intentionally freezes ISO date strings for the prototype.

ISO migration decision:

- do not rewrite dates before the competition;
- a later migration must dual-read ISO String and Firestore Timestamp;
- backfill existing records before switching all writes/queries;
- remove legacy reads only after verification.

Sub-batch 9B validation result:

- `flutter test`: **5/5 passing**;
- `flutter analyze`: 0 errors, 0 warnings, 4 informational notices.

Remaining release-matrix evidence:

1. Smoke appointment duplicate-check failure and My Requests error state under weak/offline network when practical.
2. Keep broader device/network interruption coverage in Batch 12.

Exit criteria:

- normal deletion path remains proven and retry/recovery remains tracked;
- no analyzer errors/warnings;
- wellness model tests pass;
- external `/delete-account` web request remains an explicit Play release gate.

### Batch 10 — AI Worker live completion — validated, deployed, and verified live

**Purpose:** Make the repository Worker and live Worker match, then verify safety and reliability.

Implemented, deployed, and verified on 25 August 2026:

- transparent AI identity; no human/therapist claims;
- final default `@cf/meta/llama-3.3-70b-instruct-fp8-fast` with `AI_MODEL` override;
- Worker body/message/mode/history validation and Flutter-side matching caps;
- single trusted system prompt; injected roles/modes discarded;
- crisis response before limiter/model generation;
- current Cloudflare limiter API and friendly 20/60-ready fallback;
- max 220 output tokens;
- safe quota/provider/missing-binding/empty-reply handling;
- request ID/no-store headers and message-free structured logs;
- versioned `GET /health` endpoint;
- 12/12 Worker tests passing;
- 4 Flutter ChatService tests added (9/9 total tests passing, 0 analyzer errors);
- live deployment to Cloudflare Worker `mindmate-ai-chat.tor3x-akachukwu.workers.dev`;
- verified live `/health` returning version `2026-08-23-batch10` and default model `@cf/meta/llama-3.3-70b-instruct-fp8-fast`;
- verified live responses for `make_plan`, `calm`, and immediate deterministic human crisis routing.

### Batch 11 — Safety, content, and resource verification — PART 1 COMPLETE (26 Aug 2026)

**Status:** Resources verified — all 36 states + FCT now listed and matched 1:1 against the NEMSAS state call-centre list published 19 Aug 2026 (15 states added, incl. Lagos 767); 112 confirmed as the national fallback (NCC/FG); 9 international lines verified against standard references; findahelpline.com confirmed live; professional directory now carries a "Demo data" banner; unlisted-state behaviour documented (all listed + 112 safety net). Full table: `docs/emergency_resource_verification.md`. Remaining: device pass for `tel:`/`sms:`/browser actions (with Batch 12), fresh re-verification before any public release, and the qualified-reviewer wording review (documented limitation).

**Purpose:** Verify the content people may rely on during distress.

Tasks:

1. Recheck every emergency number and operating-status note against current authoritative sources.
2. Recheck every external helpline/resource URL.
3. Confirm what happens for an unlisted Nigeria state/country.
4. Test all `tel:`, `sms:`, and browser actions on Android.
5. Review CBT, meditation, breathing, AI, and emergency wording with a qualified mental-wellness reviewer if available.
6. Ensure professional listings are verified or clearly labeled as prototype/demo data.
7. Review Terms and Privacy wording and disclose stored data accurately.

Exit criteria:

- each public emergency resource has a source and verification date;
- unverified resources are removed or clearly blocked from release;
- support actions work on a real device;
- review limitations are documented honestly.

### Batch 12 — Meaningful automated and device testing — automated tests DONE (26 Aug 2026); device matrix pending

**Status:** 31 new automated tests added (4 files) covering model serialization for sensitive records, the mood→recommendation logic, Wellness Result band behaviour, and audio lifecycle guards (see `test/`). Device matrix (account flows, `tel:`/`sms:` launches, audio interruptions, weak/no network, themes) runs on the competition phone during the release pass.

**Purpose:** Replace the current trivial smoke test with protection for the demo journey.

Current test limitation:

- `test/widget_test.dart` only renders a `MaterialApp` containing the word “MindMate.” It does not test the real app or any user flow.

Tasks:

1. Add model serialization tests for sensitive records.
2. Add recommendation/feedback logic tests.
3. Add widget tests for critical empty/error states and key controls.
4. Add audio controller/lifecycle tests where practical.
5. Run the complete Android test matrix:
   - account creation/login/profile edge cases;
   - mood + impact save;
   - recommendation + feedback save;
   - CBT save;
   - appointment request/history/admin action;
   - duplicate-request guard;
   - trusted-contact CRUD and call/message launch;
   - support-event follow-up;
   - emergency location/resource actions;
   - AI modes and failures;
   - audio controls and interruptions;
   - dark/light/system themes;
   - larger text and reduced animation;
   - weak/no network.

Exit criteria:

- automated tests pass;
- no critical crash or blocked demo path;
- known non-blockers are documented with severity and workaround.

### Batch 13 — Competition release and feature freeze

**Purpose:** Produce the exact build that will be demonstrated.

Tasks:

1. Confirm app name, icon, version, and package identity.
2. Confirm Android signing and build configuration.
3. Build/install the release candidate APK.
4. Prepare safe demo accounts and data.
5. Rehearse the core journey repeatedly.
6. Test on the actual competition phone and network conditions.
7. Prepare an offline fallback demonstration if AI/network is unavailable.
8. Freeze features; accept only critical fixes afterward.
9. Record APK checksum/version and final deployed backend versions.

Exit criteria:

- release candidate installs and runs;
- the complete demo journey works repeatedly;
- backend versions and test evidence are documented;
- rollback/demo fallback is ready.

### Optional Batch 13A — Competition landing page — IN PROGRESS (26 Aug 2026)

**Status:** site implemented in `landing/` (vanilla HTML/CSS/JS, no build step): index (hero, loop, features, screenshot frames, safety/privacy, FAQ, honest APK download card, QR) + `/delete-account/` page (identity, exact deletion list, in-app steps, external request flow). Hosting chosen: **GitHub Pages** (folder `/landing`). Deletion flow chosen: **hosted form (Google Form/Tally) + support email** — form URL and email pending from the user. Identity: "MindMate by Junior Achievers — FG Enugu (JA FGCE)" (all credits to the team, no individual credit). APK download card is config-driven (`landing/assets/js/config.js`) and honestly shows "release build being prepared" until Batch 13's signed APK metadata is filled in. Real screenshots pending from the user. Not yet deployed.

**Purpose:** Give judges and early users a fast, polished explanation of MindMate and a safe way to download the Android demo.

This is a useful competition asset, but it must not delay audio, safety, testing, or the release candidate. Build it after the app's visual/content claims are stable so screenshots and feature copy are accurate.

Approved direction:

- use the supplied Spouse Finder page only for layout, interaction, and visual inspiration;
- replace all branding, copy, colors, images, fake phone content, claims, FAQ, navigation, and CTAs with truthful MindMate material;
- build a lightweight static informational site in a separate `landing/` directory;
- do **not** expose or host the Flutter app as a browser product;
- do **not** include app Sign In/Register or route visitors into Flutter Web;
- provide product information, the check-in-to-action loop, real screenshots, safety/privacy boundaries, FAQ, installation help, and an APK download button;
- include a prominent functional `/delete-account` resource where former users can initiate account/data deletion without reinstalling the app;
- identify the app/developer, explain what is deleted, and use a real support form/email workflow—not placeholder copy;
- link only a signed, versioned release APK—not `app-debug.apk`;
- add release version, file size, SHA-256 checksum, minimum Android requirement, and honest sideload instructions when known;
- optionally add a QR code pointing to the landing page;
- keep it responsive, accessible, and fast on weak connections.

Technical note:

- keep `web/index.html` only as the Flutter Web shell used for development/testing; it is not the public landing page;
- use a separate landing-page deployment target;
- keep APK binaries out of ordinary Git history; a release-asset host such as GitHub Releases is preferred, but the final hosting choice is not yet approved;
- Firebase Hosting is not currently configured in `firebase.json`, so hosting configuration and destination must be explicitly approved.

Exit criteria:

- every claim matches the shipped prototype;
- no diagnosis/therapy/emergency-service claim;
- no broken download, privacy, support, or deletion-request link;
- `/delete-account` works without requiring the app to be reinstalled;
- responsive desktop/mobile checks pass;
- Lighthouse-style accessibility/performance checks are acceptable;
- deployed URL and hosting configuration are documented.

## Approved additions — decided 1 September 2026 (pre-competition, in scope)

Agreed with the developer on 1 September 2026, to be built during the 1–10 September window:

1. **Learn section (Option B — featured card on Home) — expanded locally 2 September 2026; validation pending.** Home now has a card between the Wellness card and Quick starts. The Learn screen groups sixteen core reads (the six foundational articles plus ten approved everyday, relationship, difficult-moment, and urgent-help scenarios) into four sections: Everyday life, Love and people, Understanding difficult moments, and Getting help. Explore more contains eight additional bundled scenario reads with search and Add to Learn persistence in local preferences. Every reader has a conversational heading style, an existing-tool next step, a general-information boundary, and an Ask MindMate about this action. The selected article is sent as bounded reference context to ChatService and the Worker; the source Worker version is `2026-09-02-learn-context`, but Worker deployment is intentionally deferred because it was not part of this code-only batch. Flutter/Worker reruns, Android/Web builds, Chrome/device validation, and health-literate review of articles 3–4 remain open; live Worker context smoke belongs to a separately approved deployment.
2. **Demo account via Admin SDK script.** Register the demo account through the app, then a one-off Node + Firebase Admin SDK script (service-account key, git-ignored, never committed) seeds ~3 weeks of realistic history with the exact production schemas (mood_logs with word-based impact, meditation_history, breathing sessions, journal_entries, thought_records, feedback_records). Repeatable/tweakable.
3. **Weekly insight on the Progress screen.** A "Your week" summary computed from existing stored data (check-in count, hardest day, practices that followed low moods). Read-only; no new storage.
4. **Working daily reminder.** The reminder-time setting already exists; add a local notification (flutter_local_notifications, no internet needed) that actually fires. New dependency + permission — test on the team's phones.
5. **Multi-phone device matrix + screenshots.** The team's phones are the device fleet: run the Batch 12 device matrix across 3–4 phones/networks and capture the 4 landing-page screenshots (Home, Practice mid-session, Daily Snapshot, Emergency Support).
6. **Honest-limits slide + five-question answer sheet** for the team (difference vs Wysa; how do you know it works; what if the emergency number isn't answered; what stops the AI saying something harmful; why trust the data). Written in full sentences for internalization, not fragments.

**Professionals directory decision (1 September 2026): Option two — keep clearly-labeled demo data.** The team has no real professional contacts; cold-outreach to strangers days before the competition is an ethics and timing risk. The existing "Demo Data" banner stays; the honest-limits slide states plainly that listings are samples, the request flow + duplicate guard + admin review are built and security-tested, and real consented providers join post-competition with verification.

## Post-competition production batches

These are important for a real product but should not displace the competition-critical sequence.

### Batch 14 — Real professional platform

- professional accounts and roles;
- verified provider identity;
- provider inbox;
- availability/calendar;
- provider approval/decline;
- notifications and audit trail;
- authoritative appointment constraints.

### Batch 15 — Long-term privacy and account controls

- account deletion;
- data export;
- granular consent;
- data retention policy;
- profile repair/registration rollback;
- security review and audit logging.

### Batch 16 — Persistent AI and journal features

- persistent chat sessions;
- past-chat screen;
- user-controlled deletion;
- explicit opt-in journal reflection;
- strict selection of which journal text is shared;
- cost/abuse controls.

### Batch 17 — Content and engagement scale

- full natural narration library;
- multiple meditation lengths;
- ambient soundscapes and optional downloads;
- scheduled check-in reminders;
- deeper pattern insights;
- content management/versioning;
- clinically reviewed programmes;
- community only after a moderation plan exists.

## Competitive product audit

This is a subjective product/UX comparison, not a clinical rating or proof of effectiveness.

### Reference products

- Headspace emphasizes a large expert-led library, guided meditation audio, sleep resources, focus audio, coaching, and therapy: https://www.headspace.com/content
- Calm emphasizes guided meditation, breathing, extensive Sleep Stories, music, and soundscapes: https://www.calm.com/
- Wysa combines conversational AI, evidence-based exercises, crisis escalation, and optional human support in some offerings: https://www.wysa.com/ai-self-help
- Finch uses a virtual self-care pet, small goals, mood checks, journaling, breathing, and rewards to drive daily engagement: https://apps.apple.com/us/app/finch-self-care-pet/id1528595748
- Daylio specializes in fast mood/activity logging, correlations, charts, goals, reminders, backup, and export: https://daylio.net/

### Provisional grade today

| Area | Grade | Reason |
|---|---:|---|
| Product idea and differentiation | A- | Strong action-first loop plus self-help, AI, feedback, and human-support escalation. |
| Core check-in-to-action journey | A- | Clear and more actionable than a mood log alone; still needs device verification. |
| Feature breadth | B+ | Mood, practices, CBT, journal, progress, AI, professionals, emergency support, and feedback are connected. |
| Guided meditation/breathing experience | D+ | Visual/text guidance exists, but there is currently no spoken audio or ambient sound. |
| AI design | B- | Structured modes and safety architecture are promising; live deployment and adversarial testing are unconfirmed. |
| Tracking and insights | C+ | Logs and gentle insights exist, but analytics, correlations, export, and long-term personalization trail specialists. |
| Retention and habit design | C+ | Gentle achievements exist, but there is no strong daily motivation loop comparable to a mature habit product. |
| Human-support path | B | Trusted contacts, emergency routes, directory, and requests are a strong concept; provider infrastructure is not real yet. |
| Safety/privacy architecture | B- | Owner rules and explicit-contact behavior are good; rule tests, resource verification, deletion/export, and clinical review remain. |
| Reliability evidence | C+ | Analyzer is clean and rules compiled/deployed, but tests, APK build, and end-to-end device evidence are pending. |
| Evidence/content maturity | D+ | No clinical validation, large expert content library, or professional narration programme yet. |
| Competition readiness | B | Strong concept and breadth; audio, testing, live Worker confirmation, and release proof are the main blockers. |
| Mature-market readiness | C | Promising early beta concept, but not yet comparable to years of content, evidence, operations, and reliability. |

### Overall assessment

- **As a competition prototype today:** approximately **B / 7–8 out of 10**.
- **Against mature commercial wellness apps today:** approximately **C / 5–6 out of 10**.
- **If Batches 6–13 pass:** it could reasonably present as an **A-/strong competition prototype**, but that is not guaranteed until tests and device evidence exist.

The main lesson is that MindMate does not need 1,000 sessions to compete in a prototype. It needs one excellent, guided, safe, reliable loop. Audio and proof of reliability matter more now than adding another feature category.

## MindMate strengths

1. **Action-first positioning** — it moves from mood to one small action instead of stopping at tracking or generic content.
2. **Closed feedback loop** — the user can report whether an action helped, including worse/same/not sure rather than forced positivity.
3. **Breadth with a coherent route** — mood, CBT, journaling, meditation, breathing, AI, progress, and human support are connected.
4. **Human escalation** — emergency resources, trusted contacts, and professional requests are visible instead of burying support.
5. **Local relevance** — Nigeria-specific support is a meaningful differentiator when verified and maintained.
6. **Explicit trusted-contact control** — the app never silently calls or messages someone.
7. **AI backend separation** — provider access stays behind the Worker rather than in Flutter.
8. **Gentle tone** — achievements and feedback avoid punishment and shame.
9. **Qualitative mood impact** — words are more humane than fake numerical emotional precision.
10. **Owner-oriented Firestore design** — personal collections have UID-based access rules, with further tests/hardening planned.

## MindMate weaknesses and risks

1. **Guided audio is only a pilot** — Quick Reset and Box Breathing exist, while the approved full coverage remains unfinished and unverified at runtime.
2. **Very small content depth** — 18 short meditation outlines are far behind mature narrated libraries.
3. **No evidence programme** — content and outcomes have not been clinically validated.
4. **Minimal automated testing** — the existing smoke test does not exercise the real app.
5. **Live AI status is unconfirmed** — repository Worker features may not match production.
6. **Crisis matching is basic** — keyword routing is useful but not a complete safety system.
7. **Emergency-resource maintenance risk** — numbers can change and must be sourced, dated, and rechecked.
8. **Professional support is still a prototype** — no provider identity, provider account, availability, notifications, or provider inbox.
9. **No authoritative duplicate-request enforcement** — pending/status integrity is deployed, but the current one-pending-request client guard can still be raced or bypassed.
10. **No persistent chat history** — conversation continuity ends with the in-memory session.
11. **Weak analytics compared with tracking specialists** — no deep correlations, export, or mature history exploration.
12. **Weak retention compared with habit specialists** — no strong personalized daily routine or reward loop.
13. **Privacy lifecycle is incomplete** — in-app deletion is locally validated, but destructive testing, data export, and the external web request path remain.
14. **Account recovery needs runtime proof** — missing-profile/rollback logic passes analysis but needs temporary-account evidence.
15. **Release proof is incomplete** — post-audio Android/Web builds and latest shell behavior pass in Chrome, but the full runtime matrix, physical device, and signed release candidate remain pending.
16. **Broad scope creates maintenance risk** — many feature areas can become shallow or inconsistent if polish is spread too thin.
17. **Package upgrades are pending** — 27 newer versions exist outside current constraints, but upgrading before feature freeze could introduce breakage.

## Current execution gate

Batch 9 is locally validated. Batch 10 Worker hardening has 12/12 source tests, but the live `/health` proves the old Worker remains deployed.

Current gate:

1. run Flutter analyze/tests for ChatService;
2. deploy the full Batch 10 Worker with explicit Llama 3.3 model and 20/60 limiter;
3. verify `/health` version/model and the complete live matrix;
4. keep deletion retry/recovery, physical-device evidence, and the landing `/delete-account` resource in the release matrix.
