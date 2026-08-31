import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/cauldron_goodie.dart';
import 'package:tubature/models/cauldron_goodies_catalog.dart';
import 'package:tubature/widgets/goodie_carousel_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testGoodies = [
    CauldronGoodie(
      id: 'maialino',
      assetPath: 'assets/goodies/maialino.png',
      displayName: 'Majjal!',
      emoji: '🐷',
      rarity: GoodieRarity.common,
      audioPath: 'assets/sounds/good-quality/majjal.mp3',
    ),
    CauldronGoodie(
      id: 'motorino',
      assetPath: 'assets/goodies/motorino.png',
      displayName: 'Motorino nel Canale',
      emoji: '🛵',
      rarity: GoodieRarity.rare,
      audioPath: 'assets/sounds/good-quality/magnat_al_canal.mp3',
    ),
    CauldronGoodie(
      id: 'schmoogle',
      assetPath: 'assets/goodies/schmoogle.png',
      displayName: 'Schmoogle',
      emoji: '👻',
      rarity: GoodieRarity.legendary,
    ),
  ];

  Widget buildTestDialog({int initialIndex = 0}) {
    return MaterialApp(
      home: Scaffold(
        body: GoodieCarouselDialog(
          goodies: testGoodies,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  group('GoodieCarouselDialog', () {
    testWidgets('renders initial goodie and counter', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestDialog(initialIndex: 0));
      await tester.pumpAndSettle();

      expect(find.text('Majjal!'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
      expect(find.text('COMMON'), findsOneWidget);
    });

    testWidgets('loops forward when next button pressed', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestDialog(initialIndex: 0));
      await tester.pumpAndSettle();

      // Tap Next (>) button
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Motorino nel Canale'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('RARE'), findsOneWidget);

      // Tap Next (>) again to get to Schmoogle
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Schmoogle'), findsOneWidget);
      expect(find.text('3 / 3'), findsOneWidget);
      expect(find.text('MYTHIC RARE'), findsOneWidget);

      // Tap Next (>) from last item wraps around to first item (Majjal!)
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Majjal!'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('loops backward when previous button pressed', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestDialog(initialIndex: 0));
      await tester.pumpAndSettle();

      // Tap Prev (<) from first item wraps around to last item (Schmoogle)
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Schmoogle'), findsOneWidget);
      expect(find.text('3 / 3'), findsOneWidget);

      // Tap Prev (<) again goes to Motorino
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Motorino nel Canale'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('navigates with swipe gestures', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestDialog(initialIndex: 0));
      await tester.pumpAndSettle();

      // Swipe Left (drag right-to-left) -> Next
      await tester.drag(find.text('Majjal!'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('Motorino nel Canale'), findsOneWidget);
      expect(find.text('2 / 3'), findsOneWidget);

      // Swipe Right (drag left-to-right) -> Previous
      await tester.drag(find.text('Motorino nel Canale'), const Offset(300, 0));
      await tester.pumpAndSettle();

      expect(find.text('Majjal!'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('navigates with keyboard arrow keys', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestDialog(initialIndex: 0));
      await tester.pumpAndSettle();

      // Press ArrowRight -> Next
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(find.text('Motorino nel Canale'), findsOneWidget);

      // Press ArrowLeft -> Prev
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(find.text('Majjal!'), findsOneWidget);
    });

    testWidgets('displays sound button when goodie has audio', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestDialog(initialIndex: 0));
      await tester.pumpAndSettle();

      // Majjal has audio
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);

      // Tap sound button
      await tester.tap(find.byIcon(Icons.volume_up_rounded));
      await tester.pumpAndSettle();
    });

    testWidgets('catalog entries for Majjal and Motorino have sound paths', () {
      final majjal = CauldronGoodiesCatalog.all.firstWhere((g) => g.id == 'maialino');
      expect(majjal.displayName, 'Majjal!');
      expect(majjal.audioPath, 'assets/sounds/good-quality/majjal.mp3');

      final motorino = CauldronGoodiesCatalog.all.firstWhere((g) => g.id == 'motorino');
      expect(motorino.displayName, 'Motorino nel Canale');
      expect(motorino.audioPath, 'assets/sounds/good-quality/magnat_al_canal.mp3');
    });
  });
}
