import 'package:flutter/material.dart';

import '../../models/personalised_guidance_model.dart';
import '../../services/chat_service.dart';
import '../../utils/app_theme.dart';
import '../breathing/breathing_screen.dart';
import '../chat/chat_tab_screen.dart';
import '../cbt/cbt_thought_reframe_screen.dart';
import '../emergency_support_screen.dart';
import '../journal/journal_screen.dart';
import '../learn/learn_screen.dart';
import '../meditation/meditation_screen.dart';

class PersonalisedGuidanceScreen extends StatelessWidget {
  final ContextualCheckIn checkIn;
  final PersonalisedGuidanceResult result;

  const PersonalisedGuidanceScreen({
    super.key,
    required this.checkIn,
    required this.result,
  });

  Future<void> _openAction(BuildContext context, GuidanceAction action) async {
    switch (action.actionId) {
      case GuidanceAction.breathing:
        await _push(context, const BreathingScreen());
        return;
      case GuidanceAction.meditation:
        await _push(context, const MeditationScreen());
        return;
      case GuidanceAction.journalPrompt:
        await _push(context, const JournalScreen());
        return;
      case GuidanceAction.thoughtReframe:
        await _push(context, const CbtThoughtReframeScreen());
        return;
      case GuidanceAction.openLearn:
        await _push(context, const LearnScreen());
        return;
      case GuidanceAction.openChat:
      case GuidanceAction.smallPlan:
        await _push(context, const ChatTabScreen());
        return;
      case GuidanceAction.trustedPersonPrompt:
        await _showTrustedPersonPrompt(context);
        return;
      case GuidanceAction.openEmergencySupport:
        await _push(context, const EmergencySupportScreen());
        return;
    }
  }

  Future<void> _push(BuildContext context, Widget screen) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _showTrustedPersonPrompt(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose someone you trust'),
        content: const Text(
          'Think of one person you could message or sit with. You could say: “I am having a hard moment. Can you stay with me for a bit?”',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('I’ll think about it'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChatTabScreen()),
              );
            },
            child: const Text('Talk it through'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, GuidanceAction action) {
    return FilledButton.icon(
      onPressed: () => _openAction(context, action),
      icon: const Icon(Icons.arrow_forward_rounded),
      label: Text(action.title),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCrisisView(BuildContext context) {
    final reply = result.crisisReply ??
        'Please open Emergency Support and move near someone you trust.';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.danger.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.danger.withValues(alpha: 0.35),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: AppTheme.danger,
                  size: 32,
                ),
                SizedBox(height: 12),
                Text(
                  'You deserve human support right now.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(reply, style: const TextStyle(fontSize: 15, height: 1.5)),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => _openAction(
              context,
              const GuidanceAction(
                title: 'Open Emergency Support',
                description: 'Find immediate human support.',
                actionId: GuidanceAction.openEmergencySupport,
              ),
            ),
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text('Open Emergency Support'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceView(BuildContext context) {
    final guidance = result.guidance!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildIntroCard(context, guidance),
          const SizedBox(height: 16),
          Text(
            'Your next step',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          _buildNextStepCard(context, guidance),
          const SizedBox(height: 20),
          Text(
            'Other ways to try',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...guidance.alternatives.map(
            (action) => _buildAlternativeTile(context, action),
          ),
          if (guidance.question != null) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      guidance.question!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            'You can try the step, choose another, or stop here. MindMate does not diagnose.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(
    BuildContext context,
    PersonalisedGuidanceResponse guidance,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHAT MIGHT BE GOING ON',
            style: TextStyle(
              color: Color(0xFF35545B),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            guidance.acknowledgement,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            guidance.whatMightBeHappening,
            style: const TextStyle(
              color: Color(0xFF35545B),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextStepCard(
    BuildContext context,
    PersonalisedGuidanceResponse guidance,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.near_me_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ONE SAFE STEP',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            guidance.nextStep.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            guidance.nextStep.description,
            style: const TextStyle(fontSize: 14, height: 1.45),
          ),
          const SizedBox(height: 12),
          Text(
            guidance.whyItMayHelp,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButton(context, guidance.nextStep),
        ],
      ),
    );
  }

  Widget _buildAlternativeTile(BuildContext context, GuidanceAction action) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: () => _openAction(context, action),
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              action.title,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              action.description,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One Safe Step'),
      ),
      body: SafeArea(
        child: result.isCrisis
            ? _buildCrisisView(context)
            : result.guidance == null
                ? const Center(child: Text('No guidance is available yet.'))
                : _buildGuidanceView(context),
      ),
    );
  }
}
