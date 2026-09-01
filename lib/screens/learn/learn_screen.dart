import 'package:flutter/material.dart';

import '../../models/learn_article_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/learn_articles.dart';
import 'learn_article_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  void _openArticle(BuildContext context, LearnArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LearnArticleScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const _LearnIntroCard(),
            const SizedBox(height: 24),
            Text(
              'Explore the topics',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Take what is useful and leave what is not. You can come back whenever you want.',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            ...learnArticles.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _LearnArticleCard(
                      article: entry.value,
                      index: entry.key,
                      onTap: () => _openArticle(context, entry.value),
                    ),
                  ),
                ),
            const SizedBox(height: 8),
            const Text(
              'MindMate’s Learn content is general information, not medical advice. If you need urgent help, open Support right now from the app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearnIntroCard extends StatelessWidget {
  const _LearnIntroCard();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textColor = brightness == Brightness.dark
        ? AppTheme.textOnDark
        : AppTheme.textDark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradientFor(brightness),
        borderRadius: BorderRadius.circular(27),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HONEST READS',
                  style: TextStyle(
                    color: Color(0xFF35545B),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  'Understand your mind without the lecture.',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Calm, practical reads about what can help, what can hurt, and when to bring in human support.',
                  style: TextStyle(
                    color: Color(0xFF35545B),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.62),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: AppTheme.primary,
              size: 29,
              semanticLabel: 'Learn',
            ),
          ),
        ],
      ),
    );
  }
}

class _LearnArticleCard extends StatelessWidget {
  final LearnArticle article;
  final int index;
  final VoidCallback onTap;

  const _LearnArticleCard({
    required this.article,
    required this.index,
    required this.onTap,
  });

  static const List<IconData> _icons = [
    Icons.spa_outlined,
    Icons.battery_alert_outlined,
    Icons.science_outlined,
    Icons.loop_rounded,
    Icons.support_agent_outlined,
    Icons.people_outline_rounded,
  ];

  static const List<Color> _colors = [
    AppTheme.primary,
    AppTheme.accent,
    Color(0xFF52759A),
    AppTheme.secondary,
    AppTheme.danger,
    Color(0xFF8A6B9F),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[index % _colors.length];
    final icon = _icons[index % _icons.length];

    return Semantics(
      button: true,
      label: '${article.title}, ${article.readTime}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 47,
                height: 47,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      article.description,
                      style: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.readTime,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
