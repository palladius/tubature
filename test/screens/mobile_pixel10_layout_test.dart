import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/game_notifier.dart';
import 'package:tubature/models/cauldron_goodies_catalog.dart';
import 'package:tubature/models/direction.dart';
import 'package:tubature/models/grid.dart';
import 'package:tubature/models/level.dart';
import 'package:tubature/models/position.dart';
import 'package:tubature/models/tile.dart';
import 'package:tubature/screens/game_screen.dart';
import 'package:tubature/screens/victory_overlay.dart';
import 'package:tubature/widgets/tile_widget.dart';

/// Builds a deterministic solvable-shaped grid of [size]x[size] where
/// column `size - 1` has rotatable non-fixed tiles and several dead-end ampolle.
Grid _buildTestGrid(int size) {
  final tiles = List.generate(size, (r) {
    return List.generate(size, (c) {
      if (r == 0 && c == 0) {
        return const Tile(
          type: TileType.source,
          baseDirection: Direction.south,
          isFixed: true,
        );
      }
      if (c == size - 1 && r < size - 1) {
        return const Tile(type: TileType.deadEnd, rotation: 90);
      }
      if (r == size - 1 && c == size - 1) {
        return const Tile(type: TileType.corner, rotation: 180);
      }
      return const Tile(type: TileType.line, rotation: 0);
    });
  });
  return Grid(size, size, tiles);
}

void main() {
  group('Pixel 10 Mobile Portrait Layout & Zero-Occlusion Tests (Issues #15 & #16)', () {
    for (final viewport in const [
      Size(515, 1144), // Pixel 10 portrait at -20% (80%) browser zoom
      Size(412, 915), // Standard Pixel 10 portrait at 100% zoom (dpr 2.625)
      Size(343, 762), // Pixel 10 portrait at +20% (120%) browser zoom
      Size(360, 780), // Pixel 10 with Display Size = Large (dpr 3.0)
      Size(320, 700), // Pixel 10 with Display Size = Larger (dpr 3.375)
      Size(280, 620), // Pixel 10 with Display Size = Largest (dpr 3.85)
    ]) {
      for (final gridSize in const [6, 7, 8, 9, 10]) {
        testWidgets(
          'Full GameScreen with ${gridSize}x$gridSize grid fits 100% within ${viewport.width.toInt()}x${viewport.height.toInt()} at 100% zoom',
          (WidgetTester tester) async {
            tester.view.physicalSize = viewport;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(() {
              tester.view.resetPhysicalSize();
              tester.view.resetDevicePixelRatio();
            });

            final grid = _buildTestGrid(gridSize);
            final goodies = {
              for (int r = 0; r < gridSize - 1; r++)
                Position(r, gridSize - 1):
                    CauldronGoodiesCatalog.all[r % CauldronGoodiesCatalog.all.length],
            };

            await tester.pumpWidget(
              ProviderScope(
                child: MaterialApp(
                  home: GameScreen(
                    difficulty: gridSize <= 6
                        ? Difficulty.easy
                        : (gridSize <= 8 ? Difficulty.medium : Difficulty.hard),
                  ),
                ),
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 100));

            // Override with exact deterministic gridSize x gridSize
            final element = tester.element(find.byType(GameScreen));
            final container = ProviderScope.containerOf(element);
            final currentState = container.read(gameProvider);
            container.read(gameProvider.notifier).state = currentState.copyWith(
              grid: grid,
              connectedTiles: {const Position(0, 0)},
              ampolleGoodies: goodies,
              moveCount: 249,
            );
            await tester.pump();
            // Advance past any initial flow/goodie timers so disposal is clean
            await tester.pump(const Duration(seconds: 10));

            // Must not throw any RenderFlex overflow exception
            expect(tester.takeException(), isNull);

            // Every single TileWidget (all gridSize * gridSize tiles, NOT just 5 or 6!)
            // must be 100% within the visible viewport bounds at 100% zoom
            final tileFinder = find.byType(TileWidget);
            expect(tileFinder, findsNWidgets(gridSize * gridSize));

            double? firstRowTileWidth;
            for (final el in tileFinder.evaluate()) {
              final renderBox = el.renderObject as RenderBox;
              final topLeft = renderBox.localToGlobal(Offset.zero);
              final bottomRight = renderBox.localToGlobal(
                Offset(renderBox.size.width, renderBox.size.height),
              );
              firstRowTileWidth ??= renderBox.size.width;

              expect(
                topLeft.dx,
                greaterThanOrEqualTo(0.0),
                reason:
                    'Tile left edge (${topLeft.dx}) overflowed left of viewport on ${gridSize}x$gridSize at ${viewport.width}x${viewport.height}',
              );
              expect(
                bottomRight.dx,
                lessThanOrEqualTo(viewport.width + 0.5),
                reason:
                    'Tile right edge (${bottomRight.dx}) overflowed viewport width (${viewport.width}) on ${gridSize}x$gridSize',
              );
              expect(
                topLeft.dy,
                greaterThanOrEqualTo(0.0),
                reason:
                    'Tile top edge (${topLeft.dy}) overflowed top of viewport on ${gridSize}x$gridSize',
              );
              expect(
                bottomRight.dy,
                lessThanOrEqualTo(viewport.height + 0.5),
                reason:
                    'Tile bottom edge (${bottomRight.dy}) overflowed viewport height (${viewport.height}) on ${gridSize}x$gridSize',
              );
            }

            // Total width of all cols tiles must be <= viewport.width
            expect(
              firstRowTileWidth! * gridSize,
              lessThanOrEqualTo(viewport.width),
            );
          },
        );
      }
    }

    testWidgets(
      'Revealed MTG / Cauldron Goodies badges NEVER occlude rightmost column tiles on Pixel 10 portrait',
      (WidgetTester tester) async {
        const viewport = Size(412, 915);
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: GameScreen(difficulty: Difficulty.medium),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Force all grid tiles to be connected so all ampolle goodies trigger reveal timers
        final element = tester.element(find.byType(GameScreen));
        final container = ProviderScope.containerOf(element);
        final state = container.read(gameProvider);
        final grid = state.grid!;

        final allPositions = <Position>{
          for (int r = 0; r < grid.rows; r++)
            for (int c = 0; c < grid.cols; c++) Position(r, c),
        };
        final fakeGoodies = <Position, dynamic>{};
        int idx = 0;
        for (int r = 0; r < grid.rows; r++) {
          final pos = Position(r, grid.cols - 1);
          fakeGoodies[pos] =
              CauldronGoodiesCatalog.all[idx % CauldronGoodiesCatalog.all.length];
          idx++;
        }

        container.read(gameProvider.notifier).state = state.copyWith(
          connectedTiles: allPositions,
          ampolleGoodies: fakeGoodies.cast(),
        );
        await tester.pump();

        // Advance 6s (goodie reveal in GridWidget) + 3s (badge delay in GameScreen) = 10s
        await tester.pump(const Duration(seconds: 7));
        await tester.pump(const Duration(seconds: 4));

        // Verify every non-fixed tile in the rightmost column (col = cols - 1)
        // can be tapped directly and increments moveCount (not blocked by badges!)
        for (int r = 0; r < grid.rows; r++) {
          final pos = Position(r, grid.cols - 1);
          final tile = container.read(gameProvider).grid!.tileAt(pos)!;
          if (tile.isFixed) continue;

          final movesBefore = container.read(gameProvider).moveCount;
          final tileWidgetFinder = find.byWidgetPredicate(
            (w) => w is TileWidget && w.position == pos,
          );
          expect(tileWidgetFinder, findsOneWidget);

          await tester.tap(tileWidgetFinder);
          await tester.pump();

          final movesAfter = container.read(gameProvider).moveCount;
          expect(
            movesAfter,
            equals(movesBefore + 1),
            reason:
                'Rightmost tile at ($r, ${grid.cols - 1}) was occluded by Goodies/MTG badges and could not be rotated!',
          );
        }

        // Flush any pending flow animation timers triggered by tile rotations
        await tester.pump(const Duration(seconds: 10));
      },
    );

    testWidgets(
      'VictoryOverlay renders without clipping Mosaico Polaroid button on narrow/scaled Pixel 10',
      (WidgetTester tester) async {
        const viewport = Size(360, 740);
        tester.view.physicalSize = viewport;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.2),
              ),
              child: child!,
            ),
            home: Scaffold(
              body: VictoryOverlay(
                moveCount: 249,
                score: 3200,
                revealedGoodies: CauldronGoodiesCatalog.all.take(8).toList(),
                onNextLevel: () {},
                onPlayAgain: () {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 600));

        expect(tester.takeException(), isNull);
        expect(find.textContaining('Mosaico Polaroid'), findsOneWidget);
        expect(find.textContaining('Next Level'), findsOneWidget);
        expect(find.textContaining('Play Again'), findsOneWidget);
      },
    );

    test(
      'web/index.html enforces 100% CSS viewport lock (max-width: 100vw, max-height: 100dvh, overflow: hidden) and responsive HUD',
      () {
        final html = File('web/index.html').readAsStringSync();
        expect(
          html,
          contains(
            'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no, viewport-fit=cover',
          ),
        );
        expect(html, contains('box-sizing: border-box'));
        expect(html, contains('max-width: 100vw'));
        expect(html, contains('max-height: 100dvh'));
        expect(html, contains('overflow: hidden'));
        expect(html, contains('flt-glass-pane, flutter-view'));
        expect(html, contains('@media (max-width: 600px)'));
        expect(html, contains('transform: scale(0.76)'));
        expect(html, contains('hud.hidden = true'));
      },
    );
  });
}
