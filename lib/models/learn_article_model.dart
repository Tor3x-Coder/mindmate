enum LearnTool {
  breathing,
  moodCheckIn,
  journal,
  emergencySupport,
}

enum LearnCategory {
  everydayLife,
  loveAndPeople,
  difficultMoments,
  gettingHelp,
}

extension LearnCategoryCopy on LearnCategory {
  String get title {
    switch (this) {
      case LearnCategory.everydayLife:
        return 'Everyday life';
      case LearnCategory.loveAndPeople:
        return 'Love and people';
      case LearnCategory.difficultMoments:
        return 'Understanding difficult moments';
      case LearnCategory.gettingHelp:
        return 'Getting help';
    }
  }

  String get description {
    switch (this) {
      case LearnCategory.everydayLife:
        return 'Small situations that can quietly shape how a day feels.';
      case LearnCategory.loveAndPeople:
        return 'The relationship and friendship situations that can stay on your mind.';
      case LearnCategory.difficultMoments:
        return 'A little clarity for moments that feel harder to make sense of.';
      case LearnCategory.gettingHelp:
        return 'When it is time to bring another person into the conversation.';
    }
  }
}

class LearnArticleSection {
  final String heading;
  final List<String> paragraphs;

  const LearnArticleSection({
    required this.heading,
    required this.paragraphs,
  });
}

class LearnArticle {
  final String id;
  final String title;
  final String description;
  final String readTime;
  final LearnCategory category;
  final List<LearnArticleSection> sections;
  final String nextStepTitle;
  final String nextStepDescription;
  final String nextStepLabel;
  final LearnTool nextStepTool;

  const LearnArticle({
    required this.id,
    required this.title,
    required this.description,
    required this.readTime,
    required this.category,
    required this.sections,
    required this.nextStepTitle,
    required this.nextStepDescription,
    required this.nextStepLabel,
    required this.nextStepTool,
  });

  String get searchText {
    return [
      title,
      description,
      ...sections.map((section) => section.heading),
      ...sections.expand((section) => section.paragraphs),
    ].join(' ').toLowerCase();
  }

  /// Sends only the selected approved article to the AI, never the whole
  /// library or the user's reading history.
  String get aiContext {
    final text = [
      'Learn article title: $title',
      'Article summary: $description',
      ...sections.expand(
        (section) => [
          section.heading,
          ...section.paragraphs,
        ],
      ),
    ].join('\n');

    return text.length > 5000 ? text.substring(0, 5000) : text;
  }
}
