import 'package:flutter_test/flutter_test.dart';

import 'package:mindmate/utils/learn_articles.dart';

void main() {
  test('bundled Learn library contains the six approved articles', () {
    expect(learnArticles, hasLength(6));
    expect(
      learnArticles.map((article) => article.id),
      containsAll(<String>[
        'supports',
        'damages',
        'substances',
        'coping',
        'help-nigeria',
        'friend',
      ]),
    );

    for (final article in learnArticles) {
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

    expect(content, contains('cannabis'));
    expect(content, contains('Alcohol'));
    expect(content, contains('Codeine-based syrups'));
    expect(content, contains('Tramadol'));
    expect(content, contains('Inhalants'));
    expect(content, contains('Myth'));
    expect(content, contains('Reality'));
  });
}
