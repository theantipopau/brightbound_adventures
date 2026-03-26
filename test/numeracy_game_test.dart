import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/core/services/adaptive_difficulty_service.dart';
import 'package:brightbound_adventures/core/services/haptic_service.dart';
import 'package:brightbound_adventures/features/numeracy/widgets/numeracy_game.dart';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';

Future<void> _pumpNumeracyGame(
  WidgetTester tester, {
  required NumeracyQuestion question,
}) async {
  SharedPreferences.setMockInitialValues({
    'autoReadQuestions': false,
    'aiHintsEnabled': false,
    'aiExplanationsEnabled': false,
    'aiCloudMode': false,
  });

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<HapticService>(create: (_) => HapticService()),
        ChangeNotifierProvider<AdaptiveDifficultyService>(
          create: (_) => AdaptiveDifficultyService(),
        ),
      ],
      child: MaterialApp(
        home: NumeracyGame(
          questions: [question],
          skillName: 'Test Skill',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NumeracyGame Tests', () {
    testWidgets('renders current question and all answer options', (WidgetTester tester) async {
      final question = NumeracyQuestion(
        id: 'test_1',
        skillId: 'test_skill',
        question: 'What is 1 + 1?',
        options: ['1', '2', '3', '4'],
        correctIndex: 1,
        type: NumeracyQuestionType.multipleChoice,
      );

      await _pumpNumeracyGame(tester, question: question);

      expect(find.text('What is 1 + 1?'), findsOneWidget);
      expect(find.text('Test Skill'), findsOneWidget);
      expect(find.text('1'), findsAtLeastNWidgets(1));
      expect(find.text('2'), findsAtLeastNWidgets(1));
      expect(find.text('3'), findsAtLeastNWidgets(1));
      expect(find.text('4'), findsAtLeastNWidgets(1));
      expect(find.byTooltip('Go home'), findsOneWidget);
      expect(find.byTooltip('Pause Game'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('shows feedback and completion callback after a correct answer', (WidgetTester tester) async {
      final question = NumeracyQuestion(
        id: 'test_2',
        skillId: 'test_skill',
        question: 'What is 3 + 2?',
        options: ['4', '5', '6', '7'],
        correctIndex: 1,
        type: NumeracyQuestionType.multipleChoice,
      );
      double? accuracy;
      int? correct;
      int? total;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<HapticService>(create: (_) => HapticService()),
            ChangeNotifierProvider<AdaptiveDifficultyService>(
              create: (_) => AdaptiveDifficultyService(),
            ),
          ],
          child: MaterialApp(
            home: NumeracyGame(
              questions: [question],
              skillName: 'Test Skill',
              onComplete: (value, correctAnswers, totalQuestions) {
                accuracy = value;
                correct = correctAnswers;
                total = totalQuestions;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await tester.tap(find.text('5').first);
      await tester.pump();

      expect(find.textContaining('+10'), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(accuracy, 1.0);
      expect(correct, 1);
      expect(total, 1);
    });

    testWidgets('pause button toggles back to play icon', (WidgetTester tester) async {
      final question = NumeracyQuestion(
        id: 'test_3',
        skillId: 'test_skill',
        question: 'What is 6 - 1?',
        options: ['3', '4', '5', '6'],
        correctIndex: 2,
        type: NumeracyQuestionType.multipleChoice,
      );

      await _pumpNumeracyGame(tester, question: question);

      await tester.tap(find.byTooltip('Pause Game'));
      await tester.pump();

      expect(find.byIcon(Icons.play_arrow), findsAtLeastNWidgets(1));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });
}
