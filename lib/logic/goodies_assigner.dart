import 'dart:math';

import '../models/cauldron_goodie.dart';
import '../models/cauldron_goodies_catalog.dart';
import '../models/level.dart';

/// Assigns goodies to dead-end tiles using weighted random selection
/// based on rarity tiers (MTG-inspired).
///
/// Probability calculation:
///   Common (weight 10): ~52%  each of 5 → ~10.4% per goodie
///   Uncommon (weight 5): ~26% each of 4 → ~6.5% per goodie
///   Rare (weight 2): ~10.5%   each of 1 → ~10.5% per goodie
///   Legendary (weight 1): ~5.3% (Hard only, else excluded)
class GoodiesAssigner {
  /// Assign goodies to dead-end tiles using weighted random selection.
  /// [deadEndCount] - how many ampolle need goodies
  /// [difficulty] - game difficulty (only Hard can get Legendary)
  /// [random] - injectable Random for testing
  static List<CauldronGoodie> assignGoodies(
    int deadEndCount,
    Difficulty difficulty, {
    Random? random,
  }) {
    final rand = random ?? Random();

    // Build the weighted pool based on difficulty
    final pool = <CauldronGoodie>[
      ...CauldronGoodiesCatalog.common,
      ...CauldronGoodiesCatalog.uncommon,
      ...CauldronGoodiesCatalog.rare,
    ];

    // Hard mode: include legendary goodies
    if (difficulty == Difficulty.hard) {
      pool.addAll(CauldronGoodiesCatalog.legendary);
    }

    // Calculate total weight
    final totalWeight = pool.fold<int>(0, (sum, g) => sum + g.rarity.weight);

    // Pick [deadEndCount] goodies using weighted random, avoiding duplicates
    final result = <CauldronGoodie>[];
    final usedIds = <String>{};

    for (int i = 0; i < deadEndCount; i++) {
      final pick = _weightedPick(pool, totalWeight, rand, usedIds);
      result.add(pick);
      usedIds.add(pick.id);

      // If we've used all unique goodies, reset to allow repeats
      if (usedIds.length >= pool.length) {
        usedIds.clear();
      }
    }

    return result;
  }

  /// Pick a single goodie using weighted random selection.
  /// Avoids [usedIds] if possible (falls through if all used).
  static CauldronGoodie _weightedPick(
    List<CauldronGoodie> pool,
    int totalWeight,
    Random rand,
    Set<String> usedIds,
  ) {
    // Try up to 20 times to get a non-duplicate
    for (int attempt = 0; attempt < 20; attempt++) {
      int roll = rand.nextInt(totalWeight);
      for (final goodie in pool) {
        roll -= goodie.rarity.weight;
        if (roll < 0) {
          if (!usedIds.contains(goodie.id) || attempt >= 19) {
            return goodie;
          }
          break; // try again
        }
      }
    }
    // Fallback: return first available
    return pool.first;
  }
}
