import 'package:brightbound_adventures/features/interactions/types/drag_to_order.dart';
import 'package:brightbound_adventures/features/storytelling/models/question.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sequencing questions derive a safe correct answer', () {
    const question = StoryQuestion(
      id: 'sequence_test',
      skillId: 'skill_story_sequencing',
      question: 'Order the steps.',
      options: [],
      correctIndex: 0,
      type: StoryQuestionType.sequencing,
      sequenceItems: ['Finish', 'Start'],
      correctOrder: [1, 0],
    );

    expect(question.correctAnswer, 'Start -> Finish');
  });

  Widget harness({required ValueChanged<bool> onSubmitted}) {
    return MaterialApp(
      home: Scaffold(
        body: DragToOrderQuestion(
          prompt: 'Put the story beats in order.',
          items: const ['Flower opens', 'Plant seed', 'Water seed'],
          correctOrder: const [1, 2, 0],
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }

  testWidgets('reports an incorrect order without crashing', (tester) async {
    bool? result;
    await tester.pumpWidget(harness(onSubmitted: (value) => result = value));

    await tester.tap(find.text('Check my order'));
    await tester.pump();

    expect(result, isFalse);
  });

  testWidgets('supports keyboard-equivalent move controls', (tester) async {
    bool? result;
    await tester.pumpWidget(harness(onSubmitted: (value) => result = value));

    final moveDownButtons = find.byTooltip('Move down');
    await tester.tap(moveDownButtons.at(0));
    await tester.pump();
    await tester.tap(moveDownButtons.at(1));
    await tester.pump();

    await tester.tap(find.text('Check my order'));
    await tester.pump();

    expect(result, isTrue);
  });
}
