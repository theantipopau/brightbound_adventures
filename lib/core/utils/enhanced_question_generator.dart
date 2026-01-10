import 'dart:math';

/// Base class for enhanced question generation with anti-repetition
abstract class EnhancedQuestionGenerator {
  static final Random _random = Random();

  /// Pool of recently used questions to avoid repetition (stores question IDs)
  static final Set<String> _recentQuestions = {};
  static const int _maxRecentQuestions = 50;

  /// Track recently used values to ensure variety
  static final Map<String, List<dynamic>> _recentValues = {};

  /// Clear the recent questions cache (use when starting a new session)
  static void clearCache() {
    _recentQuestions.clear();
    _recentValues.clear();
  }

  /// Add a question ID to the recent pool
  static void markAsUsed(String questionId) {
    _recentQuestions.add(questionId);
    if (_recentQuestions.length > _maxRecentQuestions) {
      _recentQuestions.remove(_recentQuestions.first);
    }
  }

  /// Check if a question ID was recently used
  static bool wasRecentlyUsed(String questionId) {
    return _recentQuestions.contains(questionId);
  }

  /// Add a value to track recent usage (e.g., recently used numbers)
  static void trackValue(String category, dynamic value) {
    if (!_recentValues.containsKey(category)) {
      _recentValues[category] = [];
    }
    _recentValues[category]!.add(value);
    if (_recentValues[category]!.length > 20) {
      _recentValues[category]!.removeAt(0);
    }
  }

  /// Check if a value was recently used
  static bool wasValueRecentlyUsed(String category, dynamic value) {
    return _recentValues[category]?.contains(value) ?? false;
  }

  /// Get a random value that hasn't been used recently
  static T getUnusedValue<T>(String category, List<T> options,
      {int maxAttempts = 10}) {
    for (int i = 0; i < maxAttempts; i++) {
      final value = options[_random.nextInt(options.length)];
      if (!wasValueRecentlyUsed(category, value)) {
        trackValue(category, value);
        return value;
      }
    }
    // If all values were recently used, just return a random one
    final value = options[_random.nextInt(options.length)];
    trackValue(category, value);
    return value;
  }

  /// Generate random number avoiding recently used values
  static int getUnusedNumber(String category, int min, int max) {
    for (int i = 0; i < 10; i++) {
      final num = min + _random.nextInt(max - min + 1);
      if (!wasValueRecentlyUsed(category, num)) {
        trackValue(category, num);
        return num;
      }
    }
    final num = min + _random.nextInt(max - min + 1);
    trackValue(category, num);
    return num;
  }

  /// Shuffle a list and ensure first item isn't the answer (for better UX)
  static List<T> smartShuffle<T>(List<T> options, T correctAnswer) {
    final shuffled = List<T>.from(options)..shuffle(_random);
    // If correct answer is first, swap with a random other position
    if (shuffled.first == correctAnswer && shuffled.length > 1) {
      final swapIdx = 1 + _random.nextInt(shuffled.length - 1);
      final temp = shuffled[0];
      shuffled[0] = shuffled[swapIdx];
      shuffled[swapIdx] = temp;
    }
    return shuffled;
  }

  /// Generate wrong answers that are plausible but not correct
  static List<int> generatePlausibleWrongAnswers(int correct, int count,
      {int range = 5}) {
    final wrongs = <int>{};
    while (wrongs.length < count) {
      final offset = (_random.nextInt(range * 2 + 1) - range);
      final wrong = correct + offset;
      if (wrong != correct && wrong > 0) {
        wrongs.add(wrong);
      }
    }
    return wrongs.toList();
  }
}

/// Word banks for literacy questions - expanded significantly
class WordBanks {
  // Phonics words (expanded from 8 to 50+)
  static const simpleWords = [
    'cat',
    'dog',
    'sun',
    'bat',
    'pig',
    'hen',
    'fox',
    'cup',
    'mat',
    'hat',
    'rat',
    'bin',
    'pin',
    'can',
    'fan',
    'man',
    'red',
    'bed',
    'ten',
    'pen',
    'wet',
    'net',
    'pet',
    'set',
    'hot',
    'pot',
    'dot',
    'not',
    'mop',
    'top',
    'hop',
    'pop',
    'bug',
    'rug',
    'hug',
    'mug',
    'run',
    'fun',
    'bun',
    'sun',
    'big',
    'dig',
    'fig',
    'wig',
    'zip',
    'tip',
    'dip',
    'sip',
  ];

  // Sight words by difficulty
  static const beginnerSightWords = [
    'the',
    'and',
    'a',
    'to',
    'said',
    'you',
    'he',
    'I',
    'of',
    'it',
    'was',
    'for',
    'on',
    'are',
    'as',
    'with',
    'his',
    'they',
    'at',
    'be',
    'this',
    'from',
    'have',
  ];

  static const intermediateSightWords = [
    'about',
    'after',
    'again',
    'before',
    'because',
    'could',
    'every',
    'first',
    'found',
    'friend',
    'going',
    'great',
    'house',
    'know',
    'little',
    'more',
    'people',
    'their',
    'there',
    'these',
    'think',
    'through',
    'very',
    'water',
  ];

  // Rhyming word families
  static const rhymeFamilies = {
    'at': ['cat', 'bat', 'hat', 'mat', 'rat', 'sat', 'flat'],
    'an': ['can', 'fan', 'man', 'pan', 'ran', 'tan', 'plan'],
    'et': ['bet', 'get', 'jet', 'met', 'net', 'pet', 'set', 'wet'],
    'ig': ['big', 'dig', 'fig', 'pig', 'wig', 'twig'],
    'op': ['hop', 'mop', 'pop', 'top', 'stop', 'shop', 'drop'],
    'ug': ['bug', 'dug', 'hug', 'mug', 'rug', 'tug', 'slug'],
  };

  // Story elements
  static const storyCharacters = [
    'brave knight',
    'clever fox',
    'curious cat',
    'friendly dragon',
    'wise owl',
    'playful puppy',
    'magical unicorn',
    'kind bear',
    'silly monkey',
    'tiny mouse',
    'gentle giant',
    'sneaky raccoon',
  ];

  static const storySettings = [
    'enchanted forest',
    'mysterious castle',
    'sunny beach',
    'snowy mountain',
    'busy city',
    'quiet village',
    'deep ocean',
    'magical garden',
    'desert island',
    'ancient temple',
    'space station',
    'hidden cave',
  ];

  static const storyProblems = [
    'lost their way home',
    'needed to find a treasure',
    'had to solve a riddle',
    'wanted to make new friends',
    'searched for a magical object',
    'faced a big challenge',
    'needed to help someone',
    'discovered a secret',
    'went on an adventure',
    'solved a mystery',
  ];

  static const emotions = [
    'happy',
    'sad',
    'excited',
    'worried',
    'brave',
    'scared',
    'proud',
    'curious',
    'surprised',
    'confused',
    'angry',
    'peaceful',
  ];

  // Homophones (expanded)
  static const homophones = [
    {'their': 'ownership', 'there': 'location', 'they\'re': 'they are'},
    {'to': 'direction', 'too': 'also/very', 'two': 'number 2'},
    {'your': 'ownership', 'you\'re': 'you are'},
    {'its': 'ownership', 'it\'s': 'it is'},
    {'hear': 'with ears', 'here': 'this place'},
    {'sea': 'ocean', 'see': 'with eyes'},
    {'blue': 'colour', 'blew': 'past of blow'},
    {'new': 'not old', 'knew': 'past of know'},
    {'write': 'with pen', 'right': 'correct/direction'},
    {'tail': 'animal part', 'tale': 'story'},
  ];

  // Sentence starters for variety
  static const sentenceStarters = [
    'The',
    'A',
    'My',
    'Our',
    'One',
    'Once',
    'Every',
    'This',
    'That',
    'Some',
    'Many',
    'All',
    'Each',
    'Both',
    'Most',
  ];

  // Common nouns for sentence building
  static const nouns = [
    'cat',
    'dog',
    'bird',
    'tree',
    'flower',
    'house',
    'car',
    'book',
    'apple',
    'ball',
    'star',
    'moon',
    'sun',
    'cloud',
    'river',
    'mountain',
    'friend',
    'teacher',
    'parent',
    'child',
    'baby',
    'family',
  ];

  // Common verbs
  static const verbs = [
    'runs',
    'jumps',
    'plays',
    'eats',
    'sleeps',
    'reads',
    'writes',
    'sings',
    'dances',
    'swims',
    'flies',
    'walks',
    'talks',
    'laughs',
    'smiles',
    'helps',
  ];

  // Adjectives
  static const adjectives = [
    'big',
    'small',
    'happy',
    'sad',
    'fast',
    'slow',
    'bright',
    'dark',
    'hot',
    'cold',
    'soft',
    'hard',
    'loud',
    'quiet',
    'tall',
    'short',
    'pretty',
    'ugly',
    'clean',
    'dirty',
    'new',
    'old',
    'young',
    'beautiful',
  ];
}

/// Math problem contexts for word problems
class MathContexts {
  static final Random _random = Random();

  static const contexts = [
    // Addition contexts
    {
      'type': 'addition',
      'templates': [
        '{name} has {a} {item}. {pronoun_subject} finds {b} more. How many does {pronoun_subject} have now?',
        'There are {a} {item} in one basket and {b} in another. How many {item} in total?',
        '{name} collected {a} {item} on Monday and {b} on Tuesday. How many in total?',
      ],
    },
    // Subtraction contexts
    {
      'type': 'subtraction',
      'templates': [
        '{name} had {a} {item}. {pronoun_subject} gave {b} to a friend. How many are left?',
        'There were {a} {item} on the table. {b} were eaten. How many remain?',
        'A basket had {a} {item}. {name} took {b} away. How many are left?',
      ],
    },
    // Multiplication contexts
    {
      'type': 'multiplication',
      'templates': [
        '{name} has {a} boxes with {b} {item} in each box. How many {item} in total?',
        'There are {a} rows of {b} {item} each. How many {item} altogether?',
        '{name} bought {a} packs of {item}. Each pack has {b}. How many in total?',
      ],
    },
    // Division contexts
    {
      'type': 'division',
      'templates': [
        '{name} has {a} {item} to share equally among {b} friends. How many does each get?',
        'A box of {a} {item} is divided into {b} equal groups. How many in each group?',
        '{a} {item} are placed into {b} baskets. How many in each basket?',
      ],
    },
  ];

  static const names = [
    'Alex',
    'Sam',
    'Jamie',
    'Taylor',
    'Morgan',
    'Casey',
    'Jordan',
    'Riley',
    'Avery',
    'Quinn',
    'Blake',
    'Sage',
    'River',
    'Sky',
  ];

  static const items = [
    'apples',
    'oranges',
    'bananas',
    'cookies',
    'candies',
    'marbles',
    'stickers',
    'pencils',
    'books',
    'toys',
    'flowers',
    'stars',
    'balloons',
    'coins',
    'blocks',
    'cards',
    'stamps',
    'shells',
  ];

  static const pronouns = {
    'subject': ['he', 'she', 'they'],
    'object': ['him', 'her', 'them'],
  };

  /// Generate a contextualized word problem
  static String generateWordProblem(String type, int a, int b) {
    final contextList = contexts.where((c) => c['type'] == type).toList();
    if (contextList.isEmpty) return '';

    final context = contextList[_random.nextInt(contextList.length)];
    final templates = context['templates'] as List<String>;
    final template = templates[_random.nextInt(templates.length)];

    final name = EnhancedQuestionGenerator.getUnusedValue('name', names);
    final item = EnhancedQuestionGenerator.getUnusedValue('item', items);
    final pronoun =
        pronouns['subject']![_random.nextInt(pronouns['subject']!.length)];

    return template
        .replaceAll('{name}', name)
        .replaceAll('{a}', a.toString())
        .replaceAll('{b}', b.toString())
        .replaceAll('{item}', item)
        .replaceAll('{pronoun_subject}', pronoun);
  }
}

/// Logic puzzle templates
class LogicPuzzleTemplates {
  static const patterns = [
    // Color patterns
    {
      'pattern': ['🔴', '🔵'],
      'type': 'alternating'
    },
    {
      'pattern': ['⭐', '⭐', '🌙'],
      'type': 'repeating'
    },
    {
      'pattern': ['🐶', '🐱'],
      'type': 'alternating'
    },
    {
      'pattern': ['🍎', '🍌'],
      'type': 'alternating'
    },
    {
      'pattern': ['🟢', '🟢', '🟡'],
      'type': 'repeating'
    },
    {
      'pattern': ['🦁', '🐘', '🦒'],
      'type': 'sequence'
    },
    {
      'pattern': ['🌸', '🌸', '🌸', '🌺'],
      'type': 'repeating'
    },
  ];

  static const shapes = [
    '⚫',
    '⚪',
    '🔴',
    '🔵',
    '🟢',
    '🟡',
    '🟠',
    '🟣',
    '⬛',
    '⬜',
    '🟥',
    '🟦',
    '🟩',
    '🟨',
    '🟧',
    '🟪',
    '🔺',
    '🔻',
    '🔶',
    '🔷',
    '🔸',
    '🔹',
  ];

  static const sequenceTypes = [
    'increasing',
    'decreasing',
    'alternating',
    'repeating',
  ];
}
