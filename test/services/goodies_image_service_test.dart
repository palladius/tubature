import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/services/goodies_image_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('GoodiesImageService', () {
    setUp(() {
      GoodiesImageService.clearCache();
    });

    test('getImage returns null before preload', () {
      expect(GoodiesImageService.getImage('test_id'), isNull);
    });

    test('preloadImages handles empty list', () async {
      await GoodiesImageService.preloadImages([]);
      expect(GoodiesImageService.getImage('test_id'), isNull);
    });

    test('clearCache works', () {
      GoodiesImageService.clearCache();
      expect(GoodiesImageService.getImage('test_id'), isNull);
    });
  });
}
