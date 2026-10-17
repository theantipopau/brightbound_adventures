import 'package:brightbound_adventures/core/utils/australian_naplan_questions.dart';
import 'package:brightbound_adventures/core/utils/math_word_problem_bank.dart';
import 'package:flutter_test/flutter_test.dart';

/// B1 gate: the full pool must be able to produce ≥ 1,000 unique question
/// texts across all topics, and within a topic/difficulty the generator
/// must not emit the same text twice in a wide sample.
void main() {
  // Every numeracy topic × difficulty of the NAPLAN generator.
  const year1Numeracy = ['addition', 'subtraction', 'counting', 'money'];
  const year3Numeracy = [
    'multiplication',
    'division',
    'fractions',
    'measurement'
  ];
  const year1Literacy = ['spelling', 'reading', 'grammar'];
  const year3Literacy = ['vocabulary', 'comprehension', 'punctuation'];

  const difficulties = [1, 2, 3];

  setUp(() => AustralianNAPLANQuestions.resetSessionMemory());

  test('all question banks produce ≥ 1,000 unique question texts overall', () {
    final unique = <String>{};

    void draw(String Function() template) {
      final text = template();
      if (text.isNotEmpty) unique.add(text);
    }

    for (final difficulty in difficulties) {
      for (final topic in year1Numeracy) {
        for (var i = 0; i < 260; i++) {
          draw(() => AustralianNAPLANQuestions.generateYear1Numeracy(
              topic, difficulty)['question'] as String);
        }
      }
      for (final topic in year3Numeracy) {
        for (var i = 0; i < 260; i++) {
          draw(() => AustralianNAPLANQuestions.generateYear3Numeracy(
              topic, difficulty)['question'] as String);
        }
      }
      for (final topic in year1Literacy) {
        for (var i = 0; i < 120; i++) {
          draw(() => AustralianNAPLANQuestions.generateYear1Literacy(
              topic, difficulty)['question'] as String);
        }
      }
      for (final topic in year3Literacy) {
        for (var i = 0; i < 120; i++) {
          draw(() => AustralianNAPLANQuestions.generateYear3Literacy(
              topic, difficulty)['question'] as String);
        }
      }
    }

    // Parameterised word-problem bank texts (fixed inputs count as unique).
    for (var a = 2; a <= 12; a++) {
      for (var b = 2; b <= 9; b++) {
        unique.add(MathWordProblemBank.generateAddition(a, b, 'medium'));
        unique.add(MathWordProblemBank.generateSubtraction(a, b, 'medium'));
        if (a <= 9 && b <= 9) {
          unique.add(MathWordProblemBank.generateMultiplication(a, b, 'hard'));
        }
        unique.add(MathWordProblemBank.generateDivision(a * b, b, 'medium'));
      }
      unique.add(MathWordProblemBank.generateMeasurement(a, 'cm'));
      unique.add(MathWordProblemBank.generateMoney(a * 10, 'medium'));
      unique.add(MathWordProblemBank.generateComparison(a, a + 1, 'easy'));
    }

    expect(unique.length, greaterThanOrEqualTo(1000));
  });

  test('no duplicate text within the same topic at the same difficulty', () {
    final withinTopic = <String>[]; // topic::text
    final seen = <String>{};
    Object? duplicates;

    void add(String topic, Map<String, dynamic> question) {
      final text = question['question'] as String;
      final key = '$topic::$text';
      if (!seen.add(key)) duplicates ??= key;
      withinTopic.add(key);
    }

    // 50 samples per topic × difficulty sits below every widened pair
    // capacity (addition 100, ordered subtraction 55, medium 196, hard 256),
    // and pair memory makes every draw unique until a row is exhausted —
    // so duplicates can only appear through a real generator flaw, never
    // through sampling statistics.
    for (final difficulty in difficulties) {
      for (final topic in year1Numeracy) {
        for (var i = 0; i < 50; i++) {
          add(
              'y1-num/$topic/d$difficulty',
              AustralianNAPLANQuestions.generateYear1Numeracy(
                  topic, difficulty));
        }
      }
      for (final topic in year3Numeracy) {
        for (var i = 0; i < 50; i++) {
          add(
              'y3-num/$topic/d$difficulty',
              AustralianNAPLANQuestions.generateYear3Numeracy(
                  topic, difficulty));
        }
      }
    }

    expect(duplicates, isNull, reason: 'first duplicate found: $duplicates');
  });
}
