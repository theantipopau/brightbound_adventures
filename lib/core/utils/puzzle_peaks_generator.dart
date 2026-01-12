import 'dart:math';
import 'package:brightbound_adventures/features/logic/models/question.dart';

/// Comprehensive question generator for Puzzle Peaks (Logic & Reasoning)
class PuzzlePeaksQuestionGenerator {
  static final Random _random = Random();

  /// Generate questions for different logic skills and difficulty levels
  static List<LogicQuestion> generate({
    required String skill,
    required int difficulty,
    int count = 10,
  }) {
    final questions = <LogicQuestion>[];

    for (int i = 0; i < count; i++) {
      questions.add(_generateSingleQuestion(skill, difficulty, i));
    }

    return questions;
  }

  static LogicQuestion _generateSingleQuestion(
      String skill, int difficulty, int index) {
    if (difficulty <= 2) {
      return _generateEasyQuestion(skill, difficulty, index);
    } else if (difficulty <= 4) {
      return _generateMediumQuestion(skill, difficulty, index);
    } else {
      return _generateHardQuestion(skill, difficulty, index);
    }
  }

  static LogicQuestion _generateEasyQuestion(
      String skill, int difficulty, int index) {
    final s = skill.toLowerCase();
    final bool isAll = s == 'all' || s.isEmpty;
    final questionTypes = <LogicQuestion Function()>[];

    // Simple patterns
    if (isAll || s.contains('pattern')) {
      questionTypes.add(() {
        final patterns = [
          {
            'pattern': '🔴 🔵 🔴 🔵 🔴',
            'answer': '🔵',
            'options': ['🔵', '🔴', '🟢', '🟡']
          },
          {
            'pattern': '⭐ ⭐ 🌙 ⭐ ⭐',
            'answer': '🌙',
            'options': ['🌙', '⭐', '☀️', '🌟']
          },
          {
            'pattern': '🐶 🐱 🐶 🐱 🐶',
            'answer': '🐱',
            'options': ['🐱', '🐶', '🐭', '🐹']
          },
          {
            'pattern': '🍎 🍌 🍎 🍌 🍎',
            'answer': '🍌',
            'options': ['🍌', '🍎', '🍊', '🍇']
          },
        ];

        final pattern = patterns[_random.nextInt(patterns.length)];
        return LogicQuestion(
          id: 'easy_pat_$index',
          skillId: 'patterns',
          question: 'What comes next in the pattern?\n${pattern['pattern']} ?',
          options: pattern['options'] as List<String>,
          correctIndex: 0,
          hint: 'Look for what repeats.',
          difficulty: 1,
          type: LogicQuestionType.patternCompletion,
        );
      });
    }

    // Shape matching
    if (isAll || s.contains('shape')) {
      questionTypes.add(() {
        final shapes = [
          {
            'question': 'Which shape has 3 sides?',
            'options': ['Triangle', 'Square', 'Circle', 'Rectangle'],
            'correct': 0,
          },
          {
            'question': 'Which shape has 4 equal sides?',
            'options': ['Square', 'Triangle', 'Circle', 'Oval'],
            'correct': 0,
          },
          {
            'question': 'Which shape has no corners?',
            'options': ['Circle', 'Square', 'Triangle', 'Rectangle'],
            'correct': 0,
          },
        ];

        final shape = shapes[_random.nextInt(shapes.length)];
        return LogicQuestion(
          id: 'easy_shape_$index',
          skillId: 'shapes',
          question: shape['question'] as String,
          options: shape['options'] as List<String>,
          correctIndex: shape['correct'] as int,
          hint: 'Think about the shape\'s properties.',
          difficulty: 1,
          type: LogicQuestionType.shapeMatching,
        );
      });
    }

    // Simple sorting
    if (isAll || s.contains('sorting') || s.contains('belong')) {
      questionTypes.add(() {
        final sorting = [
          {
            'question': 'Which item does NOT belong?\n🍎 🍌 🍇 🚗',
            'options': ['🚗', '🍎', '🍌', '🍇'],
            'correct': 0,
          },
          {
            'question': 'Which item does NOT belong?\n⚽ 🏀 🎾 📚',
            'options': ['📚', '⚽', '🏀', '🎾'],
            'correct': 0,
          },
        ];

        final sort = sorting[_random.nextInt(sorting.length)];
        return LogicQuestion(
          id: 'easy_sort_$index',
          skillId: 'sorting',
          question: sort['question'] as String,
          options: sort['options'] as List<String>,
          correctIndex: sort['correct'] as int,
          hint: 'Find the one that\'s different from the others.',
          difficulty: 1,
          type: LogicQuestionType.multipleChoice,
        );
      });
    }

    if (questionTypes.isEmpty) {
      return _generateEasyQuestion('all', difficulty, index);
    }

    return questionTypes[_random.nextInt(questionTypes.length)]();
  }

  static LogicQuestion _generateMediumQuestion(
      String skill, int difficulty, int index) {
    final s = skill.toLowerCase();
    final bool isAll = s == 'all' || s.isEmpty;
    final questionTypes = <LogicQuestion Function()>[];

    // Number patterns
    if (isAll || s.contains('pattern')) {
      questionTypes.add(() {
        final start = _random.nextInt(5) + 1;
        final increment = [2, 3, 5][_random.nextInt(3)];
        final sequence = List.generate(4, (i) => start + i * increment);
        final correct = start + 4 * increment;

        final wrongOptions = [
          correct + 1,
          correct - 1,
          correct + increment,
        ]..shuffle(_random);

        final options = [
          correct.toString(),
          ...wrongOptions.map((n) => n.toString())
        ]..shuffle(_random);

        return LogicQuestion(
          id: 'med_pat_$index',
          skillId: 'patterns',
          question: 'What number comes next?\n${sequence.join(', ')}, ?',
          options: options,
          correctIndex: options.indexOf(correct.toString()),
          hint: 'Find how much the pattern grows each time.',
          difficulty: 3,
          type: LogicQuestionType.patternCompletion,
        );
      });
    }

    // Spatial reasoning
    if (isAll || s.contains('spatial')) {
      questionTypes.add(() {
        final spatial = [
          {
            'question': 'A box is to the LEFT of a ball. Where is the ball?',
            'options': [
              'Right of the box',
              'Left of the box',
              'Inside the box',
              'On top of the box'
            ],
            'correct': 0,
          },
          {
            'question': 'The cat is UNDER the table. Where is the table?',
            'options': [
              'Above the cat',
              'Below the cat',
              'Next to the cat',
              'Behind the cat'
            ],
            'correct': 0,
          },
          {
            'question':
                'The book is BETWEEN the pencil and eraser. What is in the middle?',
            'options': ['Book', 'Pencil', 'Eraser', 'Nothing'],
            'correct': 0,
          },
        ];

        final sp = spatial[_random.nextInt(spatial.length)];
        return LogicQuestion(
          id: 'med_spat_$index',
          skillId: 'spatial',
          question: sp['question'] as String,
          options: sp['options'] as List<String>,
          correctIndex: sp['correct'] as int,
          hint: 'Think about the positions carefully.',
          difficulty: 3,
          type: LogicQuestionType.spatialReasoning,
        );
      });
    }

    // Logic puzzles
    if (isAll || s.contains('logic')) {
      questionTypes.add(() {
        final puzzles = [
          {
            'question':
                'All cats have tails. Fluffy is a cat. Does Fluffy have a tail?',
            'options': ['Yes', 'No', 'Maybe', 'Not enough information'],
            'correct': 0,
          },
          {
            'question':
                'If it rains, the grass gets wet. It rained today. Is the grass wet?',
            'options': ['Yes', 'No', 'Maybe', 'Not enough information'],
            'correct': 0,
          },
          {
            'question':
                'Tom is taller than Sue. Sue is taller than Jim. Who is the tallest?',
            'options': ['Tom', 'Sue', 'Jim', 'All the same height'],
            'correct': 0,
          },
        ];

        final puzzle = puzzles[_random.nextInt(puzzles.length)];
        return LogicQuestion(
          id: 'med_log_$index',
          skillId: 'logic',
          question: puzzle['question'] as String,
          options: puzzle['options'] as List<String>,
          correctIndex: puzzle['correct'] as int,
          hint: 'Use the information given to figure it out.',
          difficulty: 3,
          type: LogicQuestionType.logicPuzzle,
        );
      });
    }

    if (questionTypes.isEmpty) {
      return _generateMediumQuestion('all', difficulty, index);
    }

    return questionTypes[_random.nextInt(questionTypes.length)]();
  }

  static LogicQuestion _generateHardQuestion(
      String skill, int difficulty, int index) {
    final s = skill.toLowerCase();
    final bool isAll = s == 'all' || s.isEmpty;
    final questionTypes = <LogicQuestion Function()>[];

    // Complex patterns
    if (isAll || s.contains('pattern')) {
      questionTypes.add(() {
        final patterns = [
          {
            'question': 'What comes next?\n2, 4, 8, 16, ?',
            'options': ['32', '20', '24', '18'],
            'hint': 'Each number is multiplied by 2',
          },
          {
            'question': 'What comes next?\n1, 4, 9, 16, ?',
            'options': ['25', '20', '21', '24'],
            'hint': 'These are square numbers: 1², 2², 3², 4²...',
          },
          {
            'question': 'What comes next?\n1, 1, 2, 3, 5, ?',
            'options': ['8', '6', '7', '9'],
            'hint': 'Add the previous two numbers together',
          },
        ];

        final pattern = patterns[_random.nextInt(patterns.length)];
        return LogicQuestion(
          id: 'hard_pat_$index',
          skillId: 'patterns',
          question: pattern['question'] as String,
          options: pattern['options'] as List<String>,
          correctIndex: 0,
          hint: pattern['hint'] as String,
          difficulty: 5,
          type: LogicQuestionType.patternCompletion,
        );
      });
    }

    // Deductive reasoning
    if (isAll || s.contains('logic') || s.contains('reasoning')) {
      questionTypes.add(() {
        final deductive = [
          {
            'question':
                'At a party: Everyone wearing red has cake. Maria has cake. Is Maria wearing red?',
            'options': [
              'Can\'t tell for sure',
              'Yes, definitely',
              'No, definitely',
              'She\'s wearing blue'
            ],
            'correct': 0,
            'explanation':
                'We know red wearers have cake, but others might too.',
          },
          {
            'question':
                'All squares are rectangles. This shape is a rectangle. Is it a square?',
            'options': ['Can\'t tell for sure', 'Yes', 'No', 'Sometimes'],
            'correct': 0,
            'explanation': 'Not all rectangles are squares.',
          },
        ];

        final ded = deductive[_random.nextInt(deductive.length)];
        return LogicQuestion(
          id: 'hard_ded_$index',
          skillId: 'reasoning',
          question: ded['question'] as String,
          options: ded['options'] as List<String>,
          correctIndex: ded['correct'] as int,
          hint: 'Be careful! The answer might not be obvious.',
          explanation: ded['explanation'] as String,
          difficulty: 5,
          type: LogicQuestionType.logicPuzzle,
        );
      });
    }

    // Problem solving
    if (isAll || s.contains('problem') || s.contains('solving')) {
      questionTypes.add(() {
        final problems = [
          {
            'question':
                'You have 3 boxes. One has a prize. You pick Box A. The host opens Box B (empty). Should you switch to Box C?',
            'options': [
              'Yes, switch',
              'No, stay',
              'Doesn\'t matter',
              'Pick a new box'
            ],
            'correct': 0,
            'explanation':
                'Switching gives you better odds (Monty Hall problem).',
          },
          {
            'question':
                'A snail climbs 3 feet up a wall each day but slides 2 feet down each night. The wall is 10 feet. How many days to reach the top?',
            'options': ['8 days', '10 days', '5 days', '7 days'],
            'correct': 0,
            'explanation': 'On day 8, it climbs to 10 feet before sliding.',
          },
        ];

        final prob = problems[_random.nextInt(problems.length)];
        return LogicQuestion(
          id: 'hard_prob_$index',
          skillId: 'problem_solving',
          question: prob['question'] as String,
          options: prob['options'] as List<String>,
          correctIndex: prob['correct'] as int,
          hint: 'Think carefully through each step.',
          explanation: prob['explanation'] as String,
          difficulty: 5,
          type: LogicQuestionType.logicPuzzle,
        );
      });
    }

    if (questionTypes.isEmpty) {
      return _generateHardQuestion('all', difficulty, index);
    }

    return questionTypes[_random.nextInt(questionTypes.length)]();
  }
}
