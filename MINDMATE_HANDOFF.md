# MindMate handoff for a new chat

**Also read:** `MINDMATE_CODING_GUIDE.md` before making any edit. It contains the exact collaboration, coding, UI, safety, and fix-instruction rules to keep a new chat consistent.

## User working style

- Speak casually and plainly (“bro”), but explain programming terms in brackets.
- Do not make app-code edits without explicit approval.
- For each screen, create two strong UI options and mark the preferred one with `[RECOMMENDED]` before implementation.
- User prefers exact small-edit instructions:
  - file path;
  - exact text to find with Ctrl+F;
  - exact replacement or exact text to paste below it;
  - explain why and how to test.
- Do not ask for the whole project. Request only the relevant file(s).
- Do not treat paste indentation as a bug if the actual app compiles.

## Product direction

MindMate is a real-world, action-first mental wellness companion, not a school-project app.

Core promise:

> Help a person move from “I do not know what to do right now” to one small, personalised, safe next step.

Core loop:

```text
Mood check-in -> understand the need -> recommend one action -> user tries it ->
ask whether it helped -> offer another approach or human support
```

MindMate is not a diagnostic tool, therapist, doctor, medical device, or emergency service.

## AI direction

Keep AI, but it is AI-supported, not AI-first.

- Current AI uses a Cloudflare Worker and Cloudflare Workers AI.
- No provider API key is inside Flutter; `env.AI` is configured in Cloudflare.
- AI should support conversation, reflection, journal reflection (with consent), and small plans.
- It must not diagnose, prescribe, claim to be human, or handle crises as normal chat.
- Later AI backend batch: pass structured modes (`listen`, `calm`, `make_plan`), improve prompt, avoid generic replies/assumptions, validate history roles, limit history/message sizes, deterministic crisis routing, rate limiting, fallback.
- Current chat history is memory-only; no past-chat screen/storage yet.

## Frontend decisions and current implementation

Selected/implemented directions:

- Quiet Tide palette.
- Home: Option A — Today, One Step.
- Practice: Option A — Practice Map.
- Journal: Option A — Private Diary.
- Breathing: new Sanctuary design was rejected; original former breathing screen was restored.
- Meditation: Option A — Meditation Journey.
- CBT: Option A — Guided Path with 9-category branching.
- Progress: Option A — Your Story.
- Achievements: Option A — Wins Shelf.
- Chat: Option A — Guided Conversation.
- Me/Settings: Option A — Personal Space.
- Emergency: Option A — Immediate Help; no fake trusted-person button.
- Professional directory: Option A — Find the Right Person.
- Professional detail: Option A — Profile & Request.
- Appointment request: Option A — Request in Steps.
- My Requests: Option A — Request Tracker.
- Admin appointment review: Option A — Review Queue.
- Admin professionals: Option A — Directory Manager.
- Professional form: Option A — Guided Listing Setup.
- Terms/Privacy: Option A — Readable Legal.
- Illustration onboarding carousel was confirmed and updated; splash/illustration-first screens are excluded from further redesign.
- Existing Login/Register screens are intentionally left as-is.
- Wellness Check: Option A — Daily Snapshot.
- Wellness Result: Option A — Reflection & Next Step.

Workspace files were created/updated under `/home/user/lib/...`; the user’s actual local project is `T:\Dev\mindmate`, so files must be copied manually.

## Important frontend details

- Mood impact uses words, not a numeric slider: A little, Somewhat, A lot, Overwhelming, Not sure yet.
- CBT branching categories: Relationship, School/work, Mistake/regret, Future worry, Self-doubt, Sad/low, Angry/frustrated, Hurt/disappointed, Something else.
- `Something else` uses a neutral fallback question path.
- Post-activity feedback: Much worse, A little worse, About the same, A little better, Much better, Not sure yet.
- Journal is private first; optional AI reflection later with explicit consent.
- Trusted contact concept is planned: user adds name/phone/relationship, app launches `tel:`/`sms:` only after user taps, then asks whether they connected. Do not contact anyone silently.
- Home has a “Need help right now?” entry point to Emergency Support.
- Emergency screen currently preserves 112 and 767; MANI/SURPIN open Find a Helpline. Verify all resources before public release.
- Appointments are request-based, not instant booking. Current model has pending/approved/declined.

## Current backend gaps

- Add `/thought_records/{docId}` rule; current CBT save previously failed with permission-denied because this rule was missing.
- Use the stricter user rules that protect `isAdmin` and prevent profile deletion; do not use simple `allow read, write` on user profiles because users could self-grant admin.
- Preserve UID during updates for every personal collection.
- Ensure `requestAppointment()`, `allAppointmentsForAdmin()`, and `updateAppointmentStatus()` exist in `FirestoreService`.
- Admin appointment review UI exists but needs those service methods and navigation wiring.
- One pending request per professional policy: current frontend guard blocks exact same professional/date/time active request; stronger policy should block any pending request to the same professional and be enforced server-side later.
- Save mood impact and activity feedback.
- Add feedback/recommendation data model.
- Add trusted-contact collection/rules and support-action event tracking.
- Real professional system later: professional accounts, provider roles, provider inbox, notifications, availability/calendar.

## Known code issues already logged

- Do not trim passwords.
- Login must handle missing Firestore profile.
- Registration can create Auth account without profile if Firestore write fails.
- Several async catch blocks need mounted checks.
- Date models currently assume ISO strings.
- Wellness score components need capping at 100.
- Progress/other streams need friendly error states.
- Some screens still have hardcoded old colours.
- Onboarding Radio API and some Flutter APIs are deprecated but not blockers.

## Competition

- Competition: 11 September 2026.
- Target feature freeze: 28 August 2026.
- Current date in this handoff: 22 August 2026.
- The competition accepts prototypes. Prioritise one polished demo journey and reliability over extra features.

Demo journey:

```text
Check in -> personalised next step -> complete activity -> feedback ->
alternate action/support route
```

## Immediate next action

The frontend screen design pass is largely complete. Start a new chat with this handoff and move into backend/integration in controlled batches:

1. Firestore rules and service methods.
2. Feedback and mood-impact persistence.
3. Admin/professional request workflow.
4. AI Worker modes/safety/history.
5. Trusted contacts/support events.
6. Testing, Android APK and competition freeze.
