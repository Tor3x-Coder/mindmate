# MindMate competition release freeze

**Freeze date:** 5 September 2026  
**Branch:** `arena/01a05e3e-mindmate`  
**Release candidate:** `1.0.1+2`

## Frozen release outputs

- Android APK: `build/app/outputs/flutter-apk/app-release.apk`
- APK size: 65.4 MB
- APK SHA-256: `53FA8EDF9C728F288529C6533B92D31260D0CE3F1BCF1601B2FAC3B65F6AA073`
- Android App Bundle: `build/app/outputs/bundle/release/app-release.aab` (54.2 MB)
- Hosted Flutter Web: <https://mindmate-app-fcf2d.web.app>
- Competition QR: `docs/mindmate-web-qr.png`

## Gates completed

- Flutter test suite: **53/53 passed**
- Flutter analyze: no errors; existing informational lints only
- Release APK built successfully and installed/copied for device testing
- Release App Bundle built successfully
- Flutter Web release built and deployed to Firebase Hosting
- Chrome responsive smoke test passed
- Chat history, Learn context, trusted crisis action, and Emergency Support flow manually validated
- Web favicon/PWA icons use the MindMate phone icon rather than the default Flutter mark

## Remaining external check

The final Safari check needs an available iPhone. It is not a code gate for this freeze: use the QR or the hosted URL when the coach's phone is available. Chrome responsive testing has already covered the narrow layout.

## Freeze rules

Do not change production Dart, Worker, Android, web, Firebase, dependency, or asset files after this point without creating a new release candidate and rerunning the full gates. Presentation slides, demo notes, screenshots, and other competition documents may still be prepared.

Do not upgrade the 34 packages reported by `flutter pub get` during the competition sprint. Do not add payment, subscriptions, ads, or monetisation code to this candidate.

## Recovery copies

Keep the signed APK, AAB, APK hash, hosted URL, and QR together in the competition backup folder. If a code change becomes unavoidable, preserve this candidate and label the new build separately.
