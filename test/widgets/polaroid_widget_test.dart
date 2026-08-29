import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/cauldron_goodie.dart';
import 'package:tubature/widgets/polaroid_widget.dart';

void main() {
  const testGoodie = CauldronGoodie(
    id: 'fior_di_tubo',
    displayName: 'Fior di Tubo',
    emoji: '🌸',
    assetPath: 'assets/goodies/flower.png',
    rarity: GoodieRarity.uncommon,
  );

  testWidgets('PolaroidWidget renders goodie name and frame', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: PolaroidWidget(
              goodie: testGoodie,
              rotationAngle: 0.1,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Fior di Tubo'), findsOneWidget);
    expect(find.byType(PolaroidWidget), findsOneWidget);
    expect(find.byType(Transform), findsWidgets);
  });

  testWidgets('PolaroidWidget responds to tap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PolaroidWidget(
              goodie: testGoodie,
              rotationAngle: -0.2,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(PolaroidWidget));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('PolaroidWidget rotation angle is clamped within +/- 30 degrees', (tester) async {
    const maxAngleRad = 30.0 * pi / 180.0;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: PolaroidWidget(
              goodie: testGoodie,
              rotationAngle: 1.5, // > 30 degrees (~86 deg)
            ),
          ),
        ),
      ),
    );

    final polaroidState = tester.widget<PolaroidWidget>(find.byType(PolaroidWidget));
    expect(polaroidState.clampedRotationAngle, closeTo(maxAngleRad, 0.001));
  });
}
