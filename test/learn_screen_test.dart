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

    // The lower cards are lazily built by ListView. The content test covers
    // all six articles; this widget test keeps the navigation action visible.
    await tester.tap(find.text('Things that quietly support your mind'));
    await tester.pumpAndSettle();

    expect(find.text('A small next step'), findsOneWidget);
    expect(find.text('Try one small practice'), findsOneWidget);
    expect(find.text('Open a breathing practice and give yourself a few quiet minutes. You can stop whenever you need to.'), findsOneWidget);
  });
}
