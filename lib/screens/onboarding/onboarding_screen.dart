import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_settings_controller.dart';
import '../../services/auth_service.dart';
import '../../services/reminder_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../main_nav_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Set<String> _selectedGoals = {};
  String? _selectedReminderTime;
  bool _isSaving = false;

  Future<void> _handleFinish() async {
    if (_selectedGoals.isEmpty || _selectedReminderTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please pick at least one goal and a reminder time.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final authService = context.read<AuthService>();
      final uid = authService.currentUser!.uid;

      final reminderTime = _selectedReminderTime!;
      await authService.saveOnboardingData(
        uid: uid,
        goals: _selectedGoals.toList(),
        reminderTime: reminderTime,
      );

      await context
          .read<AppSettingsController>()
          .updateCheckInWindow(reminderTime);
      await context.read<ReminderService>().scheduleDaily(
            reminderTime,
            requestPermission: true,
          );

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainNavScreen(showFirstUseGuide: true),
        ),
        (route) => false,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Something went wrong. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(title: const Text('Let\'s personalize MindMate')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What would you like to improve?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select all that apply.',
                style: TextStyle(color: AppTheme.textLight),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: onboardingGoals.map((goal) {
                  final isSelected = _selectedGoals.contains(goal);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected
                            ? _selectedGoals.remove(goal)
                            : _selectedGoals.add(goal);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.surfaceBorder.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Text(
                        goal,
                        style: TextStyle(
                          color: isSelected ? Colors.white : onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              const Text(
                'Preferred reminder time',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'When should we check in with you?',
                style: TextStyle(color: AppTheme.textLight),
              ),
              const SizedBox(height: 16),
              Column(
                children: reminderTimes.map((time) {
                  final isSelected = _selectedReminderTime == time;
                  return RadioListTile<String>(
                    value: time,
                    groupValue: _selectedReminderTime,
                    onChanged: (value) =>
                        setState(() => _selectedReminderTime = value),
                    title: Text(
                      time,
                      style: TextStyle(color: onSurface),
                    ),
                    activeColor: AppTheme.primary,
                    tileColor: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.12)
                        : Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleFinish,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Finish Setup'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
