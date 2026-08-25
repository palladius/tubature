import 'package:equatable/equatable.dart';

/// Rarity tiers for goodies, inspired by MTG.
/// Weight determines how likely a goodie is to appear.
enum GoodieRarity {
  common(weight: 10),    // ~frequent
  uncommon(weight: 5),   // ~moderate
  rare(weight: 2),       // ~infrequent
  legendary(weight: 1);  // ~ultra-rare (Schmoogle, etc.)

  final int weight;
  const GoodieRarity({required this.weight});
}

/// Represents a cartoon image ("goodie") that appears inside an ampolla
/// during the Magic Cauldron Reveal effect.
class CauldronGoodie extends Equatable {
  final String id;
  final String assetPath;
  final String displayName;
  final String emoji;
  final GoodieRarity rarity;

  const CauldronGoodie({
    required this.id,
    required this.assetPath,
    required this.displayName,
    required this.emoji,
    this.rarity = GoodieRarity.common,
  });

  bool get isLegendary => rarity == GoodieRarity.legendary;

  @override
  List<Object?> get props => [id, assetPath, displayName, emoji, rarity];
}
