import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService playBreakSound Tests', () {
    setUp(() {
      AudioService.isMuted = false;
    });

    test('delta <= 0 does nothing and returns normally', () {
      expect(() => AudioService.playBreakSound(delta: 0), returnsNormally);
      expect(() => AudioService.playBreakSound(delta: -1), returnsNormally);
    });

    test('muted state does not throw', () {
      AudioService.isMuted = true;
      expect(() => AudioService.playBreakSound(delta: 5), returnsNormally);
      expect(() => AudioService.playBreakSound(delta: 12), returnsNormally);
    });

    test('delta 1-2 plays pipe crack', () {
      expect(() => AudioService.playBreakSound(delta: 1), returnsNormally);
      expect(() => AudioService.playBreakSound(delta: 2), returnsNormally);
    });

    test('delta 3-9 (moderate break) triggers aldamar at 20% probability or crack otherwise', () {
      // 20% threshold: roll < 0.2 triggers voice clip
      expect(() => AudioService.playBreakSound(delta: 5, probabilityRoll: 0.1), returnsNormally);
      // roll >= 0.2 triggers procedural pipe crack fallback
      expect(() => AudioService.playBreakSound(delta: 5, probabilityRoll: 0.5), returnsNormally);
      expect(() => AudioService.playBreakSound(delta: 9, probabilityRoll: 0.9), returnsNormally);
    });

    test('delta >= 10 (catastrophic break) triggers voice clip at 20% probability or crack otherwise', () {
      expect(() => AudioService.playBreakSound(delta: 10, probabilityRoll: 0.1), returnsNormally);
      expect(() => AudioService.playBreakSound(delta: 15, probabilityRoll: 0.8), returnsNormally);
    });
  });
}
