import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/utils/world_map_isometric_helper.dart';

/// Animated path painter connecting zones with particle effects
class PathPainter extends CustomPainter {
  final List<ZoneData> zones;
  final double animation;
  final int totalStars;

  PathPainter({
    required this.zones,
    required this.animation,
    required this.totalStars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < zones.length - 1; i++) {
      // Use isometric conversion for path positions
      final start = WorldMapIsometricHelper.gridToScreen(
        WorldMapIsometricHelper.offsetToIsometric(zones[i].position),
        size,
      );
      final end = WorldMapIsometricHelper.gridToScreen(
        WorldMapIsometricHelper.offsetToIsometric(zones[i + 1].position),
        size,
      );
      
      final isUnlocked = totalStars >= zones[i + 1].requiredStars;
      
      // Draw path
      final pathPaint = Paint()
        ..color = isUnlocked 
            ? Colors.amber.withValues(alpha: 0.6)
            : Colors.grey.withValues(alpha: 0.3)
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
      
      // Draw solid path (optimized for performance)
      canvas.drawPath(path, pathPaint);
      
      // Draw animated dots on unlocked paths (particle effect)
      if (isUnlocked) {
        final dotPaint = Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.fill;
        
        // Compute dot position along path
        final pathMetrics = path.computeMetrics().first;
        final progress = (animation + i * 0.2) % 1.0;
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
    return oldDelegate.animation != animation || 
           oldDelegate.totalStars != totalStars;
  }
}
