import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Parallax camera layers for the world map (v2.1 task A1).
///
/// Three depth bands move at different rates under camera pan:
///   layer 0 — sky/haze            multiplier 0.15 (slow drift)
///   layer 1 — midground islands   multiplier 0.40 (moderate drift)
///   layer 2 — foreground board    multiplier 1.00 (the existing map, drawn
///             by the existing painters and untouched here)
///
/// The widget accepts the live camera pan offset and back-offsets each
/// background layer by `offset × multiplier`, so background content drifts
/// visibly slower than the foreground. Drift is clamped upstream to the
/// subtle maximum from the visual direction spec (~12 px).
///
/// Reduced motion: when `MediaQuery.disableAnimations` is true all bands
/// render with zero offset — the map becomes a static composition.
class ParallaxMapLayer extends StatelessWidget {
  /// Live camera pan offset (in logical px) driving the drift.
  final Offset panOffset;

  /// Multiplier for the sky/haze band.
  final double hazeMultiplier;

  /// Multiplier for the midground band.
  final double midgroundMultiplier;

  /// Optional gradient override for the haze band (tests).
  final Gradient? hazeGradient;

  /// Number of soft cloud puffs drawn in the midground band.
  final int cloudCount;

  const ParallaxMapLayer({
    super.key,
    this.panOffset = Offset.zero,
    this.hazeMultiplier = 0.15,
    this.midgroundMultiplier = 0.40,
    this.hazeGradient,
    this.cloudCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disabled) {
      // Reduced motion: static haze, no midground drift, no clouds puffing.
      return _HazeLayer(
        offset: Offset.zero,
        gradient: hazeGradient,
      );
    }

    final hazeOffset = Offset(
      (panOffset.dx * hazeMultiplier).clamp(-12.0, 12.0),
      (panOffset.dy * hazeMultiplier * 0.5).clamp(-8.0, 8.0),
    );
    final midgroundOffset = Offset(
      (panOffset.dx * midgroundMultiplier).clamp(-12.0, 12.0),
      (panOffset.dy * midgroundMultiplier * 0.5).clamp(-8.0, 8.0),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: _HazeLayer(offset: hazeOffset, gradient: hazeGradient),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _MidgroundCloudPainter(
                offset: midgroundOffset,
                cloudCount: cloudCount,
              ),
              // The cloud band drifts with the camera every frame.
              willChange: true,
            ),
          ),
        ),
      ],
    );
  }
}

/// Layer 0 — the soft sky/haze wash behind the whole board.
class _HazeLayer extends StatelessWidget {
  final Offset offset;
  final Gradient? gradient;

  const _HazeLayer({required this.offset, this.gradient});

  @override
  Widget build(BuildContext context) {
    final shader = gradient ??
        const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFBFE8FF),
            Color(0xFFE3F6FF),
            Color(0xFFF6EFFF),
          ],
        );
    return Transform.translate(
      offset: offset,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: shader),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Layer 1 — soft volumetric cloud puffs drifting in the midground band.
class _MidgroundCloudPainter extends CustomPainter {
  final Offset offset;
  final int cloudCount;

  static const List<Color> _cloudColors = [
    Color(0x66FFFFFF),
    Color(0x59FFFFFF),
    Color(0x4DFFFFFF),
  ];

  _MidgroundCloudPainter({required this.offset, required this.cloudCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (cloudCount <= 0 || size.isEmpty) return;
    final rng = math.Random(7); // deterministic layout — no per-frame churn
    for (var i = 0; i < cloudCount; i++) {
      final baseX = size.width * (0.08 + 0.84 * (i / cloudCount.clamp(1, 99)));
      final baseY = size.height * (0.10 + 0.34 * rng.nextDouble());
      final radius = size.shortestSide * (0.05 + 0.05 * rng.nextDouble());
      final centre = Offset(baseX, baseY) + offset;

      final paint = Paint()
        ..color = _cloudColors[i % _cloudColors.length]
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

      // Three overlapping puffs per cloud for a chunky, rounded silhouette.
      canvas.drawCircle(centre, radius, paint);
      canvas.drawCircle(centre.translate(-radius * 0.8, radius * 0.25),
          radius * 0.7, paint);
      canvas.drawCircle(centre.translate(radius * 0.75, radius * 0.3),
          radius * 0.65, paint);
    }
  }

  @override
  bool shouldRepaint(_MidgroundCloudPainter oldDelegate) =>
      oldDelegate.offset != offset || oldDelegate.cloudCount != cloudCount;
}
