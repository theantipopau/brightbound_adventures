import 'package:flutter/material.dart';
import 'dart:math';

/// Model for a single confetti particle
class ConfettiParticle {
  final Offset initialPosition;
  final Offset velocity; // pixels per second
  final double rotation; // radians
  final double rotationSpeed; // radians per second
  final Color color;
  final double size;
  final double gravity; // pixels per second squared

  ConfettiParticle({
    required this.initialPosition,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
    this.gravity = 500.0,
  });

  /// Get position at given time elapsed (in seconds)
  Offset getPosition(double elapsed) {
    final x = initialPosition.dx + (velocity.dx * elapsed);
    final y = initialPosition.dy + (velocity.dy * elapsed) + (0.5 * gravity * elapsed * elapsed);
    return Offset(x, y);
  }

  /// Get rotation at given time elapsed (in seconds)
  double getRotation(double elapsed) {
    return rotation + (rotationSpeed * elapsed);
  }

  /// Get opacity (fades out over time)
  double getOpacity(double elapsed, double totalDuration) {
    final remaining = totalDuration - elapsed;
    // Fade out in last 0.3 seconds
    if (remaining < 0.3) {
      return remaining / 0.3;
    }
    return 1.0;
  }
}

/// Service for generating animations and animation data
class AnimationService {
  static final Random _random = Random();

  /// Generate confetti particles for correct answer celebration
  /// 
  /// [center] - Starting point for particles
  /// [count] - Number of particles (default 40)
  /// [colors] - Custom colors or defaults to rainbow
  static List<ConfettiParticle> generateConfetti({
    required Offset center,
    int count = 40,
    List<Color>? colors,
  }) {
    final colorList = colors ?? [
      Colors.red,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.orange,
      Colors.cyanAccent,
      Colors.amberAccent,
    ];

    return List.generate(count, (index) {
      // Explosive randomized distribution (Fountain/Firework style)
      // Angle: Full 360 degrees but with random jitter so it doesn't look like spokes
      final baseAngle = (2 * pi * index) / count;
      final angleJitter = (_random.nextDouble() - 0.5) * 0.5; // +/- ~15 degrees variation
      final angle = baseAngle + angleJitter;
      
      // Speed: Much higher variance for "pop" feel
      final speed = 300 + _random.nextDouble() * 600; // 300-900 px/s

      // Gravity: Slight variance to separate particles vertically over time
      final gravityVar = 400.0 + _random.nextDouble() * 400.0;

      return ConfettiParticle(
        initialPosition: center,
        velocity: Offset(
          cos(angle) * speed,
          sin(angle) * speed,
        ),
        rotation: _random.nextDouble() * 2 * pi,
        rotationSpeed: (_random.nextDouble() - 0.5) * 25, // Fast spin
        color: colorList[_random.nextInt(colorList.length)],
        size: 6 + _random.nextDouble() * 14, // 6-20 px (larger variance)
        gravity: gravityVar,
      );
    });
  }

  /// Calculate screen shake offset for wrong answer feedback
  /// 
  /// [elapsed] - Time elapsed in animation (0.0 to 1.0)
  /// [intensity] - How far to shake (default 10 pixels)
  static Offset getShakeOffset(double elapsed, {double intensity = 10.0}) {
    // Damped sine wave - shakes more at start, settles down
    final dampening = pow(1.0 - elapsed, 2).toDouble(); // Quadratic decay
    final frequency = 15.0; // How many shakes per second
    final shakeAngle = sin(elapsed * 2 * pi * frequency);

    return Offset(
      shakeAngle * intensity * dampening,
      0, // Only shake horizontally
    );
  }

  /// Calculate scale for pop/bounce animation
  /// 
  /// [elapsed] - Time elapsed (0.0 to 1.0)
  /// Returns scale factor (1.0 = normal size)
  static double getBounceScale(double elapsed) {
    // Elastic bounce: start small, expand, slightly overshoot, settle
    if (elapsed < 0.6) {
      // First phase: expand with overshoot
      return Curves.easeOut.transform(elapsed / 0.6) * 1.15;
    } else {
      // Second phase: settle back down
      return 1.0 + (0.15 * Curves.easeOut.transform(1.0 - ((elapsed - 0.6) / 0.4)));
    }
  }

  /// Generate staggered animation timings for text reveal
  /// 
  /// [textLength] - Length of text to reveal
  /// [totalDuration] - Total reveal duration in milliseconds
  /// Returns list of start times for each character
  static List<Duration> getTextRevealTimings({
    required int textLength,
    required int totalDuration,
  }) {
    final staggerDelay = totalDuration ~/ (textLength + 1);
    return List.generate(
      textLength,
      (index) => Duration(milliseconds: staggerDelay * (index + 1)),
    );
  }

  /// Create a smooth color animation sequence
  /// 
  /// [startColor] - Starting color
  /// [endColor] - Ending color
  /// [elapsed] - Time elapsed (0.0 to 1.0)
  static Color colorLerp(Color startColor, Color endColor, double elapsed) {
    return Color.lerp(startColor, endColor, elapsed) ?? startColor;
  }

  /// Calculate particle opacity with fade in/out
  /// 
  /// [elapsed] - Time elapsed (0.0 to 1.0)
  /// [fadeInDuration] - Fade in time (0.0-1.0 relative)
  /// [fadeOutDuration] - Fade out time (0.0-1.0 relative)
  static double getParticleOpacity(
    double elapsed, {
    double fadeInDuration = 0.1,
    double fadeOutDuration = 0.3,
  }) {
    // Fade in phase
    if (elapsed < fadeInDuration) {
      return elapsed / fadeInDuration;
    }

    // Fade out phase
    final fadeOutStart = 1.0 - fadeOutDuration;
    if (elapsed > fadeOutStart) {
      return (1.0 - elapsed) / fadeOutDuration;
    }

    // Full opacity
    return 1.0;
  }
}
