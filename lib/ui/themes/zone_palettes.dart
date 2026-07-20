import 'package:flutter/material.dart';

/// One zone's colour identity, with values tuned separately for light and
/// dark presentation (not simply the light colour darkened by alpha).
@immutable
class ZonePalette {
  const ZonePalette({
    required this.primary,
    required this.secondary,
    required this.glow,
    required this.routeColor,
  });

  final Color primary;
  final Color secondary;
  final Color glow;
  final Color routeColor;

  static ZonePalette lerp(ZonePalette a, ZonePalette b, double t) {
    return ZonePalette(
      primary: Color.lerp(a.primary, b.primary, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      glow: Color.lerp(a.glow, b.glow, t)!,
      routeColor: Color.lerp(a.routeColor, b.routeColor, t)!,
    );
  }
}

/// Per-zone light/dark palettes for the 8 learning worlds.
///
/// Zone keys are snake_case (`word_woods`, `number_nebula`, ...), matching
/// the identifiers already used by gameplay/progress models
/// (`skill_database.dart`, `player_stats.dart`, `daily_challenge.dart`) and
/// the map asset manifest described in the v2.1 3D visual direction spec.
///
/// This complements, rather than replaces, `WorldTokens` in `app_theme.dart`
/// (which owns zone identity: display name, emoji, ambient particles,
/// subject). `ZonePalettes` is specifically the brightness-aware colour
/// contract that world-map and UI components should read from.
@immutable
class ZonePalettes extends ThemeExtension<ZonePalettes> {
  const ZonePalettes({required this.zones});

  final Map<String, ZonePalette> zones;

  ZonePalette forZone(String zoneId) {
    final key = _normalize(zoneId);
    return zones[key] ?? zones['word_woods']!;
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'^[^\w]+'), '')
      .replaceAll(RegExp(r'[\s-]+'), '_');

  static const light = ZonePalettes(zones: {
    'word_woods': ZonePalette(
      primary: Color(0xFF2D7D32),
      secondary: Color(0xFF1B5E20),
      glow: Color(0xFF81C784),
      routeColor: Color(0xFF66BB6A),
    ),
    'number_nebula': ZonePalette(
      primary: Color(0xFF3949AB),
      secondary: Color(0xFF1A237E),
      glow: Color(0xFF7986CB),
      routeColor: Color(0xFF5C6BC0),
    ),
    'math_facts': ZonePalette(
      primary: Color(0xFFE65100),
      secondary: Color(0xFFBF360C),
      glow: Color(0xFFFFB74D),
      routeColor: Color(0xFFFF8A50),
    ),
    'story_springs': ZonePalette(
      primary: Color(0xFF1565C0),
      secondary: Color(0xFF0D47A1),
      glow: Color(0xFF64B5F6),
      routeColor: Color(0xFF42A5F5),
    ),
    'science_explorers': ZonePalette(
      primary: Color(0xFF00695C),
      secondary: Color(0xFF004D40),
      glow: Color(0xFF4DB6AC),
      routeColor: Color(0xFF26A69A),
    ),
    'creative_corner': ZonePalette(
      primary: Color(0xFFC2185B),
      secondary: Color(0xFF880E4F),
      glow: Color(0xFFF06292),
      routeColor: Color(0xFFEC407A),
    ),
    'puzzle_peaks': ZonePalette(
      primary: Color(0xFF37474F),
      secondary: Color(0xFF263238),
      glow: Color(0xFF78909C),
      routeColor: Color(0xFF546E7A),
    ),
    'adventure_arena': ZonePalette(
      primary: Color(0xFFF9A825),
      secondary: Color(0xFFF57F17),
      glow: Color(0xFFFFEE58),
      routeColor: Color(0xFFFFCA28),
    ),
  });

  /// Dark variants: lifted lightness and reduced saturation on a dark base
  /// so each zone still reads as itself at night without glare.
  static const dark = ZonePalettes(zones: {
    'word_woods': ZonePalette(
      primary: Color(0xFF66BB6A),
      secondary: Color(0xFF43A047),
      glow: Color(0xFFA5D6A7),
      routeColor: Color(0xFF81C784),
    ),
    'number_nebula': ZonePalette(
      primary: Color(0xFF7986CB),
      secondary: Color(0xFF5C6BC0),
      glow: Color(0xFF9FA8DA),
      routeColor: Color(0xFF8C9EFF),
    ),
    'math_facts': ZonePalette(
      primary: Color(0xFFFFAB74),
      secondary: Color(0xFFFF8A50),
      glow: Color(0xFFFFCC9C),
      routeColor: Color(0xFFFFB088),
    ),
    'story_springs': ZonePalette(
      primary: Color(0xFF64B5F6),
      secondary: Color(0xFF42A5F5),
      glow: Color(0xFF90CAF9),
      routeColor: Color(0xFF82B1FF),
    ),
    'science_explorers': ZonePalette(
      primary: Color(0xFF4DB6AC),
      secondary: Color(0xFF26A69A),
      glow: Color(0xFF80CBC4),
      routeColor: Color(0xFF64D8CB),
    ),
    'creative_corner': ZonePalette(
      primary: Color(0xFFF48FB1),
      secondary: Color(0xFFEC407A),
      glow: Color(0xFFF8BBD0),
      routeColor: Color(0xFFFF80AB),
    ),
    'puzzle_peaks': ZonePalette(
      primary: Color(0xFF90A4AE),
      secondary: Color(0xFF78909C),
      glow: Color(0xFFB0BEC5),
      routeColor: Color(0xFFA1B4BC),
    ),
    'adventure_arena': ZonePalette(
      primary: Color(0xFFFFD54F),
      secondary: Color(0xFFFFCA28),
      glow: Color(0xFFFFE082),
      routeColor: Color(0xFFFFDA6B),
    ),
  });

  @override
  ZonePalettes copyWith({Map<String, ZonePalette>? zones}) {
    return ZonePalettes(zones: zones ?? this.zones);
  }

  @override
  ZonePalettes lerp(ThemeExtension<ZonePalettes>? other, double t) {
    if (other is! ZonePalettes) return this;
    final result = <String, ZonePalette>{};
    for (final key in zones.keys) {
      final a = zones[key]!;
      final b = other.zones[key] ?? a;
      result[key] = ZonePalette.lerp(a, b, t);
    }
    return ZonePalettes(zones: result);
  }
}

extension ZonePalettesContext on BuildContext {
  /// Shorthand for the current theme's [ZonePalettes], falling back to
  /// light values if the extension is somehow missing.
  ZonePalettes get zonePalettes =>
      Theme.of(this).extension<ZonePalettes>() ?? ZonePalettes.light;
}
