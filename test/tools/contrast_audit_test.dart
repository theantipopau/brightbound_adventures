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
}
