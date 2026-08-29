/// Content and translations for the About Dialog in Tubature.
/// Editable file for easy text, story, translation, and link updates.
library;

enum AboutLanguage {
  english(code: 'en', label: 'English', flagEmoji: '🇬🇧'),
  italian(code: 'it', label: 'Italiano', flagEmoji: '🇮🇹');

  final String code;
  final String label;
  final String flagEmoji;

  const AboutLanguage({
    required this.code,
    required this.label,
    required this.flagEmoji,
  });
}

class AboutLinks {
  static const String riccardoGithub = 'https://github.com/palladius';
  static const String antigravity = 'https://antigravity.google/';
  static const String flutter = 'https://flutter.dev/';
  static const String repository = 'https://github.com/palladius/tubature';
}

class AboutContent {
  final String title;
  final String subtitle;
  final String storyParagraph;
  final String createdFor;
  final String techStackBadge;
  final String openSourceNote;
  final String closeButton;

  const AboutContent({
    required this.title,
    required this.subtitle,
    required this.storyParagraph,
    required this.createdFor,
    required this.techStackBadge,
    required this.openSourceNote,
    required this.closeButton,
  });

  static const Map<AboutLanguage, AboutContent> translations = {
    AboutLanguage.english: AboutContent(
      title: 'About Tubature',
      subtitle: 'The Dungeon Plumbers 🐉🚰',
      storyParagraph:
          'Tubature was created for Ale and Sebi to provide a free game with a twist of Ferrara meets Mario pipe-puzzle game. '
          'This was created by Riccardo as a weekend project with Antigravity and Flutter.',
      createdFor: 'Made with ❤️ for Alessandro & Sebastiano',
      techStackBadge: 'Built with Google Antigravity & Flutter',
      openSourceNote: 'Free & Open Source on GitHub',
      closeButton: 'Close',
    ),
    AboutLanguage.italian: AboutContent(
      title: 'Informazioni su Tubature',
      subtitle: 'Gli Idraulici del Dungeon 🐉🚰',
      storyParagraph:
          'Tubature è stato creato per Ale e Sebi come gioco gratuito con un tocco di Ferrara che incontra Super Mario in un puzzle game d\'ingegno idraulico. '
          'È stato creato da Riccardo come progetto del weekend con Antigravity e Flutter.',
      createdFor: 'Fatto con ❤️ per Alessandro e Sebastiano',
      techStackBadge: 'Sviluppato con Google Antigravity & Flutter',
      openSourceNote: 'Gratuito e Open Source su GitHub',
      closeButton: 'Chiudi',
    ),
  };

  static AboutContent of(AboutLanguage language) =>
      translations[language] ?? translations[AboutLanguage.english]!;
}
