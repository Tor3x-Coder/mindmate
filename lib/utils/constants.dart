class FirestoreCollections {
  static const String users = 'users';
  static const String moodLogs = 'mood_logs';
  static const String journalEntries = 'journal_entries';
  static const String wellnessAssessments = 'wellness_assessments';
  static const String meditationHistory = 'meditation_history';
  static const String breathingSessions = 'breathing_sessions';
  static const String professionals = 'professionals';
  static const String appointments = 'appointments';
  static const String thoughtRecords = 'thought_records';
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

// Categories for the Professional Support Directory (from the original spec).
const List<String> professionalCategories = [
  'Counselor',
  'Psychologist',
  'Psychiatrist',
  'Physiotherapist',
  'Dietitian',
  'General Practitioner',
];

const List<String> consultationTypes = ['Online', 'Physical'];

const List<String> appointmentStatuses = ['pending', 'approved', 'declined'];
