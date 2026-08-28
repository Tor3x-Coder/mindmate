# MindMate guided-audio assets

**Last updated:** 26 August 2026

This directory contains offline spoken guidance. The Flutter app must not call a speech-generation provider at runtime, and no speech-provider API key belongs in Flutter.

## Coverage (Batch 7A–7D complete — 184/184)

- **All 3 breathing patterns** — Box, 4-7-8, Simple Calm: unique intro, phase cues fitted to each phase length, and completion cue.
- **All 18 meditation sessions** — unique intro, 4 main prompts reading the session's guiding lines, and 4 short reassurance cues (the same 8-cue timeline shape as the validated Quick Reset pilot).
- **Daily Snapshot** — one short guide per major stage: Body, Mind, Routine, Review (`assets/audio/snapshot/`).
- **Wellness Result** — one safe narration per band: steady (>= 70), mixed (40–69), heavier (< 40) (`assets/audio/wellness_result/`). No score read-out, no diagnosis or medical language; each points to the displayed next step.
- The original 15 pilot clips were **re-voiced with the newly approved narrator** so the entire app uses one consistent natural voice.
- **184 MP3 files, 3,840,792 bytes (about 3.75 MB)**, durations verified, no anomalies.

## Playback architecture

- `lib/services/audio_guide_service.dart` owns one shared `just_audio` player so clips cannot intentionally overlap.
- Source changes are serialized and stop the active source before loading the next cue, preventing Web from sticking to the first clip.
- `lib/utils/audio_assets.dart` is the central asset-path registry (184 paths).
- `AppSettingsController.soundEnabled` controls whether narration plays.
- Written guidance remains visible for accessibility and silent use.
- Meditation plays at `0.88x`; Breathing at `0.92x`.
- Meditation interleaves 4 main prompts with 4 short reassurance cues across the selected 1, 3, or 5-minute duration.
- Breathing maps a short, different cue to each phase index, and phase cue lengths were verified to fit their timer intervals (Box 4s phases: cues 2.0–3.4s raw; 4-7-8: 3.2–3.9s raw for 4/7/8s phases; Simple Calm: 2.6–3.5s raw for 5s phases).
- Starting a breathing session stops any preview introduction, loads the first phase cue, and only then starts the countdown.

## Transcripts

### Breathing — Box
- Intro: “We’ll use a steady box rhythm: in, hold, out, and rest. Keep every breath comfortable. If a hold feels strained, return to your natural breathing.”
- Inhale: “Breathe in, slowly.”
- Full hold: “Hold gently.”
- Exhale: “Breathe out, slowly.”
- Empty hold: “Rest here. Stay soft.”
- Completion: “Let your breathing return to its natural rhythm. Notice any steadiness you found, even if it was small.”

### Breathing — 4-7-8
- Intro: “We’ll use the four, seven, eight rhythm. Breathe in for four, hold for seven, and breathe out slowly for eight. The long out-breath is what settles the body. Keep everything comfortable.”
- Inhale (4s): “Breathe in, for four.”
- Hold (7s): “Hold, gently. No strain.”
- Exhale (8s): “Breathe out, slow and long.”
- Completion: “Let your breath return to its natural rhythm. Notice the settle the long out-breaths brought, however small.”

### Breathing — Simple Calm
- Intro: “Let’s try simple, even breathing. In for five, out for five. No holds, no pressure. Just a smooth, steady rhythm that is easy to follow.”
- Inhale (5s): “Breathe in, easily.”
- Exhale (5s): “Breathe out, smoothly.”
- Completion: “Settle back into your natural breathing. Notice the calm that stays with you, even if it is small.”

### Meditation — Stress Relief

**Quick Reset**
- Intro: “Hi, I’m your MindMate guide for this session. Find a comfortable position, and when you’re ready, we’ll begin with a gentle reset. There’s nothing to get perfect here. Just follow at your own pace.”
1. “Settle into a position that feels easy. Let your hands rest, and allow your shoulders to drop away from your ears.”
2. “Stay with this slow, steady breath.”
3. “Notice where your body is holding tension. You do not need to force it away. Breathe gently into that space.”
4. “Easy and unhurried. Let your body soften.”
5. “As you breathe out, imagine releasing just a little of the pressure. Nothing else needs to be solved in this moment.”
6. “You’re doing well. Keep going gently.”
7. “Take one more unhurried breath. Notice any small sense of space you have created, and carry it with you when you are ready.”
8. “Take your time. We’ll finish softly.”

**Release Tension**
- Intro: “This is a body scan for release. We’ll move slowly from the head down, softening each place that is holding tight. Nothing needs to be forced. Just noticed, and let go.”
1. “Start at your forehead. Let it smooth out.”
2. “Soften one place. Then another.”
3. “Move down to your jaw. Unclench it, just slightly.”
4. “Tightness can relax when you let it.”
5. “Notice your hands. Let them go loose and heavy.”
6. “Heavy hands. Loose fingers.”
7. “Let your whole body feel supported and at ease.”
8. “Let the body take the weight.”

**Calm the Storm**
- Intro: “When everything feels like too much at once, we slow the world down. You don’t need to fix anything here. We just ride the feeling through, one breath at a time.”
1. “This feeling is loud right now, but you can take one moment at a time.”
2. “The wave can rise and fall.”
3. “You do not have to solve everything in this moment.”
4. “You don’t have to answer anything yet.”
5. “Just this breath. Just this one.”
6. “One breath is enough for now.”
7. “Let the next few minutes be a pause from the pressure.”
8. “The pause is real. You’re in it.”

### Meditation — Sleep

**Wind Down**
- Intro: “It’s time to ease out of the day. Lie comfortably, let your eyes close, and let each breath be a little softer than the one before. There’s nothing left to do tonight.”
1. “Let your body sink into wherever you are lying.”
2. “Sinking in, sinking down.”
3. “Slow your breathing, a little more with each cycle.”
4. “A little slower with each breath.” *(reworded from “Slower now, with every out-breath” after the original wording was declined by the content filter; caption and audio match)*
5. “There is nothing else you need to complete right now.”
6. “The day’s list can wait.”
7. “Let your thoughts drift without following them.”
8. “Drift is allowed here.”

**Quiet Night**
- Intro: “Let’s picture a quiet room, softly lit and completely still. No lights, no noise, no demands. Just the dark, and your slow breath, carrying you toward rest.”
1. “Picture a quiet room, softly lit and still.”
2. “The room is still. So are you.”
3. “Every breath out lets you settle a little deeper.”
4. “Deeper with every breath.”
5. “Nothing here needs your attention right now.”
6. “Your attention can rest now.”
7. “Let the quiet hold you until rest arrives.”
8. “The quiet is holding you.”

**Deep Rest**
- Intro: “If your mind keeps replaying the day, this is your permission to stop. You don’t need to resolve anything tonight. We just let the thoughts pass, and let the body rest.”
1. “The day is over now. It does not need replaying.”
2. “Let it drift on by.”
3. “Let each thought pass by like a cloud, not a task.”
4. “Not a task. Just weather.”
5. “Your body already knows how to rest. Give it time.”
6. “Rest is already happening.”
7. “Soft breath in. Slow breath out. That is enough for now.”
8. “Soft in, slow out. Enough.”

### Meditation — Focus

**Clear Mind**
- Intro: “Before you begin, let’s clear the noise. A few slow breaths, and whatever was circling your mind gets parked outside this moment. You can start from a clean, clear place.”
1. “Sit upright, alert but relaxed.”
2. “Arriving, one breath at a time.”
3. “Take three slow breaths to arrive in this moment.”
4. “Noted. Set aside. Back to now.”
5. “Notice distracting thoughts, then set them aside for now.”
6. “The clutter can wait outside.”
7. “Begin when you feel ready.”
8. “Ready when you’re ready.”

**Pre-Study Focus**
- Intro: “You’re about to study, and this is your short warm-up. We’ll take the task off the shoulders of everything, and put it back where it belongs. One small, clear next step.”
1. “Picture the task ahead calmly, one step at a time.”
2. “One step. That’s all it takes.”
3. “You do not need to know it all yet. Just the next step.”
4. “Next step, not the whole mountain.”
5. “Let confidence settle in where doubt was sitting.”
6. “Confidence is building quietly.”
7. “Start with one clear, manageable action.”
8. “One clear action to begin with.”

**Deep Work Prep**
- Intro: “For the longer, deeper work ahead, we prepare the mind the way you’d prepare a desk. Clear, ordered, and protected from interruption. Let’s steady the breath, and narrow the focus.”
1. “Breathe in for four counts, out for four counts.”
2. “Four in, four out. Keep the pace.”
3. “Let your mind narrow gently toward one task.”
4. “Narrowing in, gently.”
5. “Distractions can wait. This block of time is protected.”
6. “The block is protected. Guard it.”
7. “Settle into focus now, steady and clear.”
8. “Steady now. Clear now.”

### Meditation — Anxiety

**Grounding**
- Intro: “When the mind races ahead or back, we come back to the ground. Real sounds, real weight, real support under you. This is the present moment, and it is enough.”
1. “Notice five things you can hear right now.”
2. “Listen. That’s the now.”
3. “Feel where your body meets the chair or floor.”
4. “You’re here. The chair is here.”
5. “Notice the support beneath you in this moment.”
6. “Supported, fully, right now.”
7. “One breath at a time is all that is being asked of you.”
8. “Just the next breath. Nothing else.”

**Steady Breath**
- Intro: “A steady body helps a steady mind. We’ll slow the breath on purpose. In for four, a gentle hold, and a long soft release. Let’s find that rhythm together.”
1. “Breathe in slowly through your nose, four counts.”
2. “Slow in, gentle hold.”
3. “Hold gently for a moment, without straining.”
4. “Soft out, shoulders down.”
5. “Breathe out slowly, letting your shoulders drop.”
6. “Steadier with every cycle.”
7. “Each cycle can bring a little more steadiness.”
8. “The body is settling in.”

**Anxious Thoughts, Softened**
- Intro: “Worried thoughts can feel huge when you’re inside them. From a little distance, they’re just weather. We’ll notice each one, let it pass, and keep coming back to the breath.”
1. “A worried thought is a thought, not a fact.”
2. “Noted. Not followed.”
3. “You can notice it without needing to follow it.”
4. “Weather passes. You remain.”
5. “Let it drift past like weather, not a verdict.”
6. “Gentle return to the breath.”
7. “Return gently to the breath and the ground beneath you.”
8. “The ground is still under you.”

### Meditation — Gratitude

**Small Joys**
- Intro: “Gratitude doesn’t need a big moment. It works on small things too. A warm drink, a kind word, a quiet hour. Let’s find one, and really let it land.”
1. “Bring to mind one small thing you appreciate.”
2. “Small, and it still counts.”
3. “Let yourself really notice it, even briefly.”
4. “Linger there a moment.”
5. “Notice how that appreciation feels in your body.”
6. “Feel the warmth settle in.”
7. “Carry a little of that warmth with you today.”
8. “Carry it gently with you.”

**Gratitude for People**
- Intro: “There’s someone who has helped you recently. Maybe in a small way, maybe in a big one. Let’s give them a few quiet minutes of your full attention, and let the thanks simply be felt.”
1. “Think of a person who has helped you recently.”
2. “Let their face come into focus.”
3. “Picture their face and notice what comes up.”
4. “Whatever comes up is welcome.”
5. “If you could, what would you want to tell them?”
6. “Say it to them, silently if you need to.”
7. “Let that appreciation settle in, unhurried.”
8. “Let it settle, softly.”

**End of Day Thanks**
- Intro: “The day is ending, and before you rest, let’s take a quick look at what went right. Not the whole story. Just a few honest good moments. You’ve earned a few minutes of noticing.”
1. “Think back over today. What went okay, even briefly?”
2. “Even brief counts as a win.”
3. “You do not need a big win. Small counts too.”
4. “Small wins add up.”
5. “Let yourself acknowledge getting through today.”
6. “You got through today. That matters.”
7. “Rest now, knowing today had something good in it.”
8. “Rest now. You did enough.”

### Meditation — Morning

**Fresh Start**
- Intro: “A new day, and a clean slate. We’ll take one full, welcoming breath, leave yesterday where it belongs. Yesterday. And step into today with a little extra room in the body.”
1. “Take a deep breath in, welcoming the new day.”
2. “Welcome, new day.”
3. “Yesterday is over. Today has space in it.”
4. “Clean slate. Room to move.”
5. “Notice how your body feels without judgment.”
6. “Just notice. No fixing needed.”
7. “Carry this calm with you as you begin.”
8. “Calm is in your bag for today.”

**Set an Intention**
- Intro: “Before the day fills up, we’ll choose one small, kind intention to carry with us. Not a goal, and not a to-do. Just a quiet thread that can guide your choices.”
1. “Set one small, kind intention for today.”
2. “Small and kind is enough.”
3. “It does not need to be big. Just true to you.”
4. “True to you. That’s the test.”
5. “Picture yourself carrying it through your day.”
6. “See it move with you today.”
7. “Begin with that intention in mind.”
8. “Carry it, lightly.”

**Morning Clarity**
- Intro: “Before the day gets loud, we’ll wake the mind up gently. One moment of quiet, a few clear breaths, and the fog thins. You can start from clarity, not from a rush.”
1. “Notice the quiet of this moment before the day starts.”
2. “Quiet, before the rush.”
3. “Breathe in clarity, breathe out leftover grogginess.”
4. “Fog out, clarity in.”
5. “Today has space in it, even if it does not feel that way yet.”
6. “Space is there. Trust it.”
7. “Start from a clear, steady place.”
8. “Clear and steady to begin.”

### Daily Snapshot stage guides (played once per stage)
- Body: “Let’s start with the body. Think about sleep, energy, and how your body carried you through the day. There is no right answer here. Just what was actually true.”
- Mind: “Now, the mind. I’ll ask a few questions about how your head and feelings felt today. Choose whatever feels closest. There is no perfect answer here.”
- Routine: “Let’s look at what supported you today. Movement, water, connection, and food. These are observations, not a test. Just choose what actually happened.”
- Review: “You’re at the review step. Take a moment to look at what you entered before you save. This reflection is yours alone, and it stays private to you.”

### Wellness Result band narrations (no score read-out, no diagnosis)
- Steady (score >= 70): “Thank you for checking in. Your answers show several signs of steadiness today, and that’s a real thing to notice. Take a moment with the next step on the screen, and keep noticing what supports you.”
- Mixed (score 40–69): “Thank you for checking in. Today sounds like a mixed day. Some weight, some ease. A small reset, or a few quiet minutes, might help. The next step on the screen is a gentle one.”
- Heavier (score < 40): “Thank you for being honest in your check-in. Today sounds heavier than usual, so be gentle with yourself. The next step on the screen is small and safe, and human-support options are there if you want them.”

## Validation status

Completed locally (Arena sandbox, 26 August 2026):

- all 184 MP3s generated with the single approved narrator (voice approved in-session on 25 August 2026);
- Python asset audit passed: every registry path in `lib/utils/audio_assets.dart` exists on disk, no orphan MP3s, all 21 leaf audio directories declared in `pubspec.yaml`;
- duration scan passed: 1.94s–16.90s, no anomalies; breathing phase cues verified to fit their timer intervals;
- dev-machine runs (26 Aug 2026): `flutter analyze` 0 errors / 0 warnings (23 pre-existing informational notices, none from Batch 7), `flutter test` 9/9 passed, Chrome run clean;
- **Chrome playback matrix passed (user-confirmed 26 Aug 2026)**: new meditation timing/captions/replay-mute, 4-7-8 phase-cue sync, Daily Snapshot stage guides, and Wellness Result band narrations;
- `flutter analyze`, `flutter test`, and builds **cannot run in the Arena sandbox** (Flutter SDK download is network-blocked here) — the developer machine runs them.

Still required (release matrix):

- test an Android emulator;
- test audio focus, routing, interruption, and volume on a physical phone before release;
- review narration wording and voice-generation usage rights before public distribution.

## Replacing or adding narration

- keep speech concise enough for its timer interval;
- use one consistent approved narrator unless the product decision changes;
- use compressed MP3 and normalize loudness across clips;
- preserve or update the matching written caption/transcript;
- add every new path to `lib/utils/audio_assets.dart`;
- add each directory containing audio files to `pubspec.yaml`; Flutter directory entries do not automatically bundle arbitrary deeper subdirectories;
- record exact file count/size, tests, and remaining coverage after each audio batch.
