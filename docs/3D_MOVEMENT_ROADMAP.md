# 3D World Map Movement - Implementation Roadmap

## Overview
Implement Pokémon-style 3D movement around the world map, allowing players to navigate using arrow keys or D-pad on a 2.5D isometric-style perspective.

## Current State
- World map is currently 2D with fantasy map theme
- Keyboard navigation exists (arrow keys move between zones)
- Avatar position is tracked but not with 3D depth perception

## Implementation Plan

### Phase 1: Isometric Perspective Engine
- [ ] Create `IsometricEngine` class to handle coordinate transformation
  - Convert 2D grid coordinates to isometric screen positions
  - Handle depth sorting for proper layering
  - Calculate visual Z-order based on Y position
  
```dart
class IsometricPosition {
  final int gridX;
  final int gridY;
  final double visualX;  // Calculated from grid
  final double visualY;  // Calculated from grid
}
```

### Phase 2: Enhanced Movement
- [ ] Update `WorldMapScreen` avatar movement
  - Smooth interpolation between zones (not instant)
  - Pathfinding for multi-zone routes
  - Walking animation with directional sprites

### Phase 3: Visual Depth
- [ ] Implement depth-based sorting
  - Zones at bottom of map render behind character
  - Zones at top render in front
  - Character shadows based on position
  
### Phase 4: Camera System
- [ ] Optional: Implement camera follow mechanics
  - Center view on avatar
  - Smooth panning between zones
  - Boundary detection

## Technical Details

### Isometric Conversion Formula
```
screenX = (gridX - gridY) * tileWidth/2
screenY = (gridX + gridY) * tileHeight/2
```

### Integration Points
- File: `lib/ui/screens/world_map_screen.dart`
- Modify: `_moveToZone()`, `_buildZonePositions()`
- Create: `lib/core/utils/isometric_engine.dart`

## Dependencies
- Already have: animation controllers, gesture detection
- May need: improved character sprites with directional variants

## Estimated Effort
- Core engine: 2-4 hours
- Integration: 1-2 hours
- Testing & refinement: 1-2 hours
- **Total: 4-8 hours**

## Alternative: Simplified Approach
If 3D is not critical, enhance current 2D movement with:
- Smoother transitions between zones
- Better walking animations
- Path preview before moving
- This would take 1-2 hours instead
