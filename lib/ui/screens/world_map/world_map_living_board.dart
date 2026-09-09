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
