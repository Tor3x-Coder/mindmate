import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Terms & Privacy'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Terms'),
              Tab(text: 'Privacy'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              _TermsTab(),
              _PrivacyTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsTab extends StatelessWidget {
  const _TermsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        const _PlainLanguageBanner(
          title: 'In plain language',
          text:
              'MindMate supports everyday wellbeing. It is not a doctor, therapist, diagnosis service, or emergency service.',
        ),
        const SizedBox(height: 18),
        const _LegalIntro(
          text:
              'Please read these terms before using MindMate. The final public version should be reviewed and approved by a qualified legal professional.',
        ),
        const SizedBox(height: 16),
        _LegalSection(
          title: 'Using MindMate',
          icon: Icons.apps_outlined,
          children: const [
            Text(
              'MindMate provides mood check-ins, journaling, guided breathing, meditation, thought reflection, AI-supported conversation, and links to human support. You are responsible for deciding which tools feel appropriate for you.',
            ),
            SizedBox(height: 10),
            Text(
              'You should not use MindMate as a substitute for advice from a qualified healthcare professional.',
            ),
          ],
        ),
        _LegalSection(
          title: 'AI companion boundaries',
          icon: Icons.auto_awesome_outlined,
          children: const [
            Text(
              'The AI companion can help you reflect, talk through an everyday situation, and consider a small next step. AI responses may be incorrect or unsuitable for your situation.',
            ),
            SizedBox(height: 10),
            Text(
              'The AI is not a human, therapist, doctor, or crisis responder. Do not rely on it for diagnosis, treatment decisions, or emergency support.',
            ),
          ],
        ),
        _LegalSection(
          title: 'Professional and emergency support',
          icon: Icons.support_agent_outlined,
          children: const [
            Text(
              'MindMate may help you find professionals and send appointment requests. A request is not a confirmed booking until it has been reviewed and accepted through the appropriate process.',
            ),
            SizedBox(height: 10),
            Text(
              'If you are in immediate danger, use local emergency services or a verified crisis resource. MindMate cannot provide emergency intervention directly.',
            ),
          ],
        ),
        _LegalSection(
          title: 'Account and data deletion',
          icon: Icons.manage_accounts_outlined,
          children: const [
            Text(
              'You are responsible for keeping your login details private. The final release should provide a clear way to request account and personal-data deletion.',
            ),
            SizedBox(height: 10),
            Text(
              'Do not share another person’s private information in MindMate without permission.',
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _LastUpdatedNotice(),
      ],
    );
  }
}

class _PrivacyTab extends StatelessWidget {
  const _PrivacyTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        const _PlainLanguageBanner(
          title: 'Your choices matter',
          text:
              'Your journal and chat content can be sensitive. MindMate should always be clear about what is stored and when AI is involved.',
        ),
        const SizedBox(height: 18),
        const _LegalIntro(
          text:
              'This is a plain-language privacy overview. It must be replaced or reviewed as a formal Privacy Policy before public release.',
        ),
        const SizedBox(height: 16),
        _LegalSection(
          title: 'What MindMate may collect',
          icon: Icons.data_usage_outlined,
          children: const [
            Text(
              'Depending on the features you use, MindMate may store account details, mood check-ins, journal entries, wellness reflections, meditation history, thought records, appointment requests, and app preferences.',
            ),
          ],
        ),
        _LegalSection(
          title: 'How your information is used',
          icon: Icons.visibility_outlined,
          children: const [
            Text(
              'Your information is used to provide the features you request, show your own history, calculate non-clinical patterns, and improve your experience inside the app.',
            ),
            SizedBox(height: 10),
            Text(
              'MindMate should not use private journal or chat content for unrelated advertising or profiling.',
            ),
          ],
        ),
        _LegalSection(
          title: 'AI processing',
          icon: Icons.psychology_outlined,
          children: const [
            Text(
              'When you use an AI-supported feature, the relevant message or content may be sent to the AI backend so it can produce a response. Journal reflection should be optional and require your permission.',
            ),
            SizedBox(height: 10),
            Text(
              'The app should not send your entire journal history to the AI automatically.',
            ),
          ],
        ),
        _LegalSection(
          title: 'Your controls',
          icon: Icons.tune_rounded,
          children: const [
            Text(
              'The final release should let you review, delete, export, or request deletion of your personal information. You should be able to decide whether optional AI reflections or memories are used.',
            ),
          ],
        ),
        _LegalSection(
          title: 'Security and retention',
          icon: Icons.lock_outline_rounded,
          children: const [
            Text(
              'MindMate uses Firebase services and backend controls to protect access to user data. Security rules, retention periods, deletion behaviour, and any third-party processing must be tested and documented before release.',
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _LastUpdatedNotice(),
      ],
    );
  }
}

class _PlainLanguageBanner extends StatelessWidget {
  final String title;
  final String text;

  const _PlainLanguageBanner({
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalIntro extends StatelessWidget {
  final String text;

  const _LegalIntro({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textLight,
        fontSize: 13,
        height: 1.45,
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _LegalSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children
            .map(
              (child) => DefaultTextStyle(
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 13,
                  height: 1.45,
                ),
                child: child,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _LastUpdatedNotice extends StatelessWidget {
  const _LastUpdatedNotice();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Last updated: add the real legal review date before public release.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppTheme.textLight,
        fontSize: 12,
      ),
    );
  }
}
