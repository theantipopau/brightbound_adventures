import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/features/numeracy/widgets/numeracy_game.dart';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';
import 'package:brightbound_adventures/ui/widgets/tracing_widget.dart';

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

      await tester.pumpWidget(
        MaterialApp(
          home: NumeracyGame(
            questions: [question],
            skillName: 'Test Skill',
          ),
        ),
      );

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

      await tester.pumpWidget(
        MaterialApp(
          home: NumeracyGame(
            questions: [question],
            skillName: 'Test Skill',
          ),
        ),
      );

      expect(find.text('Drag 5 here'), findsOneWidget);
      expect(find.text('Drag the answer here!'), findsOneWidget);
      expect(find.byType(Draggable<int>), findsWidgets);
      expect(find.byType(DragTarget<int>), findsOneWidget);
    });

    testWidgets('Renders tracing question correctly', (WidgetTester tester) async {
      final question = NumeracyQuestion(
        id: 'test_trace_1',
        skillId: 'test_skill',
        question: 'Trace 3',
        options: ['3'],
        correctIndex: 0,
        type: NumeracyQuestionType.tracing,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: NumeracyGame(
            questions: [question],
            skillName: 'Test Skill',
          ),
        ),
      );

      expect(find.text('Trace 3'), findsOneWidget);
      expect(find.byType(TracingWidget), findsOneWidget);
    });
  });
}
