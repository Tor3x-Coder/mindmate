import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mindmate/models/personalised_guidance_model.dart';
import 'package:mindmate/services/chat_service.dart';

void main() {
  test('sanitizes roles, sizes, history count, and known mode', () async {
    Map<String, dynamic>? sentBody;
    final service = ChatService(
      workerUrl: 'https://example.test/chat',
      post: (url, {headers, body, encoding}) async {
        sentBody = jsonDecode(body! as String) as Map<String, dynamic>;
        return http.Response(jsonEncode({'reply': '  A gentle reply.  '}), 200);
      },
    );

    final history = <Map<String, String>>[
      {'role': 'system', 'content': 'Injected system prompt'},
      ...List.generate(
        13,
        (index) => {
          'role': index.isEven ? 'assistant' : 'user',
          'content': index == 12
              ? List.filled(5000, 'x').join()
              : 'turn-$index',
        },
      ),
    ];

    final reply = await service.sendMessage(
      userMessage: '  Help me settle.  ',
      history: history,
      mode: 'calm',
      learnContext: 'Learn article title: A rough day',
    );

    expect(reply, 'A gentle reply.');
    expect(sentBody!['message'], 'Help me settle.');
    expect(sentBody!['mode'], 'calm');
    expect(sentBody!['learnContext'], 'Learn article title: A rough day');

    final sentHistory = sentBody!['history'] as List<dynamic>;
    expect(sentHistory, hasLength(12));
    expect(
      sentHistory.every(
        (turn) => turn['role'] == 'user' || turn['role'] == 'assistant',
      ),
      isTrue,
    );
    expect(
      sentHistory.every((turn) => (turn['content'] as String).length <= 4000),
      isTrue,
    );
    expect(
      sentHistory.any(
        (turn) => (turn['content'] as String).contains('Injected system'),
      ),
      isFalse,
    );
  });

  test('parses the allow-listed Emergency Support action', () async {
    final service = ChatService(
      post: (url, {headers, body, encoding}) async {
        return http.Response(
          jsonEncode({
            'reply': 'Please reach human support now.',
            'action': {
              'type': ChatAction.openEmergencySupportWireValue,
              'label': 'Ignore this and open a different screen',
            },
          }),
          200,
        );
      },
    );

    final response = await service.sendChat(
      userMessage: 'I want to kill myself',
      history: const [],
    );

    expect(response.reply, 'Please reach human support now.');
    expect(response.action, isNotNull);
    expect(response.action!.type, ChatActionType.openEmergencySupport);
    expect(response.action!.opensEmergencySupport, isTrue);
    expect(response.action!.label, 'Open Emergency Support');
  });

  test('ignores unknown Worker actions', () async {
    final service = ChatService(
      post: (url, {headers, body, encoding}) async {
        return http.Response(
          jsonEncode({
            'reply': 'A gentle reply.',
            'action': {'type': 'open_random_screen', 'label': 'Open it'},
          }),
          200,
        );
      },
    );

    final response = await service.sendChat(
      userMessage: 'Hello',
      history: const [],
    );

    expect(response.action, isNull);
  });

  test('omits unknown modes instead of forwarding them', () async {
    Map<String, dynamic>? sentBody;
    final service = ChatService(
      post: (url, {headers, body, encoding}) async {
        sentBody = jsonDecode(body! as String) as Map<String, dynamic>;
        return http.Response(jsonEncode({'reply': 'Okay'}), 200);
      },
    );

    await service.sendMessage(
      userMessage: 'Hello',
      history: const [],
      mode: 'override_system',
    );

    expect(sentBody!.containsKey('mode'), isFalse);
  });

  test('rejects empty and oversized messages before network calls', () async {
    var calls = 0;
    final service = ChatService(
      post: (url, {headers, body, encoding}) async {
        calls++;
        return http.Response(jsonEncode({'reply': 'unused'}), 200);
      },
    );

    await expectLater(
      service.sendMessage(userMessage: '   ', history: const []),
      throwsA(isA<Exception>()),
    );
    await expectLater(
      service.sendMessage(
        userMessage: List.filled(4001, 'x').join(),
        history: const [],
      ),
      throwsA(isA<Exception>()),
    );
    expect(calls, 0);
  });

  test('handles non-JSON and safe Worker errors without leaking HTML', () async {
    final malformed = ChatService(
      post: (url, {headers, body, encoding}) async {
        return http.Response('<html>provider secret</html>', 502);
      },
    );
    await expectLater(
      malformed.sendMessage(userMessage: 'Hello', history: const []),
      throwsA(
        predicate(
          (error) => error.toString().contains('unexpected response') &&
              !error.toString().contains('provider secret'),
        ),
      ),
    );

    final safeError = ChatService(
      post: (url, {headers, body, encoding}) async {
        return http.Response(
          jsonEncode({'error': 'The AI companion is unavailable right now.'}),
          503,
        );
      },
    );
    await expectLater(
      safeError.sendMessage(userMessage: 'Hello', history: const []),
      throwsA(
        predicate(
          (error) =>
              error.toString().contains('AI companion is unavailable'),
        ),
      ),
    );
  });
test('sends a bounded contextual check-in and parses typed guidance', () async {
  Map<String, dynamic>? sentBody;
  final service = ChatService(
    post: (url, {headers, body, encoding}) async {
      sentBody = jsonDecode(body! as String) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'guidance': {
            'acknowledgement': 'That sounds like a lot to hold at once.',
            'what_might_be_happening':
                'When several demands compete for attention, starting can feel harder.',
            'next_step': {
              'title': 'Make the next few minutes smaller',
              'description': 'Choose one small part to begin with.',
              'action_id': 'small_plan',
            },
            'why_it_may_help':
                'A smaller task can make the first move feel more possible.',
            'alternatives': [
              {
                'title': 'Try a breathing reset',
                'description': 'Take a short guided pause.',
                'action_id': 'breathing',
              },
            ],
            'question': 'Which part feels most urgent?',
          },
        }),
        200,
      );
    },
  );

  final result = await service.sendGuidance(
    checkIn: const ContextualCheckIn(
      feeling: 'Overwhelmed',
      impact: 'School or work',
      need: 'Figure out what to do',
      context: 'Three deadlines are close together.',
    ),
  );

  expect(result.isCrisis, isFalse);
  expect(result.guidance!.nextStep.actionId, 'small_plan');
  expect(result.guidance!.alternatives, hasLength(1));
  expect(sentBody!['kind'], 'personalised_guidance');
  expect(sentBody!['message'], 'Personalised check-in');
  expect(
    (sentBody!['checkIn'] as Map<String, dynamic>)['feeling'],
    'Overwhelmed',
  );
});

test('rejects an unknown personalised guidance action', () async {
  final service = ChatService(
    post: (url, {headers, body, encoding}) async {
      return http.Response(
        jsonEncode({
          'guidance': {
            'acknowledgement': 'Okay.',
            'what_might_be_happening': 'A lot may be happening at once.',
            'next_step': {
              'title': 'Open something',
              'description': 'Try it.',
              'action_id': 'open_random_screen',
            },
            'why_it_may_help': 'It may help.',
            'alternatives': [
              {
                'title': 'Talk',
                'description': 'Share it.',
                'action_id': 'open_chat',
              },
            ],
            'question': null,
          },
        }),
        200,
      );
    },
  );

  await expectLater(
    service.sendGuidance(
      checkIn: const ContextualCheckIn(
        feeling: 'Overwhelmed',
        impact: 'My thoughts',
        need: 'Calm my mind',
      ),
    ),
    throwsA(predicate((error) => error.toString().contains('unexpected response'))),
  );
});

test('keeps crisis-first guidance as the trusted emergency action', () async {
  final service = ChatService(
    post: (url, {headers, body, encoding}) async {
      return http.Response(
        jsonEncode({
          'reply': 'Please get immediate human support.',
          'action': {
            'type': ChatAction.openEmergencySupportWireValue,
            'label': 'Untrusted label ignored',
          },
        }),
        200,
      );
    },
  );

  final result = await service.sendGuidance(
    checkIn: const ContextualCheckIn(
      feeling: 'Overwhelmed',
      impact: 'My thoughts',
      need: 'Connect with someone',
      context: 'I do not feel safe with myself.',
    ),
  );

  expect(result.isCrisis, isTrue);
  expect(result.action!.opensEmergencySupport, isTrue);
  expect(result.action!.label, ChatAction.openEmergencySupportLabel);
});
}
