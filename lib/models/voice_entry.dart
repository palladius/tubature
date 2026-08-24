import 'package:equatable/equatable.dart';

/// Represents a voice line in the game catalog
class VoiceEntry extends Equatable {
  final String id;
  final String folder; // 'good' or 'bad'
  final String path; // e.g. 'assets/voices/good/mayal-ac-du-bal.mp3'
  final String category; // 'victory', 'easter_egg', 'failure'
  final String displayName; // Dialect line: "Mayàl, ac du bàl!"
  final String meaningIt; // Italian translation: "Maiale, che due palle!"
  final int? requiredAmpollaCount; // e.g. 2 for mayal-ac-du-bal

  const VoiceEntry({
    required this.id,
    required this.folder,
    required this.path,
    required this.category,
    required this.displayName,
    required this.meaningIt,
    this.requiredAmpollaCount,
  });

  bool get isEasterEgg => category == 'easter_egg';
  bool get isGood => folder == 'good';
  bool get isBad => folder == 'bad';

  @override
  List<Object?> get props => [id, folder, path, category, displayName, meaningIt, requiredAmpollaCount];
}

/// Catalog containing all registered game voice lines categorized by folder
class VoiceCatalog {
  static const List<VoiceEntry> allVoices = [
    // Good / Victory pool
    VoiceEntry(
      id: 'a-scor-cle-un-piaser',
      folder: 'good',
      path: 'assets/voices/good/a-scor-cle-un-piaser.mp3',
      category: 'victory',
      displayName: "A scòr ch'l'è un piaśér!",
      meaningIt: "Scorre che è una meraviglia!",
    ),
    VoiceEntry(
      id: 'a-scor-cle-un-piaser-low',
      folder: 'good',
      path: 'assets/voices/good/a-scor-cle-un-piaser-low.mp3',
      category: 'victory',
      displayName: "A scòr ch'l'è un piaśér!",
      meaningIt: "Scorre che è un piacere!",
    ),
    VoiceEntry(
      id: 'mo-va-che-tubatura',
      folder: 'good',
      path: 'assets/voices/good/mo-va-che-tubatura.mp3',
      category: 'victory',
      displayName: "Mo và che tubatùra!",
      meaningIt: "Ma guarda che impianto a regola d'arte!",
    ),
    VoiceEntry(
      id: 'mayal-ac-du-bal',
      folder: 'good',
      path: 'assets/voices/good/mayal-ac-du-bal.mp3',
      category: 'easter_egg',
      displayName: "Mayàl, ac du bàl!",
      meaningIt: "Maiale, che due palle! (2 ampolle!)",
      requiredAmpollaCount: 2,
    ),

    // Bad / Failure pool
    VoiceEntry(
      id: 'ac-giurnadaza',
      folder: 'bad',
      path: 'assets/voices/bad/ac-giurnadaza.mp3',
      category: 'failure',
      displayName: "Ac giurnadàza!",
      meaningIt: "Che giornataccia faticosa!",
    ),
    VoiceEntry(
      id: 'non-capisci-proprio-un-tubo',
      folder: 'bad',
      path: 'assets/voices/bad/non-capisci-proprio-un-tubo.mp3',
      category: 'failure',
      displayName: "Non capisci proprio un tubo!",
      meaningIt: "Non capisci niente!",
    ),
    VoiceEntry(
      id: 'non-capisci-un-tubo',
      folder: 'bad',
      path: 'assets/voices/bad/non-capisci-un-tubo.mp3',
      category: 'failure',
      displayName: "Non capisci un tubo!",
      meaningIt: "Non capisci un tubo!",
    ),
  ];

  /// Pick a voice line on puzzle completion
  /// If [ampollaCount] == 2, returns the "Mayàl, ac du bàl!" easter egg.
  static VoiceEntry pickVictoryVoice({int ampollaCount = 0, int? randomIndex}) {
    if (ampollaCount == 2) {
      final easterEgg = allVoices.firstWhere(
        (v) => v.id == 'mayal-ac-du-bal',
        orElse: () => allVoices.first,
      );
      return easterEgg;
    }

    final goodVoices = allVoices.where((v) => v.isGood && !v.isEasterEgg).toList();
    if (goodVoices.isEmpty) return allVoices.first;

    final index = (randomIndex ?? DateTime.now().millisecondsSinceEpoch) % goodVoices.length;
    return goodVoices[index];
  }

  /// Pick a voice line on failure / reset
  static VoiceEntry pickFailureVoice({int? randomIndex}) {
    final badVoices = allVoices.where((v) => v.isBad).toList();
    if (badVoices.isEmpty) return allVoices.first;

    final index = (randomIndex ?? DateTime.now().millisecondsSinceEpoch) % badVoices.length;
    return badVoices[index];
  }
}
