import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_settings_controller.dart';
import '../../utils/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Tune the app to match your calm.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 20),
            _SectionCard(
              title: 'Appearance',
              subtitle: 'Set the mood and readability of your space.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme mode',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ChoicePill(
                        label: 'Dark',
                        selected: settings.themeMode == ThemeMode.dark,
                        onTap: () => settings.updateThemeMode(ThemeMode.dark),
                      ),
                      _ChoicePill(
                        label: 'Light',
                        selected: settings.themeMode == ThemeMode.light,
                        onTap: () => settings.updateThemeMode(ThemeMode.light),
                      ),
                      _ChoicePill(
                        label: 'System',
                        selected: settings.themeMode == ThemeMode.system,
                        onTap: () => settings.updateThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Text(
                        'Text size',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        '${settings.textScale.toStringAsFixed(2)}x',
                        style: const TextStyle(color: AppTheme.textLight),
                      ),
                    ],
                  ),
                  Slider(
                    value: settings.textScale,
                    min: 0.9,
                    max: 1.2,
                    divisions: 6,
                    label: '${settings.textScale.toStringAsFixed(2)}x',
                    onChanged: settings.updateTextScale,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Experience',
              subtitle: 'Control how lively and sensory the app feels.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Animation intensity',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ChoicePill(
                        label: 'Low',
                        selected: settings.animationIntensity == 0.6,
                        onTap: () => settings.updateAnimationIntensity(0.6),
                      ),
                      _ChoicePill(
                        label: 'Balanced',
                        selected: settings.animationIntensity == 1.0,
                        onTap: () => settings.updateAnimationIntensity(1.0),
                      ),
                      _ChoicePill(
                        label: 'Full',
                        selected: settings.animationIntensity == 1.3,
                        onTap: () => settings.updateAnimationIntensity(1.3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SwitchListTile(
                    value: settings.hapticsEnabled,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Haptics'),
                    subtitle: const Text(
                      'Gentle tactile feedback for taps and key moments.',
                    ),
                    onChanged: settings.updateHapticsEnabled,
                  ),
                  SwitchListTile(
                    value: settings.soundEnabled,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ambient sounds'),
                    subtitle: const Text(
                      'Keep sound support ready for richer guided sessions.',
                    ),
                    onChanged: settings.updateSoundEnabled,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Daily Flow',
              subtitle: 'Set the rhythm for your check-ins and practice.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Check-in window',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const ['Morning', 'Afternoon', 'Evening']
                        .map(
                          (window) => _ChoicePill(
                            label: window,
                            selected: settings.checkInWindow == window,
                            onTap: () => settings.updateCheckInWindow(window),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Preferred practice length',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [3, 5, 10]
                        .map(
                          (minutes) => _ChoicePill(
                            label: '$minutes min',
                            selected:
                                settings.preferredSessionMinutes == minutes,
                            onTap: () => settings.updatePreferredSessionMinutes(
                              minutes,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textLight),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.accentGradient : null,
          color: selected ? null : AppTheme.surfaceAlt.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : AppTheme.surfaceBorder.withValues(alpha: 0.85),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
