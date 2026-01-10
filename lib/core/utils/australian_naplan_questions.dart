import 'dart:math';

/// Australian English & NAPLAN-aligned Question Bank
/// Based on ACARA curriculum standards and NAPLAN assessment formats
/// Australian spelling: colour, favourite, metre, centre, practise (verb), practice (noun), etc.
class AustralianNAPLANQuestions {
  static final Random _random = Random();

  // ==================== NUMERACY ====================

  /// Year 1-2 NAPLAN Numeracy (Ages 5-7)
  static Map<String, dynamic> generateYear1Numeracy(
      String topic, int difficulty) {
    switch (topic) {
      case 'addition':
        return _year1Addition(difficulty);
      case 'subtraction':
        return _year1Subtraction(difficulty);
      case 'counting':
        return _year1Counting(difficulty);
      case 'money':
        return _year1Money(difficulty);
      default:
        return _year1Addition(difficulty);
    }
  }

  static Map<String, dynamic> _year1Addition(int difficulty) {
    final scenarios = [
      {
        'context':
            'Mia has {a} lamingtons. She bakes {b} more. How many lamingtons does she have now?',
        'theme': 'food'
      },
      {
        'context':
            'There are {a} kangaroos at the waterhole. {b} more hop over. How many kangaroos in total?',
        'theme': 'animals'
      },
      {
        'context':
            'You find {a} shells at Bondi Beach. Your friend finds {b} shells. How many shells altogether?',
        'theme': 'beach'
      },
      {
        'context':
            'The footy team scored {a} goals in the first half and {b} in the second half. Total goals?',
        'theme': 'sport'
      },
      {
        'context':
            'Grandma has {a} Anzac biscuits on a plate. She bakes {b} more. How many biscuits now?',
        'theme': 'food'
      },
    ];

    final nums = _getNumberPair(difficulty, 1, 10);
    final scenario = scenarios[_random.nextInt(scenarios.length)];
    final question = scenario['context']!
        .replaceAll('{a}', '${nums[0]}')
        .replaceAll('{b}', '${nums[1]}');

    return {
      'question': question,
      'answer': nums[0] + nums[1],
      'type': 'addition',
      'difficulty': difficulty,
      'theme': scenario['theme'],
    };
  }

  static Map<String, dynamic> _year1Subtraction(int difficulty) {
    final scenarios = [
      {
        'context':
            'Dad has {a} meat pies. The family eats {b}. How many pies are left?',
        'theme': 'food'
      },
      {
        'context':
            '{a} galahs were in the tree. {b} flew away. How many galahs stayed?',
        'theme': 'birds'
      },
      {
        'context':
            'You had {a} dollars. You spent {b} dollars at the tuckshop. How much money left?',
        'theme': 'money'
      },
      {
        'context':
            'There were {a} cricket balls in the shed. {b} were taken to the oval. How many left?',
        'theme': 'sport'
      },
      {
        'context':
            'Mum bought {a} Tim Tams. We ate {b} of them. How many Tim Tams remain?',
        'theme': 'food'
      },
    ];

    final nums = _getSubtractionPair(difficulty, 1, 10);
    final scenario = scenarios[_random.nextInt(scenarios.length)];
    final question = scenario['context']!
        .replaceAll('{a}', '${nums[0]}')
        .replaceAll('{b}', '${nums[1]}');

    return {
      'question': question,
      'answer': nums[0] - nums[1],
      'type': 'subtraction',
      'difficulty': difficulty,
      'theme': scenario['theme'],
    };
  }

  static Map<String, dynamic> _year1Counting(int difficulty) {
    final scenarios = [
      'Count by twos: 2, 4, 6, 8, ?',
      'Count by fives: 5, 10, 15, 20, ?',
      'What number comes after 19?',
      'What number comes before 30?',
      'Skip count by tens: 10, 20, 30, ?',
    ];

    final answers = [10, 25, 20, 29, 40];
    final index = _random.nextInt(scenarios.length);

    return {
      'question': scenarios[index],
      'answer': answers[index],
      'type': 'counting',
      'difficulty': difficulty,
    };
  }

  static Map<String, dynamic> _year1Money(int difficulty) {
    final scenarios = [
      {
        'context':
            'A paddle pop costs \$2. You have a \$5 note. How much change?',
        'answer': 3
      },
      {
        'context': 'Chips cost \$1 and a drink costs \$2. How much for both?',
        'answer': 3
      },
      {
        'context': 'You have three \$1 coins. How many dollars do you have?',
        'answer': 3
      },
      {
        'context': 'A sausage roll is \$4. How many \$1 coins do you need?',
        'answer': 4
      },
      {
        'context':
            'Mum gives you \$5. You spend \$2 at the canteen. Money left?',
        'answer': 3
      },
    ];

    final scenario = scenarios[_random.nextInt(scenarios.length)];

    return {
      'question': scenario['context'],
      'answer': scenario['answer'],
      'type': 'money',
      'difficulty': difficulty,
      'theme': 'currency',
    };
  }

  /// Year 3-4 NAPLAN Numeracy (Ages 8-9)
  static Map<String, dynamic> generateYear3Numeracy(
      String topic, int difficulty) {
    switch (topic) {
      case 'multiplication':
        return _year3Multiplication(difficulty);
      case 'division':
        return _year3Division(difficulty);
      case 'fractions':
        return _year3Fractions(difficulty);
      case 'measurement':
        return _year3Measurement(difficulty);
      default:
        return _year3Multiplication(difficulty);
    }
  }

  static Map<String, dynamic> _year3Multiplication(int difficulty) {
    final scenarios = [
      {
        'context':
            'Each cricket team has {a} players. There are {b} teams. How many players altogether?',
        'theme': 'sport'
      },
      {
        'context':
            'A box holds {a} Vegemite jars. You buy {b} boxes. How many jars in total?',
        'theme': 'food'
      },
      {
        'context':
            'Each carriage on the tram seats {a} people. There are {b} carriages. Total seats?',
        'theme': 'transport'
      },
      {
        'context':
            'The AFL team trains {a} hours each day for {b} days. Total training hours?',
        'theme': 'sport'
      },
      {
        'context':
            'Each pavlova needs {a} egg whites. Making {b} pavlovas. How many eggs needed?',
        'theme': 'cooking'
      },
    ];

    final nums = _getNumberPair(difficulty, 2, 12);
    final scenario = scenarios[_random.nextInt(scenarios.length)];
    final question = scenario['context']!
        .replaceAll('{a}', '${nums[0]}')
        .replaceAll('{b}', '${nums[1]}');

    return {
      'question': question,
      'answer': nums[0] * nums[1],
      'type': 'multiplication',
      'difficulty': difficulty,
      'theme': scenario['theme'],
    };
  }

  static Map<String, dynamic> _year3Division(int difficulty) {
    final divisor =
        difficulty == 1 ? _random.nextInt(4) + 2 : _random.nextInt(8) + 3;
    final quotient = _random.nextInt(8) + 2;
    final dividend = divisor * quotient;

    final scenarios = [
      {
        'context':
            '{a} mangoes shared equally among {b} friends. How many each?',
        'theme': 'sharing'
      },
      {
        'context':
            '{a} footy cards arranged in {b} equal piles. How many cards per pile?',
        'theme': 'sport'
      },
      {
        'context':
            'The school has {a} computers for {b} classrooms. How many per room?',
        'theme': 'school'
      },
      {
        'context':
            '{a} swimmers divided into {b} equal lanes. Swimmers per lane?',
        'theme': 'sport'
      },
    ];

    final scenario = scenarios[_random.nextInt(scenarios.length)];
    final question = scenario['context']!
        .replaceAll('{a}', '$dividend')
        .replaceAll('{b}', '$divisor');

    return {
      'question': question,
      'answer': quotient,
      'type': 'division',
      'difficulty': difficulty,
      'theme': scenario['theme'],
    };
  }

  static Map<String, dynamic> _year3Fractions(int difficulty) {
    final scenarios = [
      {
        'context': 'You eat 1/2 of a lamington. What fraction is left?',
        'answer': '1/2',
        'theme': 'food'
      },
      {
        'context':
            'A pizza is cut into 4 equal pieces. You eat 1 piece. What fraction did you eat?',
        'answer': '1/4',
        'theme': 'food'
      },
      {
        'context':
            'There are 8 slices of watermelon. You eat 2. What fraction did you eat?',
        'answer': '1/4',
        'theme': 'food'
      },
      {
        'context':
            'A chocolate bar has 6 pieces. You eat 3. What fraction did you eat?',
        'answer': '1/2',
        'theme': 'food'
      },
    ];

    final scenario = scenarios[_random.nextInt(scenarios.length)];

    return {
      'question': scenario['context'],
      'answer': scenario['answer'],
      'type': 'fractions',
      'difficulty': difficulty,
      'theme': scenario['theme'],
    };
  }

  static Map<String, dynamic> _year3Measurement(int difficulty) {
    final scenarios = [
      {
        'context': 'The classroom is 10 metres long. How many centimetres?',
        'answer': 1000,
        'unit': 'cm'
      },
      {
        'context':
            'A cricket pitch is 20 metres long. That\'s how many centimetres?',
        'answer': 2000,
        'unit': 'cm'
      },
      {
        'context':
            'Your water bottle holds 500 millilitres. How many litres is that?',
        'answer': 0.5,
        'unit': 'L'
      },
      {
        'context': 'The pool is 50 metres long. In centimetres?',
        'answer': 5000,
        'unit': 'cm'
      },
      {
        'context':
            'A packet of Tim Tams weighs 200 grams. That\'s how many kilograms?',
        'answer': 0.2,
        'unit': 'kg'
      },
    ];

    final scenario = scenarios[_random.nextInt(scenarios.length)];

    return {
      'question': scenario['context'],
      'answer': scenario['answer'],
      'type': 'measurement',
      'difficulty': difficulty,
      'unit': scenario['unit'],
    };
  }

  // ==================== LITERACY ====================

  /// Year 1-2 NAPLAN Literacy (Ages 5-7)
  static Map<String, dynamic> generateYear1Literacy(
      String topic, int difficulty) {
    switch (topic) {
      case 'spelling':
        return _year1Spelling(difficulty);
      case 'reading':
        return _year1Reading(difficulty);
      case 'grammar':
        return _year1Grammar(difficulty);
      default:
        return _year1Spelling(difficulty);
    }
  }

  static Map<String, dynamic> _year1Spelling(int difficulty) {
    // Australian English spelling focus
    final words = {
      1: ['mum', 'dad', 'cat', 'dog', 'sun', 'hat', 'run', 'fun', 'bed', 'red'],
      2: [
        'colour',
        'favourite',
        'centre',
        'metre',
        'theatre',
        'neighbour',
        'harbour',
        'favour'
      ],
      3: [
        'beautiful',
        'necessary',
        'recognise',
        'organise',
        'practise',
        'licence',
        'defence'
      ],
    };

    final wordList = words[difficulty] ?? words[1]!;
    final word = wordList[_random.nextInt(wordList.length)];

    return {
      'question': 'Spell this word: $word',
      'answer': word,
      'type': 'spelling',
      'difficulty': difficulty,
    };
  }

  static Map<String, dynamic> _year1Reading(int difficulty) {
    final passages = [
      {
        'text':
            'The kangaroo hopped across the paddock. It was looking for water.',
        'question': 'What was the kangaroo looking for?',
        'answer': 'water',
      },
      {
        'text':
            'We went to the beach yesterday. We built sandcastles and swam in the surf.',
        'question': 'Where did they go?',
        'answer': 'beach',
      },
      {
        'text': 'Mum made lamingtons for the school fête. Everyone loved them!',
        'question': 'What did Mum make?',
        'answer': 'lamingtons',
      },
    ];

    final passage = passages[_random.nextInt(passages.length)];

    return {
      'passage': passage['text'],
      'question': passage['question'],
      'answer': passage['answer'],
      'type': 'reading_comprehension',
      'difficulty': difficulty,
    };
  }

  static Map<String, dynamic> _year1Grammar(int difficulty) {
    final questions = [
      {
        'question': 'Choose the correct word: I went (to/too/two) the shops.',
        'answer': 'to',
        'options': ['to', 'too', 'two'],
      },
      {
        'question':
            'Which is correct? (Their/They\'re/There) going to the park.',
        'answer': 'They\'re',
        'options': ['Their', 'They\'re', 'There'],
      },
      {
        'question': 'Fix this sentence: the dog barked loudly',
        'answer': 'The dog barked loudly.',
        'explanation': 'Capital letter at start, full stop at end',
      },
    ];

    final q = questions[_random.nextInt(questions.length)];

    return {
      'question': q['question'],
      'answer': q['answer'],
      'type': 'grammar',
      'difficulty': difficulty,
      'options': q['options'],
    };
  }

  /// Year 3-4 NAPLAN Literacy (Ages 8-9)
  static Map<String, dynamic> generateYear3Literacy(
      String topic, int difficulty) {
    switch (topic) {
      case 'vocabulary':
        return _year3Vocabulary(difficulty);
      case 'comprehension':
        return _year3Comprehension(difficulty);
      case 'punctuation':
        return _year3Punctuation(difficulty);
      default:
        return _year3Vocabulary(difficulty);
    }
  }

  static Map<String, dynamic> _year3Vocabulary(int difficulty) {
    final questions = [
      {
        'question': 'What does "fair dinkum" mean?',
        'answer': 'genuine or true',
        'options': ['genuine or true', 'not real', 'expensive', 'colourful'],
      },
      {
        'question': 'A "bush tucker" is:',
        'answer': 'native Australian food',
        'options': [
          'native Australian food',
          'a type of tree',
          'a bird',
          'a tool'
        ],
      },
      {
        'question': 'If something is "bonza", it is:',
        'answer': 'excellent',
        'options': ['excellent', 'terrible', 'average', 'cold'],
      },
    ];

    final q = questions[_random.nextInt(questions.length)];

    return {
      'question': q['question'],
      'answer': q['answer'],
      'type': 'vocabulary',
      'difficulty': difficulty,
      'options': q['options'],
    };
  }

  static Map<String, dynamic> _year3Comprehension(int difficulty) {
    final passages = [
      {
        'text':
            '''The Great Barrier Reef is the world's largest coral reef system. It stretches over 2,300 kilometres along Queensland's coast. The reef is home to thousands of species of fish, turtles, and other marine life. It's so large you can see it from space!''',
        'question': 'How long is the Great Barrier Reef?',
        'answer': '2,300 kilometres',
        'options': [
          '1,000 kilometres',
          '2,300 kilometres',
          '5,000 kilometres',
          '10,000 kilometres'
        ],
      },
      {
        'text':
            '''Wombats are Australian marsupials known for their cube-shaped poo! They dig extensive burrow systems and are most active at night. A wombat's burrow can be up to 30 metres long. They use their cube poo to mark their territory.''',
        'question': 'Why do wombats have cube-shaped poo?',
        'answer': 'to mark their territory',
        'options': [
          'to mark their territory',
          'because they eat cubes',
          'to build their burrows',
          'to attract mates'
        ],
      },
    ];

    final passage = passages[_random.nextInt(passages.length)];

    return {
      'passage': passage['text'],
      'question': passage['question'],
      'answer': passage['answer'],
      'type': 'reading_comprehension',
      'difficulty': difficulty,
      'options': passage['options'],
    };
  }

  static Map<String, dynamic> _year3Punctuation(int difficulty) {
    final questions = [
      {
        'question':
            'Add punctuation: Sydney Melbourne and Brisbane are big cities',
        'answer': 'Sydney, Melbourne, and Brisbane are big cities.',
        'explanation': 'Commas separate items in a list',
      },
      {
        'question':
            'Which needs an apostrophe? The dogs bowl / The dog\'s bowl',
        'answer': 'The dog\'s bowl',
        'explanation': 'Apostrophe shows possession',
      },
    ];

    final q = questions[_random.nextInt(questions.length)];

    return {
      'question': q['question'],
      'answer': q['answer'],
      'type': 'punctuation',
      'difficulty': difficulty,
      'explanation': q['explanation'],
    };
  }

  // ==================== HELPER METHODS ====================

  static List<int> _getNumberPair(int difficulty, int min, int max) {
    switch (difficulty) {
      case 1: // Easy
        final a = _random.nextInt(5) + min;
        final b = _random.nextInt(5) + min;
        return [a, b];
      case 2: // Medium
        final a = _random.nextInt(8) + min;
        final b = _random.nextInt(8) + min;
        return [a, b];
      case 3: // Hard
        final a = _random.nextInt(max - min) + min;
        final b = _random.nextInt(max - min) + min;
        return [a, b];
      default:
        return [_random.nextInt(max) + min, _random.nextInt(max) + min];
    }
  }

  static List<int> _getSubtractionPair(int difficulty, int min, int max) {
    final nums = _getNumberPair(difficulty, min, max);
    // Ensure a >= b for valid subtraction
    if (nums[0] < nums[1]) {
      return [nums[1], nums[0]];
    }
    return nums;
  }

  /// Australian-specific cultural references
  static List<String> get australianContexts => [
        'kangaroo',
        'koala',
        'emu',
        'platypus',
        'wombat',
        'kookaburra',
        'lamington',
        'pavlova',
        'Vegemite',
        'Tim Tam',
        'meat pie',
        'sausage roll',
        'AFL',
        'cricket',
        'netball',
        'rugby',
        'swimming',
        'surfing',
        'beach',
        'bush',
        'outback',
        'reef',
        'rainforest',
        'billabong',
        'Melbourne',
        'Sydney',
        'Brisbane',
        'Perth',
        'Adelaide',
        'Hobart',
        'tuckshop',
        'canteen',
        'oval',
        'fête',
        'arvo',
        'barbie',
      ];

  /// Common Australian English spelling patterns
  static Map<String, String> get australianSpelling => {
        'color': 'colour',
        'favor': 'favour',
        'honor': 'honour',
        'neighbor': 'neighbour',
        'flavor': 'flavour',
        'harbor': 'harbour',
        'center': 'centre',
        'meter': 'metre',
        'theater': 'theatre',
        'fiber': 'fibre',
        'liter': 'litre',
        'organize': 'organise',
        'realize': 'realise',
        'recognize': 'recognise',
        'analyze': 'analyse',
        'paralyze': 'paralyse',
        'defense': 'defence',
        'offense': 'offence',
        'license': 'licence', // (noun)
        'practice': 'practise', // (verb)
      };
}
