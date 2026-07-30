class FirestoreCollections {
  static const String users = 'users';
  static const String moodLogs = 'mood_logs';
  static const String journalEntries = 'journal_entries';
  static const String wellnessAssessments = 'wellness_assessments';
  static const String meditationHistory = 'meditation_history';
  static const String breathingSessions = 'breathing_sessions';
  static const String professionals = 'professionals';
  static const String appointments = 'appointments';
}

class MoodOption {
  final String emoji;
  final String label;
  const MoodOption(this.emoji, this.label);
}

const List<MoodOption> moodOptions = [
  MoodOption('😊', 'Happy'),
  MoodOption('😄', 'Excited'),
  MoodOption('😐', 'Okay'),
  MoodOption('😔', 'Sad'),
  MoodOption('😣', 'Stressed'),
  MoodOption('😡', 'Angry'),
  MoodOption('😴', 'Tired'),
];

const List<String> onboardingGoals = [
  'Stress Management',
  'Better Sleep',
  'Emotional Wellness',
  'Focus',
  'Healthy Habits',
];

const List<String> reminderTimes = ['Morning', 'Afternoon', 'Evening'];
