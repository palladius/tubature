import 'package:flutter/material.dart';

/// Color palettes and artwork for each level theme in Tubature.
/// Themes celebrate the iconic Google Brand Colors (Blue, Red, Yellow, Green).
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

  /// 🔵 Google Blue Theme: iconic royal Google Blue (#4285F4)
  static const googleBlue = LevelTheme(
    name: 'Google Blue',
    flowColor: Color(0xFF4285F4),
    flowColorLight: Color(0xFF8AB4F8),
    flowColorDark: Color(0xFF1967D2),
    backgroundColor: Color(0xFFE8F0FE),
    backgroundGradientEnd: Color(0xFFD2E3FC),
    tileBackground: Color(0xFFF8FAFD),
    pipeStroke: Color(0xFF174EA6),
    pipeDisconnected: Color(0xFFBDC1C6),
    backgroundImage: 'assets/images/wizard_alchemy_lab.jpg',
  );

  /// 🔴 Google Red Theme: vibrant Google Red (#EA4335)
  static const googleRed = LevelTheme(
    name: 'Google Red',
    flowColor: Color(0xFFEA4335),
    flowColorLight: Color(0xFFF28B82),
    flowColorDark: Color(0xFFC5221F),
    backgroundColor: Color(0xFFFCE8E6),
    backgroundGradientEnd: Color(0xFFFAD2CF),
    tileBackground: Color(0xFFFDF7F7),
    pipeStroke: Color(0xFFA50E0E),
    pipeDisconnected: Color(0xFFBDC1C6),
    backgroundImage: 'assets/images/dungeon_treasure.jpg',
  );

  /// 🟡 Google Yellow Theme: radiant Google Yellow (#FBBC04)
  static const googleYellow = LevelTheme(
    name: 'Google Yellow',
    flowColor: Color(0xFFFBBC04),
    flowColorLight: Color(0xFFFDD663),
    flowColorDark: Color(0xFFF29900),
    backgroundColor: Color(0xFFFEF7E0),
    backgroundGradientEnd: Color(0xFFFEEFC3),
    tileBackground: Color(0xFFFEFCF5),
    pipeStroke: Color(0xFFE37400),
    pipeDisconnected: Color(0xFFBDC1C6),
    backgroundImage: 'assets/images/fantasy_crystal_cave.jpg',
  );

  /// 🟢 Google Green Theme: lush Google Green (#34A853)
  static const googleGreen = LevelTheme(
    name: 'Google Green',
    flowColor: Color(0xFF34A853),
    flowColorLight: Color(0xFF81C995),
    flowColorDark: Color(0xFF188038),
    backgroundColor: Color(0xFFE6F4EA),
    backgroundGradientEnd: Color(0xFFCEEAD6),
    tileBackground: Color(0xFFF6FBF7),
    pipeStroke: Color(0xFF137333),
    pipeDisconnected: Color(0xFFBDC1C6),
    backgroundImage: 'assets/images/dragon_gem_lair.jpg',
  );

  /// Backward compatible aliases
  static const dragonGems = googleGreen;
  static const wizardDungeon = googleBlue;
  static const crystalCaves = googleBlue;
  static const dungeonTreasure = googleYellow;
  static const dungeonAqueduct = googleRed;

  /// All 4 Google Brand themes
  static const List<LevelTheme> allThemes = [
    googleBlue,
    googleGreen,
    googleYellow,
    googleRed,
  ];
}
