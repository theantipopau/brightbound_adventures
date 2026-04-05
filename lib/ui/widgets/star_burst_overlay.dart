import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A radial star-sparkle burst effect shown as a full-screen overlay.
///
/// Typically used to celebrate a high streak (3+) correct answers.
/// Wraps the caller's widget subtree — just drop it into a `Stack`.
///
/// ```dart
/// Stack(
///   children: [
///     _gameBody,
///     if (_showStarBurst)
///       StarBurstOverlay(
///         color: AppColors.reward,
///         onComplete: () => setState(() => _showStarBurst = false),
///       ),
///   ],
/// )
/// ```
class StarBurstOverlay extends StatefulWidget {
  /// Primary glow colour of the sparkles.
  final Color color;

  /// Number of sparkle arms (each arm gets 3 sparkles at different radii).
  final int armCount;

  /// Total animation duration.
  final Duration duration;

  /// Called when the animation has completed.
  final VoidCallback? onComplete;

  const StarBurstOverlay({
    super.key,
    this.color = const Color(0xFFFFD600),
    this.armCount = 8,
    this.duration = const Duration(milliseconds: 900),
    this.onComplete,
  });

  @override
  State<StarBurstOverlay> createState() => _StarBurstOverlayState();
}

class _StarBurstOverlayState extends State<StarBurstOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => CustomPaint(
          painter: _StarBurstPainter(
            progress: _controller.value,
            color: widget.color,
            armCount: widget.armCount,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _StarBurstPainter extends CustomPainter {
  final double progress;
  final Color color;
  final int armCount;

  static final _rng = math.Random(42);
  // Pre-generate per-arm offsets so they're stable across repaints.
  static final List<double> _phaseOffsets =
      List.generate(24, (_) => _rng.nextDouble() * math.pi * 2);
  static final List<double> _sizeFactors =
      List.generate(24, (_) => 0.5 + _rng.nextDouble() * 0.8);

  const _StarBurstPainter({
    required this.progress,
    required this.color,
    required this.armCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) * 0.42;

    // Ease-out the expansion; fade out during the last 30%
    final expandT = Curves.easeOut.transform(math.min(progress / 0.7, 1.0));
    final alpha = progress < 0.6 ? 1.0 : 1.0 - (progress - 0.6) / 0.4;

    for (int arm = 0; arm < armCount; arm++) {
      final baseAngle = (arm / armCount) * math.pi * 2;

      // 3 sparkles per arm at different radii (33%, 66%, 100%)
      for (int ring = 0; ring < 3; ring++) {
        final ringFraction = (ring + 1) / 3.0;
        final radius = maxR * ringFraction * expandT;
        final sparkleIdx = arm * 3 + ring;
        final phaseOff = _phaseOffsets[sparkleIdx % _phaseOffsets.length];
        final sizeFactor = _sizeFactors[sparkleIdx % _sizeFactors.length];

        // Slight angle jitter per ring
        final angle = baseAngle + phaseOff * 0.18 * (ring + 1);
        final pos = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);

        // Sparkle size — grows then shrinks with progress
        final sparkleSize = 4.0 * sizeFactor * (1.0 - math.pow(progress, 1.5).toDouble()) + 1.0;

        _drawSparkle(canvas, pos, sparkleSize, color.withValues(alpha: alpha), angle);
      }
    }

    // Central flash — bright circle that fades quickly
    if (progress < 0.35) {
      final flashAlpha = (1.0 - progress / 0.35) * 0.45;
      final flashR = maxR * 0.18 * progress / 0.35;
      canvas.drawCircle(
        center,
        flashR,
        Paint()
          ..color = Colors.white.withValues(alpha: flashAlpha)
          ..style = PaintingStyle.fill,
      );
    }
  }

  /// 4-pointed star sparkle.
  void _drawSparkle(Canvas canvas, Offset center, double size, Color c, double rotation) {
    if (size <= 0) return;
    final paint = Paint()
      ..color = c
      ..style = PaintingStyle.fill;

    // Glow halo
    canvas.drawCircle(
      center,
      size * 1.4,
      Paint()
        ..color = c.withValues(alpha: c.a * 0.35)
        ..style = PaintingStyle.fill,
    );

    // 4-pointed star using 2 narrow diamond paths rotated 45° from each other
    for (int i = 0; i < 2; i++) {
      final rot = rotation + i * math.pi / 4;
      final path = Path();
      final tips = size;
      final waist = size * 0.18;

      path.moveTo(
          center.dx + math.cos(rot) * tips, center.dy + math.sin(rot) * tips);
      path.lineTo(
          center.dx + math.cos(rot + math.pi / 2) * waist,
          center.dy + math.sin(rot + math.pi / 2) * waist);
      path.lineTo(
          center.dx + math.cos(rot + math.pi) * tips,
          center.dy + math.sin(rot + math.pi) * tips);
      path.lineTo(
          center.dx + math.cos(rot - math.pi / 2) * waist,
          center.dy + math.sin(rot - math.pi / 2) * waist);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StarBurstPainter old) =>
      old.progress != progress || old.color != color;
}
