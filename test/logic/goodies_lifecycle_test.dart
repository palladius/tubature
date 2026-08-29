import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/game_notifier.dart';
import 'package:tubature/models/level.dart';
import 'package:tubature/models/tile.dart';

/// Tests that goodies (ampolleGoodies) are properly assigned and reset
/// across game lifecycle events: startNewGame, nextLevel, resetLevel.
///
/// These tests exist because of REAL BUGS found during development:
/// - BUG (2026-08-24): nextLevel() created GameState inline without calling
///   _loadLevel(), so Level 2+ had ZERO goodies assigned. The ampolle were
///   just dark blobs with no images inside.
/// - BUG (2026-08-24): GridWidget's _revealedPositions set persisted across
///   level changes, causing hover zoom to show on tiles that never received
///   water in the current level.
/// - BUG (2026-08-25): Badges (_activeBadges) in game_screen persisted after
///   clicking "Play Again" or "Next Level", showing stale goodies from the
///   previous level.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  int countDeadEnds(GameState state) {
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
    // WHY: Baseline sanity check — every dead-end must have a goodie.
    // Without this, ampolle render as dark empty blobs.
    test('startNewGame assigns goodies to all dead-end tiles', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame(Difficulty.easy);
      final state = container.read(gameProvider);

      final deadEndCount = countDeadEnds(state);

      expect(state.ampolleGoodies.isNotEmpty, true,
          reason: 'Goodies should be assigned');
      expect(state.ampolleGoodies.length, deadEndCount,
          reason: 'Every dead-end should have a goodie');
    });

    // WHY: This was the main bug! nextLevel() used to create GameState
    // directly (bypassing _loadLevel), which meant ampolleGoodies was
    // left as empty {}. Level 2 had dark blobs, no images.
    // Fix: nextLevel() now calls _loadLevel() which assigns goodies.
    test('nextLevel assigns NEW goodies — regression for dark blob bug', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame(Difficulty.easy);
      expect(container.read(gameProvider).ampolleGoodies.isNotEmpty, true,
          reason: 'Level 1 should have goodies');

      notifier.nextLevel();
      final state = container.read(gameProvider);
      final deadEndCount = countDeadEnds(state);

      expect(state.ampolleGoodies.isNotEmpty, true,
          reason: 'Level 2 should also have goodies — was empty before fix');
      expect(state.ampolleGoodies.length, deadEndCount,
          reason: 'Every dead-end on new level should have a goodie');
    });

    // WHY: When user clicks "Play Again", the same level reloads.
    // Goodies should stay the SAME (same positions, same images).
    // Uses copyWith which preserves ampolleGoodies — verify it works.
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

    // WHY: Ensure resetLevel actually resets gameplay state (not just goodies).
    // If isComplete or moveCount persists, the UI shows stale victory state.
    test('resetLevel resets connectivity (isComplete, moveCount)', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame(Difficulty.easy);
      notifier.resetLevel();
      final state = container.read(gameProvider);

      expect(state.isComplete, false);
      expect(state.moveCount, 0);
    });

    // WHY: Stress test — the dark blob bug was intermittent because
    // it only happened on Level 2+. Testing 5 consecutive levels
    // ensures the fix is robust across progressive difficulty escalation.
    test('nextLevel across 5 levels always has goodies', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.startNewGame(Difficulty.easy);
      for (int i = 0; i < 5; i++) {
        final state = container.read(gameProvider);
        expect(state.ampolleGoodies.isNotEmpty, true,
            reason: 'Level ${i + 1} should have goodies');

        // Also verify goodies are on dead-end tiles, not random positions
        for (final pos in state.ampolleGoodies.keys) {
          final tile = state.grid!.tiles[pos.row][pos.col];
          expect(tile.type, TileType.deadEnd,
              reason: 'Goodie at $pos should be on a dead-end tile');
        }

        notifier.nextLevel();
      }
    });

    // WHY: Progressive mode (no chosen difficulty) uses a different
    // code path with auto-escalating difficulty. The nextLevel bug
    // could have affected this path too — verify it works.
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
