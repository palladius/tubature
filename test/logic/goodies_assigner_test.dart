import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/cauldron_goodies_catalog.dart';
import 'package:tubature/logic/goodies_assigner.dart';
import 'package:tubature/models/level.dart';

void main() {
  group('CauldronGoodiesCatalog', () {
    test('standardGoodies has exactly 8 entries', () {
      expect(CauldronGoodiesCatalog.standardGoodies.length, 8);
    });

    test('legendary has exactly 1 entry (Schmoogle)', () {
      expect(CauldronGoodiesCatalog.legendary.length, 1);
      expect(CauldronGoodiesCatalog.legendary.first.id, 'schmoogle');
    });

    test('all has exactly 9 entries', () {
      expect(CauldronGoodiesCatalog.all.length, 9);
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
      final goodies = GoodiesAssigner.assignGoodies(10, Difficulty.easy);
      expect(goodies.length, 10);
      expect(goodies.any((g) => g.isLegendary), isFalse);
    });

    test('Schmoogle NEVER appears on Easy or Medium difficulty', () {
      final random = _FakeRandom(0.005);
      final easyGoodies = GoodiesAssigner.assignGoodies(5, Difficulty.easy, random: random);
      final mediumGoodies = GoodiesAssigner.assignGoodies(5, Difficulty.medium, random: random);
      
      expect(easyGoodies.any((g) => g.isLegendary), isFalse);
      expect(mediumGoodies.any((g) => g.isLegendary), isFalse);
    });

    test('with seeded Random where value < 0.01, Schmoogle appears on Hard', () {
      final fakeRandom = _FakeRandom(0.005);
      final goodies = GoodiesAssigner.assignGoodies(3, Difficulty.hard, random: fakeRandom);
      
      expect(goodies.any((g) => g.isLegendary), isTrue);
      expect(goodies.length, 3);
      expect(goodies.toSet().length, 3);
    });
  });
}

class _FakeRandom implements Random {
  final double nextDoubleValue;
  _FakeRandom(this.nextDoubleValue);
  
  @override
  bool nextBool() => true;
  
  @override
  double nextDouble() => nextDoubleValue;
  
  @override
  int nextInt(int max) => 0; // Always swap with index 0 in shuffle
}
