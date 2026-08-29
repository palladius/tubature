import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/voice_entry.dart';
import 'package:tubature/services/audio_service.dart';
import 'package:tubature/widgets/talking_avatar_widget.dart';

void main() {
  group('TalkingAvatarWidget Tests', () {
    testWidgets('Renders talking avatar and speech bubble on voice event', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                TalkingAvatarWidget(),
              ],
            ),
          ),
        ),
      );

      // Initially hidden
      expect(find.text('« Mayàl, ac du bàl! »'), findsNothing);
      expect(find.text('🥚 ERMETE (EASTER EGG)'), findsNothing);

      // Trigger victory voice event
      const testVoice = VoiceEntry(
        id: 'majjal-ac-du-bal',
        folder: 'good',
        path: 'assets/voices/good/majjal-ac-du-bal.mp3',
        category: 'easter_egg',
        displayName: 'Mayàl, ac du bàl!',
        meaningIt: 'Maiale, che due palle!',
        requiredAmpollaCount: 2,
      );

      AudioService.onVoiceStarted?.call(testVoice);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Should show dialect line and Italian subtitle
      expect(find.text('« Mayàl, ac du bàl! »'), findsOneWidget);
      expect(find.text('Maiale, che due palle!'), findsOneWidget);
      expect(find.text('🥚 ERMETE (EASTER EGG)'), findsOneWidget);

      // Advance clock to allow speech and dismiss timer to finish
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
