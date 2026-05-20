import 'dart:math' as math;
import 'package:brightbound_adventures/core/models/question_metadata.dart';

/// Represents a generated question with all metadata
class GeneratedQuestion {
  final String id; // Unique ID for this specific question
  final String skillId;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int difficulty;
  final String? context;
  final String bloomLevel;
  final NaplanStrand? naplanStrand;
  final String? naplanCategory;
  final int? estimatedTimeSeconds;

  const GeneratedQuestion({
    required this.id,
    required this.skillId,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
    this.context,
    required this.bloomLevel,
    this.naplanStrand,
    this.naplanCategory,
    this.estimatedTimeSeconds,
  });

  /// Get the correct answer
  String get correctAnswer => options[correctIndex];

  /// Generate question hash for freshness checking
  String generateHash() {
    final combined = '$questionText|${options.join('|')}';
    return combined.hashCode.toString();
  }

  /// Convert to JSON for storage/transport
  Map<String, dynamic> toJson() => {
        'id': id,
        'skillId': skillId,
        'questionText': questionText,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'difficulty': difficulty,
        'context': context,
        'bloomLevel': bloomLevel,
        'naplanStrand': naplanStrand?.toString().split('.').last,
        'naplanCategory': naplanCategory,
        'estimatedTimeSeconds': estimatedTimeSeconds,
      };
}

/// Generates question variations to support infinite replayability
///
/// This system ensures:
/// 1. Same skill can be practiced repeatedly
/// 2. Questions are genuinely different (different numbers, contexts, scenarios)
/// 3. Difficulty is adaptive
/// 4. All NAPLAN/ACARA metadata is preserved
/// 5. Distractor variety keeps questions interesting
abstract class QuestionVariationEngine {
  /// Generate a question for a specific skill
  static GeneratedQuestion generateForSkill({
    required String skillId,
    required int difficulty,
    required NaplanStrand? strand,
    String? preferredContext,
  }) {
    // This would be implemented by specific zones
    // Override in WordWoodsVariationEngine, NumberNebulaVariationEngine, etc.
    throw UnimplementedError('Implement in subclass');
  }

  /// Generate multiple variations of a concept
  static List<GeneratedQuestion> generateVariations({
    required String skillId,
    required int count,
    required int difficulty,
  }) {
    final variations = <GeneratedQuestion>[];
    final contexts = _getContextsForSkill(skillId);

    for (int i = 0; i < count; i++) {
      final context = contexts[i % contexts.length];
      final question = generateForSkill(
        skillId: skillId,
        difficulty: difficulty,
        strand: null, // Will be set by specific engine
        preferredContext: context,
      );
      variations.add(question);
    }

    return variations;
  }

  /// Get appropriate contexts for a skill
  static List<String> _getContextsForSkill(String skillId) {
    // Map skills to appropriate contexts
    if (skillId.contains('numeracy') || skillId.contains('number')) {
      return [
        'shopping',
        'sports',
        'money',
        'cooking',
        'travel',
        'time',
        'school'
      ];
    } else if (skillId.contains('literacy') || skillId.contains('reading')) {
      return [
        'stories',
        'recipes',
        'emails',
        'news',
        'ads',
        'instructions',
        'poetry'
      ];
    } else {
      return ['general', 'interesting', 'engaging', 'real-world', 'adventure'];
    }
  }
}

/// Word Woods (Literacy) Question Variation Engine
class WordWoodsVariationEngine extends QuestionVariationEngine {
  static final _random = math.Random();

  static final List<String> _wordContexts = [
    'stories',
    'recipes',
    'emails',
    'news',
    'advertisements',
    'instructions',
    'poetry',
    'dialogue',
    'social media',
    'informational text',
  ];

  static final List<String> _australianCulturalReferences = [
    'Bondi Beach',
    'Uluru',
    'Great Barrier Reef',
    'Outback',
    'Sydney Opera House',
    'kangaroos',
    'koalas',
    'Aboriginal art',
    'Aboriginal culture',
    'Australian animals',
  ];

  /// Generate homophones question (one of the high-risk NAPLAN areas)
  static GeneratedQuestion generateHomophonesQuestion({
    required int difficulty,
  }) {
    final pairs = [
      ('their', 'there'),
      ('to', 'too'),
      ('write', 'right'),
      ('break', 'brake'),
      ('meet', 'meat'),
      ('hear', 'here'),
      ('be', 'bee'),
      ('sea', 'see'),
      ('knight', 'night'),
      ('knows', 'nose'),
    ];

    final pair = pairs[_random.nextInt(pairs.length)];
    final correct = pair.$1;
    final homophone = pair.$2;

    return GeneratedQuestion(
      id: 'homophone_${DateTime.now().millisecondsSinceEpoch}',
      skillId: 'skill_homophones',
      questionText:
          'Which word is correct? "I can $homophone / $correct the answer."',
      options: [correct, homophone, 'nither', 'none of these'],
      correctIndex: 0,
      explanation:
          '$correct and $homophone sound the same but mean different things!',
      difficulty: difficulty,
      context: 'literacy',
      bloomLevel: CognitiveLevelBloom.understand.toString(),
      naplanStrand: NaplanStrand.grammar,
      naplanCategory: 'high_risk',
      estimatedTimeSeconds: 30,
    );
  }

  /// Generate vocabulary in context question
  static GeneratedQuestion generateVocabularyQuestion({
    required int difficulty,
  }) {
    final scenarios = [
      {
        'sentence': 'The old explorer was very _____ about the new discovery.',
        'correct': 'enthusiastic',
        'options': ['bored', 'tired', 'hungry'],
        'explanation': 'Enthusiastic means excited and eager.',
      },
      {
        'sentence': 'The team worked with great _____ to finish before sunset.',
        'correct': 'diligence',
        'options': ['laziness', 'speed', 'confusion'],
        'explanation': 'Diligence means careful and persistent effort.',
      },
      {
        'sentence': 'Her _____ smile showed she was happy about the surprise.',
        'correct': 'radiant',
        'options': ['sad', 'angry', 'confused'],
        'explanation': 'Radiant means shining brightly or glowing with joy.',
      },
    ];

    final scenario = scenarios[_random.nextInt(scenarios.length)];
    final context = _wordContexts[_random.nextInt(_wordContexts.length)];
    final options = [
      scenario['correct'] as String,
      ...((scenario['options'] as List).cast<String>())
    ]..shuffle();
    final correctIndex = options.indexOf(scenario['correct'] as String);

    return GeneratedQuestion(
      id: 'vocab_${DateTime.now().millisecondsSinceEpoch}',
      skillId: 'skill_vocabulary_context',
      questionText: scenario['sentence'] as String,
      options: options,
      correctIndex: correctIndex,
      explanation: scenario['explanation'] as String,
      difficulty: difficulty,
      context: context,
      bloomLevel: CognitiveLevelBloom.understand.toString(),
      naplanStrand: NaplanStrand.vocabulary,
      estimatedTimeSeconds: 45,
    );
  }

  /// Generate inference question (reading comprehension)
  static GeneratedQuestion generateInferenceQuestion({
    required int difficulty,
  }) {
    final stories = [
      {
        'text':
            'Sam looked at his lunch box. It was empty. His eyes went wide. His stomach rumbled loudly.',
        'question': 'Why did Sam\'s eyes go wide?',
        'correct': 'He realised he forgot his lunch',
        'options': ['He was happy', 'He was scared', 'He was bored'],
      },
      {
        'text':
            'The sky turned dark grey. The wind started to blow. People hurried inside with umbrellas.',
        'question': 'What was about to happen?',
        'correct': 'It was going to rain',
        'options': [
          'It was sunset',
          'An eclipse was coming',
          'A UFO was landing'
        ],
      },
      {
        'text':
            'Maya hadn\'t ridden her bike in a whole year. She was nervous as she pedalled down the street.',
        'question': 'Why was Maya nervous?',
        'correct': 'She worried she might have forgotten how to ride',
        'options': [
          'Her bike was broken',
          'The street was dangerous',
          'She didn\'t like biking'
        ],
      },
    ];

    final story = stories[_random.nextInt(stories.length)];
    final culturalReference = _australianCulturalReferences[
        _random.nextInt(_australianCulturalReferences.length)];
    final options = [
      story['correct'] as String,
      ...((story['options'] as List).cast<String>())
    ]..shuffle();
    final correctIndex = options.indexOf(story['correct'] as String);

    return GeneratedQuestion(
      id: 'inference_${DateTime.now().millisecondsSinceEpoch}',
      skillId: 'skill_inference',
      questionText: '${story['text']}\n\n${story['question']}',
      options: options,
      correctIndex: correctIndex,
      explanation:
          'We can infer this from the clues in the story. This is the same skill readers use when exploring texts about $culturalReference.',
      difficulty: difficulty,
      context: 'stories',
      bloomLevel: CognitiveLevelBloom.analyze.toString(),
      naplanStrand: NaplanStrand.reading,
      naplanCategory: 'high_risk',
      estimatedTimeSeconds: 60,
    );
  }

  static GeneratedQuestion generateForSkill({
    required String skillId,
    required int difficulty,
    required NaplanStrand? strand,
    String? preferredContext,
  }) {
    switch (skillId) {
      case 'skill_homophones':
        return generateHomophonesQuestion(difficulty: difficulty);
      case 'skill_vocabulary_context':
        return generateVocabularyQuestion(difficulty: difficulty);
      case 'skill_inference':
        return generateInferenceQuestion(difficulty: difficulty);
      default:
        throw UnsupportedError('Skill not supported: $skillId');
    }
  }
}

/// Number Nebula (Numeracy) Question Variation Engine
class NumberNebulaVariationEngine extends QuestionVariationEngine {
  static final _random = math.Random();

  /// Generate addition question with random numbers and contexts
  static GeneratedQuestion generateAdditionQuestion({
    required int difficulty,
  }) {
    // Difficulty 1-2: 0-10
    // Difficulty 3-4: 0-20
    // Difficulty 5: 0-50
    int maxNum = difficulty == 1
        ? 5
        : difficulty <= 2
            ? 10
            : difficulty <= 4
                ? 20
                : 50;

    final a = _random.nextInt(maxNum + 1);
    final b = _random.nextInt(maxNum + 1);
    final answer = a + b;

    final contexts = [
      'Sam collected $a shells at the beach. He found $b more shells. How many shells does Sam have altogether?',
      'A kangaroo hopped $a metres. Then it hopped $b more metres. How many metres did the kangaroo hop in total?',
      'The shop has $a apples in the basket. They get $b more apples. How many apples now?',
      'Ali scored $a goals in the first half. She scored $b goals in the second half. How many goals in total?',
      'A tree had $a birds. $b more birds landed on it. How many birds are now on the tree?',
    ];

    final context = contexts[_random.nextInt(contexts.length)];
    final options = [
      answer.toString(),
      (answer + 1).toString(),
      (answer - 1).toString(),
      (answer + 2).toString(),
    ]..shuffle();

    return GeneratedQuestion(
      id: 'addition_${DateTime.now().millisecondsSinceEpoch}',
      skillId: 'skill_addition',
      questionText: context,
      options: options,
      correctIndex: options.indexOf(answer.toString()),
      explanation: '$a + $b = $answer',
      difficulty: difficulty,
      context: 'practical_maths',
      bloomLevel: CognitiveLevelBloom.apply.toString(),
      naplanStrand: NaplanStrand.number,
      estimatedTimeSeconds: 30,
    );
  }

  /// Generate multiplication question
  static GeneratedQuestion generateMultiplicationQuestion({
    required int difficulty,
  }) {
    // Difficulty 1-2: Times tables 2-5
    // Difficulty 3-4: Times tables 6-10
    // Difficulty 5: Times tables 11-12 or larger numbers
    final multiplier = difficulty <= 2
        ? _random.nextInt(4) + 2
        : difficulty <= 4
            ? _random.nextInt(5) + 6
            : _random.nextInt(3) + 10;
    final multiplicand = _random.nextInt(12) + 1;
    final answer = multiplier * multiplicand;

    final contexts = [
      'There are $multiplier bags of lollies. Each bag has $multiplicand lollies. How many lollies altogether?',
      'A baker makes $multiplier trays of biscuits. Each tray has $multiplicand biscuits. How many biscuits in total?',
      'A car travels $multiplier times per day. Each trip is $multiplicand kilometres. Total kilometres per day?',
    ];

    final context = contexts[_random.nextInt(contexts.length)];

    final options = [
      answer.toString(),
      (answer + 1).toString(),
      (answer - 1).toString(),
      (answer + multiplier).toString(),
    ]..shuffle();

    return GeneratedQuestion(
      id: 'multiplication_${DateTime.now().millisecondsSinceEpoch}',
      skillId: 'skill_multiplication',
      questionText: context,
      options: options,
      correctIndex: options.indexOf(answer.toString()),
      explanation: '$multiplier × $multiplicand = $answer',
      difficulty: difficulty,
      context: 'practical_maths',
      bloomLevel: CognitiveLevelBloom.apply.toString(),
      naplanStrand: NaplanStrand.number,
      estimatedTimeSeconds: 45,
    );
  }

  static GeneratedQuestion generateForSkill({
    required String skillId,
    required int difficulty,
    required NaplanStrand? strand,
    String? preferredContext,
  }) {
    switch (skillId) {
      case 'skill_addition':
        return generateAdditionQuestion(difficulty: difficulty);
      case 'skill_multiplication':
        return generateMultiplicationQuestion(difficulty: difficulty);
      default:
        throw UnsupportedError('Skill not supported: $skillId');
    }
  }
}
