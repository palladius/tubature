import 'package:equatable/equatable.dart';

/// Represents a cartoon image ("goodie") that appears inside an ampolla
/// during the Magic Cauldron Reveal effect.
class CauldronGoodie extends Equatable {
  final String id;
  final String assetPath;
  final String displayName;
  final String emoji;
  final bool isLegendary;

  const CauldronGoodie({
    required this.id,
    required this.assetPath,
    required this.displayName,
    required this.emoji,
    this.isLegendary = false,
  });

  @override
  List<Object?> get props => [id, assetPath, displayName, emoji, isLegendary];
}
