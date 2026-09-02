import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/learn_article_model.dart';
import '../../services/app_settings_controller.dart';
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

  void _openExplore(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LearnExploreScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<AppSettingsController?>();
    final addedIds = settings?.addedLearnArticleIds ?? const <String>{};
    final visibleArticles = [
      ...learnArticles,
      ...learnExploreArticles.where((article) => addedIds.contains(article.id)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          IconButton(
            onPressed: () => _openExplore(context),
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Explore more reads',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const _LearnIntroCard(),
            const SizedBox(height: 18),
            _ExploreMoreCard(onTap: () => _openExplore(context)),
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
            const SizedBox(height: 18),
            ...LearnCategory.values.expand(
              (category) {
                final categoryArticles = visibleArticles
                    .where((article) => article.category == category)
                    .toList();
                if (categoryArticles.isEmpty) return <Widget>[];

                return <Widget>[
                  _CategoryHeader(category: category),
                  const SizedBox(height: 10),
                  ...categoryArticles.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LearnArticleCard(
                            article: entry.value,
                            onTap: () => _openArticle(context, entry.value),
                          ),
                        ),
                      ),
                  const SizedBox(height: 12),
                ];
              },
            ),
            const SizedBox(height: 4),
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
    final supportingColor = brightness == Brightness.dark
        ? const Color(0xFFB9D3CE)
        : const Color(0xFF35545B);

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
                Text(
                  'HONEST READS',
                  style: TextStyle(
                    color: supportingColor,
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
                Text(
                  'Calm, practical reads about what can help, what can hurt, and when to bring in human support.',
                  style: TextStyle(
                    color: supportingColor,
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
            child: const Icon(
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

class _ExploreMoreCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ExploreMoreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Explore more Learn reads',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.travel_explore_rounded,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore more',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Search for another situation and add the read to your Learn shelves.',
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final LearnCategory category;

  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          category.description,
          style: const TextStyle(
            color: AppTheme.textLight,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _LearnArticleCard extends StatelessWidget {
  final LearnArticle article;
  final VoidCallback onTap;

  const _LearnArticleCard({
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(article.category);
    final icon = _iconFor(article.category);

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

class LearnExploreScreen extends StatefulWidget {
  const LearnExploreScreen({super.key});

  @override
  State<LearnExploreScreen> createState() => _LearnExploreScreenState();
}

class _LearnExploreScreenState extends State<LearnExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openArticle(LearnArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LearnArticleScreen(article: article),
      ),
    );
  }

  Future<void> _toggleArticle(
    AppSettingsController? settings,
    LearnArticle article,
  ) async {
    if (settings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Learn preferences are not ready yet.')),
      );
      return;
    }

    if (settings.addedLearnArticleIds.contains(article.id)) {
      await settings.removeLearnArticle(article.id);
    } else {
      await settings.addLearnArticle(article.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsController?>();
    final query = _query.trim().toLowerCase();
    final results = learnExploreArticles
        .where((article) => query.isEmpty || article.searchText.contains(query))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Explore more')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Text(
              'Find a read for the situation on your mind.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'These reads are bundled with the app, so adding one works offline. Search by a word or browse the suggestions below.',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                labelText: 'Search Learn',
                hintText: 'Try love, sleep, focus, or boundaries',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 22),
            if (results.isEmpty)
              const _EmptyExploreState()
            else
              ...results.map(
                (article) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ExploreArticleCard(
                    article: article,
                    isAdded: settings?.addedLearnArticleIds.contains(article.id) ??
                        false,
                    onOpen: () => _openArticle(article),
                    onToggle: () => _toggleArticle(settings, article),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExploreArticleCard extends StatelessWidget {
  final LearnArticle article;
  final bool isAdded;
  final VoidCallback onOpen;
  final VoidCallback onToggle;

  const _ExploreArticleCard({
    required this.article,
    required this.isAdded,
    required this.onOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(article.category);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_iconFor(article.category), color: color),
                ),
                const SizedBox(width: 12),
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
                      const SizedBox(height: 7),
                      Text(
                        '${article.category.title}  •  ${article.readTime}',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textLight,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: isAdded
                ? OutlinedButton.icon(
                    onPressed: onToggle,
                    icon: const Icon(Icons.check_rounded, size: 17),
                    label: const Text('Added to Learn'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: onToggle,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add to Learn'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyExploreState extends StatelessWidget {
  const _EmptyExploreState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.35),
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_rounded, color: AppTheme.primary, size: 30),
          SizedBox(height: 10),
          Text(
            'No matching read yet',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 5),
          Text(
            'Try a broader word, or clear the search and browse the full catalogue.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

Color _colorFor(LearnCategory category) {
  switch (category) {
    case LearnCategory.everydayLife:
      return AppTheme.primary;
    case LearnCategory.loveAndPeople:
      return const Color(0xFF8A6B9F);
    case LearnCategory.difficultMoments:
      return const Color(0xFF52759A);
    case LearnCategory.gettingHelp:
      return AppTheme.danger;
  }
}

IconData _iconFor(LearnCategory category) {
  switch (category) {
    case LearnCategory.everydayLife:
      return Icons.wb_sunny_outlined;
    case LearnCategory.loveAndPeople:
      return Icons.people_outline_rounded;
    case LearnCategory.difficultMoments:
      return Icons.waves_rounded;
    case LearnCategory.gettingHelp:
      return Icons.support_agent_outlined;
  }
}
