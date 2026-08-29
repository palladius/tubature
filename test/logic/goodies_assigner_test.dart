import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/cauldron_goodies_catalog.dart';
import 'package:tubature/logic/goodies_assigner.dart';
import 'package:tubature/models/level.dart';

void main() {
  group('CauldronGoodiesCatalog', () {
    test('standardGoodies contains all non-legendary entries', () {
      expect(CauldronGoodiesCatalog.standardGoodies.length,
          CauldronGoodiesCatalog.common.length +
              CauldronGoodiesCatalog.uncommon.length +
              CauldronGoodiesCatalog.rare.length);
    });

    test('legendary has exactly 1 entry (Schmoogle)', () {
      expect(CauldronGoodiesCatalog.legendary.length, 1);
      expect(CauldronGoodiesCatalog.legendary.first.id, 'schmoogle');
    });

    test('all matches standardGoodies plus legendary', () {
      expect(CauldronGoodiesCatalog.all.length,
          CauldronGoodiesCatalog.standardGoodies.length +
              CauldronGoodiesCatalog.legendary.length);
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
      final goodies = GoodiesAssigner.assignGoodies(25, Difficulty.easy);
      expect(goodies.length, 25);
      expect(goodies.any((g) => g.isLegendary), isFalse);
    });

    test('Schmoogle NEVER appears on Easy or Medium difficulty', () {
      final random = _FakeRandom(0);
      final easyGoodies = GoodiesAssigner.assignGoodies(5, Difficulty.easy, random: random);
      final mediumGoodies = GoodiesAssigner.assignGoodies(5, Difficulty.medium, random: random);
      
      expect(easyGoodies.any((g) => g.isLegendary), isFalse);
      expect(mediumGoodies.any((g) => g.isLegendary), isFalse);
    });

    test('with seeded Random rolling highest weight index, Schmoogle appears on Hard', () {
      // Schmoogle is at the end of the pool on Hard mode
      // Roll sequence: [9999 (hits Schmoogle), 0 (hits ruby), 15 (hits dragon)]
      final fakeRandom = _SequenceRandom();
      final goodies = GoodiesAssigner.assignGoodies(3, Difficulty.hard, random: fakeRandom);
      
      expect(goodies.any((g) => g.isLegendary), isTrue);
      expect(goodies.length, 3);
      expect(goodies.toSet().length, 3);
    });
  });
}

class _FakeRandom implements Random {
  final int fixedInt;
  _FakeRandom([this.fixedInt = 0]);
  
  @override
  bool nextBool() => true;
  
  @override
  double nextDouble() => 0.0;
  
  @override
  int nextInt(int max) => fixedInt % max;
}

class _SequenceRandom implements Random {
  int _idx = 0;
  
  @override
  bool nextBool() => true;
  
  @override
  double nextDouble() => 0.0;
  
  @override
  int nextInt(int max) {
    if (_idx == 0) {
      _idx++;
      return max - 1; // Pick Schmoogle (last element)
    }
    final val = (_idx * 15) % max;
    _idx++;
    return val;
  }
}
