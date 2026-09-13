import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/models/structured_programme_model.dart';

void main() {
  group('StructuredProgramme demo model', () {
    test('demoProgrammes list has at least one programme', () {
      expect(demoProgrammes.isNotEmpty, isTrue);
    });

    test('first programme is 7-Day Overthinking Reset with 7 days', () {
      final programme = demoProgrammes.firstWhere(
        (p) => p.id == 'overthinking_reset_7',
        orElse: () => demoProgrammes.first,
      );
      expect(programme.title, contains('Overthinking'));
      expect(programme.durationDays, 7);
      expect(programme.days.length, 7);
      expect(programme.priceLabel, 'to be validated');
      expect(programme.subtitle.toLowerCase(), contains('illustrative'));
    });

    test('all programmes have DEMO labelling and no real price', () {
      for (final p in demoProgrammes) {
        expect(p.priceLabel, isNotEmpty);
        // Must not contain real currency symbols that imply charge
        expect(p.priceLabel.toLowerCase(), isNot(contains('\$')));
        expect(p.priceLabel.toLowerCase(), isNot(contains('paystack')));
        expect(p.description.toLowerCase(), isNot(contains('paystack')));
        expect(p.longDescription.toLowerCase(), contains('no payment'));
        expect(p.longDescription.toLowerCase(), contains('demo'));
      }
    });

    test('programme days have allow-listed action_ids', () {
      const allowed = {
        'breathing',
        'meditation',
        'journal_prompt',
        'thought_reframe',
        'small_plan',
        'open_learn',
        'open_chat',
        'trusted_person_prompt',
        'open_emergency_support',
      };
      for (final p in demoProgrammes) {
        for (final day in p.days) {
          expect(allowed.contains(day.actionId), isTrue,
              reason: 'Day ${day.dayNumber} action ${day.actionId} not allowed');
          expect(day.title.isNotEmpty, isTrue);
          expect(day.reflectionPrompt.isNotEmpty, isTrue);
        }
      }
    });

    test('programme long description mentions local only and no bank details', () {
      for (final p in demoProgrammes) {
        final lower = p.longDescription.toLowerCase();
        expect(
          lower.contains('no payment') ||
              lower.contains('no bank') ||
              lower.contains('competition-only demo'),
          isTrue,
          reason: 'Programme ${p.id} should mention demo nature',
        );
      }
    });

    test('whatYouGet does not claim diagnosis or prescription', () {
      for (final p in demoProgrammes) {
        for (final item in p.whatYouGet) {
          final lower = item.toLowerCase();
          expect(lower.contains('diagnos'), isFalse);
          expect(lower.contains('prescrib'), isFalse);
        }
      }
    });
  });
}
