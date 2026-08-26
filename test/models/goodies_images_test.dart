import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/models/cauldron_goodies_catalog.dart';

/// WHY: We had a bug where all .png files were actually JPEG files with a .png
/// extension. Some browsers (especially mobile) refused to render them, showing
/// emoji fallback instead. This test ensures every goodie asset:
/// 1. EXISTS on disk
/// 2. Has a valid PNG header (magic bytes: 89 50 4E 47 = \x89PNG)
/// 3. Is not empty
/// See: GitHub issue — broken emoji on mobile v2.7.1
void main() {
  group('Goodies Image Assets', () {
    test('all goodie asset files exist on disk', () {
      for (final goodie in CauldronGoodiesCatalog.all) {
        final file = File(goodie.assetPath);
        expect(file.existsSync(), isTrue,
            reason: 'Asset missing: ${goodie.assetPath} (${goodie.displayName})');
      }
    });

    test('all goodie asset files are not empty', () {
      for (final goodie in CauldronGoodiesCatalog.all) {
        final file = File(goodie.assetPath);
        final size = file.lengthSync();
        expect(size, greaterThan(0),
            reason: 'Asset empty: ${goodie.assetPath} (${goodie.displayName})');
      }
    });

    test('all .png goodie assets have valid PNG header (not JPEG!)', () {
      // WHY: Gemini image generation outputs JPEG, which we save as .png.
      // Some browsers silently accept JPEG-in-PNG, others show broken image.
      // PNG magic bytes: 0x89 0x50 0x4E 0x47 (\x89PNG)
      const pngMagic = [0x89, 0x50, 0x4E, 0x47]; // \x89PNG

      for (final goodie in CauldronGoodiesCatalog.all) {
        if (!goodie.assetPath.endsWith('.png')) continue;

        final file = File(goodie.assetPath);
        final bytes = file.readAsBytesSync();
        final header = bytes.sublist(0, 4);

        expect(header, equals(pngMagic),
            reason:
                '${goodie.assetPath} is NOT a valid PNG! '
                'Header: ${header.map((b) => "0x${b.toRadixString(16).padLeft(2, "0")}").join(" ")}. '
                'This was likely a JPEG saved as .png — convert with: '
                'sips -s format png ${goodie.assetPath} --out ${goodie.assetPath}');
      }
    });

    test('all goodie IDs are unique', () {
      final ids = CauldronGoodiesCatalog.all.map((g) => g.id).toList();
      expect(ids.toSet().length, equals(ids.length),
          reason: 'Duplicate goodie IDs found!');
    });

    test('all goodie asset paths are unique', () {
      final paths = CauldronGoodiesCatalog.all.map((g) => g.assetPath).toList();
      expect(paths.toSet().length, equals(paths.length),
          reason: 'Duplicate asset paths found!');
    });
  });
}
