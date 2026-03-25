import 'dart:math' as math;
import 'package:flutter/material.dart';

class AdventurePatternOverlay extends StatelessWidget {
  final Color color;
  final double opacity;
  final double tileSize;

  const AdventurePatternOverlay({
    super.key,
    required this.color,
    this.opacity = 0.18,
    this.tileSize = 56,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _AdventurePatternPainter(
          color: color.withValues(alpha: opacity),
          tileSize: tileSize,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _AdventurePatternPainter extends CustomPainter {
  final Color color;
  final double tileSize;

  const _AdventurePatternPainter({
    required this.color,
    required this.tileSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final horizontalPaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.35)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color.withValues(alpha: (color.a * 0.55).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    for (double x = 0; x <= size.width + tileSize; x += tileSize) {
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), linePaint);
    }

    for (double y = 0; y <= size.height + tileSize; y += tileSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), horizontalPaint);
    }

    for (double y = tileSize * 0.5; y < size.height; y += tileSize) {
      for (double x = tileSize * 0.5; x < size.width; x += tileSize) {
        final wave = math.sin((x + y) * 0.02) * 2;
        canvas.drawCircle(Offset(x, y + wave), 1.6, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AdventurePatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.tileSize != tileSize;
  }
}
