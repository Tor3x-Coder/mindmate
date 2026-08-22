import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/thought_record_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

/// A branching, step-by-step thought-reflection exercise.
///
/// The first choice changes the wording of later prompts. This first version
/// uses predictable local branching rather than AI, so the path is easy to
/// test and explain. AI personalisation can be added later with consent.
class CbtThoughtReframeScreen extends StatefulWidget {
  const CbtThoughtReframeScreen({super.key});

  @override
  State<CbtThoughtReframeScreen> createState() =>
      _CbtThoughtReframeScreenState();
}

class _CbtThoughtReframeScreenState extends State<CbtThoughtReframeScreen> {
  int _currentStep = 0;
  bool _isSaving = false;
  String? _selectedCategory;

  final _situationController = TextEditingController();
  final _automaticThoughtController = TextEditingController();
  final _evidenceForController = TextEditingController();
  final _evidenceAgainstController = TextEditingController();
  final _balancedThoughtController = TextEditingController();

  int _intensityBefore = 5;
  int _intensityAfter = 5;

  final List<_BranchChoice> _branchChoices = const [
    _BranchChoice(
      id: 'relationship',
      label: 'Relationship',
      icon: Icons.favorite_outline_rounded,
    ),
    _BranchChoice(
      id: 'school_work',
      label: 'School / work',
      icon: Icons.school_outlined,
    ),
    _BranchChoice(
      id: 'mistake_regret',
      label: 'Mistake / regret',
      icon: Icons.replay_rounded,
    ),
    _BranchChoice(
      id: 'future_worry',
      label: 'Future worry',
      icon: Icons.cloud_outlined,
    ),
    _BranchChoice(
      id: 'self_doubt',
      label: 'Self-doubt',
      icon: Icons.person_outline_rounded,
    ),
    _BranchChoice(
      id: 'sad_low',
      label: 'Sad / low',
      icon: Icons.sentiment_dissatisfied_outlined,
    ),
    _BranchChoice(
      id: 'angry_frustrated',
      label: 'Angry / frustrated',
      icon: Icons.local_fire_department_outlined,
    ),
    _BranchChoice(
      id: 'hurt_disappointed',
      label: 'Hurt / disappointed',
      icon: Icons.healing_outlined,
    ),
    _BranchChoice(
      id: 'something_else',
      label: 'Something else',
      icon: Icons.help_outline_rounded,
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

  _BranchPrompts get _currentPrompts => _promptsFor(_selectedCategory);

  List<_WizardStep> get _steps {
    final prompts = _currentPrompts;

    return [
      const _WizardStep(
        title: 'What kind of situation is this?',
        subtitle: 'Choose the closest fit. You can change it later.',
        isCategoryStep: true,
      ),
      _WizardStep(
        title: prompts.situationTitle,
        subtitle: prompts.situationSubtitle,
        hint: prompts.situationHint,
        controller: _situationController,
      ),
      _WizardStep(
        title: prompts.thoughtTitle,
        subtitle: prompts.thoughtSubtitle,
        hint: prompts.thoughtHint,
        controller: _automaticThoughtController,
      ),
      const _WizardStep(
        title: 'How strong does it feel?',
        subtitle: 'Rate how intense the thought feels right now.',
        isIntensityStep: true,
        isBeforeIntensity: true,
      ),
      _WizardStep(
        title: prompts.evidenceForTitle,
        subtitle: prompts.evidenceForSubtitle,
        hint: prompts.evidenceForHint,
        controller: _evidenceForController,
      ),
      _WizardStep(
        title: prompts.evidenceAgainstTitle,
        subtitle: prompts.evidenceAgainstSubtitle,
        hint: prompts.evidenceAgainstHint,
        controller: _evidenceAgainstController,
      ),
      _WizardStep(
        title: prompts.balancedTitle,
        subtitle: prompts.balancedSubtitle,
        hint: prompts.balancedHint,
        controller: _balancedThoughtController,
      ),
      const _WizardStep(
        title: 'How strong does it feel now?',
        subtitle: 'Rate the thought after reflecting on it.',
        isIntensityStep: true,
        isBeforeIntensity: false,
      ),
    ];
  }

  _BranchPrompts _promptsFor(String? category) {
    switch (category) {
      case 'relationship':
        return const _BranchPrompts(
          situationTitle: 'What happened between you?',
          situationSubtitle: 'Describe the interaction without judging yourself yet.',
          situationHint: 'e.g. “My friend did not reply all day.”',
          thoughtTitle: 'What did you assume it meant?',
          thoughtSubtitle: 'What did their words, silence, or action seem to say?',
          thoughtHint: 'e.g. “They must be upset with me.”',
          evidenceForTitle: 'What supports that interpretation?',
          evidenceForSubtitle: 'What made it feel true in the moment?',
          evidenceForHint: 'e.g. “They usually reply quickly.”',
          evidenceAgainstTitle: 'What else could be going on?',
          evidenceAgainstSubtitle: 'Consider another explanation, without forcing it.',
          evidenceAgainstHint: 'e.g. “They could be busy or dealing with something.”',
          balancedTitle: 'What is a fairer way to see it?',
          balancedSubtitle: 'Make room for your feelings and other possibilities.',
          balancedHint: 'e.g. “I felt ignored, but I do not know their reason yet.”',
        );
      case 'school_work':
        return const _BranchPrompts(
          situationTitle: 'What pressure are you facing?',
          situationSubtitle: 'Name the task, expectation, or moment that feels heavy.',
          situationHint: 'e.g. “I have an exam and I have not finished studying.”',
          thoughtTitle: 'What are you telling yourself about it?',
          thoughtSubtitle: 'What prediction or judgement keeps showing up?',
          thoughtHint: 'e.g. “I am going to fail everything.”',
          evidenceForTitle: 'What makes that thought feel true?',
          evidenceForSubtitle: 'Look at the facts that are worrying you.',
          evidenceForHint: 'e.g. “I have not understood two topics.”',
          evidenceAgainstTitle: 'What shows another side?',
          evidenceAgainstSubtitle: 'Remember skills, support, effort, or options you still have.',
          evidenceAgainstHint: 'e.g. “I still have time to ask for help and practise.”',
          balancedTitle: 'What is a more useful way to see it?',
          balancedSubtitle: 'Turn the pressure into one realistic next step.',
          balancedHint: 'e.g. “I may struggle, but I can focus on the next topic.”',
        );
      case 'mistake_regret':
        return const _BranchPrompts(
          situationTitle: 'What happened?',
          situationSubtitle: 'Describe the mistake or moment you keep replaying.',
          situationHint: 'e.g. “I said something careless in front of everyone.”',
          thoughtTitle: 'What are you blaming yourself for?',
          thoughtSubtitle: 'Name the harsh thought that came up.',
          thoughtHint: 'e.g. “I always ruin things.”',
          evidenceForTitle: 'What makes the self-blame feel true?',
          evidenceForSubtitle: 'Look at what you wish had gone differently.',
          evidenceForHint: 'e.g. “I should have thought before speaking.”',
          evidenceAgainstTitle: 'What was outside your control?',
          evidenceAgainstSubtitle: 'Separate responsibility from attacking yourself.',
          evidenceAgainstHint: 'e.g. “It was one moment, not everything about me.”',
          balancedTitle: 'What would responsibility without self-attack sound like?',
          balancedSubtitle: 'Be honest about what you can learn and repair.',
          balancedHint: 'e.g. “I made a mistake, and I can apologise and learn.”',
        );
      case 'future_worry':
        return const _BranchPrompts(
          situationTitle: 'What are you worried might happen?',
          situationSubtitle: 'Describe the future situation your mind keeps visiting.',
          situationHint: 'e.g. “I might not get the opportunity I want.”',
          thoughtTitle: 'What prediction keeps returning?',
          thoughtSubtitle: 'What does your mind say will definitely happen?',
          thoughtHint: 'e.g. “Everything will go badly.”',
          evidenceForTitle: 'What makes that prediction feel likely?',
          evidenceForSubtitle: 'Name the uncertainty or facts behind the worry.',
          evidenceForHint: 'e.g. “There are parts I cannot control.”',
          evidenceAgainstTitle: 'What else is possible or already true?',
          evidenceAgainstSubtitle: 'Look for facts, options, and outcomes you may be forgetting.',
          evidenceAgainstHint: 'e.g. “There are still several ways this could go.”',
          balancedTitle: 'What can you focus on today?',
          balancedSubtitle: 'Bring the thought back to a manageable present step.',
          balancedHint: 'e.g. “I cannot know the outcome yet, but I can prepare.”',
        );
      case 'self_doubt':
        return const _BranchPrompts(
          situationTitle: 'What are you doubting about yourself?',
          situationSubtitle: 'Name the ability, quality, or decision you are questioning.',
          situationHint: 'e.g. “I do not think I am good enough for this.”',
          thoughtTitle: 'What are you telling yourself you cannot do?',
          thoughtSubtitle: 'Write the thought as it actually sounds in your head.',
          thoughtHint: 'e.g. “Everyone else is better than me.”',
          evidenceForTitle: 'What seems to support that thought?',
          evidenceForSubtitle: 'Look at the moments that fed the doubt.',
          evidenceForHint: 'e.g. “Someone else answered faster.”',
          evidenceAgainstTitle: 'What evidence shows another side?',
          evidenceAgainstSubtitle: 'Remember effort, progress, strengths, or context.',
          evidenceAgainstHint: 'e.g. “I have learned difficult things before.”',
          balancedTitle: 'What would you say to a friend here?',
          balancedSubtitle: 'Offer yourself the same fairness you would offer them.',
          balancedHint: 'e.g. “Being unsure does not mean I cannot improve.”',
        );
      case 'sad_low':
        return const _BranchPrompts(
          situationTitle: 'What has been weighing on you?',
          situationSubtitle: 'Describe the moment or feeling without needing to solve it yet.',
          situationHint: 'e.g. “I have felt disconnected from everyone this week.”',
          thoughtTitle: 'What thought comes with the sadness?',
          thoughtSubtitle: 'What does the low feeling seem to say about you or your life?',
          thoughtHint: 'e.g. “Nothing is going to get better.”',
          evidenceForTitle: 'What makes that thought feel true?',
          evidenceForSubtitle: 'Notice the experiences behind the feeling.',
          evidenceForHint: 'e.g. “The last few days have been hard.”',
          evidenceAgainstTitle: 'What support or exceptions exist?',
          evidenceAgainstSubtitle: 'Look for even small moments that do not fit the thought.',
          evidenceAgainstHint: 'e.g. “One person did check on me yesterday.”',
          balancedTitle: 'What would a kinder perspective be?',
          balancedSubtitle: 'Do not force positivity; make the thought more complete.',
          balancedHint: 'e.g. “This is a hard week, but it is not the whole story.”',
        );
      case 'angry_frustrated':
        return const _BranchPrompts(
          situationTitle: 'What set this off?',
          situationSubtitle: 'Describe the event, person, or obstacle that sparked the feeling.',
          situationHint: 'e.g. “My work was changed without anyone telling me.”',
          thoughtTitle: 'What felt unfair or blocked?',
          thoughtSubtitle: 'Name the meaning your mind gave the situation.',
          thoughtHint: 'e.g. “Nobody respects my effort.”',
          evidenceForTitle: 'What makes your reaction feel justified?',
          evidenceForSubtitle: 'Acknowledge what genuinely felt wrong or difficult.',
          evidenceForHint: 'e.g. “I was left out of an important decision.”',
          evidenceAgainstTitle: 'What would help you respond without making things worse?',
          evidenceAgainstSubtitle: 'Separate what you can control from what you cannot.',
          evidenceAgainstHint: 'e.g. “I can ask for clarity before I reply.”',
          balancedTitle: 'What response matches the person you want to be?',
          balancedSubtitle: 'Make room for the anger while choosing your next action.',
          balancedHint: 'e.g. “My frustration is valid, and I can communicate it clearly.”',
        );
      case 'hurt_disappointed':
        return const _BranchPrompts(
          situationTitle: 'What happened that hurt?',
          situationSubtitle: 'Describe what felt disappointing, painful, or unfair.',
          situationHint: 'e.g. “Someone I trusted cancelled without explaining.”',
          thoughtTitle: 'What did you hope would happen?',
          thoughtSubtitle: 'Name the expectation or need that was not met.',
          thoughtHint: 'e.g. “I thought they would show up for me.”',
          evidenceForTitle: 'What did the moment seem to say?',
          evidenceForSubtitle: 'Notice what you started believing about yourself or others.',
          evidenceForHint: 'e.g. “Maybe I do not matter to them.”',
          evidenceAgainstTitle: 'What else might be true?',
          evidenceAgainstSubtitle: 'Consider another explanation without dismissing the hurt.',
          evidenceAgainstHint: 'e.g. “Their choice hurt me, but it does not define my value.”',
          balancedTitle: 'What do you need now?',
          balancedSubtitle: 'Choose a perspective or boundary that respects the feeling.',
          balancedHint: 'e.g. “I can acknowledge the hurt and decide what support I need.”',
        );
      case 'something_else':
      default:
        return const _BranchPrompts(
          situationTitle: 'What happened?',
          situationSubtitle: 'Tell us what happened in your own words.',
          situationHint: 'Describe the situation as briefly or fully as you want.',
          thoughtTitle: 'What thought came up?',
          thoughtSubtitle: 'What went through your mind in that moment?',
          thoughtHint: 'Write the thought as it actually sounded.',
          evidenceForTitle: 'What supports this thought?',
          evidenceForSubtitle: 'What made it feel true at the time?',
          evidenceForHint: 'Write the facts or experiences that came to mind.',
          evidenceAgainstTitle: 'What challenges this thought?',
          evidenceAgainstSubtitle: 'Is there another explanation or piece of information?',
          evidenceAgainstHint: 'Write anything that gives the situation more context.',
          balancedTitle: 'What is a more balanced thought?',
          balancedSubtitle: 'Make room for the feeling and the wider picture.',
          balancedHint: 'Write a fairer way to describe what is happening.',
        );
    }
  }

  bool get _isLastStep => _currentStep == _steps.length - 1;

  bool get _canGoNext {
    final step = _steps[_currentStep];
    if (step.isCategoryStep) return _selectedCategory != null;
    if (step.isIntensityStep) return true;
    return step.controller?.text.trim().isNotEmpty ?? false;
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
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in before saving this exercise.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final record = ThoughtRecordModel(
      id: '',
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
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save this thought record. Try again.'),
        ),
      );
    }
  }

  void _showCompletionDialog() {
    final before = _intensityBefore;
    final after = _intensityAfter;
    final improved = after < before;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('You finished the reframe'),
        content: Text(
          improved
              ? 'Your rating moved from $before to $after. That suggests the thought felt a little lighter after reflecting on it.'
              : 'You worked through the full exercise. A feeling does not have to change immediately for the reflection to be useful.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
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
                    const SizedBox(height: 24),
                    if (step.isCategoryStep)
                      _buildCategoryGrid()
                    else if (step.isIntensityStep)
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

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _branchChoices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 9,
        mainAxisSpacing: 9,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final choice = _branchChoices[index];
        final selected = _selectedCategory == choice.id;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = choice.id;
            });
          },
          borderRadius: BorderRadius.circular(17),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.primary.withValues(alpha: 0.13)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: selected
                    ? AppTheme.primary
                    : AppTheme.surfaceBorder.withValues(alpha: 0.8),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  choice.icon,
                  color: selected ? AppTheme.primary : AppTheme.textLight,
                  size: 23,
                ),
                const SizedBox(height: 8),
                Text(
                  choice.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected
                        ? AppTheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 11,
                    height: 1.15,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(height: 5),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.primary,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(_WizardStep step) {
    return TextField(
      controller: step.controller,
      autofocus: true,
      maxLines: 5,
      minLines: 3,
      textCapitalization: TextCapitalization.sentences,
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

    return Container(
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
                Text('Barely there', style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
                Text('Overwhelming', style: TextStyle(color: AppTheme.textLight, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

class _BranchChoice {
  final String id;
  final String label;
  final IconData icon;

  const _BranchChoice({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class _BranchPrompts {
  final String situationTitle;
  final String situationSubtitle;
  final String situationHint;
  final String thoughtTitle;
  final String thoughtSubtitle;
  final String thoughtHint;
  final String evidenceForTitle;
  final String evidenceForSubtitle;
  final String evidenceForHint;
  final String evidenceAgainstTitle;
  final String evidenceAgainstSubtitle;
  final String evidenceAgainstHint;
  final String balancedTitle;
  final String balancedSubtitle;
  final String balancedHint;

  const _BranchPrompts({
    required this.situationTitle,
    required this.situationSubtitle,
    required this.situationHint,
    required this.thoughtTitle,
    required this.thoughtSubtitle,
    required this.thoughtHint,
    required this.evidenceForTitle,
    required this.evidenceForSubtitle,
    required this.evidenceForHint,
    required this.evidenceAgainstTitle,
    required this.evidenceAgainstSubtitle,
    required this.evidenceAgainstHint,
    required this.balancedTitle,
    required this.balancedSubtitle,
    required this.balancedHint,
  });
}

class _WizardStep {
  final String title;
  final String subtitle;
  final String? hint;
  final TextEditingController? controller;
  final bool isIntensityStep;
  final bool? isBeforeIntensity;
  final bool isCategoryStep;

  const _WizardStep({
    required this.title,
    required this.subtitle,
    this.hint,
    this.controller,
    this.isIntensityStep = false,
    this.isBeforeIntensity,
    this.isCategoryStep = false,
  });
}
