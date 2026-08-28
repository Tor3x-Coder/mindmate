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
    testWidgets('Sad mood leads with talking it through, not breathing',
        (tester) async {
      await pumpNextStep(tester, 'Sad');
      // Recommended (first) option is the chat option.
      expect(find.text('Talk it through'), findsWidgets);
      // CBT reframe and human support are both offered.
      expect(find.text('Reframe one thought'), findsOneWidget);
      expect(find.text('Explore human support'), findsOneWidget);
      // Mood-appropriate moment copy, no crisis language for this mood alone.
      expect(
        find.text("You don’t have to carry this alone."),
        findsOneWidget,
      );
    });

    testWidgets('Stressed mood leads with a breathing reset', (tester) async {
      await pumpNextStep(tester, 'Stressed');
      expect(find.text('A short breathing reset'), findsOneWidget);
      expect(
        find.text('Let’s make this moment more manageable.'),
        findsOneWidget,
      );
    });

    testWidgets('Angry mood leads with a breathing reset', (tester) async {
      await pumpNextStep(tester, 'Angry');
      expect(find.text('A short breathing reset'), findsOneWidget);
      expect(
        find.text('Let’s give this feeling somewhere to go.'),
        findsOneWidget,
      );
    });

    testWidgets('Tired mood leads with a gentle wind-down meditation',
        (tester) async {
      await pumpNextStep(tester, 'Tired');
      expect(find.text('A gentle wind-down'), findsOneWidget);
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

    testWidgets('Unknown/neutral mood falls back to the safe default set',
        (tester) async {
      await pumpNextStep(tester, 'Okay');
      expect(find.text('A short breathing reset'), findsOneWidget);
      expect(find.text('You seem steady right now.'), findsOneWidget);
    });

    testWidgets('Human support is always offered, for every mood',
        (tester) async {
      for (final mood in ['Sad', 'Stressed', 'Angry', 'Tired', 'Happy',
        'Excited', 'Okay', 'Weird']) {
        await tester.pumpWidget(
          MaterialApp(
            home: NextStepScreen(moodLabel: mood, moodEmoji: '🙂'),
          ),
        );
        expect(
          find.text('Explore human support'),
          findsOneWidget,
          reason: 'human support must be offered for mood: $mood',
        );
      }
    });
  });
}
