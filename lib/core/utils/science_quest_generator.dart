import 'dart:math';
import 'package:brightbound_adventures/features/science/models/question.dart';
import 'package:brightbound_adventures/core/utils/enhanced_question_generator.dart';

class ScienceQuestGenerator {
  static final Random _random = Random();

  static List<ScienceQuestion> generate({
    required String theme,
    required int difficulty,
    int count = 10,
  }) {
    final questions = <ScienceQuestion>[];

    for (int i = 0; i < count; i++) {
      questions.add(_generateSingleQuestion(theme, difficulty, i));
    }

    return questions;
  }

  static ScienceQuestion _generateSingleQuestion(
      String theme, int difficulty, int index) {
    final t = theme.toLowerCase();
    if (t.contains('animal') || t.contains('living')) {
      return _generateLivingThingsQuestion(difficulty, index);
    } else if (t.contains('lifecycle') || t.contains('life cycle')) {
      return _generateLifecycleQuestion(difficulty, index);
    } else if (t.contains('plant')) {
      return _generatePlantQuestion(difficulty, index);
    } else if (t.contains('material')) {
      return _generateMaterialsQuestion(difficulty, index);
    } else if (t.contains('force') || t.contains('motion') || t.contains('push') || t.contains('pull')) {
      return _generateForcesQuestion(difficulty, index);
    } else if (t.contains('season') || t.contains('weather') || t.contains('water cycle')) {
      return _generateSeasonsQuestion(difficulty, index);
    } else {
      // Mixed bag using all categories
      final r = _random.nextInt(7);
      if (r == 0) return _generateLivingThingsQuestion(difficulty, index);
      if (r == 1) return _generateMaterialsQuestion(difficulty, index);
      if (r == 2) return _generateLifecycleQuestion(difficulty, index);
      if (r == 3) return _generatePlantQuestion(difficulty, index);
      if (r == 4) return _generateForcesQuestion(difficulty, index);
      if (r == 5) return _generateWeatherQuestion(difficulty, index);
      return _generateSeasonsQuestion(difficulty, index);
    }
  }

  static ScienceQuestion _generateLivingThingsQuestion(
      int difficulty, int index) {
    // Classification
    final groups = {
      'Mammal': ['Dog', 'Cat', 'Human', 'Whale', 'Lion'],
      'Bird': ['Eagle', 'Penguin', 'Parrot', 'Duck', 'Owl'],
      'Reptile': ['Snake', 'Lizard', 'Turtle', 'Crocodile'],
      'Insect': ['Bee', 'Ant', 'Butterfly', 'Beetle']
    };

    final targetGroup = groups.keys.elementAt(_random.nextInt(groups.length));
    final correct =
        groups[targetGroup]![_random.nextInt(groups[targetGroup]!.length)];

    // Distractors from other groups
    final otherGroups = groups.keys.where((k) => k != targetGroup).toList();
    final distractors = <String>[];
    for (var i = 0; i < 3; i++) {
      final g = otherGroups[_random.nextInt(otherGroups.length)];
      distractors.add(groups[g]![_random.nextInt(groups[g]!.length)]);
    }

    final options = EnhancedQuestionGenerator.smartShuffle(
        [correct, ...distractors], correct);

    return ScienceQuestion(
        id: 'sci_living_$index',
        skillId: 'skill_biological_sciences',
        question: 'Which of these is a $targetGroup?',
        options: options,
        correctIndex: options.indexOf(correct),
        difficulty: difficulty,
        topic: 'Living Things',
        explanation: '$correct is a $targetGroup.');
  }

  static ScienceQuestion _generateMaterialsQuestion(int difficulty, int index) {
    final materials = {
      'Glass': {
        'prop': 'transparent',
        'items': ['Window', 'Jar', 'Screen']
      },
      'Wood': {
        'prop': 'from trees',
        'items': ['Table', 'Pencil', 'Log']
      },
      'Metal': {
        'prop': 'shiny and hard',
        'items': ['Coin', 'Key', 'Spoon']
      },
      'Wool': {
        'prop': 'soft and warm',
        'items': ['Jumper', 'Scarf', 'Blanket']
      }
    };

    final m = materials.keys.elementAt(_random.nextInt(materials.length));
    final data = materials[m]!;
    final items = data['items'] as List<String>;
    final correct = items[_random.nextInt(items.length)];

    // Question: "Which object is made of [Material]?"
    final otherMaterials = materials.keys.where((k) => k != m).toList();
    final distractors = <String>[];
    for (var i = 0; i < 3; i++) {
      final om = otherMaterials[_random.nextInt(otherMaterials.length)];
      final oItems = materials[om]!['items'] as List<String>;
      distractors.add(oItems[_random.nextInt(oItems.length)]);
    }

    final options = EnhancedQuestionGenerator.smartShuffle(
        [correct, ...distractors], correct);

    return ScienceQuestion(
        id: 'sci_mat_$index',
        skillId: 'skill_physical_sciences',
        question: 'Which object is made of $m?',
        options: options,
        correctIndex: options.indexOf(correct),
        difficulty: difficulty,
        topic: 'Materials',
        explanation: '$correct is usually made of $m.');
  }

  static ScienceQuestion _generateSeasonsQuestion(int difficulty, int index) {
    final seasons = [
      {'name': 'Summer', 'desc': 'hottest', 'clothes': 'T-shirt and shorts'},
      {'name': 'Winter', 'desc': 'coldest', 'clothes': 'Coat and scarf'},
      {'name': 'Autumn', 'desc': 'leaves falling', 'clothes': 'Jumper'},
      {'name': 'Spring', 'desc': 'flowers blooming', 'clothes': 'Light jacket'}
    ];

    final s = seasons[_random.nextInt(seasons.length)];
    final isDesc = _random.nextBool();

    String qText;
    String correct = s['name']!;
    List<String> options = [
      'Summer',
      'Winter',
      'Autumn',
      'Spring'
    ]; // Always fixed options usually

    options = EnhancedQuestionGenerator.smartShuffle(options, correct);

    if (isDesc) {
      qText = "Which season is the ${s['desc']}?";
    } else {
      qText = "In which season would you wear: ${s['clothes']}?";
    }

    return ScienceQuestion(
        id: 'sci_season_$index',
        skillId: 'skill_earth_sciences',
        question: qText,
        options: options,
        correctIndex: options.indexOf(correct),
        difficulty: difficulty,
        topic: 'Earth and Space',
        explanation: '${s['name']} is the season of ${s['desc']}.');
  }

  // ── Animal Lifecycles ──────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> _lifecycles = [
    {
      'animal': 'Butterfly',
      'stages': ['Egg', 'Caterpillar', 'Pupa (Chrysalis)', 'Butterfly'],
      'topic': 'Insects',
      'skill': 'skill_biological_sciences',
    },
    {
      'animal': 'Frog',
      'stages': ['Egg (Frogspawn)', 'Tadpole', 'Froglet', 'Adult Frog'],
      'topic': 'Amphibians',
      'skill': 'skill_biological_sciences',
    },
    {
      'animal': 'Chicken',
      'stages': ['Egg', 'Chick', 'Juvenile Chicken', 'Adult Chicken'],
      'topic': 'Birds',
      'skill': 'skill_biological_sciences',
    },
    {
      'animal': 'Mosquito',
      'stages': ['Egg', 'Larva', 'Pupa', 'Adult Mosquito'],
      'topic': 'Insects',
      'skill': 'skill_biological_sciences',
    },
  ];

  static ScienceQuestion _generateLifecycleQuestion(int difficulty, int index) {
    final lc = _lifecycles[index % _lifecycles.length];
    final stages = lc['stages'] as List<String>;
    final animal = lc['animal'] as String;

    final qType = _random.nextInt(3);

    if (qType == 0) {
      // First stage
      final correct = stages.first;
      final others = stages.skip(1).toList()..shuffle(_random);
      final distractors = others.take(3).toList();
      final options = EnhancedQuestionGenerator.smartShuffle(
          [correct, ...distractors], correct);
      return ScienceQuestion(
        id: 'sci_lc_${animal}_$index',
        skillId: lc['skill'] as String,
        question: 'What is the FIRST stage in the lifecycle of a $animal?',
        options: options,
        correctIndex: options.indexOf(correct),
        difficulty: difficulty,
        topic: lc['topic'] as String,
        explanation: 'A $animal starts life as ${stages.first}.',
      );
    } else if (qType == 1 && stages.length > 2) {
      // Next stage after a given stage
      final stageIdx = _random.nextInt(stages.length - 1);
      final current = stages[stageIdx];
      final correct = stages[stageIdx + 1];
      final wrongPool = stages.where((s) => s != correct && s != current).toList();
      wrongPool.shuffle(_random);
      final distractors = wrongPool.take(3).toList();
      final options = EnhancedQuestionGenerator.smartShuffle(
          [correct, ...distractors], correct);
      return ScienceQuestion(
        id: 'sci_lc_next_${animal}_$index',
        skillId: lc['skill'] as String,
        question:
            'In the lifecycle of a $animal, what comes AFTER the $current stage?',
        options: options,
        correctIndex: options.indexOf(correct),
        difficulty: difficulty,
        topic: lc['topic'] as String,
        explanation:
            'After $current, a $animal becomes ${stages[stageIdx + 1]}.',
      );
    } else {
      // Count of stages
      final correct = '${stages.length}';
      final allCounts = ['3', '4', '5', '6']
          .where((c) => c != correct)
          .take(3)
          .toList();
      final options = EnhancedQuestionGenerator.smartShuffle(
          [correct, ...allCounts], correct);
      return ScienceQuestion(
        id: 'sci_lc_count_${animal}_$index',
        skillId: lc['skill'] as String,
        question: 'How many stages are in the lifecycle of a $animal?',
        options: options,
        correctIndex: options.indexOf(correct),
        difficulty: difficulty,
        topic: lc['topic'] as String,
        explanation:
            'A $animal has ${stages.length} stages: ${stages.join(' → ')}.',
      );
    }
  }

  // ── Plant Biology ──────────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> _plantFacts = [
    {
      'q': 'Which part of a plant absorbs water and nutrients from the soil?',
      'correct': 'Roots',
      'wrong': ['Leaves', 'Stem', 'Flower'],
      'exp': 'Roots grow underground and absorb water and minerals from the soil.',
    },
    {
      'q': 'What is the process called when plants use sunlight to make food?',
      'correct': 'Photosynthesis',
      'wrong': ['Respiration', 'Pollination', 'Germination'],
      'exp': 'Photosynthesis is how plants use sunlight, water, and carbon dioxide to make food.',
    },
    {
      'q': 'Which gas do plants take in during photosynthesis?',
      'correct': 'Carbon dioxide',
      'wrong': ['Oxygen', 'Nitrogen', 'Hydrogen'],
      'exp': 'Plants take in carbon dioxide (CO₂) and release oxygen during photosynthesis.',
    },
    {
      'q': 'What do leaves produce that animals need to breathe?',
      'correct': 'Oxygen',
      'wrong': ['Carbon dioxide', 'Water', 'Glucose'],
      'exp': 'Leaves produce oxygen as a by-product of photosynthesis.',
    },
    {
      'q': 'Which part of the plant carries water from the roots to the leaves?',
      'correct': 'Stem',
      'wrong': ['Roots', 'Petals', 'Seeds'],
      'exp': 'The stem acts like a pipeline, transporting water and nutrients up to the leaves.',
    },
    {
      'q': 'What do seeds need to start growing (germinating)?',
      'correct': 'Water',
      'wrong': ['Sunlight', 'Soil', 'Wind'],
      'exp': 'Seeds need water to germinate. They also need warmth, but NOT sunlight at first.',
    },
    {
      'q': 'Which part of a flower develops into a fruit?',
      'correct': 'Ovary',
      'wrong': ['Petal', 'Stamen', 'Sepal'],
      'exp': 'After pollination, the ovary of a flower develops into a fruit containing seeds.',
    },
    {
      'q': 'What is the green pigment in leaves that captures sunlight?',
      'correct': 'Chlorophyll',
      'wrong': ['Melanin', 'Keratin', 'Carotene'],
      'exp': 'Chlorophyll is the green pigment in leaves that absorbs sunlight for photosynthesis.',
    },
    {
      'q': 'Which type of plant does NOT have roots, stems, or leaves?',
      'correct': 'Moss',
      'wrong': ['Fern', 'Oak tree', 'Rose'],
      'exp': 'Mosses are non-vascular plants — they lack true roots, stems and leaves.',
    },
    {
      'q': 'How do bees help plants reproduce?',
      'correct': 'They carry pollen between flowers',
      'wrong': [
        'They water the plants',
        'They plant seeds',
        'They eat the leaves'
      ],
      'exp': 'Bees pick up pollen on their bodies and transfer it to other flowers (pollination).',
    },
  ];

  static ScienceQuestion _generatePlantQuestion(int difficulty, int index) {
    final fact = _plantFacts[index % _plantFacts.length];
    final correct = fact['correct'] as String;
    final wrong = List<String>.from(fact['wrong'] as List);
    wrong.shuffle(_random);
    final options = EnhancedQuestionGenerator.smartShuffle(
        [correct, ...wrong.take(3)], correct);
    return ScienceQuestion(
      id: 'sci_plant_$index',
      skillId: 'skill_biological_sciences',
      question: fact['q'] as String,
      options: options,
      correctIndex: options.indexOf(correct),
      difficulty: difficulty,
      topic: 'Plant Biology',
      explanation: fact['exp'] as String,
    );
  }

  // ── Forces & Motion ────────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> _forcesFacts = [
    {
      'q': 'What force pulls objects towards the centre of the Earth?',
      'correct': 'Gravity',
      'wrong': ['Friction', 'Magnetism', 'Air resistance'],
      'exp': 'Gravity is the force that pulls everything towards Earth.',
    },
    {
      'q': 'What is the name for a force that slows down objects as they slide?',
      'correct': 'Friction',
      'wrong': ['Gravity', 'Tension', 'Thrust'],
      'exp': 'Friction acts against motion when two surfaces rub together.',
    },
    {
      'q': 'Which of these is an example of a PUSH force?',
      'correct': 'Kicking a ball',
      'wrong': ['Picking up a bag', 'Opening a drawer', 'Pulling a rope'],
      'exp': 'Kicking a ball pushes it away from your foot.',
    },
    {
      'q': 'Which of these is an example of a PULL force?',
      'correct': 'Pulling a rope in tug-of-war',
      'wrong': ['Throwing a ball', 'Pressing a button', 'Pushing a door'],
      'exp': 'In tug-of-war you pull the rope towards yourself.',
    },
    {
      'q': 'What happens to a moving object if no forces act on it?',
      'correct': 'It keeps moving at the same speed',
      'wrong': ['It speeds up', 'It slows down and stops', 'It changes direction'],
      'exp':
          'Without forces acting on it, an object continues at the same speed (Newton\'s 1st Law).',
    },
    {
      'q': 'What slows a skydiver\'s fall before the parachute opens?',
      'correct': 'Air resistance',
      'wrong': ['Gravity', 'Magnetism', 'Friction'],
      'exp': 'Air resistance (drag) pushes upwards against the falling skydiver.',
    },
    {
      'q': 'Which surface would have the MOST friction?',
      'correct': 'Rough sandpaper',
      'wrong': ['Wet ice', 'Polished marble', 'Glass'],
      'exp': 'Rough surfaces produce more friction than smooth surfaces.',
    },
    {
      'q': 'A magnet attracting a metal paperclip is an example of which force?',
      'correct': 'Magnetic force',
      'wrong': ['Gravity', 'Friction', 'Air resistance'],
      'exp': 'Magnetic force acts between magnets and magnetic materials.',
    },
    {
      'q': 'What do we call a force that acts without touching an object?',
      'correct': 'Non-contact force',
      'wrong': ['Contact force', 'Push force', 'Friction force'],
      'exp': 'Gravity and magnetism are non-contact forces — they act at a distance.',
    },
    {
      'q': 'If you double the force pushing an object, what happens to its acceleration?',
      'correct': 'It doubles',
      'wrong': ['It halves', 'It stays the same', 'It triples'],
      'exp': 'Greater force → greater acceleration (F = ma, Newton\'s 2nd Law).',
    },
  ];

  static ScienceQuestion _generateForcesQuestion(int difficulty, int index) {
    // Filter facts by difficulty: easy=0-3, medium=3-6, hard=6-10
    final allFacts = difficulty <= 1
        ? _forcesFacts.take(4).toList()
        : difficulty == 2
            ? _forcesFacts.skip(2).take(5).toList()
            : _forcesFacts.skip(5).toList();
    final fact = allFacts[index % allFacts.length];
    final correct = fact['correct'] as String;
    final wrong = List<String>.from(fact['wrong'] as List);
    wrong.shuffle(_random);
    final options = EnhancedQuestionGenerator.smartShuffle(
        [correct, ...wrong.take(3)], correct);
    return ScienceQuestion(
      id: 'sci_forces_$index',
      skillId: 'skill_physical_sciences',
      question: fact['q'] as String,
      options: options,
      correctIndex: options.indexOf(correct),
      difficulty: difficulty,
      topic: 'Forces and Motion',
      explanation: fact['exp'] as String,
    );
  }

  // ── Weather & Water Cycle ──────────────────────────────────────────────────

  static const List<Map<String, dynamic>> _weatherFacts = [
    {
      'q': 'What is the process called when liquid water turns into water vapour?',
      'correct': 'Evaporation',
      'wrong': ['Condensation', 'Precipitation', 'Transpiration'],
      'exp': 'Evaporation is when heat causes liquid water to become water vapour (gas).',
    },
    {
      'q': 'What is the process called when water vapour cools and turns into liquid droplets?',
      'correct': 'Condensation',
      'wrong': ['Evaporation', 'Precipitation', 'Filtration'],
      'exp': 'Condensation happens when water vapour cools and forms tiny liquid droplets (like clouds).',
    },
    {
      'q': 'What is the name for rain, snow, and hail falling from clouds?',
      'correct': 'Precipitation',
      'wrong': ['Evaporation', 'Condensation', 'Runoff'],
      'exp': 'Precipitation is any water that falls from the sky — rain, snow, sleet, or hail.',
    },
    {
      'q': 'What do clouds form from?',
      'correct': 'Tiny water droplets or ice crystals',
      'wrong': ['Steam from factories', 'Smoke', 'Dust particles'],
      'exp': 'Clouds are made of millions of tiny water droplets or ice crystals suspended in the air.',
    },
    {
      'q': 'Which weather instrument measures temperature?',
      'correct': 'Thermometer',
      'wrong': ['Barometer', 'Anemometer', 'Rain gauge'],
      'exp': 'A thermometer measures temperature in degrees Celsius or Fahrenheit.',
    },
    {
      'q': 'What do we call the daily weather pattern that repeats over a long time in a region?',
      'correct': 'Climate',
      'wrong': ['Weather', 'Season', 'Forecast'],
      'exp': 'Climate is the average weather pattern in an area over many years.',
    },
    {
      'q': 'Where does most of the water that evaporates into clouds come from?',
      'correct': 'Oceans, lakes and rivers',
      'wrong': ['Volcanoes', 'Plants only', 'Underground caves'],
      'exp': 'Most evaporation comes from oceans, lakes, and rivers, which cover most of Earth.',
    },
    {
      'q': 'What type of cloud is very high, thin, and wispy?',
      'correct': 'Cirrus',
      'wrong': ['Cumulus', 'Stratus', 'Nimbus'],
      'exp': 'Cirrus clouds are high, thin, feathery clouds made of ice crystals.',
    },
    {
      'q': 'In the water cycle, what happens to rainwater on a slope?',
      'correct': 'It flows downhill as runoff into rivers',
      'wrong': ['It evaporates immediately', 'It turns to ice', 'It disappears into space'],
      'exp': 'Runoff is rainwater that flows over land into rivers and eventually into the ocean.',
    },
    {
      'q': 'What causes wind?',
      'correct': 'Differences in air pressure',
      'wrong': ['The Moon\'s gravity', 'Earth\'s rotation only', 'Cloud movement'],
      'exp': 'Wind is caused by air moving from areas of high pressure to areas of low pressure.',
    },
  ];

  static ScienceQuestion _generateWeatherQuestion(int difficulty, int index) {
    final fact = _weatherFacts[index % _weatherFacts.length];
    final correct = fact['correct'] as String;
    final wrong = List<String>.from(fact['wrong'] as List);
    wrong.shuffle(_random);
    final options = EnhancedQuestionGenerator.smartShuffle(
        [correct, ...wrong.take(3)], correct);
    return ScienceQuestion(
      id: 'sci_weather_$index',
      skillId: 'skill_earth_sciences',
      question: fact['q'] as String,
      options: options,
      correctIndex: options.indexOf(correct),
      difficulty: difficulty,
      topic: 'Weather and Water Cycle',
      explanation: fact['exp'] as String,
    );
  }
}
