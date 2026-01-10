import 'package:brightbound_adventures/features/literacy/models/question.dart';

/// Skill-specific question banks for Word Woods
/// Each skill has 25+ unique questions organized by difficulty level
class LiteracySkillQuestions {
  static final Map<String, SkillQuestionBank> _skillBanks = {
    'skill_silent_letters': SilentLettersQuestions(),
    'Silent Letters': SilentLettersQuestions(), // Also support display name
    'skill_homophones': HomophonesQuestions(),
    'Homophones': HomophonesQuestions(),
    'skill_apostrophes': ApostrophesQuestions(),
    'Apostrophes': ApostrophesQuestions(),
    'skill_vocabulary_context': VocabularyInContextQuestions(),
    'Vocabulary in Context': VocabularyInContextQuestions(),
    'skill_comma_usage': CommaUsageQuestions(),
    'Comma Usage': CommaUsageQuestions(),
    'skill_verb_tense': VerbTenseQuestions(),
    'Verb Tense Consistency': VerbTenseQuestions(),
    'skill_pronoun_reference': PronounReferenceQuestions(),
    'Pronoun Reference': PronounReferenceQuestions(),
    'skill_main_idea': MainIdeaQuestions(),
    'Main Idea': MainIdeaQuestions(),
    'skill_inference': InferenceQuestions(),
    'Inference': InferenceQuestions(),
    'skill_sentence_formation': SentenceFormationQuestions(),
    'Sentence Formation': SentenceFormationQuestions(),
  };

  static List<LiteracyQuestion> getQuestions({
    required String skill,
    required int difficulty,
    int count = 10,
  }) {
    final bank = _skillBanks[skill];
    if (bank == null) {
      return [];
    }

    final questions = bank.getQuestionsByDifficulty(difficulty);
    if (questions.isEmpty) {
      return [];
    }

    // Return count questions, cycling through if needed
    final result = <LiteracyQuestion>[];
    for (int i = 0; i < count; i++) {
      result.add(questions[i % questions.length]);
    }
    return result;
  }
}

/// Base class for skill-specific question banks
abstract class SkillQuestionBank {
  List<LiteracyQuestion> getQuestionsByDifficulty(int difficulty) {
    if (difficulty <= 2) {
      return easyQuestions;
    } else if (difficulty <= 4) {
      return mediumQuestions;
    } else {
      return hardQuestions;
    }
  }

  List<LiteracyQuestion> get easyQuestions;
  List<LiteracyQuestion> get mediumQuestions;
  List<LiteracyQuestion> get hardQuestions;
}

/// Silent Letters - words with letters that aren't pronounced
class SilentLettersQuestions extends SkillQuestionBank {
  @override
  List<LiteracyQuestion> get easyQuestions => [
    LiteracyQuestion(
      id: 'silent_k_1',
      skillId: 'silent_letters',
      question: 'In the word "knife", which letter is silent?',
      options: ['k', 'n', 'i', 'e'],
      correctIndex: 0,
      hint: 'Try saying the word out loud carefully.',
      explanation: 'The "k" in "knife" is silent. We say "nife".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'silent_w_1',
      skillId: 'silent_letters',
      question: 'In the word "write", which letter is silent?',
      options: ['w', 'r', 'i', 't'],
      correctIndex: 0,
      hint: 'The word sounds like "right".',
      explanation: 'The "w" in "write" is silent. We say "rite".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'silent_h_1',
      skillId: 'silent_letters',
      question: 'In the word "honest", which letter is silent?',
      options: ['h', 'o', 'n', 's'],
      correctIndex: 0,
      hint: 'We say "on-est", not "hon-est".',
      explanation: 'The "h" in "honest" is silent.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'silent_b_1',
      skillId: 'silent_letters',
      question: 'In the word "climb", which letter is silent?',
      options: ['b', 'c', 'l', 'i'],
      correctIndex: 0,
      hint: 'We say "clime", not "climb".',
      explanation: 'The "b" in "climb" is silent.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'silent_g_1',
      skillId: 'silent_letters',
      question: 'In the word "knight", which letter is silent?',
      options: ['k', 'n', 'i', 'g'],
      correctIndex: 0,
      hint: 'The word sounds like "night".',
      explanation: 'The "k" in "knight" is silent. We say "nite".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'silent_l_1',
      skillId: 'silent_letters',
      question: 'In the word "walk", which letter is silent?',
      options: ['w', 'a', 'l', 'k'],
      correctIndex: 2,
      hint: 'We say "wawk", but there\'s one letter we don\'t pronounce.',
      explanation: 'The "l" in "walk" is silent. We say "wawk".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'silent_h_2',
      skillId: 'silent_letters',
      question: 'In the word "hour", which letter is silent?',
      options: ['h', 'o', 'u', 'r'],
      correctIndex: 0,
      hint: 'We say "our", not "hour".',
      explanation: 'The "h" in "hour" is silent. We say "our".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'silent_p_1',
      skillId: 'silent_letters',
      question: 'In the word "psychology", which letter is silent?',
      options: ['p', 's', 'y', 'c'],
      correctIndex: 0,
      hint: 'We say "sy-kol-uh-jee".',
      explanation: 'The "p" in "psychology" is silent.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'silent_t_1',
      skillId: 'silent_letters',
      question: 'In the word "castle", which letter is silent?',
      options: ['c', 'a', 't', 'l'],
      correctIndex: 2,
      hint: 'We say "cassul", not "castul".',
      explanation: 'The "t" in "castle" is silent. We say "cassul".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'silent_l_2',
      skillId: 'silent_letters',
      question: 'In the word "island", which letter is silent?',
      options: ['i', 's', 'l', 'n'],
      correctIndex: 2,
      hint: 'We say "eye-lund".',
      explanation: 'The "l" in "island" is silent. We say "eye-lund".',
      difficulty: 1,
    ),
  ];

  @override
  List<LiteracyQuestion> get mediumQuestions => [
    LiteracyQuestion(
      id: 'silent_d_2',
      skillId: 'silent_letters',
      question: 'In the word "debt", which letter is silent?',
      options: ['d', 'e', 'b', 't'],
      correctIndex: 2,
      hint: 'We say "det", not "debt".',
      explanation: 'The "b" in "debt" is silent. We say "det".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'silent_c_2',
      skillId: 'silent_letters',
      question: 'In the word "receipt", which letter is silent?',
      options: ['r', 'e', 'c', 'i'],
      correctIndex: 2,
      hint: 'We say "ruh-seet".',
      explanation: 'The "c" in "receipt" is silent. We say "ruh-seet".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'silent_g_2',
      skillId: 'silent_letters',
      question: 'In the word "foreign", which letter is silent?',
      options: ['f', 'o', 'r', 'g'],
      correctIndex: 3,
      hint: 'We say "for-un".',
      explanation: 'The "g" in "foreign" is silent. We say "for-un".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'silent_u_1',
      skillId: 'silent_letters',
      question: 'In the word "guess", which letter is silent?',
      options: ['g', 'u', 'e', 's'],
      correctIndex: 1,
      hint: 'We say "ges", not "gwess".',
      explanation: 'The "u" in "guess" is silent. We say "ges".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'silent_wr_1',
      skillId: 'silent_letters',
      question: 'In the word "wrap", which letter is silent?',
      options: ['w', 'r', 'a', 'p'],
      correctIndex: 0,
      hint: 'We say "rap".',
      explanation: 'The "w" in "wrap" is silent. We say "rap".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'silent_wh_1',
      skillId: 'silent_letters',
      question: 'In the word "whole", which letter is silent?',
      options: ['w', 'h', 'o', 'l'],
      correctIndex: 0,
      hint: 'We say "hole".',
      explanation: 'The "w" in "whole" is silent. We say "hole".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'silent_gh_1',
      skillId: 'silent_letters',
      question: 'In the word "through", which letters are silent?',
      options: ['t', 'gh', 'r', 'o'],
      correctIndex: 1,
      hint: 'We say "throo".',
      explanation: 'The "gh" in "through" is silent. We say "throo".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'silent_n_1',
      skillId: 'silent_letters',
      question: 'In the word "autumn", which letter is silent?',
      options: ['a', 'u', 't', 'n'],
      correctIndex: 3,
      hint: 'We say "aw-tum".',
      explanation: 'The "n" in "autumn" is silent. We say "aw-tum".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'silent_l_3',
      skillId: 'silent_letters',
      question: 'In the word "chalk", which letter is silent?',
      options: ['c', 'h', 'a', 'l'],
      correctIndex: 3,
      hint: 'We say "chawk".',
      explanation: 'The "l" in "chalk" is silent. We say "chawk".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'silent_w_2',
      skillId: 'silent_letters',
      question: 'In the word "sword", which letter is silent?',
      options: ['s', 'w', 'o', 'r'],
      correctIndex: 1,
      hint: 'We say "sord".',
      explanation: 'The "w" in "sword" is silent. We say "sord".',
      difficulty: 3,
    ),
  ];

  @override
  List<LiteracyQuestion> get hardQuestions => [
    LiteracyQuestion(
      id: 'silent_p_2',
      skillId: 'silent_letters',
      question: 'In the word "pneumonia", which letter is silent?',
      options: ['p', 'n', 'e', 'u'],
      correctIndex: 0,
      hint: 'We say "nuh-mone-ya".',
      explanation: 'The "p" in "pneumonia" is silent.',
      difficulty: 5,
    ),
    LiteracyQuestion(
      id: 'silent_combination_1',
      skillId: 'silent_letters',
      question: 'Which word has a silent letter?',
      options: ['design', 'present', 'enough', 'answer'],
      correctIndex: 3,
      hint: 'Look for words where a letter isn\'t pronounced.',
      explanation: 'In "answer", the "w" is silent. We say "an-ser".',
      difficulty: 5,
    ),
    LiteracyQuestion(
      id: 'silent_ght_1',
      skillId: 'silent_letters',
      question: 'In the word "bought", which letters are silent?',
      options: ['b', 'ou', 'ght', 'g'],
      correctIndex: 2,
      hint: 'We say "bawt".',
      explanation: 'The "ght" in "bought" is silent.',
      difficulty: 5,
    ),
    LiteracyQuestion(
      id: 'silent_context_1',
      skillId: 'silent_letters',
      question: 'The word "knot" means a tight loop. What letter at the beginning is silent?',
      options: ['k', 'n', 'o', 't'],
      correctIndex: 0,
      hint: 'The word sounds like "not".',
      explanation: 'The "k" in "knot" is silent. We say "not".',
      difficulty: 5,
    ),
    LiteracyQuestion(
      id: 'silent_pair_1',
      skillId: 'silent_letters',
      question: 'Which pair both have silent letters?',
      options: ['cat and dog', 'knife and write', 'run and jump', 'sun and moon'],
      correctIndex: 1,
      hint: 'Look for words with silent k or silent w.',
      explanation: '"Knife" has a silent k, and "write" has a silent w.',
      difficulty: 5,
    ),
    LiteracyQuestion(
      id: 'silent_homophones_1',
      skillId: 'silent_letters',
      question: '"Knight" and "night" sound the same. What makes "knight" different?',
      options: ['Different spelling', 'It has a silent k', 'It means something different', 'All of these'],
      correctIndex: 3,
      hint: 'Both the spelling and the silent letter matter.',
      explanation: '"Knight" has a silent k and means a warrior. "Night" is darkness.',
      difficulty: 5,
    ),
  ];
}

/// Homophones - words that sound the same but have different meanings
class HomophonesQuestions extends SkillQuestionBank {
  @override
  List<LiteracyQuestion> get easyQuestions => [
    LiteracyQuestion(
      id: 'homo_to_1',
      skillId: 'homophones',
      question: 'I go ___ the shop. Which word fits?',
      options: ['to', 'too', 'two'],
      correctIndex: 0,
      hint: '"To" means direction. "Too" means also. "Two" is the number 2.',
      explanation: '"To" shows direction: "I go to the shop".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'homo_be_1',
      skillId: 'homophones',
      question: 'A bee is an insect. How do you spell the insect?',
      options: ['be', 'bee', 'bea'],
      correctIndex: 1,
      hint: '"Be" is a verb. "Bee" is the insect.',
      explanation: 'The insect is spelled "bee". We spell the verb as "be".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'homo_sea_1',
      skillId: 'homophones',
      question: 'The ocean is called the ___. Which spelling is correct?',
      options: ['see', 'sea'],
      correctIndex: 1,
      hint: '"See" means to look. "Sea" is the ocean.',
      explanation: 'The ocean is the "sea". The verb is "see".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'homo_there_1',
      skillId: 'homophones',
      question: 'Look over ___! Which word fits?',
      options: ['their', 'there', 'they\'re'],
      correctIndex: 1,
      hint: '"There" shows a place. "Their" shows possession. "They\'re" = they are.',
      explanation: '"There" shows location: "Look over there".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'homo_by_1',
      skillId: 'homophones',
      question: 'Goodbye! I\'ll see you ___. Which word fits?',
      options: ['by', 'bye'],
      correctIndex: 1,
      hint: '"By" can mean near. "Bye" is short for goodbye.',
      explanation: '"Bye" is short for goodbye. "By" means near something.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'homo_one_1',
      skillId: 'homophones',
      question: 'Can you hear me? Do you know the number after zero?',
      options: ['one', 'won'],
      correctIndex: 0,
      hint: '"One" is the number. "Won" is the past tense of win.',
      explanation: 'The number is spelled "one". The past tense of win is "won".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'homo_meet_1',
      skillId: 'homophones',
      question: 'I will ___ you tomorrow. Which word fits?',
      options: ['meet', 'meat'],
      correctIndex: 0,
      hint: '"Meet" means to come together. "Meat" is food.',
      explanation: '"Meet" means to come together. "Meat" is food from an animal.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'homo_knight_1',
      skillId: 'homophones',
      question: 'A warrior in armour is a ___. Which spelling is correct?',
      options: ['night', 'knight'],
      correctIndex: 1,
      hint: '"Knight" is a warrior. "Night" is darkness.',
      explanation: 'A warrior is spelled "knight". The dark time is "night".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'homo_write_1',
      skillId: 'homophones',
      question: 'Turn right at the corner. Do you spell that right?',
      options: ['right', 'write'],
      correctIndex: 0,
      hint: '"Right" can mean correct or a direction. "Write" means to put words on paper.',
      explanation: 'Turn "right" at the corner. You "write" with a pen.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'homo_know_1',
      skillId: 'homophones',
      question: 'Do you ___ the answer? Which word fits?',
      options: ['no', 'know'],
      correctIndex: 1,
      hint: '"Know" means to understand. "No" means not yes.',
      explanation: '"Know" means to understand. "No" is the opposite of yes.',
      difficulty: 1,
    ),
  ];

  @override
  List<LiteracyQuestion> get mediumQuestions => [
    LiteracyQuestion(
      id: 'homo_their_2',
      skillId: 'homophones',
      question: 'This is ___ book. Which word fits?',
      options: ['their', 'there', 'they\'re'],
      correctIndex: 0,
      hint: '"Their" shows who owns it. "There" is a place. "They\'re" = they are.',
      explanation: '"Their" shows possession: "their book".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'homo_theyre_1',
      skillId: 'homophones',
      question: '___ going to the park. Which word fits?',
      options: ['Their', 'There', 'They\'re'],
      correctIndex: 2,
      hint: '"They\'re" is short for "they are".',
      explanation: '"They\'re" = they are. "They\'re going to the park".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'homo_its_1',
      skillId: 'homophones',
      question: 'The cat is happy. ___ tail is fluffy.',
      options: ['It\'s', 'Its'],
      correctIndex: 1,
      hint: '"Its" shows possession. "It\'s" = it is.',
      explanation: '"Its" shows possession: "its tail". "It\'s" means "it is".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'homo_pair_1',
      skillId: 'homophones',
      question: 'Which pair are homophones?',
      options: ['cat and dog', 'break and brake', 'happy and sad', 'big and small'],
      correctIndex: 1,
      hint: 'Homophones sound the same but mean different things.',
      explanation: '"Break" (to damage) and "brake" (to stop) sound the same.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'homo_new_1',
      skillId: 'homophones',
      question: 'I have a ___ car. Which spelling is correct?',
      options: ['new', 'knew'],
      correctIndex: 0,
      hint: '"New" means not old. "Knew" is past tense of know.',
      explanation: '"New" means not old. "Knew" is the past tense of know.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'homo_for_1',
      skillId: 'homophones',
      question: 'This gift is ___ you. Which spelling is correct?',
      options: ['for', 'four'],
      correctIndex: 0,
      hint: '"For" shows purpose. "Four" is the number 4.',
      explanation: '"For" shows purpose: "for you". "Four" is the number.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'homo_wear_1',
      skillId: 'homophones',
      question: 'I will ___ my blue shirt. Which spelling is correct?',
      options: ['wear', 'where'],
      correctIndex: 0,
      hint: '"Wear" means to put on clothing. "Where" asks about location.',
      explanation: '"Wear" means to put on. "Where" asks "in what place?".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'homo_flour_1',
      skillId: 'homophones',
      question: 'The baker used ___ to make bread. Which spelling is correct?',
      options: ['flour', 'flower'],
      correctIndex: 0,
      hint: '"Flour" is for baking. "Flower" is a plant.',
      explanation: '"Flour" is used for baking. A "flower" is a plant.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'homo_pair_2',
      skillId: 'homophones',
      question: 'Which pair are homophones?',
      options: ['sun and moon', 'son and sun', 'day and night', 'hot and cold'],
      correctIndex: 1,
      hint: '"Son" and "sun" sound the same.',
      explanation: '"Son" (a boy) and "sun" (the star) sound the same.',
      difficulty: 3,
    ),
  ];

  @override
  List<LiteracyQuestion> get hardQuestions => [
    LiteracyQuestion(
      id: 'homo_complex_1',
      skillId: 'homophones',
      question: 'Pick the sentence with correct homophones:',
      options: [
        'They\'re going their way over there.',
        'Their going there over they\'re way.',
        'There going their way over they\'re place.',
        'They\'re going there and they\'re happy.'
      ],
      correctIndex: 0,
      hint: 'Check each homophone carefully.',
      explanation: '"They\'re going their way over there" uses all three correctly.',
      difficulty: 5,
    ),
    LiteracyQuestion(
      id: 'homo_context_1',
      skillId: 'homophones',
      question: 'The baker used flour from the store. Which word is a homophone?',
      options: ['baker', 'flour', 'from', 'store'],
      correctIndex: 1,
      hint: 'Which word sounds like another word?',
      explanation: '"Flour" sounds like "flower". Both are homophones.',
      difficulty: 5,
    ),
    LiteracyQuestion(
      id: 'homo_write_right_1',
      skillId: 'homophones',
      question: 'The students practiced their spelling every knight. What\'s wrong?',
      options: [
        '"Knight" should be "night"',
        '"Their" should be "there"',
        'Nothing is wrong',
        '"Spelled" should be "spend"'
      ],
      correctIndex: 0,
      hint: 'Look for homophones used incorrectly.',
      explanation: 'The sentence should say "every night", not "every knight".',
      difficulty: 5,
    ),
    LiteracyQuestion(
      id: 'homo_all_correct_1',
      skillId: 'homophones',
      question: 'Which sentence uses homophones correctly?',
      options: [
        'I know no one is here.',
        'The knight came in the morning.',
        'They\'re book is over their.',
        'We will meet at the flower bed.'
      ],
      correctIndex: 0,
      hint: 'Check each sentence for correct homophone usage.',
      explanation: '"I know no one is here" uses both correctly. "Know" (understand) and "no" (not yes).',
      difficulty: 5,
    ),
  ];
}

/// Apostrophes - contractions and possessives
class ApostrophesQuestions extends SkillQuestionBank {
  @override
  List<LiteracyQuestion> get easyQuestions => [
    LiteracyQuestion(
      id: 'apos_dont_1',
      skillId: 'apostrophes',
      question: 'What does "don\'t" mean?',
      options: ['do not', 'does not', 'did not', 'doing not'],
      correctIndex: 0,
      hint: 'A contraction puts two words together.',
      explanation: '"Don\'t" is short for "do not". The apostrophe replaces the "o".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'apos_cant_1',
      skillId: 'apostrophes',
      question: 'What does "can\'t" mean?',
      options: ['can not', 'could not', 'cannot happen', 'can something'],
      correctIndex: 0,
      hint: 'This is a negative contraction.',
      explanation: '"Can\'t" is short for "cannot" or "can not".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'apos_its_possessive_1',
      skillId: 'apostrophes',
      question: 'The dog wagged ___ tail.',
      options: ['its', 'it\'s'],
      correctIndex: 0,
      hint: 'This shows who owns the tail.',
      explanation: '"Its" shows possession: "the dog\'s tail". "It\'s" = it is.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'apos_is_1',
      skillId: 'apostrophes',
      question: 'It\'s a beautiful day. What does "It\'s" mean?',
      options: ['It is', 'It has', 'The day\'s', 'A day'],
      correctIndex: 0,
      hint: '"It\'s" is a contraction.',
      explanation: '"It\'s" = "it is". "It is a beautiful day".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'apos_wont_1',
      skillId: 'apostrophes',
      question: 'What does "won\'t" mean?',
      options: ['will not', 'want not', 'would not', 'was not'],
      correctIndex: 0,
      hint: 'This is a special contraction that changes the word.',
      explanation: '"Won\'t" is short for "will not", but the spelling changes.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'apos_shouldnt_1',
      skillId: 'apostrophes',
      question: 'What does "shouldn\'t" mean?',
      options: ['should not', 'shall not', 'should nothing', 'should never'],
      correctIndex: 0,
      hint: 'This is a negative contraction.',
      explanation: '"Shouldn\'t" = "should not".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'apos_cats_1',
      skillId: 'apostrophes',
      question: 'The cat\'s toy is broken. What does the apostrophe show?',
      options: ['The toy belongs to the cat', 'There are many toys', 'The cat is playing', 'The toy is a cat\'s'],
      correctIndex: 0,
      hint: 'The apostrophe shows possession (ownership).',
      explanation: '"The cat\'s toy" means the toy that belongs to the cat.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'apos_theyre_1',
      skillId: 'apostrophes',
      question: 'What does "they\'re" mean?',
      options: ['they are', 'they have', 'their friends', 'they own'],
      correctIndex: 0,
      hint: 'This is a contraction of two words.',
      explanation: '"They\'re" = "they are".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'apos_ive_1',
      skillId: 'apostrophes',
      question: 'What does "I\'ve" mean?',
      options: ['I have', 'I am', 'I will', 'I had'],
      correctIndex: 0,
      hint: 'This combines two words.',
      explanation: '"I\'ve" = "I have".',
      difficulty: 1,
    ),
  ];

  @override
  List<LiteracyQuestion> get mediumQuestions => [
    LiteracyQuestion(
      id: 'apos_youre_1',
      skillId: 'apostrophes',
      question: 'You\'re doing great! What does "you\'re" mean?',
      options: ['you are', 'your thing', 'you will', 'you were'],
      correctIndex: 0,
      hint: 'This is a contraction.',
      explanation: '"You\'re" = "you are".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'apos_dogs_1',
      skillId: 'apostrophes',
      question: 'The dogs\' toys are in the box. What does the apostrophe show?',
      options: ['Many dogs own toys', 'One dog\'s toy', 'The toys are small', 'Dogs and toys'],
      correctIndex: 0,
      hint: 'When multiple dogs own something, the apostrophe goes after the "s".',
      explanation: '"The dogs\' toys" = toys that belong to multiple dogs.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'apos_doesnt_1',
      skillId: 'apostrophes',
      question: 'She doesn\'t like vegetables. What does "doesn\'t" mean?',
      options: ['does not', 'did not', 'do not', 'does never'],
      correctIndex: 0,
      hint: 'This is a negative contraction.',
      explanation: '"Doesn\'t" = "does not".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'apos_choice_1',
      skillId: 'apostrophes',
      question: 'Which sentence is correct?',
      options: [
        'Its a wonderful day.',
        'It\'s a wonderful day.',
        'It is a wonderful day',
        'Both B and C are correct.'
      ],
      correctIndex: 3,
      hint: '"It\'s" = "it is".',
      explanation: 'Both "It\'s a wonderful day" and "It is a wonderful day" are correct.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'apos_hasnt_1',
      skillId: 'apostrophes',
      question: 'I haven\'t finished yet. What does "haven\'t" mean?',
      options: ['have not', 'has not', 'had not', 'having not'],
      correctIndex: 0,
      hint: 'This is a negative contraction.',
      explanation: '"Haven\'t" = "have not".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'apos_james_1',
      skillId: 'apostrophes',
      question: 'James\' book is on the table. Is this correct?',
      options: ['Yes, for names ending in "s"', 'No, it should be James\'s', 'Both are acceptable', 'Neither is correct'],
      correctIndex: 2,
      hint: 'Both "James\'" and "James\'s" can be correct.',
      explanation: 'For names ending in "s", both "James\'" and "James\'s" are acceptable.',
      difficulty: 3,
    ),
  ];

  @override
  List<LiteracyQuestion> get hardQuestions => [
    LiteracyQuestion(
      id: 'apos_complex_1',
      skillId: 'apostrophes',
      question: 'Which sentence uses apostrophes correctly?',
      options: [
        'The childrens\' books are on the shelf.',
        'The childs\' books are on the shelf.',
        'The childrens books are on the shelf.',
        'The children\'s books are on the shelf.'
      ],
      correctIndex: 3,
      hint: '"Children" is already plural, so the apostrophe goes before the "s".',
      explanation: '"The children\'s books" is correct. "Children" is plural, so we add \'s.',
      difficulty: 5,
    ),
    LiteracyQuestion(
      id: 'apos_contraction_count_1',
      skillId: 'apostrophes',
      question: 'How many contractions are in this sentence? "I\'ve said they\'re good, and we\'ve seen it\'s true."',
      options: ['1', '2', '3', '4'],
      correctIndex: 3,
      hint: 'Count each word with an apostrophe that combines two words.',
      explanation: 'There are 4 contractions: I\'ve, they\'re, we\'ve, it\'s.',
      difficulty: 5,
    ),
    LiteracyQuestion(
      id: 'apos_error_1',
      skillId: 'apostrophes',
      question: 'What\'s wrong with this sentence? "The birds nests were in the trees."',
      options: [
        'Should be "bird\'s" (one bird)',
        'Should be "birds\'" or "birds\'s" (many birds)',
        'Should be "nest\'s"',
        'Nothing is wrong.'
      ],
      correctIndex: 1,
      hint: 'Look for missing apostrophes showing possession.',
      explanation: 'Should be "The birds\' nests" (nests belonging to multiple birds).',
      difficulty: 5,
    ),
  ];
}

/// Vocabulary in Context - understanding words from surrounding text
class VocabularyInContextQuestions extends SkillQuestionBank {
  @override
  List<LiteracyQuestion> get easyQuestions => [
    LiteracyQuestion(
      id: 'vocab_context_1',
      skillId: 'vocabulary_in_context',
      question: 'The puppy was very friendly and loved to play with everyone. What does "friendly" mean?',
      options: ['cold and mean', 'nice and kind', 'quick and fast', 'tired and sleepy'],
      correctIndex: 1,
      hint: 'Look at what the puppy does - it loves to play.',
      explanation: '"Friendly" means nice and kind to others. The puppy loved to play.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'vocab_context_2',
      skillId: 'vocabulary_in_context',
      question: 'The huge elephant was enormous and so big it could barely fit in the truck. What does "enormous" mean?',
      options: ['very small', 'very big', 'very hungry', 'very tired'],
      correctIndex: 1,
      hint: 'The sentence tells us how big the elephant is.',
      explanation: '"Enormous" means very big. The elephant was so big it barely fit.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'vocab_context_3',
      skillId: 'vocabulary_in_context',
      question: 'After running in the hot sun, Maya was exhausted and needed to rest. What does "exhausted" mean?',
      options: ['happy', 'very tired', 'confused', 'excited'],
      correctIndex: 1,
      hint: 'She ran in the hot sun and needed to rest.',
      explanation: '"Exhausted" means very tired. Maya needed rest after running.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'vocab_context_4',
      skillId: 'vocabulary_in_context',
      question: 'The children looked gloomy and sad when they couldn\'t go to the park. What does "gloomy" mean?',
      options: ['happy', 'confused', 'sad and dark', 'excited'],
      correctIndex: 2,
      hint: 'The sentence says they looked sad.',
      explanation: '"Gloomy" means sad and dark. They couldn\'t go to the park.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'vocab_context_5',
      skillId: 'vocabulary_in_context',
      question: 'The ancient temple was very old and had been standing for thousands of years. What does "ancient" mean?',
      options: ['brand new', 'very old', 'very small', 'very tall'],
      correctIndex: 1,
      hint: 'It has been standing for thousands of years.',
      explanation: '"Ancient" means very old. The temple was thousands of years old.',
      difficulty: 1,
    ),
  ];

  @override
  List<LiteracyQuestion> get mediumQuestions => [
    LiteracyQuestion(
      id: 'vocab_context_6',
      skillId: 'vocabulary_in_context',
      question: 'The teacher\'s instructions were explicit and very clear about what we needed to do. What does "explicit" mean?',
      options: ['confusing', 'very clear and direct', 'boring', 'difficult'],
      correctIndex: 1,
      hint: 'The sentence says instructions were very clear.',
      explanation: '"Explicit" means very clear and direct. We knew exactly what to do.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'vocab_context_7',
      skillId: 'vocabulary_in_context',
      question: 'Sarah felt anxious and worried about her test tomorrow. What does "anxious" mean?',
      options: ['angry', 'peaceful', 'worried and nervous', 'confused'],
      correctIndex: 2,
      hint: 'She is worried about her test.',
      explanation: '"Anxious" means worried and nervous. Sarah was concerned about her test.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'vocab_context_8',
      skillId: 'vocabulary_in_context',
      question: 'The meal was delicious and tasted absolutely wonderful. What does "delicious" mean?',
      options: ['not good', 'very tasty', 'cold', 'expensive'],
      correctIndex: 1,
      hint: 'It tasted absolutely wonderful.',
      explanation: '"Delicious" means very tasty. The meal tasted wonderful.',
      difficulty: 3,
    ),
  ];

  @override
  List<LiteracyQuestion> get hardQuestions => [
    LiteracyQuestion(
      id: 'vocab_context_9',
      skillId: 'vocabulary_in_context',
      question: 'The candidate was belligerent and argumentative, constantly disagreeing with everyone. What does "belligerent" mean?',
      options: ['friendly', 'shy', 'aggressive and hostile', 'intelligent'],
      correctIndex: 2,
      hint: 'The candidate constantly disagreed with everyone.',
      explanation: '"Belligerent" means aggressive and hostile. They disagreed constantly.',
      difficulty: 5,
    ),
    LiteracyQuestion(
      id: 'vocab_context_10',
      skillId: 'vocabulary_in_context',
      question: 'The plan was too ambitious and unrealistic for our small team to accomplish. What does "ambitious" mean?',
      options: ['easy', 'difficult', 'having high goals or expectations', 'boring'],
      correctIndex: 2,
      hint: 'The plan was too big for the small team.',
      explanation: '"Ambitious" means having high goals. This plan was too challenging.',
      difficulty: 5,
    ),
  ];
}

/// Comma Usage - using commas correctly
class CommaUsageQuestions extends SkillQuestionBank {
  @override
  List<LiteracyQuestion> get easyQuestions => [
    LiteracyQuestion(
      id: 'comma_series_1',
      skillId: 'comma_usage',
      question: 'Which sentence uses commas correctly?',
      options: [
        'I like apples oranges and bananas.',
        'I like, apples, oranges, and bananas.',
        'I like apples, oranges, and bananas.',
        'I, like apples oranges and bananas.'
      ],
      correctIndex: 2,
      hint: 'Use commas between items in a list.',
      explanation: 'Use commas to separate items in a list: apples, oranges, and bananas.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'comma_address_1',
      skillId: 'comma_usage',
      question: 'Which sentence is correct?',
      options: [
        'I live in Sydney Australia.',
        'I live in Sydney, Australia.',
        'I live, in Sydney Australia.',
        'I, live in Sydney, Australia.'
      ],
      correctIndex: 1,
      hint: 'Use a comma between a city and country.',
      explanation: 'Use a comma between city and country: Sydney, Australia.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'comma_intro_1',
      skillId: 'comma_usage',
      question: 'Which sentence is correct?',
      options: [
        'After school I went to the park.',
        'After school, I went to the park.',
        'After, school I went to the park.',
        'After school I, went to the park.'
      ],
      correctIndex: 1,
      hint: 'Put a comma after an introductory phrase.',
      explanation: 'Use a comma after "After school": After school, I went to the park.',
      difficulty: 1,
    ),
  ];

  @override
  List<LiteracyQuestion> get mediumQuestions => [
    LiteracyQuestion(
      id: 'comma_complex_1',
      skillId: 'comma_usage',
      question: 'Which sentence uses commas correctly?',
      options: [
        'My favourite foods are pizza tacos and pasta.',
        'My favourite foods, are pizza, tacos, and pasta.',
        'My favourite foods are: pizza, tacos, and pasta.',
        'My favourite foods are pizza, tacos and pasta.'
      ],
      correctIndex: 2,
      hint: 'Check if commas are in the right places.',
      explanation: 'After a colon in a list, use commas: pizza, tacos, and pasta.',
      difficulty: 3,
    ),
  ];

  @override
  List<LiteracyQuestion> get hardQuestions => [
    LiteracyQuestion(
      id: 'comma_hard_1',
      skillId: 'comma_usage',
      question: 'Which sentence uses commas correctly?',
      options: [
        'Sarah, who plays tennis, likes to run every morning.',
        'Sarah who plays tennis likes to run every morning.',
        'Sarah, who plays tennis likes to run every morning.',
        'Sarah who, plays tennis, likes to run every morning.'
      ],
      correctIndex: 0,
      hint: 'Commas go around extra information in the middle of a sentence.',
      explanation: 'Use commas around extra information: Sarah, who plays tennis, likes to run.',
      difficulty: 5,
    ),
  ];
}

/// Verb Tense Consistency - keeping verb tenses consistent
class VerbTenseQuestions extends SkillQuestionBank {
  @override
  List<LiteracyQuestion> get easyQuestions => [
    LiteracyQuestion(
      id: 'verb_tense_1',
      skillId: 'verb_tense',
      question: 'Which sentence uses the same tense throughout?',
      options: [
        'She runs to the store and buys milk.',
        'She runs to the store and bought milk.',
        'She ran to the store and buys milk.',
        'She is running to the store and bought milk.'
      ],
      correctIndex: 0,
      hint: 'All verbs should be in the same tense.',
      explanation: '"Runs" and "buys" are both present tense. Tenses match!',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'verb_tense_2',
      skillId: 'verb_tense',
      question: 'Which sentence has a tense error?',
      options: [
        'They play football every day.',
        'They played football yesterday.',
        'They play football yesterday.',
        'Both B and C are correct.'
      ],
      correctIndex: 2,
      hint: '"Yesterday" shows past time, so use past tense.',
      explanation: '"Played" is correct with "yesterday". "Play" is wrong for past time.',
      difficulty: 1,
    ),
  ];

  @override
  List<LiteracyQuestion> get mediumQuestions => [
    LiteracyQuestion(
      id: 'verb_tense_3',
      skillId: 'verb_tense',
      question: 'Fix the tense error: "We went to the park and play games."',
      options: [
        'We go to the park and played games.',
        'We went to the park and played games.',
        'We go to the park and play games.',
        'We are going to the park and play games.'
      ],
      correctIndex: 1,
      hint: 'Both verbs should be past tense.',
      explanation: '"Went" is past, so "played" should also be past.',
      difficulty: 3,
    ),
  ];

  @override
  List<LiteracyQuestion> get hardQuestions => [
    LiteracyQuestion(
      id: 'verb_tense_4',
      skillId: 'verb_tense',
      question: 'Which sentence has consistent tense throughout?',
      options: [
        'She had studied for the test and passed it easily.',
        'She studies for the test and passed it easily.',
        'She studied for the test and passes it easily.',
        'She studies for the test and passes it easily.'
      ],
      correctIndex: 0,
      hint: 'All verbs need to be in the same tense or properly sequenced.',
      explanation: '"Had studied" and "passed" both show completed past actions.',
      difficulty: 5,
    ),
  ];
}

/// Pronoun Reference - pronouns matching their nouns correctly
class PronounReferenceQuestions extends SkillQuestionBank {
  @override
  List<LiteracyQuestion> get easyQuestions => [
    LiteracyQuestion(
      id: 'pronoun_1',
      skillId: 'pronoun_reference',
      question: 'The cat is hungry. ___ wants food.',
      options: ['It', 'He', 'She', 'We'],
      correctIndex: 0,
      hint: 'A cat is "it" unless we know the gender.',
      explanation: 'Use "it" for the cat: "It wants food".',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'pronoun_2',
      skillId: 'pronoun_reference',
      question: 'Sarah and Tom play football. ___ are very good.',
      options: ['It', 'He', 'She', 'They'],
      correctIndex: 3,
      hint: 'Use "they" for more than one person.',
      explanation: 'Sarah and Tom are two people, so use "they": "They are very good".',
      difficulty: 1,
    ),
  ];

  @override
  List<LiteracyQuestion> get mediumQuestions => [
    LiteracyQuestion(
      id: 'pronoun_3',
      skillId: 'pronoun_reference',
      question: 'Which sentence uses the pronoun correctly?',
      options: [
        'The dogs ran and it was happy.',
        'The dogs ran and they were happy.',
        'The dog ran and they were happy.',
        'The dogs ran and he was happy.'
      ],
      correctIndex: 1,
      hint: 'The pronoun must match the noun.',
      explanation: '"Dogs" is plural, so use "they": "The dogs ran and they were happy".',
      difficulty: 3,
    ),
  ];

  @override
  List<LiteracyQuestion> get hardQuestions => [
    LiteracyQuestion(
      id: 'pronoun_4',
      skillId: 'pronoun_reference',
      question: 'What pronoun error is in: "Each student brought their book"?',
      options: [
        '"Each" is singular, so should be "his or her book"',
        '"Their" is incorrect',
        'Both are correct in modern English',
        'Should use "it" instead'
      ],
      correctIndex: 0,
      hint: '"Each" is singular.',
      explanation: '"Each" is singular, so technically should be "his or her book" (though "their" is becoming accepted).',
      difficulty: 5,
    ),
  ];
}

/// Main Idea - identifying the main idea of a passage
class MainIdeaQuestions extends SkillQuestionBank {
  @override
  List<LiteracyQuestion> get easyQuestions => [
    LiteracyQuestion(
      id: 'main_idea_1',
      skillId: 'main_idea',
      question: 'Read: "Butterflies are insects. They have wings. They drink nectar from flowers." What is the main idea?',
      options: [
        'Flowers are beautiful',
        'Butterflies are insects with specific characteristics',
        'Insects have wings',
        'Nectar is sweet'
      ],
      correctIndex: 1,
      hint: 'What is the passage mostly about?',
      explanation: 'The passage describes what butterflies are and what they do.',
      difficulty: 1,
    ),
  ];

  @override
  List<LiteracyQuestion> get mediumQuestions => [
    LiteracyQuestion(
      id: 'main_idea_2',
      skillId: 'main_idea',
      question: 'What is the main idea? "Australia is home to unique animals found nowhere else in the world. Kangaroos hop across the outback. Koalas live in eucalyptus trees. Platypuses are one of the only egg-laying mammals."',
      options: [
        'Trees grow in Australia',
        'Australia has unique animals that exist nowhere else',
        'Kangaroos are faster than other animals',
        'Mammals lay eggs'
      ],
      correctIndex: 1,
      hint: 'What are all the sentences describing?',
      explanation: 'The passage explains that Australia has unique animals not found elsewhere.',
      difficulty: 3,
    ),
  ];

  @override
  List<LiteracyQuestion> get hardQuestions => [
    LiteracyQuestion(
      id: 'main_idea_3',
      skillId: 'main_idea',
      question: 'What is the main idea of a passage about how plants need sunlight, water, and soil to grow?',
      options: [
        'Sunlight is the most important for plants',
        'Plants grow in soil',
        'Plants have specific environmental requirements to thrive',
        'Water is essential for plants'
      ],
      correctIndex: 2,
      hint: 'What do all the details support?',
      explanation: 'The main idea is that plants need multiple conditions to grow.',
      difficulty: 5,
    ),
  ];
}

/// Inference - understanding what is implied but not directly stated
class InferenceQuestions extends SkillQuestionBank {
  @override
  List<LiteracyQuestion> get easyQuestions => [
    LiteracyQuestion(
      id: 'inference_1',
      skillId: 'inference',
      question: 'Read: "Sarah brought an umbrella to school. When she looked outside, the sky was dark and grey." Why did Sarah bring the umbrella?',
      options: [
        'Because she likes umbrellas',
        'Because she thought it might rain',
        'Because it was sunny',
        'Because her teacher said so'
      ],
      correctIndex: 1,
      hint: 'Dark, grey skies usually mean rain.',
      explanation: 'We can infer Sarah brought an umbrella because she expected rain (dark, grey sky).',
      difficulty: 1,
    ),
  ];

  @override
  List<LiteracyQuestion> get mediumQuestions => [
    LiteracyQuestion(
      id: 'inference_2',
      skillId: 'inference',
      question: 'Read: "Tom studied for three hours. He organised his notes and made flashcards." What can we infer?',
      options: [
        'Tom doesn\'t like school',
        'Tom is preparing carefully for something important',
        'Tom is lazy',
        'Tom doesn\'t have time'
      ],
      correctIndex: 1,
      hint: 'What does his behaviour tell us?',
      explanation: 'Tom\'s careful studying suggests he\'s preparing seriously, probably for a test.',
      difficulty: 3,
    ),
  ];

  @override
  List<LiteracyQuestion> get hardQuestions => [
    LiteracyQuestion(
      id: 'inference_3',
      skillId: 'inference',
      question: 'From a passage where a character locks their bedroom door, hides a diary, and whispers to a friend, what can we infer?',
      options: [
        'The character is angry',
        'The character values privacy and has secrets to keep',
        'The character is scared of their family',
        'The character doesn\'t trust anyone'
      ],
      correctIndex: 1,
      hint: 'What do all these actions suggest?',
      explanation: 'These actions suggest the character values privacy and wants to keep something private.',
      difficulty: 5,
    ),
  ];
}

/// Sentence Formation - constructing grammatically correct sentences
class SentenceFormationQuestions extends SkillQuestionBank {
  @override
  List<LiteracyQuestion> get easyQuestions => [
    LiteracyQuestion(
      id: 'sentence_1',
      skillId: 'sentence_formation',
      question: 'Which is a complete sentence?',
      options: [
        'The running dog.',
        'The dog runs.',
        'Runs the dog',
        'The dog and running.'
      ],
      correctIndex: 1,
      hint: 'A sentence needs a subject and a verb.',
      explanation: '"The dog runs" has a subject (dog) and verb (runs).',
      difficulty: 1,
    ),
  ];

  @override
  List<LiteracyQuestion> get mediumQuestions => [
    LiteracyQuestion(
      id: 'sentence_2',
      skillId: 'sentence_formation',
      question: 'Which sentence is correctly formed?',
      options: [
        'She go to the store yesterday.',
        'She goes to the store yesterday.',
        'She went to the store yesterday.',
        'She going to the store yesterday.'
      ],
      correctIndex: 2,
      hint: '"Yesterday" shows past tense.',
      explanation: '"She went" is correct past tense: "She went to the store yesterday".',
      difficulty: 3,
    ),
  ];

  @override
  List<LiteracyQuestion> get hardQuestions => [
    LiteracyQuestion(
      id: 'sentence_3',
      skillId: 'sentence_formation',
      question: 'Which sentence is correctly formed?',
      options: [
        'Although it was raining, the children played outside.',
        'Although it was raining the children played outside.',
        'Although it was raining, but the children played outside.',
        'It was raining, however the children played outside.'
      ],
      correctIndex: 0,
      hint: 'Check comma placement with conjunctions.',
      explanation: 'Use a comma after "Although it was raining".',
      difficulty: 5,
    ),
  ];
}
