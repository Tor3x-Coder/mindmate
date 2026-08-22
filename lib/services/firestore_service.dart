import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mood_log_model.dart';
import '../models/journal_entry_model.dart';
import '../models/wellness_assessment_model.dart';
import '../models/meditation_session_model.dart';
import '../models/professional_model.dart';
import '../models/appointment_model.dart';
import '../models/thought_record_model.dart';
import '../models/feedback_record_model.dart';
import '../models/trusted_contact_model.dart';
import '../models/support_event_model.dart';
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
  // NOTE: this is a client-side check only. Real enforcement comes from
  // Firestore security rules (item 6 on the remaining-work list).
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
  // Public list — readable by everyone.
  // Only uses orderBy (no where), so no composite index is needed.
  Stream<List<ProfessionalModel>> allProfessionals() {
    return _db
        .collection(FirestoreCollections.professionals)
        .orderBy('fullName')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProfessionalModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Admin-only create / update / delete. The UI checks isUserAdmin first;
  // Firestore rules will enforce this for real once item 6 is done.
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

  // ---- Appointments ----
  // Users submit requests — never an instant booking, per the spec.
  // Status starts as 'pending'. Approve/decline UI is a stretch goal;
  // the status field is stored so that can be added later.
    Future<void> requestAppointment(AppointmentModel appointment) async {
    await _db
        .collection(FirestoreCollections.appointments)
        .add(appointment.toMap());
  }

  // Checks whether the user already has an active (pending) request to the
  // same professional. Used by the request screen so a user cannot submit
  // multiple requests to the same professional while one is still pending.
  // Multiple equality filters do not need a composite index.
  Future<bool> hasPendingAppointmentForProfessional(
    String uid,
    String professionalId,
  ) async {
    final snapshot = await _db
        .collection(FirestoreCollections.appointments)
        .where('uid', isEqualTo: uid)
        .where('professionalId', isEqualTo: professionalId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
  
  Stream<List<AppointmentModel>> allAppointmentsForAdmin() {
    return _db
        .collection(FirestoreCollections.appointments)
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    await _db
        .collection(FirestoreCollections.appointments)
        .doc(appointmentId)
        .update({'status': status});
  }

  // REQUIRES a composite index in Firebase Console:
  // Collection: appointments
  // Fields: uid (Ascending), requestedAt (Descending)
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

// ---- Journal: Update & Delete ----
  Future<void> updateJournalEntry(JournalEntryModel entry) async {
    await _db
        .collection(FirestoreCollections.journalEntries)
        .doc(entry.id)
        .update(entry.toMap());
  }

  Future<void> deleteJournalEntry(String entryId) async {
    await _db
        .collection(FirestoreCollections.journalEntries)
        .doc(entryId)
        .delete();
  }
  
  // ---- CBT Thought Records ----
  // Saves a completed thought-reframe exercise (situation, automatic
  // thought, evidence for/against, and the reframed "balanced" thought).
  Future<void> addThoughtRecord(ThoughtRecordModel record) async {
    await _db
        .collection(FirestoreCollections.thoughtRecords)
        .add(record.toMap());
  }

  // REQUIRES a composite index in Firebase Console:
  // Collection: thought_records
  // Fields: uid (Ascending), date (Descending)
  Stream<List<ThoughtRecordModel>> thoughtRecordsForUser(String uid) {
    return _db
        .collection(FirestoreCollections.thoughtRecords)
        .where('uid', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ThoughtRecordModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ---- Activity Feedback Records ----
  // Saves how an activity felt after the user tried it, along with the
  // context (mood + impact) so the recommendation layer can learn.
  Future<void> addFeedbackRecord(FeedbackRecordModel record) async {
    await _db
        .collection(FirestoreCollections.feedbackRecords)
        .add(record.toMap());
  }

  // ---- Trusted Contacts ----
  // We query by uid only and sort client-side so this does not require a
  // composite Firestore index for this small, per-user list.
  Stream<List<TrustedContactModel>> trustedContactsForUser(String uid) {
    return _db
        .collection(FirestoreCollections.trustedContacts)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final contacts = snap.docs
              .map((d) => TrustedContactModel.fromMap(d.data(), d.id))
              .toList();
          contacts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return contacts;
        });
  }

  Future<void> addTrustedContact(TrustedContactModel contact) async {
    await _db
        .collection(FirestoreCollections.trustedContacts)
        .add(contact.toMap());
  }

  Future<void> updateTrustedContact(TrustedContactModel contact) async {
    await _db
        .collection(FirestoreCollections.trustedContacts)
        .doc(contact.id)
        .update(contact.toMap());
  }

  Future<void> deleteTrustedContact(String contactId) async {
    await _db
        .collection(FirestoreCollections.trustedContacts)
        .doc(contactId)
        .delete();
  }

  // ---- Support Events ----
  // Logs when a user taps a support action or answers the follow-up
  // question. Personal data is owner-only via Firestore rules.
  Future<void> addSupportEvent(SupportEventModel event) async {
    await _db
        .collection(FirestoreCollections.supportEvents)
        .add(event.toMap());
  }
}