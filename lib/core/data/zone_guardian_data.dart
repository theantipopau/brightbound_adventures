/// Zone guardian NPCs — each zone has a named character who sets the quest,
/// gives encouragement, and celebrates with the player on completion.
class ZoneGuardian {
  final String zoneId;
  final String name;
  final String emoji;
  final String title;
  final String questHook;
  final List<String> encouragements;
  final String completeMessage;
  final String color; // hex string, used for theming the banner
  /// Short celebration messages shown when the player finishes a skill session
  /// (distinct from the full zone-complete message).
  final List<String> skillCompleteMessages;

  const ZoneGuardian({
    required this.zoneId,
    required this.name,
    required this.emoji,
    required this.title,
    required this.questHook,
    required this.encouragements,
    required this.completeMessage,
    required this.color,
    this.skillCompleteMessages = const [],
  });

  /// Returns a pseudo-random skill-complete message keyed by [sessionIndex].
  String skillCompleteMessage(int sessionIndex) {
    if (skillCompleteMessages.isEmpty) return completeMessage;
    return skillCompleteMessages[sessionIndex % skillCompleteMessages.length];
  }
}

const Map<String, ZoneGuardian> zoneGuardians = {
  'word_woods': ZoneGuardian(
    zoneId: 'word_woods',
    name: 'Quill',
    emoji: '🦉',
    title: 'Guardian of Word Woods',
    questHook:
        'Oh brave adventurer! The Word Woods have gone silent — all the letters are hiding! '
        'Help me find them and bring the stories back to life!',
    encouragements: [
      'Brilliant spelling! The forest glows!',
      'Yes! The words are coming back!',
      'You\'re a reading champion!',
      'The Word Woods thank you!',
      'Fantastic! Keep going!',
    ],
    completeMessage:
        'You\'ve restored the Word Woods! 🌲 The stories are alive again! '
        'Quill is very proud of you!',
    color: '#4CAF50',
    skillCompleteMessages: [
      'A new word mastered! The forest grows! 🌿',
      'Quill hoots with delight — brilliant work!',
      'That skill is now part of your story! 📖',
      'Every word you learn makes Word Woods brighter!',
      'Well done, word wizard! Keep going! 🦉',
    ],
  ),
  'number_nebula': ZoneGuardian(
    zoneId: 'number_nebula',
    name: 'Luna',
    emoji: '🌙',
    title: 'Star Keeper of Number Nebula',
    questHook:
        'Hello, young star-counter! My numbers have scattered across the galaxy! '
        'Can you help me gather them before the stars go dark tonight?',
    encouragements: [
      'Stellar maths! ⭐',
      'You\'re a number superstar!',
      'The stars are aligning!',
      'Incredible calculation!',
      'You\'re lighting up the nebula!',
    ],
    completeMessage:
        'The Number Nebula shines bright again! 🌌 Luna does a happy moon-dance. '
        'Your maths powers are out of this world!',
    color: '#3F51B5',
    skillCompleteMessages: [
      'Another number conquered! The stars align! ⭐',
      'Luna records your score in the star chart!',
      'Your mental maths is galactic! 🚀',
      'That skill is in orbit — brilliant!',
      'Luna beams: maths champion incoming! 🌙',
    ],
  ),
  'puzzle_peaks': ZoneGuardian(
    zoneId: 'puzzle_peaks',
    name: 'Rocky',
    emoji: '🏔️',
    title: 'Keeper of Puzzle Peaks',
    questHook:
        'Ho there, young thinker! The ancient riddles of Puzzle Peaks have been '
        'jumbled by a mischievous storm. Lend me your big brain to sort them out!',
    encouragements: [
      'Super thinking! 🧠',
      'You cracked it! Rocky cheers!',
      'That puzzled even me! Well done!',
      'Your logic is unstoppable!',
      'Another puzzle solved!',
    ],
    completeMessage:
        'Puzzle Peaks stands proud once more! 🏔️ Rocky roars with joy! '
        'Your problem-solving skills are legendary!',
    color: '#FF9800',
    skillCompleteMessages: [
      'That puzzle piece clicks into place! 🧩',
      'Rocky stamps the summit with your name!',
      'Logic like that could move mountains! ⛰️',
      'Brilliant solving — the peak grows taller!',
      'Rocky cheers: one more piece of genius! 🏔️',
    ],
  ),
  'story_springs': ZoneGuardian(
    zoneId: 'story_springs',
    name: 'Pip',
    emoji: '🐸',
    title: 'Tale-Teller of Story Springs',
    questHook:
        'Ribbit! Our story springs have run dry and all the tales have dried up! '
        'Jump in and help me bring the adventures back — every word counts!',
    encouragements: [
      'Wonderful story sense! 🌊',
      'The springs are flowing again!',
      'Ribbit! That was brilliant!',
      'You\'re a natural storyteller!',
      'Pip is hopping with joy!',
    ],
    completeMessage:
        'Story Springs flow beautifully once more! 🌊 Pip leaps for joy! '
        'Your imagination is amazing — never stop telling stories!',
    color: '#00BCD4',
    skillCompleteMessages: [
      'Ribbit! Another chapter written! 🐸',
      'Your story sense is flowing like a river!',
      'Pip splashes with joy — great comprehension!',
      'The springs sing your name! 🎵',
      'Wonderful! Every tale you read makes you stronger!',
    ],
  ),
  'adventure_arena': ZoneGuardian(
    zoneId: 'adventure_arena',
    name: 'Bolt',
    emoji: '⚡',
    title: 'Champion of Adventure Arena',
    questHook:
        'Hey, champion! The Adventure Arena needs its fastest, sharpest athlete. '
        'Show me your speed and skill — every move matters here!',
    encouragements: [
      'Lightning fast! ⚡',
      'Perfect move, champion!',
      'You\'re unstoppable!',
      'Bolt is impressed!',
      'Keep charging ahead!',
    ],
    completeMessage:
        'Adventure Arena applauds its new champion! ⚡ Bolt gives you a high-five! '
        'Your coordination and speed are incredible!',
    color: '#F44336',
    skillCompleteMessages: [
      'Speed AND accuracy — you\'re electric! ⚡',
      'Bolt marks your personal best on the scoreboard!',
      'Champion move! The arena roars! 🏟️',
      'That performance was lightning fast!',
      'Bolt nods: the making of a legend! 🥇',
    ],
  ),
  'science_explorers': ZoneGuardian(
    zoneId: 'science_explorers',
    name: 'Spark',
    emoji: '🔬',
    title: 'Chief Explorer of Science Station',
    questHook:
        'Greetings, young scientist! My experiments need a brilliant mind to '
        'check the results. Science discoveries await — shall we investigate together?',
    encouragements: [
      'Excellent hypothesis! 🔬',
      'Spark\'s instruments are beeping with joy!',
      'Brilliant scientific thinking!',
      'You\'re a true explorer!',
      'Discovery after discovery!',
    ],
    completeMessage:
        'Science Station rings with success! 🧪 Spark says: "You have the makings '
        'of a great scientist!" The discovery log is complete!',
    color: '#9C27B0',
    skillCompleteMessages: [
      'Discovery logged! Spark stamps your lab book! 🔬',
      'Hypothesis confirmed — brilliant work!',
      'Science skills levelling up! 📈',
      'Spark\'s experiments agree: you\'re a natural!',
      'Another fact unlocked for the science archives! 🧪',
    ],
  ),
  'creative_corner': ZoneGuardian(
    zoneId: 'creative_corner',
    name: 'Doodle',
    emoji: '🎨',
    title: 'Artist-in-Chief of Creative Corner',
    questHook:
        'Oh, what wonderful timing! My canvas is blank — the colours have '
        'run away! Help me fill the Creative Corner with brilliant ideas again!',
    encouragements: [
      'Masterpiece! 🎨',
      'Doodle loves your creativity!',
      'Pure imagination!',
      'You\'re an artistic genius!',
      'The canvas comes to life!',
    ],
    completeMessage:
        'Creative Corner glows with colour! 🎨 Doodle does a little paint-splatter '
        'happy dance. Your creativity knows no bounds!',
    color: '#E91E63',
    skillCompleteMessages: [
      'Stroke of genius — Doodle\'s brush flies! 🎨',
      'Creative powers growing with every session!',
      'Your ideas light up the canvas! ✨',
      'Doodle applauds your artistic mind!',
      'Another masterpiece skill added! 🖌️',
    ],
  ),
};

/// Returns the guardian for a given zone, or null if none defined.
ZoneGuardian? guardianForZone(String zoneId) {
  // Normalise to underscore format
  final key = zoneId.replaceAll('-', '_').toLowerCase();
  return zoneGuardians[key];
}
