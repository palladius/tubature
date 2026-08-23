import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/app.dart';

void main() {
  testWidgets('App renders home screen with title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TubatureApp()),
    );

    // Verify the app title is displayed
    expect(find.text('TUBATURE'), findsOneWidget);
    expect(find.text('THE DUNGEON PLUMBERS'), findsOneWidget);
  });

  testWidgets('Home screen has play and tutorial buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TubatureApp()),
    );

    // Verify the main PLAY button exists
    expect(find.text('PLAY!'), findsOneWidget);

    // Verify tutorial button
    expect(find.text('📖  TUTORIAL'), findsOneWidget);

    // Verify progressive difficulty hint text
    expect(find.text('⚡ Progressive mode (difficulty increases)'), findsOneWidget);

    // Verify difficulty selector cards exist
    expect(find.text('Auto ⚡'), findsOneWidget);
    expect(find.text('Easy 🟢'), findsOneWidget);
    expect(find.text('Med 🟡'), findsOneWidget);
    expect(find.text('Hard 🔴'), findsOneWidget);
  });

  testWidgets('Selecting difficulty updates mode description', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TubatureApp()),
    );

    // Tap Easy card
    await tester.tap(find.text('Easy 🟢'));
    await tester.pumpAndSettle();

    expect(find.text('PLAY!'), findsOneWidget);
    expect(find.text('🟢 Fixed Easy mode (6×6 grid)'), findsOneWidget);

    // Tap Hard card
    await tester.tap(find.text('Hard 🔴'));
    await tester.pumpAndSettle();

    expect(find.text('PLAY!'), findsOneWidget);
    expect(find.text('🔴 Fixed Hard mode (9-10 grid)'), findsOneWidget);
  });
}
