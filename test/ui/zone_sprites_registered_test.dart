import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const zones = [
    'word-woods',
    'number-nebula',
    'math-facts',
    'story-springs',
    'science-explorers',
    'creative-corner',
    'puzzle-peaks',
    'adventure-arena',
  ];

  test('every zone has its four authored sprites registered in the bundle',
      () async {
    for (final zone in zones) {
      for (final kind in ['tile_base', 'landmark', 'path', 'accent']) {
        final path =
            'assets/images/zones/$zone/zone_${zone}_$kind.webp';
        final data =
            await rootBundle.load(path.replaceFirst('assets/', 'assets/'));
        expect(data.lengthInBytes, greaterThan(0), reason: path);
      }
    }
  });

  test('dust puff effect frames are registered (A8 landing feedback)',
      () async {
    final frame1 = await rootBundle
        .load('assets/images/zones/effects/zone_dust_puff_1.webp');
    final frame2 = await rootBundle
        .load('assets/images/zones/effects/zone_dust_puff_2.webp');
    expect(frame1.lengthInBytes, greaterThan(0));
    expect(frame2.lengthInBytes, greaterThan(0));
  });
}
