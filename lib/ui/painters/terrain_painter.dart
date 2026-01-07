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
      // Grass dots pattern
      for (int i = 0; i < 30; i++) {
        final x = center.dx + (i % 6 - 3) * 20 + (i % 2) * 10;
        final y = center.dy + (i ~/ 6 - 2) * 15;
        canvas.drawCircle(Offset(x, y), 2, texturePaint);
      }
    } else if (zoneId == 'number-nebula') {
      // Sparkle/crystal pattern
      for (int i = 0; i < 20; i++) {
        final x = center.dx + (i % 5 - 2) * 25;
        final y = center.dy + (i ~/ 5 - 2) * 20;
        final path = Path()
          ..moveTo(x, y - 4)
          ..lineTo(x + 3, y)
          ..lineTo(x, y + 4)
          ..lineTo(x - 3, y)
          ..close();
        canvas.drawPath(path, texturePaint);
      }
    } else if (zoneId == 'story-springs') {
      // Wave patterns
      final wavePaint = Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (int i = 0; i < 5; i++) {
        final path = Path();
        final y = center.dy - 40 + i * 20;
        path.moveTo(center.dx - 60, y);
        for (int j = 0; j < 5; j++) {
          final x = center.dx - 60 + j * 30;
          path.quadraticBezierTo(x + 10, y - 5, x + 20, y);
        }
        canvas.drawPath(path, wavePaint);
      }
    }
  }

  @override
  bool shouldRepaint(TerrainPainter oldDelegate) => false;
}
