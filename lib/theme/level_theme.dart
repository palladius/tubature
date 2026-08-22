import 'package:flutter/material.dart';

/// Color palettes for each level theme in Tubature.
///
/// Each theme has a primary flow color, a lighter variant for fills,
/// and accent colors for the UI.
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
  });

  /// Dragon → Gems theme: emerald green
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
  );

  /// Wizard → Dungeon theme: royal purple
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
  );

  /// Space → Star Wars theme: cosmic blue
  static const spaceWars = LevelTheme(
    name: 'Space & Stars',
    flowColor: Color(0xFF2196F3),
    flowColorLight: Color(0xFF90CAF9),
    flowColorDark: Color(0xFF1565C0),
    backgroundColor: Color(0xFFE3F2FD),
    backgroundGradientEnd: Color(0xFFBBDEFB),
    tileBackground: Color(0xFFF5F9FC),
    pipeStroke: Color(0xFF2D3340),
    pipeDisconnected: Color(0xFFBDBDBD),
  );

  /// Sunset orange (bonus theme)
  static const sunsetOrange = LevelTheme(
    name: 'Sunset',
    flowColor: Color(0xFFFF9800),
    flowColorLight: Color(0xFFFFCC80),
    flowColorDark: Color(0xFFE65100),
    backgroundColor: Color(0xFFFFF3E0),
    backgroundGradientEnd: Color(0xFFFFE0B2),
    tileBackground: Color(0xFFFCF8F5),
    pipeStroke: Color(0xFF3E352D),
    pipeDisconnected: Color(0xFFBDBDBD),
  );

  /// Ocean teal (bonus theme)
  static const oceanTeal = LevelTheme(
    name: 'Ocean',
    flowColor: Color(0xFF009688),
    flowColorLight: Color(0xFF80CBC4),
    flowColorDark: Color(0xFF00695C),
    backgroundColor: Color(0xFFE0F2F1),
    backgroundGradientEnd: Color(0xFFB2DFDB),
    tileBackground: Color(0xFFF5FAFA),
    pipeStroke: Color(0xFF2D3E3D),
    pipeDisconnected: Color(0xFFBDBDBD),
  );

  /// All available themes
  static const List<LevelTheme> allThemes = [
    dragonGems,
    wizardDungeon,
    spaceWars,
    sunsetOrange,
    oceanTeal,
  ];
}
