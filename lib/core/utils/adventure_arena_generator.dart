import 'dart:math';
import 'package:brightbound_adventures/features/motor/models/motor_game.dart';

/// Configuration generator for Adventure Arena (Motor Skills)
class AdventureArenaGenerator {
  static final Random _random = Random();
  
  /// Generate motor challenge configurations based on difficulty
  static MotorGameConfig generate({
    required String skill,
    required int difficulty,
  }) {
    if (difficulty <= 2) {
      return _generateEasyConfig(skill);
    } else if (difficulty <= 4) {
      return _generateMediumConfig(skill);
    } else {
      return _generateHardConfig(skill);
    }
  }
  
  static MotorGameConfig _generateEasyConfig(String skillId) {
    final configs = [
      // Simple tap targets with generous timing
      MotorGameConfig(
        skillId: skillId,
        name: 'Easy Tap Practice',
        description: 'Tap the targets at your own pace!',
        rounds: 3,
        roundDuration: const Duration(seconds: 30),
        targetTypes: [TargetType.tap],
        targetCount: 5,
        difficultyMultiplier: 0.7,
      ),
      // Slightly more targets
      MotorGameConfig(
        skillId: skillId,
        name: 'Gentle Challenge',
        description: 'Tap more targets, take your time!',
        rounds: 3,
        roundDuration: const Duration(seconds: 35),
        targetTypes: [TargetType.tap],
        targetCount: 6,
        difficultyMultiplier: 0.8,
      ),
      // Mix with double tap
      MotorGameConfig(
        skillId: skillId,
        name: 'Tap & Double Tap',
        description: 'Practice single and double taps!',
        rounds: 3,
        roundDuration: const Duration(seconds: 30),
        targetTypes: [TargetType.tap, TargetType.doubleTap],
        targetCount: 5,
        difficultyMultiplier: 0.9,
      ),
    ];
    
    return configs[_random.nextInt(configs.length)];
  }
  
  static MotorGameConfig _generateMediumConfig(String skillId) {
    final configs = [
      // Mixed interactions
      MotorGameConfig(
        skillId: skillId,
        name: 'Mixed Challenge',
        description: 'Tap, hold, and drag targets!',
        rounds: 3,
        roundDuration: const Duration(seconds: 35),
        targetTypes: [TargetType.tap, TargetType.longPress, TargetType.drag],
        targetCount: 8,
        difficultyMultiplier: 1.2,
      ),
      // Moving targets
      MotorGameConfig(
        skillId: skillId,
        name: 'Catch the Targets',
        description: 'Tap moving targets before they escape!',
        rounds: 3,
        roundDuration: const Duration(seconds: 30),
        targetTypes: [TargetType.tap, TargetType.moving],
        targetCount: 7,
        difficultyMultiplier: 1.3,
      ),
      // Quick reactions
      MotorGameConfig(
        skillId: skillId,
        name: 'Quick Reactions',
        description: 'Test your reaction speed!',
        rounds: 3,
        roundDuration: const Duration(seconds: 30),
        targetTypes: [TargetType.tap, TargetType.doubleTap],
        targetCount: 9,
        difficultyMultiplier: 1.4,
      ),
    ];
    
    return configs[_random.nextInt(configs.length)];
  }
  
  static MotorGameConfig _generateHardConfig(String skillId) {
    final configs = [
      // All interaction types
      MotorGameConfig(
        skillId: skillId,
        name: 'Master Challenge',
        description: 'Use all your motor skills!',
        rounds: 3,
        roundDuration: const Duration(seconds: 40),
        targetTypes: [
          TargetType.tap, 
          TargetType.doubleTap, 
          TargetType.longPress, 
          TargetType.drag,
        ],
        targetCount: 12,
        difficultyMultiplier: 1.8,
      ),
      // Fast moving targets
      MotorGameConfig(
        skillId: skillId,
        name: 'Speed Master',
        description: 'Catch fast-moving targets!',
        rounds: 3,
        roundDuration: const Duration(seconds: 35),
        targetTypes: [TargetType.tap, TargetType.moving],
        targetCount: 14,
        difficultyMultiplier: 2.0,
      ),
      // High count challenge
      MotorGameConfig(
        skillId: skillId,
        name: 'Precision Expert',
        description: 'Many targets, no mistakes!',
        rounds: 3,
        roundDuration: const Duration(seconds: 45),
        targetTypes: [TargetType.tap, TargetType.drag, TargetType.longPress],
        targetCount: 15,
        difficultyMultiplier: 1.9,
      ),
    ];
    
    return configs[_random.nextInt(configs.length)];
  }
}
