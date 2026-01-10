import 'package:brightbound_adventures/core/models/index.dart';

class DifficultyScaler {
  /// Adjusts difficulty based on performance metrics
  /// Targets 70-80% accuracy as sweet spot
  static int calculateDifficulty({
    required double accuracy,
    required int attempts,
    required int hintsUsed,
    required int currentDifficulty,
  }) {
    // Increase difficulty if performing well
    if (accuracy > 0.85 && hintsUsed == 0 && attempts < 5) {
      return (currentDifficulty + 1).clamp(1, 5);
    }

    // Decrease difficulty if struggling
    if (accuracy < 0.60 || (attempts > 10 && accuracy < 0.70)) {
      return (currentDifficulty - 1).clamp(1, 5);
    }

    // Maintain current level
    return currentDifficulty;
  }

  /// Determines language complexity level (1-5)
  static String getLanguageComplexity(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'simple'; // Ages 4-5
      case 2:
        return 'early'; // Ages 6-7
      case 3:
        return 'intermediate'; // Ages 7-8
      case 4:
        return 'advanced'; // Ages 9-10
      case 5:
        return 'expert'; // Ages 10-12
      default:
        return 'intermediate';
    }
  }

  /// Determines distractor quality (number and difficulty of wrong answers)
  static int getDistractorCount(int difficulty) {
    return difficulty + 1; // 2 at level 1, 6 at level 5
  }

  /// Determines if time pressure should be applied
  static bool shouldApplyTimePressure(int difficulty) {
    return difficulty >= 3;
  }

  /// Gets time limit in seconds for timed activities
  static int getTimeLimit(int difficulty) {
    switch (difficulty) {
      case 1:
        return 60;
      case 2:
        return 45;
      case 3:
        return 35;
      case 4:
        return 25;
      case 5:
        return 15;
      default:
        return 35;
    }
  }

  /// Calculates required correct answers for mastery at given difficulty
  static int getMasteryThreshold(int difficulty) {
    switch (difficulty) {
      case 1:
        return 8; // 80% of 10
      case 2:
        return 10; // 83% of 12
      case 3:
        return 12; // 85% of 14
      case 4:
        return 14; // 87% of 16
      case 5:
        return 16; // 89% of 18
      default:
        return 12;
    }
  }
}

class ProgressionEngine {
  /// Updates skill state based on performance
  static Skill updateSkillProgress({
    required Skill skill,
    required double sessionAccuracy,
    required int sessionHints,
  }) {
    final newAttempts = skill.attempts + 1;
    final newAccuracy =
        (skill.accuracy * skill.attempts + sessionAccuracy) / newAttempts;
    final newHints = skill.hintsUsed + sessionHints;

    Skill updated = skill.copyWith(
      accuracy: newAccuracy,
      attempts: newAttempts,
      hintsUsed: newHints,
      lastPracticed: DateTime.now(),
    );

    // Check if state should progress
    final nextState = updated.getNextState();
    if (nextState != updated.state) {
      updated = updated.copyWith(state: nextState);
    }

    // Adjust difficulty
    final newDifficulty = DifficultyScaler.calculateDifficulty(
      accuracy: newAccuracy,
      attempts: newAttempts,
      hintsUsed: newHints,
      currentDifficulty: skill.difficulty,
    );

    return updated.copyWith(difficulty: newDifficulty);
  }

  /// Determines which skills should be available for practice
  static List<Skill> getAvailableSkills(List<Skill> allSkills) {
    // Filter to locked, introduced, and practising skills
    return allSkills
        .where((skill) =>
            skill.state != SkillState.locked &&
            skill.state != SkillState.mastered)
        .toList();
  }

  /// Selects next skill to practice based on spaced repetition
  static Skill? selectNextSkill(List<Skill> availableSkills) {
    if (availableSkills.isEmpty) return null;

    // Prioritize skills not practiced recently
    availableSkills.sort((a, b) => a.lastPracticed.compareTo(b.lastPracticed));

    return availableSkills.first;
  }
}
