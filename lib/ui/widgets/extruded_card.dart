import 'package:flutter/material.dart';

/// Wraps a card so it reads as a *physical* slab lying on the surface —
/// the "storybook board-game diorama" cue from the v2.1 3D direction spec
/// (docs/V2_1_3D_VISUAL_DIRECTION.md §6 A3D-6/A3D-7), applied to question
/// cards, feedback panels and preview banners.
///
/// Renders, back to front:
///  1. an extruded **side face** — the same rounded rect shifted [depth] px
///     down, shaded darker than [accent] with a top-left → bottom-right
///     light falloff (light hits the left end of the side first);
///  2. a soft ambient-occlusion shadow beneath the whole slab;
///  3. the [child] card face on top.
///
/// Every colour is *derived* from [accent] via HSL, so this file holds no
/// direct `Color(0x…)`/`Colors.*` literals (see the colour inventory test).
class ExtrudedCard extends StatelessWidget {
  const ExtrudedCard({
    super.key,
    required this.accent,
    required this.child,
    this.depth = 6,
    this.radius = const BorderRadius.all(Radius.circular(20)),
    this.shadowStrength = 0.28,
  });

  /// Identity colour of the card; the side face is a darkened derivation.
  final Color accent;

  /// The card face. Must paint its own background/border (opaque) so the
  /// extruded side reads as its thickness.
  final Widget child;

  /// How far the side face peeks out below the card (logical px).
  final double depth;

  /// Corner radius of the *child* card, mirrored by the side face.
  final BorderRadius radius;

  /// Alpha of the ambient-occlusion shadow under the slab.
  final double shadowStrength;

  Color get _side {
    final hsl = HSLColor.fromColor(accent);
    return hsl
        .withLightness((hsl.lightness * 0.42).clamp(0.2, 0.45))
        .withSaturation((hsl.saturation * 1.05).clamp(0.0, 1.0))
        .toColor();
  }

  Color get _sideDark {
    final hsl = HSLColor.fromColor(_side);
    return hsl.withLightness((hsl.lightness * 0.72).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    // Reserve [depth] below the face so the extruded side paints inside
    // our own box instead of bleeding 6px into the next card in a Column.
    return Padding(
      padding: EdgeInsets.only(bottom: depth),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: depth,
            bottom: -depth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_side, _sideDark],
                ),
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: _side.withValues(alpha: shadowStrength),
                    blurRadius: 14,
                    offset: Offset(0, depth + 4),
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// One-shot "punch-in" entrance: scale + fade with a springy overshoot,
/// used when a feedback banner or result appears so outcomes *land* instead
/// of popping in flat. Animates once when the widget is inserted; updates to
/// an existing child do not re-trigger it. Under reduced motion it renders
/// the child statically.
///
/// Contains no colours of its own — safe for files at their colour ceiling.
class PunchIn extends StatelessWidget {
  const PunchIn({
    super.key,
    required this.child,
    this.fromScale = 0.92,
    this.duration = const Duration(milliseconds: 350),
  });

  final Widget child;
  final double fromScale;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, t, child) {
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: fromScale + (1 - fromScale) * t,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
