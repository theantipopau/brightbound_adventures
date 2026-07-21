/// Named, semantic page routes built on [MotionTokens], so every navigation
/// in the app uses one of a small, deliberate set of motions instead of a
/// bespoke [PageRouteBuilder] per screen. Each route reads
/// `MotionTokens.of(context)` from the pushing context, so reduced motion
/// is handled automatically.
///
/// Pick the route by what the navigation *means*, not how it looks:
/// - [ZoneEntryRoute]: entering an activity/zone/quest — content scales up
///   from the element the player tapped (or from center if no origin is
///   known).
/// - [SheetRoute]: a modal-feeling full screen (settings, profile, parent
///   dashboard) — slides up from the bottom with a light spring overshoot.
/// - [CelebrationRoute]: a reward/results reveal — a bigger, more playful
///   scale-and-fade entrance.
library;

import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/themes/motion_tokens.dart';

/// Entering an activity/zone/quest: scales up (and fades in) from
/// [originRect] if provided, otherwise from the center of the screen.
class ZoneEntryRoute<T> extends PageRouteBuilder<T> {
  ZoneEntryRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    this.originRect,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: MotionTokens.of(context).emphasised,
          reverseTransitionDuration: MotionTokens.of(context).standard,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tokens = MotionTokens.of(context);
            final curved = CurvedAnimation(
              parent: animation,
              curve: tokens.enterCurve,
              reverseCurve: tokens.exitCurve,
            );
            final alignment = originRect == null
                ? Alignment.center
                : _alignmentFor(originRect, MediaQuery.of(context).size);
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
                alignment: alignment,
                child: child,
              ),
            );
          },
        );

  /// Screen-space rect of the element that triggered navigation (e.g. a
  /// tapped zone card), used so the scale-up originates from it.
  final Rect? originRect;

  static Alignment _alignmentFor(Rect rect, Size screenSize) {
    if (screenSize.width == 0 || screenSize.height == 0) {
      return Alignment.center;
    }
    final center = rect.center;
    final dx = ((center.dx / screenSize.width) * 2 - 1).clamp(-1.0, 1.0);
    final dy = ((center.dy / screenSize.height) * 2 - 1).clamp(-1.0, 1.0);
    return Alignment(dx, dy);
  }
}

/// A modal-feeling full screen (settings, profile, parent dashboard):
/// slides up from the bottom with a light spring overshoot.
class SheetRoute<T> extends PageRouteBuilder<T> {
  SheetRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    super.settings,
    super.fullscreenDialog = true,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: MotionTokens.of(context).standard,
          reverseTransitionDuration: MotionTokens.of(context).quick,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tokens = MotionTokens.of(context);
            final curved = CurvedAnimation(
              parent: animation,
              // bounceCurve gives the "spring" overshoot; reduced motion
              // collapses it to a plain ease automatically.
              curve: tokens.bounceCurve,
              reverseCurve: tokens.exitCurve,
            );
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: tokens.enterCurve,
                reverseCurve: tokens.exitCurve,
              ),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}

/// A reward/results reveal: a bigger, more playful scale-and-fade entrance
/// than [ZoneEntryRoute]. Never used under reduced motion (collapses to a
/// plain fade via [MotionTokens.elasticCurve]/[MotionTokens.celebration]).
class CelebrationRoute<T> extends PageRouteBuilder<T> {
  CelebrationRoute({
    required BuildContext context,
    required WidgetBuilder builder,
    super.settings,
  }) : super(
          opaque: false,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: MotionTokens.of(context).celebration,
          reverseTransitionDuration: MotionTokens.of(context).standard,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tokens = MotionTokens.of(context);
            final curved = CurvedAnimation(
              parent: animation,
              curve: tokens.elasticCurve,
              reverseCurve: tokens.exitCurve,
            );
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: tokens.enterCurve,
                reverseCurve: tokens.exitCurve,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.7, end: 1.0).animate(curved),
                child: child,
              ),
            );
          },
        );
}
