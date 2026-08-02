import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/wellness_assessment_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class WellnessAssessmentScreen extends StatefulWidget {
  const WellnessAssessmentScreen({super.key});

  @override
  State<WellnessAssessmentScreen> createState() =>
      _WellnessAssessmentScreenState();
}

class _WellnessAssessmentScreenState extends State<WellnessAssessmentScreen> {
  // Default starting values for each question.
  double _sleepHours = 7;
  bool _exercised = false;
  bool _drankEnoughWater = false;
  bool _socialized = false;
  bool _ateHealthyMeals = false;

  // Stress quiz: each answer is 0–4 (Not at all → Extremely).
  // null means the user hasn't answered that question yet.
  final List<_StressQuestion> _stressQuestions = const [
    _StressQuestion(
      id: 'sleepQuality',
      prompt: 'How poorly did you sleep last night?',
    ),
    _StressQuestion(
      id: 'racingThoughts',
      prompt: 'Have you had racing or hard-to-quiet thoughts today?',
    ),
    _StressQuestion(
      id: 'tension',
      prompt: 'How tense or tight has your body felt today?',
    ),
    _StressQuestion(
      id: 'irritability',
      prompt: 'How irritable or easily frustrated have you felt?',
    ),
    _StressQuestion(
      id: 'overwhelm',
      prompt: 'How overwhelmed by tasks or worries have you felt?',
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

  bool _isSaving = false;
  String? _errorText;

  // After saving, we show the resulting score right on this screen
  // instead of immediately navigating away.
  int? _resultScore;
  int? _computedStressLevel;

  bool get _stressQuizComplete =>
      _stressAnswers.values.every((answer) => answer != null);

  // Maps the 5 quiz answers (each 0–4) onto the existing 1–10 stressLevel
  // field so Progress and scoring keep working without a model change.
  int _computeStressLevel() {
    final answers = _stressAnswers.values.whereType<int>().toList();
    if (answers.isEmpty) return 5;

    final sum = answers.fold<int>(0, (total, value) => total + value);
    // Max sum = 5 questions × 4 = 20. Map 0→1 and 20→10.
    return ((sum / 20) * 9).round() + 1;
  }

  Future<void> _saveAssessment() async {
    setState(() => _errorText = null);

    if (!_stressQuizComplete) {
      setState(() {
        _errorText = 'Please answer all of the stress questions first.';
      });
      return;
    }

    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      setState(() => _errorText = 'You need to be logged in to save this.');
      return;
    }

    final stressLevel = _computeStressLevel();
    setState(() => _isSaving = true);

    try {
      final assessment = WellnessAssessmentModel(
        id: '', // Firestore assigns this automatically
        uid: uid,
        sleepHours: _sleepHours,
        exercised: _exercised,
        drankEnoughWater: _drankEnoughWater,
        stressLevel: stressLevel,
        socialized: _socialized,
        ateHealthyMeals: _ateHealthyMeals,
        date: DateTime.now(),
      );

      await firestoreService.addWellnessAssessment(assessment);

      if (!mounted) return;

      // Show the score on-screen rather than a plain snackbar, since
      // this is the main payoff of filling out the assessment.
      setState(() {
        _resultScore = assessment.overallScorePercent;
        _computedStressLevel = stressLevel;
      });
    } catch (e) {
      setState(() => _errorText = 'DEBUG ERROR: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Check'),
      ),
      body: SafeArea(
        child: _resultScore != null ? _buildResultView() : _buildFormView(),
      ),
    );
  }

  // Shown once the assessment has been saved.
  Widget _buildResultView() {
    final score = _resultScore!;
    final scoreColor = score >= 70
        ? Colors.green
        : (score >= 40 ? Colors.orange : Colors.red);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your Wellness Score',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withValues(alpha: 0.12),
                border: Border.all(color: scoreColor, width: 4),
              ),
              child: Center(
                child: Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ),
            if (_computedStressLevel != null) ...[
              const SizedBox(height: 16),
              Text(
                'Computed stress level: $_computedStressLevel / 10',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              score >= 70
                  ? 'You\'re doing great! Keep it up.'
                  : (score >= 40
                      ? 'You\'re doing okay — small changes can help.'
                      : 'Things seem tough right now. Be kind to yourself.'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9A8B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  // The actual question form.
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'A few quick questions about today',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),

          // ---- Sleep ----
          Text(
            'Hours of sleep last night: ${_sleepHours.toStringAsFixed(1)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _sleepHours,
            min: 0,
            max: 12,
            divisions: 24,
            activeColor: const Color(0xFF5B9A8B),
            label: _sleepHours.toStringAsFixed(1),
            onChanged: (value) => setState(() => _sleepHours = value),
          ),
          const SizedBox(height: 20),

          // ---- Stress quiz (replaces the old 1–10 slider) ----
          const Text(
            'Stress check-in',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Answer these short questions and we\'ll estimate your stress level for you — no need to guess a number.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ..._stressQuestions.map(_buildStressQuestion),
          if (_stressQuizComplete) ...[
            const SizedBox(height: 4),
            Text(
              'Estimated stress level: ${_computeStressLevel()} / 10',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF9B8ECF),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ---- Yes/No questions (buttons instead of switches) ----
          _buildYesNoQuestion(
            title: 'Did you exercise today?',
            value: _exercised,
            onChanged: (value) => setState(() => _exercised = value),
          ),
          _buildYesNoQuestion(
            title: 'Did you drink enough water today?',
            value: _drankEnoughWater,
            onChanged: (value) => setState(() => _drankEnoughWater = value),
          ),
          _buildYesNoQuestion(
            title: 'Did you socialize with anyone today?',
            value: _socialized,
            onChanged: (value) => setState(() => _socialized = value),
          ),
          _buildYesNoQuestion(
            title: 'Did you eat healthy meals today?',
            value: _ateHealthyMeals,
            onChanged: (value) => setState(() => _ateHealthyMeals = value),
          ),

          if (_errorText != null) ...[
            const SizedBox(height: 14),
            Text(
              _errorText!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ],

          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: _isSaving ? null : _saveAssessment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9A8B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('See My Score', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildStressQuestion(_StressQuestion question) {
    final selected = _stressAnswers[question.id];

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.prompt,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_stressLabels.length, (index) {
              final isSelected = selected == index;
              return GestureDetector(
                onTap: () {
                  setState(() => _stressAnswers[question.id] = index);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF9B8ECF)
                        : Colors.grey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF9B8ECF)
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    _stressLabels[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoQuestion({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _YesNoButton(
                  label: 'Yes',
                  selected: value == true,
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 10),
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

class _StressQuestion {
  final String id;
  final String prompt;

  const _StressQuestion({required this.id, required this.prompt});
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF5B9A8B)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF5B9A8B)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
