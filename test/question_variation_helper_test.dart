import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/core/utils/question_variation_helper.dart';

class _QuestionStub {
  final String id;
  final String prompt;
  final String group;

  const _QuestionStub(this.id, this.prompt, this.group);
}

void main() {
  group('QuestionVariationHelper', () {
    const sessionKey = 'question_variation_stats_test';
    const source = [
      _QuestionStub('a', 'What is 1 + 1?', 'addition'),
      _QuestionStub('b', 'Which word means a place?', 'vocabulary'),
      _QuestionStub('c', 'Choose the next shape in the pattern.', 'logic'),
    ];

    setUp(() {
      QuestionVariationHelper.resetSessionNoveltyHistory(sessionKey);
    });

    test('reports fresh and repeated question counts during selection', () {
      final first = QuestionVariationHelper.buildSessionQuestionSetWithStats(
        sessionKey: sessionKey,
        source: source,
        idOf: (q) => q.id,
        promptOf: (q) => q.prompt,
        groupKeyOf: (q) => q.group,
        desiredCount: 3,
        random: Random(1),
      );

      expect(first.questions.length, 3);
      expect(first.freshQuestionCount, 3);
      expect(first.repeatedQuestionCount, 0);
      expect(first.noveltyPercentage, 100);

      final second = QuestionVariationHelper.buildSessionQuestionSetWithStats(
        sessionKey: sessionKey,
        source: source,
        idOf: (q) => q.id,
        promptOf: (q) => q.prompt,
        groupKeyOf: (q) => q.group,
        desiredCount: 3,
        random: Random(1),
      );

      expect(second.questions.length, 3);
      expect(second.freshQuestionCount, 0);
      expect(second.repeatedQuestionCount, 3);
      expect(second.noveltyPercentage, 0);
    });
  });
}
