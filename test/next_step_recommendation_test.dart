import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/screens/next_step_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpNextStep(WidgetTester tester, String mood) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NextStepScreen(moodLabel: mood, moodEmoji: '🙂'),
      ),
    );
  }

  group('NextStep recommendation logic', () {
    // The screen keeps itself calm by showing the recommended option plus
    // exactly two alternatives at a time, so these tests assert on what is
    // actually rendered for each mood.

    testWidgets('Sad mood leads with talking it through', (tester) async {
      await pumpNextStep(tester, 'Sad');
      // Recommended (first) option is the chat option.
      expect(find.text('Talk it through'), findsWidgets);
      // The two rendered alternatives for a sad check-in.
      expect(find.text('Write it out'), findsOneWidget);
      expect(find.text('A short breathing reset'), findsOneWidget);
      // Mood-appropriate moment copy.
      expect(
        find.text("You don’t have to carry this alone."),
        findsOneWidget,
      );
    });

    testWidgets('Stressed mood leads with a breathing reset + CBT reframe',
        (tester) async {
      await pumpNextStep(tester, 'Stressed');
      expect(find.text('A short breathing reset'), findsOneWidget);
      expect(find.text('Reframe one thought'), findsOneWidget);
      expect(find.text('Write it out'), findsOneWidget);
      expect(
        find.text('Let’s make this moment more manageable.'),
        findsOneWidget,
      );
    });

    testWidgets('Angry mood leads with a breathing reset', (tester) async {
      await pumpNextStep(tester, 'Angry');
      expect(find.text('A short breathing reset'), findsOneWidget);
      expect(find.text('Reframe one thought'), findsOneWidget);
      expect(
        find.text('Let’s give this feeling somewhere to go.'),
        findsOneWidget,
      );
    });

    testWidgets('Tired mood leads with a gentle wind-down meditation',
        (tester) async {
      await pumpNextStep(tester, 'Tired');
      expect(find.text('A gentle wind-down'), findsOneWidget);
      expect(find.text('A short breathing reset'), findsOneWidget);
      expect(
        find.text('Let’s give your mind and body a softer place to land.'),
        findsOneWidget,
      );
    });

    testWidgets('Happy mood gets positive-moment options, not crisis copy',
        (tester) async {
      await pumpNextStep(tester, 'Happy');
      expect(find.text('Tell me about it'), findsWidgets);
      expect(find.text('Keep the moment'), findsWidgets);
      expect(find.text('A short breathing reset'), findsOneWidget);
      expect(find.text('That’s nice to hear.'), findsOneWidget);
      // No sad-mood moment copy should leak into a happy check-in.
      expect(
        find.text("You don’t have to carry this alone."),
        findsNothing,
      );
    });

    testWidgets('Excited mood gets the enjoy-the-moment variant',
        (tester) async {
      await pumpNextStep(tester, 'Excited');
      expect(find.text('Tell me about it'), findsWidgets);
      expect(find.text('Enjoy the moment'), findsWidgets);
      expect(find.text('You sound excited.'), findsOneWidget);
    });

    testWidgets('Unknown/neutral moods fall back to the safe default set',
        (tester) async {
      await pumpNextStep(tester, 'Okay');
      expect(find.text('A short breathing reset'), findsOneWidget);
      expect(find.text('Write it out'), findsOneWidget);
      expect(find.text('A gentle wind-down'), findsOneWidget);
      expect(find.text('You seem steady right now.'), findsOneWidget);

      // An unexpected label must not crash and must land on the same default.
      await pumpNextStep(tester, 'Weird');
      expect(find.text('A short breathing reset'), findsOneWidget);
      expect(find.text('You seem steady right now.'), findsOneWidget);
    });

    testWidgets('every mood renders the calm 1-recommended + 2-alternatives '
        'structure', (tester) async {
      // One recommended card ("Recommended for you") plus two alternative
      // tiles under "Other ways to help", for every mood the app supports.
      for (final mood in ['Happy', 'Excited', 'Okay', 'Sad', 'Stressed',
        'Angry', 'Tired']) {
        await pumpNextStep(tester, mood);
        expect(find.text('Your next step'), findsOneWidget,
            reason: 'app bar for mood: $mood');
        expect(find.text('Other ways to help'), findsOneWidget,
            reason: 'alternatives header for mood: $mood');
        expect(find.text('I’m done for now'), findsOneWidget,
            reason: 'exit control for mood: $mood');
      }
    });
  });
}
