import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/feedback_record_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import 'breathing/breathing_screen.dart';
import 'cbt/cbt_thought_reframe_screen.dart';
import 'chat/chat_tab_screen.dart';
import 'journal/journal_screen.dart';
import 'meditation/meditation_screen.dart';
import 'professional/professional_directory_screen.dart';

/// The first frontend version of MindMate's core NextStep experience.
///
/// This screen is intentionally frontend-only for now. It uses simple
/// rule-based options and keeps feedback in local screen state. Later, the
/// selected action and feedback can be connected to Firestore and the AI
/// recommendation layer without redesigning the UI.
class NextStepScreen extends StatefulWidget {
  final String moodLabel;
  final String moodEmoji;
  final String? impactLabel;
  final int? intensity;

  const NextStepScreen({
    super.key,
    required this.moodLabel,
    required this.moodEmoji,
    this.impactLabel,
    this.intensity,
  });

  @override
  State<NextStepScreen> createState() => _NextStepScreenState();
}

class _NextStepScreenState extends State<NextStepScreen> {
  final ScrollController _scrollController = ScrollController();

  late final List<_NextStepOption> _options;
  int _selectedOptionIndex = 0;
  _ActionFeedback? _feedback;
  bool _hasOpenedAnActivity = false;
  bool _showFeedback = false;
  bool _isSavingFeedback = false;
  bool _hasSavedFeedback = false;
  String? _saveFeedbackError;

  @override
  void initState() {
    super.initState();
    _options = _optionsForMood(widget.moodLabel);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<_NextStepOption> _optionsForMood(String label) {
    final mood = label.toLowerCase();

    final breathing = _NextStepOption(
      id: 'breathing',
      title: 'A short breathing reset',
      subtitle: 'Slow your body down before trying to solve everything.',
      detail: 'A simple guided pattern for the next few minutes.',
      icon: Icons.air_rounded,
      color: AppTheme.primary,
      builder: (_) => const BreathingScreen(),
    );

    final journal = _NextStepOption(
      id: 'journal',
      title: 'Write it out',
      subtitle: 'Put the feeling somewhere outside your head.',
      detail: 'A private journal entry with an optional prompt.',
      icon: Icons.book_outlined,
      color: AppTheme.secondary,
      builder: (_) => const JournalScreen(),
    );

    final meditation = _NextStepOption(
      id: 'meditation',
      title: 'A gentle wind-down',
      subtitle: 'Give your mind and body a softer place to land.',
      detail: 'Choose a short guided meditation session.',
      icon: Icons.self_improvement_rounded,
      color: AppTheme.secondary,
      builder: (_) => const MeditationScreen(),
    );

    final positiveChat = _NextStepOption(
      id: 'positive_chat',
      title: 'Tell me about it',
      subtitle: mood.contains('excited')
          ? 'What are you looking forward to?'
          : 'What made you feel this way?',
      detail: 'Share as much or as little as you want.',
      icon: Icons.chat_bubble_outline_rounded,
      color: AppTheme.primary,
      ctaLabel: 'Tell me about it',
      builder: (_) => const ChatTabScreen(),
    );

    final positiveJournal = _NextStepOption(
      id: 'positive_journal',
      title: mood.contains('excited') ? 'Enjoy the moment' : 'Keep the moment',
      subtitle: mood.contains('excited')
          ? 'Take a moment to notice what you are looking forward to.'
          : 'Take a moment to notice what made today feel good.',
      detail: 'A private reflection with no pressure to make it perfect.',
      icon: Icons.favorite_border_rounded,
      color: AppTheme.secondary,
      ctaLabel: mood.contains('excited') ? 'Enjoy the moment' : 'Keep the moment',
      builder: (_) => const JournalScreen(),
    );

    final reframe = _NextStepOption(
      id: 'reframe',
      title: 'Reframe one thought',
      subtitle: 'Slow down a difficult thought and look at it from both sides.',
      detail: 'A guided thought exercise, one step at a time.',
      icon: Icons.psychology_outlined,
      color: AppTheme.accent,
      builder: (_) => const CbtThoughtReframeScreen(),
    );

    final chat = _NextStepOption(
      id: 'chat',
      title: 'Talk it through',
      subtitle: 'Use the AI companion as a supportive sounding board.',
      detail: 'You can talk, ask for perspective, or make a small plan.',
      icon: Icons.chat_bubble_outline_rounded,
      color: const Color(0xFF8C9BE8),
      builder: (_) => const ChatTabScreen(),
    );

    final support = _NextStepOption(
      id: 'support',
      title: 'Explore human support',
      subtitle: 'Find a real person when you would rather not handle it alone.',
      detail: 'Browse the support directory and available professionals.',
      icon: Icons.people_outline_rounded,
      color: AppTheme.danger,
      builder: (_) => const ProfessionalDirectoryScreen(),
    );

    // These are simple frontend rules for the first prototype. The later
    // recommendation layer can use mood, intensity, history, and feedback.
    if (mood.contains('sad')) {
      return [chat, journal, breathing, reframe, support];
    }

    if (mood.contains('stressed') || mood.contains('angry')) {
      return [breathing, reframe, journal, chat, support];
    }

    if (mood.contains('tired')) {
      return [meditation, breathing, journal, chat, support];
    }

    if (mood.contains('happy') || mood.contains('excited')) {
      return [positiveChat, positiveJournal, breathing, reframe, support];
    }

    return [breathing, journal, meditation, chat, support];
  }

  Future<void> _openSelectedActivity() async {
    final option = _options[_selectedOptionIndex];

    setState(() {
      _hasOpenedAnActivity = true;
      _feedback = null;
      _showFeedback = false;
    });

    await Navigator.of(context).push(
      MaterialPageRoute(builder: option.builder),
    );

    if (!mounted) return;

    setState(() {
      _feedback = null;
      _showFeedback = true;
    });
    _scrollToFeedback();
  }

  void _scrollToFeedback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _selectAlternative() {
    setState(() {
      _selectedOptionIndex =
          (_selectedOptionIndex + 1) % _options.length;
      _feedback = null;
      _showFeedback = false;
      _hasSavedFeedback = false;
      _saveFeedbackError = null;
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _saveFeedback(_ActionFeedback feedback) async {
    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      setState(() => _saveFeedbackError = 'Please log in to save feedback.');
      return;
    }

    final selected = _options[_selectedOptionIndex];

    setState(() {
      _feedback = feedback;
      _isSavingFeedback = true;
      _saveFeedbackError = null;
    });

    final record = FeedbackRecordModel(
      id: '',
      uid: uid,
      moodLabel: widget.moodLabel,
      moodEmoji: widget.moodEmoji,
      moodImpact: widget.impactLabel,
      activityId: selected.id,
      activityTitle: selected.title,
      feedback: _feedbackLabels[feedback] ?? '',
      date: DateTime.now(),
    );

    try {
      await context.read<FirestoreService>().addFeedbackRecord(record);
      if (!mounted) return;
      setState(() {
        _isSavingFeedback = false;
        _hasSavedFeedback = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSavingFeedback = false;
        _saveFeedbackError = 'Could not save your feedback. It may not have been saved.';
      });
    }
  }

  String get _momentTitle {
    final mood = widget.moodLabel.toLowerCase();

    if (mood.contains('happy')) return 'That’s nice to hear.';
    if (mood.contains('excited')) return 'You sound excited.';
    if (mood.contains('sad')) {
      return 'You don’t have to carry this alone.';
    }
    if (mood.contains('stressed')) {
      return 'Let’s make this moment more manageable.';
    }
    if (mood.contains('angry')) {
      return 'Let’s give this feeling somewhere to go.';
    }
    if (mood.contains('tired')) {
      return 'Let’s give your mind and body a softer place to land.';
    }
    return 'You seem steady right now.';
  }

  String get _momentSubtitle {
    final mood = widget.moodLabel.toLowerCase();

    if (mood.contains('happy')) return 'What made you feel this way?';
    if (mood.contains('excited')) return 'What are you looking forward to?';
    if (mood.contains('sad')) {
      return 'Let’s choose something gentle for this moment.';
    }
    if (mood.contains('stressed')) {
      return 'You can take one small step at a time.';
    }
    if (mood.contains('angry')) {
      return 'We can slow things down before deciding what to do next.';
    }
    if (mood.contains('tired')) {
      return 'A gentle reset may be enough for now.';
    }
    return 'Want to keep the momentum going?';
  }

  String get _impactSummary {
    final impact = widget.impactLabel;

    if (impact == null) {
      if (widget.intensity == null) {
        return 'Here is one gentle place to start.';
      }
      return 'You rated the feeling ${widget.intensity}/10.';
    }

    if (impact == 'Not sure yet') {
      return 'You do not have to label it yet.';
    }

    return 'It is affecting you ${impact.toLowerCase()} right now.';
  }

  String get _feedbackMessage {
    switch (_feedback) {
      case _ActionFeedback.muchBetter:
        return 'That sounds like a useful step for this moment.';
      case _ActionFeedback.better:
        return 'Even a small shift counts. You can keep going gently.';
      case _ActionFeedback.same:
        return 'That is okay. Different approaches work for different moments.';
      case _ActionFeedback.worse:
      case _ActionFeedback.muchWorse:
        return 'Thank you for being honest. Let’s try a different direction.';
      case _ActionFeedback.notSure:
        return 'That is completely okay. You do not have to know immediately.';
      case null:
        return '';
    }
  }

  bool get _needsAnotherOption {
    return _feedback == _ActionFeedback.muchWorse ||
        _feedback == _ActionFeedback.worse ||
        _feedback == _ActionFeedback.same ||
        _feedback == _ActionFeedback.notSure;
  }

  // Option A keeps the screen calm by showing only two alternatives at a
  // time instead of turning the recommendation screen into another library.
  List<int> get _alternativeIndexes {
    final indexes = List<int>.generate(_options.length, (index) => index)
        .where((index) => index != _selectedOptionIndex)
        .toList();
    return indexes.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _options[_selectedOptionIndex];
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your next step'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCheckInSummary(textColor),
              const SizedBox(height: 24),
              Text(
                _momentTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                _momentSubtitle,
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              _buildRecommendedCard(selected),
              const SizedBox(height: 24),
              Text(
                'Other ways to help',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              ..._alternativeIndexes.map(
                (index) => _buildAlternativeTile(_options[index], index),
              ),
              if (_hasOpenedAnActivity && _showFeedback) ...[
                const SizedBox(height: 14),
                _buildFeedbackCard(),
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('I’m done for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInSummary(Color textColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Text(widget.moodEmoji, style: const TextStyle(fontSize: 30)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You checked in as ${widget.moodLabel.toLowerCase()}.',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _impactSummary,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.76),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(_NextStepOption option) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: option.color.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: option.color.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: option.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(option.icon, color: option.color),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'RECOMMENDED FOR RIGHT NOW',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            option.title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 7),
          Text(
            option.subtitle,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            option.detail,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _openSelectedActivity,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(
              option.ctaLabel ?? 'Start ${option.title.toLowerCase()}',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: option.color,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeTile(_NextStepOption option, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedOptionIndex = index;
            _feedback = null;
            _showFeedback = false;
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.surfaceBorder.withValues(alpha: 0.75),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: option.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(option.icon, color: option.color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      option.subtitle,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.textLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    final selectedFeedback = _feedback;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'How did that feel?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            'There is no right answer. Your honest feedback helps choose a better next step.',
            style: TextStyle(color: AppTheme.textLight, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _feedbackLabels.entries.map((entry) {
              final isSelected = selectedFeedback == entry.key;
              return ChoiceChip(
                label: Text(entry.value),
                selected: isSelected,
                selectedColor: AppTheme.primary.withValues(alpha: 0.22),
                onSelected: (_) => _saveFeedback(entry.key),
              );
            }).toList(),
          ),
          if (_saveFeedbackError != null) ...[
            const SizedBox(height: 14),
            Text(
              _saveFeedbackError!,
              style: const TextStyle(
                color: AppTheme.danger,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          if (_isSavingFeedback) ...[
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Text('Saving your feedback...', style: TextStyle(fontSize: 13)),
              ],
            ),
          ],
          if (_hasSavedFeedback) ...[
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
                SizedBox(width: 8),
                Text(
                  'Feedback saved',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
          if (selectedFeedback != null && !_isSavingFeedback) ...[
            const SizedBox(height: 14),
            Text(
              _feedbackMessage,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
          if (_needsAnotherOption) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _selectAlternative,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try a different approach'),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfessionalDirectoryScreen(),
                ),
              ),
              icon: const Icon(Icons.people_outline_rounded),
              label: const Text('Explore human support'),
            ),
          ],
        ],
      ),
    );
  }
}

class _NextStepOption {
  final String id;
  final String title;
  final String subtitle;
  final String detail;
  final IconData icon;
  final Color color;
  final String? ctaLabel;
  final WidgetBuilder builder;

  const _NextStepOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.icon,
    required this.color,
    this.ctaLabel,
    required this.builder,
  });
}

enum _ActionFeedback {
  muchWorse,
  worse,
  same,
  better,
  muchBetter,
  notSure,
}

const Map<_ActionFeedback, String> _feedbackLabels = {
  _ActionFeedback.muchWorse: 'Much worse',
  _ActionFeedback.worse: 'A little worse',
  _ActionFeedback.same: 'About the same',
  _ActionFeedback.better: 'A little better',
  _ActionFeedback.muchBetter: 'Much better',
  _ActionFeedback.notSure: 'Not sure yet',
};

