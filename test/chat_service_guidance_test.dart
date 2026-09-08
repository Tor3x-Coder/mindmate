import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mindmate/models/check_in_context_model.dart';
import 'package:mindmate/models/guidance_response_model.dart';
import 'package:mindmate/services/chat_service.dart';

void main() {
  group('ChatService guidance', () {
    test('sends check-in context with guidance mode and validates action_id', () async {
      Map<String, dynamic>? sentBody;

      final service = ChatService(
        workerUrl: 'https://example.test/chat',
        post: (url, {headers, body, encoding}) async {
          sentBody = jsonDecode(body! as String) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'reply': 'Thanks for checking in — it makes sense this feels present.',
              'guidance': {
                'summary': 'Thanks for checking in — it makes sense this feels present.',
                'what_might_be_happening':
                    'When a lot competes for attention, it can feel harder to start.',
                'next_step': {
                  'title': 'Make the next few minutes smaller',
                  'description': 'Write down what is competing, pick one thing.',
                  'action_id': 'small_plan',
                },
                'alternatives': [
                  {'title': 'Try a calming reset', 'action_id': 'breathing'},
                ],
              },
            }),
            200,
          );
        },
      );

      final ctx = CheckInContext(
        feeling: CheckInFeeling.overwhelmed,
        energySource: CheckInEnergySource.schoolOrWork,
        need: CheckInNeed.figureOut,
        freeText: 'Exams',
      );

      final response = await service.sendGuidance(checkInContext: ctx);

      expect(sentBody!['mode'], 'guidance');
      expect(sentBody!['checkInContext']['feeling'], 'overwhelmed');
      expect(sentBody!['checkInContext']['energySource'], 'school_or_work');
      expect(sentBody!['checkInContext']['need'], 'figure_out');
      expect(response.guidance.nextStep.actionId, 'small_plan');
      expect(response.reply, isNotEmpty);
    });

    test('rejects unknown action_id from Worker', () async {
      final service = ChatService(
        post: (url, {headers, body, encoding}) async {
          return http.Response(
            jsonEncode({
              'reply': 'Some reply',
              'guidance': {
                'summary': 'Hi',
                'what_might_be_happening': 'Something',
                'next_step': {
                  'title': 'Bad',
                  'description': 'Bad',
                  'action_id': 'open_random_url',
                },
                'alternatives': [],
              },
            }),
            200,
          );
        },
      );

      final ctx = CheckInContext(
        feeling: CheckInFeeling.overwhelmed,
        energySource: CheckInEnergySource.schoolOrWork,
        need: CheckInNeed.calmMind,
      );

      await expectLater(
        service.sendGuidance(checkInContext: ctx),
        throwsA(isA<Exception>()),
      );
    });

    test('rejects unknown alternative action_id', () async {
      final service = ChatService(
        post: (url, {headers, body, encoding}) async {
          return http.Response(
            jsonEncode({
              'reply': 'Some reply',
              'guidance': {
                'summary': 'Hi',
                'what_might_be_happening': 'Something',
                'next_step': {
                  'title': 'Breathe',
                  'description': 'Breathe',
                  'action_id': 'breathing',
                },
                'alternatives': [
                  {'title': 'Evil', 'action_id': 'evil_action'},
                ],
              },
            }),
            200,
          );
        },
      );

      final ctx = CheckInContext(
        feeling: CheckInFeeling.overwhelmed,
        energySource: CheckInEnergySource.schoolOrWork,
        need: CheckInNeed.calmMind,
      );

      await expectLater(
        service.sendGuidance(checkInContext: ctx),
        throwsA(isA<Exception>()),
      );
    });

    test('parses crisis guidance with emergency action', () async {
      final service = ChatService(
        post: (url, {headers, body, encoding}) async {
          return http.Response(
            jsonEncode({
              'reply': 'I’m really glad you told me...',
              'guidance': {
                'summary': 'Thank you for sharing',
                'what_might_be_happening':
                    'When thoughts about not wanting to be here come up...',
                'next_step': {
                  'title': 'Reach human support right now',
                  'description': 'Please open Emergency Support',
                  'action_id': 'open_emergency_support',
                },
                'alternatives': [],
                'is_crisis': true,
              },
              'action': {
                'type': 'open_emergency_support',
                'label': 'Open Emergency Support',
              },
            }),
            200,
          );
        },
      );

      final ctx = CheckInContext(
        feeling: CheckInFeeling.lowOrSad,
        energySource: CheckInEnergySource.myThoughts,
        need: CheckInNeed.connectSomeone,
        freeText: 'I want to die',
      );

      final response = await service.sendGuidance(checkInContext: ctx);
      expect(response.guidance.isCrisis, isTrue);
      expect(response.guidance.nextStep.actionId,
          GuidanceActionIds.openEmergencySupport);
      expect(response.action, isNotNull);
      expect(response.action!.opensEmergencySupport, isTrue);
    });

    test('handles malformed guidance response', () async {
      final service = ChatService(
        post: (url, {headers, body, encoding}) async {
          return http.Response(
            jsonEncode({
              'reply': 'Some reply',
              // missing guidance
            }),
            200,
          );
        },
      );

      final ctx = CheckInContext(
        feeling: CheckInFeeling.overwhelmed,
        energySource: CheckInEnergySource.schoolOrWork,
        need: CheckInNeed.calmMind,
      );

      await expectLater(
        service.sendGuidance(checkInContext: ctx),
        throwsA(isA<Exception>()),
      );
    });

    test('bounds free text before sending', () async {
      Map<String, dynamic>? sentBody;
      final service = ChatService(
        post: (url, {headers, body, encoding}) async {
          sentBody = jsonDecode(body! as String) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'reply': 'Reply',
              'guidance': {
                'summary': 'Thanks',
                'what_might_be_happening': 'Something may be happening',
                'next_step': {
                  'title': 'Breathe',
                  'description': 'Breathe slowly',
                  'action_id': 'breathing',
                },
                'alternatives': [],
              },
            }),
            200,
          );
        },
      );

      final longText = List.filled(600, 'x').join();
      final ctx = CheckInContext(
        feeling: CheckInFeeling.overwhelmed,
        energySource: CheckInEnergySource.schoolOrWork,
        need: CheckInNeed.calmMind,
        freeText: longText,
      );

      await service.sendGuidance(checkInContext: ctx);
      final sentFree = sentBody!['checkInContext']['freeText'] as String;
      expect(sentFree.length, lessThanOrEqualTo(500));
    });
  });
}
