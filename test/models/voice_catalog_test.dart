import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/voice_entry.dart';

void main() {
  group('VoiceCatalog Tests', () {
    test('allVoices contains properly categorized entries', () {
      final good = VoiceCatalog.allVoices.where((v) => v.folder == 'good').toList();
      final bad = VoiceCatalog.allVoices.where((v) => v.folder == 'bad').toList();

      expect(good.length, greaterThanOrEqualTo(4));
      expect(bad.length, greaterThanOrEqualTo(3));

      for (final v in good) {
        expect(v.path.startsWith('assets/sounds/good-quality/') || v.path.startsWith('assets/voices/good/'), isTrue);
      }
      for (final v in bad) {
        expect(v.path.startsWith('assets/sounds/good-quality/') || v.path.startsWith('assets/voices/bad/'), isTrue);
      }
    });

    test('pickVictoryVoice with exactly 2 ampolle triggers Mayal easter egg', () {
      final voice = VoiceCatalog.pickVictoryVoice(ampollaCount: 2);
      expect(voice.displayName.startsWith('Mayàl'), isTrue);
      expect(voice.folder, equals('good'));
      expect(voice.category, equals('easter_egg'));
    });

    test('pickVictoryVoice with 0, 1, or 3 ampolle picks regular victory voice', () {
      final v0 = VoiceCatalog.pickVictoryVoice(ampollaCount: 0, randomIndex: 0);
      final v1 = VoiceCatalog.pickVictoryVoice(ampollaCount: 1, randomIndex: 1);
      final v3 = VoiceCatalog.pickVictoryVoice(ampollaCount: 3, randomIndex: 2);

      expect(v0.isEasterEgg, isFalse);
      expect(v1.isEasterEgg, isFalse);
      expect(v3.isEasterEgg, isFalse);

      expect(v0.isGood, isTrue);
      expect(v1.isGood, isTrue);
      expect(v3.isGood, isTrue);
    });

    test('pickFailureVoice picks voice from bad folder', () {
      final failureVoice = VoiceCatalog.pickFailureVoice(randomIndex: 0);
      expect(failureVoice.isBad, isTrue);
      expect(failureVoice.folder, equals('bad'));
      expect(failureVoice.path.startsWith('assets/sounds/good-quality/') || failureVoice.path.startsWith('assets/voices/bad/'), isTrue);
    });
  });
}
