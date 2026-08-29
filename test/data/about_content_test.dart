import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/data/about_content.dart';

void main() {
  group('AboutContent', () {
    test('English content contains story and mentions Ale, Sebi, Riccardo, Antigravity, Flutter', () {
      final en = AboutContent.of(AboutLanguage.english);
      expect(en.storyParagraph, contains('Ale and Sebi'));
      expect(en.storyParagraph, contains('Riccardo'));
      expect(en.storyParagraph, contains('Antigravity'));
      expect(en.storyParagraph, contains('Flutter'));
      expect(en.storyParagraph, contains('Ferrara'));
    });

    test('Italian content contains story and mentions Ale, Sebi, Riccardo, Antigravity, Flutter', () {
      final it = AboutContent.of(AboutLanguage.italian);
      expect(it.storyParagraph, contains('Ale e Sebi'));
      expect(it.storyParagraph, contains('Riccardo'));
      expect(it.storyParagraph, contains('Antigravity'));
      expect(it.storyParagraph, contains('Flutter'));
      expect(it.storyParagraph, contains('Ferrara'));
    });

    test('AboutLinks contains valid https URLs', () {
      expect(AboutLinks.riccardoGithub, startsWith('https://'));
      expect(AboutLinks.antigravity, startsWith('https://'));
      expect(AboutLinks.flutter, startsWith('https://'));
      expect(AboutLinks.repository, startsWith('https://'));
    });
  });
}
