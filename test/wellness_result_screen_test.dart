import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/screens/wellness/wellness_result_screen.dart';
import 'package:mindmate/services/app_settings_controller.dart';
import 'package:mindmate/services/audio_guide_service.dart';
import 'package:mindmate/utils/pattern_insight.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WellnessResultScreen band behaviour', () {
    late AppSettingsController settings;
    late AudioGuideService audioGuide;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      settings = AppSettingsController();
      audioGuide = AudioGuideService();
    });

    tearDown(() {
      try {
        audioGuide.dispose();
        settings.dispose();
      } catch (_) {
        // The test environment has no audio platform channel; dispose must
        // not propagate anything beyond a platform-missing error.
      }
    });

    Future<void> pumpResult(
      WidgetTester tester,
      int score, {
      PatternInsight insight = const PatternInsight(),
    }) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AppSettingsController>.value(value: settings),
            ChangeNotifierProvider<AudioGuideService>.value(value: audioGuide),
          ],
          child: MaterialApp(
            home: WellnessResultScreen(score: score, insight: insight),
          ),
        ),
      );
    }

    testWidgets('steady day (score 80) shows steadiness copy, no support card',
        (tester) async {
      await pumpResult(tester, 80);
      expect(find.text('What we noticed'), findsOneWidget);
      expect(find.text('One gentle next step'), findsOneWidget);
      expect(find.text('Keep the good going'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
      expect(
        find.textContaining('several signs of steadiness'),
        findsOneWidget,
      );
      // No extra-support card for a steady day.
      expect(
        find.textContaining('human-support options'),
        findsNothing,
      );
    });

    testWidgets('mixed day (score 50) suggests the breathing reset',
        (tester) async {
      await pumpResult(tester, 50);
      expect(find.text('Try a short breathing reset'), findsOneWidget);
      expect(
        find.textContaining('mixed day'),
        findsOneWidget,
      );
    });

    testWidgets('heavier day (score 30) offers talk-it-through + support card',
        (tester) async {
      await pumpResult(tester, 30);
      expect(find.text('Talk it through'), findsWidgets);
      expect(
        find.text(
          'If today feels heavier than usual, see the human-support options.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'Your answers suggest today feels heavier than usual. '
          'Be gentle with yourself.',
        ),
        findsOneWidget,
      );
    });

    testWidgets(
        'a concerning insight surfaces the support card even at a mid score',
        (tester) async {
      await pumpResult(
        tester,
        60,
        insight: const PatternInsight(
          message: 'Tough few days in a row.',
          isConcerning: true,
        ),
      );
      expect(
        find.text(
          'If today feels heavier than usual, see the human-support options.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('replay/mute controls are present on the result screen',
        (tester) async {
      await pumpResult(tester, 80);
      expect(find.byTooltip('Replay narration'), findsOneWidget);
      expect(
        find.byTooltip('Turn result voice on'),
        findsOneWidget,
        reason: 'sound is off by default, so the toggle reads "on"',
      );
    });
  });
}
