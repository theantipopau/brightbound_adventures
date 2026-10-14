import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// A4 gate: every audio asset AudioManager expects must actually ship in
/// the bundle, so gameplay falls back to haptics only for genuinely new
/// sounds rather than something the artist forgot to add.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const expected = <String>[
    'assets/sounds/sfx/correct/correct1.wav',
    'assets/sounds/sfx/correct/correct2.wav',
    'assets/sounds/sfx/correct/correct3.wav',
    'assets/sounds/sfx/incorrect/wrong1.wav',
    'assets/sounds/sfx/incorrect/wrong2.wav',
    'assets/sounds/sfx/celebration/perfect.wav',
    'assets/sounds/sfx/celebration/streak3.wav',
    'assets/sounds/sfx/celebration/streak5.wav',
    'assets/sounds/sfx/celebration/streak10.wav',
    'assets/sounds/sfx/celebration/levelup.wav',
    'assets/sounds/sfx/celebration/unlock.wav',
    'assets/sounds/sfx/ui/click.wav',
    'assets/sounds/sfx/ui/whoosh.wav',
    'assets/sounds/sfx/ui/popup.wav',
    'assets/sounds/music/menu.wav',
    'assets/sounds/music/splash.wav',
  ];

  const zones = <String>[
    'word_woods',
    'number_nebula',
    'math_facts',
    'story_springs',
    'science_explorers',
    'creative_corner',
    'puzzle_peaks',
    'adventure_arena',
  ];

  test('all core SFX are bundled', () async {
    for (final path in expected) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
  });

  test('all eight zones ship ambient loops', () async {
    for (final zone in zones) {
      final path = 'assets/sounds/music/zones/$zone.wav';
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
  });
}
