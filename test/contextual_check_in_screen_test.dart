import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mindmate/screens/check_in/contextual_check_in_screen.dart';
import 'package:mindmate/services/chat_service.dart';

void main() {
  testWidgets('completes the contextual check-in and opens guidance', (
    tester,
  ) async {
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
              'question': null,
            },
          }),
          200,
        );
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ContextualCheckInScreen(chatService: service),
      ),
    );

    expect(find.text('What feels strongest right now?'), findsOneWidget);
    await tester.tap(find.text('Overwhelmed'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    await tester.tap(find.text('School or work'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    await tester.tap(find.text('Figure out what to do'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    await tester.enterText(
      find.byType(TextField),
      'Three deadlines are close together.',
    );
    await tester.tap(find.text('Find my next step'));
    await tester.pumpAndSettle();

    expect(find.text('One Safe Step'), findsOneWidget);
    expect(find.text('Make the next few minutes smaller'), findsOneWidget);
    expect(sentBody!['kind'], 'personalised_guidance');
    expect(
      (sentBody!['checkIn'] as Map<String, dynamic>)['need'],
      'Figure out what to do',
    );
  });
}
