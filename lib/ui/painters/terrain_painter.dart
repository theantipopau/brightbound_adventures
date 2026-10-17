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

  // Vertical thickness of the extruded island platform, in logical px.
  static const double _extrusionDepth = 24;
  static const double _halfWidth = 140;
  static const double _halfHeight = 70;

  /// Returns [base] shaded darker/lighter by [amount] in HSL lightness,
  /// used to fake a single top-left light source across the extruded
  /// island faces (top face lightest, left face -25%, right face -40%).
  Color _shade(Color base, double amount) {
    final hsl = HSLColor.fromColor(base);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  void _drawBiomePatch(
      Canvas canvas, Offset center, Color color, String zoneId) {
    // Visual center adjusted for the 3D 'floor' (below where the island floats)
    final floorCenter = center + const Offset(0, 40);

    // Diamond (top-face) vertices, in isometric 2:1 projection.
    final top = Offset(floorCenter.dx, floorCenter.dy - _halfHeight);
    final right = Offset(floorCenter.dx + _halfWidth, floorCenter.dy);
    final bottom = Offset(floorCenter.dx, floorCenter.dy + _halfHeight);
    final left = Offset(floorCenter.dx - _halfWidth, floorCenter.dy);
    const depthOffset = Offset(0, _extrusionDepth);

    // 1. Ambient glow plus a tighter ambient-occlusion ellipse hugging
    // the extruded underside, which is what actually sells the island
    // as a solid floating object rather than a flat patch.
    // Kept tight on purpose: the old 350x200 wash overlapped every
    // neighbour on phones (island centres sit ~40-70px apart at 360px
    // wide), turning the archipelago into one muddy blob. This stays
    // just under the island footprint so adjacent biomes stay readable.
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawOval(
      Rect.fromCenter(center: floorCenter, width: 250, height: 140),
      glowPaint,
    );

    final aoPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawOval(
      Rect.fromCenter(
        center: bottom + depthOffset + const Offset(0, 6),
        width: _halfWidth * 1.15,
        height: 28,
      ),
      aoPaint,
    );

    // 2. Side faces (the extrusion). Drawn before the top face so the top
    // face's edges cleanly cover their upper seams. Left face is lit more
    // than right, matching a top-left light source. The shared bottom
    // vertex is rounded slightly so the island's base isn't a sharp point.
    const cornerRadius = 10.0;
    final bottomDeep = bottom + depthOffset;
    final leftDeep = left + depthOffset;
    final rightDeep = right + depthOffset;

    final leftFacePaint = Paint()
      ..color = _shade(color, -0.16).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final leftFace = Path()
      ..moveTo(left.dx, left.dy)
      ..lineTo(bottom.dx - cornerRadius, bottom.dy)
      ..quadraticBezierTo(
          bottom.dx, bottom.dy, bottom.dx, bottom.dy + cornerRadius * 0.4)
      ..lineTo(bottomDeep.dx, bottomDeep.dy)
      ..lineTo(leftDeep.dx, leftDeep.dy)
      ..close();
    canvas.drawPath(leftFace, leftFacePaint);

    final rightFacePaint = Paint()
      ..color = _shade(color, -0.26).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    final rightFace = Path()
      ..moveTo(bottom.dx + cornerRadius, bottom.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(rightDeep.dx, rightDeep.dy)
      ..lineTo(bottomDeep.dx, bottomDeep.dy)
      ..quadraticBezierTo(
          bottom.dx, bottom.dy, bottom.dx + cornerRadius, bottom.dy)
      ..close();
    canvas.drawPath(rightFace, rightFacePaint);

    // 3. Top face: layered base + sunlit centre + specular sheen, drawn
    // last. The base stays translucent so neighbouring biomes read through
    // at the seams; the lit centre + sheen sell the form without new hues
    // (zone colour + white only, per this file's palette).
    final terrainPaint = Paint()
      ..color = _shade(color, 0.06).withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(path, terrainPaint);
    // Sunlit centre: a smaller inset diamond, lighter and a touch more
    // opaque, faking a top-left light falloff across the platform.
    final lightPath = Path()
      ..moveTo(top.dx, top.dy + 14)
      ..lineTo(right.dx - 28, right.dy)
      ..lineTo(bottom.dx, bottom.dy - 14)
      ..lineTo(left.dx + 28, left.dy)
      ..close();
    canvas.drawPath(
      lightPath,
      Paint()
        ..color = _shade(color, 0.16).withValues(alpha: 0.28)
        ..style = PaintingStyle.fill,
    );
    // Specular sheen: soft white ellipse near the top edge.
    canvas.drawOval(
      Rect.fromCenter(
        center: floorCenter + const Offset(-24, -34),
        width: 120,
        height: 34,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 3b. Sun-catch speckles: a few deterministic white grains across the
    // lit centre so large flat biomes don't read as empty plastic.
    final specklePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.fill;
    final speckleSeed = zoneId.hashCode;
    for (int i = 0; i < 9; i++) {
      final sx = floorCenter.dx +
          (((speckleSeed >> (i * 3)) & 15) - 7.5) * 12;
      final sy = floorCenter.dy +
          (((speckleSeed >> (i * 2 + 1)) & 7) - 3.5) * 10;
      canvas.drawCircle(Offset(sx, sy), 2.2, specklePaint);
    }

    // 4. Rim inset - a slightly darker stroke just inside the top face's
    // edge, giving the platform a defined, tactile border.
    final rimPaint = Paint()
      ..color = _shade(color, -0.1).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, rimPaint);

    // 5. Biome-specific texture patterns
    _drawBiomeTexture(canvas, floorCenter, color, zoneId);
  }

  void _drawBiomeTexture(
      Canvas canvas, Offset center, Color color, String zoneId) {
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
        canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y + 2), width: 2, height: 8),
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
        textPainter.paint(canvas,
            Offset(x - textPainter.width / 2, y - textPainter.height / 2));
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
    } else if (zoneId == 'science-explorers') {
      // Lab bench - flask dots alternating the zone colour with white
      // (both already in the file's palette: no new direct colours).
      for (int i = 0; i < 16; i++) {
        final x = center.dx + (i % 4 - 1.5) * 38;
        final y = center.dy + (i ~/ 4 - 1.5) * 26;
        final dotPaint = Paint()
          ..color = (i.isEven ? Colors.white : color)
              .withValues(alpha: 0.30)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), i.isEven ? 3.5 : 2.5, dotPaint);
        if (i % 4 == 0) {
          canvas.drawCircle(
            Offset(x + 8, y + 6),
            5,
            Paint()
              ..color = color.withValues(alpha: 0.28)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }
      }
    } else if (zoneId == 'creative-corner') {
      // Confetti dots + a paint-stroke wave for art and music, in the
      // zone colour and white (both already in the file's palette).
      for (int i = 0; i < 16; i++) {
        final x = center.dx + (i % 4 - 1.5) * 38;
        final y = center.dy + (i ~/ 4 - 1.5) * 26;
        final dotPaint = Paint()
          ..color = (i.isEven ? color : Colors.white)
              .withValues(alpha: 0.32)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
      }
      final wavePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      final wave = Path()
        ..moveTo(center.dx - 60, center.dy + 18);
      for (int j = 0; j < 5; j++) {
        final x = center.dx - 60 + j * 26;
        wave.quadraticBezierTo(x + 8, center.dy + 8, x + 16, center.dy + 18);
      }
      canvas.drawPath(wave, wavePaint);
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
