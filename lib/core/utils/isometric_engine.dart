import 'dart:math';
import 'package:flutter/material.dart';

/// Isometric position in 3D space
class IsometricPosition {
  final double x; // Grid X coordinate
  final double y; // Grid Y coordinate
  final double z; // Height/elevation

  const IsometricPosition(this.x, this.y, [this.z = 0]);

  /// Convert isometric grid position to screen coordinates
  Offset toScreen(double tileWidth, double tileHeight) {
    final screenX = (x - y) * tileWidth / 2;
    final screenY = (x + y) * tileHeight / 2 - z * tileHeight;
    return Offset(screenX, screenY);
  }

  /// Calculate depth for z-ordering (closer to camera = higher value)
  double get depth => x + y - z;

  /// Distance between two isometric positions
  double distanceTo(IsometricPosition other) {
    final dx = x - other.x;
    final dy = y - other.y;
    final dz = z - other.z;
    return sqrt(dx * dx + dy * dy + dz * dz);
  }

  /// Linear interpolation between positions for smooth movement
  IsometricPosition lerp(IsometricPosition target, double t) {
    return IsometricPosition(
      x + (target.x - x) * t,
      y + (target.y - y) * t,
      z + (target.z - z) * t,
    );
  }

  @override
  String toString() => 'IsoPos($x, $y, $z)';

  @override
  bool operator ==(Object other) =>
      other is IsometricPosition &&
      other.x == x &&
      other.y == y &&
      other.z == z;

  @override
  int get hashCode => Object.hash(x, y, z);
}

/// Manages isometric rendering and coordinate transformations
class IsometricEngine {
  final double tileWidth;
  final double tileHeight;

  /// Camera offset for panning/centering
  Offset cameraOffset;

  /// Camera zoom level (1.0 = normal, 2.0 = 2x zoom)
  double zoom;

  IsometricEngine({
    this.tileWidth = 64.0,
    this.tileHeight = 32.0,
    this.cameraOffset = Offset.zero,
    this.zoom = 1.0,
  });

  /// Convert grid position to screen position with camera transform
  Offset gridToScreen(IsometricPosition pos) {
    final screenPos = pos.toScreen(tileWidth, tileHeight);
    return Offset(
      screenPos.dx * zoom + cameraOffset.dx,
      screenPos.dy * zoom + cameraOffset.dy,
    );
  }

  /// Convert screen position to grid position (reverse transform)
  IsometricPosition screenToGrid(Offset screenPos) {
    // Remove camera transform
    final relativeX = (screenPos.dx - cameraOffset.dx) / zoom;
    final relativeY = (screenPos.dy - cameraOffset.dy) / zoom;

    // Inverse isometric transformation
    final gridX =
        (relativeX / (tileWidth / 2) + relativeY / (tileHeight / 2)) / 2;
    final gridY =
        (relativeY / (tileHeight / 2) - relativeX / (tileWidth / 2)) / 2;

    return IsometricPosition(gridX, gridY);
  }

  /// Center camera on a specific grid position
  void centerCamera(IsometricPosition pos, Size screenSize) {
    final screenPos = pos.toScreen(tileWidth, tileHeight);
    cameraOffset = Offset(
      screenSize.width / 2 - screenPos.dx * zoom,
      screenSize.height / 2 - screenPos.dy * zoom,
    );
  }

  /// Sort renderable objects by depth for proper z-ordering
  List<T> sortByDepth<T>(
      List<T> objects, IsometricPosition Function(T) getPosition) {
    final sorted = List<T>.from(objects);
    sorted.sort((a, b) {
      final depthA = getPosition(a).depth;
      final depthB = getPosition(b).depth;
      return depthA.compareTo(depthB);
    });
    return sorted;
  }

  /// Calculate the direction angle from one position to another (in radians)
  double getDirection(IsometricPosition from, IsometricPosition to) {
    return atan2(to.y - from.y, to.x - from.x);
  }

  /// Get cardinal direction (0-7 for 8-way movement) from angle
  int getCardinalDirection(double angleRadians) {
    // Normalize angle to 0-2π
    double normalized = angleRadians % (2 * pi);
    if (normalized < 0) normalized += 2 * pi;

    // Convert to 8 directions (0 = East, clockwise)
    return ((normalized + pi / 8) ~/ (pi / 4)) % 8;
  }
}

/// Smooth movement controller for animated transitions
class IsometricMovementController {
  final IsometricEngine engine;

  IsometricPosition currentPosition;
  IsometricPosition? targetPosition;

  double movementSpeed; // Grid units per second
  double _progress = 0.0;

  IsometricMovementController({
    required this.engine,
    required this.currentPosition,
    this.movementSpeed = 2.0,
  });

  /// Start moving to a target position
  void moveTo(IsometricPosition target) {
    targetPosition = target;
    _progress = 0.0;
  }

  /// Update position based on elapsed time (returns true if still moving)
  bool update(double deltaTime) {
    if (targetPosition == null) return false;

    final distance = currentPosition.distanceTo(targetPosition!);
    if (distance < 0.01) {
      currentPosition = targetPosition!;
      targetPosition = null;
      return false;
    }

    // Calculate progress increment based on speed
    final progressIncrement = (movementSpeed * deltaTime) / distance;
    _progress = (_progress + progressIncrement).clamp(0.0, 1.0);

    // Smooth interpolation with easing
    final easedProgress = _easeInOutCubic(_progress);
    currentPosition = currentPosition.lerp(targetPosition!, easedProgress);

    return true;
  }

  /// Cubic easing function for smoother movement
  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
  }

  /// Check if currently moving
  bool get isMoving => targetPosition != null;

  /// Get current screen position
  Offset get screenPosition => engine.gridToScreen(currentPosition);

  /// Get movement direction (0-7 for animation)
  int? get movementDirection {
    if (targetPosition == null) return null;
    final angle = engine.getDirection(currentPosition, targetPosition!);
    return engine.getCardinalDirection(angle);
  }
}

/// Helper class for pathfinding in isometric grids
class IsometricPathfinder {
  final Set<IsometricPosition> walkablePositions;

  IsometricPathfinder(this.walkablePositions);

  /// Find shortest path using A* algorithm
  List<IsometricPosition>? findPath(
      IsometricPosition start, IsometricPosition goal) {
    if (!walkablePositions.contains(goal)) return null;

    final openSet = <IsometricPosition>{start};
    final cameFrom = <IsometricPosition, IsometricPosition>{};
    final gScore = <IsometricPosition, double>{start: 0};
    final fScore = <IsometricPosition, double>{start: start.distanceTo(goal)};

    while (openSet.isNotEmpty) {
      // Get node with lowest fScore
      var current = openSet.first;
      var lowestF = fScore[current] ?? double.infinity;

      for (final node in openSet) {
        final f = fScore[node] ?? double.infinity;
        if (f < lowestF) {
          current = node;
          lowestF = f;
        }
      }

      if (current == goal) {
        return _reconstructPath(cameFrom, current);
      }

      openSet.remove(current);

      // Check neighbors (4-way movement)
      final neighbors = _getNeighbors(current);
      for (final neighbor in neighbors) {
        if (!walkablePositions.contains(neighbor)) continue;

        final tentativeGScore = (gScore[current] ?? double.infinity) + 1;

        if (tentativeGScore < (gScore[neighbor] ?? double.infinity)) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] = tentativeGScore + neighbor.distanceTo(goal);

          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
          }
        }
      }
    }

    return null; // No path found
  }

  List<IsometricPosition> _reconstructPath(
    Map<IsometricPosition, IsometricPosition> cameFrom,
    IsometricPosition current,
  ) {
    final path = <IsometricPosition>[current];
    while (cameFrom.containsKey(current)) {
      current = cameFrom[current]!;
      path.insert(0, current);
    }
    return path;
  }

  List<IsometricPosition> _getNeighbors(IsometricPosition pos) {
    return [
      IsometricPosition(pos.x + 1, pos.y, pos.z), // Right
      IsometricPosition(pos.x - 1, pos.y, pos.z), // Left
      IsometricPosition(pos.x, pos.y + 1, pos.z), // Down
      IsometricPosition(pos.x, pos.y - 1, pos.z), // Up
    ];
  }
}
