/// Question models for Puzzle Peaks logic and reasoning activities
class LogicQuestion {
  final String id;
  final String skillId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? hint;
  final String? explanation;
  final int difficulty;
  final LogicQuestionType type;
  final String? imageEmoji;
  final List<String>? sequenceItems; // For pattern/sequence questions

  const LogicQuestion({
    required this.id,
    required this.skillId,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.hint,
    this.explanation,
    this.difficulty = 1,
    this.type = LogicQuestionType.multipleChoice,
    this.imageEmoji,
    this.sequenceItems,
  });

  String get correctAnswer => options[correctIndex];
  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}

enum LogicQuestionType {
  multipleChoice,
  patternCompletion,
  shapeMatching,
  spatialReasoning,
  logicPuzzle,
}

/// Question bank for pattern recognition skill
class PatternRecognitionQuestions {
  static const List<LogicQuestion> questions = [
    // Level 1 - Simple patterns
    LogicQuestion(
      id: 'pat_1',
      skillId: 'skill_pattern_recognition',
      question: 'What comes next?\n🔴 🔵 🔴 🔵 🔴 ?',
      options: ['🔴', '🔵', '🟢', '🟡'],
      correctIndex: 1,
      hint: 'Look at the pattern - red, blue, red, blue...',
      explanation:
          'The pattern alternates: red, blue, red, blue - so blue comes next!',
      difficulty: 1,
      type: LogicQuestionType.patternCompletion,
      imageEmoji: '🎨',
    ),
    LogicQuestion(
      id: 'pat_2',
      skillId: 'skill_pattern_recognition',
      question: 'What comes next?\n1, 2, 3, 4, ?',
      options: ['6', '5', '4', '7'],
      correctIndex: 1,
      hint: 'Count up by one each time',
      explanation: 'The numbers increase by 1: 1, 2, 3, 4, 5!',
      difficulty: 1,
      type: LogicQuestionType.patternCompletion,
      imageEmoji: '🔢',
    ),
    LogicQuestion(
      id: 'pat_3',
      skillId: 'skill_pattern_recognition',
      question: 'What comes next?\n⬆️ ➡️ ⬇️ ⬅️ ⬆️ ?',
      options: ['⬆️', '⬇️', '➡️', '⬅️'],
      correctIndex: 2,
      hint: 'The arrows spin around like a clock',
      explanation:
          'The arrows rotate clockwise: up, right, down, left - then repeats!',
      difficulty: 1,
      type: LogicQuestionType.patternCompletion,
      imageEmoji: '🔄',
    ),
    // Level 2 - Medium patterns
    LogicQuestion(
      id: 'pat_4',
      skillId: 'skill_pattern_recognition',
      question: 'What comes next?\n2, 4, 6, 8, ?',
      options: ['9', '10', '11', '12'],
      correctIndex: 1,
      hint: 'Count by twos!',
      explanation: 'The pattern adds 2 each time: 2, 4, 6, 8, 10!',
      difficulty: 2,
      type: LogicQuestionType.patternCompletion,
      imageEmoji: '➕',
    ),
    LogicQuestion(
      id: 'pat_5',
      skillId: 'skill_pattern_recognition',
      question: 'What comes next?\n🌕 🌖 🌗 🌘 ?',
      options: ['🌕', '🌑', '🌖', '🌙'],
      correctIndex: 1,
      hint: 'The moon is getting darker...',
      explanation: 'The moon phases go from full to new (dark) moon!',
      difficulty: 2,
      type: LogicQuestionType.patternCompletion,
      imageEmoji: '🌙',
    ),
    LogicQuestion(
      id: 'pat_6',
      skillId: 'skill_pattern_recognition',
      question: 'What comes next?\n🔺 🔺🔺 🔺🔺🔺 ?',
      options: ['🔺', '🔺🔺', '🔺🔺🔺🔺', '🔻'],
      correctIndex: 2,
      hint: 'Count how many triangles in each group',
      explanation: 'The pattern is 1, 2, 3, then 4 triangles!',
      difficulty: 2,
      type: LogicQuestionType.patternCompletion,
      imageEmoji: '🔺',
    ),
    // Level 3 - Complex patterns
    LogicQuestion(
      id: 'pat_7',
      skillId: 'skill_pattern_recognition',
      question: 'What comes next?\n1, 1, 2, 3, 5, ?',
      options: ['6', '7', '8', '9'],
      correctIndex: 2,
      hint: 'Add the two previous numbers together',
      explanation: 'Fibonacci! 1+1=2, 1+2=3, 2+3=5, 3+5=8',
      difficulty: 3,
      type: LogicQuestionType.patternCompletion,
      imageEmoji: '🌀',
    ),
    LogicQuestion(
      id: 'pat_8',
      skillId: 'skill_pattern_recognition',
      question: 'Find the odd one out:\n🍎 🍐 🍊 🥕 🍇',
      options: ['🍎', '🍐', '🥕', '🍇'],
      correctIndex: 2,
      hint: 'Most of these are a type of...',
      explanation: 'Carrot is a vegetable - the rest are fruits!',
      difficulty: 3,
      type: LogicQuestionType.patternCompletion,
      imageEmoji: '🔍',
    ),
  ];

  static List<LogicQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for shape matching skill
class ShapeMatchingQuestions {
  static const List<LogicQuestion> questions = [
    // Level 1 - Basic shapes
    LogicQuestion(
      id: 'shape_1',
      skillId: 'skill_shape_matching',
      question: 'How many sides does a triangle have?',
      options: ['2', '3', '4', '5'],
      correctIndex: 1,
      hint: 'Count the straight lines that make up a triangle',
      explanation: 'A triangle has 3 sides - tri means three!',
      difficulty: 1,
      type: LogicQuestionType.shapeMatching,
      imageEmoji: '🔺',
    ),
    LogicQuestion(
      id: 'shape_2',
      skillId: 'skill_shape_matching',
      question: 'Which shape has NO corners?',
      options: ['⬜ Square', '🔺 Triangle', '⭕ Circle', '⬡ Hexagon'],
      correctIndex: 2,
      hint: 'Think about which shape is perfectly round',
      explanation: 'A circle is round and has no corners!',
      difficulty: 1,
      type: LogicQuestionType.shapeMatching,
      imageEmoji: '⭕',
    ),
    LogicQuestion(
      id: 'shape_3',
      skillId: 'skill_shape_matching',
      question: 'Which shape is this? 4 equal sides, 4 corners',
      options: ['Triangle', 'Circle', 'Square', 'Rectangle'],
      correctIndex: 2,
      hint: 'All four sides are the same length',
      explanation: 'A square has 4 equal sides and 4 corners!',
      difficulty: 1,
      type: LogicQuestionType.shapeMatching,
      imageEmoji: '⬜',
    ),
    // Level 2 - More shapes
    LogicQuestion(
      id: 'shape_4',
      skillId: 'skill_shape_matching',
      question: 'A rectangle has how many corners?',
      options: ['3', '4', '5', '6'],
      correctIndex: 1,
      hint: 'Think about a door or book shape',
      explanation: 'Rectangles have 4 corners, like a door!',
      difficulty: 2,
      type: LogicQuestionType.shapeMatching,
      imageEmoji: '📱',
    ),
    LogicQuestion(
      id: 'shape_5',
      skillId: 'skill_shape_matching',
      question: 'An octagon has how many sides?',
      options: ['6', '7', '8', '9'],
      correctIndex: 2,
      hint: 'Octo means eight - like an octopus!',
      explanation: 'An octagon has 8 sides - like a stop sign!',
      difficulty: 2,
      type: LogicQuestionType.shapeMatching,
      imageEmoji: '🛑',
    ),
    // Level 3 - 3D shapes
    LogicQuestion(
      id: 'shape_6',
      skillId: 'skill_shape_matching',
      question: 'What 3D shape is a ball?',
      options: ['Cube', 'Sphere', 'Cylinder', 'Cone'],
      correctIndex: 1,
      hint: 'Think about a perfectly round 3D shape',
      explanation: 'A sphere is a 3D circle - like a ball!',
      difficulty: 3,
      type: LogicQuestionType.shapeMatching,
      imageEmoji: '⚽',
    ),
    LogicQuestion(
      id: 'shape_7',
      skillId: 'skill_shape_matching',
      question: 'How many faces does a cube have?',
      options: ['4', '5', '6', '8'],
      correctIndex: 2,
      hint: 'Think about a dice - count all the flat surfaces',
      explanation: 'A cube has 6 faces - top, bottom, and 4 sides!',
      difficulty: 3,
      type: LogicQuestionType.shapeMatching,
      imageEmoji: '🎲',
    ),
  ];

  static List<LogicQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for spatial reasoning skill
class SpatialReasoningQuestions {
  static const List<LogicQuestion> questions = [
    // Level 1 - Basic spatial
    LogicQuestion(
      id: 'spatial_1',
      skillId: 'skill_spatial_reasoning',
      question: 'If you rotate 🔺 halfway around, what does it look like?',
      options: ['🔺', '🔻', '◀️', '▶️'],
      correctIndex: 1,
      hint: 'Halfway is 180 degrees - it flips upside down',
      explanation: 'Rotating 180° flips the triangle upside down!',
      difficulty: 1,
      type: LogicQuestionType.spatialReasoning,
      imageEmoji: '🔄',
    ),
    LogicQuestion(
      id: 'spatial_2',
      skillId: 'skill_spatial_reasoning',
      question: 'Which arrow points the OPPOSITE direction of ⬆️?',
      options: ['➡️', '⬅️', '⬇️', '↗️'],
      correctIndex: 2,
      hint: 'Opposite of up is...',
      explanation: 'The opposite of up is down!',
      difficulty: 1,
      type: LogicQuestionType.spatialReasoning,
      imageEmoji: '🧭',
    ),
    LogicQuestion(
      id: 'spatial_3',
      skillId: 'skill_spatial_reasoning',
      question: 'What do you see if you look at 🏠 from above?',
      options: [
        'A square/rectangle',
        'A triangle',
        'A circle',
        'The front door'
      ],
      correctIndex: 0,
      hint: 'Think about what the roof looks like from a bird\'s eye view',
      explanation: 'From above, most houses look like squares or rectangles!',
      difficulty: 1,
      type: LogicQuestionType.spatialReasoning,
      imageEmoji: '🏠',
    ),
    // Level 2 - Mirror images
    LogicQuestion(
      id: 'spatial_4',
      skillId: 'skill_spatial_reasoning',
      question: 'What is the mirror image of ◀️?',
      options: ['◀️', '▶️', '🔼', '🔽'],
      correctIndex: 1,
      hint: 'A mirror flips things left to right',
      explanation: 'In a mirror, left and right are swapped!',
      difficulty: 2,
      type: LogicQuestionType.spatialReasoning,
      imageEmoji: '🪞',
    ),
    LogicQuestion(
      id: 'spatial_5',
      skillId: 'skill_spatial_reasoning',
      question:
          'If you fold a paper in half, then cut a heart shape, how many hearts when unfolded?',
      options: ['Half a heart', '1 heart', '2 hearts', '4 hearts'],
      correctIndex: 1,
      hint: 'The fold creates symmetry',
      explanation:
          'When you cut a half-heart on folded paper, unfolding shows 1 whole heart!',
      difficulty: 2,
      type: LogicQuestionType.spatialReasoning,
      imageEmoji: '❤️',
    ),
    // Level 3 - Complex spatial
    LogicQuestion(
      id: 'spatial_6',
      skillId: 'skill_spatial_reasoning',
      question:
          'A cube is unfolded into a flat cross shape (+). How many squares make up this shape?',
      options: ['4', '5', '6', '8'],
      correctIndex: 2,
      hint: 'A cube has 6 faces',
      explanation: 'An unfolded cube (net) shows all 6 faces as squares!',
      difficulty: 3,
      type: LogicQuestionType.spatialReasoning,
      imageEmoji: '📦',
    ),
    LogicQuestion(
      id: 'spatial_7',
      skillId: 'skill_spatial_reasoning',
      question:
          'If you turn ➡️ 90° clockwise (like a clock hand), which direction does it point?',
      options: ['⬆️', '⬇️', '⬅️', '➡️'],
      correctIndex: 1,
      hint: 'Clockwise is the direction clock hands move',
      explanation: 'Right arrow + 90° clockwise = Down arrow!',
      difficulty: 3,
      type: LogicQuestionType.spatialReasoning,
      imageEmoji: '⏰',
    ),
  ];

  static List<LogicQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for logic puzzles skill
class LogicPuzzleQuestions {
  static const List<LogicQuestion> questions = [
    // Level 1 - Simple logic
    LogicQuestion(
      id: 'logic_1',
      skillId: 'skill_logic_puzzles',
      question:
          'Tom is taller than Sam. Sam is taller than Ben. Who is the tallest?',
      options: ['Sam', 'Ben', 'Tom', 'They\'re all equal'],
      correctIndex: 2,
      hint: 'Tom > Sam > Ben means...',
      explanation: 'Tom is tallest, then Sam, then Ben is shortest!',
      difficulty: 1,
      type: LogicQuestionType.logicPuzzle,
      imageEmoji: '📏',
    ),
    LogicQuestion(
      id: 'logic_2',
      skillId: 'skill_logic_puzzles',
      question:
          'All dogs have four legs. Buddy is a dog. How many legs does Buddy have?',
      options: ['2', '3', '4', '5'],
      correctIndex: 2,
      hint: 'If ALL dogs have 4 legs, and Buddy is a dog...',
      explanation: 'Buddy is a dog, all dogs have 4 legs, so Buddy has 4 legs!',
      difficulty: 1,
      type: LogicQuestionType.logicPuzzle,
      imageEmoji: '🐕',
    ),
    // Level 2 - Medium logic
    LogicQuestion(
      id: 'logic_3',
      skillId: 'skill_logic_puzzles',
      question:
          'If it\'s raining, the ground gets wet. The ground is wet. Is it definitely raining?',
      options: ['Yes, definitely', 'No, not definitely', 'Maybe', 'Never'],
      correctIndex: 1,
      hint: 'Could the ground get wet another way?',
      explanation:
          'No! The ground could be wet from a sprinkler or spilled water!',
      difficulty: 2,
      type: LogicQuestionType.logicPuzzle,
      imageEmoji: '🌧️',
    ),
    LogicQuestion(
      id: 'logic_4',
      skillId: 'skill_logic_puzzles',
      question:
          'In a race: Amy finished before Ben, Carl finished after Ben. Who came in 2nd?',
      options: ['Amy', 'Ben', 'Carl', 'Can\'t tell'],
      correctIndex: 1,
      hint: 'Put them in order: Amy > ? > Carl',
      explanation: 'Order: Amy (1st), Ben (2nd), Carl (3rd)!',
      difficulty: 2,
      type: LogicQuestionType.logicPuzzle,
      imageEmoji: '🏃',
    ),
    // Level 3 - Complex logic
    LogicQuestion(
      id: 'logic_5',
      skillId: 'skill_logic_puzzles',
      question:
          'A farmer has 17 sheep. All but 9 run away. How many sheep are left?',
      options: ['8', '9', '17', '0'],
      correctIndex: 1,
      hint: 'Read carefully: "all BUT 9"',
      explanation: '"All but 9" means 9 stay! It\'s a tricky wording puzzle!',
      difficulty: 3,
      type: LogicQuestionType.logicPuzzle,
      imageEmoji: '🐑',
    ),
    LogicQuestion(
      id: 'logic_6',
      skillId: 'skill_logic_puzzles',
      question:
          'If some A are B, and all B are C, then some A are definitely...',
      options: ['C', 'B only', 'Neither', 'All A are C'],
      correctIndex: 0,
      hint: 'If some A are B, and those B are all C...',
      explanation: 'Some A are B, all B are C, so some A must be C!',
      difficulty: 3,
      type: LogicQuestionType.logicPuzzle,
      imageEmoji: '🧠',
    ),
  ];

  static List<LogicQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for problem solving skill
class ProblemSolvingQuestions {
  static const List<LogicQuestion> questions = [
    // Level 1 - Basic problems
    LogicQuestion(
      id: 'prob_1',
      skillId: 'skill_problem_solving',
      question:
          'You need to cross a river but can\'t swim. What\'s the best solution?',
      options: [
        'Fly across',
        'Find a bridge or boat',
        'Drink the river',
        'Give up'
      ],
      correctIndex: 1,
      hint: 'Think about tools or paths humans use',
      explanation: 'Finding a bridge or boat is a practical solution!',
      difficulty: 1,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🌊',
    ),
    LogicQuestion(
      id: 'prob_2',
      skillId: 'skill_problem_solving',
      question: 'Your flashlight won\'t turn on. What should you check FIRST?',
      options: [
        'Buy a new one',
        'Check the batteries',
        'Break it open',
        'Use candles instead'
      ],
      correctIndex: 1,
      hint: 'Start with the simplest thing that could be wrong',
      explanation: 'Check batteries first - it\'s the simplest fix!',
      difficulty: 1,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🔦',
    ),
    // Level 2 - Medium problems
    LogicQuestion(
      id: 'prob_3',
      skillId: 'skill_problem_solving',
      question:
          'You have 3 red socks and 3 blue socks in a dark drawer. How many must you grab to guarantee a matching pair?',
      options: ['2', '3', '4', '6'],
      correctIndex: 1,
      hint: 'Think about the worst case - you might grab different colors',
      explanation: '3 socks guarantees a pair - even if first 2 are different!',
      difficulty: 2,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🧦',
    ),
    LogicQuestion(
      id: 'prob_4',
      skillId: 'skill_problem_solving',
      question:
          'You\'re cooking and realize you\'re missing an ingredient. Best solution?',
      options: [
        'Cancel dinner',
        'Find a substitute ingredient',
        'Panic',
        'Blame someone else'
      ],
      correctIndex: 1,
      hint: 'Problem solvers look for alternatives',
      explanation: 'Finding a substitute shows creative problem solving!',
      difficulty: 2,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '👨‍🍳',
    ),
    // Level 3 - Complex problems
    LogicQuestion(
      id: 'prob_5',
      skillId: 'skill_problem_solving',
      question:
          'A bottle and cork cost \$1.10. The bottle costs \$1 more than the cork. What does the cork cost?',
      options: ['\$0.10', '\$0.05', '\$0.15', '\$0.20'],
      correctIndex: 1,
      hint:
          'If cork = \$0.10, then bottle = \$1.10, but \$0.10 + \$1.10 = \$1.20!',
      explanation:
          'Cork = \$0.05, Bottle = \$1.05. Check: \$0.05 + \$1.05 = \$1.10 ✓',
      difficulty: 3,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🍾',
    ),
    LogicQuestion(
      id: 'prob_6',
      skillId: 'skill_problem_solving',
      question: 'You have a 3L and 5L bucket. How can you measure exactly 4L?',
      options: [
        'Fill 5L, pour 3L out',
        'Fill 3L bucket twice',
        'Fill 5L, pour into 3L until full, 2L remains in 5L bucket; empty 3L; pour 2L into 3L; fill 5L; pour into 3L until full',
        'Impossible',
      ],
      correctIndex: 2,
      hint: 'You need multiple steps and pouring between buckets',
      explanation:
          'This classic puzzle requires several steps of filling and pouring!',
      difficulty: 3,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🪣',
    ),
  ];

  static List<LogicQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for sequence logic skill
class SequenceLogicQuestions {
  static const List<LogicQuestion> questions = [
    // Level 1 - Basic sequences
    LogicQuestion(
      id: 'seq_logic_1',
      skillId: 'skill_sequence_logic',
      question: 'Which comes FIRST when getting ready in the morning?',
      options: ['Eat breakfast', 'Wake up', 'Go to school', 'Pack your bag'],
      correctIndex: 1,
      hint: 'What must happen before everything else?',
      explanation: 'You must wake up first before you can do anything else!',
      difficulty: 1,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '⏰',
    ),
    LogicQuestion(
      id: 'seq_logic_2',
      skillId: 'skill_sequence_logic',
      question: 'Put in order: bake → mix → eat → get ingredients',
      options: [
        'mix, bake, get ingredients, eat',
        'get ingredients, mix, bake, eat',
        'eat, bake, mix, get ingredients',
        'bake, mix, eat, get ingredients',
      ],
      correctIndex: 1,
      hint: 'Think about baking cookies from start to finish',
      explanation: 'Get ingredients → Mix → Bake → Eat!',
      difficulty: 1,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🍪',
    ),
    // Level 2 - Logical ordering
    LogicQuestion(
      id: 'seq_logic_3',
      skillId: 'skill_sequence_logic',
      question: 'What must happen BEFORE you can read a book?',
      options: [
        'Close the book',
        'Learn to read',
        'Write a book',
        'Finish the book'
      ],
      correctIndex: 1,
      hint: 'What skill is required?',
      explanation: 'You need to learn to read first!',
      difficulty: 2,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '📖',
    ),
    LogicQuestion(
      id: 'seq_logic_4',
      skillId: 'skill_sequence_logic',
      question: 'In the water cycle: evaporation → clouds → ? → collection',
      options: ['Evaporation', 'Precipitation', 'More clouds', 'Nothing'],
      correctIndex: 1,
      hint: 'What falls from clouds?',
      explanation:
          'Evaporation → Clouds form → Precipitation (rain/snow) → Collection!',
      difficulty: 2,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '💧',
    ),
    // Level 3 - Complex sequences
    LogicQuestion(
      id: 'seq_logic_5',
      skillId: 'skill_sequence_logic',
      question:
          'A happens before B. C happens after B but before D. What\'s the correct order?',
      options: ['A, B, C, D', 'B, A, C, D', 'A, C, B, D', 'C, A, B, D'],
      correctIndex: 0,
      hint: 'A < B, B < C < D',
      explanation: 'Following the rules: A first, then B, then C, finally D!',
      difficulty: 3,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '📝',
    ),
    LogicQuestion(
      id: 'seq_logic_6',
      skillId: 'skill_sequence_logic',
      question:
          'Cause and effect: What comes LAST?\n"The ice cream melted because it was left in the sun."',
      options: [
        'Ice cream existed',
        'Ice cream left in sun',
        'Ice cream melted',
        'Sun was shining'
      ],
      correctIndex: 2,
      hint: 'What is the final result?',
      explanation:
          'Sun shining → Ice cream left out → Ice cream melts (effect)!',
      difficulty: 3,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🍦',
    ),
  ];

  static List<LogicQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}
