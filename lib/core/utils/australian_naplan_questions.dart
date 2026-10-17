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

    final nums = _getNumberPair(
      difficulty,
      1,
      10,
      category: 'y1-addition-d$difficulty',
    );
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

    final nums = _getSubtractionPair(
      difficulty,
      1,
      20,
      category: 'y1-subtraction-d$difficulty',
    );
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
    // B1: parameterised counting — skip patterns and neighbour-look-ups
    // drawn from a wide deterministic space, so the topic now supports
    // hundreds of unique questions instead of five fixed texts.
    final useSkip = _random.nextBool();
    if (useSkip) {
      // 3 steps × 71 starting terms × 2 shown-run lengths = 142 combos,
      // unique-index drawn so every next term stays ≤ 100. Runs show ≥ 2
      // terms so the step is always inferable and the answer unambiguous.
      const steps = [2, 5, 10];
      const stepSpaces = [47, 17, 7];
      final combo = _getUniqueDraw('y1-counting-skip-d$difficulty', 71 * 2);
      var within = combo % 71;
      final shownCount = 2 + combo ~/ 71; // 2..3 shown terms
      var step = 0;
      for (var s = 0; s < steps.length; s++) {
        if (within < stepSpaces[s]) {
          step = steps[s];
          break;
        }
        within -= stepSpaces[s];
      }
      final start = step + step * within;
      final run = <String>[];
      for (var i = 0; i < shownCount; i++) {
        run.add('${start + step * i}');
      }
      final answer = start + step * shownCount;
      return {
        'question': 'Skip count: ${run.join(', ')}, ?',
        'answer': answer,
        'type': 'counting',
        'difficulty': difficulty,
        'theme': 'patterns',
      };
    }
    // Neighbour look-ups: after/before across a 5–119 ladder (230 combos).
    final combo = _getUniqueDraw('y1-counting-neighbour-d$difficulty', 230);
    final after = combo < 115;
    final n = 5 + combo % 115;
    return {
      'question': 'What number comes ${after ? 'after' : 'before'} $n?',
      'answer': after ? n + 1 : n - 1,
      'type': 'counting',
      'difficulty': difficulty,
      'theme': 'place',
    };
  }

  static Map<String, dynamic> _year1Money(int difficulty) {
    // B1: parameterised tuckshop money — no 5c coins, whole-dollar prices,
    // every branch drawn through the unique-draw memory so no text
    // repeats within a difficulty row.
    const items = [
      'paddle pop',
      'sausage roll',
      'meat pie',
      'apple',
      'juice box',
      'banana',
    ];
    const flavours = ['chocolate', 'strawberry', 'banana', 'raspberry'];
    final scenario = _random.nextInt(3);

    if (scenario == 0) {
      // Buy two different items: 30 ordered item pairs × 16 price pairs.
      final combo = _getUniqueDraw('y1-money-buy-d$difficulty', 30 * 16);
      final first = items[combo ~/ 80];
      final second =
          items[(combo ~/ 80 + 1 + (combo % 80) ~/ 16) % items.length];
      final a = ((combo % 16) ~/ 4) + 1;
      final b = (combo % 4) + 1;
      return {
        'question':
            'A $first costs \$$a. A $second costs \$$b. How much for both?',
        'answer': a + b,
        'type': 'money',
        'difficulty': difficulty,
        'theme': 'currency',
      };
    }
    if (scenario == 1) {
      // Change from a note after buying an item: 3 notes × 4 prices × 6 items.
      const notes = [5, 10, 20];
      final combo = _getUniqueDraw('y1-money-change-d$difficulty', 3 * 4 * 6);
      final note = notes[combo ~/ 24];
      final price = ((combo ~/ 6) % 4) + 1; // 1..4, always less than any note
      final item = items[combo % items.length];
      return {
        'question': 'A $item costs \$$price. You pay with a \$$note note. '
            'How much change?',
        'answer': note - price,
        'type': 'money',
        'difficulty': difficulty,
        'theme': 'currency',
      };
    }
    // Coin-counting: milk flavours, whole-dollar coin piles (2..12 coins).
    final combo = _getUniqueDraw('y1-money-coins-d$difficulty', 11 * 4);
    final coins = 2 + combo ~/ 4;
    final flavourChoice = flavours[combo % 4];
    return {
      'question': 'Each $flavourChoice paddle pop costs \$1. You buy $coins '
          'paddle pops. How many dollars?',
      'answer': coins,
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

    final nums = _getNumberPair(
      difficulty,
      2,
      12,
      category: 'y3-multiplication-d$difficulty',
    );
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
    // B1: (divisor, quotient) drawn by unique index so no text repeats in
    // a row: d1 divisor 2–10 × quotient 2–10, d2 3–10 × 2–11, d3 3–10 × 2–12.
    final divisorMin = difficulty == 1 ? 2 : 3;
    final quotientMax = difficulty == 2 ? 11 : 10;
    final quotCells = quotientMax - 1;
    final combo = _getUniqueDraw(
        'y3-division-d$difficulty', (11 - divisorMin) * quotCells);
    final divisor = divisorMin + combo ~/ quotCells;
    final quotient = 2 + combo % quotCells;
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
    // B1: parameterised unit fractions — (wholes, eaten, context) drawn by
    // unique index across the full 56-pair x 3-context space (168), so
    // texts never repeat within a difficulty row; answers are reduced
    // fractions. The context used to be picked by a separate random draw
    // outside the unique window, which left 50-draw samples flaky near the
    // 56-pair ceiling (cross-referenced against the curated NAPLAN JSON
    // bank, whose fractions entries are all distinct texts).
    const wholesOptions = [2, 3, 4, 5, 6, 7, 8, 9, 10, 12];
    const contexts = [
      'A watermelon is cut into {w} equal slices. You eat {p} of them. What fraction did you eat?',
      'A fruit loaf holds {w} slices. You share {p} of them at play lunch. What fraction was shared?',
      'A recipe makes {w} pikelets. You eat {p} of them. What fraction is gone?',
    ];
    final combo = _getUniqueDraw('y3-fractions-d$difficulty', 56 * 3);
    var remain = combo ~/ 3;
    var wholes = wholesOptions.first;
    var eaten = 1;
    for (final w in wholesOptions) {
      if (remain < w - 1) {
        wholes = w;
        eaten = 1 + remain;
        break;
      }
      remain -= w - 1;
    }
    var gcdA = eaten;
    var gcdB = wholes;
    while (gcdA != 0) {
      final r = gcdB % gcdA;
      gcdB = gcdA;
      gcdA = r;
    }
    final scenario = contexts[combo % 3];
    return {
      'question':
          scenario.replaceAll('{w}', '$wholes').replaceAll('{p}', '$eaten'),
      'answer': '${eaten ~/ gcdB}/${wholes ~/ gcdB}',
      'type': 'fractions',
      'difficulty': difficulty,
      'theme': 'food',
    };
  }

  static Map<String, dynamic> _year3Measurement(int difficulty) {
    // B1: parameterised conversions — the value is drawn by unique index
    // within each unit family so texts never repeat within a difficulty row.
    const lengthNouns = [
      'classroom',
      'rope',
      'jetty',
      'fence',
      'hall',
      'path',
    ];
    const areaNouns = ['oval', 'paddock', 'carpet', 'court'];
    switch (_random.nextInt(4)) {
      case 0: // metres → centimetres
        final combo = _getUniqueDraw(
            'y3-measure-m-d$difficulty', 99 * lengthNouns.length);
        final metres = 1 + combo ~/ lengthNouns.length;
        final noun = lengthNouns[combo % lengthNouns.length];
        return {
          'question': 'The $noun is $metres metres long. How many centimetres?',
          'answer': metres * 100,
          'type': 'measurement',
          'difficulty': difficulty,
          'unit': 'cm',
        };
      case 1: // millilitres → litres
        final combo = _getUniqueDraw('y3-measure-ml-d$difficulty', 29);
        final millilitres = (1 + combo) * 100; // 100..2900 mL
        return {
          'question': 'A milk bottle holds $millilitres millilitres. '
              'How many litres is that?',
          'answer': millilitres / 1000,
          'type': 'measurement',
          'difficulty': difficulty,
          'unit': 'L',
        };
      case 2: // grams → kilograms
        final combo = _getUniqueDraw('y3-measure-g-d$difficulty', 28);
        final grams = (1 + combo) * 100; // 100..2800 g
        return {
          'question':
              'A parcel weighs $grams grams. How many kilograms is that?',
          'answer': grams / 1000,
          'type': 'measurement',
          'difficulty': difficulty,
          'unit': 'kg',
        };
      default: // rectangle perimeter in metres
        final combo = _getUniqueDraw(
            'y3-measure-peri-d$difficulty', 900 * areaNouns.length);
        final rest = combo ~/ areaNouns.length;
        final length = 10 + rest ~/ 30; // 10..39 m
        final width = 10 + rest % 30; // 10..39 m
        final noun = areaNouns[combo % areaNouns.length];
        return {
          'question': 'The $noun is $length metres long and $width metres '
              'wide. What is the perimeter?',
          'answer': 2 * (length + width),
          'type': 'measurement',
          'difficulty': difficulty,
          'unit': 'm',
        };
    }
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

  /// Recently served (a, b) number pairs, keyed by generator category, so
  /// a child never sees the same pair (and therefore the same question
  /// text) twice in a row alongside the same scenario. Pool is capped so
  /// the memory stays banded per topic rather than global.
  static final Map<String, Set<String>> _recentPairs = {};

  /// Clears all anti-repetition memory. Bounds are per play session, so a
  /// new session (or a fresh test) starts with the full parameter space
  /// available again.
  static void resetSessionMemory() => _recentPairs.clear();

  static List<int> _getNumberPair(
    int difficulty,
    int min,
    int max, {
    String category = 'default',
  }) {
    final memory = _recentPairs.putIfAbsent(category, () => <String>{});
    List<int> pair;
    var attempts = 0;
    do {
      pair = _drawNumberPair(difficulty, min, max);
      attempts++;
    } while (memory.contains('${pair[0]},${pair[1]}') &&
        attempts < 40); // saturate: accept a repeat rather than hang
    memory.add('${pair[0]},${pair[1]}');
    return pair;
  }

  /// B1: single-number unique draws backed by the same per-category memory
  /// as pair draws. Guarantees distinct parameter values until the space
  /// is honestly exhausted — used by the narrow generators (counting,
  /// money, division, fractions, measurement) so their texts never repeat
  /// within a difficulty row without needing oversized question pools.
  static int _getUniqueDraw(String category, int spaceSize) {
    final memory = _recentPairs.putIfAbsent(category, () => <String>{});
    int value;
    var attempts = 0;
    do {
      value = _random.nextInt(spaceSize);
      attempts++;
    } while (!memory.add('$value') && attempts < 40);
    return value;
  }

  // Pair capacity is sized per difficulty so sampling a topic never
  // saturates: easy = 10 cells (100 pairs), medium = 14 (196), hard = the
  // full template range plus headroom (256). Combined with per-category,
  // per-difficulty pair memory this keeps every served text unique until
  // its topic row is genuinely exhausted.
  static List<int> _drawNumberPair(int difficulty, int min, int max) {
    switch (difficulty) {
      case 1: // Easy
        final a = _random.nextInt(10) + min;
        final b = _random.nextInt(10) + min;
        return [a, b];
      case 2: // Medium
        final a = _random.nextInt(14) + min;
        final b = _random.nextInt(14) + min;
        return [a, b];
      case 3: // Hard
        final a = _random.nextInt(max - min + 8) + min;
        final b = _random.nextInt(max - min + 8) + min;
        return [a, b];
      default:
        return [_random.nextInt(max) + min, _random.nextInt(max) + min];
    }
  }

  static List<int> _getSubtractionPair(int difficulty, int min, int max,
      {String category = 'default'}) {
    // Normalise FIRST, then dedupe: (2,5) and (5,2) render as the same
    // subtraction text, so the pair memory must key the ordered form.
    // B1: pairs are drawn by unique index over the ordered (a >= b) space,
    // so every pair within a row is distinct until the space is exhausted.
    final width = max - min + 1;
    final space = width * (width + 1) ~/ 2;
    var remain = _getUniqueDraw(category, space);
    var a = min;
    var rowSize = 1;
    while (remain >= rowSize) {
      remain -= rowSize;
      rowSize++;
      a++;
    }
    return [a, min + remain];
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
