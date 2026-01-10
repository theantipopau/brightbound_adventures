/// Question model for literacy activities
class LiteracyQuestion {
  final String id;
  final String skillId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? hint;
  final String? explanation;
  final int difficulty; // 1-5

  const LiteracyQuestion({
    required this.id,
    required this.skillId,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.hint,
    this.explanation,
    this.difficulty = 1,
  });

  String get correctAnswer => options[correctIndex];

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}

/// Question bank for homophones skill
class HomophoneQuestions {
  static const List<LiteracyQuestion> questions = [
    // Level 1 - Basic homophones
    LiteracyQuestion(
      id: 'hom_1',
      skillId: 'skill_homophones',
      question: 'Which word means "a place to live"?',
      options: ['their', 'there', 'they\'re'],
      correctIndex: 1,
      hint: 'Think about a location',
      explanation:
          '"There" refers to a place. "Their" shows ownership. "They\'re" means "they are".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'hom_2',
      skillId: 'skill_homophones',
      question: 'Complete: "_____ going to the park."',
      options: ['Their', 'There', 'They\'re'],
      correctIndex: 2,
      hint: 'Try replacing with "they are"',
      explanation:
          '"They\'re" is short for "they are". "They are going to the park."',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'hom_3',
      skillId: 'skill_homophones',
      question: 'Complete: "The dog buried _____ bone."',
      options: ['its', 'it\'s'],
      correctIndex: 0,
      hint: 'Does "it is" make sense here?',
      explanation: '"Its" shows ownership. "It\'s" means "it is".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'hom_4',
      skillId: 'skill_homophones',
      question: 'Which word means "also"?',
      options: ['to', 'too', 'two'],
      correctIndex: 1,
      hint: 'It has an extra "o"',
      explanation:
          '"Too" means "also" or "very". "To" is a direction. "Two" is the number 2.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'hom_5',
      skillId: 'skill_homophones',
      question: 'Complete: "I have _____ apples."',
      options: ['to', 'too', 'two'],
      correctIndex: 2,
      hint: 'Think about the number',
      explanation: '"Two" is the number 2.',
      difficulty: 1,
    ),
    // Level 2 - Intermediate homophones
    LiteracyQuestion(
      id: 'hom_6',
      skillId: 'skill_homophones',
      question: 'Complete: "The wind _____ through the trees."',
      options: ['blue', 'blew'],
      correctIndex: 1,
      hint: 'Past tense of "blow"',
      explanation: '"Blew" is past tense of blow. "Blue" is a colour.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'hom_7',
      skillId: 'skill_homophones',
      question: 'Complete: "She _____ the book on the shelf."',
      options: ['red', 'read'],
      correctIndex: 1,
      hint: 'Past tense of reading',
      explanation:
          '"Read" (pronounced "red") is past tense of read. "Red" is a colour.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'hom_8',
      skillId: 'skill_homophones',
      question: 'Complete: "The knight wore shiny _____."',
      options: ['armor', 'armour'],
      correctIndex: 1,
      hint: 'Australian English spelling',
      explanation: 'In Australian English, we use "armour" with a "u".',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'hom_9',
      skillId: 'skill_homophones',
      question: 'Which word sounds like "nose"?',
      options: ['knows', 'gnaws', 'nos'],
      correctIndex: 0,
      hint: 'Think about understanding something',
      explanation:
          '"Knows" sounds like "nose" and means to understand or be aware.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'hom_10',
      skillId: 'skill_homophones',
      question: 'Complete: "The princess lived in a _____."',
      options: ['castle', 'cassel'],
      correctIndex: 0,
      hint: 'A large building for royalty',
      explanation: '"Castle" is the correct spelling for a royal fortress.',
      difficulty: 2,
    ),
    // Level 3 - Advanced homophones
    LiteracyQuestion(
      id: 'hom_11',
      skillId: 'skill_homophones',
      question: 'Complete: "The _____ of the movie was exciting."',
      options: ['scene', 'seen'],
      correctIndex: 0,
      hint: 'A part of a show or movie',
      explanation:
          '"Scene" is a part of a movie. "Seen" is past participle of see.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'hom_12',
      skillId: 'skill_homophones',
      question: 'Complete: "I haven\'t _____ that movie yet."',
      options: ['scene', 'seen'],
      correctIndex: 1,
      hint: 'Past participle of "see"',
      explanation:
          '"Seen" is used with "have/has/had". "Have seen" is correct.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'hom_13',
      skillId: 'skill_homophones',
      question: 'Complete: "The _____ in the story was a brave king."',
      options: ['principal', 'principle'],
      correctIndex: 0,
      hint: 'The main character',
      explanation:
          '"Principal" means main/chief. "Principle" is a belief or rule.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'hom_14',
      skillId: 'skill_homophones',
      question: 'Complete: "Honesty is an important _____."',
      options: ['principal', 'principle'],
      correctIndex: 1,
      hint: 'A moral belief',
      explanation:
          '"Principle" is a rule or belief. "Principal" means main/chief person.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'hom_15',
      skillId: 'skill_homophones',
      question: 'Complete: "The weather will _____ our picnic plans."',
      options: ['affect', 'effect'],
      correctIndex: 0,
      hint: 'A verb meaning "to influence"',
      explanation:
          '"Affect" (verb) means to influence. "Effect" (noun) is the result.',
      difficulty: 3,
    ),
  ];

  static List<LiteracyQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for apostrophes skill
class ApostropheQuestions {
  static const List<LiteracyQuestion> questions = [
    // Level 1 - Contractions
    LiteracyQuestion(
      id: 'apos_1',
      skillId: 'skill_apostrophes',
      question: 'Which is the correct contraction for "do not"?',
      options: ['dont', 'don\'t', 'do\'nt'],
      correctIndex: 1,
      hint: 'The apostrophe replaces the missing letter',
      explanation: 'In "don\'t", the apostrophe replaces the "o" in "not".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'apos_2',
      skillId: 'skill_apostrophes',
      question: 'Which is correct for "I am"?',
      options: ['I\'m', 'Im', 'I,m'],
      correctIndex: 0,
      hint: 'Use an apostrophe to show missing letters',
      explanation:
          '"I\'m" is the contraction. The apostrophe replaces the "a" in "am".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'apos_3',
      skillId: 'skill_apostrophes',
      question: 'Which is the correct contraction for "cannot"?',
      options: ['can\'t', 'cant', 'ca\'nt'],
      correctIndex: 0,
      hint: 'The apostrophe goes where letters are missing',
      explanation:
          '"Can\'t" is correct. The apostrophe replaces "no" in "cannot".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'apos_4',
      skillId: 'skill_apostrophes',
      question: 'Which is the correct contraction for "we are"?',
      options: ['were', 'we\'re', 'wer\'e'],
      correctIndex: 1,
      hint: 'The apostrophe replaces the "a"',
      explanation:
          '"We\'re" is correct. Don\'t confuse it with "were" (past tense of be).',
      difficulty: 1,
    ),
    // Level 2 - Possession
    LiteracyQuestion(
      id: 'apos_5',
      skillId: 'skill_apostrophes',
      question: 'How do you show the ball belongs to the dog?',
      options: ['the dogs ball', 'the dog\'s ball', 'the dogs\' ball'],
      correctIndex: 1,
      hint: 'One dog owns the ball',
      explanation: 'For singular possession, add \'s: "the dog\'s ball".',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'apos_6',
      skillId: 'skill_apostrophes',
      question: 'How do you show the toys belong to many children?',
      options: [
        'the childrens toys',
        'the children\'s toys',
        'the childrens\' toys'
      ],
      correctIndex: 1,
      hint: '"Children" is already plural',
      explanation: 'For plural nouns not ending in s, add \'s: "children\'s".',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'apos_7',
      skillId: 'skill_apostrophes',
      question: 'How do you show the house belongs to James?',
      options: ['James house', 'James\' house', 'Jame\'s house'],
      correctIndex: 1,
      hint: 'Names ending in "s" just need an apostrophe',
      explanation:
          'For names ending in s, you can add just \': "James\' house".',
      difficulty: 2,
    ),
    // Level 3 - Mixed
    LiteracyQuestion(
      id: 'apos_8',
      skillId: 'skill_apostrophes',
      question: 'Which sentence uses the apostrophe correctly?',
      options: [
        'The cat\'s are sleeping.',
        'The cats\' toys are everywhere.',
        'The cat\'s toy\'s are new.',
      ],
      correctIndex: 1,
      hint: 'Think about what belongs to whom',
      explanation: '"Cats\' toys" shows toys belonging to multiple cats.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'apos_9',
      skillId: 'skill_apostrophes',
      question: 'Select the correct sentence:',
      options: [
        'It\'s been a long day.',
        'Its been a long day.',
        'Its\' been a long day.',
      ],
      correctIndex: 0,
      hint: '"It is" or "it has"?',
      explanation:
          '"It\'s" = "it is" or "it has". "Its" shows possession (no apostrophe).',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'apos_10',
      skillId: 'skill_apostrophes',
      question: 'Which is correct for "who is"?',
      options: ['whose', 'who\'s', 'whos'],
      correctIndex: 1,
      hint: 'A contraction needs an apostrophe',
      explanation: '"Who\'s" = "who is". "Whose" shows possession.',
      difficulty: 3,
    ),
  ];

  static List<LiteracyQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for punctuation skill
class PunctuationQuestions {
  static const List<LiteracyQuestion> questions = [
    // Level 1 - Basic punctuation
    LiteracyQuestion(
      id: 'punc_1',
      skillId: 'skill_comma_usage',
      question: 'Which sentence has correct punctuation?',
      options: [
        'I like apples oranges and bananas',
        'I like apples, oranges, and bananas.',
        'I like apples oranges, and bananas',
      ],
      correctIndex: 1,
      hint: 'Lists need commas between items',
      explanation:
          'Use commas to separate items in a list, and a full stop at the end.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'punc_2',
      skillId: 'skill_comma_usage',
      question: 'What punctuation ends a question?',
      options: ['Full stop (.)', 'Question mark (?)', 'Exclamation mark (!)'],
      correctIndex: 1,
      hint: 'Think about what a question needs',
      explanation: 'Questions always end with a question mark (?).',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'punc_3',
      skillId: 'skill_comma_usage',
      question: 'Which sentence shows excitement correctly?',
      options: [
        'I won the race.',
        'I won the race!',
        'I won the race?',
      ],
      correctIndex: 1,
      hint: 'Excitement uses a special mark',
      explanation: 'Exclamation marks (!) show strong emotion like excitement.',
      difficulty: 1,
    ),
    // Level 2 - Commas
    LiteracyQuestion(
      id: 'punc_4',
      skillId: 'skill_comma_usage',
      question: 'Where should the comma go?\n"After school I went home"',
      options: [
        'After, school I went home',
        'After school, I went home',
        'After school I went, home',
      ],
      correctIndex: 1,
      hint: 'Commas go after introductory phrases',
      explanation:
          'Use a comma after introductory phrases like "After school".',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'punc_5',
      skillId: 'skill_comma_usage',
      question: 'Which sentence uses commas correctly?',
      options: [
        '"Hello" said Mum, "how was your day?"',
        '"Hello," said Mum, "how was your day?"',
        '"Hello", said Mum "how was your day?"',
      ],
      correctIndex: 1,
      hint: 'Speech marks have special comma rules',
      explanation: 'Commas go inside speech marks and before "said".',
      difficulty: 2,
    ),
    // Level 3 - Complex punctuation
    LiteracyQuestion(
      id: 'punc_6',
      skillId: 'skill_comma_usage',
      question: 'Which sentence uses a semicolon correctly?',
      options: [
        'I love reading; it\'s my favourite hobby.',
        'I love; reading it\'s my favourite hobby.',
        'I love reading it\'s; my favourite hobby.',
      ],
      correctIndex: 0,
      hint: 'Semicolons join related complete sentences',
      explanation: 'Semicolons connect two related independent clauses.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'punc_7',
      skillId: 'skill_comma_usage',
      question: 'Which sentence uses a colon correctly?',
      options: [
        'I need: eggs, milk, and bread.',
        'I need three things: eggs, milk, and bread.',
        'I: need eggs, milk, and bread.',
      ],
      correctIndex: 1,
      hint: 'Colons introduce lists after a complete thought',
      explanation: 'Use a colon after a complete sentence to introduce a list.',
      difficulty: 3,
    ),
  ];

  static List<LiteracyQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for rhyming words skill
class RhymingQuestions {
  static const List<LiteracyQuestion> questions = [
    LiteracyQuestion(
      id: 'rhyme_1',
      skillId: 'skill_rhyming',
      question: 'Which word rhymes with "cat"?',
      options: ['dog', 'bat', 'car', 'cup'],
      correctIndex: 1,
      hint: 'Listen to the ending sounds',
      explanation: '"Cat" and "bat" both end with "-at"!',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'rhyme_2',
      skillId: 'skill_rhyming',
      question: 'Which word rhymes with "fun"?',
      options: ['fan', 'run', 'fly', 'fox'],
      correctIndex: 1,
      hint: 'Think about words ending in "-un"',
      explanation: '"Fun" and "run" both end with "-un"!',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'rhyme_3',
      skillId: 'skill_rhyming',
      question: 'Which word rhymes with "tree"?',
      options: ['bee', 'tea', 'toe', 'try'],
      correctIndex: 0,
      hint: 'Which word sounds like "ree"?',
      explanation: '"Tree" and "bee" both have the long "ee" sound!',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'rhyme_4',
      skillId: 'skill_rhyming',
      question: 'Which word rhymes with "light"?',
      options: ['let', 'night', 'long', 'look'],
      correctIndex: 1,
      hint: 'Listen for the "-ight" sound',
      explanation: '"Light" and "night" both end with "-ight"!',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'rhyme_5',
      skillId: 'skill_rhyming',
      question: 'Which word rhymes with "make"?',
      options: ['milk', 'bake', 'more', 'mark'],
      correctIndex: 1,
      hint: 'Think of words ending in "-ake"',
      explanation: '"Make" and "bake" both end with "-ake"!',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'rhyme_6',
      skillId: 'skill_rhyming',
      question: 'Which word rhymes with "brain"?',
      options: ['train', 'brown', 'bring', 'brand'],
      correctIndex: 0,
      hint: 'Listen for the "-ain" sound',
      explanation: '"Brain" and "train" both end with "-ain"!',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'rhyme_7',
      skillId: 'skill_rhyming',
      question: 'Which word does NOT rhyme with "blue"?',
      options: ['flew', 'shoe', 'blow', 'true'],
      correctIndex: 2,
      hint: 'One ending sounds different',
      explanation:
          '"Blue", "flew", "shoe", and "true" rhyme. "Blow" ends differently!',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'rhyme_8',
      skillId: 'skill_rhyming',
      question: 'Which word rhymes with "strong"?',
      options: ['song', 'stone', 'stand', 'story'],
      correctIndex: 0,
      hint: 'Listen for the "-ong" sound',
      explanation: '"Strong" and "song" both end with "-ong"!',
      difficulty: 2,
    ),
  ];

  static List<LiteracyQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for syllable counting skill
class SyllableQuestions {
  static const List<LiteracyQuestion> questions = [
    LiteracyQuestion(
      id: 'syll_1',
      skillId: 'skill_syllables',
      question: 'How many syllables in "cat"?',
      options: ['1', '2', '3', '4'],
      correctIndex: 0,
      hint: 'Clap it out: cat',
      explanation: '"Cat" has 1 syllable: cat',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'syll_2',
      skillId: 'skill_syllables',
      question: 'How many syllables in "happy"?',
      options: ['1', '2', '3', '4'],
      correctIndex: 1,
      hint: 'Clap it out: hap-py',
      explanation: '"Happy" has 2 syllables: hap-py',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'syll_3',
      skillId: 'skill_syllables',
      question: 'How many syllables in "dinosaur"?',
      options: ['2', '3', '4', '5'],
      correctIndex: 1,
      hint: 'Clap it out: di-no-saur',
      explanation: '"Dinosaur" has 3 syllables: di-no-saur',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'syll_4',
      skillId: 'skill_syllables',
      question: 'How many syllables in "butterfly"?',
      options: ['2', '3', '4', '5'],
      correctIndex: 1,
      hint: 'Clap it out: but-ter-fly',
      explanation: '"Butterfly" has 3 syllables: but-ter-fly',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'syll_5',
      skillId: 'skill_syllables',
      question: 'How many syllables in "education"?',
      options: ['3', '4', '5', '6'],
      correctIndex: 1,
      hint: 'Clap it out: ed-u-ca-tion',
      explanation: '"Education" has 4 syllables: ed-u-ca-tion',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'syll_6',
      skillId: 'skill_syllables',
      question: 'How many syllables in "elephant"?',
      options: ['2', '3', '4', '5'],
      correctIndex: 1,
      hint: 'Clap it out: el-e-phant',
      explanation: '"Elephant" has 3 syllables: el-e-phant',
      difficulty: 2,
    ),
  ];

  static List<LiteracyQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for spelling patterns skill
class SpellingQuestions {
  static const List<LiteracyQuestion> questions = [
    LiteracyQuestion(
      id: 'spell_1',
      skillId: 'skill_spelling',
      question: 'Which spelling is correct?',
      options: ['freind', 'friend', 'frend', 'friand'],
      correctIndex: 1,
      hint: 'Remember: "i before e"',
      explanation: '"Friend" is spelled with "ie": f-r-i-e-n-d',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'spell_2',
      skillId: 'skill_spelling',
      question: 'Which spelling is correct?',
      options: ['because', 'becuase', 'becaus', 'becase'],
      correctIndex: 0,
      hint: 'Think: "Big Elephants Can Always Understand Small Elephants"',
      explanation: '"Because" is spelled: b-e-c-a-u-s-e',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'spell_3',
      skillId: 'skill_spelling',
      question: 'Which spelling is correct?',
      options: ['separate', 'seperate', 'separete', 'seprate'],
      correctIndex: 0,
      hint: 'There\'s "a rat" in separate!',
      explanation: '"Separate" has an "a" in the middle: sep-a-rate',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'spell_4',
      skillId: 'skill_spelling',
      question: 'Which spelling is correct?',
      options: ['recieve', 'receive', 'receve', 'receeve'],
      correctIndex: 1,
      hint: '"i before e except after c"',
      explanation: '"Receive" follows the rule: e-i after c',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'spell_5',
      skillId: 'skill_spelling',
      question: 'Which spelling is correct?',
      options: ['necessary', 'neccessary', 'necesary', 'neccesary'],
      correctIndex: 0,
      hint: 'One collar (c) and two sleeves (ss)',
      explanation: '"Necessary" has 1 c and 2 s\'s: n-e-c-e-s-s-a-r-y',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'spell_6',
      skillId: 'skill_spelling',
      question: 'Which spelling is correct?',
      options: ['tommorrow', 'tomorrow', 'tomorow', 'tommorow'],
      correctIndex: 1,
      hint: 'One "m", two "r"s',
      explanation: '"Tomorrow" is spelled: t-o-m-o-r-r-o-w',
      difficulty: 2,
    ),
  ];

  static List<LiteracyQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}
