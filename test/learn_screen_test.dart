import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindmate/screens/learn/learn_screen.dart';

void main() {
  testWidgets('Learn list opens the article reader', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LearnScreen()),
    );

    expect(find.text('Explore the topics'), findsOneWidget);
    expect(find.text('Things that quietly support your mind'), findsOneWidget);

    // ListView lazily builds the lower cards, so scroll before checking the
    // final topic is present in the viewport.
    await tester.scrollUntilVisible(
      find.text('If your friend is struggling'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('If your friend is struggling'), findsOneWidget);

    await tester.tap(find.text('Things that quietly support your mind'));
    await tester.pumpAndSettle();

    expect(find.text('A small next step'), findsOneWidget);
    expect(find.text('Try one small practice'), findsOneWidget);
    expect(find.text('Open a breathing practice and give yourself a few quiet minutes. You can stop whenever you need to.'), findsOneWidget);
  });
}
