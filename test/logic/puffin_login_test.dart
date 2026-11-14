import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tubature/logic/puffin_login.dart';
import 'package:tubature/screens/leaderboard_screen.dart';

void main() {
  setUp(() {
    PuffinLogin.instance.resetForTesting();
  });

  group('PuffinLogin Core & Security Invariants (Tubature)', () {
    test('Canonical 6 family profiles + Saga UAT bot match spec colors and auth types', () {
      expect(kPuffinProfiles.length, 6);
      expect(getPuffinProfileById('riccardo').colorHex, '#FACC15');
      expect(getPuffinProfileById('kate').colorHex, '#A855F7');
      expect(getPuffinProfileById('ale').colorHex, '#EF4444');
      expect(getPuffinProfileById('seby').colorHex, '#3B82F6');
      expect(getPuffinProfileById('lucilla').colorHex, '#EC4899');
      expect(getPuffinProfileById('guest').colorHex, '#9CA3AF');
      expect(getPuffinProfileById('saga').colorHex, '#22D3EE');

      expect(getPuffinProfileById('ale').authType, 'pin4');
      expect(getPuffinProfileById('seby').authType, 'pin4');
      expect(getPuffinProfileById('guest').authType, 'none');
      expect(getPuffinProfileById('saga').role, 'bot');
    });

    test('Aliases normalize to canonical profile IDs', () {
      expect(normalizePuffinProfileId('alessandro'), 'ale');
      expect(normalizePuffinProfileId('sebi'), 'seby');
      expect(normalizePuffinProfileId('papino'), 'riccardo');
      expect(normalizePuffinProfileId('mamma'), 'kate');
      expect(normalizePuffinProfileId('nonna'), 'lucilla');
      expect(normalizePuffinProfileId('ospite'), 'guest');
      expect(normalizePuffinProfileId('gemini'), 'saga');
      expect(normalizePuffinProfileId(null, allowNull: true), isNull);
    });

    test('Salted SHA-256 verification matches canonical hashes for PINs and UAT bot', () async {
      final ale = getPuffinProfileById('ale');
      final seby = getPuffinProfileById('seby');
      expect(PuffinLogin.instance.verifyCredential(ale, '2018'), isTrue);
      expect(PuffinLogin.instance.verifyCredential(ale, '0000'), isFalse);
      expect(PuffinLogin.instance.verifyCredential(seby, '2020'), isTrue);
      expect(PuffinLogin.instance.verifyCredential(seby, '9999'), isFalse);

      final bot = await PuffinLogin.instance.loginAsBot('galaxian-explosion-uat-9973');
      expect(bot?.id, 'saga');
      expect(PuffinLogin.instance.currentUser?.id, 'saga');
    });

    test('3-strike lockout jams after 3 failed attempts and resets on unjam', () {
      expect(PuffinLogin.instance.getLockoutStatus('ale').jammed, isFalse);
      PuffinLogin.instance.recordFailedAttempt('ale');
      PuffinLogin.instance.recordFailedAttempt('ale');
      expect(PuffinLogin.instance.getLockoutStatus('ale').jammed, isFalse);

      final third = PuffinLogin.instance.recordFailedAttempt('ale');
      expect(third.jammed, isTrue);
      expect(third.remainingSec, greaterThan(0));

      PuffinLogin.instance.resetLockout('ale');
      expect(PuffinLogin.instance.getLockoutStatus('ale').jammed, isFalse);
    });

    test('calculateTubatureScore scales with difficulty, efficiency, and streak', () {
      final easyScore = calculateTubatureScore(
        difficulty: 'Easy',
        totalTiles: 36,
        moves: 20,
        levelsCompleted: 0,
      );
      final hardScore = calculateTubatureScore(
        difficulty: 'Hard',
        totalTiles: 64,
        moves: 20,
        levelsCompleted: 2,
      );
      expect(easyScore, greaterThan(1200));
      expect(hardScore, greaterThan(easyScore));
    });

    test('submitScore persists guaranteed root fields, P1 telemetry, and goodies_unlocked', () async {
      await PuffinLogin.instance.loginAs('ale');
      final rec = await PuffinLogin.instance.submitScore(
        score: 5240,
        durationSec: 95,
        extra: <String, dynamic>{
          'difficulty': 'Hard',
          'level': 8,
          'grid': '8x8',
          'grid_size': 8,
          'pieces': 64,
          'total_tiles': 64,
          'moves': 29,
          'hints': 0,
          'goodies_unlocked': <String>['tubature:schmoogle', 'tubature:motorino'],
        },
      );

      expect(rec.gameId, 'tubature');
      expect(rec.playerId, 'ale');
      expect(rec.score, 5240);
      expect(rec.durationSec, 95);
      expect(rec.extra['difficulty'], 'hard');
      expect(rec.extra['grid'], '8x8');
      expect(rec.extra['grid_size'], 8);
      expect(rec.extra['goodies_unlocked'], contains('tubature:schmoogle'));

      final lb = PuffinLogin.instance.getLeaderboard(gameId: 'tubature');
      expect(lb.first.score, 5240);
      expect(lb.first.playerId, 'ale');
    });

    test('Demo seed scores and UAT bot scores are hidden by default and revealed on Debug toggle',
        () async {
      // By default showDebugScores is false, so kDefaultDummyScores (scr_seed_*) are hidden
      expect(PuffinLogin.instance.showDebugScores, isFalse);
      expect(PuffinLogin.instance.getLeaderboard(gameId: 'tubature'), isEmpty);
      expect(PuffinLogin.instance.getHiddenDebugCount(gameId: 'tubature'), greaterThan(0));

      // Submit a UAT Bot ('saga') score: also hidden while showDebugScores is false
      await PuffinLogin.instance.loginAsBot('galaxian-explosion-uat-9973');
      final uatScore = await PuffinLogin.instance.submitScore(
        score: 9999,
        durationSec: 42,
      );
      expect(uatScore.isDebugOrDemo, isTrue);
      expect(PuffinLogin.instance.getLeaderboard(gameId: 'tubature'), isEmpty);

      // Enable Debug toggle: both UAT bot and demo seed scores appear
      await PuffinLogin.instance.toggleShowDebugScores();
      expect(PuffinLogin.instance.showDebugScores, isTrue);
      final debugLb = PuffinLogin.instance.getLeaderboard(gameId: 'tubature');
      expect(debugLb, isNotEmpty);
      expect(debugLb.first.score, 9999);
      expect(debugLb.first.playerId, 'saga');
    });

    testWidgets(
        'LeaderboardScreen renders Back to Game (/), filter chips, and toggles Demo/UAT scores',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LeaderboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('🏆 Hall of Fame'), findsOneWidget);
      expect(find.text('🚰 Tubature'), findsOneWidget);
      expect(find.text('🌍 All Family Games'), findsOneWidget);
      expect(find.byKey(const Key('hof_back_to_game_btn')), findsOneWidget);
      expect(find.byKey(const Key('hof_bottom_back_to_game_btn')), findsOneWidget);
      expect(find.byKey(const Key('hof_debug_toggle_chip')), findsOneWidget);

      // Initially Debug is OFF: demo seed 'Ale' is hidden
      expect(find.text('Ale'), findsNothing);

      // Tap Debug toggle chip -> demo seed scores ('Ale', 'Seby') become visible with 🧪 DEMO badge
      await tester.tap(find.byKey(const Key('hof_debug_toggle_chip')));
      await tester.pumpAndSettle();

      expect(find.text('Ale'), findsWidgets);
      expect(find.text('🧪 DEMO'), findsWidgets);
    });
  });
}
