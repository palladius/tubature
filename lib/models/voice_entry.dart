import 'package:equatable/equatable.dart';

/// Represents a voice line in the game catalog
class VoiceEntry extends Equatable {
  final String id;
  final String folder; // 'good', 'bad', or 'vetted'
  final String path; // e.g. 'assets/sounds/good-quality/ascor_mid_low_4st.mp3'
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
  bool get isGood => folder == 'good' || category == 'victory' || category == 'easter_egg';
  bool get isBad => folder == 'bad' || category == 'failure';

  @override
  List<Object?> get props => [id, folder, path, category, displayName, meaningIt, requiredAmpollaCount];
}

/// Catalog containing all registered game voice lines categorized by folder
class VoiceCatalog {
  static const List<VoiceEntry> allVoices = [
    // Good / Victory pool (Vetted Quality)
    VoiceEntry(
      id: 'ascor_mid_low_4st',
      folder: 'good',
      path: 'assets/sounds/good-quality/ascor_mid_low_4st.mp3',
      category: 'victory',
      displayName: "A scòr ch'l'è un piaśér!",
      meaningIt: "Scorre che è una meraviglia! (Vetted)",
    ),
    VoiceEntry(
      id: 'movache_mid_low_4st',
      folder: 'good',
      path: 'assets/sounds/good-quality/movache_mid_low_4st.mp3',
      category: 'victory',
      displayName: "Mo và che tubatùra!",
      meaningIt: "Ma guarda che impianto a regola d'arte! (Vetted)",
    ),
    VoiceEntry(
      id: 'mo-va-che-tubatura',
      folder: 'good',
      path: 'assets/sounds/good-quality/mo-va-che-tubatura.mp3',
      category: 'victory',
      displayName: "Mo và che tubatùra (Classic)",
      meaningIt: "Ma guarda che impianto!",
    ),
    VoiceEntry(
      id: 'mayal-ac-du-bal',
      folder: 'good',
      path: 'assets/sounds/good-quality/mayal-akdubal.mp3',
      category: 'easter_egg',
      displayName: "Mayàl, ac du bàl!",
      meaningIt: "Maiale, che due palle! (2 ampolle!)",
      requiredAmpollaCount: 2,
    ),
    VoiceEntry(
      id: 'maial_basso_5st_fast_b',
      folder: 'good',
      path: 'assets/sounds/good-quality/maial_basso_5st_fast_b.mp3',
      category: 'easter_egg',
      displayName: "Mayàl! (Basso 5st)",
      meaningIt: "Maiale! (Versione Bassa Veloce)",
      requiredAmpollaCount: 2,
    ),
    VoiceEntry(
      id: 'maial_rel_1_raw',
      folder: 'good',
      path: 'assets/sounds/good-quality/maial_rel_1_raw.mp3',
      category: 'easter_egg',
      displayName: "Mayàl, ac du bàl! (Raw)",
      meaningIt: "Maiale, che due palle! (Original Take)",
      requiredAmpollaCount: 2,
    ),

    // Bad / Failure pool (Vetted Quality)
    VoiceEntry(
      id: 'ack_giurnadaza_tuned',
      folder: 'bad',
      path: 'assets/sounds/good-quality/ack_giurnadaza_tuned.mp3',
      category: 'failure',
      displayName: "Ac giurnadàza!",
      meaningIt: "Che giornataccia faticosa! (Vetted)",
    ),
    VoiceEntry(
      id: 'non-capisci-proprio-un-tubo',
      folder: 'bad',
      path: 'assets/sounds/good-quality/non-capisci-proprio-un-tubo.mp3',
      category: 'failure',
      displayName: "Non capisci proprio un tubo!",
      meaningIt: "Non capisci niente! (Vetted)",
    ),
    VoiceEntry(
      id: 'non-capisci-un-tubo',
      folder: 'bad',
      path: 'assets/sounds/good-quality/non-capisci-un-tubo.mp3',
      category: 'failure',
      displayName: "Non capisci un tubo!",
      meaningIt: "Non capisci un tubo! (Vetted)",
    ),
    VoiceEntry(
      id: 'elsa_corto_20',
      folder: 'bad',
      path: 'assets/sounds/good-quality/elsa_corto_20.mp3',
      category: 'failure',
      displayName: "Non capisci un tubo (Elsa)",
      meaningIt: "Non capisci un tubo! (Voce Elsa)",
    ),
    VoiceEntry(
      id: 'isabella_15',
      folder: 'bad',
      path: 'assets/sounds/good-quality/isabella_15.mp3',
      category: 'failure',
      displayName: "Non capisci un tubo (Isabella)",
      meaningIt: "Non capisci un tubo! (Voce Isabella)",
    ),

    // ─── ALESSANDRO VERLATO — Fancy Pixel (Portomaggiore) ───
    // Human-recorded ferrarese dialect, trimmed & converted. Issue #4
    VoiceEntry(
      id: 'ale-piaser-1',
      folder: 'good',
      path: 'assets/voices/good/piaser_1.mp3',
      category: 'victory',
      displayName: "Piaśér! (Ale v1)",
      meaningIt: "Piacere! — Alessandro Verlato (Fancy Pixel)",
    ),
    VoiceEntry(
      id: 'ale-piaser-2',
      folder: 'good',
      path: 'assets/voices/good/piaser_2.mp3',
      category: 'victory',
      displayName: "Piaśér! (Ale v2)",
      meaningIt: "Piacere! — Alessandro Verlato (Fancy Pixel)",
    ),
    VoiceEntry(
      id: 'ale-piaser-3',
      folder: 'good',
      path: 'assets/voices/good/piaser_3.mp3',
      category: 'victory',
      displayName: "Piaśér! (Ale v3)",
      meaningIt: "Piacere! — Alessandro Verlato (Fancy Pixel)",
    ),
    VoiceEntry(
      id: 'ale-piaser-4',
      folder: 'good',
      path: 'assets/voices/good/piaser_4.mp3',
      category: 'victory',
      displayName: "Piaśér! (Ale v4)",
      meaningIt: "Piacere! — Alessandro Verlato (Fancy Pixel)",
    ),
    VoiceEntry(
      id: 'ale-tubatura-1',
      folder: 'good',
      path: 'assets/voices/good/tubatura_1.mp3',
      category: 'victory',
      displayName: "Mo' và che tubatùra! (Ale v1)",
      meaningIt: "Che tubatura! — Alessandro Verlato (Fancy Pixel)",
    ),
    VoiceEntry(
      id: 'ale-tubatura-2',
      folder: 'good',
      path: 'assets/voices/good/tubatura_2.mp3',
      category: 'victory',
      displayName: "Mo' và che tubatùra! (Ale v2)",
      meaningIt: "Che tubatura! — Alessandro Verlato (Fancy Pixel)",
    ),
    VoiceEntry(
      id: 'ale-tubatura-3',
      folder: 'good',
      path: 'assets/voices/good/tubatura_3.mp3',
      category: 'victory',
      displayName: "Mo' và che tubatùra! (Ale v3)",
      meaningIt: "Che tubatura! — Alessandro Verlato (Fancy Pixel)",
    ),
    VoiceEntry(
      id: 'ale-tubatura-4',
      folder: 'good',
      path: 'assets/voices/good/tubatura_4.mp3',
      category: 'victory',
      displayName: "Mo' và che tubatùra! (Ale v4)",
      meaningIt: "Che tubatura! — Alessandro Verlato (Fancy Pixel)",
    ),
    VoiceEntry(
      id: 'ale-do-bal-1',
      folder: 'good',
      path: 'assets/voices/good/do_bal_1.mp3',
      category: 'easter_egg',
      displayName: "Do bàl! (Ale v1)",
      meaningIt: "Due palle! — Alessandro Verlato (Fancy Pixel)",
      requiredAmpollaCount: 2,
    ),
    VoiceEntry(
      id: 'ale-do-bal-2',
      folder: 'good',
      path: 'assets/voices/good/do_bal_2.mp3',
      category: 'easter_egg',
      displayName: "Do bàl! (Ale v2)",
      meaningIt: "Due palle! — Alessandro Verlato (Fancy Pixel)",
      requiredAmpollaCount: 2,
    ),
    VoiceEntry(
      id: 'ale-giurnadaza-1',
      folder: 'bad',
      path: 'assets/voices/bad/giurnadaza_1.mp3',
      category: 'failure',
      displayName: "Ac giurnadàza! (Ale v1)",
      meaningIt: "Che giornataccia! — Alessandro Verlato (Fancy Pixel)",
    ),
    VoiceEntry(
      id: 'ale-giurnadaza-2',
      folder: 'bad',
      path: 'assets/voices/bad/giurnadaza_2.mp3',
      category: 'failure',
      displayName: "Ac giurnadàza! (Ale v2)",
      meaningIt: "Che giornataccia! — Alessandro Verlato (Fancy Pixel)",
    ),
  ];

  /// Pick a voice line on puzzle completion
  /// If [ampollaCount] == 2, returns the "Mayàl, ac du bàl!" easter egg.
  static VoiceEntry pickVictoryVoice({int ampollaCount = 0, int? randomIndex}) {
    if (ampollaCount == 2) {
      final easterEggs = allVoices.where((v) => v.isEasterEgg).toList();
      final idx = (randomIndex ?? DateTime.now().millisecondsSinceEpoch) % easterEggs.length;
      return easterEggs[idx];
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
