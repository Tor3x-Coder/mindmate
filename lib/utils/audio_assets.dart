/// Central registry for bundled, offline guided-audio assets.
///
/// Keep paths here instead of scattering string literals across screens. This
/// makes it easier to audit coverage and replace narration without changing
/// timer or UI logic.
class MindMateAudioAssets {
  MindMateAudioAssets._();

  static const String quickResetIntro =
      'assets/audio/meditation/stress_relief/quick_reset/00_intro.mp3';

  static const List<String> quickResetPrompts = [
    'assets/audio/meditation/stress_relief/quick_reset/01_settle.mp3',
    'assets/audio/meditation/stress_relief/quick_reset/02_notice.mp3',
    'assets/audio/meditation/stress_relief/quick_reset/03_release.mp3',
    'assets/audio/meditation/stress_relief/quick_reset/04_close.mp3',
  ];

  static const List<String> quickResetSupportPrompts = [
    'assets/audio/meditation/stress_relief/quick_reset/05_steady.mp3',
    'assets/audio/meditation/stress_relief/quick_reset/06_soften.mp3',
    'assets/audio/meditation/stress_relief/quick_reset/07_gently.mp3',
    'assets/audio/meditation/stress_relief/quick_reset/08_finish_softly.mp3',
  ];

  static const String boxBreathingIntro =
      'assets/audio/breathing/box/00_intro.mp3';

  static const List<String> boxBreathingPhasePrompts = [
    'assets/audio/breathing/box/01_inhale.mp3',
    'assets/audio/breathing/box/02_hold_full.mp3',
    'assets/audio/breathing/box/03_exhale.mp3',
    'assets/audio/breathing/box/04_hold_empty.mp3',
  ];

  static const String boxBreathingComplete =
      'assets/audio/breathing/box/05_complete.mp3';
}
