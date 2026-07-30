import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_log_model.dart';
import '../models/journal_entry_model.dart';
import '../models/wellness_assessment_model.dart';
import '../models/meditation_session_model.dart';
import '../models/professional_model.dart';
import '../models/appointment_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---- User Profile ----
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // Checks the 'isAdmin' field on a user's profile. Defaults to false
  // if the field has never been set, so nobody is an admin by accident.
  Future<bool> isUserAdmin(String uid) async {
    final profile = await getUserProfile(uid);
    return profile?['isAdmin'] == true;
  }

  // ---- Mood Logs ----
  Future<void> addMoodLog(MoodLogModel log) async {
    await _db.collection(FirestoreCollections.moodLogs).add(log.toMap());
  }

  Stream<List<MoodLogModel>> moodLogsForUser(String uid) {
    return _db
        .collection(FirestoreCollections.moodLogs)
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MoodLogModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ---- Journal Entries ----
  Future<void> addJournalEntry(JournalEntryModel entry) async {
    await _db
        .collection(FirestoreCollections.journalEntries)
        .add(entry.toMap());
  }

  Stream<List<JournalEntryModel>> journalEntriesForUser(String uid) {
    return _db
        .collection(FirestoreCollections.journalEntries)
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => JournalEntryModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ---- Wellness Assessments ----
  Future<void> addWellnessAssessment(WellnessAssessmentModel assessment) async {
    await _db
        .collection(FirestoreCollections.wellnessAssessments)
        .add(assessment.toMap());
  }

  Stream<List<WellnessAssessmentModel>> wellnessAssessmentsForUser(String uid) {
    return _db
        .collection(FirestoreCollections.wellnessAssessments)
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => WellnessAssessmentModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ---- Meditation History ----
  Future<void> addMeditationSession(MeditationSessionModel session) async {
    await _db
        .collection(FirestoreCollections.meditationHistory)
        .add(session.toMap());
  }

  Stream<List<MeditationSessionModel>> meditationSessionsForUser(String uid) {
    return _db
        .collection(FirestoreCollections.meditationHistory)
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MeditationSessionModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ---- Professionals (Directory) ----

  // Only meant to be called from the admin screen.
  Future<void> addProfessional(ProfessionalModel professional) async {
    await _db
        .collection(FirestoreCollections.professionals)
        .add(professional.toMap());
  }

  Future<void> updateProfessional(ProfessionalModel professional) async {
    await _db
        .collection(FirestoreCollections.professionals)
        .doc(professional.id)
        .update(professional.toMap());
  }

  Future<void> deleteProfessional(String professionalId) async {
    await _db
        .collection(FirestoreCollections.professionals)
        .doc(professionalId)
        .delete();
  }

  // Visible to everyone — the public directory list.
  Stream<List<ProfessionalModel>> allProfessionals() {
    return _db
        .collection(FirestoreCollections.professionals)
        .orderBy('fullName')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProfessionalModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ---- Appointments ----

  // Users submit requests — never an instant booking, per the spec.
  Future<void> requestAppointment(AppointmentModel appointment) async {
    await _db
        .collection(FirestoreCollections.appointments)
        .add(appointment.toMap());
  }

  Stream<List<AppointmentModel>> appointmentsForUser(String uid) {
    return _db
        .collection(FirestoreCollections.appointments)
        .where('uid', isEqualTo: uid)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AppointmentModel.fromMap(d.data(), d.id))
            .toList());
  }
}