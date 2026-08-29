import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('PolaroidMosaicOverlay advances on Spacebar press', (tester) async {
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

    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(advanced, isTrue);
  });

  testWidgets('PolaroidMosaicOverlay advances on Enter press', (tester) async {
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

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(advanced, isTrue);
  });

  testWidgets('PolaroidMosaicOverlay advances on button click or background tap', (tester) async {
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
}
