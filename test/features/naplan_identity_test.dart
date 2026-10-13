import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/features/literacy/models/question.dart';
import 'package:brightbound_adventures/features/literacy/widgets/multiple_choice_game.dart';
import 'package:brightbound_adventures/ui/components/quest_intro.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// NAPLAN identity pass: every place a child meets a quest — the intro,
/// the question card — advertises the NAPLAN alignment, and the label
/// derivation from `Skill.naplanArea` is human-friendly.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Skill.naplanAreaLabel', () {
    Skill makeSkill({String? naplanArea}) => Skill(
          id: 'skill_test',
          name: 'Test Skill',
          description: 'desc',
          strand: 'Language',
          naplanArea: naplanArea,
          lastPracticed: DateTime(2026, 1, 1),
        );

    test('turns snake_case NAPLAN areas into display labels', () {
      expect(makeSkill(naplanArea: 'homophones').naplanAreaLabel, 'Homophones');
      expect(makeSkill(naplanArea: 'multi_step_problems').naplanAreaLabel,
          'Multi step problems');
      expect(
          makeSkill(naplanArea: 'place_value').naplanAreaLabel, 'Place value');
    });

    test('is null when the skill carries no NAPLAN tag', () {
      expect(makeSkill().naplanAreaLabel, isNull);
      expect(makeSkill(naplanArea: '').naplanAreaLabel, isNull);
    });
  });

  group('Quest intro NAPLAN badge', () {
    Widget wrap(Widget child) => MaterialApp(
          theme: AppTheme.lightTheme(),
          home: MediaQuery(
            data: const MediaQueryData(
                size: Size(420, 900), disableAnimations: true),
            child: child,
          ),
        );

    QuestIntro intro({String? naplanLabel}) => QuestIntro(
          zoneLabel: '🌲 Word Woods',
          title: 'Homophones',
          objective: 'Pick the word that sounds right.',
          reason: 'This is the next quest for you.',
          questionCount: 10,
          rewardXp: 135,
          rewardStars: 3,
          naplanLabel: naplanLabel,
          onStart: () {},
        );

    testWidgets('shows the NAPLAN focus beside the zone chip', (tester) async {
      await tester.pumpWidget(wrap(intro(naplanLabel: 'Homophones')));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('NAPLAN · Homophones'), findsOneWidget);
      expect(find.text('🌲 Word Woods'), findsOneWidget,
          reason: 'the zone chip stays alongside the NAPLAN badge');
    });

    testWidgets('omits the badge when the skill is not NAPLAN-tagged',
        (tester) async {
      await tester.pumpWidget(wrap(intro()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('NAPLAN'), findsNothing);
    });
  });

  group('Question card NAPLAN chip', () {
    const question = LiteracyQuestion(
      id: 'test_q1',
      skillId: 'skill_test',
      question: 'Which word means a young dog?',
      options: ['puppy', 'kitten', 'calf', 'foal'],
      correctIndex: 0,
      hint: 'A kitten is a young cat.',
      difficulty: 1,
    );

    Widget wrap(Widget child) => MultiProvider(
          providers: [
            ChangeNotifierProvider<AvatarProvider>.value(
                value: _NaplanTestAvatarProvider()),
            Provider<HapticService>(create: (_) => HapticService()),
            ChangeNotifierProvider<AdaptiveDifficultyService>(
                create: (_) => AdaptiveDifficultyService()),
            ChangeNotifierProvider<QuestSessionHistoryService>(
                create: (_) => QuestSessionHistoryService()),
          ],
          child: MaterialApp(
            theme: AppTheme.lightTheme(),
            home: MediaQuery(
              data: const MediaQueryData(
                  size: Size(420, 1100), disableAnimations: true),
              child: child,
            ),
          ),
        );

    testWidgets('shows the NAPLAN focus chip during play', (tester) async {
      SharedPreferences.setMockInitialValues(const {});
      await tester.pumpWidget(wrap(
        const MultipleChoiceGame(
          questions: [question],
          skillName: 'Test Skill',
          naplanLabel: 'Homophones',
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('NAPLAN · Homophones'), findsOneWidget);
    });

    testWidgets('omits the chip when no NAPLAN label is passed',
        (tester) async {
      SharedPreferences.setMockInitialValues(const {});
      await tester.pumpWidget(wrap(
        const MultipleChoiceGame(
          questions: [question],
          skillName: 'Test Skill',
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('NAPLAN'), findsNothing);
    });
  });
}

/// Minimal avatar so the game header can render without a real store.
class _NaplanTestAvatarProvider extends AvatarProvider {
  static final _avatar = Avatar(
    id: 'naplan-test-avatar',
    name: 'Explorer Test',
    baseCharacter: 'fox',
    skinColor: '#F5D6A0',
    outfitId: 'default',
    createdAt: DateTime(2026, 1, 1),
    lastModified: DateTime(2026, 1, 1),
  );

  @override
  Avatar? get avatar => _avatar;

  @override
  bool get hasAvatar => true;

  @override
  Future<void> loadAvatar() async {}
}
