import 'package:brightbound_adventures/features/literacy/models/question.dart';

/// Question bank for Creative Corner zone.
///
/// All questions reuse `LiteracyQuestion` since Creative Corner practice
/// uses the same `MultipleChoiceGame` widget as Word Woods.
class CreativeCornerQuestions {
  // ── Colours & Shapes ─────────────────────────────────────────────────────

  static const List<LiteracyQuestion> visualArts = [
    // Difficulty 1 – primary colours
    LiteracyQuestion(
      id: 'cc_va_1',
      skillId: 'skill_visual_arts',
      question: 'Which of these is a PRIMARY colour?',
      options: ['Green', 'Orange', 'Blue', 'Purple'],
      correctIndex: 2,
      hint: 'Primary colours cannot be made by mixing other colours.',
      explanation:
          'The three primary colours are red, blue, and yellow. Green, orange, and purple are secondary colours made by mixing two primaries.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_va_2',
      skillId: 'skill_visual_arts',
      question: 'What colour do you get when you mix red and yellow?',
      options: ['Purple', 'Orange', 'Green', 'Brown'],
      correctIndex: 1,
      hint: 'Think of a fruit that is this colour!',
      explanation:
          'Red + Yellow = Orange. Orange is a secondary colour formed by mixing two primary colours.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_va_3',
      skillId: 'skill_visual_arts',
      question: 'What colour do you get when you mix blue and yellow?',
      options: ['Purple', 'Orange', 'Green', 'Pink'],
      correctIndex: 2,
      hint: 'Think of the colour of grass and leaves.',
      explanation:
          'Blue + Yellow = Green. Green is a secondary colour made from two primary colours.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_va_4',
      skillId: 'skill_visual_arts',
      question: 'Which shape has THREE sides?',
      options: ['Square', 'Circle', 'Triangle', 'Rectangle'],
      correctIndex: 2,
      hint: 'The word "triangle" starts with "tri" meaning three.',
      explanation:
          'A triangle has 3 sides and 3 corners. "Tri" is a prefix meaning three.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_va_5',
      skillId: 'skill_visual_arts',
      question: 'Which of these is a WARM colour?',
      options: ['Blue', 'Green', 'Red', 'Purple'],
      correctIndex: 2,
      hint: 'Think of fire and the sun.',
      explanation:
          'Warm colours (red, orange, yellow) remind us of fire and sunlight. Cool colours (blue, green, purple) feel calming like water.',
      difficulty: 1,
    ),
    // Difficulty 2
    LiteracyQuestion(
      id: 'cc_va_6',
      skillId: 'skill_visual_arts',
      question: 'What colour do you get when you mix red and blue?',
      options: ['Orange', 'Green', 'Brown', 'Purple'],
      correctIndex: 3,
      hint: 'This is the colour of lavender flowers.',
      explanation:
          'Red + Blue = Purple. Purple is a secondary colour made from red and blue.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_va_7',
      skillId: 'skill_visual_arts',
      question: 'Which shape has FOUR equal sides?',
      options: ['Rectangle', 'Square', 'Rhombus', 'Both B and C'],
      correctIndex: 3,
      hint: 'A square and a rhombus both have four equal sides, but different angles.',
      explanation:
          'A square has 4 equal sides AND 4 right angles. A rhombus has 4 equal sides but the angles are not all right angles.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_va_8',
      skillId: 'skill_visual_arts',
      question: 'Which of these is a COOL colour?',
      options: ['Yellow', 'Orange', 'Blue', 'Red'],
      correctIndex: 2,
      hint: 'Think of the colour of the ocean.',
      explanation:
          'Cool colours include blue, green, and purple. They remind us of water, sky, and ice.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_va_9',
      skillId: 'skill_visual_arts',
      question: 'A pentagon has how many sides?',
      options: ['4', '5', '6', '8'],
      correctIndex: 1,
      hint: '"Penta" is a Greek prefix meaning five.',
      explanation:
          'A pentagon has 5 sides. A hexagon has 6, an octagon has 8.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_va_10',
      skillId: 'skill_visual_arts',
      question: 'What is the word for the flat surface an artist paints on?',
      options: ['Palette', 'Easel', 'Canvas', 'Sketch'],
      correctIndex: 2,
      hint: 'It is stretched fabric or a board that holds the painting.',
      explanation:
          'A canvas is the surface an artist paints on. A palette holds the paints, and an easel holds the canvas upright.',
      difficulty: 2,
    ),
    // Difficulty 3
    LiteracyQuestion(
      id: 'cc_va_11',
      skillId: 'skill_visual_arts',
      question:
          'Colours opposite each other on the colour wheel are called _____ colours.',
      options: ['Warm', 'Cool', 'Complementary', 'Primary'],
      correctIndex: 2,
      hint: 'Red and green, blue and orange are examples.',
      explanation:
          'Complementary colours sit opposite each other on the colour wheel. Placed next to each other, they create strong contrast.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'cc_va_12',
      skillId: 'skill_visual_arts',
      question: 'Adding white to a colour creates a _____.',
      options: ['Shade', 'Tint', 'Tone', 'Hue'],
      correctIndex: 1,
      hint: 'Think of pastel pink — red + white.',
      explanation:
          'A tint is made by adding white. A shade is made by adding black. A tone is made by adding grey.',
      difficulty: 3,
    ),
  ];

  // ── Rhythm & Music ──────────────────────────────────────────────────────

  static const List<LiteracyQuestion> music = [
    LiteracyQuestion(
      id: 'cc_mu_1',
      skillId: 'skill_music',
      question: 'Which of these instruments belongs to the PERCUSSION family?',
      options: ['Flute', 'Violin', 'Drum', 'Trumpet'],
      correctIndex: 2,
      hint: 'Percussion instruments are played by hitting or shaking.',
      explanation:
          'Percussion instruments make sound by being hit or shaken. Drums, tambourines, and xylophones are percussion.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_mu_2',
      skillId: 'skill_music',
      question: 'Which word describes a SLOW tempo in music?',
      options: ['Allegro', 'Forte', 'Largo', 'Piano'],
      correctIndex: 2,
      hint: 'Imagine slow, flowing music.',
      explanation:
          '"Largo" means a very slow tempo. "Allegro" means fast. "Forte" means loud, and "Piano" means soft.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_mu_3',
      skillId: 'skill_music',
      question: 'The BEAT in music is best described as:',
      options: [
        'The words of a song',
        'The steady pulse you can clap along to',
        'The highest note',
        'The name of the song',
      ],
      correctIndex: 1,
      hint: 'You can feel it in your hands when you clap.',
      explanation:
          'The beat is the steady pulse in music — like a heartbeat. It is what you tap your foot or clap along to.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_mu_4',
      skillId: 'skill_music',
      question: 'How many notes are in a musical scale (do, re, mi...)?',
      options: ['5', '7', '8', '12'],
      correctIndex: 2,
      hint: 'Do Re Mi Fa Sol La Ti — and then Do again.',
      explanation:
          'A standard major scale has 8 notes (Do Re Mi Fa Sol La Ti Do) — 7 unique pitches plus the octave note.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_mu_5',
      skillId: 'skill_music',
      question: 'Which of these is a STRING instrument?',
      options: ['Tuba', 'Flute', 'Cello', 'Snare Drum'],
      correctIndex: 2,
      hint: 'It uses a bow drawn across strings.',
      explanation:
          'String instruments make sound with vibrating strings. Violin, cello, guitar, and harp are string instruments.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_mu_6',
      skillId: 'skill_music',
      question: 'What does FORTE mean in music?',
      options: ['Soft', 'Fast', 'Loud', 'Slow'],
      correctIndex: 2,
      hint: 'When you see "f" in sheet music, play this way.',
      explanation:
          '"Forte" (f) means to play loudly. "Piano" (p) means softly. Together they are called dynamics.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_mu_7',
      skillId: 'skill_music',
      question: 'Which family of instruments includes the clarinet and oboe?',
      options: ['Brass', 'Strings', 'Woodwind', 'Percussion'],
      correctIndex: 2,
      hint: 'These instruments were originally made of wood.',
      explanation:
          'Woodwind instruments use air blown through a reed or a mouthpiece — clarinet, oboe, flute, and bassoon.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_mu_8',
      skillId: 'skill_music',
      question:
          'What is the name of the lines and spaces where musical notes are written?',
      options: ['Clef', 'Staff', 'Tempo', 'Rest'],
      correctIndex: 1,
      hint: 'Music is written on a set of five horizontal lines.',
      explanation:
          'The staff (or stave) is the set of five horizontal lines and four spaces used to write music notation.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_mu_9',
      skillId: 'skill_music',
      question:
          'A piece of music in 4/4 time has how many beats per bar?',
      options: ['2', '3', '4', '6'],
      correctIndex: 2,
      hint: 'The top number in the time signature tells you.',
      explanation:
          'In 4/4 time, there are 4 beats per bar. It\'s the most common time signature and is sometimes called "common time".',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'cc_mu_10',
      skillId: 'skill_music',
      question: 'What is a group of musicians playing together called?',
      options: ['Choir', 'Ensemble', 'Duet', 'Solo'],
      correctIndex: 1,
      hint: 'A smaller group than an orchestra.',
      explanation:
          'An ensemble is a group of musicians playing together. A duet is two players. A choir sings. A soloist performs alone.',
      difficulty: 2,
    ),
  ];

  // ── Elements of Art ─────────────────────────────────────────────────────

  static const List<LiteracyQuestion> artElements = [
    LiteracyQuestion(
      id: 'cc_ae_1',
      skillId: 'skill_art_elements',
      question:
          'Which element of art describes the way something FEELS or looks like it would feel?',
      options: ['Colour', 'Line', 'Texture', 'Shape'],
      correctIndex: 2,
      hint: 'Rough, smooth, bumpy — these are all types of this element.',
      explanation:
          'Texture describes the surface quality of an artwork — how it feels or appears to feel. It can be real (actual texture) or implied (visual texture).',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_ae_2',
      skillId: 'skill_art_elements',
      question: 'Which element of art refers to the EMPTY areas around objects?',
      options: ['Texture', 'Negative space', 'Line', 'Value'],
      correctIndex: 1,
      hint: 'Think of the space between objects in a drawing.',
      explanation:
          'Negative space is the area around and between subjects. Positive space is the subject itself.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_ae_3',
      skillId: 'skill_art_elements',
      question: 'In art, VALUE refers to:',
      options: [
        'How much a painting costs',
        'The lightness or darkness of a colour',
        'The number of colours used',
        'The size of the artwork',
      ],
      correctIndex: 1,
      hint: 'Shadows are dark, highlights are light.',
      explanation:
          'Value is the range from light to dark. Artists use value to create depth, form, and mood in their artwork.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_ae_4',
      skillId: 'skill_art_elements',
      question:
          'A three-dimensional object like a sphere or cube is called a _____ in art.',
      options: ['Shape', 'Form', 'Line', 'Space'],
      correctIndex: 1,
      hint: 'It has height, width, AND depth.',
      explanation:
          'Form is 3-dimensional (has depth). A shape is 2-dimensional (flat). A circle is a shape; a sphere is a form.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_ae_5',
      skillId: 'skill_art_elements',
      question:
          'An artwork where the same element repeats to create a pattern is showing:',
      options: ['Balance', 'Rhythm', 'Contrast', 'Proportion'],
      correctIndex: 1,
      hint: 'Like a beat in music, it creates a visual "beat".',
      explanation:
          'Rhythm in art is created by the repetition of elements (colour, shape, line). It leads the viewer\'s eye through the artwork.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_ae_6',
      skillId: 'skill_art_elements',
      question:
          'The principle that makes some things look bigger or more important than others is:',
      options: ['Texture', 'Emphasis', 'Balance', 'Line'],
      correctIndex: 1,
      hint: 'Artists create a focal point using this principle.',
      explanation:
          'Emphasis is the principle that makes one area of an artwork stand out. Artists use size, colour, or contrast to create a focal point.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'cc_ae_7',
      skillId: 'skill_art_elements',
      question:
          'When opposite sides of an artwork look the same, it is called:',
      options: ['Emphasis', 'Contrast', 'Symmetrical balance', 'Variety'],
      correctIndex: 2,
      hint: 'A butterfly\'s wings are a natural example.',
      explanation:
          'Symmetrical (or formal) balance means both sides mirror each other. Asymmetrical balance means both sides are different but still feel balanced.',
      difficulty: 2,
    ),
  ];

  // ── Creative Expression ──────────────────────────────────────────────────

  static const List<LiteracyQuestion> creativeExpression = [
    LiteracyQuestion(
      id: 'cc_ce_1',
      skillId: 'skill_creative_expression',
      question:
          '"The stars were diamonds in the sky." — This sentence is an example of a:',
      options: ['Simile', 'Metaphor', 'Alliteration', 'Rhyme'],
      correctIndex: 1,
      hint: 'It says the stars ARE diamonds — not that they are LIKE diamonds.',
      explanation:
          'A metaphor directly says one thing IS another (stars = diamonds). A simile uses "like" or "as" to compare.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_ce_2',
      skillId: 'skill_creative_expression',
      question: '"Her smile was like sunshine." — This is a:',
      options: ['Metaphor', 'Simile', 'Rhyme', 'Onomatopoeia'],
      correctIndex: 1,
      hint: 'It uses "like" to compare two things.',
      explanation:
          'A simile compares two things using "like" or "as". "Her smile was like sunshine" compares a smile to sunshine.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_ce_3',
      skillId: 'skill_creative_expression',
      question:
          '"The buzzing bees brought the bright blooms to life." This is an example of:',
      options: ['Metaphor', 'Onomatopoeia', 'Alliteration', 'Simile'],
      correctIndex: 2,
      hint: 'Every word starts with the same letter.',
      explanation:
          'Alliteration is the repetition of the same starting consonant sound in close words. "Buzzing bees brought bright blooms" repeats the "b" sound.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_ce_4',
      skillId: 'skill_creative_expression',
      question:
          '"The door creaked. The floorboards groaned." The words "creaked" and "groaned" are examples of:',
      options: ['Simile', 'Alliteration', 'Onomatopoeia', 'Metaphor'],
      correctIndex: 2,
      hint: 'These words sound like the sounds they describe.',
      explanation:
          'Onomatopoeia is when a word sounds like the thing it describes — creaked, groaned, buzz, crunch, splash.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_ce_5',
      skillId: 'skill_creative_expression',
      question:
          'Which is the BEST adjective to describe a very dark, stormy night?',
      options: ['Nice', 'Ominous', 'Happy', 'Colourful'],
      correctIndex: 1,
      hint: 'This word means threatening or suggesting something bad will happen.',
      explanation:
          '"Ominous" means suggesting something bad is coming — perfect for a dark, stormy night. Strong adjectives make writing vivid.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_ce_6',
      skillId: 'skill_creative_expression',
      question:
          'Giving human qualities to animals or objects is called:',
      options: ['Metaphor', 'Personification', 'Alliteration', 'Imagery'],
      correctIndex: 1,
      hint: '"The wind whispered secrets" — the wind can\'t really whisper.',
      explanation:
          'Personification gives human traits or actions to non-human things. It makes writing more vivid and relatable.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'cc_ce_7',
      skillId: 'skill_creative_expression',
      question: 'A poem where each line starts with a letter that spells a word is called:',
      options: ['Haiku', 'Limerick', 'Acrostic', 'Sonnet'],
      correctIndex: 2,
      hint: 'Each line\'s first letter spells out a word down the page.',
      explanation:
          'An acrostic poem has the first letter of each line spelling a word or message vertically.',
      difficulty: 3,
    ),
  ];

  // ── Famous Artists ───────────────────────────────────────────────────────

  static const List<LiteracyQuestion> famousArtists = [
    LiteracyQuestion(
      id: 'cc_fa_1',
      skillId: 'skill_famous_artists',
      question: 'Who painted the famous "Starry Night"?',
      options: ['Pablo Picasso', 'Vincent van Gogh', 'Leonardo da Vinci', 'Claude Monet'],
      correctIndex: 1,
      hint: 'This Dutch artist used swirling, bold brushstrokes.',
      explanation:
          'Vincent van Gogh painted "The Starry Night" in 1889. It is famous for its expressive swirling sky and bright stars.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_fa_2',
      skillId: 'skill_famous_artists',
      question: 'The "Mona Lisa" was painted by which famous artist?',
      options: ['Michelangelo', 'Raphael', 'Leonardo da Vinci', 'Salvador Dalí'],
      correctIndex: 2,
      hint: 'He was also a scientist, engineer, and inventor.',
      explanation:
          'Leonardo da Vinci painted the Mona Lisa around 1503–1519. It is displayed in the Louvre Museum in Paris.',
      difficulty: 1,
    ),
    LiteracyQuestion(
      id: 'cc_fa_3',
      skillId: 'skill_famous_artists',
      question:
          'Which artist is known for paintings of water lilies and his garden in Giverny?',
      options: ['Georges Seurat', 'Paul Cézanne', 'Claude Monet', 'Pierre-Auguste Renoir'],
      correctIndex: 2,
      hint: 'He was a founder of the Impressionist movement in France.',
      explanation:
          'Claude Monet painted his famous Water Lilies series in his garden at Giverny. He is one of the founders of Impressionism.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_fa_4',
      skillId: 'skill_famous_artists',
      question:
          'Cubism — breaking objects into geometric shapes — is most associated with which artist?',
      options: ['Vincent van Gogh', 'Pablo Picasso', 'Andy Warhol', 'Jackson Pollock'],
      correctIndex: 1,
      hint: 'He co-founded this movement with Georges Braque.',
      explanation:
          'Pablo Picasso co-founded Cubism with Georges Braque. Cubist artworks show multiple viewpoints of an object at the same time.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_fa_5',
      skillId: 'skill_famous_artists',
      question:
          'Which Australian Indigenous art form uses dots to create patterns and maps of country?',
      options: [
        'Batik',
        'Western Desert dot painting',
        'Pointillism',
        'Watercolour',
      ],
      correctIndex: 1,
      hint:
          'It originated in Central Australia in the early 1970s at Papunya.',
      explanation:
          'Western Desert dot painting (acrylic dot painting) became prominent in the 1970s at Papunya in the Northern Territory. It represents Dreamtime stories using dot patterns.',
      difficulty: 2,
    ),
    LiteracyQuestion(
      id: 'cc_fa_6',
      skillId: 'skill_famous_artists',
      question: 'Which art movement does Salvador Dalí belong to?',
      options: ['Impressionism', 'Pop Art', 'Surrealism', 'Realism'],
      correctIndex: 2,
      hint: 'Think of melting clocks and dreamlike scenes.',
      explanation:
          'Salvador Dalí was a leading Surrealist. Surrealism created dreamlike, often strange images inspired by dreams and the unconscious mind.',
      difficulty: 3,
    ),
    LiteracyQuestion(
      id: 'cc_fa_7',
      skillId: 'skill_famous_artists',
      question:
          'Andy Warhol is known as a leader of which 1960s art movement using popular culture images?',
      options: ['Cubism', 'Pop Art', 'Abstract Expressionism', 'Renaissance'],
      correctIndex: 1,
      hint: 'Think of colourful Campbell\'s soup cans and Marilyn Monroe prints.',
      explanation:
          'Andy Warhol was a leading figure of Pop Art, which used imagery from popular culture — advertising, celebrities, and everyday objects.',
      difficulty: 3,
    ),
  ];

  // ── Public API ────────────────────────────────────────────────────────────

  static List<LiteracyQuestion> getBySkillId(String skillId, {int difficulty = 1}) {
    final all = {
      'skill_visual_arts': visualArts,
      'skill_music': music,
      'skill_art_elements': artElements,
      'skill_creative_expression': creativeExpression,
      'skill_famous_artists': famousArtists,
    }[skillId] ?? famousArtists;

    final filtered = all.where((q) => q.difficulty <= difficulty + 1).toList();
    return filtered.isEmpty ? all : filtered;
  }

  static List<LiteracyQuestion> getByDifficulty(String skillId, int difficulty) {
    return getBySkillId(skillId, difficulty: difficulty);
  }
}
