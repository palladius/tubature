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
    expect(find.text('The Magic Plumber'), findsOneWidget);
  });

  testWidgets('Home screen has play and tutorial buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TubatureApp()),
    );

    // Verify the main PLAY button exists
    expect(find.text('▶  PLAY!'), findsOneWidget);

    // Verify tutorial button
    expect(find.text('📖  TUTORIAL'), findsOneWidget);

    // Verify progressive difficulty hint text
    expect(find.text('Difficulty increases as you play!'), findsOneWidget);
  });
}
