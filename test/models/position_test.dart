import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/direction.dart';
import 'package:tubature/models/position.dart';

void main() {
  group('Position', () {
    test('neighbor', () {
      const pos = Position(2, 2);
      expect(pos.neighbor(Direction.north), const Position(1, 2));
      expect(pos.neighbor(Direction.east), const Position(2, 3));
      expect(pos.neighbor(Direction.south), const Position(3, 2));
      expect(pos.neighbor(Direction.west), const Position(2, 1));
    });

    test('equality', () {
      expect(const Position(1, 1), const Position(1, 1));
      expect(const Position(1, 1), isNot(const Position(1, 2)));
    });
  });
}
