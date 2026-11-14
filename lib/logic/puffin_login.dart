import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'puffin_bridge_stub.dart'
    if (dart.library.js_interop) 'puffin_bridge_web.dart';

const String kPuffinSalt = 'puffin-salt-2026';
const String kDefaultCloudApiUrl =
    'https://puffin-login-932724269481.europe-west1.run.app/v1';
const String kTubatureAppId = 'tubature';

const int kMaxFailedAttempts = 3;
const int kJamCooldownMs = 45000;
const int kTopTenLimit = 10;

class PuffinStorageKeys {
  static const String auth = 'puffin_auth_v2';
  static const String lang = 'puffin_lang_v1';
  static const String scores = 'puffin_scores_v2';
  static const String showDebugScores = 'puffin_show_debug_scores_v1';
  static const String states = 'puffin_states_v1';
  static const String outbox = 'puffin_outbox_v1';
  static const String lockout = 'puffin_lockout_v1';
}

/// Pure-Dart RFC 6234 SHA-256 implementation so PuffinLogin has zero external pub dependencies.
String _sha256Hex(List<int> bytes) {
  const List<int> k = <int>[
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
  ];

  int rotr(int x, int n) => ((x & 0xffffffff) >>> n) | ((x << (32 - n)) & 0xffffffff);

  final int bitLen = bytes.length * 8;
  final List<int> msg = List<int>.from(bytes)..add(0x80);
  while ((msg.length % 64) != 56) {
    msg.add(0);
  }
  final bd = ByteData(8)..setUint64(0, bitLen, Endian.big);
  for (int i = 0; i < 8; i++) {
    msg.add(bd.getUint8(i));
  }

  int h0 = 0x6a09e667;
  int h1 = 0xbb67ae85;
  int h2 = 0x3c6ef372;
  int h3 = 0xa54ff53a;
  int h4 = 0x510e527f;
  int h5 = 0x9b05688c;
  int h6 = 0x1f83d9ab;
  int h7 = 0x5be0cd19;

  final List<int> w = List<int>.filled(64, 0);

  for (int offset = 0; offset < msg.length; offset += 64) {
    for (int i = 0; i < 16; i++) {
      final int j = offset + i * 4;
      w[i] = ((msg[j] & 0xff) << 24) |
          ((msg[j + 1] & 0xff) << 16) |
          ((msg[j + 2] & 0xff) << 8) |
          (msg[j + 3] & 0xff);
    }
    for (int i = 16; i < 64; i++) {
      final int s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ ((w[i - 15] & 0xffffffff) >>> 3);
      final int s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ ((w[i - 2] & 0xffffffff) >>> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
    }

    int a = h0;
    int b = h1;
    int c = h2;
    int d = h3;
    int e = h4;
    int f = h5;
    int g = h6;
    int h = h7;

    for (int i = 0; i < 64; i++) {
      final int s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
      final int ch = (e & f) ^ ((~e & 0xffffffff) & g);
      final int temp1 = (h + s1 + ch + k[i] + w[i]) & 0xffffffff;
      final int s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
      final int maj = (a & b) ^ (a & c) ^ (b & c);
      final int temp2 = (s0 + maj) & 0xffffffff;

      h = g;
      g = f;
      f = e;
      e = (d + temp1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) & 0xffffffff;
    }

    h0 = (h0 + a) & 0xffffffff;
    h1 = (h1 + b) & 0xffffffff;
    h2 = (h2 + c) & 0xffffffff;
    h3 = (h3 + d) & 0xffffffff;
    h4 = (h4 + e) & 0xffffffff;
    h5 = (h5 + f) & 0xffffffff;
    h6 = (h6 + g) & 0xffffffff;
    h7 = (h7 + h) & 0xffffffff;
  }

  String hex32(int v) => (v & 0xffffffff).toRadixString(16).padLeft(8, '0');
  return '${hex32(h0)}${hex32(h1)}${hex32(h2)}${hex32(h3)}'
      '${hex32(h4)}${hex32(h5)}${hex32(h6)}${hex32(h7)}';
}

/// Computes salted SHA-256 hex digest `SHA-256("puffin-salt-2026:<userId>:<plainSecret>")`
/// so plaintext passwords NEVER appear in source code!
String computePuffinSecretHash(String userId, String plainSecret) {
  final input = '$kPuffinSalt:${userId.trim().toLowerCase()}:${plainSecret.trim()}';
  return _sha256Hex(utf8.encode(input));
}

/// Computes the canonical Tubature level victory score.
int calculateTubatureScore({
  required String difficulty,
  required int totalTiles,
  required int moves,
  required int levelsCompleted,
}) {
  final diffLower = difficulty.trim().toLowerCase();
  final baseScore = diffLower == 'hard'
      ? 3500
      : diffLower == 'medium'
          ? 2200
          : 1200;
  final tiles = math.max(1, totalTiles);
  final safeMoves = math.max(1, moves);
  final efficiencyBonus = math.max(100, (tiles * 3 - safeMoves) * 35);
  final streakBonus = math.max(0, levelsCompleted) * 300;
  return baseScore + efficiencyBonus + streakBonus;
}

class PuffinProfile {
  final String? id;
  final List<String> aliases;
  final String displayName;
  final String displayNameEn;
  final String shortName;
  final String rpgClass;
  final String emoji;
  final String role; // 'adult' | 'kid' | 'guest' | 'bot' | 'null'
  final String authType; // 'password' | 'pin4' | 'none'
  final String secretHash;
  final String email;
  final String colorName;
  final String colorHex;
  final Color color;
  final String avatarAsset;

  const PuffinProfile({
    required this.id,
    required this.aliases,
    required this.displayName,
    required this.displayNameEn,
    required this.shortName,
    required this.rpgClass,
    required this.emoji,
    required this.role,
    required this.authType,
    required this.secretHash,
    required this.email,
    required this.colorName,
    required this.colorHex,
    required this.color,
    required this.avatarAsset,
  });
}

const List<PuffinProfile> kPuffinProfiles = <PuffinProfile>[
  PuffinProfile(
    id: 'riccardo',
    aliases: <String>['papino', 'ricc'],
    displayName: 'Papino Riccardo',
    displayNameEn: 'Dad Riccardo',
    shortName: 'Riccardo',
    rpgClass: 'Paladin',
    emoji: '👑',
    role: 'adult',
    authType: 'password',
    secretHash: 'bbad2523d48656e6eac389d4e69455244258b9be4c206dcf1cd1c9ac6cadc8f8',
    email: 'palladiusbonton@gmail.com',
    colorName: 'Giallo',
    colorHex: '#FACC15',
    color: Color(0xFFFACC15),
    avatarAsset: 'assets/avatars/riccardo.png',
  ),
  PuffinProfile(
    id: 'kate',
    aliases: <String>['mamma'],
    displayName: 'Mamma Kate',
    displayNameEn: 'Mum Kate',
    shortName: 'Kate',
    rpgClass: 'Archmage',
    emoji: '💜',
    role: 'adult',
    authType: 'password',
    secretHash: 'cc931f6c000b1450f5c5dd66c9fa43c602786a1bed164311b17a11900521f679',
    email: 'kateknight1981@gmail.com',
    colorName: 'Viola',
    colorHex: '#A855F7',
    color: Color(0xFFA855F7),
    avatarAsset: 'assets/avatars/kate.png',
  ),
  PuffinProfile(
    id: 'ale',
    aliases: <String>['alessandro'],
    displayName: 'Alessandro (Ale)',
    displayNameEn: 'Alessandro (Ale)',
    shortName: 'Ale',
    rpgClass: 'Dragon Ranger',
    emoji: '🐉',
    role: 'kid',
    authType: 'pin4',
    secretHash: 'ac05dc85bcc7ab7b461a3c9f029d602d40e271715b131474282cef104ee19d23',
    email: 'alessandrocarlesso18@gmail.com',
    colorName: 'Rosso',
    colorHex: '#EF4444',
    color: Color(0xFFEF4444),
    avatarAsset: 'assets/avatars/ale.png',
  ),
  PuffinProfile(
    id: 'seby',
    aliases: <String>['sebi', 'sebastian'],
    displayName: 'Sebastian (Seby)',
    displayNameEn: 'Sebastian (Seby)',
    shortName: 'Seby',
    rpgClass: 'Speedster Knight',
    emoji: '🏎️',
    role: 'kid',
    authType: 'pin4',
    secretHash: 'c1052cf2c1eba8d67b240680e47243cb13e5f43a05e4fcbb33f72206f02266e6',
    email: 'sebastiancarlesso20@gmail.com',
    colorName: 'Blu',
    colorHex: '#3B82F6',
    color: Color(0xFF3B82F6),
    avatarAsset: 'assets/avatars/seby.png',
  ),
  PuffinProfile(
    id: 'lucilla',
    aliases: <String>['nonna', 'nonnalucilla'],
    displayName: 'Nonna Lucilla',
    displayNameEn: 'Grandma Lucilla',
    shortName: 'Nonna',
    rpgClass: 'Owl Bard',
    emoji: '🌸',
    role: 'adult',
    authType: 'password',
    secretHash: '01e66314c5c31aeda5ba8861abbbe79c31498fb76a31599cfd54c59f163c78d4',
    email: 'lucillagennari@gmail.com',
    colorName: 'Rosa',
    colorHex: '#EC4899',
    color: Color(0xFFEC4899),
    avatarAsset: 'assets/avatars/lucilla.png',
  ),
  PuffinProfile(
    id: 'guest',
    aliases: <String>['ospite', 'anonymous'],
    displayName: 'Guest / Ospite',
    displayNameEn: 'Guest',
    shortName: 'Guest',
    rpgClass: 'Puffin Rogue',
    emoji: '🐧',
    role: 'guest',
    authType: 'none',
    secretHash: '',
    email: '',
    colorName: 'Grigio',
    colorHex: '#9CA3AF',
    color: Color(0xFF9CA3AF),
    avatarAsset: 'assets/avatars/guest.png',
  ),
];

/// 7th dedicated profile for Antigravity UAT Bot (`saga`).
const PuffinProfile kSagaBotProfile = PuffinProfile(
  id: 'saga',
  aliases: <String>['gemini', 'uat', 'bot', 'agy', 'saga-gemini'],
  displayName: 'bot (Saga di Gemini UAT)',
  displayNameEn: 'bot (Gemini Saga UAT)',
  shortName: 'bot',
  rpgClass: 'Gold Saint Bot • UAT',
  emoji: '♊',
  role: 'bot',
  authType: 'password',
  secretHash: '5ac3918812d0e665b215336daca02dea39b9908ae3169b2cc2e7774c50706893',
  email: 'palladiusbonton+saga-uat@gmail.com',
  colorName: 'Ciano Cosmo',
  colorHex: '#22D3EE',
  color: Color(0xFF22D3EE),
  avatarAsset: 'assets/avatars/saga.png',
);

const List<PuffinProfile> kAllPuffinProfiles = <PuffinProfile>[
  ...kPuffinProfiles,
  kSagaBotProfile,
];

const PuffinProfile kNullPlayerProfile = PuffinProfile(
  id: null,
  aliases: <String>[],
  displayName: 'Guest',
  displayNameEn: 'Guest',
  shortName: 'Guest',
  rpgClass: 'Mystery Wanderer',
  emoji: '',
  role: 'null',
  authType: 'none',
  secretHash: '',
  email: '',
  colorName: 'Slate',
  colorHex: '#9CA3AF',
  color: Color(0xFF9CA3AF),
  avatarAsset: 'assets/avatars/guest.png',
);

String? normalizePuffinProfileId(Object? rawId, {bool allowNull = false}) {
  if (rawId == null) return null;
  final clean = rawId.toString().trim().toLowerCase();
  if (clean.isEmpty || clean == 'null') return null;
  for (final p in kAllPuffinProfiles) {
    if (p.id == clean || p.aliases.contains(clean) || p.shortName.toLowerCase() == clean) {
      return p.id;
    }
  }
  return allowNull ? null : 'guest';
}

PuffinProfile getPuffinProfileById(Object? rawId) {
  final id = normalizePuffinProfileId(rawId, allowNull: true);
  if (id == null) return kNullPlayerProfile;
  for (final p in kAllPuffinProfiles) {
    if (p.id == id) return p;
  }
  return kPuffinProfiles.first;
}

class PuffinScoreRecord {
  final String id;
  final String gameId;
  final String? playerId;
  final int score;
  final String startedAt;
  final String endedAt;
  final int durationSec;
  final String hostname;
  final String ipAddress;
  final String device;
  final String summaryText;
  final Map<String, dynamic> extra;

  const PuffinScoreRecord({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.score,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    required this.hostname,
    required this.ipAddress,
    required this.device,
    required this.summaryText,
    required this.extra,
  });

  PuffinProfile get profile => getPuffinProfileById(playerId);

  /// Returns true if this score is a demo seed (`scr_seed_*` / `is_dummy_seed`)
  /// or an automated UAT Bot score (`player_id == 'saga'` / `scr_uat_*`).
  bool get isDebugOrDemo {
    final cleanId = id.trim().toLowerCase();
    final cleanPlayer = (playerId ?? '').trim().toLowerCase();
    return cleanId.startsWith('scr_seed_') ||
        cleanId.startsWith('scr_uat_') ||
        cleanPlayer == 'saga' ||
        extra['is_dummy_seed'] == true ||
        extra['uat'] == true;
  }

  Map<String, dynamic> toJson() {
    final p = profile;
    return <String, dynamic>{
      'id': id,
      'game_id': gameId,
      'player_id': playerId,
      'score': score,
      'started_at': startedAt,
      'ended_at': endedAt,
      'duration_sec': durationSec,
      'hostname': hostname,
      'ip_address': ipAddress,
      'source_ip': ipAddress,
      'device': device,
      'summary_text': summaryText,
      'extra': extra,
      'gameId': gameId,
      'userId': playerId,
      'displayName': p.displayName,
      'shortName': p.shortName,
      'colorHex': p.colorHex,
      'avatar': p.avatarAsset,
    };
  }

  factory PuffinScoreRecord.fromJson(Map<String, dynamic> raw) {
    final gameId = (raw['game_id'] ?? raw['gameId'] ?? raw['appId'] ?? kTubatureAppId)
        .toString()
        .trim();
    final rawPlayer = raw.containsKey('player_id')
        ? raw['player_id']
        : raw.containsKey('playerId')
            ? raw['playerId']
            : raw.containsKey('userId')
                ? raw['userId']
                : raw['name'];
    final hasExplicitNull = rawPlayer == null || rawPlayer.toString().toLowerCase() == 'null';
    final playerId = hasExplicitNull
        ? null
        : normalizePuffinProfileId(rawPlayer, allowNull: false);
    final profile = getPuffinProfileById(playerId);

    final nowIso = DateTime.now().toUtc().toIso8601String();
    final endedRaw = (raw['ended_at'] ?? raw['endedAt'] ?? raw['date'] ?? nowIso).toString();
    final endedDt = DateTime.tryParse(endedRaw)?.toUtc() ?? DateTime.now().toUtc();
    final endedAt = endedDt.toIso8601String();

    final fallbackDur = (raw['duration_sec'] ?? raw['durationSec'] ?? raw['seconds'] ?? 180);
    final fallbackSec = fallbackDur is num ? fallbackDur.toInt() : int.tryParse('$fallbackDur') ?? 180;

    final startedRaw = raw['started_at'] ?? raw['startedAt'];
    final startedDt = startedRaw != null
        ? (DateTime.tryParse(startedRaw.toString())?.toUtc() ??
            endedDt.subtract(Duration(seconds: fallbackSec)))
        : endedDt.subtract(Duration(seconds: fallbackSec));
    final startedAt = startedDt.toIso8601String();

    final durationSec = endedDt.difference(startedDt).inSeconds.clamp(1, 86400);
    final rawScore = raw['score'];
    final score = rawScore is num ? rawScore.toInt() : int.tryParse('$rawScore') ?? 0;

    final extraMap = <String, dynamic>{};
    if (raw['extra'] is Map) {
      extraMap.addAll(Map<String, dynamic>.from(raw['extra'] as Map));
    } else if (raw['metadata'] is Map) {
      extraMap.addAll(Map<String, dynamic>.from(raw['metadata'] as Map));
    }

    final hostname = (raw['hostname'] ?? '').toString().trim();
    final ipAddress =
        (raw['source_ip'] ?? raw['ip_address'] ?? raw['ipAddress'] ?? '127.0.0.1')
            .toString()
            .trim();
    final device = (raw['device'] ?? 'Flutter').toString().trim();
    final summaryText = (raw['summary_text'] ??
            raw['summaryText'] ??
            '${profile.displayName} scored $score pt in $gameId')
        .toString();
    final id = (raw['id'] ?? 'scr_${endedDt.millisecondsSinceEpoch}_${playerId ?? "null"}')
        .toString();

    return PuffinScoreRecord(
      id: id,
      gameId: gameId.isEmpty ? kTubatureAppId : gameId,
      playerId: playerId,
      score: score,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSec: durationSec,
      hostname: hostname,
      ipAddress: ipAddress.isEmpty ? '127.0.0.1' : ipAddress,
      device: device,
      summaryText: summaryText,
      extra: extraMap,
    );
  }
}

final List<PuffinScoreRecord> kDefaultDummyScores = <PuffinScoreRecord>[
  PuffinScoreRecord.fromJson(const <String, dynamic>{
    'id': 'scr_seed_05_ale_tubature',
    'game_id': 'tubature',
    'player_id': 'ale',
    'score': 4120,
    'started_at': '2026-11-05T17:12:00Z',
    'ended_at': '2026-11-05T17:15:30Z',
    'duration_sec': 210,
    'hostname': 'pupurabbux.tailnet.lan',
    'ip_address': '100.94.27.10',
    'device': 'Linux RTX 5080 (Chrome)',
    'summary_text':
        'Ale connected all 64 dungeon conduits on Level #7 (Hard, 8x8) in 31 moves and unlocked Schmoogle!',
    'extra': <String, dynamic>{
      'level': 7,
      'difficulty': 'hard',
      'grid': '8x8',
      'grid_size': 8,
      'moves': 31,
      'total_tiles': 64,
      'goodies_unlocked': <String>['tubature:schmoogle', 'tubature:maialino'],
    },
  }),
  PuffinScoreRecord.fromJson(const <String, dynamic>{
    'id': 'scr_seed_05_seby_tubature',
    'game_id': 'tubature',
    'player_id': 'seby',
    'score': 2985,
    'started_at': '2026-11-05T18:05:00Z',
    'ended_at': '2026-11-05T18:08:10Z',
    'duration_sec': 190,
    'hostname': 'ipad-seby.lan',
    'ip_address': '192.168.1.105',
    'device': 'iPad Mini (Touch)',
    'summary_text':
        'Seby connected all 36 dungeon conduits on Level #3 (Easy, 6x6) in 19 moves and unlocked Motorino!',
    'extra': <String, dynamic>{
      'level': 3,
      'difficulty': 'easy',
      'grid': '6x6',
      'grid_size': 6,
      'moves': 19,
      'total_tiles': 36,
      'goodies_unlocked': <String>['tubature:motorino'],
    },
  }),
  PuffinScoreRecord.fromJson(const <String, dynamic>{
    'id': 'scr_seed_05_null_tubature',
    'game_id': 'tubature',
    'player_id': null,
    'score': 2380,
    'started_at': '2026-11-02T19:15:00Z',
    'ended_at': '2026-11-02T19:20:40Z',
    'duration_sec': 340,
    'hostname': '',
    'ip_address': '192.168.1.199',
    'device': 'Android Tablet (PWA Offline)',
    'summary_text': 'Anonymous match (player_id: NULL) at Level 4 of Tubature with zero leaks!',
    'extra': <String, dynamic>{
      'level': 4,
      'difficulty': 'medium',
      'grid': '7x7',
      'grid_size': 7,
      'moves': 28,
    },
  }),
  PuffinScoreRecord.fromJson(const <String, dynamic>{
    'id': 'scr_seed_07_guest_jigsaw',
    'game_id': 'kids-jigsaw-puzzle',
    'player_id': 'guest',
    'score': 1420,
    'started_at': '2026-11-02T15:10:00Z',
    'ended_at': '2026-11-02T15:14:20Z',
    'duration_sec': 260,
    'hostname': 'salotto-tv.lan',
    'ip_address': '192.168.1.55',
    'device': 'Smart TV Browser',
    'summary_text': 'Guest Puffin completed the 6x6 Dragons jigsaw puzzle in 4m 20s!',
    'extra': <String, dynamic>{
      'difficulty': '6x6',
      'grid': '6x6',
      'grid_size': 6,
      'pieces': 36,
    },
  }),
  PuffinScoreRecord.fromJson(const <String, dynamic>{
    'id': 'scr_seed_01_ale_smurfs',
    'game_id': 'smurfs-and-dragons',
    'player_id': 'ale',
    'score': 4850,
    'started_at': '2026-11-02T17:10:12Z',
    'ended_at': '2026-11-02T17:18:44Z',
    'duration_sec': 512,
    'hostname': 'pupurabbux.tailnet.lan',
    'ip_address': '100.94.27.10',
    'device': 'Linux RTX 5080 (Chrome)',
    'summary_text': 'Ale crushed the Emerald Dragon at Level 42 with 62 Puffin Archers!',
    'extra': <String, dynamic>{
      'level': 42,
      'difficulty': 'nightmare',
    },
  }),
  PuffinScoreRecord.fromJson(const <String, dynamic>{
    'id': 'scr_seed_02_kate_mahjong',
    'game_id': 'family-mahjong-3d',
    'player_id': 'kate',
    'score': 3920,
    'started_at': '2026-11-02T20:04:00Z',
    'ended_at': '2026-11-02T20:11:15Z',
    'duration_sec': 435,
    'hostname': 'macbook-di-kate.local',
    'ip_address': '192.168.1.42',
    'device': 'macOS Safari',
    'summary_text': 'Mum Kate cleared Imperial layout #77b201 with Combo x8!',
    'extra': <String, dynamic>{
      'difficulty': 'hard',
    },
  }),
  PuffinScoreRecord.fromJson(const <String, dynamic>{
    'id': 'scr_seed_06_riccardo_chess',
    'game_id': 'carchess3d',
    'player_id': 'riccardo',
    'score': 1950,
    'started_at': '2026-11-02T21:00:05Z',
    'ended_at': '2026-11-02T21:06:15Z',
    'duration_sec': 370,
    'hostname': 'pupurabbux',
    'ip_address': '192.168.1.27',
    'device': 'Ubuntu Linux (RTX 5080)',
    'summary_text': 'Dad Riccardo checkmated the CPU in 37 moves on easy mode!',
    'extra': <String, dynamic>{
      'difficulty': 'easy',
      'moves': 37,
    },
  }),
];

class PuffinLockoutStatus {
  final int attempts;
  final bool jammed;
  final int remainingSec;

  const PuffinLockoutStatus({
    required this.attempts,
    required this.jammed,
    required this.remainingSec,
  });
}

/// Unified PuffinLogin state manager for Tubature (Web + Native).
class PuffinLogin extends ChangeNotifier {
  static final PuffinLogin instance = PuffinLogin._internal();

  PuffinLogin._internal();

  static const bool acceptGuestPolicy =
      bool.fromEnvironment('PUFFINLOGIN_ACCEPT_GUEST', defaultValue: true);
  static const bool requireStrongAuthPolicy =
      bool.fromEnvironment('PUFFINLOGIN_REQUIRE_STRONG_AUTH', defaultValue: false);
  static const bool matureOnlyPolicy =
      bool.fromEnvironment('PUFFINLOGIN_MATURE_ONLY', defaultValue: false);
  static const bool offlineOkPolicy =
      bool.fromEnvironment('PUFFINLOGIN_OFFLINE_OK', defaultValue: true);
  static const String apiUrl =
      String.fromEnvironment('PUFFINLOGIN_API_URL', defaultValue: kDefaultCloudApiUrl);

  PuffinProfile? _currentUser;
  String _lang = 'en';
  bool _showDebugScores = false;
  List<PuffinScoreRecord> _scores = List<PuffinScoreRecord>.from(kDefaultDummyScores);
  final Map<String, Map<String, int>> _lockoutMap = <String, Map<String, int>>{};
  bool _initialized = false;

  PuffinProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  String get lang => _lang;
  bool get showDebugScores => _showDebugScores;

  Future<void> init() async {
    if (_initialized) {
      await _syncFromLocalStorage();
      return;
    }
    _initialized = true;

    PuffinPlatformBridge.listenToWebEvents(
      onAuthOrScoreChanged: () {
        _syncFromLocalStorage();
      },
    );

    await _syncFromLocalStorage();
    unawaited(syncScoresFromCloud());
  }

  Future<void> _syncFromLocalStorage() async {
    try {
      // 1. Language & Debug toggle
      final rawLang = PuffinPlatformBridge.getRawStorageItem(PuffinStorageKeys.lang) ?? 'en';
      _lang = rawLang.toLowerCase().startsWith('it') ? 'it' : 'en';
      final rawDebug = PuffinPlatformBridge.getRawStorageItem(PuffinStorageKeys.showDebugScores);
      _showDebugScores = rawDebug == 'true' || rawDebug == '1';

      // 2. Active user session (puffin_auth_v2)
      final rawAuth = PuffinPlatformBridge.getRawStorageItem(PuffinStorageKeys.auth);
      PuffinProfile? nextUser;
      if (rawAuth != null && rawAuth.isNotEmpty) {
        final decoded = jsonDecode(rawAuth);
        if (decoded is Map) {
          final rawUserId = decoded['userId'] ?? decoded['player_id'] ?? decoded['id'];
          if (rawUserId != null) {
            final id = normalizePuffinProfileId(rawUserId, allowNull: true);
            if (id != null) {
              final candidate = getPuffinProfileById(id);
              if (isProfileAllowed(candidate)) {
                nextUser = candidate;
              }
            }
          }
        }
      }
      _currentUser = nextUser;

      // 3. Scores (puffin_scores_v2)
      final rawScores = PuffinPlatformBridge.getRawStorageItem(PuffinStorageKeys.scores);
      final byId = <String, PuffinScoreRecord>{
        for (final seed in kDefaultDummyScores) seed.id: seed,
      };
      if (rawScores != null && rawScores.isNotEmpty) {
        final decoded = jsonDecode(rawScores);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) {
              try {
                final rec = PuffinScoreRecord.fromJson(Map<String, dynamic>.from(item));
                byId[rec.id] = rec;
              } catch (_) {}
            }
          }
        }
      }
      _scores = byId.values.toList()..sort((a, b) => b.score.compareTo(a.score));
    } catch (_) {}
    notifyListeners();
  }

  bool isProfileAllowed(PuffinProfile profile) {
    if (profile.id == null) return false;
    if (profile.role == 'guest' && !acceptGuestPolicy) return false;
    if (matureOnlyPolicy && (profile.role == 'kid' || profile.role == 'guest')) return false;
    if (requireStrongAuthPolicy && profile.authType != 'password') return false;
    return true;
  }

  Future<void> setLang(String nextLang) async {
    _lang = nextLang.toLowerCase().startsWith('it') ? 'it' : 'en';
    PuffinPlatformBridge.setRawStorageItem(PuffinStorageKeys.lang, _lang);
    notifyListeners();
  }

  Future<void> setShowDebugScores(bool enabled) async {
    _showDebugScores = enabled;
    PuffinPlatformBridge.setRawStorageItem(
      PuffinStorageKeys.showDebugScores,
      enabled ? 'true' : 'false',
    );
    notifyListeners();
  }

  Future<bool> toggleShowDebugScores() async {
    final next = !_showDebugScores;
    await setShowDebugScores(next);
    return next;
  }

  int getHiddenDebugCount({String? gameId}) {
    return _scores.where((s) {
      if (gameId != null && gameId.isNotEmpty && gameId != 'ALL' && s.gameId != gameId) {
        return false;
      }
      return s.isDebugOrDemo;
    }).length;
  }

  Future<PuffinProfile?> loginAs(String userId) async {
    final id = normalizePuffinProfileId(userId, allowNull: true);
    if (id == null) {
      await logout();
      return null;
    }
    final profile = getPuffinProfileById(id);
    if (!isProfileAllowed(profile)) return null;

    _currentUser = profile;
    final payload = jsonEncode(<String, dynamic>{
      'userId': profile.id,
      'player_id': profile.id,
      'loggedAt': DateTime.now().toUtc().toIso8601String(),
      'appId': kTubatureAppId,
    });
    PuffinPlatformBridge.setRawStorageItem(PuffinStorageKeys.auth, payload);
    notifyListeners();
    return profile;
  }

  /// Programmatic UAT Bot login (`saga` — `galaxian-explosion-uat-9973`).
  Future<PuffinProfile?> loginAsBot(String secret) async {
    if (!verifyCredential(kSagaBotProfile, secret)) return null;
    return loginAs('saga');
  }

  Future<void> logout() async {
    _currentUser = null;
    PuffinPlatformBridge.removeRawStorageItem(PuffinStorageKeys.auth);
    notifyListeners();
  }

  /// Reset state for unit tests.
  void resetForTesting() {
    PuffinPlatformBridge.clearMockStorage();
    _currentUser = null;
    _lang = 'en';
    _showDebugScores = false;
    _scores = List<PuffinScoreRecord>.from(kDefaultDummyScores);
    _lockoutMap.clear();
    notifyListeners();
  }

  PuffinLockoutStatus getLockoutStatus(String userId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rec = _lockoutMap[userId];
    if (rec == null) {
      return const PuffinLockoutStatus(attempts: 0, jammed: false, remainingSec: 0);
    }
    final jammedUntil = rec['jammedUntil'] ?? 0;
    final attempts = rec['attempts'] ?? 0;
    if (jammedUntil > 0 && now >= jammedUntil) {
      _lockoutMap.remove(userId);
      return const PuffinLockoutStatus(attempts: 0, jammed: false, remainingSec: 0);
    }
    final jammed = attempts >= kMaxFailedAttempts && jammedUntil > now;
    final remainingSec = jammed ? ((jammedUntil - now) / 1000).ceil() : 0;
    return PuffinLockoutStatus(attempts: attempts, jammed: jammed, remainingSec: remainingSec);
  }

  PuffinLockoutStatus recordFailedAttempt(String userId) {
    final prev = _lockoutMap[userId];
    final attempts = (prev?['attempts'] ?? 0) + 1;
    final jammedUntil = attempts >= kMaxFailedAttempts
        ? DateTime.now().millisecondsSinceEpoch + kJamCooldownMs
        : 0;
    _lockoutMap[userId] = <String, int>{
      'attempts': attempts,
      'jammedUntil': jammedUntil,
    };
    notifyListeners();
    return getLockoutStatus(userId);
  }

  void resetLockout([String? userId]) {
    if (userId != null) {
      _lockoutMap.remove(userId);
    } else {
      _lockoutMap.clear();
    }
    notifyListeners();
  }

  bool verifyCredential(PuffinProfile profile, String inputSecret) {
    if (profile.authType == 'none') return true;
    final hash = computePuffinSecretHash(profile.id ?? '', inputSecret);
    return hash == profile.secretHash;
  }

  Future<void> triggerForgotPassword(PuffinProfile profile) async {
    if (profile.email.isEmpty) return;
    await PuffinPlatformBridge.httpPostJson(
      '$apiUrl/auth/forgot-password',
      <String, dynamic>{
        'userId': profile.id,
        'email': profile.email,
        'appId': kTubatureAppId,
      },
    );
  }

  Future<PuffinScoreRecord> submitScore({
    required int score,
    required int durationSec,
    String? startedAt,
    String? endedAt,
    String? playerId,
    String? summaryText,
    Map<String, dynamic>? extra,
  }) async {
    final resolvedPlayerId = playerId != null
        ? normalizePuffinProfileId(playerId, allowNull: true)
        : _currentUser?.id;
    final profile = getPuffinProfileById(resolvedPlayerId);
    final endIso = endedAt ?? DateTime.now().toUtc().toIso8601String();
    final endDt = DateTime.tryParse(endIso)?.toUtc() ?? DateTime.now().toUtc();
    final startIso = startedAt ??
        endDt.subtract(Duration(seconds: durationSec.clamp(1, 86400))).toIso8601String();

    final normalizedExtra = <String, dynamic>{
      if (extra != null) ...extra,
    };
    if (normalizedExtra['difficulty'] != null) {
      normalizedExtra['difficulty'] =
          normalizedExtra['difficulty'].toString().trim().toLowerCase();
    }

    final record = PuffinScoreRecord(
      id: 'scr_${endDt.millisecondsSinceEpoch}_${resolvedPlayerId ?? "null"}',
      gameId: kTubatureAppId,
      playerId: resolvedPlayerId,
      score: score,
      startedAt: startIso,
      endedAt: endIso,
      durationSec: durationSec.clamp(1, 86400),
      hostname: PuffinPlatformBridge.getHostname(),
      ipAddress: '127.0.0.1',
      device: PuffinPlatformBridge.getDeviceLabel(),
      summaryText: summaryText ??
          '${profile.displayName} scored $score pt in Tubature!',
      extra: normalizedExtra,
    );

    final byId = <String, PuffinScoreRecord>{
      for (final s in _scores) s.id: s,
      record.id: record,
    };
    _scores = byId.values.toList()..sort((a, b) => b.score.compareTo(a.score));

    final encodedScores = jsonEncode(_scores.map((s) => s.toJson()).toList());
    PuffinPlatformBridge.setRawStorageItem(PuffinStorageKeys.scores, encodedScores);
    notifyListeners();

    if (kIsWeb) {
      unawaited(PuffinPlatformBridge.submitScoreViaWebBridge(record.toJson()));
    } else {
      unawaited(PuffinPlatformBridge.httpPostJson('$apiUrl/scores', record.toJson()));
    }

    return record;
  }

  Future<List<PuffinScoreRecord>> syncScoresFromCloud({String? gameFilter}) async {
    final url = gameFilter != null && gameFilter.isNotEmpty && gameFilter != 'ALL'
        ? '$apiUrl/scores?game_id=${Uri.encodeQueryComponent(gameFilter)}&limit=50'
        : '$apiUrl/scores?limit=50';
    final raw = await PuffinPlatformBridge.httpGet(url);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map && decoded['scores'] is List) {
          final byId = <String, PuffinScoreRecord>{
            for (final s in _scores) s.id: s,
          };
          for (final item in decoded['scores'] as List) {
            if (item is Map) {
              try {
                final rec = PuffinScoreRecord.fromJson(Map<String, dynamic>.from(item));
                byId[rec.id] = rec;
              } catch (_) {}
            }
          }
          _scores = byId.values.toList()..sort((a, b) => b.score.compareTo(a.score));
          final encoded = jsonEncode(_scores.map((s) => s.toJson()).toList());
          PuffinPlatformBridge.setRawStorageItem(PuffinStorageKeys.scores, encoded);
          notifyListeners();
        }
      } catch (_) {}
    }
    return getLeaderboard(gameId: gameFilter);
  }

  List<PuffinScoreRecord> getLeaderboard({
    String? gameId,
    int limit = kTopTenLimit,
    bool? includeDebug,
  }) {
    final showDebug = includeDebug ?? _showDebugScores;
    final filtered = _scores.where((s) {
      if (gameId != null && gameId.isNotEmpty && gameId != 'ALL' && s.gameId != gameId) {
        return false;
      }
      if (!showDebug && s.isDebugOrDemo) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return filtered.take(limit).toList();
  }

  Future<void> openLoginModal(
    BuildContext context, {
    String? preselectUserId,
    bool mandatory = false,
  }) async {
    // On Web, if <puffin-login> Web Component is mounted in index.html, open its native modal!
    if (kIsWeb && PuffinPlatformBridge.openWebModal(preselectUserId)) {
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: !mandatory || isLoggedIn,
      builder: (ctx) => PuffinLoginDialog(
        initialUserId: preselectUserId,
        mandatory: mandatory,
      ),
    );
  }
}

/// Face-First (95% Face at rest -> Hover-Reveal RPG Body) Pixar Avatar Widget.
class PuffinAvatarWidget extends StatefulWidget {
  final PuffinProfile profile;
  final double size;
  final bool zoomedOut;
  final double borderWidth;

  const PuffinAvatarWidget({
    super.key,
    required this.profile,
    this.size = 34,
    this.zoomedOut = false,
    this.borderWidth = 2.0,
  });

  @override
  State<PuffinAvatarWidget> createState() => _PuffinAvatarWidgetState();
}

class _PuffinAvatarWidgetState extends State<PuffinAvatarWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final showFullBody = widget.zoomedOut || _hovered;
    final radius = BorderRadius.circular(widget.size * 0.28);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: const Color(0xFF0B0D19),
          borderRadius: radius,
          border: Border.all(
            color: widget.profile.color,
            width: widget.borderWidth,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular((widget.size * 0.28 - widget.borderWidth).clamp(2.0, 40.0)),
          child: AnimatedScale(
            scale: showFullBody ? 1.0 : 1.52,
            alignment: showFullBody ? Alignment.center : const Alignment(0, -0.52),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            child: Image.asset(
              widget.profile.avatarAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Text(
                  widget.profile.shortName.substring(0, 1),
                  style: TextStyle(
                    color: widget.profile.color,
                    fontWeight: FontWeight.w900,
                    fontSize: widget.size * 0.45,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Minimalist Top-Right PuffinLogin Pill Badge (ONLY Icon + Short Name — no emojis, no subtitles!).
/// On Web, reserves space for the floating `<puffin-login>` Web Component in `web/index.html`.
class PuffinLoginBadge extends StatelessWidget {
  final bool reserveWebSpace;

  const PuffinLoginBadge({
    super.key,
    this.reserveWebSpace = true,
  });

  @override
  Widget build(BuildContext context) {
    final isCompactMobile = MediaQuery.sizeOf(context).width < 500;
    if (kIsWeb && reserveWebSpace) {
      return SizedBox(width: isCompactMobile ? 96 : 128, height: 34);
    }

    return ListenableBuilder(
      listenable: PuffinLogin.instance,
      builder: (context, _) {
        final user = PuffinLogin.instance.currentUser;
        final isIt = PuffinLogin.instance.lang == 'it';
        final borderColor = user?.color ?? const Color(0xFFF97316);
        final label = user?.shortName ?? (isIt ? 'Login' : 'Log in');

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => PuffinLogin.instance.openLoginModal(context),
            child: Container(
              padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
              decoration: BoxDecoration(
                color: const Color(0xFF121528),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.32),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (user != null)
                    PuffinAvatarWidget(
                      profile: user,
                      size: 26,
                      borderWidth: 1.5,
                    )
                  else
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B0D19),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: const Icon(Icons.lock, size: 14, color: Color(0xFFF97316)),
                    ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFF8FAFC),
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact 6-Hero Family Login Dialog with Cutie `X X X X` Numpad, 3-Strike Jam, and EN/IT Toggle.
class PuffinLoginDialog extends StatefulWidget {
  final String? initialUserId;
  final bool mandatory;

  const PuffinLoginDialog({
    super.key,
    this.initialUserId,
    this.mandatory = false,
  });

  @override
  State<PuffinLoginDialog> createState() => _PuffinLoginDialogState();
}

class _PuffinLoginDialogState extends State<PuffinLoginDialog> {
  static const Map<int, String> _keyDecorations = <int, String>{
    1: '⭐',
    2: '🎈',
    3: '🦖',
    4: '🚀',
    5: '🌈',
    6: '🦄',
    7: '🍕',
    8: '⚡',
    9: '🎮',
    0: '🐧',
  };

  PuffinProfile? _selectedCandidate;
  String _pinBuffer = '';
  bool _showPassword = false;
  bool _highlightGuest = false;
  String _feedbackText = '';
  bool _feedbackIsError = false;
  final TextEditingController _pwdController = TextEditingController();
  Timer? _jamTimer;

  @override
  void initState() {
    super.initState();
    if (widget.initialUserId != null) {
      final p = getPuffinProfileById(widget.initialUserId);
      if (p.id != null) _selectedCandidate = p;
    }
    _jamTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _selectedCandidate?.id != null) {
        final lock = PuffinLogin.instance.getLockoutStatus(_selectedCandidate!.id!);
        if (lock.jammed) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _jamTimer?.cancel();
    _pwdController.dispose();
    super.dispose();
  }

  bool get _isIt => PuffinLogin.instance.lang == 'it';

  void _selectCandidate(PuffinProfile profile) async {
    if (!PuffinLogin.instance.isProfileAllowed(profile)) return;
    setState(() {
      _selectedCandidate = profile;
      _pinBuffer = '';
      _pwdController.clear();
      _feedbackText = '';
      _feedbackIsError = false;
    });

    if (profile.authType == 'none' && profile.id != null) {
      await PuffinLogin.instance.loginAs(profile.id!);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _submitSecret(PuffinProfile profile, String secret) async {
    if (profile.id == null) return;
    final lock = PuffinLogin.instance.getLockoutStatus(profile.id!);
    if (lock.jammed) return;

    if (PuffinLogin.instance.verifyCredential(profile, secret)) {
      PuffinLogin.instance.resetLockout(profile.id!);
      await PuffinLogin.instance.loginAs(profile.id!);
      if (mounted) Navigator.of(context).pop();
    } else {
      PuffinLogin.instance.recordFailedAttempt(profile.id!);
      setState(() {
        _pinBuffer = '';
        _highlightGuest = true;
        _feedbackIsError = true;
        _feedbackText = _isIt
            ? 'Password sbagliata - scegli Ospite se non la sai'
            : "Wrong password - choose Guest if you don't know it";
      });
    }
  }

  void _onPinDigit(PuffinProfile profile, int digit) {
    if (profile.id == null) return;
    final lock = PuffinLogin.instance.getLockoutStatus(profile.id!);
    if (lock.jammed || _pinBuffer.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pinBuffer += digit.toString();
      _feedbackText = '';
    });
    if (_pinBuffer.length == 4) {
      final candidatePin = _pinBuffer;
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (mounted) _submitSecret(profile, candidatePin);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = PuffinLogin.instance.currentUser;
    final canClose = !widget.mandatory || activeUser != null;

    return PopScope(
      canPop: canClose,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF181C36), Color(0xFF101325)],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white24, width: 2),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 36,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Header
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _isIt ? 'Chi gioca?' : "Who's playing?",
                          style: const TextStyle(
                            color: Color(0xFFF8FAFC),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await PuffinLogin.instance.setLang(_isIt ? 'en' : 'it');
                          setState(() {});
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _isIt ? '🇮🇹 IT' : '🇬🇧 EN',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (activeUser != null) ...<Widget>[
                        const SizedBox(width: 6),
                        TextButton(
                          onPressed: () async {
                            await PuffinLogin.instance.logout();
                            setState(() {
                              _selectedCandidate = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white10,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            _isIt ? 'Esci' : 'Logout',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                      if (canClose) ...<Widget>[
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 6-Hero Single Horizontal Strip
                  Row(
                    children: kPuffinProfiles.map((p) {
                      final allowed = PuffinLogin.instance.isProfileAllowed(p);
                      final isSelected = (_selectedCandidate?.id ?? activeUser?.id) == p.id;
                      final isGuestHighlight = p.id == 'guest' && _highlightGuest && allowed;
                      final lock = p.id != null
                          ? PuffinLogin.instance.getLockoutStatus(p.id!)
                          : const PuffinLockoutStatus(attempts: 0, jammed: false, remainingSec: 0);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: Opacity(
                            opacity: allowed ? 1.0 : 0.3,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: allowed ? () => _selectCandidate(p) : null,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C203B),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected || isGuestHighlight
                                        ? p.color
                                        : Colors.white12,
                                    width: isSelected || isGuestHighlight ? 2.2 : 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? <BoxShadow>[
                                          BoxShadow(
                                            color: p.color.withValues(alpha: 0.35),
                                            blurRadius: 10,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: <Widget>[
                                        PuffinAvatarWidget(
                                          profile: p,
                                          size: 44,
                                          zoomedOut: isSelected,
                                        ),
                                        if (lock.jammed)
                                          Positioned(
                                            top: -4,
                                            right: -4,
                                            child: Container(
                                              width: 16,
                                              height: 16,
                                              alignment: Alignment.center,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFEF4444),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Text(
                                                '!',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.shortName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFFF8FAFC),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Auth Drawer for PIN or Password
                  if (_selectedCandidate != null && _selectedCandidate!.authType != 'none') ...<Widget>[
                    const SizedBox(height: 12),
                    _buildAuthDrawer(_selectedCandidate!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthDrawer(PuffinProfile profile) {
    final lock = PuffinLogin.instance.getLockoutStatus(profile.id ?? '');
    final attemptsLeft = (kMaxFailedAttempts - lock.attempts).clamp(0, kMaxFailedAttempts);
    final pillText = lock.jammed
        ? (_isIt ? 'INCAGLIATO (${lock.remainingSec}s)' : 'JAMMED (${lock.remainingSec}s)')
        : (_isIt ? '$attemptsLeft tentativi' : '$attemptsLeft tries left');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lock.jammed ? const Color(0xFF2E1219) : const Color(0xFF0C0E1C),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: lock.jammed ? const Color(0xFFEF4444) : profile.color,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                profile.shortName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: lock.jammed || lock.attempts >= 2
                      ? const Color(0x33EF4444)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  pillText,
                  style: TextStyle(
                    color: lock.jammed || lock.attempts >= 2
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFF94A3B8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (lock.jammed) _buildJamBanner(profile, lock),
          if (profile.authType == 'pin4')
            _buildKidsCutiePinPad(profile, lock)
          else if (!lock.jammed)
            _buildAdultPasswordForm(profile),
          if (_feedbackText.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: <Widget>[
                Text(
                  _feedbackText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _feedbackIsError ? const Color(0xFFFCA5A5) : const Color(0xFF4ADE80),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_feedbackIsError && PuffinLogin.acceptGuestPolicy)
                  ElevatedButton(
                    onPressed: () {
                      final guest = getPuffinProfileById('guest');
                      _selectCandidate(guest);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      _isIt ? '🐧 Gioca come Ospite' : '🐧 Play as Guest',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
            ),
          ],
          if (profile.email.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            TextButton(
              onPressed: () async {
                setState(() {
                  _feedbackIsError = false;
                  _feedbackText = _isIt
                      ? 'Inviata a ${profile.email}!'
                      : 'Sent to ${profile.email}!';
                });
                await PuffinLogin.instance.triggerForgotPassword(profile);
              },
              child: Text(
                _isIt
                    ? 'Password dimenticata? Invia a ${profile.email}'
                    : 'Forgot password? Email ${profile.email}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJamBanner(PuffinProfile profile, PuffinLockoutStatus lock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x33EF4444),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF4444)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            profile.authType == 'pin4'
                ? (_isIt ? 'TASTIERINO INCAGLIATO! (3+ errori)' : 'KEYPAD JAMMED! (3+ wrong tries)')
                : (_isIt ? 'LOGIN INCAGLIATO! (3+ errori)' : 'LOGIN JAMMED! (3+ wrong tries)'),
            style: const TextStyle(
              color: Color(0xFFFEE2E2),
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isIt
                ? 'Hai sbagliato 3 volte (${lock.remainingSec}s). Scegli Ospite se non la sai:'
                : "Wrong password 3 times (${lock.remainingSec}s). Choose Guest if you don't know it:",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFFECACA), fontSize: 11),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  PuffinLogin.instance.resetLockout(profile.id);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white12,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  _isIt ? 'Sblocca' : 'Unjam',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              if (PuffinLogin.acceptGuestPolicy)
                ElevatedButton(
                  onPressed: () => _selectCandidate(getPuffinProfileById('guest')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    _isIt ? 'Gioca come Ospite' : 'Play as Guest',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKidsCutiePinPad(PuffinProfile profile, PuffinLockoutStatus lock) {
    final keys = <Object>[1, 2, 3, 4, 5, 6, 7, 8, 9, 'clear', 0, 'back'];
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(4, (i) {
            final filled = i < _pinBuffer.length;
            return Container(
              width: 42,
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: filled
                    ? profile.color.withValues(alpha: 0.18)
                    : const Color(0xFF151930),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: lock.jammed
                      ? const Color(0xFFEF4444)
                      : (filled ? profile.color : Colors.white24),
                  width: 2,
                ),
              ),
              child: Text(
                lock.jammed ? '💥' : (filled ? 'X' : '•'),
                style: TextStyle(
                  color: filled ? profile.color : Colors.white38,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 250,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: keys.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.75,
            ),
            itemBuilder: (context, idx) {
              final k = keys[idx];
              return ElevatedButton(
                onPressed: lock.jammed
                    ? null
                    : () {
                        if (k == 'clear') {
                          setState(() => _pinBuffer = '');
                        } else if (k == 'back') {
                          if (_pinBuffer.isNotEmpty) {
                            setState(() => _pinBuffer = _pinBuffer.substring(0, _pinBuffer.length - 1));
                          }
                        } else if (k is int) {
                          _onPinDigit(profile, k);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23284A),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: k is int
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '$k',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            _keyDecorations[k] ?? '✨',
                            style: const TextStyle(fontSize: 9),
                          ),
                        ],
                      )
                    : Text(
                        k == 'clear' ? '🧹' : '⌫',
                        style: const TextStyle(fontSize: 15),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAdultPasswordForm(PuffinProfile profile) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _pwdController,
            obscureText: !_showPassword,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: _isIt
                  ? 'Password di ${profile.shortName}...'
                  : "${profile.shortName}'s password...",
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF151930),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
            ),
            onSubmitted: (val) => _submitSecret(profile, val),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          onPressed: () => setState(() => _showPassword = !_showPassword),
          icon: Text(_showPassword ? '🙈' : '👁️'),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF1D2240),
          ),
        ),
        const SizedBox(width: 6),
        ElevatedButton(
          onPressed: () => _submitSecret(profile, _pwdController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: profile.color,
            foregroundColor: const Color(0xFF0A0C16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            _isIt ? 'Entra' : 'Log in',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

/// Ultra-Minimalist Hall of Fame (`<puffin-leaderboard>` equivalent in Flutter):
/// At rest: ONLY Rank + Photo + Short Name + High Score!
/// On hover or tap: Zooms out avatar to reveal tiny RPG body + reveals extra metadata!
class PuffinLeaderboardWidget extends StatefulWidget {
  final String? filterGame;
  final int limit;
  final bool shrinkWrap;

  const PuffinLeaderboardWidget({
    super.key,
    this.filterGame = kTubatureAppId,
    this.limit = kTopTenLimit,
    this.shrinkWrap = false,
  });

  @override
  State<PuffinLeaderboardWidget> createState() => _PuffinLeaderboardWidgetState();
}

class _PuffinLeaderboardWidgetState extends State<PuffinLeaderboardWidget> {
  String? _hoveredOrExpandedId;

  String _formatDuration(int sec) {
    final s = sec.clamp(0, 86400);
    final m = s ~/ 60;
    final rem = s % 60;
    return m > 0 ? '${m}m ${rem.toString().padLeft(2, "0")}s' : '${rem}s';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PuffinLogin.instance,
      builder: (context, _) {
        final showDebug = PuffinLogin.instance.showDebugScores;
        final isIt = PuffinLogin.instance.lang == 'it';
        final debugCount = PuffinLogin.instance.getHiddenDebugCount(gameId: widget.filterGame);
        final scores = PuffinLogin.instance.getLeaderboard(
          gameId: widget.filterGame,
          limit: widget.limit,
          includeDebug: showDebug,
        );

        if (scores.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    isIt
                        ? 'Nessun punteggio reale registrato ancora!'
                        : 'No real player scores recorded yet!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (debugCount > 0 && !showDebug) ...<Widget>[
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => PuffinLogin.instance.toggleShowDebugScores(),
                      icon: const Text('🧪', style: TextStyle(fontSize: 13)),
                      label: Text(
                        isIt
                            ? 'Mostra $debugCount record Demo/UAT nascosti'
                            : 'Show $debugCount hidden Demo/UAT records',
                        style: const TextStyle(
                          color: Color(0xFF67E8F9),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF22D3EE)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          itemCount: scores.length,
          separatorBuilder: (_, _) => const SizedBox(height: 7),
          itemBuilder: (context, index) {
            final entry = scores[index];
            final rank = index + 1;
            final profile = entry.profile;
            final isExpanded = _hoveredOrExpandedId == entry.id;

            Color rankColor = const Color(0xFF94A3B8);
            if (rank == 1) rankColor = const Color(0xFFFACC15);
            if (rank == 2) rankColor = const Color(0xFFE2E8F0);
            if (rank == 3) rankColor = const Color(0xFFFB923C);

            final hostStr = entry.hostname.isNotEmpty &&
                    entry.hostname != 'localhost' &&
                    entry.hostname != '127.0.0.1'
                ? entry.hostname
                : entry.ipAddress;

            final extraPairs = entry.extra.entries
                .take(4)
                .map((e) => '${e.key}:${e.value}')
                .join(', ');

            return MouseRegion(
              onEnter: (_) => setState(() => _hoveredOrExpandedId = entry.id),
              onExit: (_) {
                if (_hoveredOrExpandedId == entry.id) {
                  setState(() => _hoveredOrExpandedId = null);
                }
              },
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _hoveredOrExpandedId = isExpanded ? null : entry.id;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isExpanded
                        ? const Color(0xFF1E2444)
                        : const Color(0xFF14182E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isExpanded ? profile.color : Colors.white12,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Main minimalist row: Rank + Photo + Short Name + High Score ONLY!
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 24,
                            child: Text(
                              '$rank',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: rankColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          PuffinAvatarWidget(
                            profile: profile,
                            size: 38,
                            zoomedOut: isExpanded,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    profile.shortName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFF8FAFC),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                if (entry.isDebugOrDemo) ...<Widget>[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22D3EE).withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: const Color(0xFF22D3EE).withValues(alpha: 0.55),
                                      ),
                                    ),
                                    child: Text(
                                      profile.role == 'bot' || entry.playerId == 'saga'
                                          ? '🤖 UAT'
                                          : '🧪 DEMO',
                                      style: const TextStyle(
                                        color: Color(0xFF67E8F9),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            '${entry.score}',
                            style: TextStyle(
                              color: profile.color,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                      if (isExpanded) ...<Widget>[
                        const SizedBox(height: 6),
                        const Divider(color: Colors.white12, height: 8),
                        Text(
                          '${entry.gameId} • ⏱️ ${_formatDuration(entry.durationSec)} • 🌐 $hostStr'
                          '${extraPairs.isNotEmpty ? " • $extraPairs" : ""}',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
