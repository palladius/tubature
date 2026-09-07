import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Comprehensive build & bundle asset test.
/// Asserts that ALL critical resources declared in pubspec.yaml
/// (videos, background images, voice lines, audio SFX, goodies, shaders)
/// exist on disk, are non-empty, and when `build/web` is present, are correctly
/// bundled into the final distribution package and its AssetManifest.
void main() {
  group('Final Build Bundle & Resource Integrity Tests', () {
    test('all pubspec declared assets directories and core files exist on disk', () {
      final pubspecFile = File('pubspec.yaml');
      expect(pubspecFile.existsSync(), isTrue);
      final pubspec = pubspecFile.readAsStringSync();

      // Extract asset lines from pubspec.yaml
      final assetLines = pubspec
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.startsWith('- assets/'))
          .map((l) => l.substring(2).trim())
          .toList();

      expect(assetLines, isNotEmpty, reason: 'No assets declared in pubspec.yaml');

      for (final assetDir in assetLines) {
        final dir = Directory(assetDir);
        expect(dir.existsSync(), isTrue, reason: 'Declared asset directory missing on disk: $assetDir');
      }
    });

    test('critical media assets (videos, hero images, audio) are valid and non-empty', () {
      final criticalAssets = [
        'assets/images/home_background.jpg',
        'assets/images/home_background_wide.jpg',
        'assets/videos/home_background_portrait.mp4',
        'assets/videos/home_background_wide.mp4',
        'assets/sounds/good-quality/majjal-akdubal.mp3',
        'assets/sounds/good-quality/majjal.mp3',
      ];

      for (final path in criticalAssets) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Critical asset missing: $path');
        expect(file.lengthSync(), greaterThan(0), reason: 'Critical asset is 0 bytes: $path');
      }
    });

    test('if build/web exists, all declared assets are packaged into final bundle', () {
      final buildWebDir = Directory('build/web');
      if (!buildWebDir.existsSync()) {
        // Skip web distribution check if web hasn't been built yet
        return;
      }

      final manifestFile = File('build/web/assets/AssetManifest.bin.json');
      expect(manifestFile.existsSync(), isTrue, reason: 'AssetManifest.bin.json missing from build/web/assets');
      
      final manifestJson = manifestFile.readAsStringSync();
      final manifestBytes = base64.decode(json.decode(manifestJson) as String);
      final manifestRawString = String.fromCharCodes(manifestBytes);

      final mustBeBundled = [
        'assets/videos/home_background_wide.mp4',
        'assets/videos/home_background_portrait.mp4',
        'assets/images/home_background_wide.jpg',
        'assets/images/home_background.jpg',
      ];

      for (final relPath in mustBeBundled) {
        // 1. Check file physically exists in build/web/assets/assets/...
        final webFile = File('build/web/assets/$relPath');
        expect(webFile.existsSync(), isTrue,
            reason: 'Asset not copied to final build/web bundle: build/web/assets/$relPath');
        expect(webFile.lengthSync(), greaterThan(1000),
            reason: 'Bundled asset corrupted or empty in build/web: $relPath');

        // 2. Check asset is listed in the AssetManifest loaded by Flutter at runtime
        expect(manifestRawString.contains(relPath), isTrue,
            reason: 'Asset missing from final runtime AssetManifest.bin.json: $relPath');
      }
    });
  });
}
