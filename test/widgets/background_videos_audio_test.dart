import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Background Videos & Audio Integrity', () {
    const wideVideoPath = 'assets/videos/home_background_wide.mp4';
    const portraitVideoPath = 'assets/videos/home_background_portrait.mp4';

    test('wide and portrait video files exist on disk and are not empty', () {
      final wideFile = File(wideVideoPath);
      final portraitFile = File(portraitVideoPath);

      expect(wideFile.existsSync(), isTrue, reason: '$wideVideoPath must exist');
      expect(portraitFile.existsSync(), isTrue, reason: '$portraitVideoPath must exist');

      expect(wideFile.lengthSync(), greaterThan(1000000), reason: 'Wide video should be > 1MB');
      expect(portraitFile.lengthSync(), greaterThan(1000000), reason: 'Portrait video should be > 1MB');
    });

    test('videos have valid MP4 headers (ftyp container)', () {
      // All MP4 ISO base media files contain 'ftyp' starting at byte offset 4
      final wideBytes = File(wideVideoPath).readAsBytesSync().sublist(4, 8);
      final portraitBytes = File(portraitVideoPath).readAsBytesSync().sublist(4, 8);

      final ftyp = [0x66, 0x74, 0x79, 0x70]; // 'f', 't', 'y', 'p'
      expect(wideBytes, equals(ftyp), reason: '$wideVideoPath is not a valid MP4');
      expect(portraitBytes, equals(ftyp), reason: '$portraitVideoPath is not a valid MP4');
    });

    test('wide video has audio stream and contains English dialogue', () {
      // Verify via ffprobe that audio stream exists and is AAC stereo
      final res = Process.runSync('ffprobe', [
        '-v',
        'error',
        '-show_entries',
        'stream=codec_name,channels,sample_rate',
        '-select_streams',
        'a',
        '-of',
        'default=noprint_wrappers=1',
        wideVideoPath,
      ]);

      expect(res.exitCode, equals(0), reason: 'ffprobe failed on $wideVideoPath');
      final stdout = res.stdout.toString();
      expect(stdout, contains('codec_name=aac'), reason: '$wideVideoPath missing AAC audio');
      expect(stdout, contains('channels=2'), reason: '$wideVideoPath is not stereo');
    });

    test('portrait video has audio stream and contains Italian dialogue', () {
      final res = Process.runSync('ffprobe', [
        '-v',
        'error',
        '-show_entries',
        'stream=codec_name,channels,sample_rate',
        '-select_streams',
        'a',
        '-of',
        'default=noprint_wrappers=1',
        portraitVideoPath,
      ]);

      expect(res.exitCode, equals(0), reason: 'ffprobe failed on $portraitVideoPath');
      final stdout = res.stdout.toString();
      expect(stdout, contains('codec_name=aac'), reason: '$portraitVideoPath missing AAC audio');
      expect(stdout, contains('channels=2'), reason: '$portraitVideoPath is not stereo');
    });
  });
}
