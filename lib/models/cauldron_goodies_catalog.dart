import 'cauldron_goodie.dart';

class CauldronGoodiesCatalog {
  static const List<CauldronGoodie> standardGoodies = [
    CauldronGoodie(
      id: 'ruby',
      assetPath: 'assets/goodies/ruby.png',
      displayName: 'Ruby',
      emoji: '💎',
    ),
    CauldronGoodie(
      id: 'dragon',
      assetPath: 'assets/goodies/dragon.png',
      displayName: 'Dragon',
      emoji: '🐉',
    ),
    CauldronGoodie(
      id: 'unicorn',
      assetPath: 'assets/goodies/unicorn.png',
      displayName: 'Unicorn',
      emoji: '🦄',
    ),
    CauldronGoodie(
      id: 'hotwheel',
      assetPath: 'assets/goodies/hotwheel.png',
      displayName: 'Hotwheel',
      emoji: '🏎️',
    ),
    CauldronGoodie(
      id: 'alessandro',
      assetPath: 'assets/goodies/alessandro.png',
      displayName: 'Alessandro',
      emoji: '🧑',
    ),
    CauldronGoodie(
      id: 'sebi',
      assetPath: 'assets/goodies/sebi.png',
      displayName: 'Sebi',
      emoji: '👦',
    ),
    CauldronGoodie(
      id: 'papino',
      assetPath: 'assets/goodies/papino.png',
      displayName: 'Papino',
      emoji: '👨',
    ),
    CauldronGoodie(
      id: 'wizard',
      assetPath: 'assets/goodies/wizard.png',
      displayName: 'Wizard',
      emoji: '🧙',
    ),
  ];

  static const List<CauldronGoodie> legendary = [
    CauldronGoodie(
      id: 'schmoogle',
      assetPath: 'assets/goodies/schmoogle.png',
      displayName: 'Schmoogle',
      emoji: '👻',
      isLegendary: true,
    ),
  ];

  static List<CauldronGoodie> get all => [...standardGoodies, ...legendary];
}
