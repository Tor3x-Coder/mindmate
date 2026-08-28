import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/models/appointment_model.dart';
import 'package:mindmate/models/feedback_record_model.dart';
import 'package:mindmate/models/journal_entry_model.dart';
import 'package:mindmate/models/mood_log_model.dart';
import 'package:mindmate/models/professional_model.dart';
import 'package:mindmate/models/support_event_model.dart';
import 'package:mindmate/models/thought_record_model.dart';
import 'package:mindmate/models/trusted_contact_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MoodLogModel serialization', () {
    test('round-trips every field and keeps the document id', () {
      final original = MoodLogModel(
        id: 'doc-1',
        uid: 'user-1',
        emoji: '😔',
        label: 'Sad',
        impactLabel: 'Somewhat',
        note: 'rough day',
        date: DateTime.parse('2026-08-26T10:30:00.000'),
      );

      final restored = MoodLogModel.fromMap(original.toMap(), original.id);

      expect(restored.id, 'doc-1');
      expect(restored.uid, 'user-1');
      expect(restored.emoji, '😔');
      expect(restored.label, 'Sad');
      expect(restored.impactLabel, 'Somewhat');
      expect(restored.note, 'rough day');
      expect(restored.date, original.date);
    });

    test('optional impactLabel can be null and survive the round trip', () {
      final original = MoodLogModel(
        id: 'doc-2',
        uid: 'user-1',
        emoji: '😌',
        label: 'Happy',
        impactLabel: null,
        date: DateTime.parse('2026-08-26T09:00:00.000'),
      );

      final restored = MoodLogModel.fromMap(original.toMap(), original.id);
      expect(restored.impactLabel, isNull);
      expect(restored.note, '');
    });

    test('missing keys fall back to safe defaults without crashing', () {
      final restored = MoodLogModel.fromMap(const {}, 'doc-3');
      expect(restored.id, 'doc-3');
      expect(restored.uid, '');
      expect(restored.emoji, '😐');
      expect(restored.label, '');
      expect(restored.impactLabel, isNull);
    });
  });

  group('TrustedContactModel serialization', () {
    test('round-trips and preserves the owning uid', () {
      final original = TrustedContactModel(
        id: 'contact-1',
        uid: 'user-9',
        name: 'Mama',
        relationship: 'Parent',
        phone: '08031234567',
        createdAt: DateTime.parse('2026-08-01T08:00:00.000'),
      );

      final restored = TrustedContactModel.fromMap(
        original.toMap(),
        original.id,
      );

      expect(restored.id, 'contact-1');
      expect(restored.uid, 'user-9');
      expect(restored.name, 'Mama');
      expect(restored.relationship, 'Parent');
      expect(restored.phone, '08031234567');
      expect(restored.createdAt, original.createdAt);
    });
  });

  group('SupportEventModel serialization', () {
    test('round-trips including optional follow-up', () {
      final original = SupportEventModel(
        id: 'event-1',
        uid: 'user-9',
        actionLabel: 'Call Mama',
        detail: 'Emergency support screen',
        followUp: 'Connected',
        createdAt: DateTime.parse('2026-08-02T21:15:00.000'),
      );

      final restored = SupportEventModel.fromMap(
        original.toMap(),
        original.id,
      );

      expect(restored.id, 'event-1');
      expect(restored.uid, 'user-9');
      expect(restored.actionLabel, 'Call Mama');
      expect(restored.detail, 'Emergency support screen');
      expect(restored.followUp, 'Connected');
      expect(restored.createdAt, original.createdAt);
    });

    test('missing follow-up stays null', () {
      final restored = SupportEventModel.fromMap(
        {'uid': 'u', 'actionLabel': 'Call', 'createdAt': '2026-08-02'},
        'event-2',
      );
      expect(restored.followUp, isNull);
    });
  });

  group('FeedbackRecordModel serialization', () {
    test('round-trips the full feedback loop record', () {
      final original = FeedbackRecordModel(
        id: 'fb-1',
        uid: 'user-1',
        moodLabel: 'Stressed',
        moodEmoji: '😣',
        moodImpact: 'A lot',
        activityId: 'breathing',
        activityTitle: 'A short breathing reset',
        feedback: 'A little better',
        date: DateTime.parse('2026-08-26T14:00:00.000'),
      );

      final restored = FeedbackRecordModel.fromMap(
        original.toMap(),
        original.id,
      );

      expect(restored.id, 'fb-1');
      expect(restored.uid, 'user-1');
      expect(restored.moodLabel, 'Stressed');
      expect(restored.moodEmoji, '😣');
      expect(restored.moodImpact, 'A lot');
      expect(restored.activityId, 'breathing');
      expect(restored.activityTitle, 'A short breathing reset');
      expect(restored.feedback, 'A little better');
      expect(restored.date, original.date);
    });
  });

  group('JournalEntryModel serialization', () {
    test('round-trips private journal content', () {
      final original = JournalEntryModel(
        id: 'journal-1',
        uid: 'user-1',
        prompt: 'What is one small thing going well?',
        content: 'My morning tea, and a call from a friend.',
        date: DateTime.parse('2026-08-26T18:30:00.000'),
      );

      final restored = JournalEntryModel.fromMap(
        original.toMap(),
        original.id,
      );

      expect(restored.id, 'journal-1');
      expect(restored.uid, 'user-1');
      expect(restored.prompt, 'What is one small thing going well?');
      expect(restored.content, 'My morning tea, and a call from a friend.');
      expect(restored.date, original.date);
    });
  });

  group('ThoughtRecordModel serialization', () {
    test('round-trips all CBT fields including intensities', () {
      final original = ThoughtRecordModel(
        id: 'thought-1',
        uid: 'user-1',
        situation: 'Missed a deadline at work',
        automaticThought: 'Everyone is going to think I am lazy',
        intensityBefore: 8,
        evidenceFor: 'I was the only one late',
        evidenceAgainst: 'My manager has praised my work this month',
        balancedThought: 'One missed deadline does not define my work',
        intensityAfter: 4,
        date: DateTime.parse('2026-08-25T11:00:00.000'),
      );

      final restored = ThoughtRecordModel.fromMap(
        original.toMap(),
        original.id,
      );

      expect(restored.id, 'thought-1');
      expect(restored.uid, 'user-1');
      expect(restored.situation, 'Missed a deadline at work');
      expect(restored.automaticThought, 'Everyone is going to think I am lazy');
      expect(restored.intensityBefore, 8);
      expect(restored.evidenceFor, 'I was the only one late');
      expect(restored.evidenceAgainst,
          'My manager has praised my work this month');
      expect(restored.balancedThought,
          'One missed deadline does not define my work');
      expect(restored.intensityAfter, 4);
      expect(restored.date, original.date);
    });

    test('missing intensities fall back to the neutral default of 5', () {
      final restored = ThoughtRecordModel.fromMap(const {}, 'thought-2');
      expect(restored.intensityBefore, 5);
      expect(restored.intensityAfter, 5);
    });
  });

  group('AppointmentModel serialization', () {
    test('round-trips with status preserved', () {
      final original = AppointmentModel(
        id: 'appt-1',
        uid: 'user-1',
        professionalId: 'pro-1',
        professionalName: 'Dr. Example',
        consultationType: 'Online',
        preferredDate: '2026-09-05',
        preferredTime: '14:30',
        note: 'Feeling anxious a lot lately',
        status: 'pending',
        requestedAt: DateTime.parse('2026-08-26T10:00:00.000'),
      );

      final restored = AppointmentModel.fromMap(
        original.toMap(),
        original.id,
      );

      expect(restored.id, 'appt-1');
      expect(restored.uid, 'user-1');
      expect(restored.professionalId, 'pro-1');
      expect(restored.professionalName, 'Dr. Example');
      expect(restored.consultationType, 'Online');
      expect(restored.preferredDate, '2026-09-05');
      expect(restored.preferredTime, '14:30');
      expect(restored.note, 'Feeling anxious a lot lately');
      expect(restored.status, 'pending');
      expect(restored.requestedAt, original.requestedAt);
    });

    test('status defaults to pending when missing', () {
      final restored = AppointmentModel.fromMap(const {}, 'appt-2');
      expect(restored.status, 'pending');
    });
  });

  group('ProfessionalModel serialization', () {
    test('round-trips directory listing fields', () {
      final original = ProfessionalModel(
        id: 'pro-1',
        fullName: 'Dr. Example',
        category: 'Psychologist',
        bio: 'Demo listing',
        contactEmail: 'example@example.com',
        contactPhone: '08030000000',
        photoUrl: '',
        offersOnline: true,
        offersPhysical: false,
        location: 'Lagos',
      );

      final restored = ProfessionalModel.fromMap(
        original.toMap(),
        original.id,
      );

      expect(restored.id, 'pro-1');
      expect(restored.fullName, 'Dr. Example');
      expect(restored.category, 'Psychologist');
      expect(restored.bio, 'Demo listing');
      expect(restored.contactEmail, 'example@example.com');
      expect(restored.contactPhone, '08030000000');
      expect(restored.offersOnline, isTrue);
      expect(restored.offersPhysical, isFalse);
      expect(restored.location, 'Lagos');
    });
  });
}
