// The living-world promise: finishing a quest changes something the child
// can see on the map, derived from persisted session history rather than a
// transient effect. These tests pin that behaviour — both the island flag
// and the Quest Lens acknowledgement — and confirm the baseline (no
// history, no flag).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/screens/world_map_screen.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

class _FakeStorageService extends LocalStorageService {
  @override
  Future<List<Skill>> getAllSkills() async => [];

  @override
  Future<void> saveSkill(Skill skill) async {}

  @override
  Future<Avatar?> getAvatar() async => null;

  @override
  List<DailyChallenge> getDailyChallenges(String dateString) => [];
}

class _MapTestAvatarProvider extends AvatarProvider {
  static final _testAvatar = Avatar(
    id: 'test-avatar',
    name: 'Explorer Test',
    baseCharacter: 'fox',
    skinColor: '#F5D6A0',
    outfitId: 'default',
    createdAt: DateTime(2026, 1, 1),
    lastModified: DateTime(2026, 1, 1),
  );

  @override
  Avatar? get avatar => _testAvatar;

  @override
  bool get hasAvatar => true;

  @override
  Future<void> loadAvatar() async {}
}

QuestSessionSummary _session({
  String zoneId = 'word-woods',
  String skillId = 'skill_homophones',
  double accuracy = 0.9,
}) {
  final now = DateTime.now();
  const total = 10;
  return QuestSessionSummary(
    id: '${now.microsecondsSinceEpoch}_$skillId',
    zoneId: zoneId,
    skillId: skillId,
    skillName: skillId,
    mode: 'practice',
    startedAt: now.subtract(const Duration(minutes: 4)),
    endedAt: now,
    totalQuestions: total,
    correctAnswers: (accuracy * total).round(),
    score: (accuracy * total).round(),
    hintsUsed: 1,
    difficulty: 2,
    forced: false,
    questionIds: const ['q1', 'q2'],
  );
}

Future<void> _pumpMap(
  WidgetTester tester, {
  required QuestSessionHistoryService history,
}) async {
  final storage = _FakeStorageService();
  final skillProvider = SkillProvider(storage);
  await skillProvider.initializeSkills();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AudioManager>.value(value: AudioManager()),
        ChangeNotifierProvider<AvatarProvider>(
            create: (_) => _MapTestAvatarProvider()),
        ChangeNotifierProvider<SkillProvider>.value(value: skillProvider),
        ChangeNotifierProvider<StreakService>(create: (_) => StreakService()),
        ChangeNotifierProvider<CosmeticUnlockService>.value(
            value: CosmeticUnlockService()),
        ChangeNotifierProvider<DailyChallengeService>(
            create: (_) => DailyChallengeService(storage)),
        ChangeNotifierProvider<SpacedRepetitionService>(
            create: (_) => SpacedRepetitionService()),
        ChangeNotifierProvider<QuestSessionHistoryService>.value(
            value: history),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 640),
            disableAnimations: true,
          ),
          child: const WorldMapScreen(),
        ),
      ),
    ),
  );

  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 1600));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a completed quest raises a persistent flag on its zone island',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final history = QuestSessionHistoryService();
    await history.recordSession(_session());

    await _pumpMap(tester, history: history);

    expect(
      find.text('Quest done'),
      findsOneWidget,
      reason: 'the island must show the persisted world change',
    );
    // State is carried by an icon *and* words, never colour alone.
    expect(find.text('🚩'), findsOneWidget);
    expect(find.text('Quest done'), findsOneWidget);
  });

  testWidgets('the quest lens acknowledges what happened in this zone',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final history = QuestSessionHistoryService();
    await history.recordSession(_session());

    await _pumpMap(tester, history: history);

    expect(
      find.textContaining('finished a quest here today'),
      findsOneWidget,
      reason: 'returning to the map must not feel like an unchanged menu',
    );
  });

  testWidgets('a zone with no history raises no flag', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final history = QuestSessionHistoryService();
    await history.initialize();

    await _pumpMap(tester, history: history);

    expect(find.text('Quest done'), findsNothing);
    expect(find.textContaining('finished a quest here today'), findsNothing);
  });

  testWidgets(
      'recommendations explain themselves instead of using the '
      'generic string', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final history = QuestSessionHistoryService();
    await history.recordSession(_session());
    // Two shaky sessions in one skill: a real, evidence-backed reason to
    // review it rather than a placeholder.
    await history
        .recordSession(_session(skillId: 'skill_apostrophes', accuracy: 0.4));
    await history
        .recordSession(_session(skillId: 'skill_apostrophes', accuracy: 0.5));

    await _pumpMap(tester, history: history);

    expect(
      find.text('Recommended for your next quest.'),
      findsNothing,
      reason: 'with real history available the lens must say why, not fall '
          'back to the generic placeholder',
    );
  });
}
