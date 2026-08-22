import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/direction.dart';

void main() {
  group('Direction', () {
    test('opposite', () {
      expect(Direction.north.opposite, Direction.south);
      expect(Direction.east.opposite, Direction.west);
      expect(Direction.south.opposite, Direction.north);
      expect(Direction.west.opposite, Direction.east);
    });

    test('rotateClockwiseBy', () {
      expect(Direction.north.rotateClockwiseBy(90), Direction.east);
      expect(Direction.east.rotateClockwiseBy(180), Direction.west);
      expect(Direction.south.rotateClockwiseBy(270), Direction.east);
      expect(Direction.west.rotateClockwiseBy(360), Direction.west);
    });

    test('delta', () {
      expect(Direction.north.delta, (-1, 0));
      expect(Direction.east.delta, (0, 1));
      expect(Direction.south.delta, (1, 0));
      expect(Direction.west.delta, (0, -1));
    });
  });
}
