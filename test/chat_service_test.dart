import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
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
    );

    expect(reply, 'A gentle reply.');
    expect(sentBody!['message'], 'Help me settle.');
    expect(sentBody!['mode'], 'calm');

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
}
