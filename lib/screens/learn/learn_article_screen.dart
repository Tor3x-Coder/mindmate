import 'package:flutter/material.dart';

import '../../models/learn_article_model.dart';
import '../../utils/app_theme.dart';
import '../breathing/breathing_screen.dart';
import '../chat/chat_tab_screen.dart';
import '../emergency_support_screen.dart';
import '../journal/journal_screen.dart';
import '../mood/mood_checkin_screen.dart';

class LearnArticleScreen extends StatelessWidget {
  final LearnArticle article;

  const LearnArticleScreen({
    required this.article,
    super.key,
  });

  void _openChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatTabScreen(learnArticle: article),
      ),
    );
  }

  void _openNextStep(BuildContext context) {
    final Widget screen;

    switch (article.nextStepTool) {
      case LearnTool.breathing:
        screen = const BreathingScreen();
      case LearnTool.moodCheckIn:
        screen = const MoodCheckinScreen();
      case LearnTool.journal:
        screen = const JournalScreen();
      case LearnTool.emergencySupport:
        screen = const EmergencySupportScreen();
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _ArticleHeader(
              article: article,
              brightness: brightness,
            ),
            const SizedBox(height: 26),
            ...article.sections.asMap().entries.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key == article.sections.length - 1
                          ? 0
                          : 22,
                    ),
                    child: _ArticleSection(section: entry.value),
                  ),
                ),
            const SizedBox(height: 28),
            _NextStepCard(
              article: article,
              onPressed: () => _openNextStep(context),
              onAskMindMate: () => _openChat(context),
            ),
            const SizedBox(height: 18),
            const Text(
              'This article is general information, not medical advice. MindMate is not a doctor, therapist, or emergency service. If you are in immediate danger, use local emergency help now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleHeader extends StatelessWidget {
  final LearnArticle article;
  final Brightness brightness;

  const _ArticleHeader({
    required this.article,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = brightness == Brightness.dark
        ? AppTheme.textOnDark
        : AppTheme.textDark;
    final supportingColor = brightness == Brightness.dark
        ? const Color(0xFFB9D3CE)
        : const Color(0xFF35545B);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(brightness),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  article.readTime,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.menu_book_rounded,
                color: AppTheme.primary,
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            article.title,
            style: TextStyle(
              color: titleColor,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            article.description,
            style: TextStyle(
              color: supportingColor,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleSection extends StatelessWidget {
  final LearnArticleSection section;

  const _ArticleSection({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.heading,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 9),
        ...section.paragraphs.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == section.paragraphs.length - 1 ? 0 : 10,
                ),
                child: Text(
                  entry.value,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _NextStepCard extends StatelessWidget {
  final LearnArticle article;
  final VoidCallback onPressed;
  final VoidCallback onAskMindMate;

  const _NextStepCard({
    required this.article,
    required this.onPressed,
    required this.onAskMindMate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.42),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'A small next step',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            article.nextStepTitle,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            article.nextStepDescription,
            style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(article.nextStepLabel),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(height: 9),
          OutlinedButton.icon(
            onPressed: onAskMindMate,
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('Ask MindMate about this'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
