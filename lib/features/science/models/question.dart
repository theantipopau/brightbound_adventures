class ScienceQuestion {
  final String id;
  final String skillId;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String? hint;
  final int difficulty; // 1-5
  final String topic;

  const ScienceQuestion({
    required this.id,
    required this.skillId,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.difficulty,
    required this.topic,
    this.explanation,
    this.hint,
  });

  String get correctAnswer => options[correctIndex];
  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}

/// Biological Sciences Questions
class BiologicalSciencesQuestions {
  static const List<ScienceQuestion> questions = [
    // Level 1 - Living Things
    ScienceQuestion(
      id: 'bio_1',
      skillId: 'skill_biological_sciences',
      question: 'Which of these is a living plant? 🌱',
      options: ['A rock', 'A flower', 'Water', 'Sand'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Living Things',
      hint: 'Which one grows and needs water?',
      explanation: 'A flower is a living plant! It grows, needs water, and can reproduce.',
    ),
    ScienceQuestion(
      id: 'bio_2',
      skillId: 'skill_biological_sciences',
      question: 'What do plants need to grow? 🌿',
      options: ['Only air', 'Water, sunlight, and soil', 'Only water', 'Only sunlight'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Plant Needs',
      hint: 'Plants need three main things...',
      explanation: 'Plants need water from soil, sunlight from the sun, and nutrients from soil to grow strong!',
    ),
    ScienceQuestion(
      id: 'bio_3',
      skillId: 'skill_biological_sciences',
      question: 'What do animals eat to survive?',
      options: ['Only water', 'Food', 'Only plants', 'Only air'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Animal Needs',
      hint: 'Think about what you eat...',
      explanation: 'Animals eat food for energy and to grow. Different animals eat different things!',
    ),
    ScienceQuestion(
      id: 'bio_4',
      skillId: 'skill_biological_sciences',
      question: 'Which animal has feathers? 🦅',
      options: ['Fish', 'Bird', 'Dog', 'Frog'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Animal Features',
      hint: 'Think of something that flies in the sky',
      explanation: 'Birds have feathers! Feathers help them fly and keep them warm.',
    ),
    ScienceQuestion(
      id: 'bio_5',
      skillId: 'skill_biological_sciences',
      question: 'Where do fish live?',
      options: ['In trees', 'In water', 'Underground', 'In the sky'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Habitats',
      hint: 'Think of where fish swim...',
      explanation: 'Fish live in water - in oceans, rivers, and lakes. Water is their habitat!',
    ),
    // Level 2 - Life Cycles
    ScienceQuestion(
      id: 'bio_6',
      skillId: 'skill_biological_sciences',
      question: 'What does a caterpillar become?',
      options: ['A butterfly', 'A beetle', 'A worm', 'A fly'],
      correctIndex: 0,
      difficulty: 2,
      topic: 'Life Cycles',
      hint: 'It\'s a beautiful insect with big wings',
      explanation: 'A caterpillar becomes a butterfly! This change is called metamorphosis.',
    ),
    ScienceQuestion(
      id: 'bio_7',
      skillId: 'skill_biological_sciences',
      question: 'How does a frog start its life?',
      options: ['As a tadpole', 'As a bird', 'As an egg', 'Full-grown'],
      correctIndex: 0,
      difficulty: 2,
      topic: 'Life Cycles',
      hint: 'Baby frogs look different from adults...',
      explanation: 'A frog starts as a tadpole! Tadpoles live in water have tails, then transform into frogs.',
    ),
    ScienceQuestion(
      id: 'bio_8',
      skillId: 'skill_biological_sciences',
      question: 'What part of the plant makes food from sunlight?',
      options: ['Roots', 'Leaves', 'Stem', 'Seeds'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Plant Parts',
      hint: 'The green part of the plant',
      explanation: 'Leaves make food for the plant using sunlight, water, and air. This is called photosynthesis!',
    ),
    ScienceQuestion(
      id: 'bio_9',
      skillId: 'skill_biological_sciences',
      question: 'What do roots do? 🌱',
      options: ['Make leaves', 'Absorb water and nutrients', 'Catch sunlight', 'Make flowers'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Plant Parts',
      hint: 'They\'re under the ground...',
      explanation: 'Roots absorb water and minerals from the soil to help the plant grow and stay strong!',
    ),
    // Level 3-4 - Body Systems
    ScienceQuestion(
      id: 'bio_10',
      skillId: 'skill_biological_sciences',
      question: 'Which body system pumps blood around your body?',
      options: ['Digestive system', 'Circulatory system', 'Nervous system', 'Respiratory system'],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Body Systems',
      hint: 'Your heart is part of this system',
      explanation: 'The circulatory system pumps blood through your body, delivering oxygen and nutrients!',
    ),
    ScienceQuestion(
      id: 'bio_11',
      skillId: 'skill_biological_sciences',
      question: 'What gas do we breathe in that our body needs?',
      options: ['Carbon dioxide', 'Nitrogen', 'Oxygen', 'Hydrogen'],
      correctIndex: 2,
      difficulty: 3,
      topic: 'Respiration',
      hint: 'It\'s in the air around us',
      explanation: 'We breathe in oxygen from the air. Our body uses it for energy and survival!',
    ),
    ScienceQuestion(
      id: 'bio_12',
      skillId: 'skill_biological_sciences',
      question: 'Which animals are herbivores?',
      options: ['Lions and tigers', 'Cows and rabbits', 'Sharks and hawks', 'Bears and wolves'],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Food Chains',
      hint: 'They eat plants, not meat',
      explanation: 'Herbivores eat only plants. Cows eat grass and rabbits eat vegetables and plants!',
    ),
  ];

  static List<ScienceQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Earth Sciences Questions
class EarthSciencesQuestions {
  static const List<ScienceQuestion> questions = [
    // Level 1 - Weather & Climate
    ScienceQuestion(
      id: 'earth_1',
      skillId: 'skill_earth_sciences',
      question: 'What falls from clouds when it rains? 🌧️',
      options: ['Snow', 'Water droplets', 'Wind', 'Hail'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Water Cycle',
      hint: 'It\'s wet...',
      explanation: 'Water droplets fall from clouds as rain. This is part of the water cycle!',
    ),
    ScienceQuestion(
      id: 'earth_2',
      skillId: 'skill_earth_sciences',
      question: 'What is soil made of?',
      options: ['Only sand', 'Rock pieces, minerals, and dead plants', 'Only dirt', 'Only clay'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Soils',
      hint: 'It\'s in your garden...',
      explanation: 'Soil is made of broken rocks, minerals, and dead plant matter. Plants grow in soil!',
    ),
    ScienceQuestion(
      id: 'earth_3',
      skillId: 'skill_earth_sciences',
      question: 'What are the four seasons? ☀️❄️',
      options: ['Hot and cold', 'Spring, summer, fall, winter', 'Day and night', 'Morning and afternoon'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Seasons',
      hint: 'There are four of them',
      explanation: 'The four seasons are spring, summer, fall (autumn), and winter. They repeat each year!',
    ),
    ScienceQuestion(
      id: 'earth_4',
      skillId: 'skill_earth_sciences',
      question: 'What heats the Earth?',
      options: ['The moon', 'The sun', 'Wind', 'Water'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Sun',
      hint: 'It\'s very hot and bright',
      explanation: 'The sun heats the Earth with its energy! Without the sun, there would be no life.',
    ),
    ScienceQuestion(
      id: 'earth_5',
      skillId: 'skill_earth_sciences',
      question: 'What covers most of Earth?',
      options: ['Land', 'Ice', 'Water', 'Clouds'],
      correctIndex: 2,
      difficulty: 1,
      topic: 'Earth Surface',
      hint: 'It\'s found in oceans and seas...',
      explanation: 'Water covers about 70% of Earth\'s surface! Most is in oceans and seas.',
    ),
    // Level 2 - Rocks & Minerals
    ScienceQuestion(
      id: 'earth_6',
      skillId: 'skill_earth_sciences',
      question: 'What are rocks made of?',
      options: ['Dirt only', 'Minerals and other rocks', 'Sand only', 'Clay only'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Rocks',
      hint: 'Multiple things combine...',
      explanation: 'Rocks are made of minerals! Different combinations of minerals make different rocks.',
    ),
    ScienceQuestion(
      id: 'earth_7',
      skillId: 'skill_earth_sciences',
      question: 'What causes earthquakes?',
      options: ['Wind', 'Movement of Earth\'s crust', 'Rain', 'Animals'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Earthquakes',
      hint: 'Think about layers under the ground',
      explanation: 'Earthquakes are caused by movement of massive rock plates under Earth\'s crust!',
    ),
    ScienceQuestion(
      id: 'earth_8',
      skillId: 'skill_earth_sciences',
      question: 'What is the water cycle?',
      options: [
        'Water going round and round Earth',
        'Evaporation, condensation, and precipitation',
        'Only rain',
        'Only oceans'
      ],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Water Cycle',
      hint: 'It involves clouds, rain, and evaporation',
      explanation: 'The water cycle: water evaporates, forms clouds, then falls as rain or snow!',
    ),
    ScienceQuestion(
      id: 'earth_9',
      skillId: 'skill_earth_sciences',
      question: 'What happens when water evaporates?',
      options: ['It becomes ice', 'It turns into water vapor and rises into the air', 'It disappears', 'It becomes salt'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Water States',
      hint: 'Think of puddles in the sun...',
      explanation: 'Evaporation is when water turns into vapor and floats up into the atmosphere!',
    ),
    // Level 3 - Weather Patterns
    ScienceQuestion(
      id: 'earth_10',
      skillId: 'skill_earth_sciences',
      question: 'What is the atmosphere?',
      options: ['Ocean water', 'Layer of gases around Earth', 'Soil', 'Rocks'],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Atmosphere',
      hint: 'You breathe it every day',
      explanation: 'The atmosphere is the layer of gases (air) that surrounds Earth. We live in it!',
    ),
    ScienceQuestion(
      id: 'earth_11',
      skillId: 'skill_earth_sciences',
      question: 'What are fossils?',
      options: ['Living animals', 'Plants today', 'Remains of ancient life preserved in rocks', 'Modern stones'],
      correctIndex: 2,
      difficulty: 3,
      topic: 'Fossils',
      hint: 'They\'re very old...',
      explanation: 'Fossils are the preserved remains of living things from long ago, found in rocks!',
    ),
    ScienceQuestion(
      id: 'earth_12',
      skillId: 'skill_earth_sciences',
      question: 'Which process breaks rocks into smaller pieces?',
      options: ['Growth', 'Weathering', 'Freezing', 'Heating'],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Weathering',
      hint: 'Wind, rain, and ice do this...',
      explanation: 'Weathering is when rocks are broken into smaller pieces by wind, water, ice, and temperature changes!',
    ),
  ];

  static List<ScienceQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}

/// Physical Sciences Questions
class PhysicalSciencesQuestions {
  static const List<ScienceQuestion> questions = [
    // Level 1 - Basic Forces
    ScienceQuestion(
      id: 'phys_1',
      skillId: 'skill_physical_sciences',
      question: 'What pulls things toward the ground?',
      options: ['Wind', 'Gravity', 'Magnetism', 'Air'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Gravity',
      hint: 'It keeps us on Earth...',
      explanation: 'Gravity is a force that pulls things toward Earth. That\'s why things fall down!',
    ),
    ScienceQuestion(
      id: 'phys_2',
      skillId: 'skill_physical_sciences',
      question: 'What is motion? 🏃',
      options: ['Being still', 'Changing position', 'Being heavy', 'Being light'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Motion',
      hint: 'When something moves...',
      explanation: 'Motion is when something changes position and moves from one place to another!',
    ),
    ScienceQuestion(
      id: 'phys_3',
      skillId: 'skill_physical_sciences',
      question: 'What is a magnet?',
      options: ['A type of rock', 'Something that attracts metal', 'A tool for digging', 'A type of clay'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Magnetism',
      hint: 'It attracts metal...',
      explanation: 'A magnet is an object that attracts metals like iron. Magnets have two poles!',
    ),
    ScienceQuestion(
      id: 'phys_4',
      skillId: 'skill_physical_sciences',
      question: 'What sources give us light?',
      options: ['Rocks', 'The sun and light bulbs', 'Water', 'Plants'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Light',
      hint: 'Think of bright things...',
      explanation: 'Light sources include the sun, light bulbs, candles, and fires. They produce light energy!',
    ),
    ScienceQuestion(
      id: 'phys_5',
      skillId: 'skill_physical_sciences',
      question: 'What are three states of matter?',
      options: ['Hot and cold', 'Solid, liquid, and gas', 'Big and small', 'Hard and soft'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'States of Matter',
      hint: 'Ice, water, and steam...',
      explanation: 'The three states of matter are solid (like ice), liquid (like water), and gas (like steam)!',
    ),
    // Level 2 - Energy & Heat
    ScienceQuestion(
      id: 'phys_6',
      skillId: 'skill_physical_sciences',
      question: 'What is heat? 🔥',
      options: ['Light', 'Energy that makes things warm', 'Motion', 'Electricity'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Heat',
      hint: 'It makes things warm...',
      explanation: 'Heat is thermal energy that makes things warm. Heat flows from hot to cold places!',
    ),
    ScienceQuestion(
      id: 'phys_7',
      skillId: 'skill_physical_sciences',
      question: 'What is force?',
      options: ['Energy', 'A push or pull', 'Motion', 'Gravity alone'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Forces',
      hint: 'It pushes or pulls...',
      explanation: 'A force is a push or pull that can change how something moves or its shape!',
    ),
    ScienceQuestion(
      id: 'phys_8',
      skillId: 'skill_physical_sciences',
      question: 'How does sound travel?',
      options: ['Instantly', 'In waves through air or water', 'Only through solids', 'From the sun'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Sound',
      hint: 'It travels in waves...',
      explanation: 'Sound travels in waves through air and other materials. It needs a medium to travel!',
    ),
    ScienceQuestion(
      id: 'phys_9',
      skillId: 'skill_physical_sciences',
      question: 'What is electricity?',
      options: ['Light', 'Energy from moving electrons', 'Heat only', 'Magnetism only'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Electricity',
      hint: 'It powers light bulbs...',
      explanation: 'Electricity is energy from moving electrons. It powers our homes and devices!',
    ),
    // Level 3-4 - Complex Concepts
    ScienceQuestion(
      id: 'phys_10',
      skillId: 'skill_physical_sciences',
      question: 'What happens when a solid changes to a liquid?',
      options: ['Freezing', 'Melting', 'Evaporation', 'Condensation'],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Phase Changes',
      hint: 'Ice becomes water...',
      explanation: 'Melting is when a solid changes to a liquid by adding heat. Ice melts into water!',
    ),
    ScienceQuestion(
      id: 'phys_11',
      skillId: 'skill_physical_sciences',
      question: 'What is momentum?',
      options: ['Stillness', 'The tendency of moving objects to keep moving', 'Heat', 'Light'],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Motion',
      hint: 'Heavy objects are hard to stop...',
      explanation: 'Momentum is the tendency of a moving object to continue moving in the same direction!',
    ),
    ScienceQuestion(
      id: 'phys_12',
      skillId: 'skill_physical_sciences',
      question: 'What is friction?',
      options: ['Smoothness', 'A force that slows moving objects', 'Speed', 'Gravity'],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Forces',
      hint: 'It slows things down...',
      explanation: 'Friction is a force that resists motion when surfaces rub together. It slows things down!',
    ),
  ];

  static List<ScienceQuestion> getByDifficulty(int level) {
    return questions.where((q) => q.difficulty <= level).toList();
  }
}
