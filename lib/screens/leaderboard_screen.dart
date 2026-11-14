import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logic/puffin_login.dart';

/// Tubature Hall of Fame Screen & Dialog (`PuffinLeaderboardWidget` + Puffin Login Ring link).
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  static Future<void> showModal(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 620),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: const LeaderboardScreen(),
          ),
        ),
      ),
    );
  }

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _filterGame = kTubatureAppId;

  @override
  void initState() {
    super.initState();
    PuffinLogin.instance.syncScoresFromCloud(gameFilter: _filterGame);
  }

  Future<void> _openPuffinRing() async {
    final uri = Uri.parse('https://palladius.github.io/tubature/ring.html');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _backToGame(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PuffinLogin.instance,
      builder: (context, _) {
        final showDebug = PuffinLogin.instance.showDebugScores;
        final isIt = PuffinLogin.instance.lang == 'it';
        final debugCount = PuffinLogin.instance.getHiddenDebugCount(gameId: _filterGame);

        return Scaffold(
          backgroundColor: const Color(0xFF0A0D1A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF121528),
            foregroundColor: Colors.white,
            titleSpacing: 4,
            leadingWidth: 88,
            leading: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: TextButton.icon(
                key: const Key('hof_back_to_game_btn'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                onPressed: () => _backToGame(context),
                icon: const Icon(Icons.arrow_back_rounded, size: 15, color: Color(0xFF6EE7B7)),
                label: Text(
                  isIt ? 'Gioco' : 'Game',
                  style: const TextStyle(
                    color: Color(0xFF6EE7B7),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            title: const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '🏆 Hall of Fame',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(48, 36),
                ),
                onPressed: _openPuffinRing,
                icon: const Text('🔥💍', style: TextStyle(fontSize: 12)),
                label: const Text(
                  'Ring',
                  style: TextStyle(
                    color: Color(0xFFFACC15),
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5,
                  ),
                ),
              ),
              const PuffinLoginBadge(reserveWebSpace: false),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildFilterChip(
                          label: '🚰 Tubature',
                          value: kTubatureAppId,
                        ),
                        _buildFilterChip(
                          label: '🌍 All Family Games',
                          value: 'ALL',
                        ),
                        ActionChip(
                          key: const Key('hof_debug_toggle_chip'),
                          backgroundColor: showDebug
                              ? const Color(0xFF164E63)
                              : const Color(0xFF181C36),
                          side: BorderSide(
                            color: showDebug
                                ? const Color(0xFF22D3EE)
                                : Colors.white24,
                          ),
                          label: Text(
                            showDebug
                                ? '🧪 Debug UAT/Demo: ON ($debugCount)'
                                : '🧪 Debug UAT/Demo: OFF ($debugCount)',
                            style: TextStyle(
                              color: showDebug
                                  ? const Color(0xFF67E8F9)
                                  : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                            ),
                          ),
                          onPressed: () {
                            PuffinLogin.instance.toggleShowDebugScores();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: PuffinLeaderboardWidget(
                        filterGame: _filterGame,
                        limit: kTopTenLimit,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const Key('hof_bottom_back_to_game_btn'),
                        onPressed: () => _backToGame(context),
                        icon: const Icon(
                          Icons.sports_esports_rounded,
                          size: 18,
                          color: Color(0xFF6EE7B7),
                        ),
                        label: Text(
                          isIt ? '⬅️ Torna al Gioco (/)' : '⬅️ Back to Game (/)',
                          style: const TextStyle(
                            color: Color(0xFF6EE7B7),
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF121528),
                          side: const BorderSide(color: Color(0xFF34D399), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({required String label, required String value}) {
    final selected = _filterGame == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFF0A0C16) : Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFFFACC15),
      backgroundColor: const Color(0xFF181C36),
      onSelected: (_) {
        setState(() {
          _filterGame = value;
        });
        PuffinLogin.instance.syncScoresFromCloud(gameFilter: value);
      },
    );
  }
}
