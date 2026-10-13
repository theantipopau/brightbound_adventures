import 'package:flutter/material.dart';

/// Generated zone badge art with the zone emoji as graceful fallback.
///
/// The PNGs in `assets/images/zones/` (see `tool/generate_zone_assets.py`)
/// are the primary world art on the map and detail screens. If an asset is
/// missing — partial install, unit-test bundle, unknown zone id — the emoji
/// keeps the UI complete instead of leaving a gap.
class ZoneBadge extends StatelessWidget {
  const ZoneBadge({
    super.key,
    required this.asset,
    required this.emoji,
    this.size = 40,
  });

  final String asset;
  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(
            emoji,
            // Decorative glyph: fixed size, never driven by the platform
            // text-scale setting (same rule as the zone-island icon).
            textScaler: TextScaler.noScaling,
            style: TextStyle(fontSize: size * 0.62),
          ),
        ),
      ),
    );
  }
}
