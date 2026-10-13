import 'package:flutter/material.dart';

/// WCAG-aware ink selection (2026-10-09 contrast pass).
///
/// Picks the label colour that keeps text on a background above 4.5:1: below
/// relative luminance 0.179 white wins, above it black does — the exact
/// crossover where both branches measure >= 4.58:1. Bright fills used to
/// pin white and failed in the live audit (cyan #00E5FF ≈ 1.6:1,
/// success #00C853 ≈ 2.0:1, Daily-Challenge orange ≈ 2.2:1).
///
/// Kept in one place: the colour-inventory test counts direct
/// `Color(0x…)`/`Colors.*` uses per file, so these two bookend inks are
/// written down exactly once here (allowlisted at 2) and every call site
/// derives its ink from a background it already has.
class InkTokens {
  const InkTokens._();

  /// Ink for glyphs/labels painted on top of [bg].
  static Color on(Color bg) =>
      bg.computeLuminance() < 0.179 ? Colors.white : Colors.black;

  /// Ink for accent-tinted chips: 10–15% of [tint] composited over the light
  /// card the chip sits on. Compositing (instead of the tint's own
  /// luminance) is what gives bright accents — amber, teal, red-zone — dark
  /// ink rather than the failing white-on-near-white this audit caught
  /// (teal ≈ 2.7:1, red zone ≈ 4.0:1 at 11 px).
  static Color onTint(Color tint) => on(Color.lerp(Colors.white, tint, 0.15)!);

  /// Lerp from [from] toward [to] but stop at the luminance floor where
  /// [on] flips its answer, so a gradient painted with `on(from)` ink
  /// stays ≥ 4.5:1 across every stop.
  ///
  /// Bright red/deep-orange zone primaries sit just above the crossover:
  /// white text already fails on them, but their darker secondaries fall
  /// below the floor where black would fail instead (red card measured
  /// 3.9–4.4:1 at the far diagonal end). Capping the ramp at 0.179 keeps
  /// black ink at exactly the crossover ratio (4.58:1) for the whole
  /// gradient. Ramps whose start takes white ink need no cap — every
  /// stop is below the floor and white clears 4.5:1 throughout.
  static Color lerpWithinInkFloor(Color from, Color to) {
    if (from.computeLuminance() < 0.179) return to;
    var lo = 0.0;
    var hi = 1.0;
    for (var i = 0; i < 24; i++) {
      final mid = (lo + hi) / 2;
      if (Color.lerp(from, to, mid)!.computeLuminance() >= 0.179) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return Color.lerp(from, to, lo)!;
  }
}
