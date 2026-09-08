import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/models/check_in_context_model.dart';

void main() {
  group('CheckInContext model', () {
    test('creates valid context and bounds free text', () {
      final ctx = CheckInContext(
        feeling: CheckInFeeling.overwhelmed,
        energySource: CheckInEnergySource.schoolOrWork,
        need: CheckInNeed.figureOut,
        freeText: '  Exams coming  ',
      );
      expect(ctx.feeling, CheckInFeeling.overwhelmed);
      expect(ctx.boundedFreeText, 'Exams coming');
      expect(ctx.hasFreeText, isTrue);
      expect(ctx.toJson()['feeling'], 'overwhelmed');
      expect(ctx.toJson()['energySource'], 'school_or_work');
      expect(ctx.toJson()['need'], 'figure_out');
    });

    test('truncates free text to 500 chars', () {
      final long = List.filled(600, 'a').join();
      final ctx = CheckInContext(
        feeling: CheckInFeeling.lowOrSad,
        energySource: CheckInEnergySource.myThoughts,
        need: CheckInNeed.calmMind,
        freeText: long,
      );
      expect(ctx.boundedFreeText.length, CheckInContext.maxFreeTextChars);
    });

    test('fromJson round-trips', () {
      final original = CheckInContext(
        feeling: CheckInFeeling.lonelyOrDisconnected,
        energySource: CheckInEnergySource.relationshipsOrFamily,
        need: CheckInNeed.connectSomeone,
        freeText: 'Feeling alone',
      );
      final restored = CheckInContext.fromJson(original.toJson());
      expect(restored.feeling, CheckInFeeling.lonelyOrDisconnected);
      expect(restored.energySource, CheckInEnergySource.relationshipsOrFamily);
      expect(restored.need, CheckInNeed.connectSomeone);
      expect(restored.boundedFreeText, 'Feeling alone');
    });

    test('fromJson rejects invalid values', () {
      expect(
        () => CheckInContext.fromJson({
          'feeling': 'invalid',
          'energySource': 'school_or_work',
          'need': 'calm_mind',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('feeling display labels and situation hints', () {
      expect(CheckInFeeling.overwhelmed.displayLabel, 'Overwhelmed');
      expect(CheckInFeeling.overwhelmed.situationHint, 'overwhelmed');
      expect(CheckInFeeling.lonelyOrDisconnected.situationHint,
          'lonely_or_disconnected');
      expect(CheckInFeeling.anxiousOrWorried.situationHint, 'overthinking');
      expect(CheckInFeeling.lowOrSad.situationHint, 'low_motivation');
    });

    test('all feeling wire values are allowed', () {
      for (final f in CheckInFeeling.values) {
        expect(CheckInFeelingX.fromWire(f.wireValue), f);
      }
    });

    test('all energy wire values are allowed', () {
      for (final e in CheckInEnergySource.values) {
        expect(CheckInEnergySourceX.fromWire(e.wireValue), e);
      }
    });

    test('all need wire values are allowed', () {
      for (final n in CheckInNeed.values) {
        expect(CheckInNeedX.fromWire(n.wireValue), n);
      }
    });
  });
}
