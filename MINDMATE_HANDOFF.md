# MindMate handoff for a new chat

**Last updated:** 22 August 2026

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

- **Guided audio is currently missing and is competition-critical.** There are no audio assets or playback/TTS dependency; Meditation is timed text guidance, Breathing is visual/text guidance, and the Sound setting is only a placeholder. The user must choose the audio MVP option in `MINDMATE_REMAINING_BATCHES.md` before implementation.
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

Important: implementation is not proof of end-to-end operation. The final Batch #5 Firestore rules were compiled and released successfully to `mindmate-app-fcf2d` on 22 August 2026. Local `flutter pub get` and `flutter analyze` succeeded with 0 errors, 0 warnings, and 21 non-blocking informational notices. `flutter test` passed the repository's single basic smoke test. Firestore denial tests, Worker deployment, APK builds, meaningful test coverage, and runtime verification remain pending.

## Remaining backend/release work

Immediate prototype path:

1. Complete Batch 6 baseline: build the debug APK and use an Android emulator for startup if practical; the smoke test already passed.
2. Complete the user-approved Batch 7 guided-audio MVP; do not leave the Sound setting as a placeholder.
3. Harden/test the deployed Firestore rules and verify owner/admin denial cases; redeploy only after a rule change passes tests.
4. Fix account/runtime reliability issues from Batch 9.
5. Confirm/deploy `worker/index.js`, configure required bindings, test the live endpoint, and make the final AI model decision.
6. Verify emergency resources and sensitive content.
7. Run meaningful automated tests plus the complete device test matrix.
8. Build a release candidate APK and freeze nonessential features.

See `MINDMATE_REMAINING_BATCHES.md` for tasks and exit criteria for Batches 6–13.

Known backend/product limitations that may be deferred beyond the competition prototype:

- the one-pending-appointment check is a client/service guard, not authoritative server-side uniqueness enforcement;
- Firestore appointment rules still need stricter field validation, including `status == 'pending'` on create and restricted mutable fields;
- real professional accounts, roles, provider inboxes, notifications, and calendars;
- persistent AI chats;
- opt-in journal AI reflection;
- privacy export/deletion controls;
- registration rollback/profile recovery;
- production moderation and operational review.

## Known code issues already logged

- Do not trim passwords.
- Login must handle a missing Firestore profile.
- Registration can create an Auth account without a profile if the Firestore write fails.
- Several async catch blocks may still need mounted checks.
- Date models currently assume ISO strings.
- Wellness score components need capping at 100.
- Streams need consistent friendly loading, empty, and error states.
- Some screens still have hardcoded legacy colours.
- Current analyzer debt is non-blocking: 2 deprecated onboarding Radio API notices and 19 optional `const` notices.
- `flutter pub get` reports 22 newer package versions outside current constraints; avoid major upgrades before the competition unless required and tested.
- Some service comments are stale and can be cleaned during a controlled pass.

## Competition

- Competition: 11 September 2026.
- Target feature freeze: 28 August 2026.
- Current handoff date: 22 August 2026.
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

First, get the user's explicit audio decision from `MINDMATE_REMAINING_BATCHES.md`:

- Option A — curated natural-voice launch pack `[RECOMMENDED]`; or
- Option B — device text-to-speech for all current sessions.

The smoke test passed. Finish the Batch 6 build gate so audio is not mixed with an unknown Android compilation failure:

```bash
flutter build apk --debug
```

The developer has no physical phone. Use an Android emulator if practical and Chrome for broad UI/Firestore checks; keep phone-only behavior explicitly unverified until a borrowed or competition device is available.

After recording the APK result, implement only the approved audio option in a controlled batch. An optional competition landing page is proposed as Batch 13A and must not delay core app release work.
