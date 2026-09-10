import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/utils/isometric_engine.dart';

/// Depth-sorted scene composition for zones and the avatar pawn.
///
/// Rendering and interaction remain callback-owned by the parent; this widget
/// only owns the stable ordering boundary for the Living Board scene layer.
class WorldMapSceneLayer extends StatelessWidget {
  final List<ZoneData> zones;
  final Avatar avatar;
  final Map<String, IsometricPosition> positions;
  final IsometricPosition avatarPosition;
  final Widget Function(ZoneData zone) zoneBuilder;
  final Widget Function(Avatar avatar, IsometricPosition position) avatarBuilder;
  final Map<String, String> zoneSemanticsLabels;
  final Map<String, String> zoneSemanticsHints;

  const WorldMapSceneLayer({
    super.key,
    required this.zones,
    required this.avatar,
    required this.positions,
    required this.avatarPosition,
    required this.zoneBuilder,
    required this.avatarBuilder,
    required this.zoneSemanticsLabels,
    required this.zoneSemanticsHints,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Object>[...zones, avatar];
    items.sort((left, right) {
      final leftPosition = _positionFor(left);
      final rightPosition = _positionFor(right);
      return leftPosition.depth.compareTo(rightPosition.depth);
    });

    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...items.map((item) {
            if (item is ZoneData) return zoneBuilder(item);
            return avatarBuilder(avatar, avatarPosition);
          }),
          ...zones.map(_semanticZoneNode),
        ],
      ),
    );
  }

  Widget _semanticZoneNode(ZoneData zone) {
    final position = positions[zone.id];
    if (position == null) return const SizedBox.shrink();
    return Positioned(
      left: position.x - 24,
      top: position.y - 24,
      child: Semantics(
        container: true,
        button: true,
        label: zoneSemanticsLabels[zone.id],
        hint: zoneSemanticsHints[zone.id],
        child: const SizedBox(width: 48, height: 48),
      ),
    );
  }

  IsometricPosition _positionFor(Object item) {
    if (item is ZoneData) return positions[item.id]!;
    return avatarPosition;
  }
}
