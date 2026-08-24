import 'dart:math';

import '../models/cauldron_goodie.dart';
import '../models/cauldron_goodies_catalog.dart';
import '../models/level.dart';

class GoodiesAssigner {
  /// Assign unique goodies to dead-end tiles.
  /// [deadEndCount] - how many ampolle need goodies
  /// [difficulty] - game difficulty (only Hard can get Schmoogle)
  /// [random] - injectable Random for testing
  static List<CauldronGoodie> assignGoodies(
    int deadEndCount,
    Difficulty difficulty, {
    Random? random,
  }) {
    final rand = random ?? Random();
    
    // Create a mutable copy of standard goodies
    final pool = List<CauldronGoodie>.from(CauldronGoodiesCatalog.standardGoodies);
    pool.shuffle(rand);
    
    // On Hard: 1% chance to inject Schmoogle (replacing one standard)
    if (difficulty == Difficulty.hard && rand.nextDouble() < 0.01) {
      if (pool.isNotEmpty) {
        pool[0] = CauldronGoodiesCatalog.legendary.first;
      }
    }
    
    final result = <CauldronGoodie>[];
    for (int i = 0; i < deadEndCount; i++) {
      result.add(pool[i % pool.length]);
    }
    
    return result;
  }
}
