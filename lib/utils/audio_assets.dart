/// Central registry for bundled, offline guided-audio assets.
///
/// Keep paths here instead of scattering string literals across screens. This
/// makes it easier to audit coverage and replace narration without changing
/// timer or UI logic.
class MindMateAudioAssets {
  MindMateAudioAssets._();

  // ---------------------------------------------------------------------------
  // Meditation — Stress Relief
  // ---------------------------------------------------------------------------

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

  static const String releaseTensionIntro =
      'assets/audio/meditation/stress_relief/release_tension/00_intro.mp3';

  static const List<String> releaseTensionPrompts = [
    'assets/audio/meditation/stress_relief/release_tension/01_forehead.mp3',
    'assets/audio/meditation/stress_relief/release_tension/02_jaw.mp3',
    'assets/audio/meditation/stress_relief/release_tension/03_hands.mp3',
    'assets/audio/meditation/stress_relief/release_tension/04_supported.mp3',
  ];

  static const List<String> releaseTensionSupportPrompts = [
    'assets/audio/meditation/stress_relief/release_tension/05_one_place.mp3',
    'assets/audio/meditation/stress_relief/release_tension/06_let_it_relax.mp3',
    'assets/audio/meditation/stress_relief/release_tension/07_loose_fingers.mp3',
    'assets/audio/meditation/stress_relief/release_tension/08_take_the_weight.mp3',
  ];

  static const String calmTheStormIntro =
      'assets/audio/meditation/stress_relief/calm_the_storm/00_intro.mp3';

  static const List<String> calmTheStormPrompts = [
    'assets/audio/meditation/stress_relief/calm_the_storm/01_one_moment.mp3',
    'assets/audio/meditation/stress_relief/calm_the_storm/02_no_solving.mp3',
    'assets/audio/meditation/stress_relief/calm_the_storm/03_this_breath.mp3',
    'assets/audio/meditation/stress_relief/calm_the_storm/04_pause.mp3',
  ];

  static const List<String> calmTheStormSupportPrompts = [
    'assets/audio/meditation/stress_relief/calm_the_storm/05_wave.mp3',
    'assets/audio/meditation/stress_relief/calm_the_storm/06_no_answer.mp3',
    'assets/audio/meditation/stress_relief/calm_the_storm/07_enough.mp3',
    'assets/audio/meditation/stress_relief/calm_the_storm/08_in_the_pause.mp3',
  ];

  // ---------------------------------------------------------------------------
  // Meditation — Sleep
  // ---------------------------------------------------------------------------

  static const String windDownIntro =
      'assets/audio/meditation/sleep/wind_down/00_intro.mp3';

  static const List<String> windDownPrompts = [
    'assets/audio/meditation/sleep/wind_down/01_sink.mp3',
    'assets/audio/meditation/sleep/wind_down/02_slow.mp3',
    'assets/audio/meditation/sleep/wind_down/03_nothing_to_complete.mp3',
    'assets/audio/meditation/sleep/wind_down/04_drift.mp3',
  ];

  static const List<String> windDownSupportPrompts = [
    'assets/audio/meditation/sleep/wind_down/05_sinking.mp3',
    'assets/audio/meditation/sleep/wind_down/06_slower.mp3',
    'assets/audio/meditation/sleep/wind_down/07_list_can_wait.mp3',
    'assets/audio/meditation/sleep/wind_down/08_drift_allowed.mp3',
  ];

  static const String quietNightIntro =
      'assets/audio/meditation/sleep/quiet_night/00_intro.mp3';

  static const List<String> quietNightPrompts = [
    'assets/audio/meditation/sleep/quiet_night/01_quiet_room.mp3',
    'assets/audio/meditation/sleep/quiet_night/02_deeper.mp3',
    'assets/audio/meditation/sleep/quiet_night/03_no_attention.mp3',
    'assets/audio/meditation/sleep/quiet_night/04_held.mp3',
  ];

  static const List<String> quietNightSupportPrompts = [
    'assets/audio/meditation/sleep/quiet_night/05_still.mp3',
    'assets/audio/meditation/sleep/quiet_night/06_deeper_each.mp3',
    'assets/audio/meditation/sleep/quiet_night/07_rest_attention.mp3',
    'assets/audio/meditation/sleep/quiet_night/08_holding.mp3',
  ];

  static const String deepRestIntro =
      'assets/audio/meditation/sleep/deep_rest/00_intro.mp3';

  static const List<String> deepRestPrompts = [
    'assets/audio/meditation/sleep/deep_rest/01_day_over.mp3',
    'assets/audio/meditation/sleep/deep_rest/02_clouds.mp3',
    'assets/audio/meditation/sleep/deep_rest/03_body_rests.mp3',
    'assets/audio/meditation/sleep/deep_rest/04_enough.mp3',
  ];

  static const List<String> deepRestSupportPrompts = [
    'assets/audio/meditation/sleep/deep_rest/05_drift_on.mp3',
    'assets/audio/meditation/sleep/deep_rest/06_weather.mp3',
    'assets/audio/meditation/sleep/deep_rest/07_rest_happening.mp3',
    'assets/audio/meditation/sleep/deep_rest/08_soft_enough.mp3',
  ];

  // ---------------------------------------------------------------------------
  // Meditation — Focus
  // ---------------------------------------------------------------------------

  static const String clearMindIntro =
      'assets/audio/meditation/focus/clear_mind/00_intro.mp3';

  static const List<String> clearMindPrompts = [
    'assets/audio/meditation/focus/clear_mind/01_upright.mp3',
    'assets/audio/meditation/focus/clear_mind/02_three_breaths.mp3',
    'assets/audio/meditation/focus/clear_mind/03_set_aside.mp3',
    'assets/audio/meditation/focus/clear_mind/04_begin.mp3',
  ];

  static const List<String> clearMindSupportPrompts = [
    'assets/audio/meditation/focus/clear_mind/05_arriving.mp3',
    'assets/audio/meditation/focus/clear_mind/06_back_to_now.mp3',
    'assets/audio/meditation/focus/clear_mind/07_outside.mp3',
    'assets/audio/meditation/focus/clear_mind/08_ready.mp3',
  ];

  static const String preStudyFocusIntro =
      'assets/audio/meditation/focus/pre_study_focus/00_intro.mp3';

  static const List<String> preStudyFocusPrompts = [
    'assets/audio/meditation/focus/pre_study_focus/01_one_step.mp3',
    'assets/audio/meditation/focus/pre_study_focus/02_next_step.mp3',
    'assets/audio/meditation/focus/pre_study_focus/03_confidence.mp3',
    'assets/audio/meditation/focus/pre_study_focus/04_action.mp3',
  ];

  static const List<String> preStudyFocusSupportPrompts = [
    'assets/audio/meditation/focus/pre_study_focus/05_all_it_takes.mp3',
    'assets/audio/meditation/focus/pre_study_focus/06_not_the_mountain.mp3',
    'assets/audio/meditation/focus/pre_study_focus/07_building.mp3',
    'assets/audio/meditation/focus/pre_study_focus/08_begin_with.mp3',
  ];

  static const String deepWorkPrepIntro =
      'assets/audio/meditation/focus/deep_work_prep/00_intro.mp3';

  static const List<String> deepWorkPrepPrompts = [
    'assets/audio/meditation/focus/deep_work_prep/01_four_four.mp3',
    'assets/audio/meditation/focus/deep_work_prep/02_narrow.mp3',
    'assets/audio/meditation/focus/deep_work_prep/03_protected.mp3',
    'assets/audio/meditation/focus/deep_work_prep/04_settle.mp3',
  ];

  static const List<String> deepWorkPrepSupportPrompts = [
    'assets/audio/meditation/focus/deep_work_prep/05_keep_the_pace.mp3',
    'assets/audio/meditation/focus/deep_work_prep/06_narrowing.mp3',
    'assets/audio/meditation/focus/deep_work_prep/07_guard_it.mp3',
    'assets/audio/meditation/focus/deep_work_prep/08_steady_clear.mp3',
  ];

  // ---------------------------------------------------------------------------
  // Meditation — Anxiety
  // ---------------------------------------------------------------------------

  static const String groundingIntro =
      'assets/audio/meditation/anxiety/grounding/00_intro.mp3';

  static const List<String> groundingPrompts = [
    'assets/audio/meditation/anxiety/grounding/01_five_sounds.mp3',
    'assets/audio/meditation/anxiety/grounding/02_contact.mp3',
    'assets/audio/meditation/anxiety/grounding/03_support.mp3',
    'assets/audio/meditation/anxiety/grounding/04_one_breath.mp3',
  ];

  static const List<String> groundingSupportPrompts = [
    'assets/audio/meditation/anxiety/grounding/05_now.mp3',
    'assets/audio/meditation/anxiety/grounding/06_you_are_here.mp3',
    'assets/audio/meditation/anxiety/grounding/07_supported.mp3',
    'assets/audio/meditation/anxiety/grounding/08_next_breath.mp3',
  ];

  static const String steadyBreathIntro =
      'assets/audio/meditation/anxiety/steady_breath/00_intro.mp3';

  static const List<String> steadyBreathPrompts = [
    'assets/audio/meditation/anxiety/steady_breath/01_in_four.mp3',
    'assets/audio/meditation/anxiety/steady_breath/02_hold.mp3',
    'assets/audio/meditation/anxiety/steady_breath/03_out.mp3',
    'assets/audio/meditation/anxiety/steady_breath/04_steadiness.mp3',
  ];

  static const List<String> steadyBreathSupportPrompts = [
    'assets/audio/meditation/anxiety/steady_breath/05_in_hold.mp3',
    'assets/audio/meditation/anxiety/steady_breath/06_out_down.mp3',
    'assets/audio/meditation/anxiety/steady_breath/07_steadier.mp3',
    'assets/audio/meditation/anxiety/steady_breath/08_settling.mp3',
  ];

  static const String anxiousThoughtsSoftenedIntro =
      'assets/audio/meditation/anxiety/anxious_thoughts_softened/00_intro.mp3';

  static const List<String> anxiousThoughtsSoftenedPrompts = [
    'assets/audio/meditation/anxiety/anxious_thoughts_softened/01_not_a_fact.mp3',
    'assets/audio/meditation/anxiety/anxious_thoughts_softened/02_not_follow.mp3',
    'assets/audio/meditation/anxiety/anxious_thoughts_softened/03_weather.mp3',
    'assets/audio/meditation/anxiety/anxious_thoughts_softened/04_return.mp3',
  ];

  static const List<String> anxiousThoughtsSoftenedSupportPrompts = [
    'assets/audio/meditation/anxiety/anxious_thoughts_softened/05_noted.mp3',
    'assets/audio/meditation/anxiety/anxious_thoughts_softened/06_passes.mp3',
    'assets/audio/meditation/anxiety/anxious_thoughts_softened/07_gentle_return.mp3',
    'assets/audio/meditation/anxiety/anxious_thoughts_softened/08_ground.mp3',
  ];

  // ---------------------------------------------------------------------------
  // Meditation — Gratitude
  // ---------------------------------------------------------------------------

  static const String smallJoysIntro =
      'assets/audio/meditation/gratitude/small_joys/00_intro.mp3';

  static const List<String> smallJoysPrompts = [
    'assets/audio/meditation/gratitude/small_joys/01_small_thing.mp3',
    'assets/audio/meditation/gratitude/small_joys/02_notice_it.mp3',
    'assets/audio/meditation/gratitude/small_joys/03_feel_it.mp3',
    'assets/audio/meditation/gratitude/small_joys/04_carry.mp3',
  ];

  static const List<String> smallJoysSupportPrompts = [
    'assets/audio/meditation/gratitude/small_joys/05_counts.mp3',
    'assets/audio/meditation/gratitude/small_joys/06_linger.mp3',
    'assets/audio/meditation/gratitude/small_joys/07_warmth.mp3',
    'assets/audio/meditation/gratitude/small_joys/08_gently.mp3',
  ];

  static const String gratitudeForPeopleIntro =
      'assets/audio/meditation/gratitude/gratitude_for_people/00_intro.mp3';

  static const List<String> gratitudeForPeoplePrompts = [
    'assets/audio/meditation/gratitude/gratitude_for_people/01_person.mp3',
    'assets/audio/meditation/gratitude/gratitude_for_people/02_their_face.mp3',
    'assets/audio/meditation/gratitude/gratitude_for_people/03_tell_them.mp3',
    'assets/audio/meditation/gratitude/gratitude_for_people/04_settle.mp3',
  ];

  static const List<String> gratitudeForPeopleSupportPrompts = [
    'assets/audio/meditation/gratitude/gratitude_for_people/05_focus.mp3',
    'assets/audio/meditation/gratitude/gratitude_for_people/06_welcome.mp3',
    'assets/audio/meditation/gratitude/gratitude_for_people/07_silently.mp3',
    'assets/audio/meditation/gratitude/gratitude_for_people/08_softly.mp3',
  ];

  static const String endOfDayThanksIntro =
      'assets/audio/meditation/gratitude/end_of_day_thanks/00_intro.mp3';

  static const List<String> endOfDayThanksPrompts = [
    'assets/audio/meditation/gratitude/end_of_day_thanks/01_what_went_okay.mp3',
    'assets/audio/meditation/gratitude/end_of_day_thanks/02_small_counts.mp3',
    'assets/audio/meditation/gratitude/end_of_day_thanks/03_acknowledge.mp3',
    'assets/audio/meditation/gratitude/end_of_day_thanks/04_rest.mp3',
  ];

  static const List<String> endOfDayThanksSupportPrompts = [
    'assets/audio/meditation/gratitude/end_of_day_thanks/05_even_brief.mp3',
    'assets/audio/meditation/gratitude/end_of_day_thanks/06_add_up.mp3',
    'assets/audio/meditation/gratitude/end_of_day_thanks/07_that_matters.mp3',
    'assets/audio/meditation/gratitude/end_of_day_thanks/08_enough.mp3',
  ];

  // ---------------------------------------------------------------------------
  // Meditation — Morning
  // ---------------------------------------------------------------------------

  static const String freshStartIntro =
      'assets/audio/meditation/morning/fresh_start/00_intro.mp3';

  static const List<String> freshStartPrompts = [
    'assets/audio/meditation/morning/fresh_start/01_welcome.mp3',
    'assets/audio/meditation/morning/fresh_start/02_clean_slate.mp3',
    'assets/audio/meditation/morning/fresh_start/03_without_judgment.mp3',
    'assets/audio/meditation/morning/fresh_start/04_carry_calm.mp3',
  ];

  static const List<String> freshStartSupportPrompts = [
    'assets/audio/meditation/morning/fresh_start/05_new_day.mp3',
    'assets/audio/meditation/morning/fresh_start/06_room_to_move.mp3',
    'assets/audio/meditation/morning/fresh_start/07_just_notice.mp3',
    'assets/audio/meditation/morning/fresh_start/08_in_your_bag.mp3',
  ];

  static const String setAnIntentionIntro =
      'assets/audio/meditation/morning/set_an_intention/00_intro.mp3';

  static const List<String> setAnIntentionPrompts = [
    'assets/audio/meditation/morning/set_an_intention/01_one_intention.mp3',
    'assets/audio/meditation/morning/set_an_intention/02_true_to_you.mp3',
    'assets/audio/meditation/morning/set_an_intention/03_carry_it.mp3',
    'assets/audio/meditation/morning/set_an_intention/04_begin.mp3',
  ];

  static const List<String> setAnIntentionSupportPrompts = [
    'assets/audio/meditation/morning/set_an_intention/05_kind_enough.mp3',
    'assets/audio/meditation/morning/set_an_intention/06_the_test.mp3',
    'assets/audio/meditation/morning/set_an_intention/07_move_with_you.mp3',
    'assets/audio/meditation/morning/set_an_intention/08_lightly.mp3',
  ];

  static const String morningClarityIntro =
      'assets/audio/meditation/morning/morning_clarity/00_intro.mp3';

  static const List<String> morningClarityPrompts = [
    'assets/audio/meditation/morning/morning_clarity/01_quiet.mp3',
    'assets/audio/meditation/morning/morning_clarity/02_clarity_breaths.mp3',
    'assets/audio/meditation/morning/morning_clarity/03_space.mp3',
    'assets/audio/meditation/morning/morning_clarity/04_steady_place.mp3',
  ];

  static const List<String> morningClaritySupportPrompts = [
    'assets/audio/meditation/morning/morning_clarity/05_before_rush.mp3',
    'assets/audio/meditation/morning/morning_clarity/06_fog_out.mp3',
    'assets/audio/meditation/morning/morning_clarity/07_trust_it.mp3',
    'assets/audio/meditation/morning/morning_clarity/08_begin_clear.mp3',
  ];

  // ---------------------------------------------------------------------------
  // Breathing
  // ---------------------------------------------------------------------------

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

  static const String fourSevenEightIntro =
      'assets/audio/breathing/four_seven_eight/00_intro.mp3';

  static const List<String> fourSevenEightPhasePrompts = [
    'assets/audio/breathing/four_seven_eight/01_inhale.mp3',
    'assets/audio/breathing/four_seven_eight/02_hold.mp3',
    'assets/audio/breathing/four_seven_eight/03_exhale.mp3',
  ];

  static const String fourSevenEightComplete =
      'assets/audio/breathing/four_seven_eight/04_complete.mp3';

  static const String simpleCalmIntro =
      'assets/audio/breathing/simple_calm/00_intro.mp3';

  static const List<String> simpleCalmPhasePrompts = [
    'assets/audio/breathing/simple_calm/01_inhale.mp3',
    'assets/audio/breathing/simple_calm/02_exhale.mp3',
  ];

  static const String simpleCalmComplete =
      'assets/audio/breathing/simple_calm/03_complete.mp3';

  // ---------------------------------------------------------------------------
  // Daily Snapshot stage guides (played once per stage)
  // ---------------------------------------------------------------------------

  static const String snapshotBodyGuide = 'assets/audio/snapshot/body.mp3';

  static const String snapshotMindGuide = 'assets/audio/snapshot/mind.mp3';

  static const String snapshotRoutineGuide =
      'assets/audio/snapshot/routine.mp3';

  static const String snapshotReviewGuide = 'assets/audio/snapshot/review.mp3';

  // ---------------------------------------------------------------------------
  // Wellness Result band narrations (steady / mixed / heavier)
  // ---------------------------------------------------------------------------

  static const String wellnessResultSteady =
      'assets/audio/wellness_result/steady.mp3';

  static const String wellnessResultMixed =
      'assets/audio/wellness_result/mixed.mp3';

  static const String wellnessResultHeavier =
      'assets/audio/wellness_result/heavier.mp3';
}
