// WCAG contrast audit for SemanticColors (VS-1's design tokens) and the
// app's canvas backgrounds, per prompt.md's design-system requirement:
// "Check meaningful text/icon combinations against WCAG contrast
// expectations. Include the measured ratios in the audit or test output
// where feasible."
//
// This computes real contrast ratios using the standard WCAG relative
// luminance formula (no external package needed) and asserts each pair
// against the appropriate WCAG 2.1 AA threshold:
//   - 4.5:1 for normal body/label text
//   - 3:1 for large text and non-text UI component boundaries (borders)
// It prints every measured ratio so the numbers are visible in test
// output/CI logs, not just asserted silently.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// WCAG 2.1 relative luminance: https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
///
/// `Color.r`/`.g`/`.b` return normalised 0.0-1.0 doubles in this Flutter
/// version (the sRGB channel value), which is exactly what the WCAG
/// formula expects — no /255 conversion needed.
double _relativeLuminance(Color color) {
  double linearize(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

  final r = linearize(color.r);
  final g = linearize(color.g);
  final b = linearize(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double _contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  const lightBackground = Color(0xFFF8F9FE); // AppColors.background
  const darkBackground = Color(0xFF131625); // AppTheme's darkBackground

  void checkPair({
    required String label,
    required Color foreground,
    required Color background,
    required double minRatio,
  }) {
    final ratio = _contrastRatio(foreground, background);
    // ignore: avoid_print
    print('$label: ${ratio.toStringAsFixed(2)}:1 (needs >= $minRatio:1)');
    expect(ratio, greaterThanOrEqualTo(minRatio), reason: label);
  }

  group('SemanticColors.light contrast (normal text, AA 4.5:1)', () {
    test('measured ratios', () {
      checkPair(
        label: 'textPrimary on background',
        foreground: SemanticColors.light.textPrimary,
        background: lightBackground,
        minRatio: 4.5,
      );
      checkPair(
        label: 'textSecondary on background',
        foreground: SemanticColors.light.textSecondary,
        background: lightBackground,
        minRatio: 4.5,
      );
      checkPair(
        label: 'textPrimary on surfaceSubtle',
        foreground: SemanticColors.light.textPrimary,
        background: SemanticColors.light.surfaceSubtle,
        minRatio: 4.5,
      );
    });
  });

  group('SemanticColors.dark contrast (normal text, AA 4.5:1)', () {
    test('measured ratios', () {
      checkPair(
        label: 'textPrimary on background',
        foreground: SemanticColors.dark.textPrimary,
        background: darkBackground,
        minRatio: 4.5,
      );
      checkPair(
        label: 'textSecondary on background',
        foreground: SemanticColors.dark.textSecondary,
        background: darkBackground,
        minRatio: 4.5,
      );
      checkPair(
        label: 'textPrimary on surfaceSubtle',
        foreground: SemanticColors.dark.textPrimary,
        background: SemanticColors.dark.surfaceSubtle,
        minRatio: 4.5,
      );
    });
  });

  group('SemanticColors on-colour pairs (UI component text, AA 4.5:1)', () {
    test('light', () {
      checkPair(
        label: 'onSuccess on success',
        foreground: SemanticColors.light.onSuccess,
        background: SemanticColors.light.success,
        minRatio: 4.5,
      );
      checkPair(
        label: 'onWarning on warning',
        foreground: SemanticColors.light.onWarning,
        background: SemanticColors.light.warning,
        minRatio: 4.5,
      );
      checkPair(
        label: 'onInfo on info',
        foreground: SemanticColors.light.onInfo,
        background: SemanticColors.light.info,
        minRatio: 4.5,
      );
      checkPair(
        label: 'onReward on reward',
        foreground: SemanticColors.light.onReward,
        background: SemanticColors.light.reward,
        minRatio: 4.5,
      );
    });

    test('dark', () {
      checkPair(
        label: 'onSuccess on success',
        foreground: SemanticColors.dark.onSuccess,
        background: SemanticColors.dark.success,
        minRatio: 4.5,
      );
      checkPair(
        label: 'onWarning on warning',
        foreground: SemanticColors.dark.onWarning,
        background: SemanticColors.dark.warning,
        minRatio: 4.5,
      );
      checkPair(
        label: 'onInfo on info',
        foreground: SemanticColors.dark.onInfo,
        background: SemanticColors.dark.info,
        minRatio: 4.5,
      );
      checkPair(
        label: 'onReward on reward',
        foreground: SemanticColors.dark.onReward,
        background: SemanticColors.dark.reward,
        minRatio: 4.5,
      );
    });
  });

  group('Feedback border/surface pairs (non-text UI boundary, AA 3:1)', () {
    test('light', () {
      checkPair(
        label: 'correctFeedbackBorder on correctFeedbackSurface',
        foreground: SemanticColors.light.correctFeedbackBorder,
        background: SemanticColors.light.correctFeedbackSurface,
        minRatio: 3.0,
      );
      checkPair(
        label: 'incorrectFeedbackBorder on incorrectFeedbackSurface',
        foreground: SemanticColors.light.incorrectFeedbackBorder,
        background: SemanticColors.light.incorrectFeedbackSurface,
        minRatio: 3.0,
      );
    });

    test('dark', () {
      checkPair(
        label: 'correctFeedbackBorder on correctFeedbackSurface',
        foreground: SemanticColors.dark.correctFeedbackBorder,
        background: SemanticColors.dark.correctFeedbackSurface,
        minRatio: 3.0,
      );
      checkPair(
        label: 'incorrectFeedbackBorder on incorrectFeedbackSurface',
        foreground: SemanticColors.dark.incorrectFeedbackBorder,
        background: SemanticColors.dark.incorrectFeedbackSurface,
        minRatio: 3.0,
      );
    });
  });

  group('textHint (informational only — WCAG sets no AA floor for hint text)',
      () {
    test('measured ratios, not asserted', () {
      final lightRatio =
          _contrastRatio(SemanticColors.light.textHint, lightBackground);
      final darkRatio =
          _contrastRatio(SemanticColors.dark.textHint, darkBackground);
      // ignore: avoid_print
      print('textHint on background (light): '
          '${lightRatio.toStringAsFixed(2)}:1 (informational, no AA floor)');
      // ignore: avoid_print
      print('textHint on background (dark): '
          '${darkRatio.toStringAsFixed(2)}:1 (informational, no AA floor)');
    });
  });

  // 2026-10-09 game-feel/contrast pass: the live build measured the quiz
  // feedback pill at ~2.9:1 (white on green.shade500) and the avatar
  // banner hint fell below 3:1 for pale character accents. These pairs
  // pin the replacement colours so the pills can't drift back to the
  // mid-tone ramps.
  group('Quiz feedback pill text (AA 4.5:1, normal-size text)', () {
    test('correct pill (green ramp — numeracy/literacy gradients)', () {
      const white = Colors.white; // what the pills actually render
      checkPair(
        label: 'white msg on green.shade900',
        foreground: white,
        background: Colors.green.shade900,
        minRatio: 4.5,
      );
      checkPair(
        label: 'white msg on teal.shade800',
        foreground: white,
        background: Colors.teal.shade800,
        minRatio: 4.5,
      );
      checkPair(
        label: 'gold +XP on green.shade900',
        foreground: Colors.yellow.shade200,
        background: Colors.green.shade900,
        minRatio: 4.5,
      );
      checkPair(
        label: 'gold +XP on teal.shade800',
        foreground: Colors.yellow.shade200,
        background: Colors.teal.shade800,
        minRatio: 4.5,
      );
      checkPair(
        label: 'explanation on green.shade900',
        foreground: const Color(0xFFFFF6E8),
        background: Colors.green.shade900,
        minRatio: 4.5,
      );
    });

    test('correct pill — science solid green.shade900', () {
      checkPair(
        label: 'white msg on green.shade900 (solid)',
        foreground: Colors.white,
        background: Colors.green.shade900,
        minRatio: 4.5,
      );
      checkPair(
        label: 'pale-gold +XP on green.shade900',
        foreground: const Color(0xFFFFF1A8),
        background: Colors.green.shade900,
        minRatio: 4.5,
      );
    });

    test('wrong pill (red/orange ramp)', () {
      const white = Colors.white;
      checkPair(
        label: 'white msg on red.shade900',
        foreground: white,
        background: Colors.red.shade900,
        minRatio: 4.5,
      );
      checkPair(
        label: 'white msg on deepOrange.shade900',
        foreground: white,
        background: Colors.deepOrange.shade900,
        minRatio: 4.5,
      );
      checkPair(
        label: 'explanation on red.shade900',
        foreground: const Color(0xFFFFF6E8),
        background: Colors.red.shade900,
        minRatio: 4.5,
      );
    });

    test('feedback Continue button / Why? label on light & dark surfaces', () {
      // These buttons live on surface-coloured cards, which flip dark at
      // night. They now use the theme's onSurface ink, so the pairs below
      // document that pairing's worst cases: M3 light onSurface on a white
      // card, and white on the app's darkest surface.
      checkPair(
        label: 'light-theme onSurface on white surface',
        foreground: const Color(0xFF1D1B20),
        background: const Color(0xFFFFFFFF),
        minRatio: 4.5,
      );
      checkPair(
        label: 'dark-theme onSurface on darkest surface',
        foreground: Colors.white,
        background: const Color(0xFF000000),
        minRatio: 4.5,
      );
    });
  });

  group('Avatar banner text on the always-light ExtrudedCard face (4.5:1)', () {
    test('pinned ink over the worst-case character tint', () {
      // Face = white lerped with the character accent at the gradient's
      // 0.10 stop; pure-black is one of the character colours, so that is
      // the darkest face the banner can produce.
      final worstFace = Color.lerp(
        const Color(0xFFFFFFFF),
        const Color(0xFF000000),
        0.10,
      )!;
      checkPair(
        label: 'textPrimary name on worst-case banner face',
        foreground: AppColors.textPrimary,
        background: worstFace,
        minRatio: 4.5,
      );
      checkPair(
        label: 'textSecondary hint on worst-case banner face',
        foreground: AppColors.textSecondary,
        background: worstFace,
        minRatio: 4.5,
      );
    });
  });

  // 2026-10-09: quiz-chip labels and 18 px results stats use
  // InkTokens.onTint so bright accents (teal, amber, success green, warm
  // zone colours) take dark ink on their near-white tint instead of the
  // failing accent-on-tint pairs the live build measured (teal ≈ 2.7:1,
  // success ≈ 2.2:1 on white).
  group('InkTokens.onTint over accent tints (AA 4.5:1)', () {
    test('worst bright accents, on tint and on white', () {
      final accents = <String, Color>{
        'success green': SemanticColors.light.success,
        'teal': Colors.teal,
        'amber': Colors.amber,
        'zone orange': Colors.deepOrange,
        'zone red': Colors.red,
      };
      accents.forEach((name, accent) {
        final ink = InkTokens.onTint(accent);
        final chipBg = Color.lerp(const Color(0xFFFFFFFF), accent, 0.15)!;
        checkPair(
          label: 'onTint($name) on its 15% tint',
          foreground: ink,
          background: chipBg,
          minRatio: 4.5,
        );
        checkPair(
          label: 'onTint($name) on white (results stats)',
          foreground: ink,
          background: const Color(0xFFFFFFFF),
          minRatio: 4.5,
        );
      });
    });
  });

  // 2026-10-10: zone-detail Recommended card + results Back buttons. The
  // card paints gradient [primary, secondary] with InkTokens.on(primary)
  // ink; bright red/deep-orange secondaries used to drag black ink to
  // 3.9:1 at the far corner, so the ramp's end stop is capped by
  // InkTokens.lerpWithinInkFloor. Pins cover both real stops of the
  // rendered ramp for all 8 zones, and the results-screen flips.
  group('Zone card gradient ink (AA 4.5:1, both stops of the rendered ramp)',
      () {
    test('WorldTokens.all primary/secondary stops with card ink', () {
      for (final world in WorldTokens.all) {
        final ink = InkTokens.on(world.primaryColor);
        final endStop = InkTokens.lerpWithinInkFloor(
          world.primaryColor,
          world.secondaryColor,
        );
        checkPair(
          label: 'card ink on primary (${world.zoneId})',
          foreground: ink,
          background: world.primaryColor,
          minRatio: 4.5,
        );
        checkPair(
          label: 'card ink on gradient end (${world.zoneId})',
          foreground: ink,
          background: endStop,
          minRatio: 4.5,
        );
      }
    });
  });

  // Avatar-creator name-status chip (AA 4.5:1). The old inks — raw
  // success-green (#00C853 ≈ 2:1) and orange.shade800 (≈ 3.4:1) on the
  // 12% tinted chip, grey.shade700 counter in dark mode — all missed AA
  // for this small text, so the chip now uses theme-aware inks pinned
  // here against the same lerp composites the widget paints.
  group('Avatar name-status chip inks (AA 4.5:1, both modes)', () {
    const success = Color(0xFF00C853);
    const lightOk = Color(0xFF0B6B32);
    const lightPending = Color(0xFF8D4E00);
    const lightBase = Color(0xFFFFFFFF);
    const darkBase = Color(0xFF131625); // AppTheme's darkBackground

    test('measured ratios', () {
      checkPair(
        label: 'chip ok ink on light success tint',
        foreground: lightOk,
        background: Color.lerp(lightBase, success, 0.12)!,
        minRatio: 4.5,
      );
      checkPair(
        label: 'chip pending ink on light orange tint',
        foreground: lightPending,
        background: Color.lerp(lightBase, Colors.orange, 0.12)!,
        minRatio: 4.5,
      );
      checkPair(
        label: 'chip ok ink on dark success tint',
        foreground: SemanticColors.dark.success,
        background: Color.lerp(darkBase, success, 0.12)!,
        minRatio: 4.5,
      );
      checkPair(
        label: 'chip pending ink on dark orange tint',
        foreground: SemanticColors.dark.warning,
        background: Color.lerp(darkBase, Colors.orange, 0.12)!,
        minRatio: 4.5,
      );
      checkPair(
        label: 'chip counter on light orange tint',
        foreground: SemanticColors.light.textSecondary,
        background: Color.lerp(lightBase, Colors.orange, 0.12)!,
        minRatio: 4.5,
      );
      checkPair(
        label: 'chip counter on dark orange tint',
        foreground: SemanticColors.dark.textSecondary,
        background: Color.lerp(darkBase, Colors.orange, 0.12)!,
        minRatio: 4.5,
      );
    });

    // Large display headlines use WCAG's 3:1 large-text bar instead of
    // 4.5:1 (all pinned text here is ≥20px bold).
    test('welcome gradient ends on the light step tint', () {
      final stepTint = Color.lerp(lightBase, const Color(0xFFFF4081), 0.15)!;
      checkPair(
        label: 'gradient start (primaryDark) on step tint',
        foreground: const Color(0xFFC51162),
        background: stepTint,
        minRatio: 3.0,
      );
      checkPair(
        label: 'gradient end (secondary) on step tint',
        foreground: const Color(0xFF7C4DFF),
        background: stepTint,
        minRatio: 3.0,
      );
    });
  });

  group('Science results screen flips (AA 4.5:1)', () {
    test('Back-to-Zone: ink on solid themeColor fill', () {
      final science = WorldTokens.fromZoneId('science_explorers');
      checkPair(
        label: 'on(science theme) on science Back fill',
        foreground: InkTokens.on(science.primaryColor),
        background: science.primaryColor,
        minRatio: 4.5,
      );
    });

    test('result chips: onTint ink on the 12% accent pill', () {
      final accents = <String, Color>{
        'green': Colors.green,
        'amber700': Colors.amber.shade700,
        'science theme':
            WorldTokens.fromZoneId('science_explorers').primaryColor,
      };
      accents.forEach((name, accent) {
        checkPair(
          label: 'onTint($name) on its 12% chip tint',
          foreground: InkTokens.onTint(accent),
          background: Color.lerp(const Color(0xFFFFFFFF), accent, 0.12)!,
          minRatio: 4.5,
        );
      });
    });
  });
}
