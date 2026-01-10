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
      // Original scenarios
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
      // New scenarios (expansion)
      {
        'context':
            'A koala ate {a} eucalyptus leaves yesterday. It ate {b} more today. How many leaves in total?',
        'theme': 'animals'
      },
      {
        'context':
            'At the Olympics, Australia won {a} gold medals in the first week and {b} in the second. Total gold?',
        'theme': 'sport'
      },
      {
        'context':
            'The library has {a} books about Australian animals. They get {b} new books. How many books now?',
        'theme': 'school'
      },
      {
        'context':
            'A wombat dug {a} metres of tunnel. Then it dug {b} more metres. Total tunnel length?',
        'theme': 'animals'
      },
      {
        'context':
            'The kookaburra had {a} friends in one tree. {b} more kookaburras joined them. How many now?',
        'theme': 'animals'
      },
      {
        'context':
            'Sam picked {a} mangoes from the tree. Her brother picked {b} mangoes. How many in total?',
        'theme': 'fruit'
      },
      {
        'context':
            'There are {a} children on the bus. {b} more children get on. How many children now?',
        'theme': 'transport'
      },
      {
        'context':
            'A platypus laid {a} eggs in its burrow. A friend laid {b} more eggs nearby. How many eggs altogether?',
        'theme': 'animals'
      },
      {
        'context':
            'The school fête had {a} stalls on Monday and {b} stalls on Tuesday. How many stalls total?',
        'theme': 'school'
      },
      {
        'context':
            'A swimmer did {a} laps of the pool. Then did {b} more laps. Total laps completed?',
        'theme': 'sport'
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
      // Original scenarios
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
      // New scenarios (expansion)
      {
        'context':
            'There were {a} kangaroos in the paddock. {b} hopped away. How many kangaroos left?',
        'theme': 'animals'
      },
      {
        'context':
            'The zoo had {a} birds. {b} birds flew away. How many birds still at the zoo?',
        'theme': 'animals'
      },
      {
        'context':
            'You had {a} stickers. You gave {b} to your friend. How many stickers do you have now?',
        'theme': 'collection'
      },
      {
        'context':
            'The school had {a} books. They donated {b} books to the library. How many left?',
        'theme': 'school'
      },
      {
        'context':
            'There were {a} people at the beach. {b} people left. How many people stayed?',
        'theme': 'beach'
      },
      {
        'context':
            'A tree had {a} leaves. The wind blew off {b} leaves. How many leaves remain?',
        'theme': 'nature'
      },
      {
        'context':
            'You scored {a} points in the game. Your friend scored {b} less. How many points for your friend?',
        'theme': 'games'
      },
      {
        'context':
            'There were {a} cupcakes. We ate {b} of them. How many cupcakes are left?',
        'theme': 'food'
      },
      {
        'context':
            'A car had {a} passengers. {b} passengers got off. How many passengers left on the car?',
        'theme': 'transport'
      },
      {
        'context':
            'The basket had {a} apples. We used {b} apples to make juice. How many apples left?',
        'theme': 'fruit'
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
      // Original scenarios
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
      // New scenarios (expansion)
      {
        'context':
            'A kangaroo can hop {a} metres in one jump. If it makes {b} jumps, how far does it go?',
        'theme': 'animals'
      },
      {
        'context':
            'Each netball team has {a} players. There are {b} teams in the competition. Total players?',
        'theme': 'sport'
      },
      {
        'context':
            'A lamington has {a} coconut strands. If you make {b} lamingtons, how many strands needed?',
        'theme': 'cooking'
      },
      {
        'context':
            'The library bought {a} books for each classroom. There are {b} classrooms. Total books?',
        'theme': 'school'
      },
      {
        'context':
            'A platypus has {a} eggs. If {b} platypuses each have eggs, how many eggs in total?',
        'theme': 'animals'
      },
      {
        'context':
            'Each row of seats has {a} chairs. The hall has {b} rows. How many chairs in total?',
        'theme': 'school'
      },
      {
        'context':
            'A pack of Tim Tams has {a} biscuits. How many biscuits in {b} packs?',
        'theme': 'food'
      },
      {
        'context':
            'Each swimmer completed {a} laps. There were {b} swimmers. Total laps completed?',
        'theme': 'sport'
      },
      {
        'context':
            'An emu can run {a} km/hour. In {b} hours, how far can it run?',
        'theme': 'animals'
      },
      {
        'context':
            'Each tent holds {a} campers. At camp, there are {b} tents. How many campers total?',
        'theme': 'camping'
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
      // Original scenarios
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
      // New scenarios (expansion)
      {
        'context':
            '{a} lamingtons are shared equally among {b} people. How many each?',
        'theme': 'food'
      },
      {
        'context':
            '{a} points divided equally among {b} team members. Points per member?',
        'theme': 'sport'
      },
      {
        'context':
            '{a} books need to be put on {b} shelves equally. Books per shelf?',
        'theme': 'school'
      },
      {
        'context':
            '{a} children are divided into {b} equal groups. Children per group?',
        'theme': 'school'
      },
      {
        'context':
            '{a} biscuits shared equally among {b} friends. How many each?',
        'theme': 'food'
      },
      {
        'context':
            '{a} metres of rope cut into {b} equal pieces. Length of each piece?',
        'theme': 'measurement'
      },
      {
        'context':
            '{a} crayons shared equally among {b} students. Crayons per student?',
        'theme': 'art'
      },
      {
        'context':
            '{a} pizza slices divided equally among {b} friends. Slices per friend?',
        'theme': 'food'
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
      // Original scenarios
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
      // New scenarios (expansion)
      {
        'context': 'A cake is cut into 6 equal pieces. You take 2 pieces. What fraction is that?',
        'answer': '1/3',
        'theme': 'food'
      },
      {
        'context':
            'Your class has 20 students. 5 have blue eyes. What fraction have blue eyes?',
        'answer': '1/4',
        'theme': 'school'
      },
      {
        'context': 'A ribbon is 10 metres long. You cut off 5 metres. What fraction did you cut?',
        'answer': '1/2',
        'theme': 'craft'
      },
      {
        'context':
            'There are 12 biscuits in a packet. You eat 3. What fraction did you eat?',
        'answer': '1/4',
        'theme': 'food'
      },
      {
        'context': 'A hour has 60 minutes. 15 minutes is what fraction of an hour?',
        'answer': '1/4',
        'theme': 'time'
      },
      {
        'context':
            'A metre has 100 centimetres. 25 centimetres is what fraction?',
        'answer': '1/4',
        'theme': 'measurement'
      },
      {
        'context':
            'There are 8 flowers. 4 are red and 4 are blue. Red flowers are what fraction?',
        'answer': '1/2',
        'theme': 'nature'
      },
      {
        'context':
            'A book has 100 pages. You read 50 pages. What fraction have you read?',
        'answer': '1/2',
        'theme': 'reading'
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
      // Original scenarios
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
      // New scenarios (expansion)
      {
        'context':
            'A kangaroo is 2 metres tall. A koala is 60 centimetres tall. Difference in centimetres?',
        'answer': 140,
        'unit': 'cm'
      },
      {
        'context':
            'A beach is 3 kilometres long. How many metres is that?',
        'answer': 3000,
        'unit': 'm'
      },
      {
        'context':
            'Your backpack weighs 2.5 kilograms. How many grams?',
        'answer': 2500,
        'unit': 'g'
      },
      {
        'context':
            'A milk carton holds 1 litre. How many millilitres?',
        'answer': 1000,
        'unit': 'mL'
      },
      {
        'context':
            'The school oval is 150 metres long and 120 metres wide. What\'s the perimeter?',
        'answer': 540,
        'unit': 'm'
      },
      {
        'context':
            'A lamington weighs 25 grams. How much do 10 lamingtons weigh in grams?',
        'answer': 250,
        'unit': 'g'
      },
      {
        'context':
            'A recipe needs 250 millilitres of milk. How much in litres?',
        'answer': 0.25,
        'unit': 'L'
      },
      {
        'context':
            'The Great Barrier Reef is 2,300 kilometres long. How many metres?',
        'answer': 2300000,
        'unit': 'm'
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
      1: [
        'mum',
        'dad',
        'cat',
        'dog',
        'sun',
        'hat',
        'run',
        'fun',
        'bed',
        'red',
        'big',
        'pig',
        'bat',
        'rat',
        'mat',
        'sit',
        'sit',
        'pot',
        'hot',
        'lot'
      ],
      2: [
        'colour',
        'favourite',
        'centre',
        'metre',
        'theatre',
        'neighbour',
        'harbour',
        'favour',
        'honour',
        'travelling',
        'cancelled',
        'labelled',
        'modelled',
        'jewellery',
        'realise',
        'organise',
        'recognise',
        'practise',
        'defence',
        'licence'
      ],
      3: [
        'beautiful',
        'necessary',
        'recognise',
        'organise',
        'practise',
        'licence',
        'defence',
        'analyse',
        'emphasise',
        'summarise',
        'apologise',
        'catastrophe',
        'parallel',
        'environment',
        'government'
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
      // Original passages
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
      // New passages (expansion)
      {
        'text':
            'The koala climbed high up in the eucalyptus tree to eat leaves. It moved very slowly.',
        'question': 'Where was the koala?',
        'answer': 'in the eucalyptus tree',
      },
      {
        'text':
            'Ali played cricket with his friends on Saturday. They had lots of fun in the park.',
        'question': 'What did Ali do on Saturday?',
        'answer': 'played cricket',
      },
      {
        'text':
            'The kookaburra laughed loudly in the morning. The sound was very funny.',
        'question': 'When did the kookaburra laugh?',
        'answer': 'in the morning',
      },
      {
        'text':
            'Emma found a beautiful shell on Bondi Beach. It was pink and white.',
        'question': 'Where did Emma find the shell?',
        'answer': 'on Bondi Beach',
      },
      {
        'text':
            'At the zoo, we saw many animals. The elephant was the biggest one.',
        'question': 'Which animal was the biggest?',
        'answer': 'the elephant',
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
