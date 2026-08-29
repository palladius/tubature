import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/cauldron_goodie.dart';
import 'package:tubature/screens/polaroid_mosaic_overlay.dart';
import 'package:tubature/widgets/polaroid_widget.dart';

void main() {
  const testGoodies = [
    CauldronGoodie(
      id: 'g1',
      displayName: 'Dragon Gem',
      emoji: '💎',
      assetPath: 'assets/goodies/gem.png',
    ),
    CauldronGoodie(
      id: 'g2',
      displayName: 'Wizard Hat',
      emoji: '🧙',
      assetPath: 'assets/goodies/hat.png',
    ),
  ];

  testWidgets('PolaroidMosaicOverlay renders polaroid widgets for all goodies', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PolaroidMosaicOverlay(
            goodies: testGoodies,
            onNextLevel: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(PolaroidWidget), findsNWidgets(2));
    expect(find.text('Dragon Gem'), findsOneWidget);
    expect(find.text('Wizard Hat'), findsOneWidget);
  });

  testWidgets('PolaroidMosaicOverlay advances on button click', (tester) async {
    bool advanced = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PolaroidMosaicOverlay(
            goodies: testGoodies,
            onNextLevel: () => advanced = true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final nextButton = find.textContaining('Prossimo');
    expect(nextButton, findsOneWidget);

    await tester.tap(nextButton);
    await tester.pump();

    expect(advanced, isTrue);
  });

  testWidgets('Tapping top polaroid cycles the deck', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PolaroidMosaicOverlay(
            goodies: testGoodies,
            onNextLevel: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap top polaroid
    final topCardFinder = find.byType(PolaroidWidget).last;
    await tester.tap(topCardFinder);
    await tester.pump();

    // Verify still in overlay
    expect(find.byType(PolaroidWidget), findsNWidgets(2));
  });
}
