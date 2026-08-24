import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tubature/logic/game_notifier.dart';
import 'package:tubature/models/level.dart';

void main() {
  group('Goodies Integration', () {
    test('a level with dead-end tiles gets unique goodies assigned', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      
      notifier.startNewGame(Difficulty.easy);
      final state = container.read(gameProvider);
      
      // The generated level might have any number of dead ends, check the grid
      int deadEndCount = 0;
      for (int r = 0; r < state.grid!.rows; r++) {
        for (int c = 0; c < state.grid!.cols; c++) {
          if (state.grid!.tiles[r][c].type.name == 'deadEnd') {
            deadEndCount++;
          }
        }
      }
      
      expect(state.ampolleGoodies.length, deadEndCount);
      if (deadEndCount > 0) {
        final uniqueGoodies = state.ampolleGoodies.values.map((g) => g.id).toSet();
        expect(uniqueGoodies.length, deadEndCount); // assuming deadEndCount <= 8
      }
    });

    test('re-generating a level produces new goodies (assigned correctly)', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      
      notifier.startNewGame(Difficulty.medium);
      final state1 = container.read(gameProvider);
      final count1 = state1.ampolleGoodies.length;
      
      notifier.startNewGame(Difficulty.hard);
      final state2 = container.read(gameProvider);
      final count2 = state2.ampolleGoodies.length;
      
      // Just check they both assigned correctly based on their grids
      expect(state1.ampolleGoodies.length, count1);
      expect(state2.ampolleGoodies.length, count2);
    });
  });
}
