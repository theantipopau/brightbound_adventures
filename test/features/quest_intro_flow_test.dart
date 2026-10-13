// Every zone practice screen now opens with the same quest-briefing beat
// the literacy slice established (intro → activity → results), via the
// shared `ZoneQuestIntro` wrapper. These tests pump each screen, assert the
// briefing lands (title, challenge count, Start quest), then start the
// session and assert the zone's real activity takes over.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/features/logic/widgets/logic_game.dart';
import 'package:brightbound_adventures/features/motor/widgets/motor_game.dart';
import 'package:brightbound_adventures/features/numeracy/widgets/numeracy_game.dart';
import 'package:brightbound_adventures/features/science/widgets/science_game.dart';
import 'package:brightbound_adventures/features/storytelling/widgets/story_game.dart';
import 'package:brightbound_adventures/features/logic/screens/logic_practice_screen.dart';
import 'package:brightbound_adventures/features/motor/screens/motor_practice_screen.dart';
import 'package:brightbound_adventures/features/numeracy/screens/numeracy_practice_screen.dart';
import 'package:brightbound_adventures/features/science/screens/science_practice_screen.dart';
import 'package:brightbound_adventures/features/storytelling/screens/story_practice_screen.dart';

class _SeededStorage extends LocalStorageService {
  @override
  Future<Avatar?> getAvatar() async => null;

  @override
  Future<void> saveAvatar(Avatar value) async {}

  @override
  Future<List<Skill>> getAllSkills() async => [];

  @override
  Future<void> saveSkill(Skill skill) async {}

  @override
  List<DailyChallenge> getDailyChallenges(String dateString) => [];
}

/// First skill of a zone, as the zone detail screen would hand it over.
Future<Skill> _zoneSkill(SkillProvider skills, String zoneId) async {
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

Future<SkillProvider> _skills() async {
  SharedPreferences.setMockInitialValues(const {});
  final provider = SkillProvider(_SeededStorage());
  await provider.initializeSkills();
  return provider;
}

Future<void> _pump(
  WidgetTester tester,
  SkillProvider skills,
  Widget screen,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(420, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Services the games read alongside the briefing.
  final storage = _SeededStorage();
  final avatar = AvatarProvider()..setStorageService(storage);
  await avatar.loadAvatar();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SkillProvider>.value(value: skills),
        ChangeNotifierProvider<AvatarProvider>.value(value: avatar),
        ChangeNotifierProvider<AdaptiveDifficultyService>(
          create: (_) => AdaptiveDifficultyService(),
        ),
        ChangeNotifierProvider<QuestSessionHistoryService>(
          create: (_) => QuestSessionHistoryService(),
        ),
        Provider<HapticService>(create: (_) => HapticService()),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
              size: Size(420, 900), disableAnimations: true),
          child: screen,
        ),
      ),
    ),
  );
  // First frame + let async question loaders / zero-duration entrances tick.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
}

/// Asserts the briefing beat landed for [skillName].
void _expectBriefing(String skillName) {
  expect(find.text('Start quest'), findsOneWidget,
      reason: 'the session must open on the quest briefing');
  expect(find.textContaining('challenges'), findsOneWidget,
      reason: 'the briefing must promise the real question/round count');
  expect(find.textContaining(skillName), findsWidgets);
  expect(find.text('Back to zone'), findsOneWidget,
      reason: 'the briefing must offer a way out');
}

/// Starts the session and asserts the zone's activity takes over.
Future<void> _startAndExpectGame(WidgetTester tester,
    {required Type gameType}) async {
  await tester.tap(find.text('Start quest'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));

  expect(find.byType(gameType), findsOneWidget,
      reason: 'Start quest must hand over to the real activity');
  expect(find.text('Start quest'), findsNothing);

  // Tear the screen down so activity timers/animators are disposed before
  // the test-binding checks for pending timers.
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quest briefing beat (intro → activity → results)', () {
    testWidgets('numeracy opens on the briefing, then starts the game',
        (tester) async {
      final skills = await _skills();
      final skill = await _zoneSkill(skills, 'number_nebula');

      await _pump(
        tester,
        skills,
        NumeracyPracticeScreen(
          skill: skill,
          themeColor: const Color(0xFF7C4DFF),
          zoneId: 'number_nebula',
          zoneName: 'Number Nebula',
        ),
      );

      _expectBriefing(skill.name);
      await _startAndExpectGame(tester, gameType: NumeracyGame);
    });

    testWidgets(
        'science opens on the briefing once questions are ready, '
        'then starts the game', (tester) async {
      final skills = await _skills();
      final skill = await _zoneSkill(skills, 'science_explorers');

      await _pump(
        tester,
        skills,
        SciencePracticeScreen(
          skillId: skill.id,
          skillName: skill.name,
          zoneId: 'science_explorers',
          zoneName: 'Science Explorers',
        ),
      );

      // The briefing needs its question count, so it waits behind the
      // "preparing your lab" loader; the procedural generator guarantees a
      // set even when the JSON bank is unavailable.
      expect(find.text('Start quest'), findsOneWidget,
          reason: 'the briefing must appear once questions resolve');
      expect(find.textContaining('challenges'), findsOneWidget);
      await _startAndExpectGame(tester, gameType: ScienceGame);
    });

    testWidgets('logic opens on the briefing, then starts the game',
        (tester) async {
      final skills = await _skills();
      final skill = await _zoneSkill(skills, 'puzzle_peaks');

      await _pump(
        tester,
        skills,
        LogicPracticeScreen(
          skillId: skill.id,
          skillName: skill.name,
          zoneId: 'puzzle_peaks',
          zoneName: 'Puzzle Peaks',
        ),
      );

      _expectBriefing(skill.name);
      await _startAndExpectGame(tester, gameType: LogicGame);
    });

    testWidgets('storytelling opens on the briefing, then starts the game',
        (tester) async {
      final skills = await _skills();
      final skill = await _zoneSkill(skills, 'story_springs');

      await _pump(
        tester,
        skills,
        StoryPracticeScreen(
          skillId: skill.id,
          skillName: skill.name,
          zoneId: 'story_springs',
          zoneName: 'Story Springs',
        ),
      );

      _expectBriefing(skill.name);
      await _startAndExpectGame(tester, gameType: StoryGame);
    });

    testWidgets('motor opens on the briefing, then starts the game',
        (tester) async {
      final skills = await _skills();
      final skill = await _zoneSkill(skills, 'adventure_arena');

      await _pump(
        tester,
        skills,
        MotorPracticeScreen(
          skillId: skill.id,
          skillName: skill.name,
          zoneId: 'adventure_arena',
          zoneName: 'Adventure Arena',
        ),
      );

      // Motor briefs rounds rather than questions (3 rounds by default).
      expect(find.text('Start quest'), findsOneWidget);
      expect(find.textContaining('challenges'), findsOneWidget);
      expect(find.textContaining(skill.name), findsWidgets);

      await _startAndExpectGame(tester, gameType: MotorGame);
    });
  });
}
