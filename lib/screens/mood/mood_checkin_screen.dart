import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mood_log_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../next_step_screen.dart';

class MoodCheckinScreen extends StatefulWidget {
  const MoodCheckinScreen({super.key});

  @override
  State<MoodCheckinScreen> createState() => _MoodCheckinScreenState();
}

class _MoodCheckinScreenState extends State<MoodCheckinScreen> {
  // Uses the shared list from constants.dart so mood labels stay consistent
  // with pattern detection and the rest of the app.
  final List<MoodOption> _moods = moodOptions;

  String? _selectedEmoji;
  String? _selectedLabel;
  String? _selectedImpact;
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  bool _isSaving = false;
  String? _errorText;

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  String _friendlyError(Object error) {
    return 'Something went wrong saving your mood. Please try again.';
  }

  Future<void> _saveMood() async {
    setState(() => _errorText = null);

    if (_selectedEmoji == null || _selectedLabel == null) {
      setState(() => _errorText = 'Please pick how you\'re feeling first.');
      return;
    }

    if (_selectedImpact == null) {
      setState(() => _errorText = 'Choose how much it is affecting you.');
      return;
    }

    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid == null) {
      setState(() => _errorText = 'You need to be logged in to save a mood.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final log = MoodLogModel(
        id: '',
        uid: uid,
        emoji: _selectedEmoji!,
        label: _selectedLabel!,
        note: _noteController.text.trim(),
        date: DateTime.now(),
      );

      // The qualitative impact is currently frontend-only. We will add it
      // to the model and Firestore in the backend batch later.
      await firestoreService.addMoodLog(log);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => NextStepScreen(
            moodLabel: _selectedLabel!,
            moodEmoji: _selectedEmoji!,
            impactLabel: _selectedImpact,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorText = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check in'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'A small pause can help us choose what comes next.',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '1 of 2',
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  value: 0.5,
                  minHeight: 5,
                  backgroundColor: AppTheme.surfaceBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'What\'s present right now?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'There\'s no wrong answer. Pick what feels closest.',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final halfWidth = (constraints.maxWidth - 12) / 2;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _moods.map((mood) {
                      final isSelected = _selectedEmoji == mood.emoji;
                      return SizedBox(
                        width: halfWidth,
                        child: _buildMoodOption(
                          mood: mood,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedEmoji = mood.emoji;
                              _selectedLabel = mood.label;
                              _errorText = null;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 28),
              Text(
                'How much is it affecting you?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'No numbers needed. Choose the description that feels closest — or choose not sure.',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final halfWidth = (constraints.maxWidth - 12) / 2;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _impactOptions.map((option) {
                      final isSelected = _selectedImpact == option.label;
                      final isFullWidth = option.label == 'Not sure yet';

                      return SizedBox(
                        width: isFullWidth ? constraints.maxWidth : halfWidth,
                        child: _buildImpactOption(
                          option: option,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedImpact = option.label;
                              _errorText = null;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: () {
                  // Keep the optional note discoverable without forcing the
                  // user to write, then focus the field when requested.
                  FocusScope.of(context).requestFocus(_noteFocusNode);
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        size: 20,
                        color: AppTheme.primary,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Add a note below (optional)',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                focusNode: _noteFocusNode,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your check-in is a reflection, not a diagnosis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    color: AppTheme.danger,
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveMood,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodOption({
    required MoodOption mood,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.seaGlass.withValues(alpha: 0.55)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.surfaceBorder.withValues(alpha: 0.85),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mood.label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primary : onSurface,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactOption({
    required _ImpactOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.13)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.surfaceBorder.withValues(alpha: 0.85),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              color: isSelected ? AppTheme.primary : AppTheme.textLight,
              size: 21,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected ? AppTheme.primary : onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.helper,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primary,
                size: 19,
              ),
          ],
        ),
      ),
    );
  }
}

class _ImpactOption {
  final String label;
  final String helper;
  final IconData icon;

  const _ImpactOption({
    required this.label,
    required this.helper,
    required this.icon,
  });
}

const List<_ImpactOption> _impactOptions = [
  _ImpactOption(
    label: 'A little',
    helper: 'Noticeable, but manageable',
    icon: Icons.wb_sunny_outlined,
  ),
  _ImpactOption(
    label: 'Somewhat',
    helper: 'Affecting your mood or focus',
    icon: Icons.waves_outlined,
  ),
  _ImpactOption(
    label: 'A lot',
    helper: 'Hard to ignore right now',
    icon: Icons.priority_high_rounded,
  ),
  _ImpactOption(
    label: 'Overwhelming',
    helper: 'Taking up most of your attention',
    icon: Icons.bolt_rounded,
  ),
  _ImpactOption(
    label: 'Not sure yet',
    helper: 'You do not have to label it',
    icon: Icons.help_outline_rounded,
  ),
];
