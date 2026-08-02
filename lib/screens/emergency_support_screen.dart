import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';

class EmergencySupportScreen extends StatelessWidget {
  const EmergencySupportScreen({super.key});

  Future<void> _call(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support Right Now')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You don\'t have to go through this alone.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The people below are trained to help, right now, '
                    'for free and confidentially.',
                    style: TextStyle(color: AppTheme.textLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'In immediate danger',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 10),
            _HelpCard(
              title: 'National Emergency Line',
              subtitle: 'For any immediate danger, anywhere in Nigeria.',
              number: '112',
              onCall: () => _call('112'),
            ),
            _HelpCard(
              title: 'Lagos Emergency Line',
              subtitle: 'Local emergency response in Lagos.',
              number: '767',
              onCall: () => _call('767'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Talk to someone (free & confidential)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 10),
            _HelpCard(
              title: 'MANI (Mentally Aware Nigeria Initiative)',
              subtitle: 'Crisis support and someone to talk to.',
              number: '',
              trailing: 'Find on findahelpline.com',
            ),
            _HelpCard(
              title: 'SURPIN Suicide Prevention Helpline',
              subtitle: '24-hour national helpline, trained counsellors.',
              number: '',
              trailing: 'Search "SURPIN helpline"',
            ),
            const SizedBox(height: 24),
            const Text(
              'A gentle reminder',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Text(
              'MindMate is here to support daily habits, but it is not a '
              'substitute for real help in a crisis. Reaching out to one '
              'of the people above is a strong, capable thing to do.',
              style: TextStyle(color: AppTheme.textLight, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String number;
  final String? trailing;
  final VoidCallback? onCall;

  const _HelpCard({
    required this.title,
    required this.subtitle,
    required this.number,
    this.trailing,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
              ],
            ),
          ),
          if (onCall != null)
            ElevatedButton.icon(
              onPressed: onCall,
              icon: const Icon(Icons.call, size: 16),
              label: Text(number),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            )
          else if (trailing != null)
            Text(trailing!, style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
        ],
      ),
    );
  }
}