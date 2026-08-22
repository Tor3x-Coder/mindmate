# MindMate guided-audio assets

**Last updated:** 22 August 2026

This directory contains offline spoken guidance. The Flutter app must not call a speech-generation provider at runtime, and no speech-provider API key belongs in Flutter.

## Pilot coverage

The first Audio Sub-batch 7A pilot contains 10 MP3 files:

- 4 distinct timed prompts for Meditation → Stress Relief → Quick Reset;
- 1 Box Breathing introduction;
- 4 distinct Box Breathing phase cues;
- 1 Box Breathing completion cue.

Total pilot asset size: **280,242 bytes (about 274 KB)**.

The current pilot does not yet cover the other 17 meditation sessions, 4-7-8 Breathing, Simple Calm, Daily Snapshot, or Wellness Result. Do not describe the full audio feature as complete until those assets and integrations exist.

## Playback architecture

- `lib/services/audio_guide_service.dart` owns one shared `just_audio` player so clips cannot intentionally overlap.
- `lib/utils/audio_assets.dart` is the central asset-path registry.
- `AppSettingsController.soundEnabled` controls whether narration plays.
- Written guidance remains visible for accessibility and silent use.
- Quick Reset schedules four prompt clips across the selected 1, 3, or 5-minute duration.
- Box Breathing maps a different cue to each phase index, including separate full-lung and empty-lung hold wording.

## Pilot transcript

### Quick Reset

1. “Settle into a position that feels easy. Let your hands rest, and allow your shoulders to drop away from your ears.”
2. “Notice where your body is holding tension. You do not need to force it away. Breathe gently into that space.”
3. “As you breathe out, imagine releasing just a little of the pressure. Nothing else needs to be solved in this moment.”
4. “Take one more unhurried breath. Notice any small sense of space you have created, and carry it with you when you are ready.”

### Box Breathing

- Introduction: “We will breathe in four equal parts. Keep every breath comfortable. If holding your breath feels strained, return to your normal breathing at any time.”
- Inhale: “Breathe in slowly and steadily.”
- Full hold: “Hold gently. Keep your face and shoulders soft.”
- Exhale: “Breathe out at the same steady pace.”
- Empty hold: “Rest here for a moment before the next breath begins.”
- Completion: “Let your breathing return to its natural rhythm. Notice any steadiness you found, even if it was small.”

## Validation status

Completed locally after the pilot:

- `flutter pub get` resolved `just_audio` successfully;
- `flutter analyze` reported 0 errors, 0 warnings, and the same 21 pre-existing informational notices;
- the single smoke test passed.

- the post-audio Android debug build passed in 411 seconds after recovering from stale depfiles left by the power interruption;
- the Web build passed in 146.9 seconds and its WASM dry run succeeded.

Still required:

- confirm prompt timing and no overlap in Chrome;
- test an Android emulator;
- test audio focus, routing, interruption, and volume on a physical phone before release;
- verify the empty-hold cue finishes comfortably inside the 4-second Box Breathing phase;
- review narration wording and voice-generation usage rights before public distribution.

## Replacing or adding narration

- keep speech concise enough for its timer interval;
- use one consistent approved narrator unless the product decision changes;
- use compressed MP3 and normalize loudness across clips;
- preserve or update the matching written caption/transcript;
- add every new path to `lib/utils/audio_assets.dart`;
- declare only the parent `assets/audio/` path in `pubspec.yaml`;
- record exact file count/size, tests, and remaining coverage after each audio batch.
