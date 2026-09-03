import 'package:flutter_test/flutter_test.dart';

import 'package:mindmate/utils/learn_articles.dart';

void main() {
  test('bundled Learn library contains the approved core and explore reads', () {
    expect(learnArticles, hasLength(16));
    expect(learnExploreArticles, hasLength(8));
    expect(
      learnArticles.map((article) => article.id),
      containsAll(<String>[
        'supports',
        'damages',
        'substances',
        'coping',
        'help-nigeria',
        'friend',
        'day-starts-badly',
        'school-work-overwhelming',
        'social-media-behind',
        'unreturned-feelings',
        'breakup-week',
        'love-pressure',
        'mixed-signals-boundaries',
        'panic-next-step',
        'friend-cannot-stay-safe',
        'substance-emergency',
      ]),
    );

    for (final article in [...learnArticles, ...learnExploreArticles]) {
      expect(article.description, isNotEmpty);
      expect(article.readTime, contains('min read'));
      expect(article.sections, isNotEmpty);
      expect(article.nextStepTitle, isNotEmpty);
      expect(article.nextStepDescription, isNotEmpty);
      expect(article.nextStepLabel, isNotEmpty);
    }
  });

  test('the substances article covers the approved conversation topics', () {
    final article = learnArticles.firstWhere(
      (article) => article.id == 'substances',
    );
    final content = [
      article.title,
      ...article.sections.map((section) => section.heading),
      ...article.sections.expand((section) => section.paragraphs),
    ].join(' ');

    final normalizedContent = content.toLowerCase();
    expect(normalizedContent, contains('cannabis'));
    expect(normalizedContent, contains('alcohol'));
    expect(normalizedContent, contains('codeine-based syrups'));
    expect(normalizedContent, contains('tramadol'));
    expect(normalizedContent, contains('inhalants'));
    expect(normalizedContent, contains('myth'));
    expect(normalizedContent, contains('reality'));
  });
}
