import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/models/check_in_context_model.dart';
import 'package:mindmate/models/guidance_response_model.dart';

void main() {
  group('GuidanceActionIds allow-list', () {
    test('contains exactly 9 approved actions', () {
      expect(GuidanceActionIds.all.length, 9);
      expect(GuidanceActionIds.all, contains('breathing'));
      expect(GuidanceActionIds.all, contains('meditation'));
      expect(GuidanceActionIds.all, contains('journal_prompt'));
      expect(GuidanceActionIds.all, contains('thought_reframe'));
      expect(GuidanceActionIds.all, contains('small_plan'));
      expect(GuidanceActionIds.all, contains('open_learn'));
      expect(GuidanceActionIds.all, contains('open_chat'));
      expect(GuidanceActionIds.all, contains('trusted_person_prompt'));
      expect(GuidanceActionIds.all, contains('open_emergency_support'));
    });

    test('rejects unknown actions', () {
      expect(GuidanceActionIds.isAllowed('breathing'), isTrue);
      expect(GuidanceActionIds.isAllowed('open_random_url'), isFalse);
      expect(GuidanceActionIds.isAllowed('evil'), isFalse);
      expect(GuidanceActionIds.isAllowed(null), isFalse);
    });
  });

  group('GuidanceResponse parsing', () {
    test('parses valid guidance JSON', () {
      final json = {
        'summary': 'It sounds like you may be carrying a lot.',
        'what_might_be_happening':
            'When a lot competes for attention, starting can feel harder.',
        'next_step': {
          'title': 'Make the next few minutes smaller',
          'description': 'Write down what is competing, pick one thing.',
          'action_id': 'small_plan',
        },
        'alternatives': [
          {'title': 'Try a calming reset', 'action_id': 'breathing'},
          {'title': 'Talk it through', 'action_id': 'open_chat'},
        ],
        'why_it_might_help': 'Breaking it down can help.',
        'gentle_question': 'What would make the next hour kinder?',
      };

      final guidance = GuidanceResponse.fromJson(json);
      expect(guidance.summary, contains('carrying a lot'));
      expect(guidance.nextStep.actionId, 'small_plan');
      expect(guidance.alternatives.length, 2);
      expect(guidance.alternatives.first.actionId, 'breathing');
    });

    test('rejects unknown action_id in next_step', () {
      final json = {
        'summary': 'Hi',
        'what_might_be_happening': 'Something',
        'next_step': {
          'title': 'Bad',
          'description': 'Bad',
          'action_id': 'open_random_url',
        },
        'alternatives': [],
      };
      expect(() => GuidanceResponse.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('rejects unknown action_id in alternatives', () {
      final json = {
        'summary': 'Hi',
        'what_might_be_happening': 'Something',
        'next_step': {
          'title': 'Breathe',
          'description': 'Breathe slowly',
          'action_id': 'breathing',
        },
        'alternatives': [
          {'title': 'Bad', 'action_id': 'evil_action'},
        ],
      };
      expect(() => GuidanceResponse.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('limits alternatives to 2', () {
      final json = {
        'summary': 'Hi',
        'what_might_be_happening': 'Something',
        'next_step': {
          'title': 'Breathe',
          'description': 'Breathe slowly',
          'action_id': 'breathing',
        },
        'alternatives': [
          {'title': 'A', 'action_id': 'meditation'},
          {'title': 'B', 'action_id': 'journal_prompt'},
          {'title': 'C', 'action_id': 'open_chat'},
        ],
      };
      final guidance = GuidanceResponse.fromJson(json);
      expect(guidance.alternatives.length, 2);
    });

    test('fallback uses only allowed actions for all situations', () {
      for (final feeling in CheckInFeeling.values) {
        for (final need in CheckInNeed.values) {
          final ctx = CheckInContext(
            feeling: feeling,
            energySource: CheckInEnergySource.schoolOrWork,
            need: need,
          );
          final fallback = GuidanceResponse.fallback(ctx);
          expect(GuidanceActionIds.isAllowed(fallback.nextStep.actionId), isTrue,
              reason: 'fallback for $feeling $need has disallowed action');
          for (final alt in fallback.alternatives) {
            expect(GuidanceActionIds.isAllowed(alt.actionId), isTrue,
                reason: 'fallback alternative for $feeling $need disallowed');
          }
          expect(fallback.summary, isNotEmpty);
          expect(fallback.whatMightBeHappening, isNotEmpty);
          expect(fallback.whatMightBeHappening.toLowerCase(), contains('may'),
              reason: 'should use may/might language');
        }
      }
    });

    test('four initial situations are covered', () {
      // Overwhelmed
      final overwhelmedCtx = CheckInContext(
        feeling: CheckInFeeling.overwhelmed,
        energySource: CheckInEnergySource.schoolOrWork,
        need: CheckInNeed.figureOut,
      );
      final overwhelmed = GuidanceResponse.fallback(overwhelmedCtx);
      expect(overwhelmed.whatMightBeHappening.toLowerCase(), contains('competes'));

      // Lonely
      final lonelyCtx = CheckInContext(
        feeling: CheckInFeeling.lonelyOrDisconnected,
        energySource: CheckInEnergySource.relationshipsOrFamily,
        need: CheckInNeed.connectSomeone,
      );
      final lonely = GuidanceResponse.fallback(lonelyCtx);
      expect(lonely.nextStep.actionId, 'trusted_person_prompt');

      // Overthinking -> anxious + my_thoughts + understand
      final overthinkingCtx = CheckInContext(
        feeling: CheckInFeeling.anxiousOrWorried,
        energySource: CheckInEnergySource.myThoughts,
        need: CheckInNeed.understandFeeling,
      );
      final overthinking = GuidanceResponse.fallback(overthinkingCtx);
      expect(overthinking.nextStep.actionId, 'thought_reframe');

      // Low motivation
      final lowMotCtx = CheckInContext(
        feeling: CheckInFeeling.numbOrTired,
        energySource: CheckInEnergySource.sleepOrBody,
        need: CheckInNeed.calmMind,
      );
      final lowMot = GuidanceResponse.fallback(lowMotCtx);
      expect(GuidanceActionIds.isAllowed(lowMot.nextStep.actionId), isTrue);
    });

    test('detects emergency action', () {
      final json = {
        'summary': 'You deserve support',
        'what_might_be_happening': 'It can feel overwhelming',
        'next_step': {
          'title': 'Reach support',
          'description': 'Open emergency support',
          'action_id': 'open_emergency_support',
        },
        'alternatives': [],
        'is_crisis': true,
      };
      final guidance = GuidanceResponse.fromJson(json);
      expect(guidance.isCrisis, isTrue);
      expect(guidance.hasEmergencyAction, isTrue);
    });
  });
}
