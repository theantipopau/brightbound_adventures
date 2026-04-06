import 'dart:math';
import 'package:brightbound_adventures/features/science/models/question.dart';

/// Extended static question bank for Science Explorers.
///
/// All questions are Australian Curriculum–aligned for years F–6 (ages 5–12).
/// Use [ScienceQuestionBank.get] to draw a shuffled subset by skill and difficulty.
class ScienceQuestionBank {
  static final Random _random = Random();

  static const List<ScienceQuestion> _all = [
    // ── BIOLOGY: difficulty 1 ─────────────────────────────────────────────────

    ScienceQuestion(
      id: 'bank_bio_001',
      skillId: 'skill_biological_sciences',
      question: 'Which of these is a mammal? 🐨',
      options: ['Eagle', 'Koala', 'Crocodile', 'Goldfish'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Animal Classification',
      hint: 'Mammals have fur or hair and feed their babies milk.',
      explanation: 'A koala is a mammal — it has fur and raises its joey in a pouch.',
    ),
    ScienceQuestion(
      id: 'bank_bio_002',
      skillId: 'skill_biological_sciences',
      question: 'What do all living things need to survive? 💧',
      options: ['Only sunlight', 'Water and food', 'Only air', 'Only sunlight and air'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Needs of Living Things',
      hint: 'Think about what you need every day.',
      explanation: 'All living things need water and food (energy) to survive, plus air for most animals.',
    ),
    ScienceQuestion(
      id: 'bank_bio_003',
      skillId: 'skill_biological_sciences',
      question: 'Which of these is NOT a living thing? 🪨',
      options: ['Oak tree', 'Butterfly', 'River stone', 'Daisy'],
      correctIndex: 2,
      difficulty: 1,
      topic: 'Living and Non-living',
      hint: 'Living things grow and move on their own.',
      explanation: 'A river stone is not alive — it does not grow, breathe, or reproduce.',
    ),
    ScienceQuestion(
      id: 'bank_bio_004',
      skillId: 'skill_biological_sciences',
      question: 'Where would you find a polar bear living? 🐻‍❄️',
      options: ['Rainforest', 'Desert', 'Arctic ice', 'Ocean depths'],
      correctIndex: 2,
      difficulty: 1,
      topic: 'Habitats',
      hint: 'Polar bears have thick white fur to stay warm.',
      explanation: 'Polar bears live in the Arctic — they are adapted to survive on snow and ice.',
    ),
    ScienceQuestion(
      id: 'bank_bio_005',
      skillId: 'skill_biological_sciences',
      question: 'What covers a fish\'s body? 🐟',
      options: ['Fur', 'Feathers', 'Scales', 'Smooth skin'],
      correctIndex: 2,
      difficulty: 1,
      topic: 'Animal Features',
      hint: 'Think of what you can see shining on a fish.',
      explanation: 'Fish have scales — thin, overlapping plates that protect their bodies.',
    ),
    ScienceQuestion(
      id: 'bank_bio_006',
      skillId: 'skill_biological_sciences',
      question: 'What is the job of roots on a plant? 🌿',
      options: ['Make seeds', 'Absorb water and nutrients', 'Attract insects', 'Make food from sunlight'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Plant Parts',
      hint: 'Roots grow underground — what do they collect there?',
      explanation: 'Roots anchor the plant in soil and absorb water and minerals the plant needs to grow.',
    ),
    ScienceQuestion(
      id: 'bank_bio_007',
      skillId: 'skill_biological_sciences',
      question: 'How many legs does an insect have?',
      options: ['4', '6', '8', '10'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Animal Classification',
      hint: 'All insects share the same number of legs.',
      explanation: 'All insects have 6 legs — that\'s one of the main features of insects.',
    ),
    ScienceQuestion(
      id: 'bank_bio_008',
      skillId: 'skill_biological_sciences',
      question: 'Which animal is a reptile? 🦎',
      options: ['Eagle', 'Lizard', 'Frog', 'Shark'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Animal Classification',
      hint: 'Reptiles have scaly skin and are cold-blooded.',
      explanation: 'A lizard is a reptile. Reptiles have scaly skin and lay eggs on land.',
    ),

    // ── BIOLOGY: difficulty 2 ─────────────────────────────────────────────────

    ScienceQuestion(
      id: 'bank_bio_009',
      skillId: 'skill_biological_sciences',
      question: 'In a food chain, what is an animal called that ONLY eats plants?',
      options: ['Carnivore', 'Omnivore', 'Herbivore', 'Decomposer'],
      correctIndex: 2,
      difficulty: 2,
      topic: 'Food Chains',
      hint: '"Herb" means plant — which word starts with herb?',
      explanation: 'A herbivore only eats plants. Cows, rabbits, and caterpillars are herbivores.',
    ),
    ScienceQuestion(
      id: 'bank_bio_010',
      skillId: 'skill_biological_sciences',
      question: 'What process do plants use to make their own food using sunlight?',
      options: ['Respiration', 'Photosynthesis', 'Digestion', 'Evaporation'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Photosynthesis',
      hint: '"Photo" means light — which process uses light?',
      explanation: 'Photosynthesis: plants use sunlight, water, and carbon dioxide to make glucose (sugar).',
    ),
    ScienceQuestion(
      id: 'bank_bio_011',
      skillId: 'skill_biological_sciences',
      question: 'A simple food chain: Grass → Rabbit → Fox. What is the grass?',
      options: ['Consumer', 'Predator', 'Producer', 'Decomposer'],
      correctIndex: 2,
      difficulty: 2,
      topic: 'Food Chains',
      hint: 'The grass makes its own food — what are things called that make food?',
      explanation: 'Plants are producers — they produce (make) their own food using sunlight.',
    ),
    ScienceQuestion(
      id: 'bank_bio_012',
      skillId: 'skill_biological_sciences',
      question: 'Which organ pumps blood around your body? ❤️',
      options: ['Lung', 'Stomach', 'Heart', 'Brain'],
      correctIndex: 2,
      difficulty: 2,
      topic: 'Human Body',
      hint: 'You can feel it beating in your chest.',
      explanation: 'The heart pumps blood around the body, delivering oxygen and nutrients to every cell.',
    ),
    ScienceQuestion(
      id: 'bank_bio_013',
      skillId: 'skill_biological_sciences',
      question: 'What do lungs do? 🫁',
      options: ['Pump blood', 'Digest food', 'Take in oxygen from air', 'Send signals to muscles'],
      correctIndex: 2,
      difficulty: 2,
      topic: 'Human Body',
      hint: 'Lungs are in your chest and help you breathe.',
      explanation: 'Lungs breathe in air and extract oxygen, which the blood carries to all cells.',
    ),
    ScienceQuestion(
      id: 'bank_bio_014',
      skillId: 'skill_biological_sciences',
      question: 'During metamorphosis, what stage does a butterfly spend inside a chrysalis?',
      options: ['Larva (caterpillar)', 'Egg', 'Pupa', 'Adult'],
      correctIndex: 2,
      difficulty: 2,
      topic: 'Life Cycles',
      hint: 'The chrysalis is the case — what stage is the butterfly IN the case?',
      explanation: 'Inside the chrysalis, the caterpillar is in the PUPA stage, transforming into a butterfly.',
    ),
    ScienceQuestion(
      id: 'bank_bio_015',
      skillId: 'skill_biological_sciences',
      question: 'Which part of a flower makes pollen?',
      options: ['Petal', 'Stamen', 'Pistil', 'Sepal'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Plants',
      hint: 'The stamen is the male part of the flower.',
      explanation: 'The stamen (male part) produces pollen. Pollen is carried to other flowers for reproduction.',
    ),
    ScienceQuestion(
      id: 'bank_bio_016',
      skillId: 'skill_biological_sciences',
      question: 'What is a habitat?',
      options: ['An animal\'s diet', 'The natural home of an animal or plant', 'How an animal moves', 'An animal\'s colour pattern'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Habitats',
      hint: '"Hab" comes from Latin meaning "to dwell" — where an animal dwells.',
      explanation: 'A habitat is the natural environment where an animal or plant lives, finding food and shelter.',
    ),
    ScienceQuestion(
      id: 'bank_bio_017',
      skillId: 'skill_biological_sciences',
      question: 'Which of these animals is an amphibian? 🐸',
      options: ['Shark', 'Gecko', 'Frog', 'Pigeon'],
      correctIndex: 2,
      difficulty: 2,
      topic: 'Animal Classification',
      hint: 'Amphibians live in water AND on land.',
      explanation: 'Frogs are amphibians — they start life in water as tadpoles then live on land as adults.',
    ),

    // ── BIOLOGY: difficulty 3 ─────────────────────────────────────────────────

    ScienceQuestion(
      id: 'bank_bio_018',
      skillId: 'skill_biological_sciences',
      question: 'In a food chain, what happens if all the rabbits disappeared from: Grass → Rabbit → Fox → Eagle?',
      options: [
        'Eagles would get more food',
        'Grass would die out quickly',
        'Foxes would lose a food source and may decline',
        'Nothing would change'
      ],
      correctIndex: 2,
      difficulty: 3,
      topic: 'Ecosystems',
      hint: 'What do foxes eat in this chain?',
      explanation: 'Foxes depend on rabbits for food. Fewer rabbits means foxes have less to eat and may decline in numbers.',
    ),
    ScienceQuestion(
      id: 'bank_bio_019',
      skillId: 'skill_biological_sciences',
      question: 'What do decomposers like fungi and bacteria do in an ecosystem?',
      options: [
        'Hunt prey',
        'Photosynthesize like plants',
        'Break down dead material into nutrients',
        'Move seeds to new locations'
      ],
      correctIndex: 2,
      difficulty: 3,
      topic: 'Ecosystems',
      hint: '"De-compose" means to break apart.',
      explanation: 'Decomposers break down dead plants and animals, returning nutrients to the soil for new plants to use.',
    ),
    ScienceQuestion(
      id: 'bank_bio_020',
      skillId: 'skill_biological_sciences',
      question: 'A cactus has thick stems to store water and spines instead of leaves. What is this an example of?',
      options: ['Migration', 'Adaptation', 'Reproduction', 'Classification'],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Adaptation',
      hint: 'The cactus\'s features SUIT the desert environment.',
      explanation: 'Adaptation is when a species develops features over time that help it survive in its environment.',
    ),
    ScienceQuestion(
      id: 'bank_bio_021',
      skillId: 'skill_biological_sciences',
      question: 'Why do bees visit flowers? 🐝🌸',
      options: [
        'To sleep inside them',
        'To collect nectar for honey and accidentally pollinate the flowers',
        'To eat the petals',
        'To cool down in summer'
      ],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Ecosystems',
      hint: 'Bees collect nectar. Pollen sticks to their bodies as they move.',
      explanation: 'Bees collect nectar for honey. As they move between flowers, pollen sticks to them, pollinating other flowers.',
    ),
    ScienceQuestion(
      id: 'bank_bio_022',
      skillId: 'skill_biological_sciences',
      question: 'What is the function of a plant\'s flower?',
      options: [
        'To absorb water from the soil',
        'To make food from sunlight',
        'To attract pollinators and produce seeds for reproduction',
        'To anchor the plant in the ground'
      ],
      correctIndex: 2,
      difficulty: 3,
      topic: 'Plants',
      hint: 'Flowers are brightly coloured for a reason.',
      explanation: 'Flowers attract insects and animals that carry pollen, enabling fertilisation and seed production.',
    ),
    ScienceQuestion(
      id: 'bank_bio_023',
      skillId: 'skill_biological_sciences',
      question: 'Which body system controls breathing and speaking?',
      options: ['Circulatory system', 'Digestive system', 'Respiratory system', 'Skeletal system'],
      correctIndex: 2,
      difficulty: 3,
      topic: 'Human Body',
      hint: 'Think about respiration — what verb is inside that word?',
      explanation: 'The respiratory system (lungs, windpipe, diaphragm) controls breathing and the intake of oxygen.',
    ),

    // ── BIOLOGY: difficulty 4–5 ────────────────────────────────────────────────

    ScienceQuestion(
      id: 'bank_bio_024',
      skillId: 'skill_biological_sciences',
      question: 'A rain forest is cleared for farming. How would this MOST LIKELY affect food chains in the area?',
      options: [
        'Food chains would become stronger',
        'Organisms would adapt instantly',
        'Many food chains would collapse as habitats and food sources are lost',
        'Only carnivores would be affected'
      ],
      correctIndex: 2,
      difficulty: 4,
      topic: 'Ecosystems',
      hint: 'A food chain depends on every link. Remove the plants…',
      explanation: 'Clearing a rainforest destroys habitats and removes producers (plants), causing food chains throughout the ecosystem to collapse.',
    ),
    ScienceQuestion(
      id: 'bank_bio_025',
      skillId: 'skill_biological_sciences',
      question: 'Sharks in the open ocean rarely move into freshwater rivers. What BEST explains this?',
      options: [
        'They are afraid of fresh water',
        'Their bodies are adapted to saltwater and can\'t easily regulate salt levels in freshwater',
        'Freshwater has more predators',
        'Rivers are too shallow'
      ],
      correctIndex: 1,
      difficulty: 5,
      topic: 'Adaptation',
      hint: 'Their bodies maintain a certain salt balance — called osmoregulation.',
      explanation: 'Marine sharks are adapted to regulate salt from seawater. In fresh water, their osmoregulation system is overwhelmed.',
    ),

    // ── EARTH & SPACE: difficulty 1 ───────────────────────────────────────────

    ScienceQuestion(
      id: 'bank_earth_001',
      skillId: 'skill_earth_sciences',
      question: 'What causes day and night on Earth? 🌍',
      options: [
        'The sun moving around the Earth',
        'Clouds blocking the sun',
        'The Earth spinning on its axis',
        'The moon blocking sunlight'
      ],
      correctIndex: 2,
      difficulty: 1,
      topic: 'Earth and Space',
      hint: 'Think of the Earth as a spinning ball.',
      explanation: 'Earth spins (rotates) on its axis once every 24 hours. The side facing the sun has day; the other side has night.',
    ),
    ScienceQuestion(
      id: 'bank_earth_002',
      skillId: 'skill_earth_sciences',
      question: 'Which season is Australia\'s WARMEST? ☀️',
      options: ['Winter', 'Autumn', 'Spring', 'Summer'],
      correctIndex: 3,
      difficulty: 1,
      topic: 'Seasons',
      hint: 'School holidays in January fall in which season?',
      explanation: 'Summer is Australia\'s warmest season. In Australia, summer runs from December to February.',
    ),
    ScienceQuestion(
      id: 'bank_earth_003',
      skillId: 'skill_earth_sciences',
      question: 'What is the source of most of Earth\'s heat and light? ☀️',
      options: ['The Moon', 'Stars far away', 'The Sun', 'Earth\'s core'],
      correctIndex: 2,
      difficulty: 1,
      topic: 'Sun',
      hint: 'It rises in the east every morning.',
      explanation: 'The Sun is our nearest star. It provides light and warmth that makes life on Earth possible.',
    ),
    ScienceQuestion(
      id: 'bank_earth_004',
      skillId: 'skill_earth_sciences',
      question: 'What is the name of the planet we live on?',
      options: ['Mars', 'Venus', 'Earth', 'Saturn'],
      correctIndex: 2,
      difficulty: 1,
      topic: 'Solar System',
      hint: 'The planet with oceans and lots of life!',
      explanation: 'We live on Earth, the third planet from the Sun and the only planet known to support life.',
    ),
    ScienceQuestion(
      id: 'bank_earth_005',
      skillId: 'skill_earth_sciences',
      question: 'What is a cloud made of? ☁️',
      options: ['Cotton', 'Smoke', 'Tiny water droplets or ice crystals', 'Dust particles'],
      correctIndex: 2,
      difficulty: 1,
      topic: 'Weather',
      hint: 'Clouds are part of the water cycle.',
      explanation: 'Clouds form when water vapour in the air cools and condenses into tiny water droplets or ice crystals.',
    ),

    // ── EARTH & SPACE: difficulty 2 ───────────────────────────────────────────

    ScienceQuestion(
      id: 'bank_earth_006',
      skillId: 'skill_earth_sciences',
      question: 'What process turns liquid water into water vapour? 💧→💨',
      options: ['Condensation', 'Evaporation', 'Precipitation', 'Runoff'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Water Cycle',
      hint: '"Evaporate" sounds like "vapour".',
      explanation: 'Evaporation happens when the sun\'s heat turns liquid water (oceans, lakes) into water vapour that rises into the sky.',
    ),
    ScienceQuestion(
      id: 'bank_earth_007',
      skillId: 'skill_earth_sciences',
      question: 'Put the water cycle steps in order: Evaporation → ? → Precipitation',
      options: ['Runoff', 'Condensation', 'Absorption', 'Freezing'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Water Cycle',
      hint: 'Water vapour cools down and turns back into liquid — what is that called?',
      explanation: 'Condensation is when water vapour cools and turns back into water droplets, forming clouds.',
    ),
    ScienceQuestion(
      id: 'bank_earth_008',
      skillId: 'skill_earth_sciences',
      question: 'How many planets are in our solar system?',
      options: ['7', '8', '9', '10'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Solar System',
      hint: 'Pluto was reclassified as a dwarf planet in 2006.',
      explanation: 'There are 8 planets: Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune.',
    ),
    ScienceQuestion(
      id: 'bank_earth_009',
      skillId: 'skill_earth_sciences',
      question: 'Which planet is closest to the Sun? ☀️',
      options: ['Venus', 'Earth', 'Mercury', 'Mars'],
      correctIndex: 2,
      difficulty: 2,
      topic: 'Solar System',
      hint: 'It\'s the smallest planet too.',
      explanation: 'Mercury is the closest planet to the Sun. It\'s also the smallest planet in our solar system.',
    ),
    ScienceQuestion(
      id: 'bank_earth_010',
      skillId: 'skill_earth_sciences',
      question: 'Why does the sky appear blue during the day?',
      options: [
        'The ocean reflects up onto the sky',
        'Blue paint is at the edge of space',
        'Sunlight scatters in the atmosphere, and blue light scatters most',
        'The air itself is blue'
      ],
      correctIndex: 2,
      difficulty: 2,
      topic: 'Light and Atmosphere',
      hint: 'Different colours of light scatter differently in the atmosphere.',
      explanation: 'When sunlight enters the atmosphere, blue light (shorter wavelength) scatters in all directions — we see this scattered blue light.',
    ),
    ScienceQuestion(
      id: 'bank_earth_011',
      skillId: 'skill_earth_sciences',
      question: 'What causes the seasons to change on Earth?',
      options: [
        'Earth moving closer and farther from the Sun',
        'Earth\'s tilted axis as it orbits the Sun',
        'The moon blocking sunlight',
        'Changes in the speed Earth spins'
      ],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Seasons',
      hint: 'Earth leans at an angle — this tilt matters.',
      explanation: 'Earth\'s axis is tilted 23.5°. As Earth orbits the Sun, the tilt causes different hemispheres to receive more direct sunlight at different times.',
    ),
    ScienceQuestion(
      id: 'bank_earth_012',
      skillId: 'skill_earth_sciences',
      question: 'What type of rock is formed when magma cools and hardens?',
      options: ['Sedimentary', 'Metamorphic', 'Igneous', 'Gemstone'],
      correctIndex: 2,
      difficulty: 2,
      topic: 'Rocks and Minerals',
      hint: '"Ignite" means to set on fire — magma is very hot.',
      explanation: 'Igneous rocks form when molten rock (magma or lava) cools and solidifies. Basalt and granite are examples.',
    ),
    ScienceQuestion(
      id: 'bank_earth_013',
      skillId: 'skill_earth_sciences',
      question: 'How long does it take Earth to orbit the Sun once?',
      options: ['1 day', '1 month', '1 year', '10 years'],
      correctIndex: 2,
      difficulty: 2,
      topic: 'Earth and Space',
      hint: 'That\'s why we have a calendar year!',
      explanation: 'Earth takes approximately 365.25 days (one year) to complete one full orbit around the Sun.',
    ),

    // ── EARTH & SPACE: difficulty 3–4 ─────────────────────────────────────────

    ScienceQuestion(
      id: 'bank_earth_014',
      skillId: 'skill_earth_sciences',
      question: 'Why do we always see the same face of the Moon from Earth?',
      options: [
        'The Moon doesn\'t rotate',
        'The Moon rotates at the same speed it orbits Earth',
        'The Moon is too far away to rotate',
        'The Sun\'s gravity keeps the Moon still'
      ],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Moon',
      hint: 'The Moon\'s rotation and orbit periods happen to be the same length.',
      explanation: 'The Moon\'s rotation period equals its orbital period around Earth (both ~27 days), so the same face always points at us — this is called tidal locking.',
    ),
    ScienceQuestion(
      id: 'bank_earth_015',
      skillId: 'skill_earth_sciences',
      question: 'What are fossils?',
      options: [
        'Types of rock crystals',
        'Preserved remains or traces of ancient living things in rock',
        'Minerals formed by volcanoes',
        'Space rocks that land on Earth'
      ],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Fossils',
      hint: 'They show us what lived millions of years ago.',
      explanation: 'Fossils are preserved remains (bones, shells, imprints) of dead organisms embedded in rock over millions of years.',
    ),
    ScienceQuestion(
      id: 'bank_earth_016',
      skillId: 'skill_earth_sciences',
      question: 'How does an earthquake happen? 🌍',
      options: [
        'Volcanoes heat the ground unevenly',
        'Tectonic plates move and release energy',
        'Strong winds underground',
        'The moon\'s gravity pulls the ground'
      ],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Natural Events',
      hint: 'Earth\'s surface is made of large moving sections.',
      explanation: 'Earth\'s crust is made of large tectonic plates. When they suddenly slip past each other, energy is released as seismic waves — an earthquake.',
    ),
    ScienceQuestion(
      id: 'bank_earth_017',
      skillId: 'skill_earth_sciences',
      question: 'What is the difference between a meteor and a meteorite?',
      options: [
        'They are the same thing',
        'A meteor is in space; a meteorite has landed on Earth',
        'Meteors are huge; meteorites are tiny',
        'Meteors are from the Moon; meteorites from asteroids'
      ],
      correctIndex: 1,
      difficulty: 4,
      topic: 'Solar System',
      hint: 'The "-ite" suffix often means a mineral or rock on Earth\'s surface.',
      explanation: 'A meteor is a space rock burning in the atmosphere (shooting star). A meteorite is one that has survived and landed on Earth.',
    ),

    // ── PHYSICAL SCIENCE: difficulty 1–2 ──────────────────────────────────────

    ScienceQuestion(
      id: 'bank_phys_001',
      skillId: 'skill_physical_sciences',
      question: 'A push or a pull is called a…? 💪',
      options: ['Material', 'Force', 'Energy', 'Motion'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Forces',
      hint: 'You use force every time you open a door.',
      explanation: 'A force is a push or pull that can change an object\'s speed, direction, or shape.',
    ),
    ScienceQuestion(
      id: 'bank_phys_002',
      skillId: 'skill_physical_sciences',
      question: 'Which material is BEST for making a waterproof raincoat? 🌧️',
      options: ['Paper', 'Cotton', 'Plastic', 'Cardboard'],
      correctIndex: 2,
      difficulty: 1,
      topic: 'Materials',
      hint: 'Water cannot pass through this material.',
      explanation: 'Plastic is waterproof — water cannot soak through it, making it ideal for rain gear.',
    ),
    ScienceQuestion(
      id: 'bank_phys_003',
      skillId: 'skill_physical_sciences',
      question: 'What does a magnet attract? 🧲',
      options: ['All metals', 'Iron and steel', 'Plastic and wood', 'Water'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Magnetism',
      hint: 'Not all metals are attracted to magnets.',
      explanation: 'Magnets attract iron and steel (and a few other metals like nickel and cobalt), not all metals.',
    ),
    ScienceQuestion(
      id: 'bank_phys_004',
      skillId: 'skill_physical_sciences',
      question: 'What happens to most solids when they are heated? 🔥',
      options: ['They shrink', 'They turn into gas immediately', 'They melt into liquid', 'Nothing happens'],
      correctIndex: 2,
      difficulty: 1,
      topic: 'States of Matter',
      hint: 'Think of ice heating up.',
      explanation: 'When enough heat is applied, most solids melt and become liquid (e.g. ice → water, wax → liquid wax).',
    ),
    ScienceQuestion(
      id: 'bank_phys_005',
      skillId: 'skill_physical_sciences',
      question: 'Which material conducts electricity? ⚡',
      options: ['Rubber', 'Plastic', 'Wood', 'Copper wire'],
      correctIndex: 3,
      difficulty: 2,
      topic: 'Electricity',
      hint: 'Electrical wires are made of metal.',
      explanation: 'Copper is a metal and a good conductor — electricity flows easily through it. That\'s why wires are made from copper.',
    ),
    ScienceQuestion(
      id: 'bank_phys_006',
      skillId: 'skill_physical_sciences',
      question: 'Why does a ball slow down after being rolled along the ground?',
      options: [
        'Gravity pushes it downward',
        'Friction between the ball and ground removes energy',
        'Air takes energy from the ball',
        'The ball\'s weight increases'
      ],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Forces',
      hint: 'Think about what force opposes motion.',
      explanation: 'Friction is a force between surfaces that opposes motion. As the ball rolls, friction gradually removes its kinetic energy and slows it down.',
    ),
    ScienceQuestion(
      id: 'bank_phys_007',
      skillId: 'skill_physical_sciences',
      question: 'Light travels in…',
      options: ['Curved lines', 'Straight lines', 'Circles', 'Zigzag patterns'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Light',
      hint: 'A torch beam doesn\'t curve around corners.',
      explanation: 'Light travels in straight lines — that\'s why shadows have sharp edges and you can\'t see around corners.',
    ),
    ScienceQuestion(
      id: 'bank_phys_008',
      skillId: 'skill_physical_sciences',
      question: 'What is sound?',
      options: [
        'Light waves bouncing off objects',
        'Vibrations travelling through a medium',
        'Air becoming warmer',
        'Objects releasing colour'
      ],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Sound',
      hint: 'Touch a guitar string after plucking it — what do you feel?',
      explanation: 'Sound is created by vibrations. These vibrations travel through air (or other materials) as waves and reach our ears.',
    ),
    ScienceQuestion(
      id: 'bank_phys_009',
      skillId: 'skill_physical_sciences',
      question: 'What is the pull of gravity on an object called?',
      options: ['Mass', 'Weight', 'Friction', 'Pressure'],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Forces',
      hint: 'We measure it in Newtons.',
      explanation: 'Weight is the force of gravity pulling on an object\'s mass. Mass is the amount of matter; weight depends on the gravitational pull.',
    ),
    ScienceQuestion(
      id: 'bank_phys_010',
      skillId: 'skill_physical_sciences',
      question: 'What happens when light passes through a glass prism? 🌈',
      options: [
        'The light turns off',
        'The light speed increases',
        'White light splits into the colours of the rainbow',
        'The glass heats up and glows'
      ],
      correctIndex: 2,
      difficulty: 2,
      topic: 'Light',
      hint: 'A prism separates white light into its components.',
      explanation: 'White light is made of all the rainbow colours (red to violet). A prism bends each colour at a different angle, splitting them apart.',
    ),

    // ── PHYSICAL SCIENCE: difficulty 3–5 ──────────────────────────────────────

    ScienceQuestion(
      id: 'bank_phys_011',
      skillId: 'skill_physical_sciences',
      question: 'A lever has its pivot (fulcrum) in the MIDDLE. What type of simple machine is a seesaw?',
      options: ['Inclined plane', 'Pulley', 'First-class lever', 'Wedge'],
      correctIndex: 2,
      difficulty: 3,
      topic: 'Simple Machines',
      hint: 'When the fulcrum is between the load and effort, it\'s a first-class lever.',
      explanation: 'A seesaw is a first-class lever — the fulcrum (pivot) sits between the applied force (effort) and the load.',
    ),
    ScienceQuestion(
      id: 'bank_phys_012',
      skillId: 'skill_physical_sciences',
      question: 'Which state of matter has a definite shape AND volume?',
      options: ['Gas', 'Liquid', 'Solid', 'Plasma'],
      correctIndex: 2,
      difficulty: 3,
      topic: 'States of Matter',
      hint: 'This state keeps its shape whether you put it in a cup or leave it on a table.',
      explanation: 'Solids have both a fixed shape and fixed volume. Liquids have fixed volume but no fixed shape. Gases have neither.',
    ),
    ScienceQuestion(
      id: 'bank_phys_013',
      skillId: 'skill_physical_sciences',
      question: 'How does a solar panel produce electricity? ☀️⚡',
      options: [
        'By heating water to turn turbines',
        'By converting light energy from the sun directly into electrical energy',
        'By storing wind energy',
        'By absorbing heat from the ground'
      ],
      correctIndex: 1,
      difficulty: 4,
      topic: 'Energy',
      hint: 'Solar panels use the photovoltaic effect.',
      explanation: 'Solar panels contain photovoltaic cells that convert sunlight (photons) directly into electrical energy (electrons).',
    ),
    ScienceQuestion(
      id: 'bank_phys_014',
      skillId: 'skill_physical_sciences',
      question: 'An astronaut on the Moon weighs LESS than on Earth but has the SAME mass. Why?',
      options: [
        'The Moon has no air',
        'The Moon is smaller and has weaker gravity',
        'Space changes how heavy things are',
        'The astronaut\'s suit weighs less there'
      ],
      correctIndex: 1,
      difficulty: 4,
      topic: 'Forces',
      hint: 'Weight = mass × gravity. The Moon\'s gravity is 1/6 of Earth\'s.',
      explanation: 'Mass is the amount of matter — it never changes. Weight depends on gravity. The Moon has weaker gravity, so the same mass weighs less there.',
    ),
    ScienceQuestion(
      id: 'bank_phys_015',
      skillId: 'skill_physical_sciences',
      question: 'In a hydroelectric power station, what energy conversions take place?',
      options: [
        'Chemical → electrical',
        'Solar → kinetic → electrical',
        'Gravitational potential → kinetic → electrical',
        'Nuclear → thermal → electrical'
      ],
      correctIndex: 2,
      difficulty: 5,
      topic: 'Energy',
      hint: 'Water falls (gravity), spins a turbine (kinetic), then a generator makes electricity.',
      explanation: 'Water at height has gravitational potential energy. Falling converts it to kinetic energy (movement). A turbine+generator converts that to electrical energy.',
    ),

    // ── WEATHER & ENVIRONMENT: difficulty 1–3 ─────────────────────────────────

    ScienceQuestion(
      id: 'bank_env_001',
      skillId: 'skill_earth_sciences',
      question: 'What instrument measures temperature? 🌡️',
      options: ['Barometer', 'Thermometer', 'Ruler', 'Compass'],
      correctIndex: 1,
      difficulty: 1,
      topic: 'Weather',
      hint: 'It has mercury or coloured liquid inside a glass tube.',
      explanation: 'A thermometer measures temperature. In Celsius (°C), water freezes at 0° and boils at 100°.',
    ),
    ScienceQuestion(
      id: 'bank_env_002',
      skillId: 'skill_earth_sciences',
      question: 'What is precipitation? 🌧️',
      options: [
        'Water evaporating from oceans',
        'Water falling from clouds as rain, snow, hail, or sleet',
        'Water condensing into clouds',
        'Sunlight heating the land'
      ],
      correctIndex: 1,
      difficulty: 2,
      topic: 'Weather and Water Cycle',
      hint: 'This is the part of the water cycle where water falls back to Earth.',
      explanation: 'Precipitation is any form of water falling from clouds: rain, snow, hail, sleet, or drizzle.',
    ),
    ScienceQuestion(
      id: 'bank_env_003',
      skillId: 'skill_earth_sciences',
      question: 'What causes a rainbow to form after rain? 🌈',
      options: [
        'Sunlight reflecting off wet roads',
        'Sunlight refracting and reflecting inside rain droplets',
        'Clouds releasing coloured light',
        'Temperature changes in the air'
      ],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Light and Weather',
      hint: 'Each water droplet acts like a tiny prism.',
      explanation: 'Sunlight enters a raindrop, reflects inside, and refracts as it exits — separating white light into its spectrum of colours.',
    ),
    ScienceQuestion(
      id: 'bank_env_004',
      skillId: 'skill_earth_sciences',
      question: 'Why is reducing plastic waste important for ocean ecosystems?',
      options: [
        'Plastic makes the water warmer',
        'Marine animals mistake plastic for food, causing injury and death',
        'Plastic floats and blocks sunlight from the sky',
        'Plastic changes the taste of water'
      ],
      correctIndex: 1,
      difficulty: 3,
      topic: 'Environment',
      hint: 'Think about what sea turtles might mistake a plastic bag for.',
      explanation: 'Marine animals like turtles and seabirds often mistake plastic for food. Ingesting plastic can cause internal injuries or blockages that kill them.',
    ),
    ScienceQuestion(
      id: 'bank_env_005',
      skillId: 'skill_earth_sciences',
      question: 'What is the greenhouse effect?',
      options: [
        'Plants growing more in greenhouses',
        'The sun heating glass buildings',
        'Gases in the atmosphere trapping heat from the Sun',
        'Ozone blocking UV rays'
      ],
      correctIndex: 2,
      difficulty: 3,
      topic: 'Climate',
      hint: 'Some gases in the air act like a warm blanket around Earth.',
      explanation: 'Greenhouse gases (CO₂, methane, water vapour) let sunlight in but trap some heat from escaping back to space, warming Earth\'s surface.',
    ),
  ];

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Returns a shuffled list of questions filtered by [skillId] and [difficulty].
  ///
  /// Allows ±1 difficulty level to ensure enough questions are always returned.
  static List<ScienceQuestion> get({
    required String skillId,
    required int difficulty,
    required int count,
  }) {
    const tolerance = 1;
    final filtered = _all.where((q) {
      final skillMatch = skillId.isEmpty || q.skillId == skillId;
      final diffMatch = (q.difficulty - difficulty).abs() <= tolerance;
      return skillMatch && diffMatch;
    }).toList()
      ..shuffle(_random);

    if (filtered.length >= count) return filtered.take(count).toList();

    // Fall back to all questions for the skill if not enough at this difficulty
    final fallback = _all.where((q) {
      return skillId.isEmpty || q.skillId == skillId;
    }).toList()
      ..shuffle(_random);

    return fallback.take(count).toList();
  }

  /// Returns the total number of questions in the bank.
  static int get totalCount => _all.length;
}
