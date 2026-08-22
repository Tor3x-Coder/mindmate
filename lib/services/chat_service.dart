import 'dart:convert';
import 'package:http/http.dart' as http;

// This service is the ONLY place in the app that talks to the AI backend.
// It sends the user's message (plus recent chat history for context) to
// our Cloudflare Worker, which forwards it to the AI model along with
// the system prompt and sends the reply back. The AI provider's API key
// never touches this app — it lives only inside the Worker, which is the
// whole point of routing through a backend instead of calling an AI
// provider directly from Flutter.
class ChatService {
  // The live URL of the Cloudflare Worker (from the Cloudflare dashboard).
  // If you ever redeploy the Worker under a different name/subdomain,
  // this is the only line that needs to change.
  static const String _workerUrl =
      'https://mindmate-ai-chat.tor3x-akachukwu.workers.dev';

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
    try {
      // Validate and sanitize the history before sending it to the Worker.
      // Only user/assistant roles are accepted, content is trimmed to a
      // reasonable size, and we keep at most 12 turns to avoid sending a
      // huge payload to the AI.
      final cleanHistory = history
          .where((turn) {
            final role = turn['role'];
            return role == 'user' || role == 'assistant';
          })
          .where((turn) {
            final content = turn['content']?.trim() ?? '';
            return content.isNotEmpty;
          })
          .map((turn) {
            return <String, String>{
              'role': turn['role']!,
              'content': turn['content']!.trim(),
            };
          })
          .toList();
      final limitedHistory = cleanHistory.length > 12
          ? cleanHistory.sublist(cleanHistory.length - 12)
          : cleanHistory;

      final body = <String, dynamic>{
        'message': userMessage.trim(),
        'history': limitedHistory,
      };
      if (mode != null && mode.trim().isNotEmpty) {
        body['mode'] = mode.trim();
      }

      final response = await http
          .post(
            Uri.parse(_workerUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          // If the AI takes too long to respond, fail clearly instead of
          // leaving the user staring at a spinner forever.
          .timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        // The Worker sends back a JSON error like {"error": "...", "details": "..."}
        // when something goes wrong on its end (e.g. bad model name,
        // AI service hiccup). Surface that message so it's easy to debug.
        final errorMsg = data['error'] ?? 'Something went wrong.';
        throw Exception(errorMsg);
      }

      final reply = data['reply'] as String?;
      if (reply == null || reply.trim().isEmpty) {
        throw Exception('Received an empty reply from the AI.');
      }

      return reply;
    } on http.ClientException {
      throw Exception(
        'Could not reach the AI companion. Check your internet connection.',
      );
    } catch (e) {
      // Re-throw anything else (including the Exceptions we threw above)
      // so the screen can show a message to the user.
      rethrow;
    }
  }
}