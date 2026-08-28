import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_settings_controller.dart';
import '../../utils/app_theme.dart';
import 'delete_account_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('App settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            const _SectionTitle(title: 'Appearance'),
            _SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ThemeChoice(
                        label: 'Light',
                        icon: Icons.light_mode_outlined,
                        selected: settings.themeMode == ThemeMode.light,
                        onTap: () => settings.updateThemeMode(ThemeMode.light),
                      ),
                      _ThemeChoice(
                        label: 'System',
                        icon: Icons.brightness_auto_outlined,
                        selected: settings.themeMode == ThemeMode.system,
                        onTap: () => settings.updateThemeMode(ThemeMode.system),
                      ),
                      _ThemeChoice(
                        label: 'Dark',
                        icon: Icons.dark_mode_outlined,
                        selected: settings.themeMode == ThemeMode.dark,
                        onTap: () => settings.updateThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _SliderSetting(
                    title: 'Text size',
                    valueLabel: '${(settings.textScale * 100).round()}%',
                    value: settings.textScale,
                    min: 0.9,
                    max: 1.2,
                    divisions: 6,
                    onChanged: settings.updateTextScale,
                  ),
                  _SliderSetting(
                    title: 'Animation intensity',
                    valueLabel: '${(settings.animationIntensity * 100).round()}%',
                    value: settings.animationIntensity,
                    min: 0.6,
                    max: 1.3,
                    divisions: 7,
                    onChanged: settings.updateAnimationIntensity,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle(title: 'Experience'),
            _SettingsCard(
              child: Column(
                children: [
                  _SwitchSetting(
                    title: 'Haptics',
                    subtitle: 'Use small vibrations during supported interactions.',
                    value: settings.hapticsEnabled,
                    onChanged: settings.updateHapticsEnabled,
                  ),
                  const Divider(height: 18),
                  _SwitchSetting(
                    title: 'Guided voice',
                    subtitle: 'Play natural voice prompts in supported sessions.',
                    value: settings.soundEnabled,
                    onChanged: settings.updateSoundEnabled,
                  ),
                  const Divider(height: 18),
                  _ActionSetting(
                    icon: Icons.explore_outlined,
                    title: 'Replay app tour',
                    subtitle: 'See Home, Practice, Chat, and Me again.',
                    onTap: () {
                      settings.requestTourReplay();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle(title: 'Check-in routine'),
            _SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preferred check-in window',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'This saves your preference. Notifications will be connected in a later batch.',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['Morning', 'Afternoon', 'Evening'].map((time) {
                      final selected = settings.checkInWindow == time;
                      return ChoiceChip(
                        label: Text(time),
                        selected: selected,
                        selectedColor: AppTheme.primary.withValues(alpha: 0.18),
                        labelStyle: TextStyle(
                          color: selected
                              ? AppTheme.primary
                              : AppTheme.textDark,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        showCheckmark: false,
                        onSelected: (_) => settings.updateCheckInWindow(time),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Preferred session length',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [1, 3, 5].map((minutes) {
                      final selected =
                          settings.preferredSessionMinutes == minutes;
                      return ChoiceChip(
                        label: Text('$minutes min'),
                        selected: selected,
                        selectedColor: AppTheme.primary.withValues(alpha: 0.18),
                        labelStyle: TextStyle(
                          color: selected
                              ? AppTheme.primary
                              : AppTheme.textDark,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        showCheckmark: false,
                        onSelected: (_) =>
                            settings.updatePreferredSessionMinutes(minutes),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle(title: 'Privacy and data'),
            _SettingsCard(
              child: _ActionSetting(
                icon: Icons.delete_forever_outlined,
                title: 'Delete account',
                subtitle: 'Permanently delete your account and stored data.',
                color: AppTheme.danger,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DeleteAccountScreen(
                        resumePendingDeletion:
                            settings.accountDeletionPending,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle(title: 'About MindMate'),
            const _SettingsCard(
              child: Text(
                'MindMate is a wellness support tool. It does not diagnose conditions, prescribe treatment, replace a professional, or handle emergencies directly.',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: child,
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.13)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : AppTheme.surfaceBorder.withValues(alpha: 0.8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? AppTheme.primary : AppTheme.textLight,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.primary : AppTheme.textDark,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String title;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(
              valueLabel,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ActionSetting extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionSetting({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppTheme.textLight,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSetting({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppTheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
