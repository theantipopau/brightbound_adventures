import 'package:flutter/material.dart';

/// Semantic colours that are correct for their surrounding theme.
///
/// `AppColors` in `app_theme.dart` is a set of fixed constants originally
/// authored for light mode; many screens reference it directly regardless
/// of brightness, which is why dark mode does not have true parity today.
/// New code should read colours from `Theme.of(context).extension<SemanticColors>()`
/// instead, so light and dark each get colours actually designed for them.
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  const SemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.reward,
    required this.onReward,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.correctFeedbackSurface,
    required this.correctFeedbackBorder,
    required this.incorrectFeedbackSurface,
    required this.incorrectFeedbackBorder,
    required this.surfaceSubtle,
    required this.surfaceDisabled,
    required this.divider,
    required this.shadow,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;
  final Color onInfo;
  final Color reward;
  final Color onReward;

  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  final Color correctFeedbackSurface;
  final Color correctFeedbackBorder;
  final Color incorrectFeedbackSurface;
  final Color incorrectFeedbackBorder;

  final Color surfaceSubtle;
  final Color surfaceDisabled;
  final Color divider;
  final Color shadow;

  /// Light-mode values, matching the existing `AppColors` constants so
  /// migrated call sites render identically in light mode.
  static const light = SemanticColors(
    success: Color(0xFF00C853),
    onSuccess: Colors.white,
    warning: Color(0xFFFFAB00),
    onWarning: Colors.black,
    info: Color(0xFF2979FF),
    onInfo: Colors.white,
    reward: Color(0xFFFFD600),
    onReward: Colors.black,
    textPrimary: Color(0xFF1A1B2E),
    textSecondary: Color(0xFF626480),
    textHint: Color(0xFFBBBBCC),
    correctFeedbackSurface: Color(0xFFE8F5E9),
    correctFeedbackBorder: Color(0xFF4CAF50),
    incorrectFeedbackSurface: Color(0xFFFFEBEE),
    incorrectFeedbackBorder: Color(0xFFE53935),
    surfaceSubtle: Color(0xFFF0F0F8),
    surfaceDisabled: Color(0xFFE8E8F0),
    divider: Color(0xFFE0E5F0),
    shadow: Color(0x1F000000),
  );

  /// Dark-mode values: tonal separation on a dark base rather than the
  /// light palette darkened by transparency, per the v2.1 audit's theme
  /// programme (readable surfaces, verified on-colours).
  static const dark = SemanticColors(
    success: Color(0xFF4CD787),
    onSuccess: Colors.black,
    warning: Color(0xFFFFC94D),
    onWarning: Colors.black,
    info: Color(0xFF6EA8FF),
    onInfo: Colors.black,
    reward: Color(0xFFFFE066),
    onReward: Colors.black,
    textPrimary: Color(0xFFF3F4FF),
    textSecondary: Color(0xFFC6C8DC),
    textHint: Color(0xFF8E92AF),
    correctFeedbackSurface: Color(0xFF14351F),
    correctFeedbackBorder: Color(0xFF4CD787),
    incorrectFeedbackSurface: Color(0xFF3A1A1E),
    incorrectFeedbackBorder: Color(0xFFFF6B6B),
    surfaceSubtle: Color(0xFF262A40),
    surfaceDisabled: Color(0xFF32364C),
    divider: Color(0xFF454B66),
    shadow: Color(0x33000000),
  );

  @override
  SemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? reward,
    Color? onReward,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? correctFeedbackSurface,
    Color? correctFeedbackBorder,
    Color? incorrectFeedbackSurface,
    Color? incorrectFeedbackBorder,
    Color? surfaceSubtle,
    Color? surfaceDisabled,
    Color? divider,
    Color? shadow,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      reward: reward ?? this.reward,
      onReward: onReward ?? this.onReward,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      correctFeedbackSurface:
          correctFeedbackSurface ?? this.correctFeedbackSurface,
      correctFeedbackBorder:
          correctFeedbackBorder ?? this.correctFeedbackBorder,
      incorrectFeedbackSurface:
          incorrectFeedbackSurface ?? this.incorrectFeedbackSurface,
      incorrectFeedbackBorder:
          incorrectFeedbackBorder ?? this.incorrectFeedbackBorder,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      surfaceDisabled: surfaceDisabled ?? this.surfaceDisabled,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return SemanticColors(
      success: c(success, other.success),
      onSuccess: c(onSuccess, other.onSuccess),
      warning: c(warning, other.warning),
      onWarning: c(onWarning, other.onWarning),
      info: c(info, other.info),
      onInfo: c(onInfo, other.onInfo),
      reward: c(reward, other.reward),
      onReward: c(onReward, other.onReward),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textHint: c(textHint, other.textHint),
      correctFeedbackSurface:
          c(correctFeedbackSurface, other.correctFeedbackSurface),
      correctFeedbackBorder:
          c(correctFeedbackBorder, other.correctFeedbackBorder),
      incorrectFeedbackSurface:
          c(incorrectFeedbackSurface, other.incorrectFeedbackSurface),
      incorrectFeedbackBorder:
          c(incorrectFeedbackBorder, other.incorrectFeedbackBorder),
      surfaceSubtle: c(surfaceSubtle, other.surfaceSubtle),
      surfaceDisabled: c(surfaceDisabled, other.surfaceDisabled),
      divider: c(divider, other.divider),
      shadow: c(shadow, other.shadow),
    );
  }
}

extension SemanticColorsContext on BuildContext {
  /// Shorthand for `Theme.of(context).extension<SemanticColors>()!`.
  SemanticColors get semanticColors =>
      Theme.of(this).extension<SemanticColors>() ?? SemanticColors.light;
}
