import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/level_generator.dart';
import 'package:tubature/logic/win_checker.dart';
import 'package:tubature/models/level.dart';

void main() {
  test('LevelGenerator generates valid solvable level', () {
    final generator = LevelGenerator();
    final level = generator.generateLevel(Difficulty.easy);
    
    expect(level.grid.rows, 5);
    expect(level.grid.cols, 5);
    expect(WinChecker.checkWin(level.grid), isFalse); // Initially shuffled and unsolved
  });

  test('LevelGenerator tutorial levels', () {
    final generator = LevelGenerator();
    final level = generator.getTutorialLevel(1);
    
    expect(level.grid.rows, 3);
    expect(level.grid.cols, 3);
    expect(WinChecker.checkWin(level.grid), isFalse);
  });
}
