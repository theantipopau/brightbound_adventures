import 'dart:math';

/// Massively expanded word banks for literacy activities
/// 200+ words organized by themes and difficulty
class LiteracyWordBank {
  static final Random _random = Random();

  // Story themes with associated words
  static final storyThemes = {
    'space': {
      'nouns': [
        'rocket',
        'planet',
        'star',
        'astronaut',
        'moon',
        'comet',
        'galaxy',
        'alien',
        'spaceship',
        'meteor'
      ],
      'verbs': [
        'fly',
        'float',
        'explore',
        'discover',
        'orbit',
        'launch',
        'land',
        'zoom',
        'blast',
        'soar'
      ],
      'adjectives': [
        'bright',
        'distant',
        'vast',
        'mysterious',
        'shiny',
        'dark',
        'endless',
        'sparkly',
        'round',
        'huge'
      ],
      'emoji': '🚀🌟🪐👽🌙',
    },
    'ocean': {
      'nouns': [
        'fish',
        'whale',
        'coral',
        'treasure',
        'ship',
        'dolphin',
        'wave',
        'beach',
        'shell',
        'pearl'
      ],
      'verbs': [
        'swim',
        'dive',
        'splash',
        'float',
        'sail',
        'surf',
        'jump',
        'glide',
        'sink',
        'flow'
      ],
      'adjectives': [
        'blue',
        'deep',
        'wavy',
        'salty',
        'cool',
        'clear',
        'vast',
        'smooth',
        'shiny',
        'wet'
      ],
      'emoji': '🌊🐟🐬🏖️🐚',
    },
    'forest': {
      'nouns': [
        'tree',
        'deer',
        'bear',
        'path',
        'bird',
        'squirrel',
        'flower',
        'mushroom',
        'stream',
        'cave'
      ],
      'verbs': [
        'climb',
        'run',
        'hide',
        'grow',
        'sing',
        'leap',
        'bloom',
        'rustle',
        'flow',
        'peek'
      ],
      'adjectives': [
        'green',
        'tall',
        'shady',
        'quiet',
        'wild',
        'leafy',
        'dense',
        'mossy',
        'peaceful',
        'cool'
      ],
      'emoji': '🌲🦌🐻🦅🌸',
    },
    'city': {
      'nouns': [
        'building',
        'car',
        'street',
        'park',
        'shop',
        'bus',
        'library',
        'school',
        'cafe',
        'museum'
      ],
      'verbs': [
        'walk',
        'drive',
        'shop',
        'play',
        'visit',
        'ride',
        'explore',
        'stop',
        'cross',
        'meet'
      ],
      'adjectives': [
        'busy',
        'tall',
        'crowded',
        'bright',
        'modern',
        'noisy',
        'colourful',
        'fast',
        'urban',
        'lively'
      ],
      'emoji': '🏙️🚗🏫🏪🚌',
    },
    'farm': {
      'nouns': [
        'barn',
        'cow',
        'chicken',
        'tractor',
        'field',
        'pig',
        'horse',
        'hay',
        'fence',
        'farmer'
      ],
      'verbs': [
        'plant',
        'harvest',
        'feed',
        'milk',
        'plow',
        'gather',
        'care',
        'tend',
        'grow',
        'ride'
      ],
      'adjectives': [
        'fresh',
        'sunny',
        'muddy',
        'wide',
        'quiet',
        'green',
        'peaceful',
        'open',
        'rolling',
        'golden'
      ],
      'emoji': '🚜🐄🐔🌾🏡',
    },
    'kitchen': {
      'nouns': [
        'spoon',
        'bowl',
        'oven',
        'plate',
        'cup',
        'fork',
        'pot',
        'pan',
        'food',
        'table'
      ],
      'verbs': [
        'cook',
        'bake',
        'mix',
        'stir',
        'pour',
        'chop',
        'taste',
        'serve',
        'eat',
        'wash'
      ],
      'adjectives': [
        'hot',
        'yummy',
        'sweet',
        'fresh',
        'warm',
        'tasty',
        'clean',
        'full',
        'empty',
        'round'
      ],
      'emoji': '🍳🥄🍽️🎂🥗',
    },
    'playground': {
      'nouns': [
        'swing',
        'slide',
        'sandbox',
        'friend',
        'ball',
        'jump rope',
        'seesaw',
        'monkey bars',
        'park',
        'game'
      ],
      'verbs': [
        'play',
        'swing',
        'slide',
        'jump',
        'run',
        'climb',
        'laugh',
        'share',
        'chase',
        'catch'
      ],
      'adjectives': [
        'fun',
        'happy',
        'fast',
        'high',
        'colourful',
        'safe',
        'exciting',
        'friendly',
        'active',
        'sunny'
      ],
      'emoji': '🎡⛹️🤾🎪😄',
    },
    'weather': {
      'nouns': [
        'rain',
        'sun',
        'cloud',
        'wind',
        'snow',
        'storm',
        'rainbow',
        'thunder',
        'lightning',
        'fog'
      ],
      'verbs': [
        'shine',
        'blow',
        'pour',
        'snow',
        'drizzle',
        'clear',
        'storm',
        'freeze',
        'melt',
        'float'
      ],
      'adjectives': [
        'sunny',
        'rainy',
        'windy',
        'cold',
        'hot',
        'cloudy',
        'snowy',
        'stormy',
        'clear',
        'foggy'
      ],
      'emoji': '☀️🌧️⛈️🌈❄️',
    },
  };

  // Phonics patterns
  static final phonicsPatterns = {
    'short_a': [
      'cat',
      'bat',
      'hat',
      'mat',
      'rat',
      'sat',
      'pat',
      'fat',
      'flat',
      'chat'
    ],
    'short_e': [
      'bed',
      'red',
      'fed',
      'led',
      'wed',
      'sled',
      'shed',
      'pet',
      'jet',
      'wet'
    ],
    'short_i': [
      'big',
      'pig',
      'dig',
      'fig',
      'wig',
      'sit',
      'bit',
      'hit',
      'lit',
      'fit'
    ],
    'short_o': [
      'dog',
      'log',
      'fog',
      'jog',
      'hot',
      'dot',
      'pot',
      'cot',
      'got',
      'lot'
    ],
    'short_u': [
      'bug',
      'hug',
      'mug',
      'rug',
      'dug',
      'tug',
      'cut',
      'hut',
      'nut',
      'but'
    ],
    'long_a': [
      'cake',
      'make',
      'take',
      'lake',
      'bake',
      'rake',
      'name',
      'game',
      'same',
      'came'
    ],
    'long_e': [
      'see',
      'bee',
      'tree',
      'free',
      'three',
      'knee',
      'feet',
      'meet',
      'sweet',
      'street'
    ],
    'long_i': [
      'bike',
      'like',
      'hike',
      'mike',
      'kite',
      'bite',
      'white',
      'night',
      'right',
      'light'
    ],
    'long_o': [
      'go',
      'no',
      'so',
      'boat',
      'coat',
      'goat',
      'road',
      'toad',
      'home',
      'bone'
    ],
    'long_u': [
      'cute',
      'mute',
      'flute',
      'use',
      'fuse',
      'tube',
      'cube',
      'huge',
      'rule',
      'tune'
    ],
    'ch': [
      'chip',
      'chop',
      'chat',
      'chick',
      'chin',
      'chess',
      'chest',
      'church',
      'cheese',
      'cherry'
    ],
    'sh': [
      'ship',
      'shop',
      'shut',
      'shell',
      'shark',
      'sheep',
      'shoe',
      'shine',
      'shake',
      'shape'
    ],
    'th': [
      'that',
      'this',
      'them',
      'then',
      'thick',
      'thin',
      'thing',
      'think',
      'three',
      'throw'
    ],
    'wh': [
      'when',
      'what',
      'where',
      'which',
      'white',
      'whale',
      'wheat',
      'wheel',
      'while',
      'whip'
    ],
    'oo': [
      'book',
      'look',
      'took',
      'cook',
      'hook',
      'moon',
      'soon',
      'noon',
      'room',
      'zoom'
    ],
  };

  // High-frequency sight words by level
  static final sightWords = {
    'level_1': [
      'the',
      'and',
      'a',
      'to',
      'in',
      'is',
      'you',
      'that',
      'it',
      'he',
      'was',
      'for',
      'on',
      'are',
      'as'
    ],
    'level_2': [
      'with',
      'his',
      'they',
      'at',
      'be',
      'this',
      'have',
      'from',
      'or',
      'one',
      'had',
      'by',
      'word',
      'but',
      'not'
    ],
    'level_3': [
      'what',
      'all',
      'were',
      'we',
      'when',
      'your',
      'can',
      'said',
      'there',
      'use',
      'an',
      'each',
      'which',
      'she',
      'do'
    ],
    'level_4': [
      'how',
      'their',
      'if',
      'will',
      'up',
      'other',
      'about',
      'out',
      'many',
      'then',
      'them',
      'these',
      'so',
      'some',
      'her'
    ],
    'level_5': [
      'would',
      'make',
      'like',
      'him',
      'into',
      'time',
      'has',
      'look',
      'two',
      'more',
      'write',
      'go',
      'see',
      'number',
      'no'
    ],
  };

  // Sentence starters for creative writing
  static final sentenceStarters = [
    'Once upon a time',
    'Long ago',
    'In a land far away',
    'One sunny day',
    'Yesterday I saw',
    'My best friend and I',
    'If I could fly',
    'When I grow up',
    'The magical',
    'In my dream',
    'At the park',
    'Under the sea',
    'On a rainy day',
    'In the forest',
    'At school today',
    'My favorite thing',
    'I wonder why',
    'Can you believe',
    'It was amazing when',
    'I learned that',
  ];

  // Descriptive word pairs
  static final descriptivePairs = [
    {'adjective': 'tiny', 'opposite': 'huge', 'emoji': '🐜🐘'},
    {'adjective': 'fast', 'opposite': 'slow', 'emoji': '🐆🐢'},
    {'adjective': 'hot', 'opposite': 'cold', 'emoji': '🔥❄️'},
    {'adjective': 'happy', 'opposite': 'sad', 'emoji': '😊😢'},
    {'adjective': 'loud', 'opposite': 'quiet', 'emoji': '📢🤫'},
    {'adjective': 'bright', 'opposite': 'dark', 'emoji': '💡🌙'},
    {'adjective': 'full', 'opposite': 'empty', 'emoji': '🥤🫗'},
    {'adjective': 'strong', 'opposite': 'weak', 'emoji': '💪🤏'},
    {'adjective': 'heavy', 'opposite': 'light', 'emoji': '🏋️🪶'},
    {'adjective': 'rough', 'opposite': 'smooth', 'emoji': '🪨🧈'},
  ];

  // Compound words
  static final compoundWords = [
    {'word': 'sunflower', 'part1': 'sun', 'part2': 'flower', 'emoji': '🌻'},
    {'word': 'rainbow', 'part1': 'rain', 'part2': 'bow', 'emoji': '🌈'},
    {'word': 'cupcake', 'part1': 'cup', 'part2': 'cake', 'emoji': '🧁'},
    {'word': 'basketball', 'part1': 'basket', 'part2': 'ball', 'emoji': '🏀'},
    {'word': 'butterfly', 'part1': 'butter', 'part2': 'fly', 'emoji': '🦋'},
    {'word': 'snowman', 'part1': 'snow', 'part2': 'man', 'emoji': '⛄'},
    {'word': 'starfish', 'part1': 'star', 'part2': 'fish', 'emoji': '⭐🐟'},
    {'word': 'mailbox', 'part1': 'mail', 'part2': 'box', 'emoji': '📬'},
    {'word': 'pancake', 'part1': 'pan', 'part2': 'cake', 'emoji': '🥞'},
    {'word': 'bookshelf', 'part1': 'book', 'part2': 'shelf', 'emoji': '📚'},
    {'word': 'toothbrush', 'part1': 'tooth', 'part2': 'brush', 'emoji': '🪥'},
    {'word': 'bedroom', 'part1': 'bed', 'part2': 'room', 'emoji': '🛏️'},
    {'word': 'sunshine', 'part1': 'sun', 'part2': 'shine', 'emoji': '☀️'},
    {'word': 'backpack', 'part1': 'back', 'part2': 'pack', 'emoji': '🎒'},
    {'word': 'football', 'part1': 'foot', 'part2': 'ball', 'emoji': '⚽'},
  ];

  // Rhyming families
  static final rhymingFamilies = {
    'at': [
      'cat',
      'bat',
      'hat',
      'mat',
      'rat',
      'sat',
      'pat',
      'fat',
      'chat',
      'flat'
    ],
    'an': [
      'can',
      'man',
      'pan',
      'ran',
      'fan',
      'tan',
      'van',
      'plan',
      'scan',
      'than'
    ],
    'op': [
      'hop',
      'pop',
      'top',
      'mop',
      'shop',
      'stop',
      'drop',
      'crop',
      'flop',
      'prop'
    ],
    'ig': ['big', 'dig', 'fig', 'pig', 'wig', 'twig', 'brig'],
    'ug': [
      'bug',
      'dug',
      'hug',
      'jug',
      'mug',
      'rug',
      'tug',
      'slug',
      'plug',
      'snug'
    ],
    'ay': [
      'day',
      'may',
      'way',
      'say',
      'pay',
      'play',
      'stay',
      'gray',
      'spray',
      'tray'
    ],
    'ake': [
      'bake',
      'cake',
      'lake',
      'make',
      'take',
      'wake',
      'shake',
      'brake',
      'snake',
      'flake'
    ],
    'ine': [
      'fine',
      'line',
      'mine',
      'nine',
      'pine',
      'vine',
      'shine',
      'spine',
      'whine',
      'combine'
    ],
    'ock': [
      'block',
      'clock',
      'dock',
      'lock',
      'rock',
      'sock',
      'knock',
      'flock',
      'shock',
      'stock'
    ],
    'ing': [
      'king',
      'ring',
      'sing',
      'wing',
      'bring',
      'spring',
      'thing',
      'swing',
      'string',
      'bling'
    ],
  };

  // Action verbs with visuals
  static final actionVerbs = [
    {'verb': 'jump', 'emoji': '🦘', 'past': 'jumped', 'ing': 'jumping'},
    {'verb': 'run', 'emoji': '🏃', 'past': 'ran', 'ing': 'running'},
    {'verb': 'swim', 'emoji': '🏊', 'past': 'swam', 'ing': 'swimming'},
    {'verb': 'dance', 'emoji': '💃', 'past': 'danced', 'ing': 'dancing'},
    {'verb': 'sing', 'emoji': '🎤', 'past': 'sang', 'ing': 'singing'},
    {'verb': 'fly', 'emoji': '🦅', 'past': 'flew', 'ing': 'flying'},
    {'verb': 'climb', 'emoji': '🧗', 'past': 'climbed', 'ing': 'climbing'},
    {'verb': 'read', 'emoji': '📖', 'past': 'read', 'ing': 'reading'},
    {'verb': 'write', 'emoji': '✍️', 'past': 'wrote', 'ing': 'writing'},
    {'verb': 'draw', 'emoji': '🎨', 'past': 'drew', 'ing': 'drawing'},
    {'verb': 'eat', 'emoji': '🍽️', 'past': 'ate', 'ing': 'eating'},
    {'verb': 'sleep', 'emoji': '😴', 'past': 'slept', 'ing': 'sleeping'},
    {'verb': 'play', 'emoji': '🎮', 'past': 'played', 'ing': 'playing'},
    {'verb': 'laugh', 'emoji': '😄', 'past': 'laughed', 'ing': 'laughing'},
    {'verb': 'think', 'emoji': '🤔', 'past': 'thought', 'ing': 'thinking'},
  ];

  // Helper methods
  static String getRandomTheme() {
    return storyThemes.keys.elementAt(_random.nextInt(storyThemes.length));
  }

  static List<String> getThemeWords(String theme, String type) {
    return storyThemes[theme]?[type] as List<String>? ?? [];
  }

  static String getThemeEmoji(String theme) {
    return storyThemes[theme]?['emoji'] as String? ?? '';
  }

  static List<String> getPhonicsWords(String pattern) {
    return phonicsPatterns[pattern] ?? [];
  }

  static List<String> getSightWords(String level) {
    return sightWords[level] ?? [];
  }

  static String getRandomSentenceStarter() {
    return sentenceStarters[_random.nextInt(sentenceStarters.length)];
  }

  static Map<String, dynamic> getRandomCompoundWord() {
    return compoundWords[_random.nextInt(compoundWords.length)];
  }

  static List<String> getRhymingFamily(String family) {
    return rhymingFamilies[family] ?? [];
  }

  static Map<String, dynamic> getRandomActionVerb() {
    return actionVerbs[_random.nextInt(actionVerbs.length)];
  }

  // ==================== AUSTRALIAN CONTENT ====================

  /// Australian-specific vocabulary for cultural context
  static final Map<String, List<String>> australianVocabulary = {
    'animals': [
      'kangaroo',
      'koala',
      'wombat',
      'platypus',
      'emu',
      'kookaburra',
      'galah',
      'possum',
      'wallaby',
      'quokka'
    ],
    'food': [
      'lamington',
      'pavlova',
      'Vegemite',
      'Tim Tam',
      'meat pie',
      'sausage roll',
      'fairy bread',
      'Anzac biscuit',
      'lamington',
      'macadamia'
    ],
    'places': [
      'outback',
      'bush',
      'billabong',
      'reef',
      'beach',
      'gumtree',
      'waterhole',
      'scrub',
      'rainforest',
      'coast'
    ],
    'sports': [
      'footy',
      'cricket',
      'netball',
      'rugby',
      'surfing',
      'swimming',
      'AFL',
      'league',
      'tennis',
      'sailing'
    ],
    'slang': [
      'arvo',
      'barbie',
      'brekkie',
      'chook',
      'esky',
      'dunny',
      'ute',
      'thongs',
      'togs',
      'servo'
    ],
    'school': [
      'tuckshop',
      'canteen',
      'oval',
      'assembly',
      'fête',
      'excursion',
      'classroom',
      'playground',
      'library',
      'uniform'
    ],
  };

  /// Australian English spelling differences (correct Australian spelling)
  static final Map<String, String> australianSpelling = {
    'colour': 'colour', 'favourite': 'favourite', 'honour': 'honour',
    'neighbour': 'neighbour', 'flavour': 'flavour', 'harbour': 'harbour',
    'centre': 'centre', 'metre': 'metre', 'theatre': 'theatre',
    'fibre': 'fibre', 'litre': 'litre', 'organise': 'organise',
    'realise': 'realise', 'recognise': 'recognise', 'analyse': 'analyse',
    'defence': 'defence', 'offence': 'offence', 'licence': 'licence',
    'practise': 'practise', // verb
    'practice': 'practice', // noun
  };

  static String getRandomAustralianWord(String category) {
    final words =
        australianVocabulary[category] ?? australianVocabulary['animals']!;
    return words[_random.nextInt(words.length)];
  }
}
