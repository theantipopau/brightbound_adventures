/// Question and story models for Story Springs activities
class StoryQuestion {
  final String id;
  final String skillId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? hint;
  final String? explanation;
  final int difficulty;
  final StoryQuestionType type;
  final String? imageEmoji;
  final List<String>? storyParts; // For sequencing

  const StoryQuestion({
    required this.id,
    required this.skillId,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.hint,
    this.explanation,
    this.difficulty = 1,
    this.type = StoryQuestionType.multipleChoice,
    this.imageEmoji,
    this.storyParts,
  });

  String get correctAnswer => options[correctIndex];
  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}

enum StoryQuestionType {
  multipleChoice,
  sequencing,
  emotionMatch,
  fillInBlank,
  storyBuilder,
}

/// Question bank for story sequencing skill
class StorySequencingQuestions {
  static const List<StoryQuestion> questions = [
    // Level 1 - Simple 3-part sequences
    StoryQuestion(
      id: 'seq_1',
      skillId: 'skill_story_sequencing',
      question: 'What happens FIRST when you make a sandwich?',
      options: [
        'Eat the sandwich',
        'Get bread and ingredients',
        'Put everything together',
        'Clean up',
      ],
      correctIndex: 1,
      hint: 'Think about what you need before you start making it',
      explanation: 'First, you get bread and ingredients. Then make it, then eat it!',
      difficulty: 1,
      imageEmoji: '🥪',
    ),
    StoryQuestion(
      id: 'seq_2',
      skillId: 'skill_story_sequencing',
      question: 'What happens LAST when you wake up?',
      options: [
        'Open your eyes',
        'Get out of bed',
        'Hear the alarm',
        'Stretch your arms',
      ],
      correctIndex: 1,
      hint: 'What\'s the final action before you start your day?',
      explanation: 'First alarm, then eyes open, stretch, then get out of bed!',
      difficulty: 1,
      imageEmoji: '🛏️',
    ),
    StoryQuestion(
      id: 'seq_3',
      skillId: 'skill_story_sequencing',
      question: 'Put this story in order: A caterpillar becomes a butterfly.\nWhat happens SECOND?',
      options: [
        'It builds a cocoon',
        'It hatches from an egg',
        'It flies away',
        'It eats lots of leaves',
      ],
      correctIndex: 3,
      hint: 'After hatching, what does the hungry caterpillar do?',
      explanation: 'Egg → Caterpillar eats → Cocoon → Butterfly!',
      difficulty: 1,
      imageEmoji: '🦋',
    ),
    // Level 2 - 4-part sequences
    StoryQuestion(
      id: 'seq_4',
      skillId: 'skill_story_sequencing',
      question: 'A boy plants a seed. What happens THIRD?',
      options: [
        'He digs a hole',
        'He waters the seed',
        'A plant starts to grow',
        'He picks a flower',
      ],
      correctIndex: 2,
      hint: 'Dig → Plant → Water → Then what starts to happen?',
      explanation: 'Dig hole → Plant seed → Water it → Plant grows → Flower blooms!',
      difficulty: 2,
      imageEmoji: '🌱',
    ),
    StoryQuestion(
      id: 'seq_5',
      skillId: 'skill_story_sequencing',
      question: 'Sarah bakes cookies. What happens BEFORE she puts them in the oven?',
      options: [
        'She lets them cool',
        'She mixes the ingredients',
        'She eats a cookie',
        'She sets a timer',
      ],
      correctIndex: 1,
      hint: 'You need to prepare the dough first!',
      explanation: 'Mix ingredients → Shape cookies → Bake → Cool → Eat!',
      difficulty: 2,
      imageEmoji: '🍪',
    ),
    // Level 3 - Complex sequences
    StoryQuestion(
      id: 'seq_6',
      skillId: 'skill_story_sequencing',
      question: 'A rainy day story: It\'s sunny, then clouds appear, then it rains. What happens NEXT?',
      options: [
        'More clouds appear',
        'A rainbow might appear',
        'It starts snowing',
        'The sun explodes',
      ],
      correctIndex: 1,
      hint: 'After rain and sun together, something beautiful can happen!',
      explanation: 'Sun → Clouds → Rain → Sun comes back → Rainbow!',
      difficulty: 3,
      imageEmoji: '🌈',
    ),
    StoryQuestion(
      id: 'seq_7',
      skillId: 'skill_story_sequencing',
      question: 'Jack climbs a beanstalk to find treasure. Put in order: He plants magic beans, climbs the beanstalk, finds a giant, returns with gold. What\'s the THIRD event?',
      options: [
        'Plants magic beans',
        'Climbs the beanstalk',
        'Finds a giant',
        'Returns with gold',
      ],
      correctIndex: 2,
      hint: 'He climbs up THEN meets someone',
      explanation: 'Plant → Beanstalk grows → Climb → Meet giant → Get gold → Return home!',
      difficulty: 3,
      imageEmoji: '🏰',
    ),
  ];

  static List<StoryQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for emotion recognition skill
class EmotionRecognitionQuestions {
  static const List<StoryQuestion> questions = [
    // Level 1 - Basic emotions
    StoryQuestion(
      id: 'emo_1',
      skillId: 'skill_emotion_recognition',
      question: 'Tom\'s dog ran away. How does Tom probably feel?',
      options: ['Happy 😊', 'Sad 😢', 'Angry 😠', 'Excited 🤩'],
      correctIndex: 1,
      hint: 'His pet is gone...',
      explanation: 'Tom would feel sad because he lost his beloved pet.',
      difficulty: 1,
      type: StoryQuestionType.emotionMatch,
      imageEmoji: '🐕',
    ),
    StoryQuestion(
      id: 'emo_2',
      skillId: 'skill_emotion_recognition',
      question: 'Emma won first place in the race! How does she feel?',
      options: ['Scared 😨', 'Bored 😐', 'Proud 🥇', 'Confused 🤔'],
      correctIndex: 2,
      hint: 'Winning feels great!',
      explanation: 'Emma feels proud because she achieved something amazing!',
      difficulty: 1,
      type: StoryQuestionType.emotionMatch,
      imageEmoji: '🏆',
    ),
    StoryQuestion(
      id: 'emo_3',
      skillId: 'skill_emotion_recognition',
      question: 'A big dog barks loudly at little Mia. How might Mia feel?',
      options: ['Sleepy 😴', 'Scared 😨', 'Hungry 🤤', 'Silly 🤪'],
      correctIndex: 1,
      hint: 'Loud, big things can be frightening',
      explanation: 'Mia might feel scared because the big dog startled her.',
      difficulty: 1,
      type: StoryQuestionType.emotionMatch,
      imageEmoji: '🐕‍🦺',
    ),
    // Level 2 - Complex emotions
    StoryQuestion(
      id: 'emo_4',
      skillId: 'skill_emotion_recognition',
      question: 'Leo\'s friend got the toy he wanted. Leo feels...',
      options: ['Jealous 😒', 'Grateful 🙏', 'Relaxed 😌', 'Curious 🧐'],
      correctIndex: 0,
      hint: 'When someone has what you want...',
      explanation: 'Leo feels jealous because his friend has the toy he wanted.',
      difficulty: 2,
      type: StoryQuestionType.emotionMatch,
      imageEmoji: '🎁',
    ),
    StoryQuestion(
      id: 'emo_5',
      skillId: 'skill_emotion_recognition',
      question: 'Maya helped an old lady carry her bags. How does Maya feel?',
      options: ['Embarrassed 😳', 'Angry 😠', 'Kind & Helpful 💝', 'Tired 😫'],
      correctIndex: 2,
      hint: 'Helping others makes us feel good!',
      explanation: 'Maya feels kind and helpful because she did a good deed.',
      difficulty: 2,
      type: StoryQuestionType.emotionMatch,
      imageEmoji: '👵',
    ),
    // Level 3 - Mixed emotions
    StoryQuestion(
      id: 'emo_6',
      skillId: 'skill_emotion_recognition',
      question: 'Alex is starting a new school. He might feel excited AND...',
      options: ['Angry', 'Nervous', 'Sleepy', 'Hungry'],
      correctIndex: 1,
      hint: 'New situations can bring mixed feelings',
      explanation: 'Alex can feel both excited about new friends AND nervous about the unknown!',
      difficulty: 3,
      type: StoryQuestionType.emotionMatch,
      imageEmoji: '🏫',
    ),
    StoryQuestion(
      id: 'emo_7',
      skillId: 'skill_emotion_recognition',
      question: 'Zoe\'s grandma is moving far away. Zoe feels sad but also...',
      options: ['Hopeful they\'ll visit', 'Angry at everyone', 'Happy she\'s leaving', 'Nothing else'],
      correctIndex: 0,
      hint: 'Even in sad times, we can look forward to something',
      explanation: 'Zoe feels sad AND hopeful - sad about distance but hopeful about future visits!',
      difficulty: 3,
      type: StoryQuestionType.emotionMatch,
      imageEmoji: '✈️',
    ),
  ];

  static List<StoryQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for descriptive language skill
class DescriptiveLanguageQuestions {
  static const List<StoryQuestion> questions = [
    // Level 1 - Basic descriptions
    StoryQuestion(
      id: 'desc_1',
      skillId: 'skill_descriptive_language',
      question: 'Which sentence is MORE descriptive?\n\n"The dog ran." vs "The fluffy brown dog ran quickly."',
      options: [
        'The dog ran.',
        'The fluffy brown dog ran quickly.',
        'Both are the same',
        'Neither is good',
      ],
      correctIndex: 1,
      hint: 'Which one paints a better picture in your mind?',
      explanation: 'Adding adjectives (fluffy, brown) and adverbs (quickly) makes writing more vivid!',
      difficulty: 1,
      imageEmoji: '🐕',
    ),
    StoryQuestion(
      id: 'desc_2',
      skillId: 'skill_descriptive_language',
      question: 'Add a describing word: "The ___ sun shone brightly."',
      options: ['big', 'golden', 'ran', 'happy'],
      correctIndex: 1,
      hint: 'What color is the sun? What does it look like?',
      explanation: '"Golden" describes the sun\'s color and makes the sentence more interesting!',
      difficulty: 1,
      imageEmoji: '☀️',
    ),
    StoryQuestion(
      id: 'desc_3',
      skillId: 'skill_descriptive_language',
      question: 'Which word best describes a kitten?',
      options: ['Tiny and soft', 'Huge and rough', 'Old and grey', 'Fast and loud'],
      correctIndex: 0,
      hint: 'Think about what kittens look and feel like',
      explanation: 'Kittens are usually tiny and soft - these words describe them accurately!',
      difficulty: 1,
      imageEmoji: '🐱',
    ),
    // Level 2 - Using senses
    StoryQuestion(
      id: 'desc_4',
      skillId: 'skill_descriptive_language',
      question: 'Which sentence uses the sense of SMELL?',
      options: [
        'The cake looked delicious.',
        'The fresh-baked cake smelled amazing.',
        'The cake was big.',
        'I ate the cake.',
      ],
      correctIndex: 1,
      hint: 'Which one talks about how something smells?',
      explanation: 'Good writers use all 5 senses - sight, sound, smell, taste, and touch!',
      difficulty: 2,
      imageEmoji: '🎂',
    ),
    StoryQuestion(
      id: 'desc_5',
      skillId: 'skill_descriptive_language',
      question: 'Make this better: "The storm was bad."\n\nWhich is most descriptive?',
      options: [
        'The storm was very bad.',
        'The storm was really bad.',
        'The fierce storm howled and crashed.',
        'The storm happened.',
      ],
      correctIndex: 2,
      hint: 'Use action words and strong adjectives!',
      explanation: '"Fierce," "howled," and "crashed" paint a vivid picture of the storm!',
      difficulty: 2,
      imageEmoji: '⛈️',
    ),
    // Level 3 - Show don't tell
    StoryQuestion(
      id: 'desc_6',
      skillId: 'skill_descriptive_language',
      question: 'Instead of "She was scared," which SHOWS fear better?',
      options: [
        'She was very scared.',
        'She felt fear.',
        'Her hands trembled and her heart pounded.',
        'She was frightened.',
      ],
      correctIndex: 2,
      hint: 'Show what the body does when scared, don\'t just say "scared"',
      explanation: 'Describing physical reactions (trembling, pounding heart) SHOWS emotions!',
      difficulty: 3,
      imageEmoji: '😰',
    ),
    StoryQuestion(
      id: 'desc_7',
      skillId: 'skill_descriptive_language',
      question: 'Which sentence uses a simile (comparing with "like" or "as")?',
      options: [
        'The snow was white.',
        'The snow fell down.',
        'The snow sparkled like diamonds.',
        'It was snowing.',
      ],
      correctIndex: 2,
      hint: 'Look for "like" or "as" comparing two things',
      explanation: 'Similes compare things using "like" or "as" to make writing more interesting!',
      difficulty: 3,
      imageEmoji: '❄️',
    ),
  ];

  static List<StoryQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for dialogue creation skill
class DialogueCreationQuestions {
  static const List<StoryQuestion> questions = [
    // Level 1 - Basic dialogue
    StoryQuestion(
      id: 'dial_1',
      skillId: 'skill_dialogue_creation',
      question: 'Which is the correct way to write someone speaking?',
      options: [
        'Tom said hello.',
        '"Hello," said Tom.',
        'Tom: Hello.',
        'Hello Tom said.',
      ],
      correctIndex: 1,
      hint: 'Spoken words go inside quotation marks " "',
      explanation: 'Dialogue uses quotation marks around the spoken words!',
      difficulty: 1,
      imageEmoji: '💬',
    ),
    StoryQuestion(
      id: 'dial_2',
      skillId: 'skill_dialogue_creation',
      question: 'A happy character might say:',
      options: [
        '"I\'m so sad..."',
        '"This is boring."',
        '"Yay! This is amazing!"',
        '"I don\'t care."',
      ],
      correctIndex: 2,
      hint: 'What would someone happy and excited say?',
      explanation: 'Happy characters use excited words and exclamation marks!',
      difficulty: 1,
      imageEmoji: '😄',
    ),
    // Level 2 - Character voice
    StoryQuestion(
      id: 'dial_3',
      skillId: 'skill_dialogue_creation',
      question: 'A pirate character would most likely say:',
      options: [
        '"Good day, fine sir."',
        '"Arrr, where\'s me treasure?"',
        '"I love doing homework!"',
        '"Beep boop beep."',
      ],
      correctIndex: 1,
      hint: 'Pirates have a special way of talking!',
      explanation: 'Good dialogue matches the character - pirates say "arrr" and talk about treasure!',
      difficulty: 2,
      imageEmoji: '🏴‍☠️',
    ),
    StoryQuestion(
      id: 'dial_4',
      skillId: 'skill_dialogue_creation',
      question: 'Instead of always writing "said," which word shows someone is ANGRY?',
      options: [
        '"Stop!" he whispered.',
        '"Stop!" he shouted.',
        '"Stop!" he giggled.',
        '"Stop!" he asked.',
      ],
      correctIndex: 1,
      hint: 'When angry, people speak loudly!',
      explanation: '"Shouted" shows anger better than "said" - use strong verbs!',
      difficulty: 2,
      imageEmoji: '😠',
    ),
    // Level 3 - Natural dialogue
    StoryQuestion(
      id: 'dial_5',
      skillId: 'skill_dialogue_creation',
      question: 'Which dialogue sounds most natural between friends?',
      options: [
        '"I am going to the park. Would you like to come with me?"',
        '"Hey! Wanna go to the park?"',
        '"I shall accompany you to the recreational area."',
        '"Park. Go. You. Me."',
      ],
      correctIndex: 1,
      hint: 'How do real friends talk to each other?',
      explanation: 'Natural dialogue sounds like real speech - casual and friendly!',
      difficulty: 3,
      imageEmoji: '🤝',
    ),
    StoryQuestion(
      id: 'dial_6',
      skillId: 'skill_dialogue_creation',
      question: 'What makes this dialogue boring?\n\n"Hi," said Tom.\n"Hi," said Sue.\n"How are you?" said Tom.\n"Fine," said Sue.',
      options: [
        'Too many characters',
        'Too much "said" and short answers',
        'Not enough quotation marks',
        'It\'s perfect',
      ],
      correctIndex: 1,
      hint: 'Notice how every line is very similar...',
      explanation: 'Vary your dialogue! Use different speaking verbs and longer, interesting responses!',
      difficulty: 3,
      imageEmoji: '📝',
    ),
  ];

  static List<StoryQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for plot structure skill
class PlotStructureQuestions {
  static const List<StoryQuestion> questions = [
    // Level 1 - Basic story parts
    StoryQuestion(
      id: 'plot_1',
      skillId: 'skill_plot_structure',
      question: 'Every story needs a BEGINNING that...',
      options: [
        'Ends the story',
        'Introduces characters and setting',
        'Has the biggest problem',
        'Solves everything',
      ],
      correctIndex: 1,
      hint: 'What do readers need to know first?',
      explanation: 'The beginning introduces WHO the story is about and WHERE it happens!',
      difficulty: 1,
      imageEmoji: '📖',
    ),
    StoryQuestion(
      id: 'plot_2',
      skillId: 'skill_plot_structure',
      question: 'What usually happens at the END of a story?',
      options: [
        'We meet new characters',
        'The problem gets worse',
        'The problem is solved',
        'Nothing happens',
      ],
      correctIndex: 2,
      hint: 'Stories need a satisfying finish!',
      explanation: 'The ending resolves the problem and shows how things turned out!',
      difficulty: 1,
      imageEmoji: '🎬',
    ),
    // Level 2 - Problem/Conflict
    StoryQuestion(
      id: 'plot_3',
      skillId: 'skill_plot_structure',
      question: 'What is the PROBLEM in this story?\n\n"A mouse wanted cheese but a cat blocked the kitchen."',
      options: [
        'The mouse is hungry',
        'There\'s no cheese',
        'The cat is blocking the way',
        'The kitchen is messy',
      ],
      correctIndex: 2,
      hint: 'What\'s stopping the mouse from getting what it wants?',
      explanation: 'The problem (conflict) is what the character must overcome - the cat!',
      difficulty: 2,
      imageEmoji: '🐱',
    ),
    StoryQuestion(
      id: 'plot_4',
      skillId: 'skill_plot_structure',
      question: 'The MIDDLE of a story usually has...',
      options: [
        'Only happy moments',
        'Challenges and attempts to solve the problem',
        'The ending',
        'Nothing important',
      ],
      correctIndex: 1,
      hint: 'The middle is where the action happens!',
      explanation: 'The middle shows the character trying to solve their problem!',
      difficulty: 2,
      imageEmoji: '⚡',
    ),
    // Level 3 - Complete story structure
    StoryQuestion(
      id: 'plot_5',
      skillId: 'skill_plot_structure',
      question: 'What story element is MISSING?\n\n"Once upon a time there was a princess. She lived happily ever after."',
      options: [
        'A beginning',
        'An ending',
        'A problem/middle',
        'A character',
      ],
      correctIndex: 2,
      hint: 'What happened BETWEEN the beginning and end?',
      explanation: 'This story has beginning and end but no middle with a problem to solve!',
      difficulty: 3,
      imageEmoji: '👸',
    ),
    StoryQuestion(
      id: 'plot_6',
      skillId: 'skill_plot_structure',
      question: 'In a good story, the CLIMAX is...',
      options: [
        'The quiet beginning',
        'The most exciting/tense moment',
        'When characters are introduced',
        'After the ending',
      ],
      correctIndex: 1,
      hint: 'It\'s the peak of excitement!',
      explanation: 'The climax is the most exciting part - when the problem is finally faced!',
      difficulty: 3,
      imageEmoji: '🎢',
    ),
  ];

  static List<StoryQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Question bank for character development skill
class CharacterDevelopmentQuestions {
  static const List<StoryQuestion> questions = [
    // Level 1 - Basic character traits
    StoryQuestion(
      id: 'char_1',
      skillId: 'skill_character_development',
      question: 'A BRAVE character would...',
      options: [
        'Run away from everything',
        'Face their fears',
        'Hide under the bed',
        'Cry all the time',
      ],
      correctIndex: 1,
      hint: 'What does brave mean?',
      explanation: 'Brave characters face their fears even when scared!',
      difficulty: 1,
      imageEmoji: '🦸',
    ),
    StoryQuestion(
      id: 'char_2',
      skillId: 'skill_character_development',
      question: 'Which trait describes someone who shares?',
      options: [
        'Greedy',
        'Generous',
        'Shy',
        'Angry',
      ],
      correctIndex: 1,
      hint: 'Sharing means giving to others...',
      explanation: 'Generous characters like to share with others!',
      difficulty: 1,
      imageEmoji: '🎁',
    ),
    // Level 2 - Motivations
    StoryQuestion(
      id: 'char_3',
      skillId: 'skill_character_development',
      question: 'A character\'s MOTIVATION is...',
      options: [
        'Their favorite color',
        'Why they do what they do',
        'Their age',
        'Where they live',
      ],
      correctIndex: 1,
      hint: 'What DRIVES a character to act?',
      explanation: 'Motivation is the reason behind a character\'s actions!',
      difficulty: 2,
      imageEmoji: '🎯',
    ),
    StoryQuestion(
      id: 'char_4',
      skillId: 'skill_character_development',
      question: 'The villain in a story often wants to...',
      options: [
        'Help everyone',
        'Stop the hero or cause problems',
        'Do nothing at all',
        'Be friends with everyone',
      ],
      correctIndex: 1,
      hint: 'Villains create conflict in stories',
      explanation: 'Villains often oppose the hero, creating the story\'s conflict!',
      difficulty: 2,
      imageEmoji: '🦹',
    ),
    // Level 3 - Complex characters
    StoryQuestion(
      id: 'char_5',
      skillId: 'skill_character_development',
      question: 'A well-rounded character has...',
      options: [
        'Only good qualities',
        'Only bad qualities',
        'Both strengths AND weaknesses',
        'No personality at all',
      ],
      correctIndex: 2,
      hint: 'Real people aren\'t perfect...',
      explanation: 'Realistic characters have both good and bad traits, like real people!',
      difficulty: 3,
      imageEmoji: '🎭',
    ),
    StoryQuestion(
      id: 'char_6',
      skillId: 'skill_character_development',
      question: 'Character GROWTH means the character...',
      options: [
        'Gets taller',
        'Learns and changes during the story',
        'Stays exactly the same',
        'Disappears from the story',
      ],
      correctIndex: 1,
      hint: 'Characters can change over time...',
      explanation: 'Good characters learn from their experiences and grow!',
      difficulty: 3,
      imageEmoji: '🌱',
    ),
  ];

  static List<StoryQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}
