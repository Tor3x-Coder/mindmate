import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/check_in_context_model.dart';
import '../../models/feedback_record_model.dart';
import '../../models/guidance_response_model.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../breathing/breathing_screen.dart';
import '../cbt/cbt_thought_reframe_screen.dart';
import '../chat/chat_tab_screen.dart';
import '../emergency_support_screen.dart';
import '../journal/journal_screen.dart';
import '../learn/learn_screen.dart';
import '../meditation/meditation_screen.dart';

enum _Helpfulness {
  aLot,
  aLittle,
  notReally,
  differentApproach,
}

const Map<_Helpfulness, String> _helpfulnessLabels = {
  _Helpfulness.aLot: 'A lot',
  _Helpfulness.aLittle: 'A little',
  _Helpfulness.notReally: 'Not really',
  _Helpfulness.differentApproach: 'I want a different approach',
};

class GuidanceResultScreen extends StatefulWidget {
  final CheckInContext checkInContext;
  final GuidanceResponse guidanceResponse;
  final ChatAction? chatAction;

  const GuidanceResultScreen({
    super.key,
    required this.checkInContext,
    required this.guidanceResponse,
    this.chatAction,
  });

  @override
  State<GuidanceResultScreen> createState() => _GuidanceResultScreenState();
}

class _GuidanceResultScreenState extends State<GuidanceResultScreen> {
  final ScrollController _scrollController = ScrollController();
  _Helpfulness? _selectedHelpfulness;
  bool _hasOpenedActivity = false;
  bool _isSavingFeedback = false;
  bool _hasSavedFeedback = false;
  String? _saveError;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _openAction(String actionId) async {
    setState(() {
      _hasOpenedActivity = true;
      _selectedHelpfulness = null;
      _hasSavedFeedback = false;
      _saveError = null;
    });

    Widget? destination;

    switch (actionId) {
      case GuidanceActionIds.breathing:
        destination = const BreathingScreen();
        break;
      case GuidanceActionIds.meditation:
        destination = const MeditationScreen();
        break;
      case GuidanceActionIds.journalPrompt:
        destination = const JournalScreen();
        break;
      case GuidanceActionIds.thoughtReframe:
        destination = const CbtThoughtReframeScreen();
        break;
      case GuidanceActionIds.smallPlan:
        // Small plan is supported via Chat with make_plan mode or journal
        destination = ChatTabScreen(checkInContext: widget.checkInContext);
        break;
      case GuidanceActionIds.openLearn:
        destination = const LearnScreen();
        break;
      case GuidanceActionIds.openChat:
        destination = ChatTabScreen(checkInContext: widget.checkInContext);
        break;
      case GuidanceActionIds.trustedPersonPrompt:
        // Show trusted person prompt then open emergency support for contacts
        await _showTrustedPersonPrompt();
        destination = const EmergencySupportScreen();
        break;
      case GuidanceActionIds.openEmergencySupport:
        destination = const EmergencySupportScreen();
        break;
      default:
        // Should never happen due to allow-list validation, but handle safely
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This action is not available right now.'),
          ),
        );
        return;
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination!),
    );

    if (!mounted) return;
    setState(() {});
    _scrollToFeedback();
  }

  Future<void> _showTrustedPersonPrompt() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reach out to someone you trust'),
        content: const Text(
          'Consider sending a short message to a safe person about how you are feeling. For example: “Hey, I have been feeling a bit low today. Can we check in later?”\n\nYou do not have to share everything — just what feels okay.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EmergencySupportScreen(),
                ),
              );
            },
            child: const Text('Open support'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveFeedback(_Helpfulness helpfulness) async {
    final uid = context.read<AuthService>().currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      setState(() => _saveError = 'Please log in to save feedback.');
      return;
    }

    setState(() {
      _selectedHelpfulness = helpfulness;
      _isSavingFeedback = true;
      _saveError = null;
    });

    final record = FeedbackRecordModel(
      id: '',
      uid: uid,
      moodLabel: widget.checkInContext.feeling.displayLabel,
      moodEmoji: widget.checkInContext.feeling.emoji,
      moodImpact: widget.checkInContext.energySource.displayLabel,
      activityId: widget.guidanceResponse.nextStep.actionId,
      activityTitle: widget.guidanceResponse.nextStep.title,
      feedback: _helpfulnessLabels[helpfulness] ?? '',
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
        _saveError = 'Could not save your feedback. It may not have been saved.';
      });
    }
  }

  String get _feedbackMessage {
    switch (_selectedHelpfulness) {
      case _Helpfulness.aLot:
        return 'That sounds like a useful step for this moment. You can keep going gently.';
      case _Helpfulness.aLittle:
        return 'Even a small shift counts. You can build on it when you are ready.';
      case _Helpfulness.notReally:
        return 'That is okay. Different approaches work for different moments.';
      case _Helpfulness.differentApproach:
        return 'Thank you for being honest. Let us try a different direction.';
      case null:
        return '';
    }
  }

  bool get _needsAlternative =>
      _selectedHelpfulness == _Helpfulness.notReally ||
      _selectedHelpfulness == _Helpfulness.differentApproach;

  @override
  Widget build(BuildContext context) {
    final guidance = widget.guidanceResponse;
    final isCrisis = guidance.isCrisis ||
        widget.chatAction?.opensEmergencySupport == true ||
        guidance.hasEmergencyAction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('One Safe Step'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCheckInSummary(),
              const SizedBox(height: 14),
              _buildJourneyTrail(),
              const SizedBox(height: 22),
              if (isCrisis) _buildCrisisCard(),
              if (isCrisis) const SizedBox(height: 18),
              Text(
                guidance.summary,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
              ),
              const SizedBox(height: 14),
              _buildWhatMightCard(guidance),
              const SizedBox(height: 18),
              _buildNextStepCard(guidance),
              if (guidance.alternatives.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text(
                  'Other ways to help',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                ...guidance.alternatives.map(
                  (alt) => _buildAlternativeTile(alt),
                ),
              ],
              if (guidance.gentleQuestion != null) ...[
                const SizedBox(height: 18),
                _buildGentleQuestionCard(guidance.gentleQuestion!),
              ],
              if (_hasOpenedActivity) ...[
                const SizedBox(height: 18),
                _buildFeedbackCard(),
              ],
              const SizedBox(height: 20),
              _buildSupportFooter(),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                child: const Text('I’m done for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInSummary() {
    final ctx = widget.checkInContext;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Text(ctx.feeling.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You checked in as ${ctx.feeling.displayLabel.toLowerCase()}.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ctx.energySource.displayLabel} • ${ctx.need.displayLabel}',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyTrail() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          const _JourneyStage(
            icon: Icons.check_rounded,
            label: 'Checked in',
            isComplete: true,
          ),
          Expanded(
            child: Divider(
              indent: 8,
              endIndent: 8,
              color: AppTheme.primary.withValues(alpha: 0.35),
            ),
          ),
          const _JourneyStage(
            icon: Icons.near_me_rounded,
            label: 'One safe step',
            isActive: true,
          ),
          Expanded(
            child: Divider(
              indent: 8,
              endIndent: 8,
              color: AppTheme.surfaceBorder.withValues(alpha: 0.9),
            ),
          ),
          const _JourneyStage(
            icon: Icons.edit_note_rounded,
            label: 'Reflect',
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.danger.withValues(alpha: 0.40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.support_agent_rounded,
                    color: AppTheme.danger),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'You deserve immediate support',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'I am an AI companion and cannot provide emergency help, but you deserve human support right now. Please open Emergency Support.',
            style: TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _openAction(GuidanceActionIds.openEmergencySupport),
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('Open Emergency Support'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatMightCard(GuidanceResponse guidance) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  size: 18, color: AppTheme.secondary),
              SizedBox(width: 6),
              Text(
                'WHAT MIGHT BE HAPPENING?',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            guidance.whatMightBeHappening,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 10),
          const Text(
            'This is not a diagnosis — just one way of making sense of what you shared.',
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepCard(GuidanceResponse guidance) {
    final nextStep = guidance.nextStep;
    final color = _colorForAction(nextStep.actionId);
    final icon = _iconForAction(nextStep.actionId);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: color.withValues(alpha: 0.55), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
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
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'ONE SAFE STEP FOR RIGHT NOW',
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
            nextStep.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            nextStep.description,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (nextStep.whyItMightHelp != null ||
              guidance.whyItMightHelp != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.favorite_border_rounded,
                      size: 16, color: color.withValues(alpha: 0.8)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nextStep.whyItMightHelp ??
                          guidance.whyItMightHelp ??
                          'A small step can be easier than solving everything at once.',
                      style: TextStyle(
                        color: color.withValues(alpha: 0.9),
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => _openAction(nextStep.actionId),
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text('Start ${nextStep.title.toLowerCase()}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeTile(GuidanceAlternative alt) {
    final color = _colorForAction(alt.actionId);
    final icon = _iconForAction(alt.actionId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _openAction(alt.actionId),
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
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alt.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGentleQuestionCard(String question) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.chat_bubble_outline_rounded,
              size: 18, color: AppTheme.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              question,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
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
            'Did that help?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          const Text(
            'There is no right answer. Your honest feedback helps choose a better next step.',
            style: TextStyle(
                color: AppTheme.textLight, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _Helpfulness.values.map((h) {
              final isSelected = _selectedHelpfulness == h;
              return ChoiceChip(
                label: Text(_helpfulnessLabels[h]!),
                selected: isSelected,
                selectedColor: AppTheme.primary.withValues(alpha: 0.22),
                onSelected: (_) => _saveFeedback(h),
              );
            }).toList(),
          ),
          if (_saveError != null) ...[
            const SizedBox(height: 14),
            Text(
              _saveError!,
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
                Text('Saving your feedback...',
                    style: TextStyle(fontSize: 13)),
              ],
            ),
          ],
          if (_hasSavedFeedback) ...[
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppTheme.success, size: 18),
                SizedBox(width: 8),
                Text(
                  'Feedback saved',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
          if (_selectedHelpfulness != null && !_isSavingFeedback) ...[
            const SizedBox(height: 14),
            Text(
              _feedbackMessage,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
          if (_needsAlternative) ...[
            const SizedBox(height: 14),
            const Text(
              'Want to try a different approach?',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            ...widget.guidanceResponse.alternatives.map(
              (alt) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  onPressed: () => _openAction(alt.actionId),
                  icon: Icon(_iconForAction(alt.actionId), size: 18),
                  label: Text(alt.title),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatTabScreen(
                    checkInContext: widget.checkInContext,
                  ),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text('Talk it through in Chat'),
            ),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EmergencySupportScreen(),
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

  Widget _buildSupportFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'MindMate is an AI wellbeing companion, not a therapist or emergency service. If you need immediate help, please use Emergency Support.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.textLight,
          fontSize: 11,
          height: 1.35,
        ),
      ),
    );
  }

  Color _colorForAction(String actionId) {
    switch (actionId) {
      case GuidanceActionIds.breathing:
        return AppTheme.primary;
      case GuidanceActionIds.meditation:
        return AppTheme.secondary;
      case GuidanceActionIds.journalPrompt:
        return const Color(0xFF8A6B9F);
      case GuidanceActionIds.thoughtReframe:
        return AppTheme.accent;
      case GuidanceActionIds.smallPlan:
        return const Color(0xFF52759A);
      case GuidanceActionIds.openLearn:
        return AppTheme.secondary;
      case GuidanceActionIds.openChat:
        return const Color(0xFF8C9BE8);
      case GuidanceActionIds.trustedPersonPrompt:
        return const Color(0xFFE6A23C);
      case GuidanceActionIds.openEmergencySupport:
        return AppTheme.danger;
      default:
        return AppTheme.primary;
    }
  }

  IconData _iconForAction(String actionId) {
    switch (actionId) {
      case GuidanceActionIds.breathing:
        return Icons.air_rounded;
      case GuidanceActionIds.meditation:
        return Icons.self_improvement_rounded;
      case GuidanceActionIds.journalPrompt:
        return Icons.book_outlined;
      case GuidanceActionIds.thoughtReframe:
        return Icons.psychology_outlined;
      case GuidanceActionIds.smallPlan:
        return Icons.checklist_rounded;
      case GuidanceActionIds.openLearn:
        return Icons.menu_book_rounded;
      case GuidanceActionIds.openChat:
        return Icons.chat_bubble_outline_rounded;
      case GuidanceActionIds.trustedPersonPrompt:
        return Icons.favorite_border_rounded;
      case GuidanceActionIds.openEmergencySupport:
        return Icons.support_agent_rounded;
      default:
        return Icons.near_me_rounded;
    }
  }
}

class _JourneyStage extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isComplete;
  final bool isActive;

  const _JourneyStage({
    required this.icon,
    required this.label,
    this.isComplete = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isComplete || isActive ? AppTheme.primary : AppTheme.textLight;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isActive ? 0.16 : 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
