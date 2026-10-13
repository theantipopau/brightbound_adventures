import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/utils/board_path.dart';

/// Animated path painter connecting zones with particle effects
///
/// Optimizations:
/// - Accepts precomputed screen positions to avoid repeated coordinate conversions
/// - Uses an [Animation<double>] as the repaint listenable so the framework
///   repaints this painter when the animation ticks (no need to rebuild parent)
class PathPainter extends CustomPainter {
  final List<ZoneData> zones;
  final Map<String, Offset> zoneScreenPositions;
  final Animation<double> animation;
  final int totalStars;

  PathPainter({
    required this.zones,
    required this.zoneScreenPositions,
    required this.animation,
    required this.totalStars,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Route geometry is shared with the pawn that walks the board
    // (BoardPath), so the painted track and the character always agree.
    final boardPath = BoardPath.fromPositions([
      for (final zone in zones) zoneScreenPositions[zone.id]!,
    ]);

    for (int i = 0; i < boardPath.segmentCount; i++) {
      final segment = boardPath.segments[i];
      final isUnlocked = totalStars >= zones[i + 1].requiredStars;

      // Curved hop between islands (adjusted for iso perspective).
      final path = Path()
        ..moveTo(segment.start.dx, segment.start.dy)
        ..quadraticBezierTo(
          segment.control.dx,
          segment.control.dy,
          segment.end.dx,
          segment.end.dy,
        );

      // Draw path with stronger contrast and readability.
      final bounds = path.getBounds();
      final pathPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isUnlocked
              ? [
                  const Color(0xFFFFE082).withValues(alpha: 0.95),
                  const Color(0xFFFFB300).withValues(alpha: 0.9),
                ]
              : [
                  Colors.grey.shade500.withValues(alpha: 0.7),
                  Colors.grey.shade400.withValues(alpha: 0.6),
                ],
        ).createShader(bounds)
        ..strokeWidth = isUnlocked ? 12 : 10
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      if (isUnlocked) {
        final glowPaint = Paint()
          ..color = Colors.amber.withValues(alpha: 0.28)
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawPath(path, glowPaint);
      }

      canvas.drawPath(path, pathPaint);

      // Draw animated dots on unlocked paths (particle effect)
      if (isUnlocked) {
        final dotPaint = Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.fill;

        final pathMetrics = path.computeMetrics().first;
        final progress = (animation.value + i * 0.2) % 1.0;
        final pos = pathMetrics
            .getTangentForOffset(
              pathMetrics.length * progress,
            )
            ?.position;

        if (pos != null) {
          // Small drop shadow (light from top-left, so it falls bottom-right)
          // plus a top-left highlight, giving the travel dot a glossy,
          // 3D "bead" look instead of a flat filled circle.
          canvas.drawCircle(
            pos + const Offset(1.5, 2),
            6,
            Paint()
              ..color = Colors.black.withValues(alpha: 0.18)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
          );
          canvas.drawCircle(
              pos, 10, dotPaint..color = Colors.amber.withValues(alpha: 0.35));
          canvas.drawCircle(pos, 6, dotPaint..color = Colors.amber);
          canvas.drawCircle(
            pos + const Offset(-1.5, -1.5),
            2,
            Paint()..color = Colors.white.withValues(alpha: 0.55),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    // Animation drives repaint via the repaint listenable. Only repaint if
    // non-animated state changes (e.g., unlocking a new path).
    return oldDelegate.totalStars != totalStars ||
        oldDelegate.zoneScreenPositions.length != zoneScreenPositions.length;
  }
}
