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

/// Higher-order thinking logic questions (Evaluate/Create levels)
/// ACARA codes: ACMNA015, ACMNA029, ACMNA043
class HigherOrderThinkingLogicQuestions {
  static const List<LogicQuestion> questions = [
    // Evaluate level (Level 5)
    LogicQuestion(
      id: 'hot_logic_1',
      skillId: 'skill_logical_reasoning',
      question: 'Two solutions to a puzzle: A) Red, Blue, Green pattern | B) Red, Green, Blue pattern. Which is correct?',
      options: ['A is correct', 'B is correct', 'Both are correct', 'Neither is correct'],
      correctIndex: 2,
      hint: 'Can there be multiple valid patterns?',
      explanation: 'Both A and B are valid patterns! Logic often has multiple correct solutions.',
      difficulty: 4,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🎨',
    ),
    LogicQuestion(
      id: 'hot_logic_2',
      skillId: 'skill_logical_reasoning',
      question: 'Three statements: (1) All dogs bark. (2) Max is a dog. (3) Max barks. Is this valid reasoning?',
      options: ['No, Max might not bark', 'Yes, the conclusion follows logically', 'Maybe, depends on Max\'s mood', 'Cannot determine'],
      correctIndex: 1,
      hint: 'Does statement 3 logically follow from 1 and 2?',
      explanation: 'If all dogs bark AND Max is a dog, then Max MUST bark. Valid deductive reasoning!',
      difficulty: 5,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🐕',
    ),
    LogicQuestion(
      id: 'hot_logic_3',
      skillId: 'skill_logical_reasoning',
      question: 'Which problem-solving strategy is best? A) Try everything randomly B) Identify pattern, test hypothesis',
      options: ['A is faster', 'B is better and more efficient', 'Both are equally good', 'Neither works'],
      correctIndex: 1,
      hint: 'Which method reduces wasted effort?',
      explanation: 'Strategy B (pattern recognition → hypothesis → testing) is more efficient and logical',
      difficulty: 5,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🧠',
    ),
    LogicQuestion(
      id: 'hot_logic_4',
      skillId: 'skill_logical_reasoning',
      question: 'Why might a pattern fail? (Rule: 1, 2, 4, 8, ___ should be 16)',
      options: ['The pattern is wrong', 'Numbers might not always double', 'Context determines if pattern applies', 'There\'s always a reason'],
      correctIndex: 2,
      hint: 'Are all patterns universal?',
      explanation: 'Context matters: the pattern works in math, but not all real-world sequences follow it',
      difficulty: 5,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '📊',
    ),

    // Create level (Level 6)
    LogicQuestion(
      id: 'hot_logic_5',
      skillId: 'skill_logical_reasoning',
      question: 'Create your own pattern rule. Which is best? A) Red, Blue B) Red, Blue, Green, Red, Blue, Green',
      options: ['A is better', 'B shows more complete pattern understanding', 'Both equal', 'Neither is good'],
      correctIndex: 1,
      hint: 'Which demonstrates clearer pattern recognition?',
      explanation: 'B shows a complete cycle revealing the pattern more clearly: repeat of 3-color sequence',
      difficulty: 6,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🔄',
    ),
    LogicQuestion(
      id: 'hot_logic_6',
      skillId: 'skill_logical_reasoning',
      question: 'Design a logic puzzle rule. If A=1, B=2, and you want C to equal 5, how would you make it work?',
      options: ['C = A + B + 2', 'C = A × B + 3', 'C = B × 2 + 1', 'All could work'],
      correctIndex: 3,
      hint: 'Test each formula with A=1 and B=2',
      explanation: 'All three work! A+B+2 = 1+2+2 = 5 ✓, A×B+3 = 1×2+3 = 5 ✓, B×2+1 = 2×2+1 = 5 ✓. Multiple rules can produce the same result!',
      difficulty: 6,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🧩',
    ),
    LogicQuestion(
      id: 'hot_logic_7',
      skillId: 'skill_logical_reasoning',
      question: 'Analyze an error: A student says "2+3 could equal 6". Why is this wrong logically?',
      options: ['It just is', '2+3 always equals 5 in all systems, math is absolute', 'The system changed', 'Logic requires consistency'],
      correctIndex: 3,
      hint: 'What makes logic valid?',
      explanation: 'Logic requires consistent rules; if we change definitions, it\'s no longer standard math',
      difficulty: 6,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '➕',
    ),
    // Year 5-6 deductive reasoning
    LogicQuestion(
      id: 'hot_logic_8',
      skillId: 'skill_logical_reasoning',
      question: 'All squares are rectangles. This shape is a square. What can we conclude?',
      options: [
        'It is not a rectangle',
        'It is a rectangle',
        'It might be a rectangle',
        'We cannot determine this',
      ],
      correctIndex: 1,
      hint: 'If ALL squares are rectangles, and this IS a square...',
      explanation: 'Valid deduction: all squares → rectangles, this is a square, therefore it IS a rectangle. This is syllogistic logic!',
      difficulty: 4,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🟦',
    ),
    LogicQuestion(
      id: 'hot_logic_9',
      skillId: 'skill_logical_reasoning',
      question: '"If it rains, the ground gets wet. The ground IS wet." Does this prove it rained?',
      options: [
        'Yes, definitely',
        'No — something else (sprinklers, flood) could have made it wet',
        'Yes, always',
        'Only if there are no sprinklers',
      ],
      correctIndex: 1,
      hint: 'Can the ground get wet another way?',
      explanation: 'This is a logical fallacy called "affirming the consequent". Wet ground has many possible causes!',
      difficulty: 4,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🌧️',
    ),
    LogicQuestion(
      id: 'hot_logic_10',
      skillId: 'skill_logical_reasoning',
      question: '"Some birds cannot fly." Does this mean no birds can fly?',
      options: [
        'Yes, if some cannot, none can',
        'No — "some cannot" is compatible with "others can"',
        'Yes, birds rarely fly',
        'Cannot determine',
      ],
      correctIndex: 1,
      hint: 'Think of penguins vs eagles — both are birds',
      explanation: '"Some X are not Y" never means "no X are Y". Penguins can\'t fly but eagles can!',
      difficulty: 4,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🦅',
    ),
    // Year 6-7 combinatorics and algebraic thinking
    LogicQuestion(
      id: 'hot_logic_11',
      skillId: 'skill_logical_reasoning',
      question: 'A rule says: multiply the position number by 3, then subtract 1. What is the 6th term?',
      options: ['15', '17', '18', '20'],
      correctIndex: 1,
      hint: '6 × 3 = 18, then subtract 1',
      explanation: 'Term 6: 6 × 3 − 1 = 18 − 1 = 17. The rule is n × 3 − 1!',
      difficulty: 4,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🔢',
    ),
    LogicQuestion(
      id: 'hot_logic_12',
      skillId: 'skill_logical_reasoning',
      question: 'A café offers 3 pasta types and 4 sauce options. How many different pasta-sauce combinations are possible?',
      options: ['7', '9', '12', '16'],
      correctIndex: 2,
      hint: 'Each pasta can pair with each sauce: 3 × 4 = ?',
      explanation: '3 pastas × 4 sauces = 12 combinations total. This is called the multiplication principle!',
      difficulty: 5,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🍝',
    ),
    LogicQuestion(
      id: 'hot_logic_13',
      skillId: 'skill_logical_reasoning',
      question: 'Four students shake hands with each other exactly once. How many handshakes occur in total?',
      options: ['4', '6', '8', '12'],
      correctIndex: 1,
      hint: 'Student 1: 3 shakes, Student 2: 2 new shakes, Student 3: 1 new shake',
      explanation: '3 + 2 + 1 = 6 handshakes. Formula: n×(n−1)÷2 = 4×3÷2 = 6!',
      difficulty: 5,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🤝',
    ),
    LogicQuestion(
      id: 'hot_logic_14',
      skillId: 'skill_logical_reasoning',
      question: '"Most students in my class like cricket, so most Australians must like cricket." What is wrong with this argument?',
      options: [
        'Nothing, it is valid',
        'The sample is too small and unrepresentative of all Australians',
        'Cricket is popular everywhere so it must be right',
        'Statistics always support this type of conclusion',
      ],
      correctIndex: 1,
      hint: 'Is one class a good sample for all of Australia?',
      explanation: 'This is a "hasty generalisation" fallacy — a small or biased sample cannot represent an entire population.',
      difficulty: 5,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '🏏',
    ),
    LogicQuestion(
      id: 'hot_logic_8',
      skillId: 'skill_logical_reasoning',
      question: 'Create a counterexample: "All shortcuts save time." What beats this statement?',
      options: ['Shortcuts always help', 'A shortcut that creates problems later', 'Shortcuts sometimes fail', 'Impossible to disprove'],
      correctIndex: 1,
      hint: 'Find an exception to prove it wrong',
      explanation: 'A shortcut that causes problems later (like cutting corners in homework = wrong answers)',
      difficulty: 6,
      type: LogicQuestionType.multipleChoice,
      imageEmoji: '❌',
    ),
  ];

  static List<LogicQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}
