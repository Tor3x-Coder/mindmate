# MindMate handoff for a new chat

**Last updated:** 22 August 2026

## Read these first

1. `MINDMATE_STATUS.md` — current implementation, validation, deployment state, and exact next action.
2. `MINDMATE_CODING_GUIDE.md` — collaboration, coding, UI, safety, and documentation rules.
3. This file — product direction, decisions, and broader context.
4. `worker/README.md` before changing or deploying the AI Worker.

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

Important: implementation is not proof of deployment or end-to-end operation. Firestore deployment, Worker deployment, Flutter analysis, and device verification remain unconfirmed at this checkpoint.

## Remaining backend/release work

Immediate prototype path:

1. Run `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter build apk --debug` in a Flutter environment.
2. Fix all analyzer/build errors and document each fix.
3. Test Firestore rules, deploy them, and verify owner/admin denial cases.
4. Confirm/deploy `worker/index.js`, configure required bindings, and test the live endpoint.
5. Make the final AI model decision.
6. Run the complete demo journey and emergency/appointment test matrix on Android.
7. Build a release candidate APK and freeze nonessential features.

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
- Onboarding Radio API and some Flutter APIs are deprecated but may not block the prototype.
- Some service comments are stale and should be cleaned during validation.

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

Do not start another feature. Begin **validation step 1** from `MINDMATE_STATUS.md`:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Record the results in `MINDMATE_STATUS.md`, fix any blocking issues in controlled batches, and update all relevant documentation with each fix.
