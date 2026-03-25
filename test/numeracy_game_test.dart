import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/adaptive_difficulty_service.dart';
import 'package:brightbound_adventures/core/services/haptic_service.dart';
import 'package:brightbound_adventures/features/numeracy/widgets/numeracy_game.dart';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';

Future<void> _pumpNumeracyGame(
  WidgetTester tester, {
  required NumeracyQuestion question,
}) async {
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NumeracyGame Tests', () {
    testWidgets('Renders multiple choice question correctly', (WidgetTester tester) async {
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
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('Renders drag and drop question correctly', (WidgetTester tester) async {
      final question = NumeracyQuestion(
        id: 'test_drag_1',
        skillId: 'test_skill',
        question: 'Drag 5 here',
        options: ['3', '5', '7', '9'],
        correctIndex: 1,
        type: NumeracyQuestionType.dragAndDrop,
      );

      await _pumpNumeracyGame(tester, question: question);

      expect(find.text('Drag 5 here'), findsOneWidget);
      expect(find.text('Drag the answer here!'), findsOneWidget);
      expect(find.byType(Draggable<int>), findsWidgets);
      expect(find.byType(DragTarget<int>), findsOneWidget);
    });

    testWidgets(
      'Renders tracing question correctly',
      (WidgetTester tester) async {
      final question = NumeracyQuestion(
        id: 'test_trace_1',
        skillId: 'test_skill',
        question: 'Trace 3',
        options: ['3'],
        correctIndex: 0,
        type: NumeracyQuestionType.tracing,
      );

      await _pumpNumeracyGame(tester, question: question);

        expect(find.text('Trace 3'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      },
      skip: true,
    );
  }, skip: true);
}
