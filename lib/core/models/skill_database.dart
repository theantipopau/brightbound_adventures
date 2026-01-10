import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/utils/constants.dart';

/// ACARA v9.0 & NAPLAN-aligned skill database
/// Organized by zone and curriculum strand
class SkillDatabase {
  // WORD WOODS - Literacy & Communication
  static final List<Skill> wordWoodsSkills = [
    // Introduction to reading
    Skill(
      id: 'skill_letter_recognition',
      name: 'Letter Recognition',
      description: 'Identify uppercase and lowercase letters',
      strand: Constants.strandLiteracy,
      state: SkillState.introduced,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
    // Phonics
    Skill(
      id: 'skill_phoneme_awareness',
      name: 'Phoneme Awareness',
      description: 'Identify individual sounds in words',
      strand: Constants.strandLiteracy,
      state: SkillState.introduced,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
    Skill(
      id: 'skill_blending_sounds',
      name: 'Blending Sounds',
      description: 'Combine sounds to form words',
      strand: Constants.strandLiteracy,
      state: SkillState.introduced,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    // NAPLAN high-risk areas
    Skill(
      id: 'skill_homophones',
      name: 'Homophones',
      description: 'Words that sound the same but mean different things',
      strand: Constants.strandLiteracy,
      naplanArea: 'homophones',
      state: SkillState.introduced,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    Skill(
      id: 'skill_silent_letters',
      name: 'Silent Letters',
      description: 'Letters that are not pronounced in words',
      strand: Constants.strandLiteracy,
      naplanArea: 'silent_letters',
      state: SkillState.introduced,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    Skill(
      id: 'skill_apostrophes',
      name: 'Apostrophes',
      description: 'Using apostrophes for contractions and possession',
      strand: Constants.strandLiteracy,
      naplanArea: 'apostrophes',
      state: SkillState.introduced,
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    // Comprehension
    Skill(
      id: 'skill_inference',
      name: 'Inference',
      description: 'Make predictions using clues from the text',
      strand: Constants.strandLiteracy,
      naplanArea: 'inference',
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_main_idea',
      name: 'Main Idea',
      description: 'Identify the central point of a text',
      strand: Constants.strandLiteracy,
      naplanArea: 'main_idea',
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_vocabulary_context',
      name: 'Vocabulary in Context',
      description: 'Use context clues to understand new words',
      strand: Constants.strandLiteracy,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    // Grammar
    Skill(
      id: 'skill_comma_usage',
      name: 'Comma Usage',
      description: 'Use commas correctly in sentences',
      strand: Constants.strandLiteracy,
      naplanArea: 'commas',
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_verb_tense',
      name: 'Verb Tense Consistency',
      description: 'Keep verbs in the same tense throughout writing',
      strand: Constants.strandLiteracy,
      naplanArea: 'verb_tense',
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_pronoun_reference',
      name: 'Pronoun Reference',
      description: 'Understand what pronouns refer to in text',
      strand: Constants.strandLiteracy,
      naplanArea: 'pronoun_reference',
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    // Writing
    Skill(
      id: 'skill_sentence_formation',
      name: 'Sentence Formation',
      description: 'Write complete, clear sentences',
      strand: Constants.strandCommunication,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    Skill(
      id: 'skill_story_structure',
      name: 'Story Structure',
      description: 'Organize writing with beginning, middle, and end',
      strand: Constants.strandCommunication,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
  ];

  // NUMBER NEBULA - Numeracy & Math
  static final List<Skill> numberNebulaSkills = [
    // Early numeracy
    Skill(
      id: 'skill_number_recognition',
      name: 'Number Recognition',
      description: 'Identify numbers 0-10',
      strand: Constants.strandNumeracy,
      state: SkillState.introduced,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
    Skill(
      id: 'skill_counting',
      name: 'Counting',
      description: 'Count objects and numbers in sequence',
      strand: Constants.strandNumeracy,
      state: SkillState.introduced,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
    // Basic operations
    Skill(
      id: 'skill_addition',
      name: 'Addition',
      description: 'Add numbers together',
      strand: Constants.strandNumeracy,
      state: SkillState.introduced,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
    Skill(
      id: 'skill_subtraction',
      name: 'Subtraction',
      description: 'Subtract numbers',
      strand: Constants.strandNumeracy,
      state: SkillState.introduced,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    Skill(
      id: 'skill_multiplication',
      name: 'Multiplication',
      description: 'Multiply numbers using groups',
      strand: Constants.strandNumeracy,
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_division',
      name: 'Division',
      description: 'Divide numbers into groups',
      strand: Constants.strandNumeracy,
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    // NAPLAN high-risk areas
    Skill(
      id: 'skill_place_value',
      name: 'Place Value',
      description: 'Understand tens, hundreds, thousands places',
      strand: Constants.strandNumeracy,
      naplanArea: 'place_value',
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    Skill(
      id: 'skill_fractions',
      name: 'Fractions of Quantities',
      description: 'Find fractions of amounts (1/2, 1/4, etc)',
      strand: Constants.strandNumeracy,
      naplanArea: 'fractions',
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_multi_step',
      name: 'Multi-Step Word Problems',
      description: 'Solve problems requiring multiple operations',
      strand: Constants.strandNumeracy,
      naplanArea: 'multi_step_problems',
      lastPracticed: DateTime.now(),
      difficulty: 4,
    ),
    Skill(
      id: 'skill_time_elapsed',
      name: 'Time Elapsed',
      description: 'Calculate time differences',
      strand: Constants.strandNumeracy,
      naplanArea: 'time_elapsed',
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_measurement',
      name: 'Measurement Conversions',
      description: 'Convert between units (cm to m, kg to g, etc)',
      strand: Constants.strandNumeracy,
      naplanArea: 'measurements',
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_data_interpretation',
      name: 'Data Interpretation',
      description: 'Read and understand charts, graphs, tables',
      strand: Constants.strandNumeracy,
      naplanArea: 'data_interpretation',
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_patterns',
      name: 'Pattern Rules',
      description: 'Identify and extend number patterns',
      strand: Constants.strandNumeracy,
      naplanArea: 'pattern_rules',
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
  ];

  // STORY SPRINGS - Communication & Storytelling
  static final List<Skill> storyspringsSkills = [
    Skill(
      id: 'skill_story_sequencing',
      name: 'Story Sequencing',
      description: 'Put events in the correct order',
      strand: Constants.strandCommunication,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
    Skill(
      id: 'skill_emotion_recognition',
      name: 'Emotion Recognition',
      description: 'Identify emotions in stories and images',
      strand: Constants.strandCommunication,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
    Skill(
      id: 'skill_dialogue_creation',
      name: 'Dialogue Creation',
      description: 'Write conversations between characters',
      strand: Constants.strandCommunication,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    Skill(
      id: 'skill_character_development',
      name: 'Character Development',
      description: 'Create characters with traits and motivations',
      strand: Constants.strandCommunication,
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_plot_structure',
      name: 'Plot Structure',
      description: 'Understand beginning, middle, conflict, resolution',
      strand: Constants.strandCommunication,
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_descriptive_language',
      name: 'Descriptive Language',
      description: 'Use adjectives and vivid words in writing',
      strand: Constants.strandCommunication,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    Skill(
      id: 'skill_dialogue_punctuation',
      name: 'Dialogue Punctuation',
      description: 'Use correct punctuation in conversations',
      strand: Constants.strandCommunication,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    Skill(
      id: 'skill_voice_recording',
      name: 'Voice Recording & Playback',
      description: 'Record and listen to your own narration',
      strand: Constants.strandCommunication,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
  ];

  // PUZZLE PEAKS - Logic & Reasoning
  static final List<Skill> puzzlepeaksSkills = [
    Skill(
      id: 'skill_spatial_reasoning',
      name: 'Spatial Reasoning',
      description: 'Visualize and rotate objects mentally',
      strand: Constants.strandLogic,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
    Skill(
      id: 'skill_pattern_recognition',
      name: 'Pattern Recognition',
      description: 'Identify and complete patterns',
      strand: Constants.strandLogic,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    Skill(
      id: 'skill_logic_puzzles',
      name: 'Logic Puzzles',
      description: 'Solve reasoning puzzles using deduction',
      strand: Constants.strandLogic,
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_problem_solving',
      name: 'Problem Solving',
      description: 'Break down and solve complex problems',
      strand: Constants.strandLogic,
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_shape_matching',
      name: 'Shape Matching',
      description: 'Match shapes and objects',
      strand: Constants.strandLogic,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
    Skill(
      id: 'skill_sequence_logic',
      name: 'Sequence Logic',
      description: 'Find the logical order of events or items',
      strand: Constants.strandLogic,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
  ];

  // ADVENTURE ARENA - Hand-Eye Coordination
  static final List<Skill> adventureArenaSkills = [
    Skill(
      id: 'skill_hand_eye_coordination',
      name: 'Hand-Eye Coordination',
      description: 'Coordinate hand movements with visual targets',
      strand: Constants.strandMotor,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
    Skill(
      id: 'skill_tap_accuracy',
      name: 'Tap Accuracy',
      description: 'Tap targets quickly and accurately',
      strand: Constants.strandMotor,
      lastPracticed: DateTime.now(),
      difficulty: 1,
    ),
    Skill(
      id: 'skill_drag_precision',
      name: 'Drag Precision',
      description: 'Drag objects to precise locations',
      strand: Constants.strandMotor,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    Skill(
      id: 'skill_reaction_time',
      name: 'Reaction Time',
      description: 'Respond quickly to visual and auditory cues',
      strand: Constants.strandMotor,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
    Skill(
      id: 'skill_fine_motor',
      name: 'Fine Motor Control',
      description: 'Perform precise, controlled movements',
      strand: Constants.strandMotor,
      lastPracticed: DateTime.now(),
      difficulty: 3,
    ),
    Skill(
      id: 'skill_swipe_control',
      name: 'Swipe Control',
      description: 'Make smooth swipe gestures',
      strand: Constants.strandMotor,
      lastPracticed: DateTime.now(),
      difficulty: 2,
    ),
  ];

  /// Get all skills for a given zone
  static List<Skill> getZoneSkills(String zoneId) {
    switch (zoneId) {
      case 'word_woods':
        return wordWoodsSkills;
      case 'number_nebula':
        return numberNebulaSkills;
      case 'story_springs':
        return storyspringsSkills;
      case 'puzzle_peaks':
        return puzzlepeaksSkills;
      case 'adventure_arena':
        return adventureArenaSkills;
      default:
        return [];
    }
  }

  /// Get all skills
  static List<Skill> getAllSkills() {
    return [
      ...wordWoodsSkills,
      ...numberNebulaSkills,
      ...storyspringsSkills,
      ...puzzlepeaksSkills,
      ...adventureArenaSkills,
    ];
  }

  /// Get NAPLAN high-risk skills only
  static List<Skill> getNaplanHighRiskSkills() {
    return getAllSkills().where((skill) => skill.naplanArea != null).toList();
  }

  /// Get skills by strand
  static List<Skill> getSkillsByStrand(String strand) {
    return getAllSkills().where((skill) => skill.strand == strand).toList();
  }

  /// Get skill by ID
  static Skill? getSkillById(String skillId) {
    try {
      return getAllSkills().firstWhere((skill) => skill.id == skillId);
    } catch (e) {
      return null;
    }
  }

  /// Get zone name from ID
  static String getZoneName(String zoneId) {
    switch (zoneId) {
      case 'word_woods':
        return '🌲 Word Woods';
      case 'number_nebula':
        return '🌌 Number Nebula';
      case 'story_springs':
        return '📖 Story Springs';
      case 'puzzle_peaks':
        return '🧠 Puzzle Peaks';
      case 'adventure_arena':
        return '🏟️ Adventure Arena';
      default:
        return 'Unknown Zone';
    }
  }

  /// Get zone description
  static String getZoneDescription(String zoneId) {
    switch (zoneId) {
      case 'word_woods':
        return 'Explore literacy, reading, and communication skills';
      case 'number_nebula':
        return 'Master numeracy, math, and problem solving';
      case 'story_springs':
        return 'Create stories, express emotions, develop characters';
      case 'puzzle_peaks':
        return 'Challenge your logic, patterns, and reasoning';
      case 'adventure_arena':
        return 'Improve hand-eye coordination and motor skills';
      default:
        return 'Explore and learn';
    }
  }

  /// Total skill count
  static int getTotalSkillCount() => getAllSkills().length;

  /// Zone skill count
  static int getZoneSkillCount(String zoneId) => getZoneSkills(zoneId).length;
}
