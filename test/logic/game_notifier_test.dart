import 'package:tubature/models/tile.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubature/logic/game_notifier.dart';
import 'package:tubature/models/level.dart';
import 'package:tubature/models/position.dart';

void main() {
  test('GameNotifier initial state', () {
    final container = ProviderContainer();
    final state = container.read(gameProvider);
    expect(state.grid, isNull);
    expect(state.isComplete, isFalse);
  });

  test('GameNotifier startNewGame', () {
    final container = ProviderContainer();
    container.read(gameProvider.notifier).startNewGame(Difficulty.easy);
    
    final state = container.read(gameProvider);
    expect(state.grid, isNotNull);
    expect(state.grid!.rows, 6);
    expect(state.moveCount, 0);
  });

  test('GameNotifier rotateTile', () {
    final container = ProviderContainer();
    container.read(gameProvider.notifier).startTutorial(1);
    
    final state = container.read(gameProvider);
    expect(state.grid, isNotNull);
    
    // Find a non-fixed tile to rotate
    Position? targetPos;
    for (int r = 0; r < state.grid!.rows; r++) {
      for (int c = 0; c < state.grid!.cols; c++) {
        final t = state.grid!.tiles[r][c];
        if (!t.isFixed && t.type != TileType.empty) {
          targetPos = Position(r, c);
          break;
        }
      }
      if (targetPos != null) break;
    }

    if (targetPos != null) {
      container.read(gameProvider.notifier).rotateTile(targetPos);
      final newState = container.read(gameProvider);
      expect(newState.moveCount, 1);
    }
  });

  test('GameNotifier resetLevel', () {
    final container = ProviderContainer();
    container.read(gameProvider.notifier).startTutorial(1);
    container.read(gameProvider.notifier).resetLevel();
    
    final state = container.read(gameProvider);
    expect(state.moveCount, 0);
  });
}
