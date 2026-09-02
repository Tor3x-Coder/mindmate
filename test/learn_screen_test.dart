import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mindmate/screens/learn/learn_screen.dart';

void main() {
  testWidgets('Learn list opens the article reader', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LearnScreen()),
    );

    expect(find.text('Explore the topics'), findsOneWidget);
    expect(find.text('What helps your mind on an ordinary day'), findsOneWidget);

    // The lower cards are lazily built by ListView. The content test covers
    // all sixteen core articles; this widget test keeps the navigation action visible.
    await tester.tap(find.text('What helps your mind on an ordinary day'));
    await tester.pumpAndSettle();

    // The reader is also a lazy ListView, so move to the end before checking
    // the article's in-app next-step card.
    await tester.scrollUntilVisible(
      find.text('A small next step'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('A small next step'), findsOneWidget);
    expect(find.text('Try one small practice'), findsOneWidget);
    expect(
      find.text(
        'Open a breathing practice and give yourself a few quiet minutes. You can stop whenever you need to.',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Ask MindMate about this'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Ask MindMate about this'), findsOneWidget);

    await tester.tap(find.text('Ask MindMate about this'));
    await tester.pumpAndSettle();

    expect(
      find.text('Using this read: What helps your mind on an ordinary day'),
      findsOneWidget,
    );
  });

  testWidgets('Explore more searches the bundled catalogue', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LearnExploreScreen()),
    );

    expect(find.text('Explore more'), findsOneWidget);
    expect(find.text('When your mind will not switch off'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'jealousy');
    await tester.pump();

    expect(find.text('When jealousy starts taking over'), findsOneWidget);
    expect(find.text('When your mind will not switch off'), findsNothing);
  });
}
