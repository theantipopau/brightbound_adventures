import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/ui/themes/app_theme.dart';
import 'package:brightbound_adventures/ui/themes/semantic_colors.dart';
import 'package:brightbound_adventures/ui/themes/zone_palettes.dart';
import 'package:brightbound_adventures/ui/themes/shape_tokens.dart';

void main() {
  group('Theme extensions registration', () {
    test('light theme exposes SemanticColors, ZonePalettes, ShapeTokens', () {
      final theme = AppTheme.lightTheme();
      expect(theme.extension<SemanticColors>(), SemanticColors.light);
      expect(theme.extension<ZonePalettes>(), ZonePalettes.light);
      expect(theme.extension<ShapeTokens>(), ShapeTokens.standard);
    });

    test('dark theme exposes SemanticColors, ZonePalettes, ShapeTokens', () {
      final theme = AppTheme.darkTheme();
      expect(theme.extension<SemanticColors>(), SemanticColors.dark);
      expect(theme.extension<ZonePalettes>(), ZonePalettes.dark);
      expect(theme.extension<ShapeTokens>(), ShapeTokens.standard);
    });

    test('light and dark semantic colours are distinct', () {
      expect(SemanticColors.light.textPrimary,
          isNot(SemanticColors.dark.textPrimary));
      expect(SemanticColors.light.surfaceSubtle,
          isNot(SemanticColors.dark.surfaceSubtle),
          reason: 'dark surfaces must be tonally separated, not just alpha '
              'over the light palette');
    });
  });

  group('ZonePalettes.forZone', () {
    test('resolves all 8 zone ids in snake_case', () {
      const zoneIds = [
        'word_woods',
        'number_nebula',
        'math_facts',
        'story_springs',
        'science_explorers',
        'creative_corner',
        'puzzle_peaks',
        'adventure_arena',
      ];
      for (final id in zoneIds) {
        expect(ZonePalettes.light.zones.containsKey(id), isTrue,
            reason: '$id missing from light palette');
        expect(ZonePalettes.dark.zones.containsKey(id), isTrue,
            reason: '$id missing from dark palette');
      }
    });

    test('normalizes kebab-case and mixed input', () {
      final palette = ZonePalettes.light.forZone('word-woods');
      expect(palette, ZonePalettes.light.zones['word_woods']);
    });

    test('falls back to word_woods for unknown zone id', () {
      final palette = ZonePalettes.light.forZone('nonexistent-zone');
      expect(palette, ZonePalettes.light.zones['word_woods']);
    });
  });

  group('BuildContext extensions', () {
    testWidgets(
        'semanticColors/zonePalettes/shapeTokens resolve in a themed tree',
        (tester) async {
      SemanticColors? semantic;
      ZonePalettes? zones;
      ShapeTokens? shape;

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Builder(builder: (context) {
          semantic = context.semanticColors;
          zones = context.zonePalettes;
          shape = context.shapeTokens;
          return const SizedBox();
        }),
      ));

      expect(semantic, SemanticColors.light);
      expect(zones, ZonePalettes.light);
      expect(shape, ShapeTokens.standard);
    });
  });
}
