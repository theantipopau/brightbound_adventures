import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/features/literacy/models/question.dart';
import 'package:brightbound_adventures/features/literacy/screens/skill_practice_screen.dart';
import 'package:brightbound_adventures/features/literacy/widgets/multiple_choice_game.dart';
import 'package:brightbound_adventures/features/literacy/widgets/quiz_results_screen.dart';

/// End-to-end coverage for the vertical slice:
/// quest intro → learning encounter → instructional feedback → reward
/// transaction → premium reveal, with the reward proven to apply exactly
/// once per session.
///
/// Harness notes:
/// * Providers mirror `main.dart`; services that are factory singletons
///   (Shop/Achievement/Streak/Cosmetic) are initialised from mocked
///   SharedPreferences instead of re-created, so state resets per test.
/// * Reduced motion (`disableAnimations: true`) makes the reward reveal's
///   choreography settle on its final frame immediately — deterministic, and
///   it doubles as the reduced-motion branch check.
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

Future<SkillProvider> _seededSkillProvider(_SeededStorage storage) async {
  final provider = SkillProvider(storage);
  await provider.initializeSkills();
  return provider;
}

/// First skill of Word Woods, as the zone screen would hand it over.
Skill _homophonesSkill(SkillProvider skills) {
  final zoneSkills = skills.getZoneSkills('word_woods');
  if (zoneSkills.isNotEmpty) return zoneSkills.first;
  return Skill(
    id: 'skill_homophones',
    name: 'Homophones',
    description: 'Words that sound the same but mean different things',
    strand: 'Literacy',
    lastPracticed: DateTime(2026, 1, 1),
    difficulty: 1,
  );
}

const _literacyQuestion = LiteracyQuestion(
  id: 'test_q1',
  skillId: 'skill_test',
  question: 'Which word means a young dog?',
  options: ['puppy', 'kitten', 'calf', 'foal'],
  correctIndex: 0,
  hint: 'A kitten is a young cat.',
  explanation: 'A young dog is called a puppy, so "puppy" is correct.',
  difficulty: 1,
);

/// Sets a real test viewport — `MediaQueryData(size:)` alone does not move
/// the render tree, so off-screen controls would fail to hit-test.
void _viewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(finder);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quest intro', () {
    testWidgets('states the objective, the reason, and the rewards before play',
        (tester) async {
      _viewport(tester, const Size(420, 900));
      SharedPreferences.setMockInitialValues(const {});
      final storage = _SeededStorage();
      final skills = await _seededSkillProvider(storage);
      final avatar = AvatarProvider()..setStorageService(storage);
      await avatar.loadAvatar();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SkillProvider>.value(value: skills),
            ChangeNotifierProvider<AvatarProvider>.value(value: avatar),
            ChangeNotifierProvider<StreakService>(
                create: (_) => StreakService()),
            ChangeNotifierProvider<SpacedRepetitionService>(
                create: (_) => SpacedRepetitionService()),
            ChangeNotifierProvider<QuestSessionHistoryService>(
                create: (_) => QuestSessionHistoryService()),
            ChangeNotifierProvider<DailyChallengeService>(
                create: (_) => DailyChallengeService(storage)),
            Provider<HapticService>(create: (_) => HapticService()),
            ChangeNotifierProvider<AdaptiveDifficultyService>(
                create: (_) => AdaptiveDifficultyService()),
            ChangeNotifierProvider<RewardTransactionService>.value(
              value: RewardTransactionService(
                shop: ShopService(),
                achievements: AchievementService(),
                streak: StreakService(),
                cosmeticUnlock: CosmeticUnlockService(),
              ),
            ),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                  size: Size(400, 800), disableAnimations: true),
              child: SkillPracticeScreen(
                skill: _homophonesSkill(skills),
                themeColor: const Color(0xFF2D7D32),
                zoneId: 'word_woods',
                zoneName: '🌲 Word Woods',
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.text('Start quest'), findsOneWidget);
      expect(find.textContaining('Word Woods'), findsWidgets);
      expect(find.textContaining('Practise'), findsOneWidget,
          reason: 'the intro must state the learning objective');
      expect(find.text('Quest rewards'), findsOneWidget);
      expect(find.textContaining('Up to'), findsOneWidget);
      expect(find.textContaining('135 XP'), findsOneWidget);
      expect(find.textContaining('3 stars'), findsOneWidget);
      expect(find.textContaining('challenges'), findsOneWidget);
      expect(find.byType(MultipleChoiceGame), findsNothing);

      await _tap(tester, find.text('Start quest'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));

      expect(find.byType(MultipleChoiceGame), findsOneWidget,
          reason: 'Start must actually begin the activity');
      expect(find.text('Start quest'), findsNothing);
    });
  });

  group('Instructional feedback', () {
    testWidgets(
        'shows the authored explanation and waits for the child instead of auto-advancing',
        (tester) async {
      SharedPreferences.setMockInitialValues(const {
        'autoReadQuestions': false,
        'aiHintsEnabled': false,
        'aiExplanationsEnabled': false,
        'aiCloudMode': false,
      });
      var completed = 0;
      final storage = _SeededStorage();
      final avatar = AvatarProvider()..setStorageService(storage);
      await avatar.loadAvatar();

      _viewport(tester, const Size(420, 1100));
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AvatarProvider>.value(value: avatar),
            Provider<HapticService>(create: (_) => HapticService()),
            ChangeNotifierProvider<AdaptiveDifficultyService>(
                create: (_) => AdaptiveDifficultyService()),
            ChangeNotifierProvider<QuestSessionHistoryService>(
                create: (_) => QuestSessionHistoryService()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                  size: Size(420, 1100), disableAnimations: true),
              child: MultipleChoiceGame(
                questions: const [_literacyQuestion],
                skillName: 'Test Skill',
                themeColor: const Color(0xFF2D7D32),
                onComplete: (_, __, ___) => completed++,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await _tap(tester, find.text('puppy'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.textContaining('A young dog is called a puppy'),
        findsOneWidget,
        reason: 'the authored explanation must be shown after answering',
      );
      expect(find.byKey(const ValueKey('quiz-continue')), findsOneWidget);
      expect(completed, 0);

      // No blind timer: three seconds later we are still reading feedback.
      await tester.pump(const Duration(seconds: 3));
      expect(
          find.textContaining('A young dog is called a puppy'), findsOneWidget);
      expect(completed, 0);

      await _tap(tester, find.byKey(const ValueKey('quiz-continue')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(completed, 1,
          reason: 'Continue hands over to the results exactly once');
    });

    testWidgets('an incorrect answer still gets an explanation',
        (tester) async {
      _viewport(tester, const Size(420, 1100));
      final storage = _SeededStorage();
      final avatar = AvatarProvider()..setStorageService(storage);
      await avatar.loadAvatar();
      SharedPreferences.setMockInitialValues(const {
        'autoReadQuestions': false,
        'aiHintsEnabled': false,
        'aiExplanationsEnabled': false,
        'aiCloudMode': false,
      });

      var completed = 0;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AvatarProvider>.value(value: avatar),
            Provider<HapticService>(create: (_) => HapticService()),
            ChangeNotifierProvider<AdaptiveDifficultyService>(
                create: (_) => AdaptiveDifficultyService()),
            ChangeNotifierProvider<QuestSessionHistoryService>(
                create: (_) => QuestSessionHistoryService()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                  size: Size(420, 1100), disableAnimations: true),
              child: MultipleChoiceGame(
                questions: const [_literacyQuestion],
                skillName: 'Test Skill',
                themeColor: const Color(0xFF2D7D32),
                onComplete: (_, __, ___) => completed++,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await _tap(tester, find.text('kitten'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.textContaining('A young dog is called a puppy'),
        findsOneWidget,
        reason: 'mistakes are the teaching moment — never skip the why',
      );
      expect(find.byKey(const ValueKey('quiz-continue')), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('quiz-continue')));
      await tester.pump();
      // Drain the option-entrance (60 ms) and avatar-emotion (2 s) timers so
      // the test finishes with no live timers.
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 200));
      expect(completed, 1);
    });
  });

  group('Reward transaction + reveal', () {
    Future<
        ({
          AvatarProvider avatar,
          ShopService shop,
          RewardTransactionService rewards,
        })> setupRewards() async {
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

      final rewards = RewardTransactionService(
        shop: shop,
        achievements: achievements,
        streak: streak,
        cosmeticUnlock: CosmeticUnlockService(),
      );
      return (avatar: avatar, shop: shop, rewards: rewards);
    }

    Future<void> pumpResults(
      WidgetTester tester, {
      required AvatarProvider avatar,
      required RewardTransactionService rewards,
      required SkillProvider skills,
      required String sessionId,
    }) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AvatarProvider>.value(value: avatar),
            ChangeNotifierProvider<SkillProvider>.value(value: skills),
            ChangeNotifierProvider<RewardTransactionService>.value(
                value: rewards),
            ChangeNotifierProvider<SpacedRepetitionService>(
                create: (_) => SpacedRepetitionService()),
            ChangeNotifierProvider<QuestSessionHistoryService>(
                create: (_) => QuestSessionHistoryService()),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                  size: Size(400, 900), disableAnimations: true),
              child: QuizResultsScreen(
                skillName: 'Homophones',
                skillId: 'skill_homophones',
                sessionId: sessionId,
                correctAnswers: 10,
                totalQuestions: 10,
                accuracy: 1.0,
                hintsUsed: 0,
                zoneId: 'word-woods',
                zoneName: 'Word Woods',
              ),
            ),
          ),
        ),
      );
      // First frame → post-frame callback kicks off processing → awaits.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 400));

      // A3: a level-up award schedules the companion's transient reaction
      // (a 2.2 s auto-reset timer on AvatarProvider). Idle the fake clock
      // past it so the final expectation sees a settled tree instead of a
      // pending timer at dispose.
      await tester.pump(const Duration(seconds: 3));
    }

    testWidgets('applies XP and stars once, and explains them in the reveal',
        (tester) async {
      final setup = await setupRewards();
      final skills = await _seededSkillProvider(_SeededStorage());

      await pumpResults(
        tester,
        avatar: setup.avatar,
        rewards: setup.rewards,
        skills: skills,
        sessionId: 'skill_homophones_session_a',
      );

      // 135 XP crosses a level boundary, so the avatar keeps the 35 that
      // overflow into level 2.
      expect(setup.avatar.avatar!.level, 2, reason: '135 XP crosses level 2');
      expect(setup.avatar.avatar!.experiencePoints, 35,
          reason: '100 consumed by the level-up, 35 carried into level 2');
      expect(setup.shop.starBalance, 3);

      // The reveal explains what was earned and why.
      expect(find.text('Level up!'), findsOneWidget);
      expect(find.text('+135 XP'), findsOneWidget);
      expect(find.text('You reached level 2!'), findsOneWidget);
      expect(find.textContaining('+100 for taking part'), findsOneWidget);
      expect(find.textContaining('+25 accuracy bonus'), findsOneWidget);
      expect(find.textContaining('+10 for working it out yourself'),
          findsOneWidget);
      expect(find.textContaining('stars to spend'), findsOneWidget);
      expect(find.text('See it on the map'), findsOneWidget,
          reason: 'the reveal must point at what to do next');
    });

    testWidgets('replaying the same session never double-awards',
        (tester) async {
      final setup = await setupRewards();
      final skills = await _seededSkillProvider(_SeededStorage());
      const sessionId = 'skill_homophones_session_repeat';

      await pumpResults(
        tester,
        avatar: setup.avatar,
        rewards: setup.rewards,
        skills: skills,
        sessionId: sessionId,
      );

      final xpAfterFirst = setup.avatar.avatar!.experiencePoints;
      final starsAfterFirst = setup.shop.starBalance;
      expect(xpAfterFirst, 35, reason: 'post-level-up remainder of 135 XP');
      expect(setup.avatar.avatar!.level, 2);
      expect(starsAfterFirst, 3);

      // Leave the screen entirely, then come back to the *same* completion
      // (rebuild, resume, reopened results — all hit this path).
      await tester.pumpWidget(const SizedBox.shrink());
      await pumpResults(
        tester,
        avatar: setup.avatar,
        rewards: setup.rewards,
        skills: skills,
        sessionId: sessionId,
      );

      expect(setup.avatar.avatar!.experiencePoints, xpAfterFirst,
          reason: 're-opening a result must not re-earn XP');
      expect(setup.shop.starBalance, starsAfterFirst,
          reason: 're-opening a result must not re-earn stars');
    });
  });
}
