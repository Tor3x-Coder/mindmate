enum LearnTool {
  breathing,
  moodCheckIn,
  journal,
  emergencySupport,
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
    required this.sections,
    required this.nextStepTitle,
    required this.nextStepDescription,
    required this.nextStepLabel,
    required this.nextStepTool,
  });
}
