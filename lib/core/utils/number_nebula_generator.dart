import 'dart:math';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';
import 'package:brightbound_adventures/core/utils/enhanced_question_generator.dart';
import 'package:brightbound_adventures/core/utils/australian_naplan_questions.dart';
import 'package:brightbound_adventures/core/utils/math_word_problem_bank.dart';

/// Comprehensive question generator for Number Nebula (Numeracy/Math)
/// Features adaptive difficulty mixing and 15+ question varieties.
class NumberNebulaQuestionGenerator {
  static final Random _random = Random();

  /// Generate questions for different math skills and difficulty levels
  /// Uses an adaptive mix: requesting Difficulty 3 will include some Easy (warmup) and Hard (challenge) questions.
  static List<NumeracyQuestion> generate({
    required String skill,
    required int difficulty,
    int count = 10,
  }) {
    final questions = <NumeracyQuestion>[];
    
    // Adaptive Mix Calculation
    // If Difficulty 1: 100% Easy
    // If Difficulty 2: 70% Easy, 30% Medium
    // If Difficulty 3: 20% Easy, 60% Medium, 20% Hard
    // If Difficulty 4: 70% Medium, 30% Hard
    // If Difficulty 5: 100% Hard
    
    // We generate a "plan" for the 10 questions
    List<int> questionDifficulties = [];
    for (int i = 0; i < count; i++) {
      if (difficulty == 1) {
        questionDifficulties.add(1);
      } else if (difficulty == 2) {
        questionDifficulties.add(_random.nextDouble() < 0.7 ? 1 : 3); // Map 2 to mix of 1 & 3
      } else if (difficulty == 3) {
        double r = _random.nextDouble();
        if (r < 0.2) {
          questionDifficulties.add(1); // Warmup
        } else if (r < 0.8) {
          questionDifficulties.add(3); // Core
        } else {
          questionDifficulties.add(5); // Challenge
        }
      } else if (difficulty == 4) {
        questionDifficulties.add(_random.nextDouble() < 0.7 ? 3 : 5);
      } else {
        questionDifficulties.add(5);
      }
    }

    // Ensure we generate unique questions
    for (int i = 0; i < count; i++) {
      // Use the calculated difficulty for this specific slot
      final targetDiff = questionDifficulties[i];

      // 20% chance to generate a rich word problem for variety (if diff > 1)
      if (targetDiff > 1 && _random.nextDouble() < 0.2) {
         final q = _generateProceduralWordProblem(targetDiff, i);
         EnhancedQuestionGenerator.markAsUsed(q.id);
         questions.add(q);
      } else {
         final question = _generateUniqueQuestion(skill, targetDiff, i);
         EnhancedQuestionGenerator.markAsUsed(question.id);
         questions.add(question);
      }
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

    // NEW: Time (Basic hour/half-hour)
    if (isAll || s.contains('time') || s.contains('clock')) {
       questionTypes.add(() {
         final hour = _random.nextInt(12) + 1;
         final isHalf = _random.nextBool();
         final minute = isHalf ? 30 : 0;
         
         final timeStr = "$hour:${minute.toString().padLeft(2, '0')}";
         // Generate text description
         final desc = isHalf 
             ? "Half past $hour"
             : "$hour o'clock";
             
         final wrongs = [
             isHalf ? "$hour o'clock" : "Half past $hour",
             isHalf ? "Half past ${hour + 1}" : "${hour + 1} o'clock",
             isHalf ? "Half past ${hour - 1}" : "${hour - 1} o'clock"
         ];
         
         final options = [desc, ...wrongs];
         final shuffled = EnhancedQuestionGenerator.smartShuffle(options, desc);
         
         return NumeracyQuestion(
            id: 'easy_time_${hour}_${minute}_$index',
            skillId: 'time',
            question: 'What time is it?\n🕒 $timeStr',
            options: shuffled,
            correctIndex: shuffled.indexOf(desc),
            hint: isHalf ? 'The minute hand is on the 6.' : 'The minute hand is on the 12 (top).',
            explanation: 'When the time is $timeStr, we say "$desc".',
            difficulty: 1
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

    // NEW: Missing Number (Algebra Logic)
    if (isAll || s.contains('algebra') || s.contains('missing')) {
       questionTypes.add(() {
          final target = EnhancedQuestionGenerator.getUnusedNumber('alg_med_t', 10, 20);
          final part = EnhancedQuestionGenerator.getUnusedNumber('alg_med_p', 1, target - 1);
          final answer = target - part;
          
          final wrongs = EnhancedQuestionGenerator.generatePlausibleWrongAnswers(answer, 3);
          final options = [answer.toString(), ...wrongs.map((w) => w.toString())];
          final shuffled = EnhancedQuestionGenerator.smartShuffle(options, answer.toString());
          
          return NumeracyQuestion(
             id: 'med_alg_${target}_${part}_$index',
             skillId: 'algebra_intro',
             question: '? + $part = $target\nWhat number goes in the ?',
             options: shuffled,
             correctIndex: shuffled.indexOf(answer.toString()),
             hint: 'What number plus $part equals $target?',
             explanation: '$answer + $part = $target',
             difficulty: 3
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
    
    // NEW: Geometry (Sides of shapes)
    if (isAll || s.contains('shape') || s.contains('geometry')) {
       questionTypes.add(() {
         final shapes = [
            {'name': 'Triangle', 'sides': 3},
            {'name': 'Square', 'sides': 4},
            {'name': 'Rectangle', 'sides': 4},
            {'name': 'Pentagon', 'sides': 5},
            {'name': 'Hexagon', 'sides': 6},
            {'name': 'Octagon', 'sides': 8},
         ];
         final shape = shapes[_random.nextInt(shapes.length)];
         final answer = shape['sides'].toString();
         final wrongs = [3,4,5,6,8].where((x) => x != shape['sides']).take(3).map((e) => e.toString()).toList();
         
         final options = [answer, ...wrongs];
         final shuffled = EnhancedQuestionGenerator.smartShuffle(options, answer);
         
         return NumeracyQuestion(
            id: 'hard_geo_${shape['name']}_$index',
            skillId: 'geometry',
            question: 'How many sides does a ${shape['name']} have?',
            options: shuffled,
            correctIndex: shuffled.indexOf(answer),
            hint: 'Think about drawing a ${shape['name']}. Count the lines.',
            explanation: 'A ${shape['name']} has $answer sides.',
            difficulty: 5
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

  /// Procedurally generates a rich word problem using MathWordProblemBank scenarios
  /// Covers Shopping, Adventure (distance/items), Time, and Sharing
  static NumeracyQuestion _generateProceduralWordProblem(int difficulty, int index) {
     // Select a random scenario type
     int type = _random.nextInt(4); // 0: Shopping, 1: Adventure, 2: Time, 3: Sharing
     
     // Correct implementation
     String qText = "";
     int ans = 0;
     String hint = "";
     String exp = "";
     
     if (type == 0) { // Shopping (Addition)
        final s = MathWordProblemBank.shoppingScenarios[_random.nextInt(MathWordProblemBank.shoppingScenarios.length)];
        final q1 = _random.nextInt(8) + 3;
        final q2 = _random.nextInt(5) + 2;
        ans = q1 + q2;
        qText = "You have $q1 ${s['item']}. You ${s['verb']} $q2 more.\n\nHow many ${s['item']} do you have now?";
        hint = "Start with $q1 and add $q2.";
        exp = "$q1 + $q2 = $ans ${s['item']}.";
     } else if (type == 1) { // Adventure (Subtraction)
        final s = MathWordProblemBank.adventureScenarios[_random.nextInt(MathWordProblemBank.adventureScenarios.length)];
        final start = _random.nextInt(8) + 8; // 8 to 15
        final lost = _random.nextInt(5) + 1;
        ans = start - lost;
        
        // "Maya collected 12 seashells but dropped 3. How many does she have left?"
        qText = "${s['character']} ${s['action']} $start ${s['object']} ${s['emoji']}, but dropped $lost of them.\n\nHow many are left?";
        hint = "Subtract the lost ones: $start - $lost.";
        exp = "Remaining: $start - $lost = $ans ${s['object']}.";
     } else if (type == 2) { // Time (Duration)
        final s = MathWordProblemBank.timeScenarios[_random.nextInt(MathWordProblemBank.timeScenarios.length)];
        final startT = _random.nextInt(5) + 1; // 1 to 5
        final duration = _random.nextInt(3) + 1;
        ans = startT + duration;
        
        qText = "It takes $duration hours to ${s['event']}. If you start at $startT o'clock, what time will you finish?";
        hint = "Count forward $duration hours from $startT.";
        exp = "$startT + $duration = $ans o'clock.";
     } else { // Sharing (Division/Groups)
        final s = MathWordProblemBank.sharingScenarios[_random.nextInt(MathWordProblemBank.sharingScenarios.length)];
        final people = _random.nextInt(3) + 2; // 2 to 4 people
        final perPerson = _random.nextInt(4) + 2; // 2 to 5 items each
        final total = people * perPerson;
        ans = perPerson;
        
        qText = "There are $total ${s['item']} to share equally among $people ${s['people']}.\n\nHow many does each person get?";
        hint = "Divide $total by $people.";
        exp = "$total shared by $people means each gets $ans.";
     }

     final options = EnhancedQuestionGenerator.smartShuffle(
        [ans.toString(), (ans+1).toString(), (ans-1).toString(), (ans+2).toString()],
        ans.toString()
     );
     
     return NumeracyQuestion(
        id: 'proc_wp_${type}_$index',
        skillId: 'word_problems',
        question: qText,
        options: options,
        correctIndex: options.indexOf(ans.toString()),
        difficulty: difficulty,
        hint: hint,
        explanation: exp
     );
  }
}
