import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/widgets/cauldron_reveal_painter.dart';

void main() {
  group('CauldronRevealPainter', () {
    test('convergenceOpacity(0.0) returns 0.0', () {
      expect(CauldronRevealPainter.convergenceOpacity(0.0), 0.0);
    });

    test('convergenceOpacity(0.25) returns 0.0', () {
      expect(CauldronRevealPainter.convergenceOpacity(0.25), 0.0);
    });

    test('convergenceOpacity(0.40) returns value between 0.05 and 0.15', () {
      final opacity = CauldronRevealPainter.convergenceOpacity(0.40);
      expect(opacity, greaterThanOrEqualTo(0.05));
      expect(opacity, lessThanOrEqualTo(0.15));
    });

    test('convergenceOpacity(0.60) returns value between 0.15 and 0.50', () {
      final opacity = CauldronRevealPainter.convergenceOpacity(0.60);
      expect(opacity, greaterThanOrEqualTo(0.15));
      expect(opacity, lessThanOrEqualTo(0.50));
    });

    test('convergenceOpacity(0.85) returns value between 0.50 and 0.90', () {
      final opacity = CauldronRevealPainter.convergenceOpacity(0.85);
      expect(opacity, greaterThanOrEqualTo(0.50));
      expect(opacity, lessThanOrEqualTo(0.90));
    });

    test('convergenceOpacity(1.0) returns 1.0', () {
      expect(CauldronRevealPainter.convergenceOpacity(1.0), 1.0);
    });

    test('turbulenceIntensity(0.40) returns high value', () {
      expect(CauldronRevealPainter.turbulenceIntensity(0.40), closeTo(0.846, 0.01));
    });

    test('turbulenceIntensity(0.85) returns low value', () {
      expect(CauldronRevealPainter.turbulenceIntensity(0.85), closeTo(0.153, 0.01));
    });

    test('turbulenceIntensity(1.0) returns 0.0', () {
      expect(CauldronRevealPainter.turbulenceIntensity(1.0), 0.0);
    });
  });
}
