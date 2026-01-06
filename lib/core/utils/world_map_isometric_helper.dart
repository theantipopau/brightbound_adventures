import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/utils/isometric_engine.dart';

// Forward declaration - ZoneData is defined in world_map_screen.dart
// This helper works with any object that has a position property

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
  
  /// Convert zone position (Offset with dx/dy 0-1) to isometric position
  static IsometricPosition offsetToIsometric(Offset position) {
    // Convert normalized position to grid coordinates
    final gridX = (position.dx * (gridWidth - 1)).toDouble();
    final gridY = (position.dy * (gridHeight - 1)).toDouble();
    const gridZ = 0.0; // All zones on ground level for now
    
    return IsometricPosition(gridX, gridY, gridZ);
  }
  
  /// Get zone positions for zones with position property
  static Map<String, IsometricPosition> getZonePositions(List<dynamic> zones) {
    final Map<String, IsometricPosition> positions = {};
    
    for (var zone in zones) {
      // Access properties dynamically since we don't have compile-time type
      final id = (zone as dynamic).id as String;
      final position = (zone as dynamic).position as Offset;
      positions[id] = offsetToIsometric(position);
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
    return engine.sortByDepth(items, getPosition);
  }
  
  /// Calculate path between two zones for avatar movement
  static List<IsometricPosition> calculatePath(
    IsometricPosition start,
    IsometricPosition end,
  ) {
    // For world map, zones are far apart, so direct path is fine
    // Return simple two-point path
    return [start, end];
  }
}
