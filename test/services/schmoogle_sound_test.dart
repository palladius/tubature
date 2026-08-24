import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/services/audio_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioService Schmoogle Sound', () {
    test('has playSchmoogleReveal method that can be called without error', () {
      // We mute to ensure we don't try to play real audio during test (which might fail depending on environment)
      // Actually we should test it both muted and unmuted to ensure the stub works.
      
      AudioService.isMuted = true;
      expect(() => AudioService.playSchmoogleReveal(), returnsNormally);
      
      AudioService.isMuted = false;
      expect(() => AudioService.playSchmoogleReveal(), returnsNormally);
    });
  });
}
