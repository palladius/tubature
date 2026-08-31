import 'cauldron_goodie.dart';

/// Catalog of all goodies available in the game.
/// Organized by rarity tiers (MTG-inspired):
///   Common (weight 10) — appear frequently
///   Uncommon (weight 5) — appear moderately
///   Rare (weight 2) — appear infrequently
///   Legendary (weight 1) — ultra-rare, special effects
class CauldronGoodiesCatalog {
  // ─── COMMON (weight 10) ───
  static const List<CauldronGoodie> common = [
    CauldronGoodie(
      id: 'ruby',
      assetPath: 'assets/goodies/ruby2.png',
      displayName: 'Ruby',
      emoji: '💎',
      rarity: GoodieRarity.common,
    ),
    CauldronGoodie(
      id: 'dragon',
      assetPath: 'assets/goodies/dragon.png',
      displayName: 'Dragon',
      emoji: '🐉',
      rarity: GoodieRarity.common,
    ),
    CauldronGoodie(
      id: 'unicorn',
      assetPath: 'assets/goodies/unicorn.png',
      displayName: 'Unicorn',
      emoji: '🦄',
      rarity: GoodieRarity.common,
    ),
    CauldronGoodie(
      id: 'hotwheel',
      assetPath: 'assets/goodies/hotwheel.png',
      displayName: 'Hotwheel',
      emoji: '🏎️',
      rarity: GoodieRarity.common,
    ),
    CauldronGoodie(
      id: 'pizza',
      assetPath: 'assets/goodies/pizza.png',
      displayName: 'Pizza Cotto&Funghi',
      emoji: '🍕',
      rarity: GoodieRarity.common,
    ),
    CauldronGoodie(
      id: 'puffin',
      assetPath: 'assets/goodies/puffin.png',
      displayName: 'Puffin Mosaico',
      emoji: '🐧',
      rarity: GoodieRarity.common,
    ),
    CauldronGoodie(
      id: 'maialino',
      assetPath: 'assets/goodies/maialino.png',
      displayName: 'Majjal!',
      emoji: '🐷',
      rarity: GoodieRarity.common,
      audioPath: 'assets/sounds/good-quality/majjal.mp3',
    ),
    CauldronGoodie(
      id: 'e-le-fante',
      assetPath: 'assets/goodies/e-le-fante.png',
      displayName: 'E-Le-Fante',
      emoji: '🐘',
      rarity: GoodieRarity.common,
    ),
    CauldronGoodie(
      id: 'coccodrillo',
      assetPath: 'assets/goodies/coccodrillo.png',
      displayName: 'Coccodrillo Chill',
      emoji: '🐊',
      rarity: GoodieRarity.common,
    ),
    CauldronGoodie(
      id: 'giraffa',
      assetPath: 'assets/goodies/giraffa.png',
      displayName: 'Giraffa Boxer',
      emoji: '🦒',
      rarity: GoodieRarity.common,
    ),
    CauldronGoodie(
      id: 'rinoceronte',
      assetPath: 'assets/goodies/rinoceronte.png',
      displayName: 'Rinoceronte Cucciolo',
      emoji: '🦏',
      rarity: GoodieRarity.common,
    ),
  ];

  // ─── UNCOMMON (weight 5) ───
  static const List<CauldronGoodie> uncommon = [
    CauldronGoodie(
      id: 'alessandro',
      assetPath: 'assets/goodies/alessandro.png',
      displayName: 'Alessandro',
      emoji: '🧑',
      rarity: GoodieRarity.uncommon,
    ),
    CauldronGoodie(
      id: 'sebi',
      assetPath: 'assets/goodies/sebi.png',
      displayName: 'Sebi',
      emoji: '👦',
      rarity: GoodieRarity.uncommon,
    ),
    CauldronGoodie(
      id: 'salama',
      assetPath: 'assets/goodies/salama.png',
      displayName: 'Salama da Sugo',
      emoji: '🧆',
      rarity: GoodieRarity.uncommon,
    ),
    CauldronGoodie(
      id: 'papino',
      assetPath: 'assets/goodies/papino.png',
      displayName: 'Papino',
      emoji: '👨',
      rarity: GoodieRarity.uncommon,
    ),
    CauldronGoodie(
      id: 'wizard',
      assetPath: 'assets/goodies/wizard.png',
      displayName: 'Wizard',
      emoji: '🧙',
      rarity: GoodieRarity.uncommon,
    ),
  ];

  // ─── RARE (weight 2) ───
  static const List<CauldronGoodie> rare = [
    CauldronGoodie(
      id: 'acquario',
      assetPath: 'assets/goodies/acquario.png',
      displayName: 'Acquario d\'Oro',
      emoji: '♒',
      rarity: GoodieRarity.rare,
    ),
    CauldronGoodie(
      id: 'fratelli',
      assetPath: 'assets/goodies/fratelli.png',
      displayName: 'Ale & Sebi',
      emoji: '🫂',
      rarity: GoodieRarity.rare,
    ),
    CauldronGoodie(
      id: 'tram',
      assetPath: 'assets/goodies/tram.png',
      displayName: 'Züri-Tram',
      emoji: '🚊',
      rarity: GoodieRarity.rare,
    ),
    CauldronGoodie(
      id: 'antigravity',
      assetPath: 'assets/goodies/antigravity.png',
      displayName: 'Antigravity',
      emoji: '🅰️',
      rarity: GoodieRarity.rare,
    ),
    CauldronGoodie(
      id: 'motorino',
      assetPath: 'assets/goodies/motorino.png',
      displayName: 'Motorino nel Canale',
      emoji: '🛵',
      rarity: GoodieRarity.rare,
      audioPath: 'assets/sounds/good-quality/magnat_al_canal.mp3',
    ),
  ];

  // ─── LEGENDARY (weight 1) ───
  static const List<CauldronGoodie> legendary = [
    CauldronGoodie(
      id: 'schmoogle',
      assetPath: 'assets/goodies/schmoogle.png',
      displayName: 'Schmoogle',
      emoji: '👻',
      rarity: GoodieRarity.legendary,
    ),
  ];

  /// All goodies across all rarities.
  static List<CauldronGoodie> get all => [
    ...common,
    ...uncommon,
    ...rare,
    ...legendary,
  ];

  /// Backward compatibility: standard = everything except legendary.
  static List<CauldronGoodie> get standardGoodies => [
    ...common,
    ...uncommon,
    ...rare,
  ];
}
