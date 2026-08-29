import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/cauldron_goodies_catalog.dart';
import 'package:tubature/logic/goodies_assigner.dart';
import 'package:tubature/models/level.dart';

void main() {
  group('CauldronGoodiesCatalog', () {
    test('standardGoodies has exactly 13 entries', () {
      expect(CauldronGoodiesCatalog.standardGoodies.length, 13);
    });

    test('legendary has exactly 1 entry (Schmoogle)', () {
      expect(CauldronGoodiesCatalog.legendary.length, 1);
      expect(CauldronGoodiesCatalog.legendary.first.id, 'schmoogle');
    });

    test('all has exactly 14 entries', () {
      expect(CauldronGoodiesCatalog.all.length, 14);
    });
  });

  group('GoodiesAssigner', () {
    test('assignGoodies(3, Difficulty.easy) returns 3 unique standard goodies', () {
      final goodies = GoodiesAssigner.assignGoodies(3, Difficulty.easy);
      expect(goodies.length, 3);
      expect(goodies.toSet().length, 3);
      expect(goodies.any((g) => g.isLegendary), isFalse);
    });

    test('assignGoodies(4, Difficulty.easy) returns 4 unique standard goodies, no Schmoogle', () {
      final goodies = GoodiesAssigner.assignGoodies(4, Difficulty.easy);
      expect(goodies.length, 4);
      expect(goodies.toSet().length, 4);
      expect(goodies.any((g) => g.isLegendary), isFalse);
    });

    test('assignGoodies returns no duplicates within result', () {
      final goodies = GoodiesAssigner.assignGoodies(5, Difficulty.medium);
      expect(goodies.length, 5);
      expect(goodies.toSet().length, 5);
    });

    test('when deadEndCount > standardGoodies.length, wraps around gracefully', () {
      final goodies = GoodiesAssigner.assignGoodies(15, Difficulty.easy);
      expect(goodies.length, 15);
      expect(goodies.any((g) => g.isLegendary), isFalse);
    });

    test('Schmoogle NEVER appears on Easy or Medium difficulty', () {
      final random = _FakeRandom(pickLast: true);
      final easyGoodies = GoodiesAssigner.assignGoodies(5, Difficulty.easy, random: random);
      final mediumGoodies = GoodiesAssigner.assignGoodies(5, Difficulty.medium, random: random);
      
      expect(easyGoodies.any((g) => g.isLegendary), isFalse);
      expect(mediumGoodies.any((g) => g.isLegendary), isFalse);
    });

    test('with seeded Random rolling highest weight, Schmoogle appears on Hard', () {
      final fakeRandom = _FakeRandom(pickLast: true);
      final goodies = GoodiesAssigner.assignGoodies(3, Difficulty.hard, random: fakeRandom);
      
      expect(goodies.any((g) => g.isLegendary), isTrue);
      expect(goodies.length, 3);
      expect(goodies.toSet().length, 3);
    });
  });
}

class _FakeRandom implements Random {
  final bool pickLast;
  int _counter = 0;
  _FakeRandom({this.pickLast = false});
  
  @override
  bool nextBool() => true;
  
  @override
  double nextDouble() => 0.0;
  
  @override
  int nextInt(int max) {
    if (pickLast && _counter == 0) {
      _counter++;
      return max - 1;
    }
    final val = _counter % max;
    _counter++;
    return val;
  }
}
