import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

// Placeholder Terms & Conditions text. Written to be genuinely usable
// for a school project demo, but should be reviewed by a real person
// (or adapted from a proper template) before any real public launch,
// especially the data/privacy sections once real users are involved.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MindMate Terms & Conditions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              const Text(
                'Last updated: August 2026',
                style: TextStyle(color: AppTheme.textLight, fontSize: 12),
              ),
              const SizedBox(height: 24),

              const _Section(
                title: '1. What MindMate Is',
                body:
                    'MindMate is a wellness companion app designed to support '
                    'healthy daily habits through mood tracking, journaling, '
                    'guided breathing and meditation exercises, and a '
                    'directory to help you connect with wellness '
                    'professionals.',
              ),
              const _Section(
                title: '2. What MindMate Is NOT',
                body:
                    'MindMate does not diagnose medical or mental health '
                    'conditions, prescribe treatment or medication, replace '
                    'a doctor or licensed therapist, or provide emergency '
                    'medical advice. If you are experiencing a medical or '
                    'mental health emergency, please contact emergency '
                    'services or a crisis helpline in your area immediately.',
              ),
              const _Section(
                title: '3. Your Account',
                body:
                    'You are responsible for keeping your login details '
                    'secure. You must be old enough to legally create an '
                    'account in your country, or have permission from a '
                    'parent or guardian. Please provide accurate '
                    'information when registering.',
              ),
              const _Section(
                title: '4. Your Data',
                body:
                    'Information you enter into MindMate \u2014 including mood '
                    'logs, journal entries, and wellness assessments \u2014 is '
                    'stored securely and is only accessible to you unless '
                    'you choose to share it (for example, when requesting '
                    'an appointment with a professional). We do not sell '
                    'your personal data.',
              ),
              const _Section(
                title: '5. The Professional Directory',
                body:
                    'MindMate helps you find and request appointments with '
                    'listed professionals. We do not employ these '
                    'professionals, and we do not guarantee the accuracy of '
                    'their listed information or the outcome of any '
                    'appointment. Appointment requests are not automatically '
                    'confirmed \u2014 they are reviewed before being accepted.',
              ),
              const _Section(
                title: '6. Acceptable Use',
                body:
                    'Please use MindMate respectfully. Do not use the app '
                    'to harass others, impersonate someone else, or attempt '
                    'to access another user\u2019s account or data.',
              ),
              const _Section(
                title: '7. Changes to These Terms',
                body:
                    'We may update these terms from time to time as '
                    'MindMate grows. Significant changes will be '
                    'communicated within the app.',
              ),
              const _Section(
                title: '8. Contact',
                body:
                    'Questions about these terms can be directed to the '
                    'MindMate team through the app\u2019s support channel.',
              ),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'This is a placeholder document written for early '
                  'development and testing. Before MindMate is released '
                  'publicly, this text should be reviewed and finalized '
                  'by someone with legal expertise, particularly the '
                  'sections covering data privacy and professional '
                  'directory liability.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }
}