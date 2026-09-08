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
enum ChatActionType { openEmergencySupport }

class ChatAction {
  static const String openEmergencySupportWireValue =
      'open_emergency_support';
  static const String openEmergencySupportLabel = 'Open Emergency Support';

  final ChatActionType type;
  final String label;

  const ChatAction({
    required this.type,
    required this.label,
  });

  bool get opensEmergencySupport =>
      type == ChatActionType.openEmergencySupport;
}

class ChatResponse {
  final String reply;
  final ChatAction? action;

  const ChatResponse({
    required this.reply,
    this.action,
  });
}

class ChatService {
  static const int _maxMessageChars = 4000;
  static const int _maxHistoryChars = 4000;
  static const int _maxHistoryTurns = 12;
  static const int _maxLearnContextChars = 5000;
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

  /// Backward-compatible convenience method for callers that only need text.
  Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, String>> history,
    String? mode,
    String? learnContext,
  }) async {
    final result = await sendChat(
      userMessage: userMessage,
      history: history,
      mode: mode,
      learnContext: learnContext,
    );
    return result.reply;
  }

  // Sends [userMessage] to the AI, along with [history] (recent prior
  // turns in the conversation, oldest first) so the AI has context.
  //
  // [history] should be a list of maps shaped like:
  //   {'role': 'user', 'content': 'some earlier message'}
  //   {'role': 'assistant', 'content': 'the AI's earlier reply'}
  // The optional learnContext field contains only the selected approved Learn
  // article and is passed separately from the user's chat history.
  //
  // [mode] is optional and tells the Worker the kind of reply to aim for:
  //   'listen'    - reflective listening, minimal advice
  //   'calm'      - grounding, calming language
  //   'make_plan' - help make one small, realistic next step
  //   null        - general supportive conversation
  //
  // [learnContext] is the selected, bundled Learn article. It is optional and
  // limited before being sent so the AI can answer a question about that read
  // without receiving the whole library or the user's reading history.
  //
  // Returns the AI's reply and an optional allow-listed app action.
  // Throws an Exception with a human-readable message if anything goes
  // wrong (no internet, Worker down, bad response, etc.) — the screen
  // calling this should catch that and show a friendly error instead of
  // crashing.
  Future<ChatResponse> sendChat({
    required String userMessage,
    required List<Map<String, String>> history,
    String? mode,
    String? learnContext,
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
    final normalizedLearnContext = learnContext?.trim() ?? '';
    final limitedLearnContext = normalizedLearnContext.length >
            _maxLearnContextChars
        ? normalizedLearnContext.substring(0, _maxLearnContextChars)
        : normalizedLearnContext;
    final body = <String, dynamic>{
      'message': message,
      'history': limitedHistory,
      if (_allowedModes.contains(normalizedMode)) 'mode': normalizedMode,
      if (limitedLearnContext.isNotEmpty) 'learnContext': limitedLearnContext,
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

      ChatAction? action;
      final rawAction = decoded['action'];
      if (rawAction is Map<String, dynamic>) {
        final type = rawAction['type'];
        // Only actions owned by this app can reach the UI. Unknown action
        // types are ignored rather than rendered as arbitrary instructions.
        // The label is also app-controlled, not copied from the response.
        if (type == ChatAction.openEmergencySupportWireValue) {
          action = const ChatAction(
            type: ChatActionType.openEmergencySupport,
            label: ChatAction.openEmergencySupportLabel,
          );
        }
      }

      return ChatResponse(reply: reply.trim(), action: action);
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