import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Target class for interactive motor skills games
class MotorTarget {
  final String id;
  final Offset position;
  final double size;
  final Color color;
  final TargetType type;
  final int points;
  final double? speed; // For moving targets
  final Offset? direction; // For moving targets

  MotorTarget({
    required this.id,
    required this.position,
    this.size = 60,
    required this.color,
    this.type = TargetType.tap,
    this.points = 10,
    this.speed,
    this.direction,
  });

  MotorTarget copyWith({
    String? id,
    Offset? position,
    double? size,
    Color? color,
    TargetType? type,
    int? points,
    double? speed,
    Offset? direction,
  }) {
    return MotorTarget(
      id: id ?? this.id,
      position: position ?? this.position,
      size: size ?? this.size,
      color: color ?? this.color,
      type: type ?? this.type,
      points: points ?? this.points,
      speed: speed ?? this.speed,
      direction: direction ?? this.direction,
    );
  }
}

enum TargetType {
  tap, // Simple tap target
  doubleTap, // Double tap required
  longPress, // Hold target
  moving, // Moving target to catch
  drag, // Drag to destination
}

/// Game configuration for motor skills
class MotorGameConfig {
  final String skillId;
  final String name;
  final String description;
  final int rounds;
  final Duration roundDuration;
  final List<TargetType> targetTypes;
  final int targetCount;
  final double difficultyMultiplier;

  const MotorGameConfig({
    required this.skillId,
    required this.name,
    required this.description,
    this.rounds = 3,
    this.roundDuration = const Duration(seconds: 30),
    required this.targetTypes,
    this.targetCount = 5,
    this.difficultyMultiplier = 1.0,
  });
}

/// Predefined game configurations
class MotorGameConfigs {
  static const tapAccuracy = MotorGameConfig(
    skillId: 'skill_tap_accuracy',
    name: 'Tap Targets',
    description: 'Tap the targets as fast as you can!',
    targetTypes: [TargetType.tap],
    targetCount: 8,
    rounds: 3,
    roundDuration: Duration(seconds: 20),
  );

  static const reactionTime = MotorGameConfig(
    skillId: 'skill_reaction_time',
    name: 'Quick Reactions',
    description: 'Tap targets before they disappear!',
    targetTypes: [TargetType.tap, TargetType.moving],
    targetCount: 6,
    rounds: 3,
    roundDuration: Duration(seconds: 25),
    difficultyMultiplier: 1.2,
  );

  static const handEyeCoordination = MotorGameConfig(
    skillId: 'skill_hand_eye_coordination',
    name: 'Catch the Stars',
    description: 'Track and tap moving targets!',
    targetTypes: [TargetType.moving],
    targetCount: 10,
    rounds: 3,
    roundDuration: Duration(seconds: 30),
  );

  static const dragPrecision = MotorGameConfig(
    skillId: 'skill_drag_precision',
    name: 'Drag to Target',
    description: 'Drag items to their matching spots!',
    targetTypes: [TargetType.drag],
    targetCount: 5,
    rounds: 3,
    roundDuration: Duration(seconds: 35),
  );

  static const fineMotor = MotorGameConfig(
    skillId: 'skill_fine_motor',
    name: 'Precision Challenge',
    description: 'Tap small targets with precision!',
    targetTypes: [TargetType.tap, TargetType.doubleTap],
    targetCount: 10,
    rounds: 3,
    roundDuration: Duration(seconds: 30),
    difficultyMultiplier: 1.5,
  );

  static const swipeControl = MotorGameConfig(
    skillId: 'skill_swipe_control',
    name: 'Swipe Away',
    description: 'Swipe targets in the right direction!',
    targetTypes: [TargetType.drag],
    targetCount: 8,
    rounds: 3,
    roundDuration: Duration(seconds: 30),
  );

  static MotorGameConfig getForSkill(String skillId) {
    switch (skillId) {
      case 'skill_tap_accuracy':
        return tapAccuracy;
      case 'skill_reaction_time':
        return reactionTime;
      case 'skill_hand_eye_coordination':
        return handEyeCoordination;
      case 'skill_drag_precision':
        return dragPrecision;
      case 'skill_fine_motor':
        return fineMotor;
      case 'skill_swipe_control':
        return swipeControl;
      default:
        return tapAccuracy;
    }
  }
}

/// Track game results
class MotorGameResult {
  final int targetsHit;
  final int totalTargets;
  final int score;
  final Duration averageReactionTime;
  final double accuracy;

  const MotorGameResult({
    required this.targetsHit,
    required this.totalTargets,
    required this.score,
    required this.averageReactionTime,
    required this.accuracy,
  });

  int get xpEarned {
    int xp = targetsHit * 12;
    if (accuracy >= 0.9) xp += 40; // Bonus for high accuracy
    if (accuracy >= 1.0) xp += 20; // Perfect bonus
    return xp;
  }
}

/// Generator for random targets
class TargetGenerator {
  static final math.Random _random = math.Random();

  static final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
  ];

  static MotorTarget generateTarget({
    required Size screenSize,
    required TargetType type,
    double? sizeOverride,
    double difficultyMultiplier = 1.0,
  }) {
    const padding = 60.0;
    final size =
        sizeOverride ?? (80 - (20 * difficultyMultiplier)).clamp(30, 80);

    final x = padding +
        _random.nextDouble() * (screenSize.width - 2 * padding - size);
    final y = padding +
        100 +
        _random.nextDouble() * (screenSize.height - 2 * padding - size - 200);

    Offset? direction;
    double? speed;

    if (type == TargetType.moving) {
      final angle = _random.nextDouble() * 2 * math.pi;
      direction = Offset(math.cos(angle), math.sin(angle));
      speed = 50 + _random.nextDouble() * 100 * difficultyMultiplier;
    }

    return MotorTarget(
      id: 'target_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}',
      position: Offset(x, y),
      size: size.toDouble(),
      color: _colors[_random.nextInt(_colors.length)],
      type: type,
      points: (10 * difficultyMultiplier).round(),
      direction: direction,
      speed: speed,
    );
  }
}
