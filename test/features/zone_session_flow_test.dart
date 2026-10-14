import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/features/logic/widgets/logic_results_screen.dart';
import 'package:brightbound_adventures/features/motor/widgets/motor_results_screen.dart';
import 'package:brightbound_adventures/features/numeracy/widgets/numeracy_results_screen.dart';
import 'package:brightbound_adventures/features/science/widgets/science_results_screen.dart';

/// Zone coverage for the shared post-session loop: every migrated results
/// screen runs the same `completeSession` orchestration, so each zone must
/// award XP/stars exactly once per session id, record history once, and
/// present the same `RewardReveal`.
///
/// Harness notes (mirrors `literacy_session_flow_test.dart`):
/// * Providers mirror `main.dart`; services that are factory singletons
///   (Shop/Achievement/Streak/Cosmetic) are initialised from mocked
///   SharedPreferences so state resets per test.
/// * Reduced motion (`disableAnimations: true`) settles the reveal's
///   choreography on its final frame immediately, and drains the results
///   screens' delayed animation timers deterministically.
class _SeededStorage extends LocalStorageService {
  Avatar? avatar = Avatar(
    id: 'a1',
    name: 'Rex',
    baseCharacter: 'fox',
    skinColor: '#F5D6A0',
    outfitId: 'default',
    experiencePoints: 0,
    level: 1,
    createdAt: DateTime(2026, 1, 1),
    lastModified: DateTime(2026, 1, 1),
  );

  @override
  Future<Avatar?> getAvatar() async => avatar;

  @override
  Future<void> saveAvatar(Avatar value) async {
    avatar = value;
  }

  @override
  Future<List<Skill>> getAllSkills() async => [];

  @override
  Future<void> saveSkill(Skill skill) async {}

  @override
  List<DailyChallenge> getDailyChallenges(String dateString) => [];
}

/// First skill of a zone, as the zone detail screen would hand it over.
Skill _firstZoneSkill(SkillProvider skills, String zoneId) {
  final zoneSkills = skills.getZoneSkills(zoneId);
  if (zoneSkills.isNotEmpty) return zoneSkills.first;
  return Skill(
    id: 'skill_test',
    name: 'Test Skill',
    description: 'A fallback skill for the test harness',
    strand: 'Logic',
    lastPracticed: DateTime(2026, 1, 1),
    difficulty: 1,
  );
}

QuestSessionSummary _summary({
  required String id,
  required String zoneId,
  required Skill skill,
  required int correct,
  required int total,
  int hintsUsed = 0,
}) {
  final endedAt = DateTime(2026, 1, 2, 10);
  return QuestSessionSummary(
    id: id,
    zoneId: zoneId,
    skillId: skill.id,
    skillName: skill.name,
    mode: 'practice',
    startedAt: endedAt.subtract(const Duration(minutes: 3)),
    endedAt: endedAt,
    totalQuestions: total,
    correctAnswers: correct,
    score: correct * 10,
    hintsUsed: hintsUsed,
    difficulty: 1,
    forced: false,
    questionIds: const [],
  );
}

/// Real test viewport — `MediaQueryData(size:)` alone does not move the
/// render tree, so off-screen content would fail to lay out honestly.
void _viewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

class _ZoneSetup {
  _ZoneSetup({
    required this.avatar,
    required this.shop,
    required this.rewards,
    required this.skills,
    required this.history,
  });

  final AvatarProvider avatar;
  final ShopService shop;
  final RewardTransactionService rewards;
  final SkillProvider skills;
  final QuestSessionHistoryService history;
}

Future<_ZoneSetup> _setup() async {
  SharedPreferences.setMockInitialValues(const {});
  final shop = ShopService();
  await shop.initialize();
  final achievements = AchievementService();
  await achievements.initialize();
  final streak = StreakService();
  await streak.initialize();
  CosmeticUnlockService().initialize(
    level: 1,
    unlockedOutfits: const [],
    unlockedAccessories: const [],
  );

  final storage = _SeededStorage();
  final avatar = AvatarProvider()..setStorageService(storage);
  await avatar.loadAvatar();

  final skills = SkillProvider(storage);
  await skills.initializeSkills();

  final history = QuestSessionHistoryService();

  final rewards = RewardTransactionService(
    shop: shop,
    achievements: achievements,
    streak: streak,
    cosmeticUnlock: CosmeticUnlockService(),
  );
  return _ZoneSetup(
    avatar: avatar,
    shop: shop,
    rewards: rewards,
    skills: skills,
    history: history,
  );
}

/// Pumps a zone results screen through the shared loop: first frame →
/// post-frame `completeSession` → transaction → reveal, then drains the
/// screen's delayed animation timers (800 ms logic, 500 ms motor).
Future<void> _pumpResults(
  WidgetTester tester, {
  required _ZoneSetup setup,
  required Widget Function() screen,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AvatarProvider>.value(value: setup.avatar),
        ChangeNotifierProvider<SkillProvider>.value(value: setup.skills),
        ChangeNotifierProvider<RewardTransactionService>.value(
            value: setup.rewards),
        ChangeNotifierProvider<QuestSessionHistoryService>.value(
            value: setup.history),
        ChangeNotifierProvider<SpacedRepetitionService>(
            create: (_) => SpacedRepetitionService()),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
              size: Size(420, 900), disableAnimations: true),
          child: screen(),
        ),
      ),
    ),
  );
  // First frame → post-frame callback kicks off processing → awaits.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 400));
  // Drain the results screens' Future.delayed animation beats so the test
  // finishes with no live timers, plus the A3 companion's level-up reaction
  // reset timer (2.2 s) scheduled when the award crosses a level boundary.
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 3));
}

/// The perfect run every zone shares: 135 XP crosses into level 2 (35
/// carried over) and 3 stars land in the jar.
void _expectPerfectReward(_ZoneSetup setup) {
  expect(setup.avatar.avatar!.level, 2, reason: '135 XP crosses level 2');
  expect(setup.avatar.avatar!.experiencePoints, 35,
      reason: '100 consumed by the level-up, 35 carried into level 2');
  expect(setup.shop.starBalance, 3);
}

/// The reveal explains what was earned, why, and what to do next.
void _expectRevealExplainsReward() {
  expect(find.text('Packing your reward…'), findsNothing,
      reason: 'the applying card must be replaced by the finished reveal');
  expect(find.text('Level up!'), findsOneWidget);
  expect(find.textContaining('+135 XP'), findsWidgets,
      reason: 'the screen chip and the reveal both cite the shared total');
  expect(find.text('You reached level 2!'), findsOneWidget);
  expect(find.textContaining('+100 for taking part'), findsOneWidget);
  expect(find.textContaining('+25 accuracy bonus'), findsOneWidget);
  expect(
      find.textContaining('+10 for working it out yourself'), findsOneWidget);
  expect(find.textContaining('stars to spend'), findsOneWidget);
  expect(find.text('See it on the map'), findsOneWidget,
      reason: 'the reveal must point at what to do next');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Logic — Puzzle Peaks (history path)', () {
    testWidgets(
        'applies XP and stars once, records history once, explains the reward',
        (tester) async {
      _viewport(tester, const Size(420, 900));
      final setup = await _setup();
      final skill = _firstZoneSkill(setup.skills, 'puzzle_peaks');
      final summary = _summary(
        id: 'logic_flow_a_${skill.id}',
        zoneId: 'puzzle-peaks',
        skill: skill,
        correct: 10,
        total: 10,
      );

      await _pumpResults(
        tester,
        setup: setup,
        screen: () => LogicResultsScreen(
          correctAnswers: 10,
          totalQuestions: 10,
          skillName: skill.name,
          sessionId: 'logic_flow_a',
          skillId: skill.id,
          zoneId: 'puzzle_peaks',
          zoneName: 'Puzzle Peaks',
          history: summary,
          hintsUsed: 0,
          onContinue: () {},
        ),
      );

      _expectPerfectReward(setup);
      _expectRevealExplainsReward();

      expect(setup.history.sessions.where((s) => s.id == summary.id).length, 1,
          reason: 'the session-history entry must be recorded exactly once');
    });

    testWidgets('replaying the same session never double-awards',
        (tester) async {
      _viewport(tester, const Size(420, 900));
      final setup = await _setup();
      final skill = _firstZoneSkill(setup.skills, 'puzzle_peaks');
      final summary = _summary(
        id: 'logic_flow_b_${skill.id}',
        zoneId: 'puzzle-peaks',
        skill: skill,
        correct: 10,
        total: 10,
      );

      Widget screen() => LogicResultsScreen(
            correctAnswers: 10,
            totalQuestions: 10,
            skillName: skill.name,
            sessionId: 'logic_flow_b',
            skillId: skill.id,
            zoneId: 'puzzle_peaks',
            zoneName: 'Puzzle Peaks',
            history: summary,
            hintsUsed: 0,
            onContinue: () {},
          );

      await _pumpResults(tester, setup: setup, screen: screen);

      final xpAfterFirst = setup.avatar.avatar!.experiencePoints;
      final starsAfterFirst = setup.shop.starBalance;
      expect(xpAfterFirst, 35);
      expect(setup.shop.starBalance, 3);

      // Leave the screen entirely, then come back to the *same* completion
      // (rebuild, resume, reopened results — all hit this path).
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpResults(tester, setup: setup, screen: screen);

      expect(setup.avatar.avatar!.experiencePoints, xpAfterFirst,
          reason: 're-opening a result must not re-earn XP');
      expect(setup.shop.starBalance, starsAfterFirst,
          reason: 're-opening a result must not re-earn stars');
      expect(setup.history.sessions.where((s) => s.id == summary.id).length, 1,
          reason: 'replaying must replace the history entry, not duplicate it');
    });
  });

  group('Motor — Adventure Arena (no hints path)', () {
    testWidgets('applies the shared reward once and survives a replay',
        (tester) async {
      _viewport(tester, const Size(420, 900));
      final setup = await _setup();
      final skill = _firstZoneSkill(setup.skills, 'adventure_arena');
      final summary = _summary(
        id: 'motor_flow_a_${skill.id}',
        zoneId: 'adventure-arena',
        skill: skill,
        correct: 10,
        total: 10,
      );

      Widget screen() => MotorResultsScreen(
            targetsHit: 10,
            totalTargets: 10,
            score: 1000,
            avgReactionTime: const Duration(milliseconds: 420),
            accuracy: 1.0,
            skillName: skill.name,
            sessionId: 'motor_flow_a',
            skillId: skill.id,
            zoneId: 'adventure_arena',
            zoneName: 'Adventure Arena',
            history: summary,
            onContinue: () {},
          );

      await _pumpResults(tester, setup: setup, screen: screen);

      _expectPerfectReward(setup);
      _expectRevealExplainsReward();
      expect(setup.history.sessions.where((s) => s.id == summary.id).length, 1);

      final xpAfterFirst = setup.avatar.avatar!.experiencePoints;
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpResults(tester, setup: setup, screen: screen);

      expect(setup.avatar.avatar!.experiencePoints, xpAfterFirst,
          reason: 're-opening a motor result must not re-earn XP');
      expect(setup.shop.starBalance, 3,
          reason: 're-opening a motor result must not re-earn stars');
      expect(setup.history.sessions.where((s) => s.id == summary.id).length, 1);
    });
  });

  group('Science — Science Explorers (hints path)', () {
    testWidgets(
        'a used hint removes the effort bonus — and replay still never double-awards',
        (tester) async {
      _viewport(tester, const Size(420, 900));
      final setup = await _setup();
      final skill = _firstZoneSkill(setup.skills, 'science_explorers');

      Widget screen() => ScienceResultsScreen(
            skillName: skill.name,
            skillId: skill.id,
            sessionId: 'science_flow_a',
            correctAnswers: 10,
            totalQuestions: 10,
            accuracy: 1.0,
            hintsUsed: 1,
            onPlayAgain: () {},
            onExit: () {},
            zoneId: 'science_explorers',
            zoneName: 'Science Explorers',
          );

      await _pumpResults(tester, setup: setup, screen: screen);

      // 100 base + 25 mastery, but no +10 effort: one hint was opened.
      expect(setup.avatar.avatar!.level, 2);
      expect(setup.avatar.avatar!.experiencePoints, 25,
          reason: '125 XP total — the hint forfeits the effort bonus');
      expect(setup.shop.starBalance, 3);

      expect(find.text('Packing your reward…'), findsNothing);
      expect(find.text('Level up!'), findsOneWidget);
      expect(find.textContaining('+125 XP'), findsWidgets);
      expect(find.textContaining('+100 for taking part'), findsOneWidget);
      expect(find.textContaining('+25 accuracy bonus'), findsOneWidget);
      expect(
          find.textContaining('+10 for working it out yourself'), findsNothing,
          reason: 'the effort bonus must not be claimed when a hint was used');
      expect(find.textContaining('stars to spend'), findsOneWidget);
      expect(find.text('See it on the map'), findsOneWidget);

      final xpAfterFirst = setup.avatar.avatar!.experiencePoints;
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpResults(tester, setup: setup, screen: screen);

      expect(setup.avatar.avatar!.experiencePoints, xpAfterFirst,
          reason: 're-opening a science result must not re-earn XP');
      expect(setup.shop.starBalance, 3,
          reason: 're-opening a science result must not re-earn stars');
    });
  });

  group('Numeracy — Number Nebula (same shared loop as every zone)', () {
    testWidgets(
        'applies XP and stars exactly once — and replaying never double-awards',
        (tester) async {
      _viewport(tester, const Size(420, 900));
      final setup = await _setup();
      final skill = _firstZoneSkill(setup.skills, 'number_nebula');

      Widget screen() => NumeracyResultsScreen(
            skillName: skill.name,
            skillId: skill.id,
            sessionId: 'numeracy_flow_a',
            correctAnswers: 10,
            totalQuestions: 10,
            accuracy: 1.0,
            hintsUsed: 0,
            onPlayAgain: () {},
            onExit: () {},
            zoneId: 'number_nebula',
            zoneName: 'Number Nebula',
          );

      await _pumpResults(tester, setup: setup, screen: screen);

      _expectPerfectReward(setup);
      _expectRevealExplainsReward();

      final xpAfterFirst = setup.avatar.avatar!.experiencePoints;
      final starsAfterFirst = setup.shop.starBalance;

      // Leave the screen entirely, then come back to the same completion
      // (rebuild, resume, reopened results — all hit this path).
      await tester.pumpWidget(const SizedBox.shrink());
      await _pumpResults(tester, setup: setup, screen: screen);

      expect(setup.avatar.avatar!.experiencePoints, xpAfterFirst,
          reason: 're-opening a numeracy result must not re-earn XP');
      expect(setup.shop.starBalance, starsAfterFirst,
          reason: 're-opening a numeracy result must not re-earn stars');
    });
  });
}
