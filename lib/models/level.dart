// ignore_for_file: constant_identifier_names

import 'package:equatable/equatable.dart';
import 'grid.dart';

enum Difficulty { easy, medium, hard }
enum CreatureTheme { dragon_gems, wizard_dungeon, crystal_caves }

class Level extends Equatable {
  final int id;
  final Difficulty difficulty;
  final Grid grid;
  final CreatureTheme theme;
  final int? optimalMoves;
  /// The solved grid state (before shuffling). Used by the automated solver.
  final Grid? solvedGrid;

  const Level({
    required this.id,
    required this.difficulty,
    required this.grid,
    required this.theme,
    this.optimalMoves,
    this.solvedGrid,
  });

  @override
  List<Object?> get props => [id, difficulty, grid, theme, optimalMoves];
}
