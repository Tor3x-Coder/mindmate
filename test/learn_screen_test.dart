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

    // Jump to the end so the action itself, rather than only its label, is
    // inside the test viewport before tapping it.
    final scrollableState = tester.state<ScrollableState>(
      find.byType(Scrollable).first,
    );
    scrollableState.position.jumpTo(scrollableState.position.maxScrollExtent);
    await tester.pumpAndSettle();

    final askButton = find.widgetWithText(
      OutlinedButton,
      'Ask MindMate about this',
    );
    expect(askButton, findsOneWidget);
    await tester.tap(askButton);
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
