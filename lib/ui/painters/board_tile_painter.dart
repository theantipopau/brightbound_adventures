import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/utils/board_path.dart';

/// Mario-Party-style board spaces: small 2:1 isometric tiles dotted along
/// the route between islands, so the path reads as a *board* the pawn walks
/// — spaces to land on — rather than a line drawn on a map.
///
/// Each hop gets 2–5 spaces depending on its length, coloured by the zone
/// the hop leads into (greyed out while that zone is still locked). The
/// middle space of every hop is a gold "question space" — the board's
/// promise that a NAPLAN question waits at each stage.
///
/// Geometry comes from the shared [BoardPath] that `PathPainter` draws and
/// the pawn walks, so tiles always sit exactly on the track.
class BoardTilePainter extends CustomPainter {
  final List<ZoneData> zones;
  final Map<String, Offset> positions;
  final int totalStars;

  BoardTilePainter({
    required this.zones,
    required this.positions,
    required this.totalStars,
  });

  /// Route length (approximated along the control polygon) between spaces.
  static const double _spacing = 84;
  static const int _minSpacesPerHop = 2;
  static const int _maxSpacesPerHop = 5;

  static const double _halfWidth = 15;
  static const double _halfHeight = 7.5;
  static const double _extrusion = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final ordered = [
      for (final zone in zones) positions[zone.id],
    ].whereType<Offset>();
    if (ordered.length < 2) return;

    final boardPath = BoardPath.fromPositions(ordered.toList(growable: false));
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (var i = 0; i < boardPath.segmentCount; i++) {
      final segment = boardPath.segments[i];
      final destination = zones[i + 1];
      final isUnlocked = totalStars >= destination.requiredStars;

      // Approximate arc length via the control polygon (cheap, good enough
      // for spacing decisions).
      final approxLength = (segment.control - segment.start).distance +
          (segment.end - segment.control).distance;
      final count = (approxLength / _spacing)
          .round()
          .clamp(_minSpacesPerHop, _maxSpacesPerHop);
      final middle = (count / 2).ceil();

      for (var k = 1; k <= count; k++) {
        final point = segment.pointAt(k / (count + 1));
        final isQuestionSpace = k == middle;
        _drawSpace(
          canvas,
          point,
          baseColor: isQuestionSpace || isUnlocked
              ? destination.color
              : const Color(0xFF9E9E9E),
          dimmed: !isUnlocked && !isQuestionSpace,
          question: isQuestionSpace,
          shadow: shadowPaint,
        );
      }
    }
  }

  void _drawSpace(
    Canvas canvas,
    Offset center, {
    required Color baseColor,
    required bool dimmed,
    required bool question,
    required Paint shadow,
  }) {
    final top = center.translate(0, -_halfHeight);
    final right = center.translate(_halfWidth, 0);
    final bottom = center.translate(0, _halfHeight);
    final left = center.translate(-_halfWidth, 0);

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(1.5, _extrusion + 3),
        width: _halfWidth * 1.7,
        height: _halfHeight * 1.6,
      ),
      shadow,
    );

    // Extruded side: same diamond shifted down, in a shaded tone of the
    // space's colour (light comes from the top-left, per the diorama spec).
    final sideColor =
        Color.lerp(baseColor, Colors.black, dimmed ? 0.45 : 0.32)!;
    final sidePath = Path()
      ..moveTo(left.dx, left.dy + _extrusion)
      ..lineTo(bottom.dx, bottom.dy + _extrusion)
      ..lineTo(right.dx, right.dy + _extrusion)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(sidePath, Paint()..color = sideColor);

    // Top face.
    final facePath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(
      facePath,
      Paint()..color = baseColor.withValues(alpha: dimmed ? 0.62 : 0.95),
    );

    // Rim + top-left highlight for the glossy board-plastic look.
    canvas.drawPath(
      facePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = question ? 2 : 1.2
        ..color = Colors.white.withValues(alpha: dimmed ? 0.4 : 0.8),
    );
    canvas.drawLine(
      top,
      left,
      Paint()
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.5),
    );

    if (question) {
      // Gold "question space": the NAPLAN trigger tile.
      canvas.drawPath(
        facePath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..color = Colors.amber,
      );
      final label = TextPainter(
        text: const TextSpan(
          text: '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(
        canvas,
        center - Offset(label.width / 2, label.height / 2 + 1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant BoardTilePainter oldDelegate) {
    return oldDelegate.totalStars != totalStars ||
        oldDelegate.positions != positions ||
        oldDelegate.zones != zones;
  }
}
