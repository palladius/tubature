import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/widgets/about_dialog.dart';

void main() {
  testWidgets('AboutTubatureDialog renders and switches languages', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AboutTubatureDialog(),
        ),
      ),
    );

    // Default language is Italian
    expect(find.text('Informazioni su Tubature'), findsOneWidget);
    expect(find.textContaining('Ale e Sebi'), findsOneWidget);

    // Switch to English
    final englishButton = find.text('English');
    expect(englishButton, findsOneWidget);
    await tester.tap(englishButton);
    await tester.pumpAndSettle();

    // Now English title and text should be present
    expect(find.text('About Tubature'), findsOneWidget);
    expect(find.textContaining('Ale and Sebi'), findsOneWidget);

    // Links & Credits should be rendered
    expect(find.text('Riccardo (@palladius)'), findsOneWidget);
    expect(find.text('Antigravity'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget);
  });
}
