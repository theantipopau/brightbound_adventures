import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/zone_data.dart';

/// Single source of truth for the eight BrightBound world zones.
///
/// Before this existed, the same eight zones (id, name, emoji, colour,
/// position, description, order, requiredStars) were hand-copied in
/// `world_map_screen.dart`, `profile_stats_screen.dart` (an incomplete,
/// stale 5-zone copy), `world_entry_screen.dart` and `fantasy_map.dart`.
/// Any screen that needs the zone catalog — not the world map's own layout
/// data (isometric positions, elevations) — should read from here instead
/// of re-declaring the list.
///
/// Colour values are the literal values from `AppColors.wordWoodsColor`
/// etc. (`lib/ui/themes/app_theme.dart`), copied rather than imported so
/// `core/models/` does not depend on `ui/themes/` — `core/` stays UI-free.
class ZoneCatalog {
  const ZoneCatalog._();

  static const List<ZoneData> zones = [
    ZoneData(
      id: 'word-woods',
      name: 'Word Woods',
      emoji: '🌲',
      color: Color(0xFF2D7D32),
      position: Offset(0.06, 0.86),
      description: 'Master letters & reading!',
      order: 0,
      requiredStars: 0,
    ),
    ZoneData(
      id: 'number-nebula',
      name: 'Number Nebula',
      emoji: '🌌',
      color: Color(0xFF3949AB),
      position: Offset(0.94, 0.84),
      description: 'Explore math & numbers!',
      order: 1,
      requiredStars: 3,
    ),
    ZoneData(
      id: 'math-facts',
      name: 'Math Facts',
      emoji: '🔢',
      color: Color(0xFFFF6B6B),
      position: Offset(0.18, 0.62),
      description: 'Master multiplication & addition!',
      order: 2,
      requiredStars: 6,
    ),
    ZoneData(
      id: 'story-springs',
      name: 'Story Springs',
      emoji: '📖',
      color: Color(0xFF1565C0),
      position: Offset(0.72, 0.60),
      description: 'Create amazing stories!',
      order: 3,
      requiredStars: 10,
    ),
    ZoneData(
      id: 'science-explorers',
      name: 'Science Explorers',
      emoji: '🔬',
      color: Color(0xFF4DB6AC),
      position: Offset(0.08, 0.36),
      description: 'Discover the world!',
      order: 4,
      requiredStars: 15,
    ),
    ZoneData(
      id: 'creative-corner',
      name: 'Creative Corner',
      emoji: '🎨',
      color: Color(0xFFFFB74D),
      position: Offset(0.82, 0.34),
      description: 'Draw and make music!',
      order: 5,
      requiredStars: 20,
    ),
    ZoneData(
      id: 'puzzle-peaks',
      name: 'Puzzle Peaks',
      emoji: '🧩',
      color: Color(0xFF6A1B9A),
      position: Offset(0.34, 0.18),
      description: 'Solve tricky puzzles!',
      order: 6,
      requiredStars: 22,
    ),
    ZoneData(
      id: 'adventure-arena',
      name: 'Adventure Arena',
      emoji: '🏆',
      color: Color(0xFFF9A825),
      position: Offset(0.60, 0.16),
      description: 'Ultimate challenges!',
      order: 7,
      requiredStars: 28,
    ),
  ];
}
