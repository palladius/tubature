import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Rarity tiers for goodies, inspired by MTG.
/// Weight determines how likely a goodie is to appear.
/// Colors follow MTG card border conventions:
///   Common = Black, Uncommon = Silver, Rare = Gold, Mythic Rare = Dark Orange
enum GoodieRarity {
  common(weight: 10, color: Colors.black, label: 'Common'),
  uncommon(weight: 5, color: Color(0xFFC0C0C0), label: 'Uncommon'),   // Silver
  rare(weight: 2, color: Color(0xFFD4AF37), label: 'Rare'),           // Gold
  legendary(weight: 1, color: Color(0xFFCD7F32), label: 'Mythic Rare'); // Bronze/Dark Orange

  final int weight;
  final Color color;
  final String label;
  const GoodieRarity({required this.weight, required this.color, required this.label});
}

/// Represents a cartoon image ("goodie") that appears inside an ampolla
/// during the Magic Cauldron Reveal effect.
class CauldronGoodie extends Equatable {
  final String id;
  final String assetPath;
  final String displayName;
  final String emoji;
  final GoodieRarity rarity;
  /// Optional audio to play on hover/tap. Path to an mp3 asset.
  final String? audioPath;

  const CauldronGoodie({
    required this.id,
    required this.assetPath,
    required this.displayName,
    required this.emoji,
    this.rarity = GoodieRarity.common,
    this.audioPath,
  });

  bool get isLegendary => rarity == GoodieRarity.legendary;
  bool get hasAudio => audioPath != null;

  @override
  List<Object?> get props => [id, assetPath, displayName, emoji, rarity, audioPath];
}
