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
  static const String feedbackRecords = 'feedback_records';
  static const String trustedContacts = 'trusted_contacts';
  static const String supportEvents = 'support_events';
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

// ---------------------------------------------------------------------------
// Emergency support resources (for Emergency Support screen).
// National/state numbers below come from the NCC state emergency call-centre
// list plus 112 as the nationwide fallback. Local numbers are only shown when
// we have a verified source; otherwise the app tells the user to dial 112.
// VERIFY EVERY LISTING BEFORE PUBLIC RELEASE.
// ---------------------------------------------------------------------------

class NigeriaStateEmergency {
  final String state;
  final String? localNumber;
  final String? note;

  const NigeriaStateEmergency({
    required this.state,
    this.localNumber,
    this.note,
  });
}

const List<NigeriaStateEmergency> nigeriaStateEmergencies = [
  NigeriaStateEmergency(state: 'Abia', localNumber: '08000000800'),
  NigeriaStateEmergency(state: 'Adamawa', localNumber: '07011111443', note: 'Also 1755'),
  NigeriaStateEmergency(state: 'Akwa Ibom', localNumber: '08000022322', note: 'Also 08000022422'),
  NigeriaStateEmergency(state: 'Anambra', localNumber: '08002200008', note: 'Also 5111'),
  NigeriaStateEmergency(state: 'Bauchi', localNumber: '07038636433'),
  NigeriaStateEmergency(state: 'Bayelsa', localNumber: '08002200223'),
  NigeriaStateEmergency(state: 'Benue', note: 'Listed as not operational by NEMSAS'),
  NigeriaStateEmergency(state: 'Borno', localNumber: '08000000033'),
  NigeriaStateEmergency(state: 'Ebonyi', localNumber: '08086446891', note: 'Also 08086445736'),
  NigeriaStateEmergency(state: 'Edo', localNumber: '09037999871', note: 'Also 739'),
  NigeriaStateEmergency(state: 'Ekiti', localNumber: '08000606606'),
  NigeriaStateEmergency(
    state: 'Enugu',
    localNumber: '09074996090',
    note: 'Also 07066466429',
  ),
  NigeriaStateEmergency(state: 'Gombe', localNumber: '07033825646'),
  NigeriaStateEmergency(state: 'Imo', note: 'Listed as not operational by NEMSAS'),
  NigeriaStateEmergency(state: 'Jigawa', note: 'Use 112'),
  NigeriaStateEmergency(state: 'Kaduna', localNumber: '08064111599'),
  NigeriaStateEmergency(state: 'Niger', localNumber: '08022422953'),
  NigeriaStateEmergency(state: 'Osun', localNumber: '08111110532', note: 'Also 08111110561'),
  NigeriaStateEmergency(state: 'Taraba', localNumber: '07041122777', note: 'Also 07041100777'),
  NigeriaStateEmergency(state: 'Yobe', localNumber: '09169981792'),
  NigeriaStateEmergency(state: 'Zamfara', note: 'Use 112'),
  NigeriaStateEmergency(state: 'FCT Abuja', localNumber: '09157892931', note: 'Also 09157892932'),
];

class InternationalEmergency {
  final String country;
  final String number;
  final String note;

  const InternationalEmergency({
    required this.country,
    required this.number,
    this.note = '',
  });
}

const List<InternationalEmergency> internationalEmergencies = [
  InternationalEmergency(country: 'European Union', number: '112', note: 'Works across most of Europe'),
  InternationalEmergency(country: 'United States / Canada', number: '911'),
  InternationalEmergency(country: 'United Kingdom / Ireland', number: '999', note: '112 also works'),
  InternationalEmergency(country: 'Australia', number: '000'),
  InternationalEmergency(country: 'New Zealand', number: '111'),
  InternationalEmergency(country: 'South Africa', number: '10111', note: 'Ambulance 10177'),
  InternationalEmergency(country: 'India', number: '112'),
  InternationalEmergency(country: 'Japan', number: '110', note: 'Ambulance/fire 119'),
  InternationalEmergency(country: 'Singapore', number: '999'),
];
