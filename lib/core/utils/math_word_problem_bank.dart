import 'dart:math';

/// Massively expanded question templates for math word problems
/// 100+ unique question scenarios with real-world contexts
class MathWordProblemBank {
  static final Random _random = Random();

  // Shopping scenarios - Australian context
  static final shoppingScenarios = [
    {'item': '🍎 apples', 'verb': 'bought', 'unit': 'each'},
    {'item': '🥧 meat pies', 'verb': 'bought', 'unit': 'from the bakery'},
    {'item': '🎈 balloons', 'verb': 'got for a party', 'unit': 'total'},
    {'item': '🎁 presents', 'verb': 'wrapped', 'unit': 'boxes'},
    {'item': '🌸 flowers', 'verb': 'picked', 'unit': 'from the garden'},
    {'item': '⭐ stickers', 'verb': 'earned', 'unit': 'sheets'},
    {'item': '📚 books', 'verb': 'read', 'unit': 'this week'},
    {'item': '🧁 lamingtons', 'verb': 'baked', 'unit': 'for the fête'},
    {'item': '🎨 crayons', 'verb': 'collected', 'unit': 'from the art box'},
    {'item': '🍫 Tim Tams', 'verb': 'bought', 'unit': 'packets'},
  ];

  // Adventure scenarios
  static final adventureScenarios = [
    {
      'character': 'Maya',
      'action': 'climbed',
      'object': 'trees',
      'emoji': '🌳'
    },
    {'character': 'Liam', 'action': 'caught', 'object': 'fish', 'emoji': '🐟'},
    {
      'character': 'Zara',
      'action': 'collected',
      'object': 'seashells',
      'emoji': '🐚'
    },
    {
      'character': 'Finn',
      'action': 'built',
      'object': 'sandcastles',
      'emoji': '🏰'
    },
    {
      'character': 'Ruby',
      'action': 'spotted',
      'object': 'butterflies',
      'emoji': '🦋'
    },
    {
      'character': 'Noah',
      'action': 'drew',
      'object': 'pictures',
      'emoji': '🎨'
    },
    {'character': 'Ava', 'action': 'planted', 'object': 'seeds', 'emoji': '🌱'},
    {
      'character': 'Oliver',
      'action': 'made',
      'object': 'paper airplanes',
      'emoji': '✈️'
    },
    {
      'character': 'Emma',
      'action': 'folded',
      'object': 'origami cranes',
      'emoji': '🦢'
    },
    {
      'character': 'Lucas',
      'action': 'kicked',
      'object': 'soccer goals',
      'emoji': '⚽'
    },
  ];

  // Time-based scenarios
  static final timeScenarios = [
    {'event': 'practice piano', 'duration': 'minutes', 'time': 'afternoon'},
    {'event': 'play outside', 'duration': 'hours', 'time': 'after school'},
    {'event': 'read a story', 'duration': 'pages', 'time': 'before bed'},
    {'event': 'do homework', 'duration': 'problems', 'time': 'evening'},
    {'event': 'bake cookies', 'duration': 'minutes in oven', 'time': 'weekend'},
    {'event': 'watch a movie', 'duration': 'minutes', 'time': 'Friday night'},
    {'event': 'help with chores', 'duration': 'tasks', 'time': 'Saturday'},
    {'event': 'play a game', 'duration': 'rounds', 'time': 'game night'},
    {'event': 'ride a bike', 'duration': 'laps around park', 'time': 'morning'},
    {
      'event': 'paint a picture',
      'duration': 'colours used',
      'time': 'art class'
    },
  ];

  // Sharing scenarios
  static final sharingScenarios = [
    {
      'item': '🍕 pizza slices',
      'people': 'friends',
      'occasion': 'birthday party'
    },
    {'item': '🍬 candies', 'people': 'siblings', 'occasion': 'Halloween'},
    {
      'item': '🎮 game controllers',
      'people': 'players',
      'occasion': 'game tournament'
    },
    {'item': '🖍️ markers', 'people': 'classmates', 'occasion': 'art project'},
    {'item': '🍿 popcorn', 'people': 'friends', 'occasion': 'movie night'},
    {'item': '🧊 ice cubes', 'people': 'glasses', 'occasion': 'picnic'},
    {'item': '🎵 songs', 'people': 'playlist', 'occasion': 'road trip'},
    {'item': '⚽ balls', 'people': 'teams', 'occasion': 'sports day'},
    {'item': '📖 chapters', 'people': 'days', 'occasion': 'reading challenge'},
    {'item': '🌟 points', 'people': 'levels', 'occasion': 'video game'},
  ];

  // Collection scenarios
  static final collectionScenarios = [
    {'item': '🦖 dinosaur cards', 'place': 'toy store'},
    {'item': '🚂 train stickers', 'place': 'train museum'},
    {'item': '🌈 rainbow gems', 'place': 'treasure hunt'},
    {'item': '🎭 theater tickets', 'place': 'show'},
    {'item': '🏆 trophies', 'place': 'competitions'},
    {'item': '🎪 carnival tickets', 'place': 'fair'},
    {'item': '🎸 guitar picks', 'place': 'music shop'},
    {'item': '🦄 unicorn stamps', 'place': 'post office'},
    {'item': '🌺 flower stamps', 'place': 'garden club'},
    {'item': '🧸 teddy bears', 'place': 'toy drive'},
  ];

  // Generate addition word problem
  static String generateAddition(int a, int b, String difficulty) {
    if (difficulty == 'easy') {
      final scenario =
          shoppingScenarios[_random.nextInt(shoppingScenarios.length)];
      return 'You ${scenario['verb']} $a ${scenario['item']}. Then you ${scenario['verb']} $b more. How many do you have now?';
    } else if (difficulty == 'medium') {
      final adventure =
          adventureScenarios[_random.nextInt(adventureScenarios.length)];
      return '${adventure['character']} ${adventure['action']} $a ${adventure['object']} ${adventure['emoji']} in the morning and $b more in the afternoon. How many ${adventure['object']} did ${adventure['character']} ${adventure['action']} in total?';
    } else {
      final share = sharingScenarios[_random.nextInt(sharingScenarios.length)];
      return 'At the ${share['occasion']}, there were $a ${share['item']} on one table and $b ${share['item']} on another table. How many ${share['item']} were there in total?';
    }
  }

  // Generate subtraction word problem
  static String generateSubtraction(int a, int b, String difficulty) {
    if (difficulty == 'easy') {
      final scenario =
          shoppingScenarios[_random.nextInt(shoppingScenarios.length)];
      return 'You had $a ${scenario['item']}. You gave away $b. How many do you have left?';
    } else if (difficulty == 'medium') {
      final adventure =
          adventureScenarios[_random.nextInt(adventureScenarios.length)];
      return '${adventure['character']} started with $a ${adventure['object']} ${adventure['emoji']}. ${adventure['character']} gave $b to a friend. How many ${adventure['object']} does ${adventure['character']} have now?';
    } else {
      final time = timeScenarios[_random.nextInt(timeScenarios.length)];
      return 'You need to ${time['event']} for $a ${time['duration']}. You already did $b ${time['duration']}. How many more ${time['duration']} do you need?';
    }
  }

  // Generate multiplication word problem
  static String generateMultiplication(int a, int b, String difficulty) {
    if (difficulty == 'medium') {
      final share = sharingScenarios[_random.nextInt(sharingScenarios.length)];
      return 'Each of $a ${share['people']} gets $b ${share['item']}. How many ${share['item']} do you need in total?';
    } else {
      final collection =
          collectionScenarios[_random.nextInt(collectionScenarios.length)];
      return 'You bought $a packs of ${collection['item']} from the ${collection['place']}. Each pack has $b items. How many ${collection['item']} do you have?';
    }
  }

  // Generate division word problem
  static String generateDivision(int dividend, int divisor, String difficulty) {
    if (difficulty == 'medium') {
      final share = sharingScenarios[_random.nextInt(sharingScenarios.length)];
      return 'You have $dividend ${share['item']} to share equally among $divisor ${share['people']}. How many does each person get?';
    } else {
      final adventure =
          adventureScenarios[_random.nextInt(adventureScenarios.length)];
      return '${adventure['character']} has $dividend ${adventure['object']} ${adventure['emoji']} and wants to put them in $divisor equal groups. How many in each group?';
    }
  }

  // Generate measurement word problem
  static String generateMeasurement(int amount, String unit) {
    final scenarios = [
      'A recipe needs $amount cups of flour. How much flour do you need?',
      'Your room is $amount feet long. How long is your room?',
      'You walked $amount miles today. How far did you walk?',
      'The fish tank holds $amount liters. How much water does it hold?',
      'Your backpack weighs $amount pounds. How heavy is your backpack?',
      'The tree is $amount meters tall. How tall is the tree?',
      'You drank $amount glasses of water. How much water did you drink?',
      'The rope is $amount inches long. How long is the rope?',
      'Your dog weighs $amount kilograms. How heavy is your dog?',
      'The race is $amount kilometers. How far is the race?',
    ];
    return scenarios[_random.nextInt(scenarios.length)];
  }

  // Generate money word problem
  static String generateMoney(int cents, String difficulty) {
    final dollars = cents ~/ 100;
    final remainingCents = cents % 100;

    final items = [
      '🍦 ice cream cone',
      '🎮 game',
      '🧸 toy',
      '📚 book',
      '🎨 art supplies',
      '⚽ soccer ball',
      '🎸 guitar pick',
      '🎭 ticket',
    ];

    final item = items[_random.nextInt(items.length)];

    if (difficulty == 'easy') {
      return 'A $item costs $dollars dollar${dollars != 1 ? 's' : ''}. How much does it cost?';
    } else {
      return 'A $item costs \$$dollars.$remainingCents. You have \$${dollars + 5}. How much change will you get?';
    }
  }

  // Generate comparison word problem
  static String generateComparison(int a, int b, String difficulty) {
    final comparisons = [
      'Emma has $a ${shoppingScenarios[0]['item']} and Liam has $b. Who has more?',
      'Team A scored $a points and Team B scored $b points. Which team won?',
      'Monday it was $a° and Tuesday it was $b°. Which day was warmer?',
      'Book A has $a pages and Book B has $b pages. Which book is longer?',
      'Plant A grew $a inches and Plant B grew $b inches. Which grew taller?',
      'Route A is $a miles and Route B is $b miles. Which route is shorter?',
      'Box A weighs $a pounds and Box B weighs $b pounds. Which is heavier?',
      'Song A is $a minutes and Song B is $b minutes. Which song is longer?',
      'Tower A has $a blocks and Tower B has $b blocks. Which tower is taller?',
      'Jar A has $a candies and Jar B has $b candies. Which jar has fewer?',
    ];
    return comparisons[_random.nextInt(comparisons.length)];
  }
}
