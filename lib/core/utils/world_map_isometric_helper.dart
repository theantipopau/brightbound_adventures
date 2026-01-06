import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/utils/isometric_engine.dart';
import 'package:brightbound_adventures/core/models/index.dart';

/// Helper class to integrate isometric engine with world map
class WorldMapIsometricHelper {
  // Grid dimensions - world is 10x10 tiles
  static const int gridWidth = 10;
  static const int gridHeight = 10;
  
  // Tile dimensions for isometric projection
  static const double tileWidth = 100.0;
  static const double tileHeight = 50.0;
  
  // Create the isometric engine
  static final IsometricEngine engine = IsometricEngine(
    tileWidth: tileWidth,
    tileHeight: tileHeight,
  );
  
  /// Convert zone data to isometric positions
  /// Takes normalized 0-1 positions and converts to grid coordinates
  static IsometricPosition zoneToIsometric(ZoneData zone) {
    // Convert normalized position to grid coordinates
    final gridX = (zone.position.dx * (gridWidth - 1)).round();
    final gridY = (zone.position.dy * (gridHeight - 1)).round();
    final gridZ = 0; // All zones on ground level for now
    
    return IsometricPosition(gridX, gridY, gridZ);
  }
  
  /// Get all zone isometric positions
  static Map<String, IsometricPosition> getZonePositions(List<ZoneData> zones) {
    final Map<String, IsometricPosition> positions = {};
    
    for (var zone in zones) {
      positions[zone.id] = zoneToIsometric(zone);
    }
    
    return positions;
  }
  
  /// Convert isometric grid position to screen position
  /// with screen-space offsets for centering
  static Offset gridToScreen(
    IsometricPosition pos, 
    Size screenSize,
  ) {
    // Get base isometric screen coordinates
    final isoOffset = engine.gridToScreen(pos);
    
    // Add centering offset to place grid in middle of screen
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2 - 100; // Slightly up from center
    
    // Grid origin offset (center of 10x10 grid)
    final gridCenterX = (gridWidth / 2) * tileWidth / 2;
    final gridCenterY = (gridHeight / 2) * tileHeight;
    
    return Offset(
      isoOffset.dx + centerX - gridCenterX,
      isoOffset.dy + centerY - gridCenterY,
    );
  }
  
  /// Sort zones by depth for proper rendering order
  static List<T> sortByDepth<T>(
    List<T> items,
    IsometricPosition Function(T) getPosition,
  ) {
    final sorted = List<T>.from(items);
    sorted.sort((a, b) {
      final posA = getPosition(a);
      final posB = getPosition(b);
      return engine.compareDepth(posA, posB);
    });
    return sorted;
  }
  
  /// Calculate path between two zones for avatar movement
  static List<IsometricPosition> calculatePath(
    IsometricPosition start,
    IsometricPosition end,
  ) {
    // For world map, zones are far apart, so direct path is fine
    // In more complex scenarios, use IsometricPathfinder
    final pathfinder = IsometricPathfinder();
    
    // Create walkable grid (all tiles walkable for world map)
    bool isWalkable(IsometricPosition pos) {
      return pos.gridX >= 0 && pos.gridX < gridWidth &&
             pos.gridY >= 0 && pos.gridY < gridHeight;
    }
    
    return pathfinder.findPath(start, end, isWalkable) ?? [start, end];
  }
  
  /// Create movement controller for avatar
  static IsometricMovementController createMovementController({
    required IsometricPosition start,
    required IsometricPosition target,
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return IsometricMovementController(
      vsync: vsync,
      duration: duration,
      tileWidth: tileWidth,
      tileHeight: tileHeight,
    );
  }
}
