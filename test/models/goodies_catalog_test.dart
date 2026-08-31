import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/cauldron_goodies_catalog.dart';
import 'package:tubature/models/cauldron_goodie.dart';

/// WHY: Every goodie in the catalog MUST have a real image asset, not just an
/// emoji fallback. When GoodiesImageService.preloadImages() runs, it loads
/// images by assetPath. If the path is wrong or missing, the goodie shows
/// an ugly emoji instead of the beautiful mosaic art.
///
/// BUG (2026-08-25): The Goodies Catalog debug screen showed emoji for most
/// goodies because images weren't preloaded from the home screen. Even after
/// fixing the preload, we need to ensure every catalog entry points to a
/// valid asset path.
void main() {
  group('Goodies catalog integrity', () {
    // WHY: Catches typos in assetPath or forgotten asset declarations.
    test('every goodie has a valid assetPath format', () {
      for (final goodie in CauldronGoodiesCatalog.all) {
        expect(goodie.assetPath.isNotEmpty, true,
            reason: '${goodie.id} must have an assetPath');
        expect(goodie.assetPath.startsWith('assets/goodies/'), true,
            reason: '${goodie.id} assetPath must start with assets/goodies/');
        expect(goodie.assetPath.endsWith('.png'), true,
            reason: '${goodie.id} assetPath must end with .png');
      }
    });

    // WHY: Duplicate IDs would cause GoodiesImageService cache collisions —
    // one image would silently overwrite another.
    test('every goodie has a unique id', () {
      final ids = CauldronGoodiesCatalog.all.map((g) => g.id).toSet();
      expect(ids.length, CauldronGoodiesCatalog.all.length,
          reason: 'All goodie IDs must be unique');
    });

    // WHY: Every goodie needs a displayName for the victory/catalog screens.
    test('every goodie has a non-empty displayName', () {
      for (final goodie in CauldronGoodiesCatalog.all) {
        expect(goodie.displayName.isNotEmpty, true,
            reason: '${goodie.id} must have a displayName');
      }
    });

    // WHY: Rarity weights must be positive for weighted random to work.
    // Zero or negative weights would break the probability math.
    test('every goodie has a positive rarity weight', () {
      for (final goodie in CauldronGoodiesCatalog.all) {
        expect(goodie.rarity.weight > 0, true,
            reason: '${goodie.id} rarity weight must be > 0');
      }
    });

    // WHY: We want all 4 MTG-inspired rarity tiers populated.
    test('catalog has goodies in all 4 rarity tiers', () {
      final rarities = CauldronGoodiesCatalog.all.map((g) => g.rarity).toSet();
      expect(rarities.contains(GoodieRarity.common), true);
      expect(rarities.contains(GoodieRarity.uncommon), true);
      expect(rarities.contains(GoodieRarity.rare), true);
      expect(rarities.contains(GoodieRarity.legendary), true);
    });

    // WHY: standardGoodies is used for non-Hard modes and must exclude
    // legendary goodies (Schmoogle is Hard-only).
    test('standardGoodies does not include legendary', () {
      for (final g in CauldronGoodiesCatalog.standardGoodies) {
        expect(g.isLegendary, false,
            reason: '${g.id} should not be legendary in standardGoodies');
      }
    });

    // WHY: isLegendary must match rarity == legendary, not be hardcoded.
    test('isLegendary is derived from rarity', () {
      for (final g in CauldronGoodiesCatalog.all) {
        expect(g.isLegendary, g.rarity == GoodieRarity.legendary,
            reason: '${g.id}: isLegendary should match rarity');
      }
    });

    // WHY: Verify minimum catalog size — we need enough variety for 5+ dead-ends.
    test('catalog has at least 10 goodies', () {
      expect(CauldronGoodiesCatalog.all.length >= 10, true,
          reason: 'Need enough variety for large grids');
    });

    // WHY: Goodies with custom audio must have non-empty audio paths ending in .mp3/.ogg
    test('goodies with audio have valid audio paths', () {
      final goodiesWithAudio = CauldronGoodiesCatalog.all.where((g) => g.hasAudio).toList();
      expect(goodiesWithAudio.isNotEmpty, true);
      for (final g in goodiesWithAudio) {
        expect(g.audioPath != null && g.audioPath!.isNotEmpty, true,
            reason: '${g.id} audioPath must not be empty');
        expect(
            g.audioPath!.endsWith('.mp3') || g.audioPath!.endsWith('.ogg'), true,
            reason: '${g.id} audioPath must end in .mp3 or .ogg');
      }
    });
  });
}
