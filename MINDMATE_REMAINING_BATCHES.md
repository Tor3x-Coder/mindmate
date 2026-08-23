# MindMate remaining batches and competitive audit

**Last updated:** 22 August 2026  
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

#### Sub-batch 7B — Three unique breathing guides

Each breathing pattern gets its own wording and pacing rather than a recycled cue set:

- Box Breathing;
- 4-7-8 Breathing;
- Simple Calm.

Phase cues must stay synchronized with the timer. Guidance should be calm and concise so repeated cycles do not become noisy or annoying.

#### Sub-batch 7C — All 18 meditation sessions

- every existing meditation session gets its own natural-voice prompt set;
- each prompt set follows that session's existing purpose and written guidance;
- segmented prompts are scheduled across 1, 3, or 5 minutes with natural quiet between them;
- a single session never overlaps or restarts another clip accidentally;
- selecting a different session uses different words, not a generic narration reused under another title.

This means 18 distinct narrated experiences, not only one flagship session per category.

#### Sub-batch 7D — Daily Snapshot and Wellness Result

When Sound is enabled:

- play one short guide once for each major Daily Snapshot stage: Body, Mind, Routine, and Review;
- do not automatically read every answer choice or repeat audio after every tap;
- provide a replay and mute control;
- after Save, play one safe result narration for:
  - steady day;
  - mixed day;
  - heavier day.

The result voice must not say the score is a diagnosis, medical assessment, or certainty. It should thank the user, reflect the broad band gently, and point to the displayed next step.

#### Sub-batch 7E — Audio validation

Completed:

- all pilot assets are declared and included in successful Android/Web builds;
- post-audio analyzer reports 0 errors and 0 warnings;
- the single smoke test passes;
- debug APK and Web builds pass; the WASM dry run also passes.

Still required:

- test Chrome playback behavior and browser autoplay restrictions;
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

### Batch 9 — Account and runtime reliability

**Purpose:** Fix known failures that static analysis does not detect.

Tasks:

1. Handle login when Firebase Auth exists but the Firestore user profile is missing.
2. Handle registration when Auth succeeds but profile creation fails.
3. Audit async gaps for missing `mounted` checks.
4. Cap wellness-score components at 100.
5. Add consistent friendly loading, empty, and error states to critical streams.
6. Clean stale service comments while touching the relevant code.
7. Decide whether ISO date strings remain for the prototype; do not perform a risky Timestamp migration without a migration plan.

Exit criteria:

- each reproduced failure has a test or exact manual test path;
- no analyzer errors/warnings;
- debug build passes;
- documentation records intentionally deferred issues.

### Batch 10 — AI Worker live completion

**Purpose:** Make the repository Worker and live Worker match, then verify safety and reliability.

Tasks:

1. Compare the live Cloudflare Worker with `worker/index.js`.
2. Change any wording that could imply the AI is human; keep it transparently an AI companion.
3. Confirm the `AI` binding.
4. Choose and record the final `AI_MODEL`.
5. Decide whether to enable `MINDMATE_RATE_LIMIT`.
6. Decide whether to enable `MINDMATE_METRICS`.
7. Deploy the reviewed Worker.
8. Test:
   - normal conversation;
   - `listen`, `calm`, and `make_plan`;
   - invalid payloads;
   - injected roles;
   - oversized message/history;
   - deterministic crisis route;
   - quota fallback;
   - provider/network failure;
   - logs without sensitive message content.

Exit criteria:

- live deployment version is recorded;
- every test case has a result;
- Flutter receives safe, friendly responses;
- no raw provider error is exposed.

### Batch 11 — Safety, content, and resource verification

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

### Batch 12 — Meaningful automated and device testing

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

### Optional Batch 13A — Competition landing page — direction approved

**Purpose:** Give judges and early users a fast, polished explanation of MindMate and a safe way to download the Android demo.

This is a useful competition asset, but it must not delay audio, safety, testing, or the release candidate. Build it after the app's visual/content claims are stable so screenshots and feature copy are accurate.

Approved direction:

- use the supplied Spouse Finder page only for layout, interaction, and visual inspiration;
- replace all branding, copy, colors, images, fake phone content, claims, FAQ, navigation, and CTAs with truthful MindMate material;
- build a lightweight static informational site in a separate `landing/` directory;
- do **not** expose or host the Flutter app as a browser product;
- do **not** include app Sign In/Register or route visitors into Flutter Web;
- provide product information, the check-in-to-action loop, real screenshots, safety/privacy boundaries, FAQ, installation help, and an APK download button;
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
- no broken download, privacy, or support link;
- responsive desktop/mobile checks pass;
- Lighthouse-style accessibility/performance checks are acceptable;
- deployed URL and hosting configuration are documented.

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
9. **Appointment rules need hardening** — pending-only creation and mutable-field restrictions are not complete.
10. **No authoritative duplicate-request enforcement** — the current normal-flow guard can be bypassed.
11. **No persistent chat history** — conversation continuity ends with the in-memory session.
12. **Weak analytics compared with tracking specialists** — no deep correlations, export, or mature history exploration.
13. **Weak retention compared with habit specialists** — no strong personalized daily routine or reward loop.
14. **No user data export/deletion flow** — a serious long-term privacy gap.
15. **Account edge cases remain** — missing profile and partial registration failures need explicit handling.
16. **Release proof is incomplete** — post-audio Android/Web builds and latest shell behavior pass in Chrome, but the full runtime matrix, physical device, and signed release candidate remain pending.
17. **Broad scope creates maintenance risk** — many feature areas can become shallow or inconsistent if polish is spread too thin.
18. **Package upgrades are pending** — 27 newer versions exist outside current constraints, but upgrading before feature freeze could introduce breakage.

## Current execution gate

Batch 8 validation and deployment passed: 13/13 emulator cases, Flutter 0 errors/0 warnings, smoke test passed, and the rules are live on `mindmate-app-fcf2d`.

Current gate:

1. run brief normal-flow live smoke checks;
2. close Batch 8 if no expected flow is denied;
3. then move to Batch 9 account/runtime reliability.

Do not expand narration or start the landing site ahead of this final live-smoke check.
