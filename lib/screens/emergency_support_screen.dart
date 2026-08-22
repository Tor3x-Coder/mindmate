import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'professional/professional_directory_screen.dart';
import '../utils/app_theme.dart';

class EmergencySupportScreen extends StatefulWidget {
  const EmergencySupportScreen({super.key});

  @override
  State<EmergencySupportScreen> createState() =>
      _EmergencySupportScreenState();
}

class _EmergencySupportScreenState extends State<EmergencySupportScreen> {
  String? _lastAction;
  bool _showFollowUp = false;

  Future<void> _openExternal(Uri uri, String actionLabel) async {
    final canOpen = await canLaunchUrl(uri);

    if (!canOpen) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This support option could not be opened here.'),
        ),
      );
      return;
    }

    await launchUrl(uri);

    if (!mounted) return;
    setState(() {
      _lastAction = actionLabel;
      _showFollowUp = true;
    });
  }

  Future<void> _call(String number, String actionLabel) {
    return _openExternal(Uri.parse('tel:$number'), actionLabel);
  }

  Future<void> _openResourceDirectory(String actionLabel) {
    return _openExternal(
      Uri.parse('https://findahelpline.com/'),
      actionLabel,
    );
  }

  void _openProfessionalSupport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfessionalDirectoryScreen(),
      ),
    );
  }

  void _setFollowUp(String answer) {
    setState(() {
      _showFollowUp = false;
      _lastAction = answer;
    });

    if (answer == 'I still need immediate help') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please use the emergency or crisis call options above.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support right now')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _buildIntro(),
            const SizedBox(height: 22),
            const Text(
              'Are you in immediate danger?',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 9),
            _HelpCard(
              title: 'National Emergency Line',
              subtitle: 'For immediate danger anywhere in Nigeria.',
              actionLabel: 'Call 112',
              icon: Icons.warning_amber_rounded,
              urgent: true,
              onAction: () => _call('112', 'Emergency line'),
            ),
            _HelpCard(
              title: 'Lagos Emergency Line',
              subtitle: 'Local emergency response in Lagos.',
              actionLabel: 'Call 767',
              icon: Icons.location_on_outlined,
              urgent: true,
              onAction: () => _call('767', 'Lagos emergency line'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose a way to get support',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 9),
            _HelpCard(
              title: 'Call a crisis support line',
              subtitle: 'Use a trained human support service.',
              actionLabel: 'Find a line',
              icon: Icons.phone_in_talk_outlined,
              onAction: () => _openResourceDirectory('Crisis support'),
            ),
            _HelpCard(
              title: 'MANI',
              subtitle: 'Mentally Aware Nigeria Initiative support resources.',
              actionLabel: 'Open resources',
              icon: Icons.support_agent_rounded,
              onAction: () => _openResourceDirectory('MANI resources'),
            ),
            _HelpCard(
              title: 'SURPIN',
              subtitle: 'Suicide prevention and trained-counsellor resources.',
              actionLabel: 'Open resources',
              icon: Icons.chat_outlined,
              onAction: () => _openResourceDirectory('SURPIN resources'),
            ),
            _HelpCard(
              title: 'Find professional support',
              subtitle: 'For support that is not immediately urgent.',
              actionLabel: 'View professionals',
              icon: Icons.people_outline_rounded,
              onAction: _openProfessionalSupport,
            ),
            if (_showFollowUp) ...[
              const SizedBox(height: 14),
              _buildFollowUpCard(),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'If someone you trust is nearby, you can ask them to stay with you. MindMate does not contact anyone automatically and is not a replacement for emergency or professional care.',
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

  Widget _buildIntro() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientLight,
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SUPPORT RIGHT NOW',
            style: TextStyle(
              color: Color(0xFF59646F),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 11),
          Text(
            'You deserve support in a difficult moment.',
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Choose the option that fits what you need right now.',
            style: TextStyle(
              color: Color(0xFF59646F),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpCard() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _lastAction == null
                ? 'Did you manage to reach someone?'
                : 'Did you manage to use $_lastAction?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'MindMate cannot know whether a call or message was completed, so your answer is optional and honest.',
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FollowUpChip(
                label: 'I connected',
                onTap: () => _setFollowUp('I connected'),
              ),
              _FollowUpChip(
                label: 'Not yet',
                onTap: () => _setFollowUp('Not yet'),
              ),
              _FollowUpChip(
                label: 'Still need help',
                onTap: () => _setFollowUp('I still need immediate help'),
              ),
              _FollowUpChip(
                label: 'Not sure',
                onTap: () => _setFollowUp('Not sure'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final bool urgent;
  final VoidCallback onAction;

  const _HelpCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.onAction,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final actionColor = urgent ? AppTheme.danger : AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: urgent
              ? AppTheme.danger.withValues(alpha: 0.45)
              : AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: actionColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
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
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: actionColor,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _FollowUpChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FollowUpChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
