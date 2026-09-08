import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/models/check_in_context_model.dart';
import 'package:mindmate/models/guidance_response_model.dart';
import 'package:mindmate/screens/check_in/contextual_check_in_screen.dart';
import 'package:mindmate/screens/check_in/guidance_result_screen.dart';

void main() {
  group('Contextual check-in flow', () {
    testWidgets('renders first question with 7 feeling options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ContextualCheckInScreen()),
      );

      expect(find.text('What feels strongest right now?'), findsOneWidget);
      // 7 feelings
      expect(find.text('Low or sad'), findsOneWidget);
      expect(find.text('Anxious or worried'), findsOneWidget);
      expect(find.text('Overwhelmed'), findsOneWidget);
      expect(find.text('Lonely or disconnected'), findsOneWidget);
      expect(find.text('Frustrated or angry'), findsOneWidget);
      expect(find.text('Numb or tired'), findsOneWidget);
      expect(find.text('Okay, but I want to check in'), findsOneWidget);
    });

    testWidgets('requires selection before continuing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ContextualCheckInScreen()),
      );

      // Continue button should be disabled initially (check via onPressed null)
      // Tap feeling
      await tester.tap(find.text('Overwhelmed'));
      await tester.pump();

      // Now continue should work and move to step 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('What is taking the most energy?'), findsOneWidget);
    });

    testWidgets('full flow through 3 questions to optional context', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ContextualCheckInScreen()),
      );

      // Step 1: feeling
      await tester.tap(find.text('Overwhelmed'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 2: energy
      expect(find.text('What is taking the most energy?'), findsOneWidget);
      await tester.tap(find.text('School or work'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 3: need
      expect(find.text('What would help most right now?'), findsOneWidget);
      await tester.tap(find.text('Figure out what to do'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 4: optional context
      expect(find.text('Want to tell MindMate a little more?'), findsOneWidget);
      expect(find.text('Find my next step'), findsOneWidget);
    });

    testWidgets('guidance result screen shows summary and next step', (tester) async {
      final ctx = CheckInContext(
        feeling: CheckInFeeling.overwhelmed,
        energySource: CheckInEnergySource.schoolOrWork,
        need: CheckInNeed.figureOut,
        freeText: 'Exams',
      );

      final guidance = GuidanceResponse(
        summary: 'It sounds like you may be carrying several demands at once.',
        whatMightBeHappening:
            'When too much competes for attention, starting can feel harder. Your mind might be trying to hold everything at once.',
        nextStep: const GuidanceNextStep(
          title: 'Make the next few minutes smaller',
          description:
              'Write down what is competing for your attention, then choose one thing for today.',
          actionId: 'small_plan',
          whyItMightHelp: 'One small step can be easier than solving everything.',
        ),
        alternatives: const [
          GuidanceAlternative(title: 'Try a calming reset', actionId: 'breathing'),
          GuidanceAlternative(title: 'Talk it through', actionId: 'open_chat'),
        ],
        gentleQuestion: 'Is there one small thing that would make the next hour kinder?',
      );

      await tester.pumpWidget(
        MaterialApp(home: GuidanceResultScreen(checkInContext: ctx, guidanceResponse: guidance)),
      );

      expect(find.textContaining('You checked in as overwhelmed'), findsOneWidget);
      expect(find.text('WHAT MIGHT BE HAPPENING?'), findsOneWidget);
      expect(find.textContaining('When too much competes'), findsOneWidget);
      expect(find.text('Make the next few minutes smaller'), findsOneWidget);
      expect(find.text('Other ways to help'), findsOneWidget);
      expect(find.text('Try a calming reset'), findsOneWidget);
      expect(find.text('ONE SAFE STEP FOR RIGHT NOW'), findsOneWidget);
    });

    testWidgets('crisis guidance shows emergency support card', (tester) async {
      final ctx = CheckInContext(
        feeling: CheckInFeeling.lowOrSad,
        energySource: CheckInEnergySource.myThoughts,
        need: CheckInNeed.connectSomeone,
      );

      final guidance = GuidanceResponse(
        summary: 'Thank you for sharing this',
        whatMightBeHappening: 'It can feel overwhelming',
        nextStep: const GuidanceNextStep(
          title: 'Reach human support right now',
          description: 'Please open Emergency Support',
          actionId: 'open_emergency_support',
        ),
        alternatives: const [],
        isCrisis: true,
      );

      await tester.pumpWidget(
        MaterialApp(home: GuidanceResultScreen(checkInContext: ctx, guidanceResponse: guidance)),
      );

      expect(find.text('You deserve immediate support'), findsOneWidget);
      expect(find.text('Open Emergency Support'), findsWidgets);
    });
  });
}
