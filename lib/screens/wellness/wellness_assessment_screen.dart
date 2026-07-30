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
  int _stressLevel = 5;
  bool _socialized = false;
  bool _ateHealthyMeals = false;

  bool _isSaving = false;
  String? _errorText;

  // After saving, we show the resulting score right on this screen
  // instead of immediately navigating away.
  int? _resultScore;

  String _friendlyError(Object e) {
    return 'Something went wrong saving your assessment. Please try again.';
  }

  Future<void> _saveAssessment() async {
    setState(() => _errorText = null);

    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      setState(() => _errorText = 'You need to be logged in to save this.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final assessment = WellnessAssessmentModel(
        id: '', // Firestore assigns this automatically
        uid: uid,
        sleepHours: _sleepHours,
        exercised: _exercised,
        drankEnoughWater: _drankEnoughWater,
        stressLevel: _stressLevel,
        socialized: _socialized,
        ateHealthyMeals: _ateHealthyMeals,
        date: DateTime.now(),
      );

      await firestoreService.addWellnessAssessment(assessment);

      if (!mounted) return;

      // Show the score on-screen rather than a plain snackbar, since
      // this is the main payoff of filling out the assessment.
      setState(() => _resultScore = assessment.overallScorePercent);
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
          const SizedBox(height: 16),

          // ---- Stress ----
          Text(
            'Stress level today: $_stressLevel / 10',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _stressLevel.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: const Color(0xFF9B8ECF),
            label: '$_stressLevel',
            onChanged: (value) =>
                setState(() => _stressLevel = value.round()),
          ),
          const SizedBox(height: 8),

          // ---- Yes/No questions ----
          _buildSwitchTile(
            title: 'Did you exercise today?',
            value: _exercised,
            onChanged: (value) => setState(() => _exercised = value),
          ),
          _buildSwitchTile(
            title: 'Did you drink enough water today?',
            value: _drankEnoughWater,
            onChanged: (value) => setState(() => _drankEnoughWater = value),
          ),
          _buildSwitchTile(
            title: 'Did you socialize with anyone today?',
            value: _socialized,
            onChanged: (value) => setState(() => _socialized = value),
          ),
          _buildSwitchTile(
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

  // Small helper so we're not repeating the same SwitchListTile code
  // six times over.
  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      activeColor: const Color(0xFF5B9A8B),
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }
}