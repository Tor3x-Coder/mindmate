# MindMate

A Flutter wellness app for everyday mental health support — mood tracking, journaling, guided breathing and meditation, CBT-style thought reframing, an AI companion chat, and a directory to connect with real wellness professionals.

Built as a Junior Achievers school project. Not a diagnostic or clinical tool — MindMate never diagnoses conditions, prescribes treatment, or gives emergency medical advice directly. It points to real crisis resources instead.

## Tech stack

- **Flutter** (Dart) — tested primarily via `flutter run -d chrome`
- **Firebase Auth** — email/password authentication
- **Cloud Firestore** — all user data (mood logs, journal entries, meditation history, thought records, appointments, etc.)
- **Provider** — state management
- **Cloudflare Workers AI** — powers the AI companion chat (free tier, avoids the Firebase Blaze paywall)
- **model_viewer_plus** — renders a 3D meditation guide figure (`.glb` model)

## Features

**Built and working:**
- Auth (register/login, show-password toggle, Terms checkbox)
- Onboarding + splash carousel
- Dashboard with bottom nav (Home / Practice / Chat / Me)
- Mood check-in with "always give a next step" response pattern
- Journal — create, edit, delete entries, diary-style visuals
- Guided breathing (3 patterns: Box, 4-7-8, Simple Calm) with an animated breathing figure
- Guided meditation — 6 categories × 3 sessions each, with a 3D meditation guide model
- Wellness assessment (computed stress quiz)
- Progress tracking
- CBT thought-reframe wizard (7-step guided exercise, saved to Firestore)
- Achievements / gamification
- Professional support directory + admin panel + appointment requests (request-based, not instant booking)
- Emergency Support screen (currently Nigeria-specific: 112 national, 767 Lagos, MANI, SURPIN — needs to become location-aware before wider release)
- AI companion chat — supportive listener, not a licensed therapist; detects crisis language and redirects to Emergency Support
- Personalization / pattern detection across mood & wellness history
- Light + dark theme support
- Session persistence (stays logged in across app restarts)

**Known gaps / not yet built:**
- Real audio for breathing/meditation (currently silent timer + on-screen guiding text — this is the single biggest gap vs. apps like Headspace/Calm)
- Meditation guide model has no animation yet (static 3D figure, exploring AI text-to-motion tools)
- Email verification after registration
- Android / real-device testing (Chrome-only so far)
- App icon + app name still likely default Flutter
- Release APK build
- Privacy Policy + real Terms & Conditions legal review
- Adversarial "break it" testing pass before any public release
- Community/peer support — intentionally on hold until there's a real moderation plan

## Project structure

```
lib/
  models/       # Data classes (fromMap/toMap pattern)
  screens/      # One folder per feature area
  services/     # firestore_service.dart, auth_service.dart, chat_service.dart, etc.
  utils/        # app_theme.dart (AppTheme), constants.dart (FirestoreCollections)
assets/
  models/       # 3D .glb models for meditation guide
```

**Patterns used throughout:**
- Every feature = a model (`fromMap`/`toMap`) + a pair of methods in `firestore_service.dart` (`addX()` / `xForUser(uid)` stream) + a screen
- Collection name strings live in `utils/constants.dart` as `FirestoreCollections` — never hardcoded
- Theme colors come from `utils/app_theme.dart` (`AppTheme`) — supports light and dark mode throughout
- Current uid via `context.read<AuthService>().currentUser?.uid`

## Setup

1. Clone the repo and run `flutter pub get`
2. Firebase project must be configured (`firebase_options.dart` — not committed, set up your own via FlutterFire CLI)
3. Firestore security rules: per-uid locked down (see `firestore.rules`) — any new collection needs a matching rule block or writes will fail with `permission-denied`
4. Any Firestore query combining `.where()` with `.orderBy()` needs a composite index — Firebase will give you a console link the first time it's queried
5. AI chat requires the Cloudflare Worker (`mindmate-ai-chat`) to be deployed and its URL set in `chat_service.dart`
6. Run with `flutter run -d chrome` (web) — for local testing across restarts, use a fixed port so login sessions persist: `flutter run -d chrome --web-port=5000`
7. For the 3D model viewer on web, `web/index.html` must include:
   ```html
   <script type="module" src="./assets/packages/model_viewer_plus/assets/model-viewer.min.js" defer></script>
   ```

## License / attribution

If any third-party 3D models, icons, or assets with attribution requirements are used, credit them here:

- *(add model/asset credits as they're added)*