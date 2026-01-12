import 'dart:math';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';
import 'package:brightbound_adventures/core/utils/enhanced_question_generator.dart';
import 'package:brightbound_adventures/core/utils/australian_naplan_questions.dart';

/// Comprehensive question generator for Number Nebula (Numeracy/Math)
/// Now with 10x more variety and no repetition!
class NumberNebulaQuestionGenerator {
  static final Random _random = Random();

  /// Generate questions for different math skills and difficulty levels
  static List<NumeracyQuestion> generate({
    required String skill,
    required int difficulty,
    int count = 10,
  }) {
    final questions = <NumeracyQuestion>[];

    // Ensure we generate unique questions
    for (int i = 0; i < count; i++) {
      final question = _generateUniqueQuestion(skill, difficulty, i);
      EnhancedQuestionGenerator.markAsUsed(question.id);
      questions.add(question);
    }

    return questions;
  }

  static NumeracyQuestion _generateUniqueQuestion(
      String skill, int difficulty, int index) {
    // Try to generate a question that wasn't used recently
    for (int attempt = 0; attempt < 5; attempt++) {
      final question = _generateSingleQuestion(skill, difficulty, index);
      if (!EnhancedQuestionGenerator.wasRecentlyUsed(question.id)) {
        return question;
      }
    }
    // If all attempts failed, return the last one anyway
    return _generateSingleQuestion(skill, difficulty, index);
  }

  static NumeracyQuestion _generateSingleQuestion(
      String skill, int difficulty, int index) {
    if (difficulty <= 2) {
      return _generateEasyQuestion(skill, difficulty, index);
    } else if (difficulty <= 4) {
      return _generateMediumQuestion(skill, difficulty, index);
    } else {
      return _generateHardQuestion(skill, difficulty, index);
    }
  }

  static NumeracyQuestion _generateEasyQuestion(
      String skill, int difficulty, int index) {
    final s = skill.toLowerCase();
    final bool isAll = s == 'all' || s.isEmpty;

    final questionTypes = <NumeracyQuestion Function()>[];

    // Simple addition
    if (isAll ||
        s.contains('addition') ||
        s.contains('plus') ||
        s.contains('sum')) {
      // 40% chance to use Australian NAPLAN question
      if (_random.nextDouble() < 0.4) {
        questionTypes.add(() => _fromNAPLAN(
            AustralianNAPLANQuestions.generateYear1Numeracy(
                'addition', difficulty),
            'skill_addition',
            'easy_add_naplan_$index'));
      }

      questionTypes.add(() {
        final a =
            EnhancedQuestionGenerator.getUnusedNumber('addition_easy_a', 1, 5);
        final b =
            EnhancedQuestionGenerator.getUnusedNumber('addition_easy_b', 1, 5);
        final answer = a + b;
        final wrongs =
            EnhancedQuestionGenerator.generatePlausibleWrongAnswers(answer, 3);
        final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'easy_add_${a}_${b}_$index',
          skillId: 'addition',
          question: '$a + $b = ?',
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'Try counting on your fingers: $a... then $b more!',
          explanation:
              '$a + $b = $answer. Count: ${List.generate(a, (i) => '👆').join()} + ${List.generate(b, (i) => '👆').join()} = $answer!',
          difficulty: 1,
        );
      });
    }

    // Counting with emojis
    if (isAll ||
        s.contains('counting') ||
        s.contains('recognition') ||
        s.contains('how many')) {
      // 40% chance to use Australian context
      if (_random.nextDouble() < 0.4) {
        final topic = _random.nextBool() ? 'counting' : 'money';
        questionTypes.add(() => _fromNAPLAN(
            AustralianNAPLANQuestions.generateYear1Numeracy(topic, difficulty),
            'skill_counting',
            'easy_count_naplan_$index'));
      }

      questionTypes.add(() {
        final count =
            EnhancedQuestionGenerator.getUnusedNumber('count_easy', 2, 8);
        final emojis = ['⭐', '🍎', '🌸', '🎈', '🐱', '🚗', '🏀', '🍪'];
        final emoji = emojis[_random.nextInt(emojis.length)];
        final wrongs =
            EnhancedQuestionGenerator.generatePlausibleWrongAnswers(count, 3);
        final options = [count.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, count.toString());

        return NumeracyQuestion(
          id: 'easy_count_${count}_${emoji}_$index',
          skillId: 'counting',
          question: 'How many $emoji?\n${emoji * count}',
          options: shuffled,
          correctIndex: shuffled.indexOf(count.toString()),
          hint: 'Touch each one as you count!',
          explanation:
              'There are $count $emoji! Count them: ${List.generate(count, (i) => '${i + 1}').join(', ')}',
          difficulty: 1,
          type: NumeracyQuestionType.counting,
        );
      });
    }

    // Simple subtraction
    if (isAll ||
        s.contains('subtraction') ||
        s.contains('minus') ||
        s.contains('take away')) {
      // 40% chance to use Australian context
      if (_random.nextDouble() < 0.4) {
        questionTypes.add(() => _fromNAPLAN(
            AustralianNAPLANQuestions.generateYear1Numeracy(
                'subtraction', difficulty),
            'skill_subtraction',
            'easy_sub_naplan_$index'));
      }

      questionTypes.add(() {
        final a = EnhancedQuestionGenerator.getUnusedNumber(
            'subtraction_easy_a', 5, 10);
        final b = EnhancedQuestionGenerator.getUnusedNumber(
            'subtraction_easy_b', 1, a);
        final answer = a - b;
        final wrongs = EnhancedQuestionGenerator.generatePlausibleWrongAnswers(
            answer, 3,
            range: 3);
        final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'easy_sub_${a}_${b}_$index',
          skillId: 'subtraction',
          question: '$a - $b = ?',
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'Start at $a and count backwards $b times.',
          explanation:
              '$a - $b = $answer. If you have $a things and take $b away, $answer are left!',
          difficulty: 1,
        );
      });
    }

    // Number sequencing
    if (isAll ||
        s.contains('sequencing') ||
        s.contains('ordering') ||
        s.contains('patterns')) {
      questionTypes.add(() {
        final start =
            EnhancedQuestionGenerator.getUnusedNumber('sequence_easy', 1, 15);
        final answer = start + 1;
        final wrongs = [answer - 1, answer + 1, answer + 2]
            .where((w) => w != answer)
            .toList();
        final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'easy_seq_${start}_$index',
          skillId: 'sequencing',
          question: 'What number comes after $start?',
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'Count: $start, ___',
          explanation:
              'After $start comes $answer! Keep counting: ${start - 1}, $start, $answer, ${answer + 1}',
          difficulty: 1,
        );
      });
    }

    // Simple comparing
    if (isAll ||
        s.contains('comparing') ||
        s.contains('bigger') ||
        s.contains('smaller')) {
      questionTypes.add(() {
        final a = EnhancedQuestionGenerator.getUnusedNumber('compare_a', 1, 10);
        final b = EnhancedQuestionGenerator.getUnusedNumber('compare_b', 1, 10);
        final answer = a > b ? a : b;
        final options = [
          a.toString(),
          b.toString(),
          (a + b).toString(),
          '${(a + b) / 2}'
        ];
        final shuffled = EnhancedQuestionGenerator.smartShuffle(
            options.toSet().toList(), answer.toString());

        return NumeracyQuestion(
          id: 'easy_compare_${a}_${b}_$index',
          skillId: 'comparing',
          question: 'Which number is bigger: $a or $b?',
          options: shuffled.length >= 2
              ? shuffled.take(4).toList()
              : [a.toString(), b.toString()],
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'Think about which number means more things.',
          explanation: '$answer is bigger than ${a > b ? b : a}!',
          difficulty: 1,
        );
      });
    }

    if (questionTypes.isEmpty) {
      return _generateEasyQuestion('all', difficulty, index);
    }

    return questionTypes[_random.nextInt(questionTypes.length)]();
  }

  static NumeracyQuestion _generateMediumQuestion(
      String skill, int difficulty, int index) {
    final s = skill.toLowerCase();
    final bool isAll = s == 'all' || s.isEmpty;

    final questionTypes = <NumeracyQuestion Function()>[];

    // Addition with larger numbers
    if (isAll || s.contains('addition')) {
      questionTypes.add(() {
        final a =
            EnhancedQuestionGenerator.getUnusedNumber('addition_med_a', 10, 50);
        final b =
            EnhancedQuestionGenerator.getUnusedNumber('addition_med_b', 10, 50);
        final answer = a + b;
        final wrongs = EnhancedQuestionGenerator.generatePlausibleWrongAnswers(
            answer, 3,
            range: 10);
        final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'med_add_${a}_${b}_$index',
          skillId: 'addition',
          question: '$a + $b = ?',
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'Try breaking into tens and ones: ($a) + ($b)',
          explanation: '$a + $b = $answer',
          difficulty: 3,
        );
      });
    }

    // Multiplication
    if (isAll || s.contains('multiplication') || s.contains('groups')) {
      // 40% chance to use Australian context
      if (_random.nextDouble() < 0.4) {
        questionTypes.add(() => _fromNAPLAN(
            AustralianNAPLANQuestions.generateYear3Numeracy(
                'multiplication', difficulty),
            'skill_multiplication',
            'med_mult_naplan_$index'));
      }

      questionTypes.add(() {
        final a =
            EnhancedQuestionGenerator.getUnusedNumber('mult_med_a', 2, 10);
        final b =
            EnhancedQuestionGenerator.getUnusedNumber('mult_med_b', 2, 10);
        final answer = a * b;
        final wrongs = EnhancedQuestionGenerator.generatePlausibleWrongAnswers(
            answer, 3,
            range: a);
        final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'med_mult_${a}_${b}_$index',
          skillId: 'multiplication',
          question: '$a × $b = ?',
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'Think: $a groups of $b. Or add $b + $b + $b... $a times!',
          explanation: '$a × $b = $answer. That\'s $a groups of $b things!',
          difficulty: 3,
        );
      });
    }

    // Word problems with context
    if (isAll || s.contains('word') || s.contains('multi_step')) {
      questionTypes.add(() {
        final a =
            EnhancedQuestionGenerator.getUnusedNumber('word_med_a', 5, 20);
        final b = EnhancedQuestionGenerator.getUnusedNumber('word_med_b', 1, a);
        final answer = a - b;
        final question = MathContexts.generateWordProblem('subtraction', a, b);
        final wrongs =
            EnhancedQuestionGenerator.generatePlausibleWrongAnswers(answer, 3);
        final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'med_word_sub_${a}_${b}_$index',
          skillId: 'word_problems',
          question: question,
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'This is a subtraction problem. Start with the bigger number.',
          explanation: 'Start with $a and subtract $b: $a - $b = $answer',
          difficulty: 3,
        );
      });
    }

    // Skip counting
    if (isAll || s.contains('patterns') || s.contains('skip')) {
      questionTypes.add(() {
        final skip = [2, 5, 10][_random.nextInt(3)];
        final start = skip *
            EnhancedQuestionGenerator.getUnusedNumber('skip_start', 1, 5);
        final answer = start + skip;
        final sequence = [start - skip, start, answer];
        final wrongs = EnhancedQuestionGenerator.generatePlausibleWrongAnswers(
            answer, 3,
            range: skip);
        final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'med_skip_${skip}_${start}_$index',
          skillId: 'patterns',
          question: 'Count by ${skip}s: ${sequence.join(', ')}, ___',
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'Add $skip each time!',
          explanation:
              'Counting by ${skip}s: ${sequence.join(', ')}, $answer. We add $skip each time!',
          difficulty: 3,
        );
      });
    }

    // Place value
    if (isAll || s.contains('place value')) {
      questionTypes.add(() {
        final tens =
            EnhancedQuestionGenerator.getUnusedNumber('place_tens', 1, 9);
        final ones =
            EnhancedQuestionGenerator.getUnusedNumber('place_ones', 0, 9);
        final answer = tens * 10 + ones;
        final wrongs = [tens + ones, tens, ones]
            .where((w) => w != answer)
            .take(3)
            .toList();
        while (wrongs.length < 3) {
          wrongs.add(answer + _random.nextInt(10) + 1);
        }
        final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'med_place_${tens}_${ones}_$index',
          skillId: 'place_value',
          question: '$tens tens and $ones ones equals:',
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'Each ten is worth 10. So $tens tens = ${tens * 10}.',
          explanation:
              '$tens tens = ${tens * 10} and $ones ones = $ones, so ${tens * 10} + $ones = $answer',
          difficulty: 3,
        );
      });
    }

    if (questionTypes.isEmpty) {
      return _generateMediumQuestion('all', difficulty, index);
    }

    return questionTypes[_random.nextInt(questionTypes.length)]();
  }

  static NumeracyQuestion _generateHardQuestion(
      String skill, int difficulty, int index) {
    final s = skill.toLowerCase();
    final bool isAll = s == 'all' || s.isEmpty;

    final questionTypes = <NumeracyQuestion Function()>[];

    // Division
    if (isAll || s.contains('division')) {
      // 40% chance to use Australian context
      if (_random.nextDouble() < 0.4) {
        questionTypes.add(() => _fromNAPLAN(
            AustralianNAPLANQuestions.generateYear3Numeracy(
                'division', difficulty),
            'skill_division',
            'hard_div_naplan_$index'));
      }

      questionTypes.add(() {
        final b =
            EnhancedQuestionGenerator.getUnusedNumber('div_hard_b', 2, 12);
        final answer =
            EnhancedQuestionGenerator.getUnusedNumber('div_hard_ans', 2, 12);
        final a = answer * b;
        final wrongs = EnhancedQuestionGenerator.generatePlausibleWrongAnswers(
            answer, 3,
            range: 3);
        final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'hard_div_${a}_${b}_$index',
          skillId: 'division',
          question: '$a ÷ $b = ?',
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'How many groups of $b fit into $a?',
          explanation: '$a ÷ $b = $answer. Check: $answer × $b = $a ✓',
          difficulty: 5,
        );
      });
    }

    // Fractions
    if (isAll || s.contains('fraction')) {
      // 40% chance to use Australian context
      if (_random.nextDouble() < 0.4) {
        questionTypes.add(() => _fromNAPLAN(
            AustralianNAPLANQuestions.generateYear3Numeracy(
                'fractions', difficulty),
            'skill_fractions',
            'hard_frac_naplan_$index'));
      }

      questionTypes.add(() {
        final fractions = [
          {'value': '1/2', 'desc': 'one half', 'decimal': 0.5},
          {'value': '1/3', 'desc': 'one third', 'decimal': 0.33},
          {'value': '1/4', 'desc': 'one quarter', 'decimal': 0.25},
          {'value': '2/3', 'desc': 'two thirds', 'decimal': 0.67},
          {'value': '3/4', 'desc': 'three quarters', 'decimal': 0.75},
          {'value': '1/5', 'desc': 'one fifth', 'decimal': 0.2},
        ];
        final correct = fractions[_random.nextInt(fractions.length)];
        final wrongFractions = fractions.where((f) => f != correct).toList();
        wrongFractions.shuffle(_random);
        final options = [
          correct['value'] as String,
          ...wrongFractions.take(3).map((f) => f['value'] as String),
        ];
        final shuffled = EnhancedQuestionGenerator.smartShuffle(
            options, correct['value'] as String);

        return NumeracyQuestion(
          id: 'hard_frac_${correct['value']}_$index',
          skillId: 'fractions',
          question: 'Which fraction means ${correct['desc']}?',
          options: shuffled,
          correctIndex: shuffled.indexOf(correct['value'] as String),
          hint: 'The bottom number shows how many equal parts total.',
          explanation: '${correct['value']} means ${correct['desc']}!',
          difficulty: 5,
        );
      });
    }

    // Multi-step word problems
    if (isAll || s.contains('word') || s.contains('multi_step')) {
      questionTypes.add(() {
        final boxes =
            EnhancedQuestionGenerator.getUnusedNumber('word_hard_a', 3, 12);
        final perBox =
            EnhancedQuestionGenerator.getUnusedNumber('word_hard_b', 2, 10);
        final answer = boxes * perBox;
        final question =
            MathContexts.generateWordProblem('multiplication', boxes, perBox);
        final wrongs = EnhancedQuestionGenerator.generatePlausibleWrongAnswers(
            answer, 3,
            range: perBox);
        final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'hard_word_mult_${boxes}_${perBox}_$index',
          skillId: 'word_problems',
          question: question,
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'Multiply $boxes × $perBox to find the total.',
          explanation: '$boxes groups of $perBox = $boxes × $perBox = $answer',
          difficulty: 5,
        );
      });
    }

    // Order of operations (PEMDAS basics)
    if (isAll ||
        s.contains('order') ||
        s.contains('operations') ||
        s.contains('pemdas')) {
      questionTypes.add(() {
        final a = EnhancedQuestionGenerator.getUnusedNumber('pemdas_a', 2, 10);
        final b = EnhancedQuestionGenerator.getUnusedNumber('pemdas_b', 2, 10);
        final c = EnhancedQuestionGenerator.getUnusedNumber('pemdas_c', 1, 10);
        final answer = (a * b) + c;
        final wrongAnswer = a * (b + c); // Common mistake
        final options = [
          answer.toString(),
          wrongAnswer.toString(),
          (a + b * c).toString(),
          (a * b - c).toString(),
        ];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'hard_order_${a}_${b}_${c}_$index',
          skillId: 'order_of_operations',
          question: '($a × $b) + $c = ?',
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: 'Do what\'s in parentheses first!',
          explanation:
              'First: $a × $b = ${a * b}. Then: ${a * b} + $c = $answer',
          difficulty: 5,
        );
      });
    }

    // Percentages (intro level)
    if (isAll || s.contains('percent')) {
      questionTypes.add(() {
        final total = [10, 20, 50, 100][_random.nextInt(4)];
        final percent = [10, 25, 50, 75][_random.nextInt(4)];
        final answer = (total * percent / 100).round();
        final wrongs = EnhancedQuestionGenerator.generatePlausibleWrongAnswers(
            answer, 3,
            range: 5);
        final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
        final shuffled =
            EnhancedQuestionGenerator.smartShuffle(options, answer.toString());

        return NumeracyQuestion(
          id: 'hard_percent_${total}_${percent}_$index',
          skillId: 'percentages',
          question: 'What is $percent% of $total?',
          options: shuffled,
          correctIndex: shuffled.indexOf(answer.toString()),
          hint: '$percent% means $percent out of 100.',
          explanation: '$percent% of $total = $answer',
          difficulty: 5,
        );
      });
    }

    // Measurement & Conversions
    if (isAll || s.contains('measurement') || s.contains('conversion')) {
      questionTypes.add(() => _fromNAPLAN(
          AustralianNAPLANQuestions.generateYear3Numeracy(
              'measurement', difficulty),
          'skill_measurement',
          'hard_measure_naplan_$index'));
    }

    if (questionTypes.isEmpty) {
      return _generateHardQuestion('all', difficulty, index);
    }

    return questionTypes[_random.nextInt(questionTypes.length)]();
  }

  static NumeracyQuestion _fromNAPLAN(
      Map<String, dynamic> naplan, String skillId, String id) {
    final List<String> options = [];
    int correctIndex = 0;

    if (naplan.containsKey('options')) {
      options.addAll((naplan['options'] as List).map((e) => e.toString()));
      correctIndex = options.indexOf(naplan['answer'].toString());
    } else {
      // Generate options if none provided
      final answer = int.tryParse(naplan['answer'].toString()) ?? 0;
      final wrongs =
          EnhancedQuestionGenerator.generatePlausibleWrongAnswers(answer, 3);
      options.add(answer.toString());
      options.addAll(wrongs.map((w) => w.toString()));
      final shuffled =
          EnhancedQuestionGenerator.smartShuffle(options, answer.toString());
      options.clear();
      options.addAll(shuffled);
      correctIndex = options.indexOf(answer.toString());
    }

    return NumeracyQuestion(
      id: id,
      skillId: skillId,
      question: naplan['question'] ?? 'No question text',
      options: options,
      correctIndex: correctIndex,
      difficulty: naplan['difficulty'] ?? 1,
      explanation: naplan['explanation'],
    );
  }
}
