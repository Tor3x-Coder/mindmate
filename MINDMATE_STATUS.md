# MindMate current status

**Last updated:** 3 September 2026
**Purpose:** This is the single source of truth for the current implementation checkpoint and the next task.

Every agent or developer continuing MindMate must read this file together with:

1. `MINDMATE_CODING_GUIDE.md` — how to work on the project;
2. `MINDMATE_HANDOFF.md` — product decisions and broader context;
3. `MINDMATE_REMAINING_BATCHES.md` — ordered remaining batches, guided-audio decision, and competitive audit;
4. the relevant feature README, such as `worker/README.md`, before changing that feature.

## Status words used in this project

These words are deliberately separate:

- **Implemented:** the code exists in the repository.
- **Validated:** the relevant analyzer, automated test, or syntax check passed.
- **Deployed:** the Firebase/Cloudflare/live environment was updated.
- **Verified:** the feature was tested end to end against the deployed services on a target device.

Do not call a feature “finished” merely because it is implemented. State all four statuses when handing it over.

## Current checkpoint

**Current Chat improvement checkpoint — 3 September 2026:**

- Implemented locally: richer ordinary AI guidance, including feeling-first difficult-day responses, one small step or up to three options, and at most one gentle question; model output budget is now 320 tokens.
- Implemented locally: deterministic crisis coverage for clear self-harm, violence, and physical-emergency phrases remains before rate limiting/model generation, and crisis replies now include only the allow-listed `open_emergency_support` action.
- Implemented locally: ChatService parses only that known action, and Chat renders an app-controlled **Open Emergency Support** button that opens the existing `EmergencySupportScreen`; arbitrary Worker action types are ignored.
- Validated here: Worker **13/13** tests, `node --check`, and `git diff --check`. Flutter/Dart are not installed in this Arena workspace; the developer PC must run the new Flutter tests, analyzer, and device/Chrome check.
- Deployment: live Worker remains `2026-09-02-learn-context`; source `2026-09-03-connected-chat` is not deployed. Preserve the existing `AI` binding and `AI_MODEL` setting when deploying, then rerun `/health` and the POST smoke matrix.

**Session handoff — 1 September 2026 (read this first when continuing):**

- **Date correction:** the competition is **21 September 2026** (earlier docs said 11 September — that is when school starts). Full-team build window: **1–10 September**. Feature freeze: **~13–14 September**. Rehearsal window (school time, evenings only): 11–21 September.
- **App is live on real phones.** Release APK v1.0.0 (62 MB) built and signed with `mindmate-release.jks` (on the developer's PC, with `android/key.properties` — both git-ignored, never committed). The launch crash (namespace vs MainActivity class mismatch + lost applicationId change) was fixed in commit `1fc3ef8`. Login/register verified working on device (Infinix X669, Android 12); an earlier auth failure was network-side (mobile data worked).
- **Decisions locked on 1 September 2026:**
  1. **Learn section = Option B (expanded):** featured card on Home (between the Wellness Score card and the quick-tile grid), four approved shelves, six foundational articles, ten priority scenario articles, and a local Explore more catalogue. Tone: calm, honest, non-preachy, never medical advice, each article ends pointing into the app's own tools. A health-literate team member skims articles 3–4 and the urgent-help content before the competition.
  2. **Demo account = script seeding:** register the demo account through the app normally, then a one-off Firebase Admin SDK script (Node, service-account key, never committed) writes ~3 weeks of realistic history (mood logs with word-based impact, meditation/breathing sessions from the real 18/3 catalog, journal entries, thought records, matching feedback records).
  3. **Professionals directory = Option two:** keep clearly-labeled demo data (the "Demo data" banner is already in the app). The team has no real professional contacts; do NOT cold-outreach strangers with days on the clock. The honest-limits slide states plainly: sample listings, request flow + duplicate guard + admin review fully built and security-tested, real consented providers join post-competition with verification.
  4. **Tier-two features are now IN SCOPE** (time allows): weekly insight on the Progress screen, and a working local-notification daily reminder (the setting already exists; the notification does not).
- **Build order for 1–10 September:** Learn section → demo seeding script → weekly insight → daily reminder → multi-phone device test matrix (the team's phones ARE the device fleet) + the 4 landing-page screenshots → honest-limits slide + five-question answer sheet for the team.
- **Verify-or-complete item:** confirm whether the final (post-`1fc3ef8`) release APK was uploaded to a GitHub Release (`v1.0.0`) and whether `landing/assets/js/config.js` was flipped to the live download state (version/size/SHA-256/URL). If not: upload the APK to a Release, copy the SHA-256 GitHub shows, fill `config.js`, push, re-sync `gh-pages`.
- **GitHub incident note (1 Sep):** GitHub reported degraded *Pull Request diff rendering*; git push/commit (Git Operations) was unaffected and we never use PRs, so no impact on this workflow.

The repository contains backend/integration batches 1–10 plus completed Batch 7 (full audio), Batch 11 part 1 (resource verification), Batch 12 automated tests, and Batch 13A (landing site live). See the sections below for detail.

The developer confirmed that the local checkout tracks `arena/01a02a49-mindmate`. Batch 8 passed all 13 emulator cases, Flutter analysis/tests, compiled successfully, and was released to Firestore project `mindmate-app-fcf2d` on 23 August 2026. Brief normal-flow live smoke checks remain.

Batch 9A account reliability is implemented on the Spark plan. The updated rules pass all 13 emulator cases, Flutter gates pass, the profile-delete delta is live, and the user confirmed the disposable-account happy path deletes successfully. Interruption/retry, missing-profile recovery evidence, data export, and the external web request resource remain.

Audio, Floating Tide navigation, contextual tour, and the Modern Shell were confirmed working in Chrome. Post-audio Android/Web builds passed; physical-device validation remains open.

Batch 7A–7D audio is implemented in the repository (26 August 2026): all 3 breathing patterns and all 18 meditation sessions have unique offline narration wired into their screens with matching captions, plus 4 Daily Snapshot stage guides and 3 Wellness Result band narrations wired into the wellness screens with replay/mute controls. **All 184 MP3s (about 3.75 MB) are recorded with one consistent narrator** (the 15 pilot clips were re-voiced for consistency). Only 7E (the Chrome/device playback matrix) remains open.

| Area | Implemented | Validated | Deployed | Verified end to end |
|---|---:|---:|---:|---:|
| Firestore owner/admin rules | Batch 8 + Batch 9 profile-delete delta live | Updated **13/13 emulator tests passed** | **Deployed — `mindmate-app-fcf2d`** | Temporary-account deletion test pending |
| Mood impact and activity feedback persistence | Yes | Flutter analysis/tests pass; runtime pending | Batch 8 rules live | No |
| Appointment admin workflow | Pending-only create + admin status-only rules/service guards implemented | Emulator + Flutter gates passed | **Batch 8 rules live** | Normal live request/admin smoke pending |
| One-pending-request guard | Client/service guard only | `flutter analyze` passed; runtime pending | N/A | No |
| Mode-aware AI Worker and safety route | Batch 10 hardened; Learn article context implemented locally; richer replies and allow-listed crisis action implemented locally | **13/13 Worker tests passed; prior developer-PC Flutter suite 47/47 with analyzer 0 errors/0 warnings; new Flutter checks pending** | **`2026-09-02-learn-context` remains live; source `2026-09-03-connected-chat` is not deployed yet** | Previous normal/calm/Learn/crisis POST smoke passed; rerun the expanded reply/synonym/action matrix after deployment |
| Trusted contacts and support-event tracking | Strict schemas/immutability implemented | Owner/cross-user emulator cases passed | **Batch 8 rules live** | Normal CRUD/event smoke pending |
| State/international emergency-number UI | All 36 states + FCT now listed (15 added, verified); state cards + professional demo-data label fixed | Verified against NEMSAS list of 19 Aug 2026 + standard international references (docs/emergency_resource_verification.md) | N/A | `tel:`/`sms:`/browser actions still need the device pass (Batch 12) |
| Guided audio: Meditation, Breathing, Daily Snapshot | All 18 meditations + 3 breathing patterns + 4 snapshot stage guides + 3 result band narrations recorded and wired with captions/replay/mute (184 clips, one narrator) | Python asset audit passed (184/184 registry/disk/pubspec, durations, no orphans); `flutter analyze`/tests/build pending on dev machine | N/A | Full-library Chrome + device playback matrix pending (7E); Quick Reset/Box were previously Chrome-confirmed |
| Floating Tide Orb navigation | Polished implementation | User confirmed slower/lower four-tab behavior in Chrome | N/A | Physical-device layout still pending |
| Contextual first-use guide | Implemented | User confirmed tour controls and Settings replay in Chrome | N/A | Fresh-account/physical-device release matrix still pending |
| Quiet Tide modern shell | Focused shell polish implemented | User confirmed combined shell works in Chrome | N/A | Child-screen redesign intentionally deferred |
| Account deletion/recovery | Spark-compatible implementation + rules deployed | User confirmed temporary-account happy-path deletion works | Rules live; retry/recovery proof pending | External web request page still required |
| Daily Snapshot UI/progress | Theme/progress fix implemented | User confirmed Light/default colours + 8-unit progress in Chrome | N/A | Physical-device check pending |
| Wellness scoring/runtime | 0–100 component/average caps + 4 unit tests implemented | **4/4 model tests passed**; analyzer clean | N/A | Score remains non-clinical |
| Critical async/error states | Appointment duplicate-check + dashboard async guards + My Requests privacy state implemented | Flutter analyzer/tests passed | N/A | Broader device/network matrix pending |
| Registration/onboarding text | Login-matched dark input style implemented | User confirmed inputs/setup choices readable in Chrome | N/A | Physical-device check pending |
| Informational landing site | Site implemented in `landing/` (index + `/delete-account/`, hosted-form deletion flow, config-driven APK card, team credit "Junior Achievers — FG Enugu") | Live site checked; form + email wired in `config.js` | **Deployed — https://tor3x-coder.github.io/mindmate/** (GitHub Pages on `gh-pages`) | Screenshots still pending (currently placeholder frames); APK card flips live when Batch 13's signed APK metadata is set |
| Android APK | Post-audio debug APK built | Build passed in 411 seconds despite recovered stale-depfile warnings | N/A | No phone available; emulator/device verification pending |
| Learn and One Safe Step | Home featured card, four category shelves, sixteen core reads, eight local Explore more reads, Add to Learn persistence, mood-aware One Safe Step flow, visible Check in → One safe step → Reflect trail, Learn bridge, human-support bridge, and article-scoped AI context implemented | Developer PC before this UI batch: `flutter analyze` **0 errors/0 warnings**; focused Learn test **2/2**, catalogue/Chat tests **6/6**, full Flutter suite **47/47**; new One Safe Step test rerun pending | App code not deployed; current live Worker remains `2026-09-02-learn-context`; new `2026-09-03-connected-chat` Worker source is not deployed | Rerun focused/full Flutter tests, then Chrome/device One Safe Step flow; deploy the new Worker only after Worker/UI tests pass, then verify richer replies and crisis action button |
| Demo account history seed | One-off Node/Firebase Admin SDK script implemented with deterministic IDs, explicit dry-run default, and no-delete boundary | Script tests **4/4**; syntax check and 50-document dry run passed; developer applied the seed and confirmed the seeded history in the app | Not a deployment; 50 synthetic documents were written to the dedicated demo account only | **Verified in the app:** demo Progress, Journal, Achievements, and history views displayed the seeded data; keep the service-account JSON private |
| Weekly Progress insight | Read-only seven-day summary implemented from existing moods, journals, wellness reflections, and feedback | Developer PC: focused test **2/2**, full Flutter suite **45/45**, analyzer **0 errors/0 warnings with 23 informational notices**; Chrome demo screenshot confirmed seeded counts and feedback observation | N/A | Formatting was committed separately as `7e58c90`; no deployment; continue to local reminder |
| Daily local reminder | Implementation in progress: local timezone-aware daily scheduling, Android/iOS permission request, test notification, reboot rescheduling, and logout/deletion cancellation | Flutter/Dart checks pending; Arena sandbox cannot run Flutter | Not deployed | Android phone/emulator firing test and permission-denial check remain |

### Learn section — expanded locally, automated validation complete

The approved Learn Option B is now expanded in the app code. Home places a featured Learn card directly between the Wellness card and Quick starts. The Learn screen now groups the six foundational reads and ten priority scenario reads into four sections: Everyday life, Love and people, Understanding difficult moments, and Getting help. Each topic opens a scrollable article reader with a calm header, conversational headings, a general-information disclaimer, a real next-step button into an existing MindMate tool, and an Ask MindMate about this action.

Explore more is a local bundled catalogue of eight additional scenario reads. It has search, article preview, and Add to Learn/Added to Learn controls. Added article IDs are saved in local preferences, so the selected reads reappear in their normal Learn section without a backend or a fake download claim. No Firestore collection or new personal data is used.

The article-scoped AI path sends only the selected approved article as bounded reference context to the existing Chat screen and Worker. Chat shows the selected article, lets the user clear the context, and keeps the existing crisis-first and AI-boundary behavior. The Worker source `2026-09-02-learn-context` remains live through the Cloudflare dashboard, and the new local source `2026-09-03-connected-chat` adds richer make-plan replies and allow-listed Emergency Support action metadata; it is not deployed yet. The user confirmed the separate Bindings view shows `AI` as a Workers AI binding; no optional rate-limit or metrics bindings were previously configured, so none were added. The previous live normal, calm, Learn-context, and deterministic crisis POST smoke tests passed; the expanded matrix remains pending after redeployment.

Current Learn validation state: implementation and automated validation are now complete for this batch. On the developer PC, `flutter analyze` reports 0 errors/0 warnings; the focused Learn widget test passes 2/2, the catalogue/Chat test command passes 6/6, and the full Flutter suite passes 47/47. The developer's broad `dart format lib test` changes remain safely in the local stash named `local formatting before Learn test fix`. The previously deployed Worker remains live at `2026-09-02-learn-context`; the richer-reply/crisis-action Worker source is local and still needs deployment after its 13-test suite and Flutter checks. Android/Web builds, Chrome/device checks, and the health-literate skim of articles 3–4 remain open. Nothing from the app expansion is deployed yet; the earlier Worker deployment is the exception.

### Demo account history seed — implemented and applied

The one-off seeder now lives in `scripts/demo_seed/`. It uses the Firebase Admin SDK only when explicitly applied, targets a registered Firebase Auth user by email or UID, and writes 50 deterministic `demo_seed_v1_*` documents across the existing `mood_logs`, `journal_entries`, `wellness_assessments`, `meditation_history`, `breathing_sessions`, `thought_records`, and `feedback_records` collections. It does not write the user profile, appointments, professionals, trusted contacts, support events, or chat data, and it never deletes documents. The same seed can be rerun for the same demo account without duplicate IDs.

The default command is a dry run that does not load credentials or contact Firebase. Actual writes require both `--apply` and `--confirm-demo`, and the service-account JSON must stay outside the repository. Script tests pass 4/4, and the developer successfully applied the 50-document seed to the dedicated demo account. The developer then confirmed in the app that the demo Progress, Journal, Achievements, and history views display the seeded data.

### Weekly Progress insight — implemented and validated

The Progress screen now has a read-only `Your week` card computed from the last seven days of existing data. It shows check-in, journal, and wellness-reflection counts, identifies a heavier day only when difficult-mood entries provide a clear pattern, and names up to two practices associated with harder check-ins when feedback exists. The language is observational rather than diagnostic, and an empty week has a calm starting state. It adds no collection, no write, no AI call, and no numeric emotional score.

The card reads existing feedback through a UID-only Firestore query and sorts that small list on the client to avoid introducing a composite index. On the developer PC, the focused tests passed **2/2**, the full Flutter suite passed **45/45**, and `flutter analyze` reported **0 errors/0 warnings with 23 informational notices**. The seeded demo Progress screenshot showed the expected counts, Tuesday stressed check-in, and `Write it out` practice observation.

### Daily local reminder — implementation in progress

The existing Morning/Afternoon/Evening setting now has a local-reminder path in progress. The planned implementation uses `flutter_local_notifications` with the device timezone, inexact daily scheduling, Android boot rescheduling, explicit notification permission, a Settings test notification, and cancellation on logout/account deletion. It stores no new data and does not require a network connection. Chrome remains useful for the settings UI but cannot deliver an OS notification; Android phone/emulator testing is required.

### Validation environment note

Flutter and Dart are not installed in the current Arena sandbox, so Flutter commands cannot be repeated here. Local post-audio dependency resolution, analysis, smoke test, Android build, and Web build all pass. Chrome playback, emulator runtime, and physical-device behavior remain pending.

The developer currently has no physical Android phone for testing. Use Chrome for broad UI/Firestore checks and an Android emulator if the PC can support one. Physical-device-only behavior—especially `tel:`, `sms:`, audio interruption/routing, notifications, and final APK installation—must remain explicitly unverified until a borrowed or competition device is available.

## Backend/integration work implemented so far

### Batch 1 — Firestore rules and admin appointment support

Implemented:

- stricter `/users/{uid}` rules that prevent users from self-granting `isAdmin`;
- UID preservation on personal-record updates;
- the missing `/thought_records/{docId}` rule;
- owner/admin appointment access rules;
- `requestAppointment()`, `allAppointmentsForAdmin()`, and `updateAppointmentStatus()` service methods;
- admin appointment-review UI integration.

Main files:

- `firestore.rules`
- `lib/services/firestore_service.dart`
- `lib/screens/professional/admin_appointments_screen.dart`

### Batch 2 — Mood impact and activity feedback

Implemented:

- mood-impact persistence on mood logs;
- `FeedbackRecordModel`;
- `feedback_records` collection constant, service method, and owner-only rule;
- post-activity feedback save flow in NextStep.

Main files:

- `lib/models/feedback_record_model.dart`
- `lib/models/mood_log_model.dart`
- `lib/screens/mood/mood_checkin_screen.dart`
- `lib/screens/next_step_screen.dart`
- `lib/services/firestore_service.dart`
- `firestore.rules`

### Batch 3 — Appointment duplicate-request guard

Implemented:

- a service query for an existing pending request by the same user to the same professional;
- frontend prevention of another pending request when one already exists.

Important limitation:

- this is **not authoritative server-side uniqueness enforcement**. A modified client or simultaneous requests could bypass a read-then-write guard. Production enforcement still needs a trusted backend transaction/Cloud Function or a deterministic document-key design.

### Batch 4 — AI Worker modes, validation, safety, and operations

Implemented:

- structured chat modes: `listen`, `calm`, and `make_plan`;
- Flutter-side history sanitization and history limits;
- Worker-side role validation, message/history limits, and client-system-message rejection;
- deterministic crisis-keyword routing before AI generation;
- generic client-safe errors with server-side structured logs;
- friendly quota fallback;
- optional `MINDMATE_RATE_LIMIT` binding;
- optional `MINDMATE_METRICS` KV usage counter;
- switchable `AI_MODEL` environment variable.

Main files:

- `lib/services/chat_service.dart`
- `lib/screens/chat/chat_tab_screen.dart`
- `worker/index.js`
- `worker/README.md`

Important limitations:

- the current live Worker deployment has not been confirmed to match `worker/index.js`;
- the crisis matcher and all mental-wellness copy need adversarial and qualified human review;
- persistent chat history is not implemented.

### Batch 5 — Trusted contacts, support events, and emergency resources

Implemented:

- trusted-contact model and owner-only Firestore CRUD;
- support-event model and owner-only event writes;
- user-triggered `tel:` and `sms:` actions only—MindMate never contacts anyone silently;
- “Did you connect?” follow-up tracking;
- Nigeria state selection with 112 fallback;
- international emergency-number choices and worldwide helpline-directory access.

Main files:

- `lib/models/trusted_contact_model.dart`
- `lib/models/support_event_model.dart`
- `lib/screens/emergency_support_screen.dart`
- `lib/services/firestore_service.dart`
- `lib/utils/constants.dart`
- `firestore.rules`

Important limitation:

- every emergency number, operating status, label, and external resource must be rechecked against authoritative current sources before a public build. Do not treat a code comment or an old search result as release verification.

## What remains before calling the prototype complete

The complete ordered plan is in `MINDMATE_REMAINING_BATCHES.md`. Guided audio is competition-critical and now has a build-valid pilot for Quick Reset and Box Breathing. Runtime playback must pass before the remaining narration is generated.

Do these first, in order.

### 1. Finish Flutter validation in the local environment

Completed before the audio pilot:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Result: **0 errors, 0 warnings, 21 informational notices, 1 passing smoke test, and a successful debug APK build**. The smoke test is not meaningful end-to-end coverage. Android runtime remains unverified; emulator testing is deferred and a physical-device check is still required before the competition.

### 2. Implement the approved full natural-voice guidance

Approved scope:

- one consistent narrator with unique scripts;
- all 18 meditation sessions using segmented prompts that fit 1, 3, and 5-minute choices;
- unique synchronized guidance for Box Breathing, 4-7-8, and Simple Calm;
- one short guide per Daily Snapshot major step;
- three safe Wellness Result narrations for steady, mixed, and heavier bands;
- real Sound-setting behavior, captions, replay/mute controls, and safe lifecycle handling.

Batch 7B + 7C are now implemented in the repository (26 August 2026):

- one shared `just_audio` service/provider prevents intentional overlap;
- the Sound preference controls real supported-session behavior;
- all 18 meditation sessions have unique natural narration: intro, 4 main prompts reading the session's guiding lines, and 4 short reassurance cues with matching written captions, interleaved across 1/3/5 minutes at `0.88x`;
- all 3 breathing patterns (Box, 4-7-8, Simple Calm) have unique intro, phase cues verified to fit each phase length, and completion cues at `0.92x`;
- the original 15 pilot clips were re-voiced with the newly approved narrator, so the entire app uses one consistent voice;
- pause/resume, replay, mute, preview, stop-on-exit, and matching written captions were added;
- 184 MP3 files total **3,840,792 bytes (about 3.75 MB)**; durations verified with no anomalies;
- Daily Snapshot plays one short guide once per stage (Body, Mind, Routine, Review) with replay/mute controls above the Continue bar;
- the Wellness Result screen (now stateful) plays one safe band narration on entry (steady >= 70 / mixed 40-69 / heavier < 40) with replay/mute, stops on exit, and never reads the score or claims a diagnosis;
- asset audit passed: every registry path exists on disk, no orphan files, all 21 leaf audio directories declared in `pubspec.yaml`.

Remaining for Batch 7: 7E only (Chrome/device playback matrix on the developer machine).

The user confirmed the combined Quiet Tide Modern shell works in Chrome: slower/lower Floating Tide navigation, four contextual coach marks, 2D guide, tour controls, Settings replay, tab-state behavior, and the 8-cue Quick Reset timeline. Physical-device behavior and a fresh-account release-matrix check remain pending. Literal breathing loops/background music remain deferred behind optional licensed ambience.

### 3. Validate and deploy Batch 8 Firestore integrity

Implemented locally:

- robust `isAdmin` handling for profiles without the field;
- self-admin creation/promotion and email-change denial;
- exact appointment schema with pending-only creation;
- immutable appointment details after creation;
- admin status-only updates limited to pending/approved/declined;
- service-layer pending/status guards;
- strict trusted-contact schema with immutable uid/createdAt;
- append-only support events with owner read/delete;
- 13 Firebase Emulator authorization tests covering owner, cross-user, admin, and malformed-write cases.

Validation passed on the developer PC:

- Android Studio Java 21 activated for the test terminal;
- Firestore Emulator suite: **13 passing in 12 seconds**;
- expected `PERMISSION_DENIED` attack attempts were correctly blocked;
- emulator started/stopped cleanly without touching live data;
- `flutter analyze`: 0 errors, 0 warnings, 4 informational notices;
- `flutter test`: 1 smoke test passed;
- production dependency audit (`npm audit --omit=dev`): 0 vulnerabilities;
- locked dev toolchain: no high/critical audit findings.

Deployment completed on 23 August 2026:

```text
firestore.rules compiled successfully
firestore.rules released to cloud.firestore
Deploy complete
Project: mindmate-app-fcf2d
```

Batch 8 is now live. Remaining: brief normal user profile, trusted-contact/support-event, pending appointment, and admin status smoke checks against the intended project.

### 4. Validate Batch 9A account deletion and recovery

Implemented locally for the Spark plan:

- Settings → Privacy and data → Delete account;
- type `DELETE`, password reauthentication, and final irreversible confirmation;
- repeatable 200-document deletion batches across every UID-owned collection;
- Firestore profile deletion last, Firebase Auth deletion after Firestore;
- persistent local retry marker if deletion is interrupted;
- Splash routes interrupted attempts back to deletion;
- missing-profile recovery or deletion choice;
- registration rollback when Firestore profile creation fails;
- Login/Splash route incomplete profiles back through setup;
- passwords are no longer trimmed;
- local preferences clear only after confirmed Auth deletion.

Important limitation: a trusted Cloud Function remains preferable but requires Blaze. This Spark-compatible flow is designed to be retryable rather than falsely claiming atomic deletion.

Google Play also requires a functional external web resource where a user can request account/data deletion. The planned landing site must include a real `/delete-account` pathway before Play submission: https://support.google.com/googleplay/android-developer/answer/13327111

Validation passed on the developer PC:

- updated Firestore Emulator suite: **13/13 passing in 12 seconds**;
- owner profile deletion allowed; another user's deletion denied;
- `flutter analyze`: 0 errors, 0 warnings, 4 informational notices;
- `flutter test`: 1 smoke test passed.

The tested profile-delete rules delta compiled/released successfully, and the user confirmed the disposable-account happy path works end to end. Keep interruption/retry and missing-profile restoration in the release matrix; never repeat destructive testing with the developer/admin account.

The user confirmed the Light default, Login-matched registration text, readable post-registration choices, theme-aware Daily Snapshot colours, and accurate 8-unit progress all work in Chrome. Mind 5/5 correctly shows Step 6 of 8 / 75%.

Batch 9B is implemented locally:

- every wellness score component and final average is clamped to 0–100;
- 4 focused model tests cover normal, extreme-positive, extreme-negative, and range invariants;
- appointment duplicate-check failures now stay inside a mounted-safe friendly handler;
- legacy Dashboard profile/admin loading no longer leaks unhandled async errors;
- My Requests no longer exposes raw Firestore errors and uses theme surfaces.

ISO date strings are intentionally frozen for the competition prototype. A future migration must dual-read String/Timestamp, backfill existing records, then switch writes—never rewrite the schema casually before release.

Validation passed on the developer PC:

- `flutter test`: **5/5 passed** (1 smoke + 4 wellness-boundary tests);
- `flutter analyze`: 0 errors, 0 warnings, 4 informational notices.

Batch 9B is closed. Weak/offline and physical-device behavior remains part of the broader release matrix.

### 5. Deploy and verify Batch 10 AI Worker — validated, deployed, and verified live

Implemented and deployed:

- transparent AI-only identity; all “human companion” wording removed;
- final default model: `@cf/meta/llama-3.3-70b-instruct-fp8-fast`;
- `AI_MODEL` set as an explicit environment variable and controlled override;
- strict message/body/history/mode validation on Flutter and Worker sides;
- one trusted system prompt; client-injected roles discarded;
- explicit crisis response before rate limits/model generation;
- current Cloudflare rate-limit API (`limit({ key })`) with friendly fallback;
- max 220 output tokens and concise mode instructions;
- safe malformed/quota/provider/missing-binding behavior;
- request IDs, no-store headers, and length-only logs;
- versioned `GET /health` endpoint;
- 12/12 Worker source tests passed;
- 4 Flutter ChatService tests added (9/9 total tests passing, 0 analyzer errors).

Live verification passed on 25 August 2026:

- `GET /health` returned `version: "2026-08-23-batch10"`, `defaultModel: "@cf/meta/llama-3.3-70b-instruct-fp8-fast"`, `status: "ok"`;
- `POST make_plan` returned an actionable, concise small next step;
- `POST calm` returned an immediate grounding and breathing relaxation response;
- `POST crisis` ("I want to kill myself") returned immediate human crisis support guidance without model dependencies.

Batch 10 is complete, deployed, and verified.

### 6. Run the end-to-end demo checklist

Required journey:

```text
Sign in
  -> mood check-in + qualitative impact
  -> one recommended action
  -> complete/try the action
  -> save honest feedback
  -> offer an alternative or human-support route
```

Also verify:

- CBT thought-record save;
- appointment request, duplicate guard, user request history, and admin approve/decline;
- trusted-contact add/edit/delete and explicit call/message taps;
- support-event and “Did you connect?” writes;
- emergency location switching and every external resource;
- AI modes, safety route, and friendly unavailable state.

### 7. Build the competition APK and freeze features

- fix critical reliability/accessibility issues found during testing;
- produce and install a release candidate APK;
- rehearse the demo journey offline/under weak-network conditions;
- avoid adding nonessential features after feature freeze.

### Batch 12 status (26 Aug 2026): automated tests implemented — 30 new tests across 4 files (run 1: 36 passed / 4 test-harness fixes applied)

- `test/models_serialization_test.dart` (13) — round-trip + uid/id preservation + missing-key defaults for Mood, TrustedContact, SupportEvent, FeedbackRecord, JournalEntry, ThoughtRecord, Appointment, and Professional models;
- `test/next_step_recommendation_test.dart` (8) — mood→recommendation mapping (sad/stressed/angry/tired/happy/excited/default) asserting the actually-rendered 1-recommended + 2-alternatives structure, no crisis copy on positive moods, safe fallback for unexpected labels;
- `test/wellness_result_screen_test.dart` (5) — steady/mixed/heavier band behaviour, concerning-insight support card, replay/mute controls present;
- `test/audio_guide_service_test.dart` (4) — lifecycle guards that need no platform channel: clean start, safe stop, pause/resume no-ops, dispose. (Full playback is device/Chrome-verified in the 7E/12 matrix; a first draft's playAsset-in-test variant leaked just_audio's own plugin-missing async error in the VM, so those two tests were dropped in favor of the platform-free guards.)

Existing 9 tests remain; dev machine should now show 39 total. The Android/device matrix (check-in→action→feedback journey, `tel:`/`sms:` actions, audio interruptions, weak network) runs on the competition phone with Batch 12's device pass.

## Still planned, but not required to prove the competition prototype

- authoritative backend enforcement of one pending appointment per professional;
- professional Firebase accounts and provider roles;
- provider appointment inbox and direct provider actions;
- verified provider identity, availability, and calendar handling;
- push/email/SMS notifications;
- persistent AI chat sessions and a past-chat screen;
- opt-in journal AI reflection;
- privacy data export controls;
- trusted-backend account deletion after a future Blaze upgrade;
- scheduled check-in notifications;
- a production moderation plan before any community feature.

## Known issues still to review

- Emergency resources: verified 26 Aug 2026 — all 36 states + FCT listed and matched against the NEMSAS list of 19 Aug 2026 (15 states added, incl. Lagos 767); 112 confirmed as the national fallback; international lines standard. Remaining: device pass for `tel:`/`sms:`/browser actions, a fresh re-verification before any public release, and the qualified-reviewer wording review (documented limitation).
- Account deletion happy path is proven; interruption/retry and missing-profile restoration still need runtime evidence.
- Light-default, registration contrast, and Daily Snapshot progress/colour fixes are Chrome-validated; physical-device checks remain.
- Critical async flows are audited/fixed; broader device/network interruption testing remains.
- ISO date strings are intentionally deferred; migration requires dual-read/backfill planning after the competition.
- Wellness score caps and 4 focused tests are validated; weak/offline behavior remains in the release matrix.
- Critical stream states are friendly; broader consistency polish remains.
- Some screens still use hardcoded legacy colours.
- Analyzer informational debt at the last run: 2 deprecated onboarding Radio API uses and 2 optional `const` notices.
- Post-audio `flutter pub get` reports 27 newer package versions outside current constraints; defer major upgrades unless a tested fix requires one.
- Firestore comments in `lib/services/firestore_service.dart` contain some stale “later” wording and can be cleaned during a later controlled pass.

## Documentation update log

Append one concise row after every code batch or fix. Keep detailed product documentation in the relevant file; this table is a continuation checkpoint, not a full changelog.

| Date | Batch/fix | Code status | Validation | Deployment | Next action |
|---|---|---|---|---|---|
| 22 Aug 2026 | Batches 1–5 recovered from interrupted Arena session | Implemented and committed | Worker syntax passed; Flutter checks unavailable | Firestore now confirmed; Worker unconfirmed | Run Flutter checks, then test rules and deploy/test Worker |
| 22 Aug 2026 | Documentation continuity policy and status refresh | Documentation updated | `git diff --check` and local Markdown-link check passed | Not applicable | Start validation step 1 |
| 22 Aug 2026 | Local sync and Firestore deployment confirmation | Current branch pulled; working tree clean | Firebase CLI compiled rules successfully | Rules released to `mindmate-app-fcf2d` | Run `flutter pub get` and `flutter analyze` |
| 22 Aug 2026 | Local dependency resolution and static analysis | No code change | `flutter pub get` succeeded; `flutter analyze`: 0 errors, 0 warnings, 21 info | Not applicable | Run `flutter test`, then `flutter build apk --debug` |
| 22 Aug 2026 | Remaining-batch plan and competitive audit | Planning/docs only; audio confirmed missing | Repository audio/assets/dependency audit completed | Not applicable | Choose audio Option A or B; run Batch 6 baseline first |
| 22 Aug 2026 | Local Flutter test | No code change | `flutter test`: 1 test passed; coverage is smoke-only | Not applicable | Build debug APK; use emulator/Chrome because no phone is available |
| 22 Aug 2026 | Device-constraint and landing-page plan | Planning/docs only | No physical phone; emulator/Chrome fallback documented | Not applicable | Finish APK build; approve audio and optional landing-page options |
| 22 Aug 2026 | Full natural-voice scope approval | Planning/docs only | One narrator, unique scripts, timed 1/3/5 prompts, and step-based wellness audio selected | Not applicable | Build debug APK, then audition narrator and start Sub-batch 7A |
| 22 Aug 2026 | Batch 6 debug build gate | No code change | `flutter build apk --debug` passed in 159.6 seconds | Debug APK created locally | Begin controlled audio pilot |
| 22 Aug 2026 | Audio Sub-batch 7A pilot | Shared player + Quick Reset + Box Breathing + 10 MP3s implemented | Static registry/import/delimiter checks passed | Not deployed | Pull, resolve package, analyze/test/rebuild, then Chrome-test audio |
| 22 Aug 2026 | Post-audio local validation | No code change | `pub get` passed; analyze 0 errors/0 warnings/21 info; 1 smoke test passed | Not deployed | Chrome-test audio after builds |
| 22 Aug 2026 | Post-audio platform builds | No code change | Debug APK passed in 411s; Web passed in 146.9s; WASM dry run passed | Build artifacts local only | Run Chrome playback matrix |
| 22 Aug 2026 | Contextual guide decision | Planning only | Four one-time coach marks + lightweight 2D Flutter-drawn guide approved | Not applicable | Implement only after audio pilot playback validation |
| 22 Aug 2026 | Landing-site direction | Planning only | Separate informational static site; supplied page is design reference only | Not deployed | Build later with product copy + signed release APK download |
| 22 Aug 2026 | Chrome audio asset-load fix | Explicit nested asset directories + debug-only load/play logs | Initial preview failed safely; loading later confirmed | Not deployed | Continue playback matrix |
| 22 Aug 2026 | Audio cue-switching + intro fix | Serialized source replacement; distinct Quick Reset welcome asset/copy | MP3 hashes/registry differ; loading/speech confirmed | Not deployed | Continue timing/pacing test |
| 22 Aug 2026 | Breathing sync + narration pacing | Preview-stop/start synchronization; 4 concise Box cues; meditation 0.88x, breathing 0.92x | User confirmed core playback works; no major blocker reported | Not deployed | Keep physical-device test pending |
| 22 Aug 2026 | Quick Reset reassurance timeline | Added 4 unique midpoint cues with matching captions; 15 MP3s total | User confirmed updated timeline works in Chrome | Not deployed | Keep physical-device audio test pending |
| 22 Aug 2026 | Floating Tide Orb navigation | Replaced standard NavigationBar with animated four-tab orb/labels; IndexedStack preserved | User liked concept but reported fast/high positioning | Not deployed | Included in Modern Shell correction |
| 22 Aug 2026 | Quiet Tide Modern shell + guide | Slowed/lowered nav; modern AppBar defaults; 2D guide; new-user four-step tour; persisted completion; Settings replay | User confirmed combined behavior works in Chrome | Not deployed | Move to Batch 8; keep physical/fresh-account matrix pending |
| 23 Aug 2026 | Batch 8 Firestore integrity | Pending-only/status-only appointment boundary; user/admin hardening; trusted/support schemas; service guards; 13 emulator cases | **13/13 passed**; Flutter 0 errors/0 warnings; smoke test passed | **Deployed to `mindmate-app-fcf2d`** | Live-smoke normal profile/contact/request/admin flows |
| 23 Aug 2026 | Batch 9A account deletion/recovery | Spark-compatible deletion, retry routing, missing-profile recovery, registration rollback, no password trimming, Settings UI | **13/13 rules passed**; Flutter gates passed; disposable-account deletion confirmed | **Profile-delete delta deployed** | Retry/recovery + external web request still pending |
| 23 Aug 2026 | Light default + Daily Snapshot fix | Correct first-run/reset theme; theme-aware wellness colours; 8-unit progress | User confirmed correct Light colours and 6/8 (75%) at Mind 5/5 | N/A | Keep physical-device check pending |
| 23 Aug 2026 | Registration/onboarding contrast fix | Register inputs match Login dark 16px style; onboarding options use surface text colour | User confirmed all registration/setup text is readable | N/A | Keep physical-device check pending |
| 23 Aug 2026 | Batch 9B runtime reliability | Wellness 0–100 caps + 4 tests; mounted-safe appointment/dashboard handling; private My Requests errors; ISO migration deferred | **5/5 tests passed**; Flutter 0 errors/0 warnings | N/A | Batch closed; proceed to AI Worker or release-matrix checks |
| 23 Aug 2026 | Batch 10 AI Worker hardening | Transparent AI identity; final Llama 3.3 70B; strict input/modes/history; crisis-first; current limiter API; health/version; client sanitization | **12/12 Worker tests passed**; Flutter ChatService tests pending | **Not deployed**; live health is old | Run local gates, deploy Worker/bindings, verify live matrix |
| 25 Aug 2026 | Batch 10 AI Worker deployment & live verification | Implemented in Worker & Flutter | **12/12 Worker tests passed**; **9/9 Flutter tests passed**; `flutter analyze` clean | **Deployed to `mindmate-ai-chat`** | Live `/health`, plan, calm, and crisis responses verified |
| 26 Aug 2026 | Batch 7B+7C full narration (breathing + all 18 meditations) | 177 unique MP3s recorded with one approved narrator (15 pilot clips re-voiced for consistency); wired into Breathing + Meditation screens with matching captions; pubspec + registry extended | Python asset audit passed (184 registry paths, 177 on disk, no orphans, 21 pubspec dirs, durations 1.94–16.90s, phase-cue fit verified); `flutter analyze`/tests/build pending on dev machine (sandbox cannot run Flutter) | Not deployed | Record Batch 7D clips (4 snapshot + 3 result), wire wellness screens, then 7E Chrome/device matrix |
| 26 Aug 2026 | Batch 7D Daily Snapshot + Wellness Result narration | 7 more MP3s (184 total) recorded; snapshot stage guides play once per stage with replay/mute in the bottom bar; result screen converted to stateful with band narration (steady/mixed/heavier) on entry + replay/mute + stop-on-exit | Python audit passed 184/184 (registry/disk/pubspec consistent, no duration anomalies, ~3.75 MB); dev-machine `flutter analyze` re-run pending (user's first run showed 0 errors, 9/9 tests, 2 warnings for the then-missing 7D dirs now fixed) | Not deployed | 7E: user runs analyze/build + Chrome playback matrix for the full library |
| 26 Aug 2026 | Batch 7E Chrome playback matrix | No code change | Dev machine: `flutter analyze` 0 errors/0 warnings (23 pre-existing informational notices, none from Batch 7); `flutter test` 9/9; Chrome run clean. User confirmed all 4 check groups: new meditation timing/captions/controls, 4-7-8 phase-cue sync, Daily Snapshot stage guides + replay/mute, result band narration | N/A | **Batch 7 closed for the prototype** (physical-device audio remains a release gate); proceed to Batch 13A |
| 26 Aug 2026 | Landing: form + email + Pages deployment | `config.js` wired with the deletion-request Google Form and `tor3x.akachukwu@gmail.com`; repo made public; Pages enabled on `gh-pages` branch (site root = landing folder) | Live site https://tor3x-coder.github.io/mindmate/ (user-confirmed) | **Deployed — GitHub Pages** | User to confirm the form button on the live `/delete-account/` page; screenshots still pending |
| 26 Aug 2026 | Batch 12 automated tests | 30 new tests in 4 files: model serialization (8 models, round-trip/uid/defaults), NextStep recommendation mapping (rendered 1+2 structure per mood), Wellness Result band behaviour, AudioGuideService lifecycle guards | Run 1 on dev machine: 36/40 passed; 4 failures were test-harness issues (assertions vs the real 2-alternatives UI, too-broad text match, just_audio plugin-missing async leak in VM) — fixed in the same batch | N/A | User re-runs `flutter test` (expect 39 total); device matrix still pending on the competition phone |
| 26 Aug 2026 | Batch 11 emergency-resource verification (part 1) | 15 missing Nigerian states added with verified numbers (all 36 + FCT now listed, incl. Lagos 767); Niger/Yobe secondary numbers added; state-card internal copy removed; professional directory now shows a "Demo data — not verified providers" banner; verification table written | Every state number checked 1:1 against the NEMSAS list published 19 Aug 2026 (ConsumerConnect report 20 Aug 2026); 112 national status confirmed (NCC + FG Jul 2026); 9 international lines verified vs standard references; findahelpline.com confirmed live via search index | N/A (in-app data) | Device pass for `tel:`/`sms:`/browser actions (Batch 12); re-verify against a fresh NEMSAS list before any public release; qualified-reviewer wording review remains a documented limitation |
| 26 Aug 2026 | Batch 13A landing site scaffold | Static site in `landing/`: index + `/delete-account/`, Quiet Tide styling, accessible/responsive, config-driven APK card (honest pre-release state), QR; docs in `landing/README.md` | Local link/structure check passed (no build step); visual check pending on deployed Pages | Not deployed — GitHub Pages chosen, config pending | User: form URL + support email + 4 real screenshots; then enable Pages (branch + `/landing` folder) and verify |
| 1 Sep 2026 | Learn section — Option B | Home featured card, topic list, article reader, six bundled static articles, and two Learn tests added; article CTAs open existing in-app tools | Flutter/Dart unavailable in Arena; test files and static content were reviewed for scope, six topics, safety framing, and required substance coverage | Not deployed; no backend or data change | Run `flutter analyze`, `flutter test`, Android/Web builds, and Chrome/device flow on the synced PC; health-literate skim articles 3–4 |
| 2 Sep 2026 | Learn widget-test visibility fixes | Made the intro icon const and kept the widget navigation tap on the visible first card instead of assuming all lazy list cards are mounted; catalogue coverage now includes the sixteen core reads and eight Explore reads | Developer PC analyzer: 0 errors/0 warnings/23 info on the prior boundary; two test runs reached 40/41 before this expansion because of lazy-list test ordering; patched, rerun pending | Not deployed; no backend or data change | Re-run `flutter test`, then build and run the Learn flow in Chrome/device; review urgent content and articles 3–4 |
| 2 Sep 2026 | Learn reader-test visibility fix | Updated the reader widget test to scroll to the end-of-article next-step card before checking it; no app behavior changed | Developer PC: focused and full test runs reached 40/41 before this patch because the reader CTA was lazily built offscreen; rerun pending | Not deployed; no backend or data change | Re-run `flutter test test/learn_screen_test.dart` and the full suite; then build and run Chrome/device checks |
| 2 Sep 2026 | Learn expansion + article-scoped AI context | Added four Learn shelves, ten core scenario reads, eight local Explore more reads with search/Add to Learn persistence, conversational headings, Ask MindMate article context, bounded ChatService/Worker payload support, and tests | Arena static checks passed; Worker `npm test` **13/13** and `node --check` passed; Flutter PC rerun completed at **47/47** with analyzer **0 errors/0 warnings** | Flutter app not deployed; Worker deployment approved but pending authenticated Cloudflare access and binding verification (live Worker remains Batch 10) | Run Android/Web builds and review urgent articles and articles 3–4; deploy the Worker through the verified dashboard/CLI path, then run live context smoke tests |
| 2 Sep 2026 | Learn Chat widget-test visibility patch | The article test now jumps the reader scroll position to its end and taps the actual `OutlinedButton`, so the Ask MindMate action must be inside the test viewport; no app behavior changed | Developer PC: analyzer **0 errors/0 warnings**; focused Learn **2/2**, catalogue/Chat **6/6**, and full Flutter suite **47/47** passed after the fix | Flutter app not deployed; Worker deployment approved but pending authenticated Cloudflare access and binding verification | Continue the documented validation order: health-literate review and later Chrome/device/release checks; deploy Worker only through the verified binding-preserving path, then run live smoke tests |
| 2 Sep 2026 | Demo account seed script | Added a one-off Firebase Admin SDK script with repeatable 21-day synthetic history, 50 production-shaped documents, target-account guard, dry-run default, explicit apply confirmation, and credential safety documentation | Node seed tests **4/4**; `node --check` passed; 50-document dry run passed; developer successfully applied the 50-document seed to the dedicated demo account | Not a deployment; only the dedicated demo account received synthetic history | **Verified in app:** demo Progress, Journal, Achievements, and history views displayed the seeded data; do not commit or share the service-account JSON |
| 2 Sep 2026 | Weekly Progress insight | Added a read-only seven-day summary card with counts, a cautious heavier-day observation, practice feedback context, empty state, and UID-only feedback loading | Developer PC: focused test **2/2**, full Flutter suite **45/45**, analyzer **0 errors/0 warnings with 23 informational notices**, and seeded demo screenshot verified | Not a deployment; no new backend data | Formatting committed separately as `7e58c90`; proceed with daily reminder validation after this batch |
| 2 Sep 2026 | Daily local reminder | Added timezone-aware local scheduling service, Morning/Afternoon/Evening slots, Android scheduling permissions/boot receiver, iOS plugin registrant hook, onboarding/settings wiring, test notification, and logout/deletion cancellation | Arena sandbox cannot run Flutter; focused reminder test, analyzer, dependency resolution, and Android/iOS runtime checks pending on the developer PC | Not deployed; no new Firestore data | Run `flutter pub get`, format/check/test from the repo root, then fire the test notification and a near-term daily schedule on Android |
| 2 Sep 2026 | Learn-context Worker dashboard deployment | Deployed the current `worker/index.js` source to the existing `mindmate-ai-chat` Worker; the visible `AI_MODEL` value remains the explicit Llama 3.3 70B FP8 Fast value | Live `/health` verified `2026-09-02-learn-context`; user confirmed the separate Bindings view shows `AI` as Workers AI; local Worker tests **13/13** and live normal/calm/Learn/crisis POST smoke all passed | Deployed to the existing Worker; no optional rate-limit/metrics bindings were previously configured or added; no landing/APK configuration changed | Continue app/device validation and review the release APK/landing checklist |
| 3 Sep 2026 | One Safe Step connection pass | Rebranded the Home entry and post-check-in screen, added the Check in → One safe step → Reflect trail, mood-aware Learn guide bridge with article-specific Chat available, high-impact human-support bridge, and direct Progress link after feedback is saved | Initial Chrome compile caught a missing `LearnArticle` import; fixed in `09cd89e`; `git diff --check` passed; Flutter/Dart runtime validation is pending on the developer PC | App code not deployed; no new backend collection; existing feedback persistence is reused | Pull `09cd89e`, rerun Chrome, then run `flutter analyze`, focused `test/next_step_recommendation_test.dart`, full `flutter test`, and the device flow |

## Rule for the next agent

Before editing code:

1. run `git status --short --branch` and `git log --oneline -10`;
2. read this file, `MINDMATE_CODING_GUIDE.md`, and `MINDMATE_REMAINING_BATCHES.md`;
3. treat the Modern Shell and Batch 8 deployment as passed;
4. treat Batch 9A normal deletion as passed; keep retry/recovery evidence open and never use the developer/admin account for destructive tests;
5. treat Light-default/registration/Daily Snapshot Chrome validation as passed;
6. treat Batch 9B's 5/5 tests and clean analyzer as passed;
7. treat Batch 10 as fully deployed and verified live (12/12 worker tests, 9/9 Flutter tests, live `/health` version `2026-08-23-batch10` with Llama 3.3 70B FP8 Fast);
8. keep `/delete-account` web requests as a Play blocker and update relevant docs in every batch; Worker deployments are separate approved actions, not automatic steps of a code batch;
9. treat Batch 7 (7A–7E Chrome) as complete: 184 clips recorded/wired, asset audit passed, dev-machine analyzer 0 errors/0 warnings + 9/9 tests, Chrome matrix user-confirmed on 26 Aug 2026; physical-device audio remains a documented release gate; Flutter commands still cannot run in the Arena sandbox.
10. **continue from the "Session handoff — 1 September 2026" block at the top of this file:** competition is 21 September (school starts 11 September), build window is 1–10 September, the four locked decisions (expanded Learn, script demo seeding, professionals Option two, and tier-two features in scope) and the build order are recorded there; the existing safety boundaries remain mandatory; the GitHub Release / landing-card item is verify-or-complete; do not start any batch work without reading that block first.
