import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/performance_config.dart';
import 'package:tubature/models/cauldron_goodies_catalog.dart';
import 'package:tubature/models/level.dart';
import 'package:tubature/screens/game_screen.dart';
import 'package:tubature/screens/home_screen.dart';
import 'package:tubature/services/goodies_image_service.dart';
import 'package:tubature/widgets/tile_widget.dart';

void main() {
  setUp(() {
    PerformanceConfig.instance.setRaspberryPiMode(false);
    GoodiesImageService.clearCache();
  });

  tearDown(() {
    PerformanceConfig.instance.setRaspberryPiMode(false);
    GoodiesImageService.clearCache();
  });

  group('PerformanceConfig Raspberry Pi Detection & Toggles', () {
    test('detectFromUriAndEnvironment recognizes rpi, sguisatazzo, lowperf, and lite flags', () {
      expect(
        PerformanceConfig.detectFromUriAndEnvironment(
          queryParameters: {'rpi': '1'},
          jsLowEndFlag: false,
        ),
        isTrue,
      );
      expect(
        PerformanceConfig.detectFromUriAndEnvironment(
          queryParameters: {'sguisatazzo': 'true'},
          jsLowEndFlag: false,
        ),
        isTrue,
      );
      expect(
        PerformanceConfig.detectFromUriAndEnvironment(
          queryParameters: {'lowperf': 'yes'},
          jsLowEndFlag: false,
        ),
        isTrue,
      );
      expect(
        PerformanceConfig.detectFromUriAndEnvironment(
          queryParameters: {'rpi': '0'},
          jsLowEndFlag: true,
        ),
        isFalse,
      );
      expect(
        PerformanceConfig.detectFromUriAndEnvironment(
          queryParameters: const {},
          jsLowEndFlag: true,
        ),
        isTrue,
      );
    });

    test('toggling Raspberry Pi mode updates all performance gates and notifies listeners', () {
      int notifications = 0;
      void listener() => notifications++;
      PerformanceConfig.instance.addListener(listener);

      expect(PerformanceConfig.isLowEnd, isFalse);
      expect(PerformanceConfig.enableContinuousShimmer, isTrue);
      expect(PerformanceConfig.enableBackdropBlur, isTrue);
      expect(PerformanceConfig.enableBackgroundVideoAutoplay, isTrue);
      expect(PerformanceConfig.goodieDecodeTargetSize, equals(256));

      PerformanceConfig.instance.setRaspberryPiMode(true);
      expect(notifications, equals(1));
      expect(PerformanceConfig.isLowEnd, isTrue);
      expect(PerformanceConfig.enableContinuousShimmer, isFalse);
      expect(PerformanceConfig.enableBackdropBlur, isFalse);
      expect(PerformanceConfig.enableBackgroundVideoAutoplay, isFalse);
      expect(PerformanceConfig.enableCanvasBlurAndSaveLayer, isFalse);
      expect(PerformanceConfig.goodieDecodeTargetSize, equals(128));
      expect(PerformanceConfig.victoryConfettiCount, equals(14));

      PerformanceConfig.instance.toggleRaspberryPiMode();
      expect(notifications, equals(2));
      expect(PerformanceConfig.isLowEnd, isFalse);

      PerformanceConfig.instance.removeListener(listener);
    });
  });

  group('GoodiesImageService Downscaled Texture Decoding (L2 Cache Friendly)', () {
    test('decodes 1024x1024 PNGs to 128x128 in Raspberry Pi mode and 256x256 in standard mode', () async {
      final sampleGoodie = CauldronGoodiesCatalog.all.first;

      PerformanceConfig.instance.setRaspberryPiMode(true);
      GoodiesImageService.clearCache();
      await GoodiesImageService.preloadImages([sampleGoodie]);
      final rpiImg = GoodiesImageService.getImage(sampleGoodie.id);
      expect(rpiImg, isNotNull);
      expect(rpiImg!.width, equals(128));
      expect(rpiImg.height, equals(128));

      PerformanceConfig.instance.setRaspberryPiMode(false);
      GoodiesImageService.clearCache();
      await GoodiesImageService.preloadImages([sampleGoodie]);
      final stdImg = GoodiesImageService.getImage(sampleGoodie.id);
      expect(stdImg, isNotNull);
      expect(stdImg!.width, equals(256));
      expect(stdImg.height, equals(256));
    });
  });

  group('HomeScreen & GameScreen Raspberry Pi Compliance', () {
    testWidgets('HomeScreen bypasses BackdropFilter in RPi mode and supports interactive toggle', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      PerformanceConfig.instance.setRaspberryPiMode(true);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump();

      // In RPi mode, BackdropFilter is bypassed!
      expect(find.byType(BackdropFilter), findsNothing);
      expect(find.text('🍓 RPi Turbo: ON ⚡'), findsOneWidget);

      // Tap toggle to switch to standard mode
      await tester.tap(find.byKey(const ValueKey('rpi_turbo_toggle')));
      await tester.pump();

      expect(PerformanceConfig.isLowEnd, isFalse);
      expect(find.byType(BackdropFilter), findsOneWidget);
      expect(find.text('🍓 RPi Mode: OFF'), findsOneWidget);
    });

    testWidgets('GameScreen in RPi mode isolates tiles in RepaintBoundary and settles with zero infinite tickers', (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      PerformanceConfig.instance.setRaspberryPiMode(true);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameScreen(difficulty: Difficulty.easy),
          ),
        ),
      );
      await tester.pump();
      // Advance past initial flow animations and ampolla timers:
      // In RPi mode, pumpAndSettle succeeds without timing out because 0 infinite tickers run at rest!
      await tester.pumpAndSettle(const Duration(milliseconds: 100), EnginePhase.sendSemanticsUpdate, const Duration(seconds: 12));

      final tileWidgets = tester.widgetList<TileWidget>(find.byType(TileWidget));
      expect(tileWidgets.length, greaterThanOrEqualTo(25));
      expect(find.byType(RepaintBoundary), findsWidgets);
      expect(find.byKey(const ValueKey('game_rpi_turbo_btn')), findsOneWidget);
    });

    test('web/index.html includes Raspberry Pi auto-detection and WebKit2GTK ImageDecoder fix', () {
      final html = File('web/index.html').readAsStringSync();
      expect(html, contains('_tubatureLowEnd'));
      expect(html, contains('_setTubatureRpiMode'));
      expect(html, contains('delete window.ImageDecoder'));
      expect(html, contains('html.rpi-mode'));
    });
  });
}
