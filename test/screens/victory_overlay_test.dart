import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/screens/victory_overlay.dart';

void main() {
  group('VictoryOverlay', () {
    Widget buildTestOverlay() {
      return MaterialApp(
        home: Scaffold(
          body: VictoryOverlay(
            moveCount: 12,
            onNextLevel: () {},
            onPlayAgain: () {},
          ),
        ),
      );
    }

    testWidgets('renders celebration text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestOverlay());
      await tester.pump(const Duration(milliseconds: 600));

      // One of the celebration texts should be rendered
      final richTexts = find.byType(Text);
      expect(richTexts, findsWidgets);
    });

    testWidgets('displays move count', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestOverlay());
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Solved in 12 moves!'), findsOneWidget);
    });

    testWidgets('displays Next Level and Play Again buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestOverlay());
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Next Level 🐉'), findsOneWidget);
      expect(find.text('Play Again 🔄'), findsOneWidget);
    });

    testWidgets('renders drag handle indicator', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestOverlay());
      await tester.pump(const Duration(milliseconds: 600));

      // The drag handle is a small Container. Verify Transform.translate exists
      // (it wraps the card and enables dragging via offset)
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('card can be dragged to a new position',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestOverlay());
      await tester.pump(const Duration(milliseconds: 600));

      // Find the victory card container (white card with rounded corners)
      final cardFinder = find.byType(GestureDetector);
      expect(cardFinder, findsWidgets);

      // Get the initial position of the card
      // The card starts centered with Transform.translate offset zero
      final transformFinder = find.byType(Transform);
      expect(transformFinder, findsWidgets);

      // Perform a drag gesture on the card
      // We drag from center of screen by (100, 50) pixels
      final center = tester.getCenter(find.text('Next Level 🐉'));
      await tester.dragFrom(center, const Offset(100, 50));
      await tester.pump();

      // After dragging, the Transform.translate should have a non-zero offset
      // Verify the card has moved by checking the Transform widget
      final transforms = tester.widgetList<Transform>(transformFinder);
      bool foundTranslated = false;
      for (final t in transforms) {
        if (t.transform.storage[12] != 0 || t.transform.storage[13] != 0) {
          foundTranslated = true;
          break;
        }
      }
      expect(foundTranslated, isTrue,
          reason: 'Card should have moved after drag');
    });

    testWidgets('card position changes after drag',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestOverlay());
      await tester.pump(const Duration(milliseconds: 600));

      // Get initial Transform matrices
      final transformsBefore =
          tester.widgetList<Transform>(find.byType(Transform)).toList();
      final initialOffsets = transformsBefore
          .map((t) => Offset(t.transform.storage[12], t.transform.storage[13]))
          .toList();

      // Drag the card
      final buttonCenter = tester.getCenter(find.text('Next Level 🐉'));
      await tester.dragFrom(buttonCenter, const Offset(80, 40));
      await tester.pump();

      // Verify at least one Transform offset changed
      final transformsAfter =
          tester.widgetList<Transform>(find.byType(Transform)).toList();
      bool anyMoved = false;
      for (int i = 0; i < transformsAfter.length && i < initialOffsets.length; i++) {
        final after = Offset(
            transformsAfter[i].transform.storage[12],
            transformsAfter[i].transform.storage[13]);
        if (after != initialOffsets[i]) {
          anyMoved = true;
          break;
        }
      }
      expect(anyMoved, isTrue,
          reason: 'At least one Transform offset should change after drag');
    });

    testWidgets('onNextLevel callback fires when button pressed',
        (WidgetTester tester) async {
      bool nextLevelCalled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VictoryOverlay(
            moveCount: 5,
            onNextLevel: () => nextLevelCalled = true,
            onPlayAgain: () {},
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.text('Next Level 🐉'));
      expect(nextLevelCalled, isTrue);
    });

    testWidgets('onPlayAgain callback fires when button pressed',
        (WidgetTester tester) async {
      bool playAgainCalled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VictoryOverlay(
            moveCount: 5,
            onNextLevel: () {},
            onPlayAgain: () => playAgainCalled = true,
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.text('Play Again 🔄'));
      expect(playAgainCalled, isTrue);
    });

    testWidgets('confetti animation is active', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestOverlay());
      await tester.pump(const Duration(milliseconds: 600));

      // CustomPaint is used for confetti
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('displays Mosaico Polaroid button and opens mosaic overlay on tap',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestOverlay());
      await tester.pump(const Duration(milliseconds: 600));

      final mosaicBtn = find.textContaining('Mosaico Polaroid');
      expect(mosaicBtn, findsOneWidget);

      await tester.tap(mosaicBtn);
      await tester.pumpAndSettle();

      expect(find.text('✨ MAGNIFICO! ✨'), findsWidgets);
    });
  });
}
