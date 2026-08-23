# MindMate guided-audio assets

**Last updated:** 22 August 2026

This directory contains offline spoken guidance. The Flutter app must not call a speech-generation provider at runtime, and no speech-provider API key belongs in Flutter.

## Pilot coverage

The Audio Sub-batch 7A pilot contains 15 MP3 files:

- 1 separate Quick Reset welcome/introduction;
- 4 distinct main Quick Reset prompts;
- 4 short Quick Reset reassurance cues;
- 1 Box Breathing introduction;
- 4 distinct Box Breathing phase cues;
- 1 Box Breathing completion cue.

Total pilot MP3 size: **379,299 bytes (about 370 KB)**.

The current pilot does not yet cover the other 17 meditation sessions, 4-7-8 Breathing, Simple Calm, Daily Snapshot, or Wellness Result. Do not describe the full audio feature as complete until those assets and integrations exist.

## Playback architecture

- `lib/services/audio_guide_service.dart` owns one shared `just_audio` player so clips cannot intentionally overlap.
- source changes are serialized and stop the active source before loading the next cue, preventing Web from sticking to the first clip;
- `lib/utils/audio_assets.dart` is the central asset-path registry.
- `AppSettingsController.soundEnabled` controls whether narration plays.
- Written guidance remains visible for accessibility and silent use.
- Quick Reset interleaves four main prompts with four short reassurance cues across the selected 1, 3, or 5-minute duration and plays at `0.88x` for a calmer pace.
- Box Breathing maps a short, different cue to each phase index, including separate full-lung and empty-lung hold wording, and plays at `0.92x`.
- starting a breathing session stops any preview introduction, loads the first phase cue, and only then starts the countdown.

## Pilot transcript

### Quick Reset

- Introduction: “Hi, I’m your MindMate guide for this session. Find a comfortable position, and when you’re ready, we’ll begin with a gentle reset. There’s nothing to get perfect here. Just follow at your own pace.”

1. Main: “Settle into a position that feels easy. Let your hands rest, and allow your shoulders to drop away from your ears.”
2. Reassurance: “Stay with this slow, steady breath.”
3. Main: “Notice where your body is holding tension. You do not need to force it away. Breathe gently into that space.”
4. Reassurance: “Easy and unhurried. Let your body soften.”
5. Main: “As you breathe out, imagine releasing just a little of the pressure. Nothing else needs to be solved in this moment.”
6. Reassurance: “You’re doing well. Keep going gently.”
7. Main: “Take one more unhurried breath. Notice any small sense of space you have created, and carry it with you when you are ready.”
8. Reassurance: “Take your time. We’ll finish softly.”

### Box Breathing

- Introduction: “We’ll use a steady box rhythm: in, hold, out, and rest. Keep every breath comfortable. If a hold feels strained, return to your natural breathing.”
- Inhale: “Breathe in, slowly.”
- Full hold: “Hold gently.”
- Exhale: “Breathe out, slowly.”
- Empty hold: “Rest here. Stay soft.”
- Completion: “Let your breathing return to its natural rhythm. Notice any steadiness you found, even if it was small.”

## Validation status

Completed locally after the pilot:

- `flutter pub get` resolved `just_audio` successfully;
- `flutter analyze` reported 0 errors, 0 warnings, and the same 21 pre-existing informational notices;
- the single smoke test passed.

- the post-audio Android debug build passed in 411 seconds after recovering from stale depfiles left by the power interruption;
- the Web build passed in 146.9 seconds and its WASM dry run succeeded.

Initial Chrome playback exposed an asset-packaging bug: Flutter did not include deeply nested MP3 directories from the parent `assets/audio/` entry. Explicit declarations fixed loading.

The next Chrome test confirmed playback but exposed source switching: phase/prompt text changed while the first loaded clip repeated. Source replacement is serialized with an explicit stop, and debug builds log every loaded asset path. Quick Reset also has a separate welcome clip so preview never plays Prompt 1.

A later timing test showed the Box introduction could continue into the active timer and long phase sentences could be cut off. Start now stops the preview and waits for Cue 1 before beginning; all four phase clips were regenerated as concise commands. The user then confirmed the core breathing/meditation fixes worked.

The newest change adds four midpoint reassurance cues to reduce long silent stretches without removing all intentional quiet. The user confirmed the updated Quick Reset/Box pilot works in Chrome. Literal human breathing loops and background music are not included in this batch. Later ambience must be optional, licensed, loop-safe, separately volume-controlled, and duck under speech.

Still required:

- verify the 8-cue Quick Reset timeline across all 1/3/5-minute options during the release matrix;
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
- add each directory containing audio files to `pubspec.yaml`; Flutter directory entries do not automatically bundle arbitrary deeper subdirectories;
- record exact file count/size, tests, and remaining coverage after each audio batch.
