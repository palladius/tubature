import 'package:flutter/material.dart';

/// Color palettes and fantasy artwork for each level theme in Tubature.
class LevelTheme {
  final String name;
  final Color flowColor;
  final Color flowColorLight;
  final Color flowColorDark;
  final Color backgroundColor;
  final Color backgroundGradientEnd;
  final Color tileBackground;
  final Color pipeStroke;
  final Color pipeDisconnected;
  final String? backgroundImage;

  const LevelTheme({
    required this.name,
    required this.flowColor,
    required this.flowColorLight,
    required this.flowColorDark,
    required this.backgroundColor,
    required this.backgroundGradientEnd,
    required this.tileBackground,
    required this.pipeStroke,
    required this.pipeDisconnected,
    this.backgroundImage,
  });

  /// 🐉 Dragon & Gemstones: emerald green
  static const dragonGems = LevelTheme(
    name: 'Dragon & Gems',
    flowColor: Color(0xFF4CAF50),
    flowColorLight: Color(0xFFA5D6A7),
    flowColorDark: Color(0xFF2E7D32),
    backgroundColor: Color(0xFFF1F8E9),
    backgroundGradientEnd: Color(0xFFDCEDC8),
    tileBackground: Color(0xFFFAF8F5),
    pipeStroke: Color(0xFF2E3D2E),
    pipeDisconnected: Color(0xFFBDBDBD),
    backgroundImage: 'assets/images/dragon_gem_lair.jpg',
  );

  /// 🧙 Wizard & Alchemy Dungeon: royal purple
  static const wizardDungeon = LevelTheme(
    name: 'Wizard & Dungeon',
    flowColor: Color(0xFF9C27B0),
    flowColorLight: Color(0xFFCE93D8),
    flowColorDark: Color(0xFF6A1B9A),
    backgroundColor: Color(0xFFF3E5F5),
    backgroundGradientEnd: Color(0xFFE1BEE7),
    tileBackground: Color(0xFFFAF5FC),
    pipeStroke: Color(0xFF3E2D3E),
    pipeDisconnected: Color(0xFFBDBDBD),
    backgroundImage: 'assets/images/wizard_alchemy_lab.jpg',
  );

  /// 💎 Crystal Caves & Gemstone Grotto: luminous cyan/turquoise
  static const crystalCaves = LevelTheme(
    name: 'Crystal Caves',
    flowColor: Color(0xFF00ACC1),
    flowColorLight: Color(0xFF80DEEA),
    flowColorDark: Color(0xFF006064),
    backgroundColor: Color(0xFFE0F7FA),
    backgroundGradientEnd: Color(0xFFB2EBF2),
    tileBackground: Color(0xFFF4FBFB),
    pipeStroke: Color(0xFF1D353A),
    pipeDisconnected: Color(0xFFBDBDBD),
    backgroundImage: 'assets/images/fantasy_crystal_cave.jpg',
  );

  /// 🪙 Dungeon Treasure Vault: radiant amber gold
  static const dungeonTreasure = LevelTheme(
    name: 'Dungeon Treasure',
    flowColor: Color(0xFFFF9800),
    flowColorLight: Color(0xFFFFCC80),
    flowColorDark: Color(0xFFE65100),
    backgroundColor: Color(0xFFFFF3E0),
    backgroundGradientEnd: Color(0xFFFFE0B2),
    tileBackground: Color(0xFFFCF8F5),
    pipeStroke: Color(0xFF3E352D),
    pipeDisconnected: Color(0xFFBDBDBD),
    backgroundImage: 'assets/images/dungeon_treasure.jpg',
  );

  /// 🏛️ Dragon Aqueduct: deep aquatic teal
  static const dungeonAqueduct = LevelTheme(
    name: 'Dragon Aqueduct',
    flowColor: Color(0xFF009688),
    flowColorLight: Color(0xFF80CBC4),
    flowColorDark: Color(0xFF00695C),
    backgroundColor: Color(0xFFE0F2F1),
    backgroundGradientEnd: Color(0xFFB2DFDB),
    tileBackground: Color(0xFFF5FAFA),
    pipeStroke: Color(0xFF2D3E3D),
    pipeDisconnected: Color(0xFFBDBDBD),
    backgroundImage: 'assets/images/dungeon_aqueduct.jpg',
  );

  /// All medieval fantasy themes
  static const List<LevelTheme> allThemes = [
    dragonGems,
    wizardDungeon,
    crystalCaves,
    dungeonTreasure,
    dungeonAqueduct,
  ];
}
