import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wellness_assessment_model.dart';
import '../../services/app_settings_controller.dart';
import '../../services/audio_guide_service.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/audio_assets.dart';
import '../../utils/pattern_insight.dart';
import 'wellness_result_screen.dart';

class WellnessAssessmentScreen extends StatefulWidget {
  const WellnessAssessmentScreen({super.key});

  @override
  State<WellnessAssessmentScreen> createState() =>
      _WellnessAssessmentScreenState();
}

class _WellnessAssessmentScreenState extends State<WellnessAssessmentScreen> {
  double? _sleepHours;
  bool? _exercised;
  bool? _drankEnoughWater;
  bool? _socialized;
  bool? _ateHealthyMeals;

  int _currentStep = 0;
  int _stressQuestionIndex = 0;
  bool _isSaving = false;
  String? _errorText;
  AudioGuideService? _audioGuide;
  int _guidedStep = -1;

  final List<_StressQuestion> _stressQuestions = const [
    _StressQuestion(
      id: 'sleepQuality',
      prompt: 'How poorly did you sleep last night?',
    ),
    _StressQuestion(
      id: 'racingThoughts',
      prompt: 'How hard was it to quiet your thoughts today?',
    ),
    _StressQuestion(
      id: 'tension',
      prompt: 'How tense did your body feel today?',
    ),
    _StressQuestion(
      id: 'irritability',
      prompt: 'How irritable or easily frustrated did you feel?',
    ),
    _StressQuestion(
      id: 'overwhelm',
      prompt: 'How overwhelmed by tasks or worries did you feel?',
    ),
  ];

  final Map<String, int?> _stressAnswers = {
    'sleepQuality': null,
    'racingThoughts': null,
    'tension': null,
    'irritability': null,
    'overwhelm': null,
  };

  static const List<String> _stressLabels = [
    'Not at all',
    'A little',
    'Somewhat',
    'Quite a bit',
    'Extremely',
  ];

  static const int _totalProgressUnits = 8;

  _StressQuestion get _currentQuestion =>
      _stressQuestions[_stressQuestionIndex];

  int get _currentProgressUnit {
    if (_currentStep == 0) return 1;
    if (_currentStep == 1) return 2 + _stressQuestionIndex;
    if (_currentStep == 2) return 7;
    return 8;
  }

  double get _overallProgress =>
      _currentProgressUnit / _totalProgressUnits;

  bool get _routineComplete =>
      _exercised != null &&
      _drankEnoughWater != null &&
      _socialized != null &&
      _ateHealthyMeals != null;

  int _computeStressLevel() {
    final answers = _stressAnswers.values.whereType<int>().toList();
    if (answers.isEmpty) return 5;

    final sum = answers.fold<int>(0, (total, value) => total + value);
    return ((sum / 20) * 9).round() + 1;
  }

  String get _stepEyebrow {
    if (_currentStep == 0) return 'BODY';
    if (_currentStep == 1) {
      return 'MIND · ${_stressQuestionIndex + 1} OF ${_stressQuestions.length}';
    }
    if (_currentStep == 2) return 'ROUTINE';
    return 'YOUR SNAPSHOT';
  }

  String get _stepTitle {
    if (_currentStep == 0) return 'How did your body feel today?';
    if (_currentStep == 1) return _currentQuestion.prompt;
    if (_currentStep == 2) return 'What supported you today?';
    return 'Your reflection is ready.';
  }

  String get _stepSubtitle {
    if (_currentStep == 0) {
      return 'Start with sleep, energy and how your body felt.';
    }
    if (_currentStep == 1) {
      return 'Choose the description that feels closest. There is no perfect answer.';
    }
    if (_currentStep == 2) {
      return 'These are observations, not a test. Choose what actually happened.';
    }
    return 'Take a look at what you entered before saving this check-in.';
  }

  String? _stageGuideAsset(int step) {
    switch (step) {
      case 0:
        return MindMateAudioAssets.snapshotBodyGuide;
      case 1:
        return MindMateAudioAssets.snapshotMindGuide;
      case 2:
        return MindMateAudioAssets.snapshotRoutineGuide;
      case 3:
        return MindMateAudioAssets.snapshotReviewGuide;
      default:
        return null;
    }
  }

  /// Plays the short guide for the current stage once (per stage entry).
  Future<void> _maybePlayStageGuide() async {
    final audioGuide = _audioGuide;
    if (audioGuide == null || _guidedStep == _currentStep) return;
    final asset = _stageGuideAsset(_currentStep);
    if (asset == null) return;
    if (!context.read<AppSettingsController>().soundEnabled) return;
    _guidedStep = _currentStep;
    await audioGuide.playAsset(asset);
  }

  Future<void> _replayStageGuide() async {
    final audioGuide = _audioGuide;
    final asset = _stageGuideAsset(_currentStep);
    if (audioGuide == null || asset == null) return;
    await audioGuide.playAsset(asset);
  }

  Future<void> _toggleSnapshotSound(bool enabled) async {
    final settings = context.read<AppSettingsController>();
    final audioGuide = _audioGuide;
    await settings.updateSoundEnabled(enabled);
    if (!mounted) return;
    if (!enabled) {
      await audioGuide?.stop();
      return;
    }
    if (_guidedStep != _currentStep) {
      await _maybePlayStageGuide();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_audioGuide == null) {
      _audioGuide = context.read<AudioGuideService>();
      unawaited(_maybePlayStageGuide());
    }
  }

  @override
  void dispose() {
    final audioGuide = _audioGuide;
    if (audioGuide != null) unawaited(audioGuide.stop());
    super.dispose();
  }

  void _nextStep() {
    setState(() => _errorText = null);

    if (_currentStep == 0) {
      if (_sleepHours == null) {
        setState(() => _errorText = 'Choose the sleep range that feels closest.');
        return;
      }
      setState(() => _currentStep = 1);
      unawaited(_maybePlayStageGuide());
      return;
    }

    if (_currentStep == 1) {
      if (_stressAnswers[_currentQuestion.id] == null) {
        setState(() => _errorText = 'Choose one answer before continuing.');
        return;
      }

      if (_stressQuestionIndex < _stressQuestions.length - 1) {
        setState(() => _stressQuestionIndex++);
      } else {
        setState(() => _currentStep = 2);
        unawaited(_maybePlayStageGuide());
      }
      return;
    }

    if (_currentStep == 2) {
      if (!_routineComplete) {
        setState(() => _errorText = 'Answer each routine question first.');
        return;
      }
      setState(() => _currentStep = 3);
      unawaited(_maybePlayStageGuide());
      return;
    }

    _saveAssessment();
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
      return;
    }

    if (_currentStep == 1 && _stressQuestionIndex > 0) {
      setState(() => _stressQuestionIndex--);
      return;
    }

    if (_currentStep == 2) {
      setState(() {
        _currentStep = 1;
        _stressQuestionIndex = _stressQuestions.length - 1;
      });
      return;
    }

    setState(() => _currentStep--);
  }

  Future<void> _saveAssessment() async {
    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null) {
      setState(() => _errorText = 'You need to be logged in to save this.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    final assessment = WellnessAssessmentModel(
      id: '',
      uid: uid,
      sleepHours: _sleepHours!,
      exercised: _exercised!,
      drankEnoughWater: _drankEnoughWater!,
      stressLevel: _computeStressLevel(),
      socialized: _socialized!,
      ateHealthyMeals: _ateHealthyMeals!,
      date: DateTime.now(),
    );

    try {
      final firestore = context.read<FirestoreService>();
      await firestore.addWellnessAssessment(assessment);

      PatternInsight moodInsight = const PatternInsight();
      PatternInsight scoreInsight = const PatternInsight();

      // The assessment is already saved if these optional insight queries
      // fail. Do not make a successful save look like a failed submission.
      try {
        final recentMoods = await firestore.moodLogsForUser(uid).first;
        final recentAssessments =
            await firestore.wellnessAssessmentsForUser(uid).first;
        moodInsight = PatternInsight.fromRecentMoods(recentMoods);
        scoreInsight = PatternInsight.fromRecentAssessments(recentAssessments);
      } catch (_) {
        // Keep the default empty insights and continue to the result screen.
      }

      final insight = scoreInsight.isConcerning
          ? scoreInsight
          : (moodInsight.message != null ? moodInsight : scoreInsight);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WellnessResultScreen(
            score: assessment.overallScorePercent,
            insight: insight,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorText = 'Could not save this reflection. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily snapshot'),
        leading: IconButton(
          onPressed: _isSaving ? null : _goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStepHero(),
                    const SizedBox(height: 22),
                    if (_currentStep == 0) _buildSleepStep(),
                    if (_currentStep == 1) _buildStressStep(),
                    if (_currentStep == 2) _buildRoutineStep(),
                    if (_currentStep == 3) _buildReviewStep(),
                    if (_errorText != null) ...[
                      const SizedBox(height: 15),
                      Text(
                        _errorText!,
                        style: const TextStyle(
                          color: AppTheme.danger,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'STEP $_currentProgressUnit OF $_totalProgressUnits',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '${(_overallProgress * 100).round()}%',
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                height: 6,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  width: constraints.maxWidth * _overallProgress,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepHero() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppTheme.textOnDark : AppTheme.textDark;
    final supportingColor = isDark
        ? AppTheme.textOnDark.withValues(alpha: 0.72)
        : const Color(0xFF59646F);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(theme.brightness),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _stepEyebrow,
            style: TextStyle(
              color: isDark ? AppTheme.seaGlass : const Color(0xFF806B59),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            _stepTitle,
            style: TextStyle(
              color: titleColor,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _stepSubtitle,
            style: TextStyle(
              color: supportingColor,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How many hours did you sleep?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ChoiceCard(
              label: 'Less than 5',
              subtitle: 'A short night',
              selected: _sleepHours == 4,
              onTap: () => setState(() => _sleepHours = 4),
            ),
            _ChoiceCard(
              label: '5–6 hours',
              subtitle: 'Some rest',
              selected: _sleepHours == 5.5,
              onTap: () => setState(() => _sleepHours = 5.5),
            ),
            _ChoiceCard(
              label: '7–8 hours',
              subtitle: 'A steadier night',
              selected: _sleepHours == 7.5,
              onTap: () => setState(() => _sleepHours = 7.5),
            ),
            _ChoiceCard(
              label: '9+ hours',
              subtitle: 'A longer rest',
              selected: _sleepHours == 9,
              onTap: () => setState(() => _sleepHours = 9),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStressStep() {
    final selected = _stressAnswers[_currentQuestion.id];
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose the closest description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: List.generate(_stressLabels.length, (index) {
            final isSelected = selected == index;
            return ChoiceChip(
              label: Text(_stressLabels[index]),
              selected: isSelected,
              backgroundColor: theme.colorScheme.surface,
              selectedColor: AppTheme.primary.withValues(alpha: 0.14),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primary.withValues(alpha: 0.48)
                    : theme.dividerColor.withValues(alpha: 0.68),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? AppTheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              showCheckmark: false,
              onSelected: (_) {
                setState(() => _stressAnswers[_currentQuestion.id] = index);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRoutineStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RoutineQuestion(
          title: 'Did you exercise today?',
          value: _exercised,
          onChanged: (value) => setState(() => _exercised = value),
        ),
        _RoutineQuestion(
          title: 'Did you drink enough water today?',
          value: _drankEnoughWater,
          onChanged: (value) => setState(() => _drankEnoughWater = value),
        ),
        _RoutineQuestion(
          title: 'Did you connect with anyone today?',
          value: _socialized,
          onChanged: (value) => setState(() => _socialized = value),
        ),
        _RoutineQuestion(
          title: 'Did you eat meals that supported you today?',
          value: _ateHealthyMeals,
          onChanged: (value) => setState(() => _ateHealthyMeals = value),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReviewRow(label: 'Sleep', value: _sleepLabel),
        _ReviewRow(label: 'Stress snapshot', value: '${_computeStressLevel()} / 10'),
        _ReviewRow(
          label: 'Routine answers',
          value: _routineComplete ? 'Complete' : 'Not complete',
        ),
        const SizedBox(height: 16),
        const Text(
          'This is a personal reflection based on what you entered. It is not a medical assessment.',
          style: TextStyle(
            color: AppTheme.textLight,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  String get _sleepLabel {
    if (_sleepHours == 4) return 'Less than 5 hours';
    if (_sleepHours == 5.5) return '5–6 hours';
    if (_sleepHours == 7.5) return '7–8 hours';
    if (_sleepHours == 9) return '9+ hours';
    return 'Not chosen';
  }

  Widget _buildBottomBar() {
    final settings = context.watch<AppSettingsController>();
    final canReplay = settings.soundEnabled && _guidedStep == _currentStep;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Replay stage guide',
                  onPressed: canReplay ? _replayStageGuide : null,
                  icon: const Icon(Icons.replay_rounded),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: settings.soundEnabled
                      ? 'Turn stage guide voice off'
                      : 'Turn stage guide voice on',
                  onPressed: () => _toggleSnapshotSound(!settings.soundEnabled),
                  icon: Icon(
                    settings.soundEnabled
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _nextStep,
                child: _isSaving
                    ? const SizedBox(
                        height: 21,
                        width: 21,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(_currentStep == 3 ? 'Save reflection' : 'Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StressQuestion {
  final String id;
  final String prompt;

  const _StressQuestion({required this.id, required this.prompt});
}

class _ChoiceCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.13)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : AppTheme.surfaceBorder.withValues(alpha: 0.78),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppTheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.62),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoutineQuestion extends StatelessWidget {
  final String title;
  final bool? value;
  final ValueChanged<bool> onChanged;

  const _RoutineQuestion({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _YesNoButton(
                  label: 'Yes',
                  selected: value == true,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _YesNoButton(
                  label: 'No',
                  selected: value == false,
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _YesNoButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _YesNoButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.14)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : AppTheme.surfaceBorder.withValues(alpha: 0.78),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppTheme.primary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.62),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
