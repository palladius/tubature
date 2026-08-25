@TestOn('browser')
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/game_notifier.dart';
import 'package:tubature/models/level.dart';
import 'package:tubature/models/tile.dart';

/// Tests that goodies (ampolleGoodies) are properly assigned and reset
/// across game lifecycle events: startNewGame, nextLevel, resetLevel.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  int _countDeadEnds(GameState state) {
    int count = 0;
    for (int r = 0; r < state.grid!.rows; r++) {
      for (int c = 0; c < state.grid!.cols; c++) {
        if (state.grid!.tiles[r][c].type == TileType.deadEnd) {
          count++;
        }
      }
    }
    return count;
  }

  group('Goodies lifecycle', () {
    test('startNewGame assigns goodies to all dead-end tiles', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame(Difficulty.easy);
      final state = container.read(gameProvider);

      final deadEndCount = _countDeadEnds(state);

      expect(state.ampolleGoodies.isNotEmpty, true,
          reason: 'Goodies should be assigned');
      expect(state.ampolleGoodies.length, deadEndCount,
          reason: 'Every dead-end should have a goodie');
    });

    test('nextLevel assigns NEW goodies (not empty)', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame(Difficulty.easy);
      expect(container.read(gameProvider).ampolleGoodies.isNotEmpty, true,
          reason: 'Level 1 should have goodies');

      notifier.nextLevel();
      final state = container.read(gameProvider);
      final deadEndCount = _countDeadEnds(state);

      expect(state.ampolleGoodies.isNotEmpty, true,
          reason: 'Level 2 should also have goodies');
      expect(state.ampolleGoodies.length, deadEndCount,
          reason: 'Every dead-end on new level should have a goodie');
    });

    test('resetLevel preserves goodies (same level, same goodies)', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame(Difficulty.easy);
      final originalGoodies = Map.of(container.read(gameProvider).ampolleGoodies);
      expect(originalGoodies.isNotEmpty, true);

      notifier.resetLevel();
      final resetGoodies = container.read(gameProvider).ampolleGoodies;

      expect(resetGoodies.length, originalGoodies.length,
          reason: 'Reset should keep the same goodies');
      for (final pos in originalGoodies.keys) {
        expect(resetGoodies[pos]?.id, originalGoodies[pos]?.id,
            reason: 'Goodie at $pos should be the same after reset');
      }
    });

    test('resetLevel resets connectivity (isComplete, moveCount)', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame(Difficulty.easy);
      notifier.resetLevel();
      final state = container.read(gameProvider);

      expect(state.isComplete, false);
      expect(state.moveCount, 0);
    });

    test('nextLevel across 5 levels always has goodies', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame(Difficulty.easy);
      for (int i = 0; i < 5; i++) {
        final state = container.read(gameProvider);
        expect(state.ampolleGoodies.isNotEmpty, true,
            reason: 'Level ${i + 1} should have goodies');

        for (final pos in state.ampolleGoodies.keys) {
          final tile = state.grid!.tiles[pos.row][pos.col];
          expect(tile.type, TileType.deadEnd,
              reason: 'Goodie at $pos should be on a dead-end tile');
        }

        notifier.nextLevel();
      }
    });

    test('progressive mode has goodies across levels', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.startProgressive();
      expect(container.read(gameProvider).ampolleGoodies.isNotEmpty, true,
          reason: 'Progressive level 1 should have goodies');

      notifier.nextLevel();
      expect(container.read(gameProvider).ampolleGoodies.isNotEmpty, true,
          reason: 'Progressive level 2 should have goodies');
    });
  });
}
