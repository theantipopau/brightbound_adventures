import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/utils/world_map_isometric_helper.dart';

/// Terrain painter with biome-themed ground patches
class TerrainPainter extends CustomPainter {
  final List<ZoneData> zones;
  
  TerrainPainter({required this.zones});

  @override
  void paint(Canvas canvas, Size size) {
    for (final zone in zones) {
      final isoPos = WorldMapIsometricHelper.offsetToIsometric(zone.position);
      final screenPos = WorldMapIsometricHelper.gridToScreen(isoPos, size);
      
      _drawBiomePatch(canvas, screenPos, zone.color, zone.id);
    }
  }

  void _drawBiomePatch(Canvas canvas, Offset center, Color color, String zoneId) {
    // 1. Large soft glow for ambient biome color
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30); 

    // Visual center adjusted for the 3D 'floor' (below where the island floats)
    final floorCenter = center + const Offset(0, 40);

    canvas.drawOval(
      Rect.fromCenter(center: floorCenter, width: 350, height: 200),
      glowPaint,
    );
    
    // 2. Isometric Terrain Base (Rhombus shape to suggest grid/land)
    final terrainPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
      
    final path = Path();
    const double width = 140; // Half width magnitude
    const double height = 70;  // Half height magnitude
    
    path.moveTo(floorCenter.dx, floorCenter.dy - height); // Top
    path.lineTo(floorCenter.dx + width, floorCenter.dy);    // Right
    path.lineTo(floorCenter.dx, floorCenter.dy + height);   // Bottom
    path.lineTo(floorCenter.dx - width, floorCenter.dy);    // Left
    path.close();
    
    canvas.drawPath(path, terrainPaint);

    // 3. Terrain Detail Rings (Ripples)
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
      
    canvas.drawPath(path, ringPaint);
    
    // 4. Biome-specific texture patterns
    _drawBiomeTexture(canvas, floorCenter, color, zoneId);
  }

  void _drawBiomeTexture(Canvas canvas, Offset center, Color color, String zoneId) {
    final texturePaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    if (zoneId == 'word-woods') {
      // Forest floor - trees and grass dots
      for (int i = 0; i < 20; i++) {
        final x = center.dx + (i % 5 - 2) * 35;
        final y = center.dy + (i ~/ 5 - 2) * 20;
        // Draw small tree shapes
        final treePaint = Paint()
          ..color = Colors.green.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y - 3), 5, treePaint);
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y + 2), width: 2, height: 8), 
          Paint()..color = Colors.brown.withValues(alpha: 0.3));
      }
    } else if (zoneId == 'number-nebula') {
      // Space/nebula - stars and cosmic swirls
      for (int i = 0; i < 25; i++) {
        final x = center.dx + (i % 6 - 2.5) * 25;
        final y = center.dy + (i ~/ 6 - 2) * 18;
        // Draw star shapes
        final starPaint = Paint()
          ..color = Colors.yellow.withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;
        final path = Path()
          ..moveTo(x, y - 4)
          ..lineTo(x + 1.5, y - 1)
          ..lineTo(x + 4, y)
          ..lineTo(x + 1.5, y + 1)
          ..lineTo(x, y + 4)
          ..lineTo(x - 1.5, y + 1)
          ..lineTo(x - 4, y)
          ..lineTo(x - 1.5, y - 1)
          ..close();
        canvas.drawPath(path, starPaint);
      }
    } else if (zoneId == 'math-facts') {
      // Math symbols floating
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );
      final symbols = ['+', '-', '×', '÷', '='];
      for (int i = 0; i < 15; i++) {
        final x = center.dx + (i % 5 - 2) * 30;
        final y = center.dy + (i ~/ 5 - 1) * 25;
        textPainter.text = TextSpan(
          text: symbols[i % symbols.length],
          style: TextStyle(
            color: color.withValues(alpha: 0.3),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
      }
    } else if (zoneId == 'story-springs') {
      // Book pages and water ripples
      final wavePaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (int i = 0; i < 6; i++) {
        final path = Path();
        final y = center.dy - 30 + i * 15;
        path.moveTo(center.dx - 70, y);
        for (int j = 0; j < 6; j++) {
          final x = center.dx - 70 + j * 25;
          path.quadraticBezierTo(x + 8, y - 4, x + 16, y);
        }
        canvas.drawPath(path, wavePaint);
      }
      // Add book icons
      for (int i = 0; i < 8; i++) {
        final x = center.dx + (i % 4 - 1.5) * 40;
        final y = center.dy + (i ~/ 4 - 0.5) * 30;
        final bookPaint = Paint()
          ..color = Colors.brown.withValues(alpha: 0.25)
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, y), width: 8, height: 12),
            const Radius.circular(1),
          ),
          bookPaint,
        );
      }
    } else if (zoneId == 'puzzle-peaks') {
      // Puzzle pieces pattern
      for (int i = 0; i < 12; i++) {
        final x = center.dx + (i % 4 - 1.5) * 35;
        final y = center.dy + (i ~/ 4 - 1) * 30;
        final piecePaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        // Draw puzzle piece outline
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(x, y), width: 18, height: 18),
            const Radius.circular(2),
          ),
          piecePaint,
        );
        // Add knob
        canvas.drawCircle(Offset(x + 9, y), 4, piecePaint);
      }
    } else if (zoneId == 'adventure-arena') {
      // Trophy/crown patterns and victory elements
      for (int i = 0; i < 15; i++) {
        final x = center.dx + (i % 5 - 2) * 30;
        final y = center.dy + (i ~/ 5 - 1) * 25;
        final trophyPaint = Paint()
          ..color = Colors.amber.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        // Draw trophy shape
        final path = Path()
          ..moveTo(x - 6, y - 5)
          ..lineTo(x - 4, y)
          ..lineTo(x - 5, y + 5)
          ..lineTo(x + 5, y + 5)
          ..lineTo(x + 4, y)
          ..lineTo(x + 6, y - 5)
          ..close();
        canvas.drawPath(path, trophyPaint);
        // Add star on top
        canvas.drawCircle(Offset(x, y - 7), 3, trophyPaint);
      }
    }
  }

  @override
  bool shouldRepaint(TerrainPainter oldDelegate) => false;
}
