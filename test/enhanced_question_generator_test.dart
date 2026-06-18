import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/core/utils/enhanced_question_generator.dart';

void main() {
  group('EnhancedQuestionGenerator', () {
    test('smartShuffle removes duplicates and keeps the correct answer', () {
      final options = EnhancedQuestionGenerator.smartShuffle(
        ['7', '7', '8', '9'],
        '7',
      );

      expect(options.toSet().length, options.length);
      expect(options, contains('7'));
    });

    test('smartShuffle adds a missing correct answer', () {
      final options = EnhancedQuestionGenerator.smartShuffle(
        ['4', '5', '6'],
        '7',
      );

      expect(options, contains('7'));
    });

    test('plausible wrong answers finish for tight ranges', () {
      final wrongs = EnhancedQuestionGenerator.generatePlausibleWrongAnswers(
        1,
        3,
        range: 1,
      );

      expect(wrongs.length, 3);
      expect(wrongs.toSet().length, 3);
      expect(wrongs, isNot(contains(1)));
      expect(wrongs.every((value) => value > 0), isTrue);
    });
  });
}
