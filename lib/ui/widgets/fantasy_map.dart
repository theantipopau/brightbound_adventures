import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:brightbound_adventures/ui/themes/index.dart';

/// Magical fantasy map painter - draws terrain, paths, and magical decorations
class FantasyMapPainter extends CustomPainter {
  final double animationValue;
  final math.Random _random =
      math.Random(42); // Fixed seed for consistent terrain

  FantasyMapPainter({this.animationValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    // Safety check - don't paint if size is invalid
    if (size.width <= 0 ||
        size.height <= 0 ||
        size.width.isInfinite ||
        size.height.isInfinite ||
        size.width.isNaN ||
        size.height.isNaN) {
      return;
    }

    // Sky gradient background
    _drawSkyBackground(canvas, size);

    // Distant mountains silhouette
    _drawDistantMountains(canvas, size);

    // Main terrain
    _drawGrassyHills(canvas, size);
    _drawRiver(canvas, size, animationValue);
    _drawBridge(canvas, size);

    // Forest details
    _drawEnchantedForest(canvas, size);

    // Mountains with snow
    _drawMagicMountains(canvas, size);

    // Magic pond with sparkles
    _drawMagicPond(canvas, size, animationValue);

    // Paths with stepping stones
    _drawMagicPaths(canvas, size);

    // Decorative elements
    _drawFlowers(canvas, size);
    _drawMushrooms(canvas, size);
    _drawRainbow(canvas, size, animationValue);
    _drawButterflies(canvas, size, animationValue);
    _drawMagicSparkles(canvas, size, animationValue);
    _drawStars(canvas, size, animationValue);
    _drawClouds(canvas, size, animationValue);

    // Castle in distance
    _drawFairyCastle(canvas, size);

    // Map decorations
    _drawMapBorder(canvas, size);
    _drawCompass(canvas, size);
  }

  void _drawSkyBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF87CEEB), // Sky blue
          const Color(0xFFB4E7F8), // Light blue
          const Color(0xFFFFF8DC), // Cornsilk (warm horizon)
          const Color(0xFF90EE90)
              .withValues(alpha: 0.5), // Light green (grass blend)
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
  }

  void _drawDistantMountains(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8A9C9).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.35);
    path.lineTo(size.width * 0.15, size.height * 0.25);
    path.lineTo(size.width * 0.25, size.height * 0.32);
    path.lineTo(size.width * 0.4, size.height * 0.2);
    path.lineTo(size.width * 0.55, size.height * 0.28);
    path.lineTo(size.width * 0.7, size.height * 0.18);
    path.lineTo(size.width * 0.85, size.height * 0.26);
    path.lineTo(size.width, size.height * 0.22);
    path.lineTo(size.width, size.height * 0.4);
    path.lineTo(0, size.height * 0.4);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawGrassyHills(Canvas canvas, Size size) {
    // Rolling green hills
    final grassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF7CCD7C), // Medium green
          Color(0xFF228B22), // Forest green
          Color(0xFF2E8B57), // Sea green
        ],
      ).createShader(
          Rect.fromLTWH(0, size.height * 0.35, size.width, size.height * 0.65));

    final hillPath = Path();
    hillPath.moveTo(0, size.height * 0.4);

    // Wavy hills
    for (double x = 0; x <= size.width; x += size.width / 8) {
      final y = size.height * 0.4 + math.sin(x * 0.02) * 20;
      hillPath.lineTo(x, y);
    }

    hillPath.lineTo(size.width, size.height);
    hillPath.lineTo(0, size.height);
    hillPath.close();
    canvas.drawPath(hillPath, grassPaint);

    // Add grass texture
    final grassStrokePaint = Paint()
      ..color = const Color(0xFF228B22).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 100; i++) {
      final x = _random.nextDouble() * size.width;
      final y = size.height * 0.45 + _random.nextDouble() * size.height * 0.5;
      final grassPath = Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(x - 3, y - 8, x, y - 15);
      canvas.drawPath(grassPath, grassStrokePaint);
    }
  }

  void _drawRiver(Canvas canvas, Size size, double animation) {
    final riverPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF4169E1).withValues(alpha: 0.7),
          const Color(0xFF00BFFF).withValues(alpha: 0.8),
          const Color(0xFF87CEEB).withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final riverPath = Path();
    riverPath.moveTo(size.width * 0.1, size.height * 0.3);

    // Winding river
    riverPath.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.45,
      size.width * 0.35,
      size.height * 0.5,
    );
    riverPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.55,
      size.width * 0.4,
      size.height * 0.7,
    );
    riverPath.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.85,
      size.width * 0.35,
      size.height,
    );

    // River width
    riverPath.lineTo(size.width * 0.42, size.height);
    riverPath.quadraticBezierTo(
      size.width * 0.37,
      size.height * 0.85,
      size.width * 0.47,
      size.height * 0.7,
    );
    riverPath.quadraticBezierTo(
      size.width * 0.57,
      size.height * 0.55,
      size.width * 0.42,
      size.height * 0.5,
    );
    riverPath.quadraticBezierTo(
      size.width * 0.27,
      size.height * 0.45,
      size.width * 0.17,
      size.height * 0.3,
    );
    riverPath.close();

    canvas.drawPath(riverPath, riverPaint);

    // Animated water sparkles
    final sparklePaint = Paint()
      ..color = Colors.white
          .withValues(alpha: 0.6 + 0.3 * math.sin(animation * math.pi * 4));

    for (int i = 0; i < 8; i++) {
      final x = size.width * (0.2 + 0.2 * (i / 8)) +
          math.sin(animation * math.pi * 2 + i) * 10;
      final y = size.height * (0.4 + 0.05 * i) +
          math.cos(animation * math.pi * 2 + i) * 5;
      canvas.drawCircle(Offset(x, y), 2, sparklePaint);
    }
  }

  void _drawBridge(Canvas canvas, Size size) {
    final bridgeX = size.width * 0.38;
    final bridgeY = size.height * 0.5;

    // Bridge planks
    final woodPaint = Paint()..color = const Color(0xFF8B4513);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(bridgeX, bridgeY), width: 50, height: 15),
        const Radius.circular(3),
      ),
      woodPaint,
    );

    // Bridge rails
    final railPaint = Paint()
      ..color = const Color(0xFF654321)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(Offset(bridgeX - 25, bridgeY - 12),
        Offset(bridgeX - 25, bridgeY - 3), railPaint);
    canvas.drawLine(Offset(bridgeX + 25, bridgeY - 12),
        Offset(bridgeX + 25, bridgeY - 3), railPaint);
    canvas.drawLine(Offset(bridgeX - 25, bridgeY - 12),
        Offset(bridgeX + 25, bridgeY - 12), railPaint);
  }

  void _drawEnchantedForest(Canvas canvas, Size size) {
    final forestX = size.width * 0.12;
    final forestY = size.height * 0.38;

    // Draw multiple tree layers for depth
    final treeTrunkPaint = Paint()..color = const Color(0xFF5D4037);
    final treeLeafPaint = Paint()..color = const Color(0xFF228B22);
    final treeLeafDarkPaint = Paint()..color = const Color(0xFF006400);
    final treeLeafLightPaint = Paint()..color = const Color(0xFF32CD32);

    // Background trees (smaller, darker)
    for (int i = 0; i < 6; i++) {
      final x = forestX + (i - 3) * 22 + math.sin(i * 1.5) * 8;
      final y = forestY - 25 + math.cos(i * 1.2) * 5;
      _drawPineTree(canvas, x, y, 0.6, treeLeafDarkPaint, treeTrunkPaint);
    }

    // Foreground trees (larger, brighter)
    for (int i = 0; i < 8; i++) {
      final x = forestX + (i - 4) * 28 + math.sin(i * 2) * 10;
      final y = forestY + (i % 2) * 20 + math.cos(i * 1.5) * 8;
      final leafPaint = i % 2 == 0 ? treeLeafPaint : treeLeafLightPaint;
      _drawPineTree(
          canvas, x, y, 0.9 + (i % 3) * 0.15, leafPaint, treeTrunkPaint);
    }

    // Add some round bushes
    final bushPaint = Paint()..color = const Color(0xFF3CB371);
    for (int i = 0; i < 5; i++) {
      final x = forestX + (i - 2) * 35;
      final y = forestY + 45 + (i % 2) * 10;
      canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 25, height: 18),
          bushPaint);
    }
  }

  void _drawPineTree(Canvas canvas, double x, double y, double scale,
      Paint leafPaint, Paint trunkPaint) {
    // Trunk
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(x, y + 25 * scale),
          width: 8 * scale,
          height: 20 * scale),
      trunkPaint,
    );

    // Three layers of leaves
    for (int layer = 0; layer < 3; layer++) {
      final layerY = y - layer * 12 * scale;
      final layerWidth = (35 - layer * 8) * scale;
      final path = Path()
        ..moveTo(x - layerWidth / 2, layerY + 15 * scale)
        ..lineTo(x, layerY - 10 * scale)
        ..lineTo(x + layerWidth / 2, layerY + 15 * scale)
        ..close();
      canvas.drawPath(path, leafPaint);
    }
  }

  void _drawMagicMountains(Canvas canvas, Size size) {
    final peaksX = size.width * 0.78;
    final peaksY = size.height * 0.18;

    final mountainPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF9370DB), // Medium purple
          Color(0xFF6B4E8D), // Darker purple
          Color(0xFF483D8B), // Dark slate blue
        ],
      ).createShader(Rect.fromLTWH(peaksX - 80, peaksY - 50, 160, 120));

    final snowPaint = Paint()..color = Colors.white;
    final magicGlowPaint = Paint()
      ..color = const Color(0xFFE6E6FA).withValues(alpha: 0.5);

    // Draw magic mountains
    final mountains = [
      [peaksX - 50, 55.0, 35.0],
      [peaksX, 70.0, 45.0],
      [peaksX + 45, 50.0, 32.0],
      [peaksX - 25, 45.0, 28.0],
      [peaksX + 20, 55.0, 35.0],
    ];

    for (final m in mountains) {
      final mx = m[0];
      final mh = m[1];
      final mw = m[2];

      // Mountain body
      final path = Path()
        ..moveTo(mx - mw, peaksY + mh)
        ..lineTo(mx, peaksY)
        ..lineTo(mx + mw, peaksY + mh)
        ..close();
      canvas.drawPath(path, mountainPaint);

      // Snow cap
      final snowPath = Path()
        ..moveTo(mx - mw * 0.35, peaksY + mh * 0.3)
        ..lineTo(mx, peaksY)
        ..lineTo(mx + mw * 0.35, peaksY + mh * 0.3)
        ..quadraticBezierTo(
            mx, peaksY + mh * 0.4, mx - mw * 0.35, peaksY + mh * 0.3);
      canvas.drawPath(snowPath, snowPaint);

      // Magic glow
      canvas.drawCircle(Offset(mx, peaksY + 5), 8, magicGlowPaint);
    }
  }

  void _drawMagicPond(Canvas canvas, Size size, double animation) {
    final pondX = size.width * 0.48;
    final pondY = size.height * 0.72;

    // Pond water with gradient
    final pondPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF87CEEB).withValues(alpha: 0.9),
          const Color(0xFF4169E1).withValues(alpha: 0.8),
          const Color(0xFF1E90FF).withValues(alpha: 0.7),
        ],
      ).createShader(Rect.fromCenter(
          center: Offset(pondX, pondY), width: 100, height: 60));

    // Pond shape
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pondX, pondY), width: 90, height: 50),
      pondPaint,
    );

    // Lily pads
    final lilyPaint = Paint()..color = const Color(0xFF228B22);
    final lilyPositions = [
      Offset(pondX - 25, pondY - 8),
      Offset(pondX + 20, pondY + 5),
      Offset(pondX - 10, pondY + 12),
    ];

    for (final pos in lilyPositions) {
      canvas.drawOval(
          Rect.fromCenter(center: pos, width: 18, height: 12), lilyPaint);
      // Pink flower
      final flowerPaint = Paint()..color = const Color(0xFFFF69B4);
      canvas.drawCircle(Offset(pos.dx + 2, pos.dy - 2), 4, flowerPaint);
      canvas.drawCircle(
          Offset(pos.dx, pos.dy - 1), 2, Paint()..color = Colors.yellow);
    }

    // Animated sparkles on water
    final sparklePaint = Paint()..color = Colors.white;
    for (int i = 0; i < 5; i++) {
      final angle = animation * math.pi * 2 + i * 1.2;
      final r = 20.0 + i * 5;
      final sx = pondX + math.cos(angle) * r * 0.8;
      final sy = pondY + math.sin(angle) * r * 0.4;
      final opacity =
          (0.3 + 0.5 * math.sin(animation * math.pi * 4 + i)).clamp(0.0, 1.0);
      canvas.drawCircle(Offset(sx, sy), 2,
          sparklePaint..color = Colors.white.withValues(alpha: opacity));
    }
  }

  void _drawMagicPaths(Canvas canvas, Size size) {
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.52;

    final pathPaint = Paint()
      ..color = const Color(0xFFDEB887).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final stonePaint = Paint()..color = const Color(0xFFD2B48C);
    final stoneOutlinePaint = Paint()
      ..color = const Color(0xFF8B7355)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Zone positions
    final zones = [
      Offset(size.width * 0.12, size.height * 0.38), // Word Woods
      Offset(size.width * 0.78, size.height * 0.35), // Number Nebula
      Offset(size.width * 0.78, size.height * 0.18), // Puzzle Peaks
      Offset(size.width * 0.48, size.height * 0.72), // Story Springs
      Offset(size.width * 0.85, size.height * 0.78), // Adventure Arena
    ];

    for (final zone in zones) {
      // Draw path
      final path = Path()..moveTo(centerX, centerY);
      final midX = (centerX + zone.dx) / 2;
      final midY = (centerY + zone.dy) / 2;
      path.quadraticBezierTo(midX + 15, midY - 10, zone.dx, zone.dy);
      canvas.drawPath(path, pathPaint);

      // Draw stepping stones along path
      for (double t = 0.15; t < 0.95; t += 0.2) {
        final x = _quadBezier(centerX, midX + 15, zone.dx, t);
        final y = _quadBezier(centerY, midY - 10, zone.dy, t);
        canvas.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: 14, height: 10),
            stonePaint);
        canvas.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: 14, height: 10),
            stoneOutlinePaint);
      }
    }
  }

  double _quadBezier(double p0, double p1, double p2, double t) {
    return (1 - t) * (1 - t) * p0 + 2 * (1 - t) * t * p1 + t * t * p2;
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final flowerColors = [
      const Color(0xFFFF69B4), // Pink
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF6347), // Tomato
      const Color(0xFF9370DB), // Purple
      const Color(0xFF00CED1), // Cyan
    ];

    for (int i = 0; i < 30; i++) {
      final x = _random.nextDouble() * size.width;
      final y = size.height * 0.5 + _random.nextDouble() * size.height * 0.45;
      final color = flowerColors[i % flowerColors.length];

      // Simple flower
      final petalPaint = Paint()..color = color;
      final centerPaint = Paint()..color = Colors.yellow;

      // Petals
      for (int p = 0; p < 5; p++) {
        final angle = p * math.pi * 2 / 5;
        final px = x + math.cos(angle) * 4;
        final py = y + math.sin(angle) * 4;
        canvas.drawCircle(Offset(px, py), 3, petalPaint);
      }
      // Center
      canvas.drawCircle(Offset(x, y), 2, centerPaint);
    }
  }

  void _drawMushrooms(Canvas canvas, Size size) {
    final mushPositions = [
      Offset(size.width * 0.08, size.height * 0.55),
      Offset(size.width * 0.22, size.height * 0.62),
      Offset(size.width * 0.65, size.height * 0.58),
      Offset(size.width * 0.92, size.height * 0.65),
    ];

    for (final pos in mushPositions) {
      // Stem
      final stemPaint = Paint()..color = const Color(0xFFFFF8DC);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset(pos.dx, pos.dy + 8), width: 8, height: 12),
          stemPaint);

      // Cap
      final capPaint = Paint()..color = const Color(0xFFFF6347);
      canvas.drawArc(
        Rect.fromCenter(center: Offset(pos.dx, pos.dy), width: 20, height: 16),
        math.pi,
        math.pi,
        true,
        capPaint,
      );

      // Spots
      final spotPaint = Paint()..color = Colors.white;
      canvas.drawCircle(Offset(pos.dx - 4, pos.dy - 2), 2, spotPaint);
      canvas.drawCircle(Offset(pos.dx + 3, pos.dy - 1), 1.5, spotPaint);
    }
  }

  void _drawRainbow(Canvas canvas, Size size, double animation) {
    final rainbowOpacity =
        (0.4 + 0.2 * math.sin(animation * math.pi * 2)).clamp(0.0, 1.0);
    final colors = [
      Colors.red.withValues(alpha: rainbowOpacity),
      Colors.orange.withValues(alpha: rainbowOpacity),
      Colors.yellow.withValues(alpha: rainbowOpacity),
      Colors.green.withValues(alpha: rainbowOpacity),
      Colors.blue.withValues(alpha: rainbowOpacity),
      Colors.purple.withValues(alpha: rainbowOpacity),
    ];

    final centerX = size.width * 0.6;
    final centerY = size.height * 0.45;

    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: 200 - i * 12,
            height: 100 - i * 6),
        math.pi,
        math.pi,
        false,
        paint,
      );
    }
  }

  void _drawButterflies(Canvas canvas, Size size, double animation) {
    final butterflyColors = [
      const Color(0xFFFF69B4),
      const Color(0xFF87CEEB),
      const Color(0xFFFFD700),
      const Color(0xFF9370DB),
    ];

    for (int i = 0; i < 6; i++) {
      final baseX = size.width * (0.2 + 0.6 * (i / 5));
      final baseY = size.height * (0.3 + 0.3 * math.sin(i * 1.5));

      // Animated position
      final x = baseX + math.sin(animation * math.pi * 4 + i * 2) * 20;
      final y = baseY + math.cos(animation * math.pi * 3 + i * 1.5) * 15;

      // Wing flap animation
      final wingAngle = math.sin(animation * math.pi * 8 + i) * 0.4;

      final color = butterflyColors[i % butterflyColors.length];
      final wingPaint = Paint()..color = color;

      // Left wing
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(wingAngle);
      canvas.drawOval(
          Rect.fromCenter(center: const Offset(-5, 0), width: 10, height: 6),
          wingPaint);
      canvas.restore();

      // Right wing
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(-wingAngle);
      canvas.drawOval(
          Rect.fromCenter(center: const Offset(5, 0), width: 10, height: 6),
          wingPaint);
      canvas.restore();

      // Body
      canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 2, height: 8),
          Paint()..color = Colors.black);
    }
  }

  void _drawMagicSparkles(Canvas canvas, Size size, double animation) {
    for (int i = 0; i < 25; i++) {
      final x = (i * 47 + animation * 100) % size.width;
      final y = size.height * (0.2 + 0.6 * math.sin(i * 0.8));
      final opacity = (0.3 + 0.7 * math.sin(animation * math.pi * 6 + i * 0.5))
          .clamp(0.0, 1.0);
      final sparkleSize = 2 + math.sin(animation * math.pi * 4 + i) * 1.5;

      // Draw 4-point star sparkle
      final paint = Paint()..color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), sparkleSize, paint);

      // Cross lines for sparkle effect
      final linePaint = Paint()
        ..color =
            Colors.white.withValues(alpha: (opacity * 0.6).clamp(0.0, 1.0))
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x - sparkleSize * 2, y),
          Offset(x + sparkleSize * 2, y), linePaint);
      canvas.drawLine(Offset(x, y - sparkleSize * 2),
          Offset(x, y + sparkleSize * 2), linePaint);
    }
  }

  void _drawStars(Canvas canvas, Size size, double animation) {
    final starPaint = Paint()..color = const Color(0xFFFFD700);

    for (int i = 0; i < 12; i++) {
      final x = size.width * (0.1 + 0.8 * (i / 11));
      final y = size.height * (0.05 + 0.15 * math.sin(i * 1.3));
      final twinkle = (0.5 + 0.5 * math.sin(animation * math.pi * 4 + i * 0.7))
          .clamp(0.0, 1.0);

      _drawStar(
          canvas,
          x,
          y,
          4 + twinkle * 2,
          starPaint
            ..color = const Color(0xFFFFD700).withValues(alpha: twinkle));
    }
  }

  void _drawStar(Canvas canvas, double x, double y, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / 5;
      final innerAngle = angle + math.pi / 5;

      final outerX = x + math.cos(angle) * size;
      final outerY = y + math.sin(angle) * size;
      final innerX = x + math.cos(innerAngle) * size * 0.4;
      final innerY = y + math.sin(innerAngle) * size * 0.4;

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawClouds(Canvas canvas, Size size, double animation) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final shadowPaint = Paint()..color = Colors.grey.withValues(alpha: 0.2);

    final cloudPositions = [
      [size.width * 0.15 + animation * 80, size.height * 0.06, 1.2],
      [size.width * 0.5 + animation * 50, size.height * 0.04, 1.0],
      [size.width * 0.85 - animation * 60, size.height * 0.08, 0.8],
    ];

    for (final cloud in cloudPositions) {
      final cx = (cloud[0]) % (size.width + 100) - 50;
      final cy = cloud[1];
      final scale = cloud[2];

      // Shadow
      _drawCloudShape(canvas, cx + 3, cy + 3, scale, shadowPaint);
      // Cloud
      _drawCloudShape(canvas, cx, cy, scale, cloudPaint);
    }
  }

  void _drawCloudShape(
      Canvas canvas, double x, double y, double scale, Paint paint) {
    canvas.drawCircle(Offset(x, y), 18 * scale, paint);
    canvas.drawCircle(Offset(x + 20 * scale, y - 5 * scale), 15 * scale, paint);
    canvas.drawCircle(Offset(x + 35 * scale, y), 12 * scale, paint);
    canvas.drawCircle(Offset(x + 15 * scale, y + 8 * scale), 10 * scale, paint);
  }

  void _drawFairyCastle(Canvas canvas, Size size) {
    final castleX = size.width * 0.88;
    final castleY = size.height * 0.28;

    // Castle walls
    final wallPaint = Paint()..color = const Color(0xFFE6E6FA);
    final roofPaint = Paint()..color = const Color(0xFF9370DB);
    final windowPaint = Paint()..color = const Color(0xFF4169E1);

    // Main tower
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(castleX, castleY + 15), width: 25, height: 35),
        wallPaint);

    // Tower roof
    final roofPath = Path()
      ..moveTo(castleX - 15, castleY - 2)
      ..lineTo(castleX, castleY - 22)
      ..lineTo(castleX + 15, castleY - 2)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Side towers
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(castleX - 18, castleY + 18), width: 12, height: 25),
        wallPaint);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(castleX + 18, castleY + 18), width: 12, height: 25),
        wallPaint);

    // Side tower roofs
    final leftRoof = Path()
      ..moveTo(castleX - 25, castleY + 5)
      ..lineTo(castleX - 18, castleY - 8)
      ..lineTo(castleX - 11, castleY + 5)
      ..close();
    canvas.drawPath(leftRoof, roofPaint);

    final rightRoof = Path()
      ..moveTo(castleX + 11, castleY + 5)
      ..lineTo(castleX + 18, castleY - 8)
      ..lineTo(castleX + 25, castleY + 5)
      ..close();
    canvas.drawPath(rightRoof, roofPaint);

    // Windows
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(castleX, castleY + 10), width: 6, height: 10),
        windowPaint);
    canvas.drawCircle(Offset(castleX, castleY + 2), 3, windowPaint);

    // Flag
    final flagPaint = Paint()..color = const Color(0xFFFF69B4);
    canvas.drawRect(Rect.fromLTWH(castleX - 1, castleY - 32, 2, 12),
        Paint()..color = Colors.brown);
    canvas.drawRect(Rect.fromLTWH(castleX + 1, castleY - 32, 10, 6), flagPaint);
  }

  void _drawMapBorder(Canvas canvas, Size size) {
    // Fancy scroll border
    final borderPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final innerBorderPaint = Paint()
      ..color = const Color(0xFFDEB887)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final goldPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    // Main border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height - 8),
        const Radius.circular(12),
      ),
      borderPaint,
    );

    // Inner decorative border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(12, 12, size.width - 24, size.height - 24),
        const Radius.circular(8),
      ),
      innerBorderPaint,
    );

    // Gold corner decorations
    final corners = [
      const Offset(18, 18),
      Offset(size.width - 18, 18),
      Offset(18, size.height - 18),
      Offset(size.width - 18, size.height - 18),
    ];

    for (final corner in corners) {
      _drawStar(canvas, corner.dx, corner.dy, 8, goldPaint);
    }
  }

  void _drawCompass(Canvas canvas, Size size) {
    final compassX = size.width * 0.08;
    final compassY = size.height * 0.92;
    const radius = 28.0;

    // Compass background
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFFFFF8DC),
          Color(0xFFDEB887),
        ],
      ).createShader(
          Rect.fromCircle(center: Offset(compassX, compassY), radius: radius));
    canvas.drawCircle(Offset(compassX, compassY), radius, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset(compassX, compassY), radius, borderPaint);

    // Inner circle
    canvas.drawCircle(
        Offset(compassX, compassY),
        radius - 8,
        Paint()
          ..color = const Color(0xFF8B4513)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // Direction labels
    const textStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: Color(0xFF8B4513),
    );

    final directions = [
      ['N', Offset(compassX - 4, compassY - radius + 6)],
      ['E', Offset(compassX + radius - 12, compassY - 5)],
      ['S', Offset(compassX - 4, compassY + radius - 16)],
      ['W', Offset(compassX - radius + 4, compassY - 5)],
    ];

    for (final dir in directions) {
      final tp = TextPainter(
        text: TextSpan(
          text: dir[0] as String,
          style: dir[0] == 'N'
              ? textStyle.copyWith(color: Colors.red.shade700)
              : textStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, dir[1] as Offset);
    }

    // Compass needle
    final needlePaint = Paint()..color = Colors.red.shade700;
    final needlePath = Path()
      ..moveTo(compassX, compassY - 15)
      ..lineTo(compassX - 5, compassY)
      ..lineTo(compassX, compassY + 15)
      ..lineTo(compassX + 5, compassY)
      ..close();
    canvas.drawPath(needlePath, needlePaint);

    // Center jewel
    canvas.drawCircle(Offset(compassX, compassY), 4,
        Paint()..color = const Color(0xFFFFD700));
    canvas.drawCircle(Offset(compassX, compassY), 2,
        Paint()..color = const Color(0xFFFF6347));
  }

  @override
  bool shouldRepaint(covariant FantasyMapPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Interactive zone marker on the map - Magical portal style!
class ZoneMarker extends StatefulWidget {
  final String zoneName;
  final String emoji;
  final Color color;
  final VoidCallback onTap;
  final bool isUnlocked;
  final double progress;

  const ZoneMarker({
    super.key,
    required this.zoneName,
    required this.emoji,
    required this.color,
    required this.onTap,
    this.isUnlocked = true,
    this.progress = 0.0,
  });

  @override
  State<ZoneMarker> createState() => _ZoneMarkerState();
}

class _ZoneMarkerState extends State<ZoneMarker> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _sparkleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_pulseController, _rotateController, _sparkleController]),
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.isUnlocked ? widget.onTap : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Magical portal zone marker
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating magic ring
                    Transform.rotate(
                      angle: _rotateController.value * 2 * math.pi,
                      child: CustomPaint(
                        size: const Size(88, 88),
                        painter: _MagicRingPainter(
                          color: widget.color,
                          opacity: _glowAnimation.value,
                        ),
                      ),
                    ),
                    // Inner rotating ring (opposite direction)
                    Transform.rotate(
                      angle: -_rotateController.value * 2 * math.pi * 0.7,
                      child: CustomPaint(
                        size: const Size(72, 72),
                        painter: _MagicRingPainter(
                          color: widget.color.withValues(alpha: 0.7),
                          opacity: _glowAnimation.value * 0.6,
                          starCount: 4,
                        ),
                      ),
                    ),
                    // Glow effect
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.color
                                .withValues(alpha: _glowAnimation.value),
                            blurRadius: 20,
                            spreadRadius: 8,
                          ),
                          BoxShadow(
                            color: Colors.white
                                .withValues(alpha: _glowAnimation.value * 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    // Main portal circle
                    Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.95),
                              widget.color.withValues(alpha: 0.85),
                              widget.color,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withValues(alpha: 0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: widget.isUnlocked
                              ? Text(
                                  widget.emoji,
                                  style: const TextStyle(fontSize: 26),
                                )
                              : const Icon(Icons.lock,
                                  color: Colors.white54, size: 24),
                        ),
                      ),
                    ),
                    // Floating sparkles around the portal
                    ..._buildSparkles(),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Fancy zone name banner (scroll style)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFF8DC),
                      Color(0xFFFFEBC8),
                      Color(0xFFFFF8DC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF8B4513), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 4),
                    Text(
                      widget.zoneName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('✨', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              // Progress stars instead of bar
              if (widget.progress > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final filled = (widget.progress * 5) > index;
                      return Icon(
                        filled ? Icons.star : Icons.star_border,
                        size: 12,
                        color: filled
                            ? const Color(0xFFFFD700)
                            : Colors.grey.shade400,
                      );
                    }),
                  ),
                ),
              // Lock indicator with sparkle
              if (!widget.isUnlocked)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey.shade600, Colors.grey.shade800],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade500, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Locked',
                          style: TextStyle(fontSize: 9, color: Colors.white)),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSparkles() {
    final sparkles = <Widget>[];
    for (int i = 0; i < 6; i++) {
      final angle =
          (i / 6) * 2 * math.pi + _sparkleController.value * 2 * math.pi;
      final radius =
          38 + math.sin(_sparkleController.value * math.pi * 2 + i) * 5;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      final opacity = (0.3 +
              0.7 * math.sin(_sparkleController.value * math.pi * 4 + i * 0.8))
          .clamp(0.0, 1.0);

      sparkles.add(
        Positioned(
          left: 45 + x - 4,
          top: 45 + y - 4,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: opacity),
              boxShadow: [
                BoxShadow(
                  color: widget.color
                      .withValues(alpha: (opacity * 0.8).clamp(0.0, 1.0)),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return sparkles;
  }
}

/// Painter for the rotating magic ring around zone markers
class _MagicRingPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final int starCount;

  _MagicRingPainter({
    required this.color,
    required this.opacity,
    this.starCount = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final safeOpacity = opacity.clamp(0.0, 1.0);

    // Draw ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: (safeOpacity * 0.5).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    // Draw small stars/dots around the ring
    final starPaint = Paint()
      ..color = Colors.white.withValues(alpha: safeOpacity);
    for (int i = 0; i < starCount; i++) {
      final angle = (i / starCount) * 2 * math.pi;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      canvas.drawCircle(Offset(x, y), 3, starPaint);

      // Small glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: (safeOpacity * 0.5).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), 5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MagicRingPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

/// Central hub marker (where avatar lives) - Magical home base!
class CentralHub extends StatefulWidget {
  final String avatarEmoji;
  final String avatarName;
  final int level;

  const CentralHub({
    super.key,
    required this.avatarEmoji,
    required this.avatarName,
    required this.level,
  });

  @override
  State<CentralHub> createState() => _CentralHubState();
}

class _CentralHubState extends State<CentralHub> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _sparkleController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _floatAnimation = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatController, _sparkleController]),
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Magic sparkle crown above avatar
            SizedBox(
              width: 100,
              height: 25,
              child: CustomPaint(
                painter: _MagicCrownPainter(
                  animationValue: _sparkleController.value,
                ),
              ),
            ),
            // Floating avatar with magic effects
            Transform.translate(
              offset: Offset(0, _floatAnimation.value),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow ring
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.primary.withValues(
                              alpha: 0.2 +
                                  0.1 *
                                      math.sin(_sparkleController.value *
                                          math.pi *
                                          2)),
                          AppColors.secondary.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 0.7, 1.0],
                      ),
                    ),
                  ),
                  // Main avatar container
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD700), // Gold
                          Color(0xFFFFA500), // Orange
                          Color(0xFFFF6B35), // Coral
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(widget.avatarEmoji,
                          style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                  // Floating stars around avatar
                  ..._buildFloatingStars(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Fancy name scroll banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFA500),
                    Color(0xFFFFD700),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('👑', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        widget.avatarName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('👑', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          'Level ${widget.level}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('⭐', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildFloatingStars() {
    final stars = <Widget>[];
    final colors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFF69B4), // Pink
      const Color(0xFF87CEEB), // Sky blue
      const Color(0xFF98FB98), // Pale green
    ];

    for (int i = 0; i < 8; i++) {
      final baseAngle = (i / 8) * 2 * math.pi;
      final angle = baseAngle + _sparkleController.value * math.pi * 2 * 0.5;
      final radius =
          48 + math.sin(_sparkleController.value * math.pi * 3 + i) * 4;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      final opacity = (0.4 +
              0.6 * math.sin(_sparkleController.value * math.pi * 4 + i * 0.7))
          .clamp(0.0, 1.0);

      stars.add(
        Positioned(
          left: 50 + x - 5,
          top: 50 + y - 5,
          child: Icon(
            Icons.star,
            size: 10,
            color: colors[i % colors.length].withValues(alpha: opacity),
          ),
        ),
      );
    }
    return stars;
  }
}

/// Painter for the magic crown sparkles above the avatar
class _MagicCrownPainter extends CustomPainter {
  final double animationValue;

  _MagicCrownPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Draw sparkle dots in a crown pattern
    final sparklePositions = [
      Offset(centerX - 35, 15),
      Offset(centerX - 20, 5),
      Offset(centerX, 0),
      Offset(centerX + 20, 5),
      Offset(centerX + 35, 15),
    ];

    for (int i = 0; i < sparklePositions.length; i++) {
      final pos = sparklePositions[i];
      final phase = animationValue * math.pi * 2 + i * 0.5;
      final opacity = (0.3 + 0.7 * math.sin(phase * 2)).clamp(0.0, 1.0);
      final sparkleSize = 3 + math.sin(phase) * 2;

      final paint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: opacity);
      canvas.drawCircle(pos, sparkleSize, paint);

      // Cross lines for sparkle effect
      final linePaint = Paint()
        ..color =
            Colors.white.withValues(alpha: (opacity * 0.6).clamp(0.0, 1.0))
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(pos.dx - sparkleSize * 1.5, pos.dy),
        Offset(pos.dx + sparkleSize * 1.5, pos.dy),
        linePaint,
      );
      canvas.drawLine(
        Offset(pos.dx, pos.dy - sparkleSize * 1.5),
        Offset(pos.dx, pos.dy + sparkleSize * 1.5),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MagicCrownPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
