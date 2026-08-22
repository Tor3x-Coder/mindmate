# MindMate coding guide

Read this with `MINDMATE_HANDOFF.md` before making any MindMate change. This guide exists so a new chat/agent follows the same conventions and does not introduce a different coding style.

## Collaboration rules

- Speak to the developer casually and plainly, but explain programming terms in brackets.
- Do not make app-code edits until the developer explicitly approves the change.
- Before changing a screen, show two strong UI/UX options and mark the preferred one with `[RECOMMENDED]`.
- If the developer has selected an option, implement only that option.
- Do not redesign excluded splash/illustration-first screens or the existing Login/Register screens unless a functional bug is found.
- Do not ask for the whole project. Ask only for the relevant file(s).
- Treat the developer's pasted code as the source of truth for their local project. Do not assume that a workspace draft has been copied into `T:\Dev\mindmate`.
- Do not invent field names, class names, file paths, phone numbers, crisis resources, or backend methods. Inspect first or clearly label a new dependency.
- After every batch, require `flutter analyze` and clear all severity 8 errors before moving on. Informational/deprecation warnings can be grouped for later cleanup.

## Small-fix instruction format

For a small fix, do not provide vague directions such as “find the method.” Use:

1. File path.
2. Exact text to find with Ctrl+F.
3. Exact replacement, or exact text to paste directly below it.
4. Explain why the fix is needed.
5. Explain how to test it.

If there may be multiple matches, say which occurrence. If a change is large or has many dependencies, say that replacing the whole file is safer and list every required file/method.

## Flutter/Dart style

- Use two-space indentation.
- Use `const` where it is genuinely valid, but do not turn non-const widget trees into invalid `const` trees.
- Use clear private helper widgets for repeated UI.
- Dispose every `TextEditingController`, `FocusNode`, `ScrollController`, `Timer`, and `AnimationController` owned by a State object.
- Check `mounted` after async gaps before calling `setState`, using `context`, showing a SnackBar, or navigating.
- Do not trim passwords. Trim emails and ordinary text where appropriate.
- Keep UI, data, and network responsibilities separate.

## MindMate architecture

- `screens/`: widgets and user flows.
- `models/`: data classes with `fromMap`/`toMap`.
- `services/`: Auth, Firestore, settings, and chat/network operations.
- `utils/app_theme.dart`: all shared theme colours and component styles.
- `utils/constants.dart`: Firestore collection names and shared option lists.
- Use `Provider` consistently:
  - `context.read<T>()` for an action/service call.
  - `context.watch<T>()` when the widget should rebuild from changes.
- Do not call Firestore directly from a screen when a `FirestoreService` method should own the operation.
- When adding a service method, update the service, rules, model, and consuming screen as one dependency-aware batch.
- Do not claim a feature is implemented until its imports, methods, rules, and navigation are all present.

## UI rules

- Current direction is the Quiet Tide palette:
  - Ink: `#182A35`
  - Tide: `#2E7D73`
  - Sea Glass: `#B8DFD2`
  - Sand: `#F4E7D4`
  - Coral: `#D9776A`
- Prefer theme values over raw screen-specific colours.
- Avoid duplicating the Home layout on Practice or other screens.
- Keep one clear primary action per screen.
- Provide loading, empty, error, and disabled states.
- Make copy match the user's mood and context; do not use crisis language for positive moods.
- Avoid fake precision, especially numerical emotional/medical claims.
- Never present a heuristic wellness score as a diagnosis or clinical measurement.

## AI and sensitive data

- The Cloudflare Worker is the only AI backend endpoint used by Flutter.
- No AI provider secret belongs in Flutter.
- The AI is a transparent AI companion, not a human, therapist, doctor, or emergency service.
- Use AI for supportive conversation, reflection, and small plans; not diagnosis, prescription, or safety decisions.
- Journal reflection must be opt-in. Do not send a user's entire journal history automatically.
- Crisis handling needs a deterministic safety route before normal generation.
- Validate client-supplied chat history roles and limit message/history sizes.
- Do not expose raw Worker/provider error details to users.

## Firestore and privacy

- Personal data must be owner-only.
- On update, preserve the original document UID.
- Admin access must be enforced by Firestore rules, not only by hiding UI.
- Every new collection requires a matching rule block.
- Queries combining `where` and `orderBy` may require composite indexes.
- Journal, chat, mood, thought, and appointment data are sensitive.
- Add deletion/export/privacy controls where the feature stores personal data.

## Product decisions

- MindMate's core loop is:

```text
Check in -> recommend one next step -> try it -> ask whether it helped ->
offer another approach or human support
```

- Feedback options include better, same, worse, and not sure; never force a success claim.
- Mood impact uses words such as A little, Somewhat, A lot, Overwhelming, and Not sure yet instead of a numeric slider.
- Professional support is request-based, not instant booking.
- A real professional system is planned: professional accounts, roles, provider inbox, approval/decline, notifications, availability, and calendar handling.
- Trusted-contact actions must be user-triggered; the app must never contact someone silently.

## Before handing over code

Confirm:

- The file path matches the local project.
- Every new import points to a real file.
- Every new method called by a screen exists in the service.
- Every new stored collection has Firestore rules.
- Existing features and routes were not accidentally removed.
- No secrets or private credentials were added.
- The user has an exact test path.
- The user knows which changes are approved and which are only drafts.
