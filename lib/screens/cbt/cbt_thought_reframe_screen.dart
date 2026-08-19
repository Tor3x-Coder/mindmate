import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/thought_record_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

// A guided, step-by-step CBT "thought record" exercise. The user works
// through one question at a time (situation -> automatic thought ->
// how strong it feels -> evidence for/against -> a more balanced
// thought -> how strong it feels now), then everything gets saved as
// a single ThoughtRecordModel on the last step.
//
// This screen does NOT diagnose or give clinical advice — it's a
// structured self-reflection tool, same spirit as the rest of the app.
class CbtThoughtReframeScreen extends StatefulWidget {
  const CbtThoughtReframeScreen({super.key});

  @override
  State<CbtThoughtReframeScreen> createState() =>
      _CbtThoughtReframeScreenState();
}

class _CbtThoughtReframeScreenState extends State<CbtThoughtReframeScreen> {
  // Which step the user is currently on. 0-indexed, matches the
  // _steps list below.
  int _currentStep = 0;
  bool _isSaving = false;

  // One controller per text-entry step. Sliders don't need controllers
  // since their value is just an int we track directly.
  final _situationController = TextEditingController();
  final _automaticThoughtController = TextEditingController();
  final _evidenceForController = TextEditingController();
  final _evidenceAgainstController = TextEditingController();
  final _balancedThoughtController = TextEditingController();

  int _intensityBefore = 5;
  int _intensityAfter = 5;

  // Describes each step: what to show, and (for text steps) which
  // controller holds its answer. Keeping this as a list makes the
  // progress bar, back/next logic, and page content all driven by
  // the same single source of truth instead of duplicated per-step.
  late final List<_WizardStep> _steps = [
    _WizardStep(
      title: 'What happened?',
      subtitle: 'Briefly describe the situation that triggered this feeling.',
      hint: 'e.g. "My friend didn\'t reply to my message all day."',
      controller: _situationController,
    ),
    _WizardStep(
      title: 'What thought came up?',
      subtitle: 'What went through your mind in that moment?',
      hint: 'e.g. "They\'re mad at me" or "I always mess things up."',
      controller: _automaticThoughtController,
    ),
    _WizardStep(
      title: 'How strong does it feel?',
      subtitle: 'Rate how intense that thought feels right now.',
      isIntensityStep: true,
      isBeforeIntensity: true,
    ),
    _WizardStep(
      title: 'What supports this thought?',
      subtitle: 'What evidence makes this thought feel true?',
      hint: 'e.g. "They usually reply within an hour."',
      controller: _evidenceForController,
    ),
    _WizardStep(
      title: 'What challenges this thought?',
      subtitle: 'Is there evidence against it, or another explanation?',
      hint: 'e.g. "They said they had a busy day at work."',
      controller: _evidenceAgainstController,
    ),
    _WizardStep(
      title: 'What\'s a more balanced thought?',
      subtitle: 'Given both sides, how else could you see this?',
      hint: 'e.g. "They\'re probably just busy, not upset with me."',
      controller: _balancedThoughtController,
    ),
    _WizardStep(
      title: 'How strong does it feel now?',
      subtitle: 'Rate the thought\'s intensity after reframing it.',
      isIntensityStep: true,
      isBeforeIntensity: false,
    ),
  ];

  @override
  void dispose() {
    _situationController.dispose();
    _automaticThoughtController.dispose();
    _evidenceForController.dispose();
    _evidenceAgainstController.dispose();
    _balancedThoughtController.dispose();
    super.dispose();
  }

  bool get _isLastStep => _currentStep == _steps.length - 1;

  // Text steps require something typed in before moving on. Intensity
  // (slider) steps are always valid since they start with a value.
  bool get _canGoNext {
    final step = _steps[_currentStep];
    if (step.isIntensityStep) return true;
    return step.controller!.text.trim().isNotEmpty;
  }

  void _goNext() {
    if (!_canGoNext) return;
    if (_isLastStep) {
      _save();
    } else {
      setState(() => _currentStep++);
    }
  }

  void _goBack() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _currentStep--);
    }
  }

  Future<void> _save() async {
    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    final record = ThoughtRecordModel(
      id: '', // Firestore assigns the real id; unused until read back.
      uid: uid,
      situation: _situationController.text.trim(),
      automaticThought: _automaticThoughtController.text.trim(),
      intensityBefore: _intensityBefore,
      evidenceFor: _evidenceForController.text.trim(),
      evidenceAgainst: _evidenceAgainstController.text.trim(),
      balancedThought: _balancedThoughtController.text.trim(),
      intensityAfter: _intensityAfter,
      date: DateTime.now(),
    );

    try {
      await context.read<FirestoreService>().addThoughtRecord(record);
      if (!mounted) return;
      _showCompletionDialog();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save: ${e.toString()}')),
      );
    }
  }

  // A simple confirmation before returning to Practice, so the user
  // gets a clear sense of completion rather than just being dumped
  // back on the previous screen.
  void _showCompletionDialog() {
    final before = _intensityBefore;
    final after = _intensityAfter;
    final improved = after < before;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Nice work'),
        content: Text(
          improved
              ? 'You brought the intensity down from $before to $after. '
                  'That\'s the exercise working — keep this thought record '
                  'to look back on.'
              : 'You worked all the way through it — that matters even '
                  'when the feeling doesn\'t drop right away.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // close wizard, back to Practice
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reframe a Thought'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isSaving ? null : _goBack,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.subtitle,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (step.isIntensityStep)
                      _buildIntensitySlider(step.isBeforeIntensity!)
                    else
                      _buildTextField(step),
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

  // A row of small segments, one per step, filled in up to the current
  // step — gives a lightweight sense of progress without needing exact
  // percentages.
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: List.generate(_steps.length, (i) {
          final isDone = i <= _currentStep;
          return Expanded(
            child: Container(
              height: 5,
              margin: EdgeInsets.only(right: i == _steps.length - 1 ? 0 : 6),
              decoration: BoxDecoration(
                color: isDone
                    ? AppTheme.primary
                    : AppTheme.surfaceBorder.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField(_WizardStep step) {
    return TextField(
      controller: step.controller,
      autofocus: true,
      maxLines: 5,
      minLines: 3,
      textCapitalization: TextCapitalization.sentences,
      // Rebuilds the Next button's enabled state as the user types,
      // since _canGoNext depends on the controller's current text.
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: step.hint,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.75),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.75),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildIntensitySlider(bool isBefore) {
    final value = isBefore ? _intensityBefore : _intensityAfter;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.surfaceBorder.withValues(alpha: 0.75),
            ),
          ),
          child: Column(
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'out of 10',
                style: TextStyle(color: AppTheme.textLight, fontSize: 13),
              ),
              Slider(
                value: value.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: AppTheme.primary,
                onChanged: (v) {
                  setState(() {
                    if (isBefore) {
                      _intensityBefore = v.round();
                    } else {
                      _intensityAfter = v.round();
                    }
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Barely there',
                        style: TextStyle(
                            color: AppTheme.textLight, fontSize: 12)),
                    Text('Overwhelming',
                        style: TextStyle(
                            color: AppTheme.textLight, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
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
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: _canGoNext ? AppTheme.accentGradient : null,
              color: _canGoNext ? null : AppTheme.surfaceBorder,
              borderRadius: BorderRadius.circular(26),
            ),
            child: ElevatedButton(
              onPressed: (_canGoNext && !_isSaving) ? _goNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isLastStep ? 'Finish' : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// Plain data holder describing one step of the wizard. Not a widget —
// just configuration that the build methods above read from.
class _WizardStep {
  final String title;
  final String subtitle;
  final String? hint;
  final TextEditingController? controller;
  final bool isIntensityStep;
  final bool? isBeforeIntensity;

  _WizardStep({
    required this.title,
    required this.subtitle,
    this.hint,
    this.controller,
    this.isIntensityStep = false,
    this.isBeforeIntensity,
  });
}