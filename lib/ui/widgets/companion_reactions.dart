import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/ui/widgets/animated_character.dart';

/// A3 — companion emotion animations.
///
/// Reads [AvatarProvider.emotion] and plays a choreographed reaction on the
/// wrapped companion widget:
///
/// * `celebrate` — bounce + tilt-spin, 0.6 s (correct answers)
/// * `encourage` — droop then recover, 0.5 s (wrong answers)
/// * `levelUp`   — full hop + glow ring, 1.2 s (XP level transitions)
/// * `mastered`  — star-burst pose, 1.0 s (zone/skill mastery)
/// * `neutral` (idle) — returns cleanly; the provider's reset timer drives it
///
/// Reduced motion (`MediaQuery.disableAnimations`): transforms collapse to a
/// single static frame — the emoji badge still shows, no loops, no drift.
///
/// The widget owns no animation controller for emotion triggers; every state
/// change is a *one-shot* from a [Tween] with [TweenAnimationBuilder], so a
/// fast correct/wrong/correct sequence restarts smoothly instead of stacking
/// controller updates. There are no lingering timers here — [AvatarProvider]
/// owns the reset.
class CompanionReactions extends StatelessWidget {
  /// The companion widget this reaction layer wraps (an excerpt of the
  /// avatar rendering — `AnimatedCharacter`, an emoji portrait, etc.).
  final Widget child;

  /// Base size used by the reaction choreography.
  final double size;

  const CompanionReactions({
    super.key,
    required this.child,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    return _ReactionsBody(
      size: size,
      child: child,
    );
  }
}

/// Floating corner companion for quiz screens.
///
/// Renders the child's character (from [AvatarProvider]) wrapped in
/// [CompanionReactions] so celebrate/encourage/level-up/mastered reactions
/// play next to the question. Drop this into any quiz Scaffold's Stack:
///
/// ```dart
/// const Positioned(
///   top: 12,
///   right: 12,
///   child: QuizCompanionCorner(),
/// )
/// ```
///
/// Pointer-transparent so it never steals answer taps; hidden entirely when
/// no avatar exists (pre-creation state).
class QuizCompanionCorner extends StatelessWidget {
  /// Which screen corner the companion occupies.
  final AlignmentGeometry alignment;

  /// Extra inset inside the alignment's corner.
  final EdgeInsets padding;

  const QuizCompanionCorner({
    super.key,
    this.alignment = Alignment.topRight,
    this.padding = const EdgeInsets.fromLTRB(8, 60, 8, 8),
  });

  @override
  Widget build(BuildContext context) {
    final avatar = context.select<AvatarProvider, Avatar?>(
      (AvatarProvider p) => p.avatar,
    );
    if (avatar == null) return const SizedBox.shrink();

    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: IgnorePointer(
          child: CompanionReactions(
            size: 56,
            child: AnimatedCharacter(
              character: avatar.baseCharacter,
              skinColor: avatar.skinColor,
              size: 56,
              animation: CharacterAnimation.idle,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactionsBody extends StatelessWidget {
  final Widget child;
  final double size;

  const _ReactionsBody({required this.child, required this.size});

  @override
  Widget build(BuildContext context) {
    final emotion = context.select<AvatarProvider, AvatarEmotion?>(
      (AvatarProvider p) => p.emotion,
    );
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final emoji = context.select<AvatarProvider, String>(
      (AvatarProvider p) => p.emotionEmoji,
    );

    return SizedBox(
      width: size * 1.8,
      height: size * 1.9,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (!reduceMotion)
            _MotionLayer(
              emotion: emotion,
              size: size,
              child: child,
            )
          else
            // Reduced motion: static pose for the reactive states, plain
            // child otherwise.
            child,
          if (emotion != null &&
              emotion != AvatarEmotion.neutral &&
              emoji.isNotEmpty)
            Positioned(
              top: -6,
              right: 2,
              child: _EmotionBadge(emotion: emotion, emoji: emoji),
            ),
          if (!reduceMotion && emotion == AvatarEmotion.levelUp)
            const Positioned.fill(child: _LevelGlowRing()),
          if (!reduceMotion && emotion == AvatarEmotion.mastered)
            const Positioned.fill(child: _StarBurstPainter()),
        ],
      ),
    );
  }
}

/// One-shot transform choreography for each reactive emotion.
class _MotionLayer extends StatelessWidget {
  final AvatarEmotion? emotion;
  final double size;
  final Widget child;

  const _MotionLayer({
    required this.emotion,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    switch (emotion) {
      // Pre-existing emotion vocabulary keeps its reaction: joy/pride use
      // the celebrate choreography, sadness the encourage droop — the
      // games' emotion calls need no changes to look alive.
      case AvatarEmotion.happy:
      case AvatarEmotion.proud:
      case AvatarEmotion.celebrate:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, t, _) {
            return Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..translateByDouble(0.0, -size * 0.28 * math.sin(t * math.pi),
                    0.0, 1.0)
                ..rotateZ(math.sin(t * math.pi * 2) * 0.12)
                ..scaleByDouble(1.0 + 0.12 * math.sin(t * math.pi),
                    1.0 + 0.12 * math.sin(t * math.pi), 1.0, 1.0),
              child: child,
            );
          },
        );
      case AvatarEmotion.sad:
      case AvatarEmotion.encourage:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) {
            // Droop (first 40%) then recover on an elastic tail.
            final droop = t < 0.4
                ? Curves.easeIn.transform(t / 0.4)
                : 1.0 - Curves.elasticOut.transform((t - 0.4) / 0.6);
            return Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..translateByDouble(0.0, size * 0.12 * droop, 0.0, 1.0)
                ..rotateZ(0.10 * droop)
                ..scaleByDouble(1.0 - 0.08 * droop, 1.0 + 0.10 * droop, 1.0,
                    1.0),
              child: child,
            );
          },
        );
      case AvatarEmotion.levelUp:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.elasticOut,
          builder: (context, t, _) {
            final hop = math.sin(t * math.pi * 2) * -size * 0.4 *
                (1 - t).clamp(0.05, 1.0);
            return Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..translateByDouble(0.0, hop, 0.0, 1.0)
                ..scaleByDouble(1.0 + 0.14 * math.sin(t * math.pi),
                    1.0 + 0.14 * math.sin(t * math.pi), 1.0, 1.0),
              child: child,
            );
          },
        );
      case AvatarEmotion.mastered:
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1000),
          curve: Curves.elasticOut,
          builder: (context, t, _) {
            return Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..translateByDouble(0.0, -size * 0.2 * math.sin(t * math.pi),
                    0.0, 1.0)
                ..scaleByDouble(1.0 + 0.2 * Curves.easeOutBack.transform(t),
                    1.0 + 0.2 * Curves.easeOutBack.transform(t), 1.0, 1.0),
              child: child,
            );
          },
        );
      default:
        return child;
    }
  }
}

/// Small floating emoji badge naming the current reaction.
class _EmotionBadge extends StatelessWidget {
  final AvatarEmotion emotion;
  final String emoji;

  const _EmotionBadge({required this.emotion, required this.emoji});

  @override
  Widget build(BuildContext context) {
    final glow = switch (emotion) {
      AvatarEmotion.celebrate ||
      AvatarEmotion.levelUp ||
      AvatarEmotion.mastered =>
        const Color(0xFFFFC94A),
      _ => const Color(0xFF90A4AE),
    };
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      builder: (context, t, _) {
        return Transform.scale(
          scale: t,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: 0.55),
                  blurRadius: 10 * t,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
        );
      },
    );
  }
}

/// Soft expanding glow ring behind a level-up reaction.
class _LevelGlowRing extends StatelessWidget {
  const _LevelGlowRing();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      builder: (context, t, _) {
        return DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF64FFDA).withValues(alpha: 0.35 * (1 - t)),
                Colors.transparent,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Starburst rays painted around a mastery reaction.
class _StarBurstPainter extends StatelessWidget {
  const _StarBurstPainter();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      builder: (context, t, _) {
        return CustomPaint(
          painter: _StarBurstWrapper(t),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _StarBurstWrapper extends CustomPainter {
  final double t;
  _StarBurstWrapper(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFC94A).withValues(alpha: 0.75 * (1 - t));
    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + t * 0.6;
      final radius = 14 + t * size.shortestSide * 0.45;
      final point = centre.translate(math.cos(angle) * radius,
          math.sin(angle) * radius);
      canvas.drawCircle(point, 2.5 * (1 - t) + 1, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarBurstWrapper oldDelegate) =>
      oldDelegate.t != t;
}
