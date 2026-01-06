import 'dart:math';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';

/// Comprehensive question generator for Number Nebula (Numeracy/Math)
class NumberNebulaQuestionGenerator {
  static final Random _random = Random();
  
  /// Generate questions for different math skills and difficulty levels
  static List<NumeracyQuestion> generate({
    required String skill,
    required int difficulty,
    int count = 10,
  }) {
    final questions = <NumeracyQuestion>[];
    
    for (int i = 0; i < count; i++) {
      questions.add(_generateSingleQuestion(difficulty, i));
    }
    
    return questions;
  }
  
  static NumeracyQuestion _generateSingleQuestion(int difficulty, int index) {
    if (difficulty <= 2) {
      return _generateEasyQuestion(index);
    } else if (difficulty <= 4) {
      return _generateMediumQuestion(index);
    } else {
      return _generateHardQuestion(index);
    }
  }
  
  static NumeracyQuestion _generateEasyQuestion(int index) {
    final questionTypes = [
      // Simple addition
      () {
        final a = _random.nextInt(5) + 1;
        final b = _random.nextInt(5) + 1;
        final answer = a + b;
        final options = [
          answer.toString(),
          (answer + 1).toString(),
          (answer - 1).toString(),
          (answer + 2).toString(),
        ]..shuffle(_random);
        
        return NumeracyQuestion(
          id: 'easy_$index',
          skillId: 'addition',
          question: '$a + $b = ?',
          options: options,
          correctIndex: options.indexOf(answer.toString()),
          hint: 'Count on your fingers!',
          difficulty: 1,
        );
      },
      // Counting
      () {
        final count = _random.nextInt(8) + 2;
        final options = [
          count.toString(),
          (count + 1).toString(),
          (count - 1).toString(),
          (count + 2).toString(),
        ]..shuffle(_random);
        
        return NumeracyQuestion(
          id: 'easy_$index',
          skillId: 'counting',
          question: 'How many stars? ${'⭐' * count}',
          options: options,
          correctIndex: options.indexOf(count.toString()),
          hint: 'Count them one by one.',
          difficulty: 1,
        );
      },
    ];
    
    return questionTypes[_random.nextInt(questionTypes.length)]();
  }
  
  static NumeracyQuestion _generateMediumQuestion(int index) {
    final questionTypes = [
      // Addition with larger numbers
      () {
        final a = _random.nextInt(20) + 1;
        final b = _random.nextInt(20) + 1;
        final answer = a + b;
        final options = [
          answer.toString(),
          (answer + 2).toString(),
          (answer - 2).toString(),
          (answer + 5).toString(),
        ]..shuffle(_random);
        
        return NumeracyQuestion(
          id: 'med_$index',
          skillId: 'addition',
          question: '$a + $b = ?',
          options: options,
          correctIndex: options.indexOf(answer.toString()),
          hint: 'Try breaking the numbers into tens and ones.',
          difficulty: 3,
        );
      },
      // Multiplication
      () {
        final a = _random.nextInt(10) + 1;
        final b = _random.nextInt(10) + 1;
        final answer = a * b;
        final options = [
          answer.toString(),
          (answer + a).toString(),
          (answer - a).toString(),
          (answer + b).toString(),
        ]..shuffle(_random);
        
        return NumeracyQuestion(
          id: 'med_$index',
          skillId: 'multiplication',
          question: '$a × $b = ?',
          options: options,
          correctIndex: options.indexOf(answer.toString()),
          hint: 'Think of it as adding $a groups of $b.',
          difficulty: 3,
        );
      },
      // Word problems
      () {
        final apples = _random.nextInt(10) + 5;
        final given = _random.nextInt(apples);
        final answer = apples - given;
        final options = [
          answer.toString(),
          (answer + 1).toString(),
          (answer + 2).toString(),
          (answer - 1).toString(),
        ]..shuffle(_random);
        
        return NumeracyQuestion(
          id: 'med_$index',
          skillId: 'word_problems',
          question: 'Sarah has $apples apples. She gives $given to her friend. How many does she have left?',
          options: options,
          correctIndex: options.indexOf(answer.toString()),
          hint: 'This is a subtraction problem.',
          difficulty: 3,
        );
      },
    ];
    
    return questionTypes[_random.nextInt(questionTypes.length)]();
  }
  
  static NumeracyQuestion _generateHardQuestion(int index) {
    final questionTypes = [
      // Division
      () {
        final b = _random.nextInt(10) + 2;
        final answer = _random.nextInt(10) + 1;
        final a = answer * b;
        final options = [
          answer.toString(),
          (answer + 1).toString(),
          (answer - 1).toString(),
          (answer + 2).toString(),
        ]..shuffle(_random);
        
        return NumeracyQuestion(
          id: 'hard_$index',
          skillId: 'division',
          question: '$a ÷ $b = ?',
          options: options,
          correctIndex: options.indexOf(answer.toString()),
          hint: 'How many times does $b fit into $a?',
          difficulty: 5,
        );
      },
      // Fractions
      () {
        final fractions = ['1/2', '1/3', '1/4', '2/3', '3/4'];
        final descriptions = ['one half', 'one third', 'one quarter', 'two thirds', 'three quarters'];
        final idx = _random.nextInt(fractions.length);
        final options = fractions.toList()..shuffle(_random);
        
        return NumeracyQuestion(
          id: 'hard_$index',
          skillId: 'fractions',
          question: 'Which fraction means ${descriptions[idx]}?',
          options: options,
          correctIndex: options.indexOf(fractions[idx]),
          hint: 'Think about dividing into equal parts.',
          difficulty: 5,
        );
      },
      // Complex word problems
      () {
        final trays = _random.nextInt(8) + 2;
        final perTray = _random.nextInt(8) + 2;
        final answer = trays * perTray;
        final options = [
          answer.toString(),
          (answer + trays).toString(),
          (answer + perTray).toString(),
          (trays + perTray).toString(),
        ]..shuffle(_random);
        
        return NumeracyQuestion(
          id: 'hard_$index',
          skillId: 'word_problems',
          question: 'A baker makes $trays trays of cookies. Each tray has $perTray cookies. How many cookies in total?',
          options: options,
          correctIndex: options.indexOf(answer.toString()),
          hint: 'Multiply the number of trays by cookies per tray.',
          difficulty: 5,
        );
      },
    ];
    
    return questionTypes[_random.nextInt(questionTypes.length)]();
  }
}
