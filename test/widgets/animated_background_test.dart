import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/widgets/animated_background.dart';

void main() {
  testWidgets('AnimatedBackground builds and displays Image widget in landscape', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedBackground(
            isLandscape: true,
            initialDelay: Duration(milliseconds: 100),
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedBackground), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Fast-forward past delay to verify no exception thrown
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
  });

  testWidgets('AnimatedBackground builds and displays Image widget in portrait', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedBackground(
            isLandscape: false,
            initialDelay: Duration(milliseconds: 100),
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedBackground), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
  });
}
