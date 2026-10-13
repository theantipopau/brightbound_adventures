// Overflow probe, part 2 (2026-10-10 clipping pass): the screens AFTER a
// session — results, celebrations — plus shop and mini-games.
//
// Same two stress conditions as quiz_layout_overflow_test.dart: a tiny
// phone (320x568 @1.0 text) and a small phone at 200% text scale. Asserts
// Flutter raises no layout/clip exceptions on render. Results screens run
// their real reward-transaction setup (mirroring literacy_session_flow_test)
// so rendering is faithful, not a stripped-down stub.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nested/nested.dart' show SingleChildWidget;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/features/logic/widgets/logic_results_screen.dart';
import 'package:brightbound_adventures/features/literacy/widgets/quiz_results_screen.dart';
import 'package:brightbound_adventures/features/mini_games/memory_match_game.dart';
import 'package:brightbound_adventures/features/mini_games/pattern_puzzle_game.dart';
import 'package:brightbound_adventures/features/mini_games/word_search_game.dart';
import 'package:brightbound_adventures/features/motor/widgets/motor_results_screen.dart';
import 'package:brightbound_adventures/features/numeracy/widgets/numeracy_results_screen.dart';
import 'package:brightbound_adventures/features/science/widgets/science_results_screen.dart';
import 'package:brightbound_adventures/features/storytelling/widgets/story_results_screen.dart';
import 'package:brightbound_adventures/ui/screens/mini_games_screen.dart';
import 'package:brightbound_adventures/ui/screens/shop_screen.dart';
import 'package:brightbound_adventures/ui/widgets/index.dart';
import 'package:brightbound_adventures/ui/widgets/zone_mastered_celebration.dart';

class _SeededStorage extends LocalStorageService {
  Avatar? avatar = Avatar(
    id: 'a1',
    name: 'Rexandra the Wonderfully Long Name',
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

/// Mirrors the provider rig the results screens actually run under in
/// production (see literacy_session_flow_test.dart setupRewards).
Future<List<SingleChildWidget>> _resultsProviders() async {
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

  final skillProvider = SkillProvider(storage);
  await skillProvider.initializeSkills();

  return [
    ChangeNotifierProvider<AvatarProvider>.value(value: avatar),
    ChangeNotifierProvider<SkillProvider>.value(value: skillProvider),
    ChangeNotifierProvider<RewardTransactionService>.value(value: rewards),
    // ShopScreen consumes ShopService directly for the star balance.
    ChangeNotifierProvider<ShopService>.value(value: shop),
    ChangeNotifierProvider<SpacedRepetitionService>(
        create: (_) => SpacedRepetitionService()),
    ChangeNotifierProvider<QuestSessionHistoryService>(
        create: (_) => QuestSessionHistoryService()),
  ];
}

Future<void> _probe(
  WidgetTester tester,
  Widget screen, {
  required Size size,
  double scale = 1.0,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  Widget content = MediaQuery(
    data: MediaQueryData(size: size, textScaler: TextScaler.linear(scale)),
    child: screen,
  );
  final rig = await _resultsProviders();
  content = MultiProvider(providers: rig, child: content);

  // Capture full error details (widget site + stack) for every flutterError,
  // including ones the framework records silently for takeException.
  final raw = <String>[];
  final prevOnError = FlutterError.onError;
  FlutterError.onError = (d) {
    raw.add(d.toString());
    prevOnError?.call(d);
  };
  addTearDown(() => FlutterError.onError = prevOnError);

  await tester.pumpWidget(MaterialApp(home: content));
  // Bounded pumps — reward choreography and ambient timers run; do not settle.
  await tester.pump(const Duration(milliseconds: 150));
  await tester.pump(const Duration(milliseconds: 600));
  final errors = <String>[];
  void collect(String phase) {
    Object? ex;
    while ((ex = tester.takeException()) != null) {
      errors.add('[$phase] $ex');
    }
    while (raw.isNotEmpty) {
      debugPrint('=== RAW[$phase] ===\n${raw.removeAt(0)}');
    }
  }

  collect('initial');
  await tester.pump(const Duration(seconds: 1));
  collect('after-async');
  expect(
    errors,
    isEmpty,
    reason: 'at ${size.width}x${size.height} @${scale}x text\n'
        'EXCEPTIONS:\n${errors.join('\n---\n')}',
  );

  await tester.pumpWidget(const SizedBox.shrink());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final longName = 'Reading Comprehension & Advanced Vocabulary Mastery';

  final viewports = <(String, Size, double)>[
    ('tiny phone', const Size(320, 568), 1.0),
    ('small phone @200% text', const Size(360, 640), 2.0),
  ];

  for (final (label, size, scale) in viewports) {
    testWidgets('literacy results has no overflow — $label', (tester) async {
      await _probe(
        tester,
        QuizResultsScreen(
          skillName: longName,
          skillId: 'skill_probe',
          sessionId: 'probe_lit_results',
          correctAnswers: 7,
          totalQuestions: 10,
          accuracy: 0.7,
          hintsUsed: 2,
          zoneId: 'word-woods',
          zoneName: 'Word Woods',
        ),
        size: size,
        scale: scale,
      );
    });

    testWidgets('numeracy results has no overflow — $label', (tester) async {
      await _probe(
        tester,
        NumeracyResultsScreen(
          skillName: longName,
          skillId: 'skill_probe',
          sessionId: 'probe_num_results',
          correctAnswers: 9,
          totalQuestions: 10,
          accuracy: 0.9,
          onPlayAgain: () {},
          onExit: () {},
          zoneId: 'number-nebula',
          zoneName: 'Number Nebula',
        ),
        size: size,
        scale: scale,
      );
    });

    testWidgets('science results has no overflow — $label', (tester) async {
      await _probe(
        tester,
        ScienceResultsScreen(
          skillName: longName,
          skillId: 'skill_probe',
          sessionId: 'probe_sci_results',
          correctAnswers: 6,
          totalQuestions: 10,
          accuracy: 0.6,
          onPlayAgain: () {},
          onExit: () {},
          zoneId: 'science-explorers',
          zoneName: 'Science Explorers',
        ),
        size: size,
        scale: scale,
      );
    });

    testWidgets('motor results has no overflow — $label', (tester) async {
      await _probe(
        tester,
        MotorResultsScreen(
          targetsHit: 18,
          totalTargets: 20,
          score: 2450,
          avgReactionTime: const Duration(milliseconds: 640),
          accuracy: 0.9,
          skillName: longName,
          sessionId: 'probe_motor_results',
          skillId: 'skill_probe',
          onContinue: () {},
        ),
        size: size,
        scale: scale,
      );
    });

    testWidgets('logic results has no overflow — $label', (tester) async {
      await _probe(
        tester,
        LogicResultsScreen(
          correctAnswers: 8,
          totalQuestions: 10,
          skillName: longName,
          sessionId: 'probe_logic_results',
          skillId: 'skill_probe',
          hintsUsed: 1,
          onContinue: () {},
        ),
        size: size,
        scale: scale,
      );
    });

    testWidgets('story results has no overflow — $label', (tester) async {
      await _probe(
        tester,
        StoryResultsScreen(
          correctAnswers: 5,
          totalQuestions: 10,
          skillName: longName,
          sessionId: 'probe_story_results',
          skillId: 'skill_probe',
          onContinue: () {},
        ),
        size: size,
        scale: scale,
      );
    });

    testWidgets('shop has no overflow — $label', (tester) async {
      await _probe(
        tester,
        const ShopScreen(),
        size: size,
        scale: scale,
      );
    });

    testWidgets('mini games hub has no overflow — $label', (tester) async {
      await _probe(
        tester,
        const MiniGamesScreen(),
        size: size,
        scale: scale,
      );
    });

    testWidgets('word search has no overflow — $label', (tester) async {
      await _probe(
        tester,
        const WordSearchGame(),
        size: size,
        scale: scale,
      );
    });

    testWidgets('pattern puzzle has no overflow — $label', (tester) async {
      await _probe(
        tester,
        const PatternPuzzleGame(),
        size: size,
        scale: scale,
      );
    });

    testWidgets('memory match has no overflow — $label', (tester) async {
      await _probe(
        tester,
        const MemoryMatchGame(),
        size: size,
        scale: scale,
      );
    });

    testWidgets('level-up dialog has no overflow — $label', (tester) async {
      await _probe(
        tester,
        LevelUpDialog(
          result: LevelUpResult(
            leveledUp: true,
            oldLevel: 4,
            newLevel: 6,
            xpGained: 480,
            totalXp: 3120,
          ),
        ),
        size: size,
        scale: scale,
      );
    });

    testWidgets('streak milestone modal has no overflow — $label',
        (tester) async {
      await _probe(
        tester,
        StreakMilestoneModal(
          streakDays: 30,
          bonusStars: 50,
          onDismiss: () {},
        ),
        size: size,
        scale: scale,
      );
    });

    testWidgets('quiz results celebration has no overflow — $label',
        (tester) async {
      await _probe(
        tester,
        QuizResultsCelebration(
          correctAnswers: 10,
          totalQuestions: 10,
          starsEarned: 3,
          xpEarned: 250,
          isNewBest: true,
          onContinue: () {},
        ),
        size: size,
        scale: scale,
      );
    });

    testWidgets('mastery certificate dialog has no overflow — $label',
        (tester) async {
      await _probe(
        tester,
        CertificateDialog(
          certificate: MasteryCertificate(
            studentName: 'Rexandra the Wonderfully Long Name',
            achievementType: 'zone',
            achievementName: 'Word Woods Zone Mastery',
            date: '10 October 2026',
            starsEarned: 24,
          ),
        ),
        size: size,
        scale: scale,
      );
    });

    testWidgets('zone mastered celebration has no overflow — $label',
        (tester) async {
      await _probe(
        tester,
        Builder(
          builder: (context) {
            // Fire once the host is mounted.
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showZoneMasteredCelebration(
                context,
                zoneId: 'word-woods',
                zoneName: 'Word Woods',
              );
            });
            return const SizedBox.shrink();
          },
        ),
        size: size,
        scale: scale,
      );
    });
  }
}
