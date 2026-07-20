import 'package:flutter/material.dart';

/// Shared motion vocabulary for BrightBound animations.
///
/// New animation code should read timings/curves from [MotionTokens.of]
/// rather than hard-coding `Duration`/`Curve` values, so the whole app
/// shares one motion language and reduced-motion is handled in one place.
class MotionTokens {
  const MotionTokens._({required this.reduced});

  final bool reduced;

  /// Resolves tokens for the current context. Reduced motion is already
  /// funneled into `MediaQuery.disableAnimations` at the app root in
  /// `main.dart` (platform preference OR the in-app accessibility toggle),
  /// so this is the single check every consumer needs.
  factory MotionTokens.of(BuildContext context) {
    return MotionTokens._(reduced: MediaQuery.of(context).disableAnimations);
  }

  // --- Durations ---------------------------------------------------------

  static const Duration _instant = Duration(milliseconds: 100);
  static const Duration _quick = Duration(milliseconds: 180);
  static const Duration _standard = Duration(milliseconds: 250);
  static const Duration _emphasised = Duration(milliseconds: 400);
  static const Duration _celebration = Duration(milliseconds: 850);

  /// Micro-feedback: press states, toggles. Always allowed, even reduced.
  Duration get instant => _instant;

  /// Small UI transitions: hover lift, badge pop, focus change.
  Duration get quick => _reduce(_quick);

  /// Default transitions: route changes, panel open/close.
  Duration get standard => _reduce(_standard);

  /// Larger choreographed moments: zone unlock, quest lens transition.
  Duration get emphasised => _reduce(_emphasised);

  /// One-shot celebration sequences: reward reveal, mastery, travel settle.
  /// Under reduced motion this collapses to [_standard] rather than
  /// vanishing entirely, since these moments carry information (what was
  /// earned), not just decoration.
  Duration get celebration => reduced ? _standard : _celebration;

  Duration _reduce(Duration value) => reduced ? _instant : value;

  // --- Curves --------------------------------------------------------------

  /// Default easing for most transitions.
  Curve get standardCurve => reduced ? Curves.linear : Curves.easeInOutCubic;

  /// Entrances: reveals, pop-ins, panel open.
  Curve get enterCurve => reduced ? Curves.linear : Curves.easeOutCubic;

  /// Exits: dismiss, panel close.
  Curve get exitCurve => reduced ? Curves.linear : Curves.easeInCubic;

  /// Playful overshoot for rewards/unlocks. Never used under reduced motion.
  Curve get bounceCurve => reduced ? Curves.easeOut : Curves.easeOutBack;

  /// Maximum playfulness: level-up, chest opening. Never used under
  /// reduced motion.
  Curve get elasticCurve => reduced ? Curves.easeOut : Curves.elasticOut;

  // --- Distances -----------------------------------------------------------

  /// Standard press-down scale for buttons/answer options.
  double get pressScale => reduced ? 1.0 : 0.96;

  /// Standard hover/focus lift distance in logical pixels.
  double get hoverLift => reduced ? 0.0 : 6.0;
}
