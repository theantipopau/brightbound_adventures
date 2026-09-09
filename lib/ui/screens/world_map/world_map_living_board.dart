import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/utils/isometric_engine.dart';
import 'package:brightbound_adventures/ui/painters/path_painter.dart';
import 'package:brightbound_adventures/ui/painters/shadow_painter.dart';
import 'package:brightbound_adventures/ui/painters/terrain_painter.dart';

/// Composition boundary for the world-map board.
///
/// The parent still owns scene data, selection, movement, and navigation.
/// This widget owns only the ordered visual layers that make up the board.
class WorldMapLivingBoard extends StatelessWidget {
  final List<ZoneData> zones;
  final Map<String, Offset> screenPositions;
  final IsometricPosition? avatarPosition;
  final Animation<double> pathAnimation;
  final int totalStars;
  final double mapZoom;
  final Size size;
  final CustomPainter boardPainter;
  final Widget sceneLayer;

  const WorldMapLivingBoard({
    super.key,
    required this.zones,
    required this.screenPositions,
    required this.avatarPosition,
    required this.pathAnimation,
    required this.totalStars,
    required this.mapZoom,
    required this.size,
    required this.boardPainter,
    required this.sceneLayer,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _paintLayer(
          painter: boardPainter,
        ),
        _paintLayer(painter: TerrainPainter(zones: zones)),
        _paintLayer(
          painter: ShadowPainter(
            zones: zones,
            avatarPosition: avatarPosition,
          ),
        ),
        _paintLayer(
          painter: PathPainter(
            zones: zones,
            zoneScreenPositions: screenPositions,
            animation: pathAnimation,
            totalStars: totalStars,
          ),
        ),
        Transform.scale(
          alignment: Alignment.center,
          scale: mapZoom,
          child: sceneLayer,
        ),
      ],
    );
  }

  Widget _paintLayer({required CustomPainter painter}) {
    return RepaintBoundary(
      child: Transform.scale(
        alignment: Alignment.center,
        scale: mapZoom,
        child: CustomPaint(
          painter: painter,
          size: size,
        ),
      ),
    );
  }
}

class WorldMapBoardPainter extends CustomPainter {
  final List<ZoneData> zones;
  final Map<String, Offset> positions;
  final String selectedZoneId;
  final double animationValue;

  WorldMapBoardPainter({
    required this.zones,
    required this.positions,
    required this.selectedZoneId,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty) return;

    final xs = positions.values.map((p) => p.dx);
    final ys = positions.values.map((p) => p.dy);
    final minX = xs.reduce(math.min);
    final maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min);
    final maxY = ys.reduce(math.max);

    final boardRect = Rect.fromLTRB(
      (minX - 155).clamp(16.0, size.width),
      (minY - 96).clamp(16.0, size.height),
      (maxX + 155).clamp(0.0, size.width - 16),
      (maxY + 132).clamp(0.0, size.height - 16),
    );
    if (boardRect.width <= 120 || boardRect.height <= 90) return;

    final base = RRect.fromRectAndRadius(boardRect, const Radius.circular(54));
    final side = RRect.fromRectAndRadius(
      boardRect.shift(const Offset(0, 18)),
      const Radius.circular(54),
    );

    final sidePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF9D7342), Color(0xFF6F4B2A)],
      ).createShader(side.outerRect);
    canvas.drawRRect(side, sidePaint);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawRRect(side.shift(const Offset(0, 10)), shadowPaint);

    final topPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF6CF), Color(0xFFE7F6FF), Color(0xFFF8E8FF)],
      ).createShader(base.outerRect);
    canvas.drawRRect(base, topPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawRRect(base.deflate(3), borderPaint);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white.withValues(alpha: 0.48);
    final trackGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFF6FC7FF).withValues(alpha: 0.15);

    final orderedPositions = zones
        .map((zone) => positions[zone.id])
        .whereType<Offset>()
        .toList(growable: false);
    if (orderedPositions.length > 1) {
      final path = Path()
        ..moveTo(orderedPositions.first.dx, orderedPositions.first.dy);
      for (var i = 1; i < orderedPositions.length; i++) {
        final previous = orderedPositions[i - 1];
        final current = orderedPositions[i];
        final control = Offset(
          (previous.dx + current.dx) / 2,
          (previous.dy + current.dy) / 2 - 26,
        );
        path.quadraticBezierTo(control.dx, control.dy, current.dx, current.dy);
      }
      canvas.drawPath(path, trackGlow);
      canvas.drawPath(path, trackPaint);
    }

    for (final zone in zones) {
      final pos = positions[zone.id];
      if (pos == null) continue;
      final selected = zone.id == selectedZoneId;
      final pulse =
          selected ? 1.0 + math.sin(animationValue * math.pi * 2) * 0.04 : 1.0;
      final rect = Rect.fromCenter(
        center: pos.translate(0, 34),
        width: 116 * pulse,
        height: 46 * pulse,
      );
      final padPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            zone.color.withValues(alpha: selected ? 0.48 : 0.24),
            Colors.white.withValues(alpha: selected ? 0.44 : 0.22),
            Colors.transparent,
          ],
        ).createShader(rect);
      canvas.drawOval(rect, padPaint);

      final rimPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 3.2 : 1.6
        ..color = zone.color.withValues(alpha: selected ? 0.72 : 0.34);
      canvas.drawOval(rect.deflate(4), rimPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WorldMapBoardPainter oldDelegate) {
    return oldDelegate.positions != positions ||
        oldDelegate.selectedZoneId != selectedZoneId ||
        oldDelegate.animationValue != animationValue;
  }
}
