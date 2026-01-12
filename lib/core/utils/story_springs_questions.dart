import 'package:brightbound_adventures/features/storytelling/models/question.dart';

/// Master bank for Story Springs curation
class StorySpringsSkillQuestions {
  /// Map of skills to their respective question lists
  static final Map<String, List<StoryQuestion>> _skillBanks = {
    'sequencing': _sequencingQuestions,
    'emotions': _emotionQuestions,
    'characters': _characterQuestions,
    'dialogue': _dialogueQuestions,
    'plot': _plotQuestions,
    'description': _descriptionQuestions,
  };

  /// Main entry point to get questions for a skill
  static List<StoryQuestion> getQuestionsForSkill(String skill, int difficulty) {
    final skillLower = skill.toLowerCase();
    
    // Find bank by key or sub-match
    List<StoryQuestion>? bank;
    for (final entry in _skillBanks.entries) {
      if (skillLower.contains(entry.key)) {
        bank = entry.value;
        break;
      }
    }

    if (bank == null || bank.isEmpty) return [];

    // Filter by difficulty (allowing lower difficulty questions as well)
    return bank.where((q) => q.difficulty <= (difficulty + 1)).toList();
  }

  static const List<StoryQuestion> _sequencingQuestions = [
    // Level 1: Basics (3-4 steps)
    StoryQuestion(
      id: 'ss_seq_1',
      skillId: 'skill_story_sequencing',
      question: 'What happens FIRST when getting ready for a day at the beach?',
      options: ['Swim in the ocean', 'Put on sunscreen', 'Build a sandcastle', 'Eat a meat pie'],
      correctIndex: 1,
      hint: 'Sun safety first!',
      difficulty: 1,
      imageEmoji: '🏖️',
    ),
    StoryQuestion(
      id: 'ss_seq_2',
      skillId: 'skill_story_sequencing',
      question: 'How does a Koala joey grow up? What happens SECOND?',
      options: ['It lives in the pouch', 'It starts eating leaves on mom\'s back', 'It finds its own tree', 'It learns to sleep 20 hours'],
      correctIndex: 1,
      hint: 'After the pouch, it hitches a ride!',
      difficulty: 1,
      imageEmoji: '🐨',
    ),
    StoryQuestion(
      id: 'ss_seq_3',
      skillId: 'skill_story_sequencing',
      question: 'Making a Lamington: What happens LAST?',
      options: ['Bake the sponge cake', 'Dip it in chocolate', 'Roll it in coconut', 'Wait for it to cool'],
      correctIndex: 2,
      hint: 'The white fluffy part at the end!',
      difficulty: 1,
      imageEmoji: '🍰',
    ),
    StoryQuestion(
      id: 'ss_seq_4',
      skillId: 'skill_story_sequencing',
      question: 'A storm in the Outback: What happens THIRD?',
      options: ['Clouds get dark', 'Thunder rumbles', 'The rain pours down', 'The sun comes back out'],
      correctIndex: 2,
      hint: 'The actual weather part!',
      difficulty: 1,
      imageEmoji: '⛈️',
    ),
    // Level 2: More complex
    StoryQuestion(
      id: 'ss_seq_5',
      skillId: 'skill_story_sequencing',
      question: 'Watching a game of Cricket: What happens after the bowler throws the ball?',
      options: ['The batsman hits the ball', 'The crowd cheers', 'The game ends', 'Players go to lunch'],
      correctIndex: 0,
      hint: 'Action and reaction!',
      difficulty: 2,
      imageEmoji: '🏏',
    ),
    StoryQuestion(
      id: 'ss_seq_6',
      skillId: 'skill_story_sequencing',
      question: 'Life cycle of a Frog: What happens after the eggs hatch?',
      options: ['Tadpole swims', 'Frog jumps', 'Legs grow', 'Tail disappears'],
      correctIndex: 0,
      hint: 'Think of the little wiggly tail.',
      difficulty: 2,
      imageEmoji: '🐸',
    ),
  ];

  static const List<StoryQuestion> _emotionQuestions = [
    StoryQuestion(
      id: 'ss_emo_1',
      skillId: 'skill_emotion_recognition',
      question: 'The Matildas just scored a goal at the World Cup! How does the crowd feel?',
      options: ['Disappointed', 'Ecstatic & Joyful', 'Bored', 'Sleepy'],
      correctIndex: 1,
      hint: 'A huge achievement for Australia!',
      difficulty: 1,
      imageEmoji: '⚽',
    ),
    StoryQuestion(
      id: 'ss_emo_2',
      skillId: 'skill_emotion_recognition',
      question: 'Benny Bear sees a huge huntsman spider in his tent. How does he feel?',
      options: ['Terrified', 'Hungry', 'Relaxed', 'Proud'],
      correctIndex: 0,
      hint: 'Spiders can be very scary!',
      difficulty: 1,
      imageEmoji: '🕷️',
    ),
    StoryQuestion(
      id: 'ss_emo_3',
      skillId: 'skill_emotion_recognition',
      question: 'Little Roo lost his favorite boomerang in the tall grass. How does he feel?',
      options: ['Upset & Sad', 'Excited', 'Funny', 'Brave'],
      correctIndex: 0,
      hint: 'Losing something you love is hard.',
      difficulty: 1,
      imageEmoji: '🪃',
    ),
    StoryQuestion(
      id: 'ss_emo_4',
      skillId: 'skill_emotion_recognition',
      question: 'The surfers are waiting for a wave at Bells Beach, but no waves are coming. How do they feel?',
      options: ['Impatient', 'Scared', 'Cold', 'Surprised'],
      correctIndex: 0,
      hint: 'Waiting a long time for something good...',
      difficulty: 2,
      imageEmoji: '🏄',
    ),
    StoryQuestion(
      id: 'ss_emo_5',
      skillId: 'skill_emotion_recognition',
      question: 'Kylie is trying Vegemite for the FIRST time. She\'s not sure if she\'ll like it. She feels...',
      options: ['Apprehensive/Hesitant', 'Guilty', 'Angry', 'Confident'],
      correctIndex: 0,
      hint: 'A new, strong taste can be worrying!',
      difficulty: 2,
      imageEmoji: '🍞',
    ),
  ];

  static const List<StoryQuestion> _characterQuestions = [
    StoryQuestion(
      id: 'ss_char_1',
      skillId: 'skill_character_development',
      question: 'Wally the Wombat always shares his burrow during a bushfire. What trait is this?',
      options: ['Selfless & Kind', 'Greedy', 'Cowardly', 'Noisy'],
      correctIndex: 0,
      hint: 'He is thinking of others.',
      difficulty: 1,
      imageEmoji: '🕳️',
    ),
    StoryQuestion(
      id: 'ss_char_2',
      skillId: 'skill_character_development',
      question: 'Pip the Penguin practices his slide every single day until he master it. Pip is...',
      options: ['Persistent', 'Lazy', 'Mean', 'Silly'],
      correctIndex: 0,
      hint: 'He keeps trying even if it\'s hard.',
      difficulty: 1,
      imageEmoji: '🐧',
    ),
    StoryQuestion(
      id: 'ss_char_3',
      skillId: 'skill_character_development',
      question: 'Which of these would be a "Hero" trait in a story?',
      options: ['Bravery', 'Sneakiness', 'Rudeness', 'Bullying'],
      correctIndex: 0,
      hint: 'Heroes do good things.',
      difficulty: 1,
      imageEmoji: '🦸',
    ),
  ];

  static const List<StoryQuestion> _dialogueQuestions = [
    StoryQuestion(
      id: 'ss_dia_1',
      skillId: 'skill_dialogue_creation',
      question: 'How would a friendly Platypus greet a friend?',
      options: ['"G\'day mate! Fancy a swim?"', '"Go away!"', '"I am a rock."', '...Silence...'],
      correctIndex: 0,
      hint: 'Think of common Australian greetings.',
      difficulty: 1,
      imageEmoji: '🦆',
    ),
    StoryQuestion(
      id: 'ss_dia_2',
      skillId: 'skill_dialogue_creation',
      question: 'Which sentence needs quotation marks for dialogue?',
      options: ['The bird sang a song.', 'I love the beach said Toby.', 'It was very hot today.', 'She ran fast.'],
      correctIndex: 1,
      hint: 'Dialogue is what someone says.',
      difficulty: 2,
      imageEmoji: '🗣️',
    ),
    StoryQuestion(
      id: 'ss_dia_3',
      skillId: 'skill_dialogue_creation',
      question: 'Choose the best way to show someone is WHISPERING:',
      options: ['"BE QUIET!" he yelled.', '"Someone is coming," she breathed softly.', '"YES!" he shouted.', '"I am here," he said.'],
      correctIndex: 1,
      hint: 'Soft voices use soft words.',
      difficulty: 2,
      imageEmoji: '🤫',
    ),
  ];

  static const List<StoryQuestion> _plotQuestions = [
    StoryQuestion(
      id: 'ss_plot_1',
      skillId: 'skill_plot_structure',
      question: 'What is the CLIMAX of a story?',
      options: ['The very beginning', 'The most exciting part', 'The final page', 'The table of contents'],
      correctIndex: 1,
      hint: 'The part where everything happens!',
      difficulty: 3,
      imageEmoji: '🌋',
    ),
    StoryQuestion(
      id: 'ss_plot_2',
      skillId: 'skill_plot_structure',
      question: 'In "The Boy Who Cried Wolf," what was the RESOLUTION?',
      options: ['He lied about the wolf', 'The wolf finally came', 'The boy learned to tell the truth', 'He ate lunch'],
      correctIndex: 2,
      hint: 'The lesson or the end of the problem.',
      difficulty: 3,
      imageEmoji: '🐺',
    ),
    StoryQuestion(
      id: 'ss_plot_3',
      skillId: 'skill_plot_structure',
      question: 'Which element starts the adventure in a story?',
      options: ['The Middle', 'The Inciting Incident', 'The Resolution', 'The Glossary'],
      correctIndex: 1,
      hint: 'The spark that starts the flame.',
      difficulty: 3,
      imageEmoji: '🧨',
    ),
  ];

  static const List<StoryQuestion> _descriptionQuestions = [
    StoryQuestion(
      id: 'ss_desc_1',
      skillId: 'skill_descriptive_language',
      question: 'Which adjective best describes the Great Barrier Reef?',
      options: ['Vibrant & Colorful', 'Grey & Dull', 'Boring', 'Empty'],
      correctIndex: 0,
      hint: 'Think of all the fish and coral!',
      difficulty: 1,
      imageEmoji: '🐠',
    ),
    StoryQuestion(
      id: 'ss_desc_2',
      skillId: 'skill_descriptive_language',
      question: 'Complete the sentence with a vivid word: The outback sun was...',
      options: ['blistering', 'nice', 'okay', 'blue'],
      correctIndex: 0,
      hint: 'It is very, very hot!',
      difficulty: 2,
      imageEmoji: '☀️',
    ),
    StoryQuestion(
      id: 'ss_desc_3',
      skillId: 'skill_descriptive_language',
      question: 'Choose the best descriptive sentence:',
      options: [
        'The water was blue.',
        'The turquoise waves crashed against the jagged, grey rocks.',
        'The waves were big.',
        'It was salty.'
      ],
      correctIndex: 1,
      hint: 'Use more detail!',
      difficulty: 3,
      imageEmoji: '🌊',
    ),
  ];
}
