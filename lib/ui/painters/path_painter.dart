import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';

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
    for (int i = 0; i < zones.length - 1; i++) {
      final start = zoneScreenPositions[zones[i].id]!;
      final end = zoneScreenPositions[zones[i + 1].id]!;

      final isUnlocked = totalStars >= zones[i + 1].requiredStars;

      // Draw path
      final pathPaint = Paint()
        ..color = (isUnlocked ? Colors.amber : Colors.grey).withOpacity(isUnlocked ? 0.6 : 0.3)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Create curved path (adjusted for iso perspective)
      final path = Path();
      path.moveTo(start.dx, start.dy);

      // Midpoint for curve control
      final midX = (start.dx + end.dx) / 2;
      final midY = (start.dy + end.dy) / 2;

      // Lift the curve up for visual depth
      final controlX = midX;
      final controlY = midY - 30;

      path.quadraticBezierTo(controlX, controlY, end.dx, end.dy);

      // Draw solid path
      canvas.drawPath(path, pathPaint);

      // Draw animated dots on unlocked paths (particle effect)
      if (isUnlocked) {
        final dotPaint = Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.fill;

        final pathMetrics = path.computeMetrics().first;
        final progress = (animation.value + i * 0.2) % 1.0;
        final pos = pathMetrics.getTangentForOffset(
          pathMetrics.length * progress,
        )?.position;

        if (pos != null) {
          canvas.drawCircle(pos, 6, dotPaint);
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
