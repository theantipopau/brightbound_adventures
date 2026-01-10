import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to manage adaptive difficulty based on player performance
class AdaptiveDifficultyService extends ChangeNotifier {
  static const String _performanceKey = 'adaptive_difficulty_performance';
  static const int _historyLength = 5; // Track last 5 answers per skill

  // Map of skillId -> list of recent correct/incorrect (true/false)
  final Map<String, List<bool>> _performanceHistory = {};

  // Map of skillId -> current difficulty level (1-3)
  final Map<String, int> _skillDifficulty = {};

  bool _initialized = false;

  bool get initialized => _initialized;

  /// Initialize the service and load performance history
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_performanceKey);

      if (historyJson != null) {
        final data = json.decode(historyJson) as Map<String, dynamic>;

        // Load performance history
        final history = data['history'] as Map<String, dynamic>? ?? {};
        for (final entry in history.entries) {
          _performanceHistory[entry.key] = List<bool>.from(entry.value as List);
        }

        // Load difficulty levels
        final difficulty = data['difficulty'] as Map<String, dynamic>? ?? {};
        for (final entry in difficulty.entries) {
          _skillDifficulty[entry.key] = entry.value as int;
        }
      }
    } catch (e) {
      debugPrint('Error loading adaptive difficulty: $e');
    }

    _initialized = true;
    notifyListeners();
  }

  /// Get the current difficulty level for a skill (1-3)
  int getDifficultyForSkill(String skillId) {
    return _skillDifficulty[skillId] ?? 1; // Default to level 1
  }

  /// Record an answer and potentially adjust difficulty
  Future<void> recordAnswer({
    required String skillId,
    required bool wasCorrect,
  }) async {
    // Add to history
    if (!_performanceHistory.containsKey(skillId)) {
      _performanceHistory[skillId] = [];
    }

    _performanceHistory[skillId]!.add(wasCorrect);

    // Keep only last N answers
    if (_performanceHistory[skillId]!.length > _historyLength) {
      _performanceHistory[skillId]!.removeAt(0);
    }

    // Adjust difficulty based on recent performance
    await _adjustDifficulty(skillId);

    // Persist changes
    await _saveToStorage();
    notifyListeners();
  }

  /// Adjust difficulty based on recent performance
  Future<void> _adjustDifficulty(String skillId) async {
    final history = _performanceHistory[skillId];
    if (history == null || history.length < 3) {
      return; // Need at least 3 answers to adjust
    }

    final currentDifficulty = _skillDifficulty[skillId] ?? 1;
    final recentCorrect = history.where((correct) => correct).length;
    final totalRecent = history.length;
    final accuracy = recentCorrect / totalRecent;

    // Check last 3 answers for consecutive patterns
    final lastThree =
        history.length >= 3 ? history.sublist(history.length - 3) : history;
    final threeInARow = lastThree.length == 3 && lastThree.every((c) => c);
    final twoWrongInRow = history.length >= 2 &&
        !history[history.length - 1] &&
        !history[history.length - 2];

    int newDifficulty = currentDifficulty;

    // Increase difficulty if:
    // - 3 correct in a row, OR
    // - Accuracy >= 90% and not at max difficulty
    if (threeInARow || (accuracy >= 0.9 && currentDifficulty < 3)) {
      newDifficulty = (currentDifficulty + 1).clamp(1, 3);
      if (newDifficulty != currentDifficulty) {
        debugPrint(
            '📈 Increasing difficulty for $skillId: $currentDifficulty → $newDifficulty');
      }
    }
    // Decrease difficulty if:
    // - 2 wrong in a row, OR
    // - Accuracy < 40% and not at min difficulty
    else if (twoWrongInRow || (accuracy < 0.4 && currentDifficulty > 1)) {
      newDifficulty = (currentDifficulty - 1).clamp(1, 3);
      if (newDifficulty != currentDifficulty) {
        debugPrint(
            '📉 Decreasing difficulty for $skillId: $currentDifficulty → $newDifficulty');
      }
    }

    _skillDifficulty[skillId] = newDifficulty;
  }

  /// Get recent performance for a skill
  List<bool> getRecentPerformance(String skillId) {
    return List.from(_performanceHistory[skillId] ?? []);
  }

  /// Get accuracy for recent performance (0.0 to 1.0)
  double getRecentAccuracy(String skillId) {
    final history = _performanceHistory[skillId];
    if (history == null || history.isEmpty) return 0.0;

    final correct = history.where((c) => c).length;
    return correct / history.length;
  }

  /// Get a difficulty recommendation message for UI
  String getDifficultyMessage(String skillId) {
    final difficulty = getDifficultyForSkill(skillId);
    final accuracy = getRecentAccuracy(skillId);
    final history = _performanceHistory[skillId];

    if (history == null || history.isEmpty) {
      return 'Starting at level $difficulty';
    }

    if (accuracy >= 0.8) {
      return 'Great work! Level $difficulty';
    } else if (accuracy >= 0.6) {
      return 'Keep practicing! Level $difficulty';
    } else {
      return 'You can do it! Level $difficulty';
    }
  }

  /// Reset difficulty for a skill (useful for retry)
  Future<void> resetSkillDifficulty(String skillId) async {
    _skillDifficulty[skillId] = 1;
    _performanceHistory[skillId]?.clear();
    await _saveToStorage();
    notifyListeners();
  }

  /// Reset all difficulties
  Future<void> resetAll() async {
    _skillDifficulty.clear();
    _performanceHistory.clear();
    await _saveToStorage();
    notifyListeners();
  }

  /// Save to SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'history': _performanceHistory,
        'difficulty': _skillDifficulty,
      };
      await prefs.setString(_performanceKey, json.encode(data));
    } catch (e) {
      debugPrint('Error saving adaptive difficulty: $e');
    }
  }

  /// Get statistics for debugging/display
  Map<String, dynamic> getStats() {
    return {
      'totalSkills': _skillDifficulty.length,
      'difficulty1': _skillDifficulty.values.where((d) => d == 1).length,
      'difficulty2': _skillDifficulty.values.where((d) => d == 2).length,
      'difficulty3': _skillDifficulty.values.where((d) => d == 3).length,
      'averageAccuracy': _performanceHistory.isEmpty
          ? 0.0
          : _performanceHistory.values
                  .map((h) => h.where((c) => c).length / h.length)
                  .reduce((a, b) => a + b) /
              _performanceHistory.length,
    };
  }
}
