import 'package:flutter/material.dart';

import '../../models/structured_programme_model.dart';
import '../../services/demo_entitlement_service.dart';
import '../../utils/app_theme.dart';
import '../breathing/breathing_screen.dart';
import '../cbt/cbt_thought_reframe_screen.dart';
import '../chat/chat_tab_screen.dart';
import '../emergency_support_screen.dart';
import '../journal/journal_screen.dart';
import '../learn/learn_screen.dart';
import '../meditation/meditation_screen.dart';

class ProgrammePlayerScreen extends StatefulWidget {
  final StructuredProgramme programme;

  const ProgrammePlayerScreen({super.key, required this.programme});

  @override
  State<ProgrammePlayerScreen> createState() => _ProgrammePlayerScreenState();
}

class _ProgrammePlayerScreenState extends State<ProgrammePlayerScreen> {
  final DemoEntitlementService _entitlementService = DemoEntitlementService();
  Set<int> _completedDays = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final completed =
        await _entitlementService.getCompletedDays(widget.programme.id);
    if (!mounted) return;
    setState(() {
      _completedDays = completed;
      _isLoading = false;
    });
  }

  Future<void> _toggleDayComplete(int dayNumber) async {
    final isCompleted = _completedDays.contains(dayNumber);
    if (isCompleted) {
      await _entitlementService.markDayIncomplete(
          widget.programme.id, dayNumber);
    } else {
      await _entitlementService.markDayComplete(
          widget.programme.id, dayNumber);
    }
    await _loadProgress();
  }

  Future<void> _openAction(String actionId, ProgrammeDay day) async {
    Widget? destination;
    switch (actionId) {
      case 'breathing':
        destination = const BreathingScreen();
        break;
      case 'meditation':
        destination = const MeditationScreen();
        break;
      case 'journal_prompt':
        destination = const JournalScreen();
        break;
      case 'thought_reframe':
        destination = const CbtThoughtReframeScreen();
        break;
      case 'small_plan':
        destination = const ChatTabScreen(initialMode: 'make_plan');
        break;
      case 'open_learn':
        destination = const LearnScreen();
        break;
      case 'open_chat':
        destination = const ChatTabScreen(initialMode: 'listen');
        break;
      case 'trusted_person_prompt':
        destination = const EmergencySupportScreen();
        break;
      case 'open_emergency_support':
        destination = const EmergencySupportScreen();
        break;
      default:
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Action not available in demo')),
        );
        return;
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination!),
    );

    // After returning, mark day as complete automatically if user interacted
    // (user can also manually toggle)
    if (!mounted) return;
    if (!_completedDays.contains(day.dayNumber)) {
      // Show gentle prompt to mark complete
      final shouldMark = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Mark Day ${day.dayNumber} complete?'),
          content: Text(
            'You tried "${day.activityTitle}". Would you like to mark this day as done? You can always unmark it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not yet'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Mark done'),
            ),
          ],
        ),
      );
      if (shouldMark == true) {
        await _toggleDayComplete(day.dayNumber);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.programme;
    final progress = _completedDays.length;
    final total = p.days.length;
    final progressPercent = total == 0 ? 0.0 : progress / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.title),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDemoBanner(),
                    const SizedBox(height: 16),
                    _buildProgressCard(
                        progress, total, progressPercent, p.color),
                    const SizedBox(height: 18),
                    Text(
                      'Your 7-day journey',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Each day: check-in → what might be happening → one safe step → reflect. No diagnosis, no prescription.',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...p.days.map((day) => _buildDayCard(day, p.color)),
                    const SizedBox(height: 20),
                    _buildFooter(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDemoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE69C)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_rounded, size: 18, color: Color(0xFF856404)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo access unlocked — no payment was processed. Local demo only.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF856404),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
      int progress, int total, double percent, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$progress / $total days',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Progress is stored locally on this device only. No diagnosis or clinical tracking.',
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(ProgrammeDay day, Color programColor) {
    final isCompleted = _completedDays.contains(day.dayNumber);
    final color = isCompleted ? AppTheme.success : programColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? AppTheme.success.withValues(alpha: 0.4)
              : AppTheme.surfaceBorder.withValues(alpha: 0.8),
          width: isCompleted ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: isCompleted
                    ? const Icon(Icons.check_rounded,
                        color: AppTheme.success, size: 20)
                    : Text(
                        '${day.dayNumber}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: programColor,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            day.focus,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isCompleted)
                          const Text(
                            'Done',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.success,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      day.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _toggleDayComplete(day.dayNumber),
                icon: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: color,
                ),
                tooltip: isCompleted ? 'Mark incomplete' : 'Mark complete',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            day.description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_iconForAction(day.actionId),
                        size: 16, color: color),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        day.activityTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  day.activityDescription,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openAction(day.actionId, day),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text('Try ${day.activityTitle.toLowerCase()}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded,
                    size: 16, color: AppTheme.textLight),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reflect: ${day.reflectionPrompt}',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'This programme is illustrative future depth. It does not diagnose, prescribe, or replace human support. If you need immediate help, use Emergency Support. Demo progress is local only and can be cleared in Settings.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.textLight,
          fontSize: 11,
          height: 1.35,
        ),
      ),
    );
  }

  IconData _iconForAction(String actionId) {
    switch (actionId) {
      case 'breathing':
        return Icons.air_rounded;
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'journal_prompt':
        return Icons.book_outlined;
      case 'thought_reframe':
        return Icons.psychology_outlined;
      case 'small_plan':
        return Icons.checklist_rounded;
      case 'open_learn':
        return Icons.menu_book_rounded;
      case 'open_chat':
        return Icons.chat_bubble_outline_rounded;
      case 'trusted_person_prompt':
        return Icons.favorite_border_rounded;
      case 'open_emergency_support':
        return Icons.support_agent_rounded;
      default:
        return Icons.near_me_rounded;
    }
  }
}
