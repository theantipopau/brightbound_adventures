import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// A [Text] widget whose foreground is painted with a [Gradient].
///
/// Uses [ShaderMask] — no custom painter needed. Works with any [TextStyle]
/// including font family, weight, shadows, etc.
///
/// ```dart
/// GradientText(
///   'Word Woods',
///   gradient: LinearGradient(colors: [Color(0xFF2D7D32), Color(0xFF81C784)]),
///   style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
/// )
///
/// // Convenience factory for zone names:
/// GradientText.zone('Number Nebula', WorldTokens.numberNebula)
/// ```
class GradientText extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  /// Convenience constructor using a [WorldTokens] zone's header gradient.
  factory GradientText.zone(
    String text,
    WorldTokens world, {
    Key? key,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextOverflow? overflow,
  }) =>
      GradientText(
        text,
        key: key,
        gradient: world.headerGradient,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );

  /// Convenience constructor using the app's primary brand gradient.
  factory GradientText.brand(
    String text, {
    Key? key,
    TextStyle? style,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextOverflow? overflow,
  }) =>
      GradientText(
        text,
        key: key,
        gradient: AppGradients.primary,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: (style ?? const TextStyle()).copyWith(
          // ShaderMask's srcIn blends the gradient over the text shape.
          // The text must be opaque white for the gradient to show correctly.
          color: Colors.white,
        ),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
