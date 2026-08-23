import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/level_generator.dart';
import 'package:tubature/logic/win_checker.dart';
import 'package:tubature/models/level.dart';

void main() {
  test('LevelGenerator generates valid solvable level', () {
    final generator = LevelGenerator();
    final level = generator.generateLevel(Difficulty.easy);
    
    expect(level.grid.rows, 6);
    expect(level.grid.cols, 6);
    expect(WinChecker.checkWin(level.grid), isFalse); // Initially shuffled and unsolved
  });

  test('LevelGenerator tutorial levels', () {
    final generator = LevelGenerator();
    final level = generator.getTutorialLevel(1);
    
    expect(level.grid.rows, 4);
    expect(level.grid.cols, 4);
    expect(WinChecker.checkWin(level.grid), isFalse);
  });
}
