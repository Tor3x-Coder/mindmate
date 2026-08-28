import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

typedef ChatHttpPost = Future<http.Response> Function(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
});

// This service is the ONLY place in the app that talks to the AI backend.
// It sends the user's message (plus recent chat history for context) to
// our Cloudflare Worker, which forwards it to the AI model along with
// the system prompt and sends the reply back. The AI provider's API key
// never touches this app — it lives only inside the Worker, which is the
// whole point of routing through a backend instead of calling an AI
// provider directly from Flutter.
class ChatService {
  static const int _maxMessageChars = 4000;
  static const int _maxHistoryChars = 4000;
  static const int _maxHistoryTurns = 12;
  static const Set<String> _allowedModes = {
    'listen',
    'calm',
    'make_plan',
  };

  static const String _defaultWorkerUrl =
      'https://mindmate-ai-chat.tor3x-akachukwu.workers.dev';

  final ChatHttpPost _post;
  final Uri _workerUri;

  ChatService({
    ChatHttpPost? post,
    String workerUrl = _defaultWorkerUrl,
  })  : _post = post ?? http.post,
        _workerUri = Uri.parse(workerUrl);

  // Sends [userMessage] to the AI, along with [history] (recent prior
  // turns in the conversation, oldest first) so the AI has context.
  //
  // [history] should be a list of maps shaped like:
  //   {'role': 'user', 'content': 'some earlier message'}
  //   {'role': 'assistant', 'content': 'the AI's earlier reply'}
  // This matches exactly what the Worker expects and just gets passed
  // straight through to it.
  //
  // [mode] is optional and tells the Worker the kind of reply to aim for:
  //   'listen'    - reflective listening, minimal advice
  //   'calm'      - grounding, calming language
  //   'make_plan' - help make one small, realistic next step
  //   null        - general supportive conversation
  //
  // Returns the AI's reply as a plain string.
  // Throws an Exception with a human-readable message if anything goes
  // wrong (no internet, Worker down, bad response, etc.) — the screen
  // calling this should catch that and show a friendly error instead of
  // crashing.
  Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, String>> history,
    String? mode,
  }) async {
    final message = userMessage.trim();
    if (message.isEmpty) {
      throw Exception('Write a message before sending.');
    }
    if (message.length > _maxMessageChars) {
      throw Exception('That message is too long. Shorten it and try again.');
    }

    final cleanHistory = history
        .where((turn) {
          final role = turn['role'];
          return role == 'user' || role == 'assistant';
        })
        .map((turn) {
          final content = turn['content']?.trim() ?? '';
          final limitedContent = content.length > _maxHistoryChars
              ? content.substring(0, _maxHistoryChars)
              : content;
          return <String, String>{
            'role': turn['role']!,
            'content': limitedContent,
          };
        })
        .where((turn) => turn['content']!.isNotEmpty)
        .toList();
    final limitedHistory = cleanHistory.length > _maxHistoryTurns
        ? cleanHistory.sublist(cleanHistory.length - _maxHistoryTurns)
        : cleanHistory;

    final normalizedMode = mode?.trim() ?? '';
    final body = <String, dynamic>{
      'message': message,
      'history': limitedHistory,
      if (_allowedModes.contains(normalizedMode)) 'mode': normalizedMode,
    };

    try {
      final response = await _post(
        _workerUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected Worker response shape.');
      }

      if (response.statusCode != 200) {
        final workerError = decoded['error'];
        throw Exception(
          workerError is String && workerError.trim().isNotEmpty
              ? workerError
              : 'The AI companion is unavailable right now.',
        );
      }

      final reply = decoded['reply'];
      if (reply is! String || reply.trim().isEmpty) {
        throw Exception('The AI companion returned an empty reply.');
      }

      return reply.trim();
    } on http.ClientException {
      throw Exception(
        'Could not reach the AI companion. Check your internet connection.',
      );
    } on TimeoutException {
      throw Exception('The AI companion took too long to respond. Try again.');
    } on FormatException {
      throw Exception('The AI companion returned an unexpected response.');
    }
  }
}