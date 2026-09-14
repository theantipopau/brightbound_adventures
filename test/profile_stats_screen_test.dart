// Regression coverage for ProfileStatsScreen (the "Player Profile" the user
// reported as broken). The previous version of this test only pumped a
// `LocalStorageService` and never touched `AvatarProvider`, `SkillProvider`,
// `ShopService`, `StreakService` or `QuestSessionHistoryService` — exactly
// the "simplified mock that can conceal route and hydration failures"
// pattern the diagnostic protocol warns about. It could pass while the
// screen displayed a StatsService-backed model nothing in the app ever
// wrote to (see docs/PROMPT_MD_EXECUTION_TRACKER.md for the root cause).
//
// This version pumps the real provider graph (matching the pattern used in
// test/world_map/world_map_regression_test.dart) so the assertions actually
// exercise the same wiring the shipped app uses.
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/screens/profile_stats_screen.dart';
import 'package:brightbound_adventures/ui/widgets/xp_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpProfile(
    WidgetTester tester, {
    required AvatarProvider avatarProvider,
    required LocalStorageService storage,
    StreakService? streakService,
    QuestSessionHistoryService? questHistoryService,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AvatarProvider>.value(value: avatarProvider),
          ChangeNotifierProvider<SkillProvider>(
            create: (_) => SkillProvider(storage),
          ),
          // ShopService() is a process-wide singleton (factory constructor),
          // so this always resolves to the same instance a test mutated
          // beforehand. StreakService/QuestSessionHistoryService are not
          // singletons, so those must be passed in explicitly — otherwise
          // the widget tree would read a fresh, unmutated instance.
          ChangeNotifierProvider<ShopService>.value(value: ShopService()),
          ChangeNotifierProvider<StreakService>.value(
            value: streakService ?? StreakService(),
          ),
          ChangeNotifierProvider<QuestSessionHistoryService>.value(
            value: questHistoryService ?? QuestSessionHistoryService(),
          ),
        ],
        child: const MaterialApp(home: ProfileStatsScreen()),
      ),
    );

    // Let SkillProvider's in-memory seed and the screen's own hydration
    // (SkillProvider.initializeSkills / QuestSessionHistoryService.initialize)
    // complete.
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows an empty state when no avatar exists', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpProfile(
      tester,
      avatarProvider: _NoAvatarProvider(),
      storage: _FakeProfileStorageService(),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No progress yet'), findsOneWidget);
    expect(find.textContaining('Create an avatar'), findsOneWidget);
  });

  testWidgets(
      'shows the real avatar level/XP and real star/streak/quest counts — '
      'not a stale zeroed model', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Seed real, non-zero state in the actual canonical services — a
    // StatsService-backed implementation would show 0 for all of these
    // regardless, since nothing ever wrote to that model.
    await ShopService().initialize();
    await ShopService().reset();
    await ShopService().awardStarsForActivity(
      score: 9,
      maxScore: 10,
      accuracy: 0.9,
    );
    final expectedStars = ShopService().starBalance;
    expect(expectedStars, greaterThan(0),
        reason: 'test setup sanity check: ShopService should have awarded '
            'stars for a 90% activity');

    final streakService = StreakService();
    await streakService.initialize();
    await streakService.resetStreak();
    await streakService.recordPlay();
    final expectedStreak = streakService.currentStreak;
    expect(expectedStreak, greaterThan(0));

    final questHistory = QuestSessionHistoryService();
    await questHistory.initialize();
    await questHistory.clearHistory();
    await questHistory.recordSession(QuestSessionSummary(
      id: 'session-1',
      zoneId: 'word_woods',
      skillId: 'test-skill',
      skillName: 'Test Skill',
      mode: 'practice',
      startedAt: DateTime(2026, 1, 1, 9),
      endedAt: DateTime(2026, 1, 1, 9, 5),
      totalQuestions: 10,
      correctAnswers: 9,
      score: 90,
      hintsUsed: 0,
      difficulty: 1,
      forced: false,
      questionIds: const ['q1'],
    ));
    expect(questHistory.sessions.length, 1);

    final avatarProvider = _FixedAvatarProvider(
      Avatar(
        id: 'test-avatar',
        name: 'Explorer Test',
        baseCharacter: 'fox',
        skinColor: '#F5D6A0',
        outfitId: 'default',
        experiencePoints: 42,
        level: 3,
        createdAt: DateTime(2026, 1, 1),
        lastModified: DateTime(2026, 1, 1),
      ),
    );

    await pumpProfile(
      tester,
      avatarProvider: avatarProvider,
      storage: _FakeProfileStorageService(),
      streakService: streakService,
      questHistoryService: questHistory,
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No progress yet'), findsNothing);
    expect(find.textContaining('Couldn\'t load'), findsNothing);

    // Real avatar identity and level, not a fabricated default. Scoped to
    // LevelBadge specifically (rather than a bare find.text('3')) since a
    // plain numeral can coincidentally collide with an unrelated stat
    // value elsewhere on the same screen.
    expect(find.text('Explorer Test\'s Progress'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(LevelBadge),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );

    // Real star/streak/quest numbers sourced from the actual services, not
    // a StatsService record nothing ever populated. Matched by each stat
    // card's semantic label (set from the same value) rather than bare
    // digit text, which several unrelated numbers on this screen could
    // coincidentally share.
    expect(
      find.bySemanticsLabel('Stars: $expectedStars stars'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Day Streak: $expectedStreak day streak'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Quests Completed: 1 quests completed'),
      findsOneWidget,
    );

    // All 8 zones appear (the old hard-coded list only showed 5).
    for (final zone in ZoneCatalog.zones) {
      expect(find.text(zone.name), findsOneWidget,
          reason: '${zone.name} should appear in zone progress');
    }
  });
}

class _NoAvatarProvider extends AvatarProvider {
  @override
  Avatar? get avatar => null;

  @override
  bool get hasAvatar => false;

  @override
  Future<void> loadAvatar() async {}
}

class _FixedAvatarProvider extends AvatarProvider {
  _FixedAvatarProvider(this._avatar);

  final Avatar _avatar;

  @override
  Avatar? get avatar => _avatar;

  @override
  bool get hasAvatar => true;

  @override
  Future<void> loadAvatar() async {}
}

class _FakeProfileStorageService extends LocalStorageService {
  @override
  Future<List<Skill>> getAllSkills() async => [];

  @override
  Future<void> saveSkill(Skill skill) async {}

  @override
  Future<Avatar?> getAvatar() async => null;
}
