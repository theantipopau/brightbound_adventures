import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/core/models/question_history.dart';

/// Service to prevent question repetition and track question freshness
///
/// Ensures users see fresh questions through intelligent rotation while
/// maintaining spaced repetition at the skill level.
///
/// Key responsibilities:
/// - Track which questions have been shown
/// - Calculate "freshness score" (lower = fresher)
/// - Prevent same question appearing within configurable window (default 30 days)
/// - Generate question fingerprints for comparison
/// - Maintain question history for analytics
class QuestionFreshnessService extends ChangeNotifier {
  static const String _questionStatsKey = 'question_stats_v1';
  static const String _questionHistoryKey = 'question_history_v1';
  static const int _defaultFreshnessDays = 30;
  static const int _maxHistorySize = 500; // Limit to prevent storage bloat

  final Map<String, QuestionStatistics> _stats = {};
  final List<QuestionInstance> _history = [];
  bool _initialized = false;

  // ── Public API ────────────────────────────────────────────────────────────

  bool get isInitialized => _initialized;

  /// Get freshness score for a question (0 = fresh, 1+ = not fresh)
  /// Lower scores = fresher questions
  ///
  /// Scoring:
  /// - Never shown: 0.0
  /// - Shown but outside freshness window: 0.5
  /// - Shown recently: 1.0
  /// - Shown very recently (< 7 days): 2.0
  double getQuestionFreshnessScore(String questionHash) {
    final stats = _stats[questionHash];
    if (stats == null) return 0.0; // Never shown, very fresh

    final daysSinceSeen = stats.daysSinceLastShown;
    if (daysSinceSeen == null) return 0.0;

    if (daysSinceSeen < 7) {
      return 2.0; // Very recently shown
    } else if (daysSinceSeen < _defaultFreshnessDays) {
      return 1.0; // Recently shown
    } else {
      return 0.5; // Old enough to show again
    }
  }

  /// Check if a question should be shown (outside freshness window)
  bool isQuestionFresh(String questionHash,
      {int freshnessWindowDays = _defaultFreshnessDays}) {
    final stats = _stats[questionHash];
    if (stats == null) return true; // Never shown

    final daysSinceSeen = stats.daysSinceLastShown;
    if (daysSinceSeen == null) return true;

    return daysSinceSeen >= freshnessWindowDays;
  }

  /// Get all questions that have NOT been shown yet (freshest possible)
  List<String> getUnseenQuestionHashes(List<String> candidateHashes) {
    return candidateHashes.where((hash) => _stats[hash] == null).toList();
  }

  /// Get questions sorted by freshness (freshest first)
  /// Useful for selecting next question variant
  List<String> sortByFreshness(List<String> questionHashes) {
    final hashes = [...questionHashes];
    hashes.sort((a, b) {
      final scoreA = getQuestionFreshnessScore(a);
      final scoreB = getQuestionFreshnessScore(b);
      return scoreA.compareTo(scoreB); // Lower (fresher) comes first
    });
    return hashes;
  }

  /// Record that a question was shown to the user
  /// Should be called after user answers question
  Future<void> recordQuestionAsked(
    String questionHash, {
    required String skillId,
    required dynamic userAnswer,
    required dynamic correctAnswer,
    required int timeSpentMs,
    int? confidenceLevel,
    String? context,
    String? bloomLevel,
  }) async {
    // Create question instance
    final instance = QuestionInstance.create(
      skillId: skillId,
      questionHash: questionHash,
      userAnswer: userAnswer,
      correctAnswer: correctAnswer,
      timeSpentMs: timeSpentMs,
      confidenceLevel: confidenceLevel,
      context: context,
      bloomLevel: bloomLevel,
    );

    // Add to history (with limit)
    _history.add(instance);
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0); // Remove oldest
    }

    // Update stats
    final existing = _stats[questionHash] ??
        QuestionStatistics(
          questionHash: questionHash,
          timesShown: 0,
          correctCount: 0,
          avgTimeMs: 0,
        );

    _stats[questionHash] = existing.recordAttempt(
      isCorrect: instance.isCorrect,
      timeSpentMs: timeSpentMs,
    );

    await _persist();
    notifyListeners();
  }

  /// Get statistics for a question
  QuestionStatistics? getQuestionStatistics(String questionHash) {
    return _stats[questionHash];
  }

  /// Get history of all questions asked (for analytics)
  List<QuestionInstance> getHistory({
    String? forSkillId,
    int? lastDays,
  }) {
    var filtered = [..._history];

    if (forSkillId != null) {
      filtered = filtered.where((q) => q.skillId == forSkillId).toList();
    }

    if (lastDays != null) {
      final cutoff = DateTime.now().subtract(Duration(days: lastDays));
      filtered = filtered.where((q) => q.askedAt.isAfter(cutoff)).toList();
    }

    return filtered;
  }

  /// Get summary statistics
  Map<String, dynamic> getSummaryStats() {
    int totalQuestionsAsked = _history.length;
    int correctAnswers = _history.where((q) => q.isCorrect).length;
    double overallAccuracy =
        totalQuestionsAsked > 0 ? correctAnswers / totalQuestionsAsked : 0.0;

    int avgTimeMs = 0;
    if (_history.isNotEmpty) {
      avgTimeMs = _history.fold<int>(0, (sum, q) => sum + q.timeSpentMs) ~/
          _history.length;
    }

    return {
      'totalQuestionsAsked': totalQuestionsAsked,
      'correctAnswers': correctAnswers,
      'overallAccuracy': overallAccuracy,
      'averageTimeMs': avgTimeMs,
      'uniqueQuestionsAsked': _stats.length,
    };
  }

  /// Clear history (for testing or user request)
  Future<void> clearHistory() async {
    _history.clear();
    _stats.clear();
    await _persist();
    notifyListeners();
  }

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load stats
      final statsJson = prefs.getString(_questionStatsKey);
      if (statsJson != null) {
        try {
          final map = jsonDecode(statsJson) as Map<String, dynamic>;
          for (final entry in map.entries) {
            _stats[entry.key] = QuestionStatistics.fromJson(
              entry.value as Map<String, dynamic>,
            );
          }
        } catch (e) {
          debugPrint('Failed to load question stats: $e');
        }
      }

      // Load history
      final historyJson = prefs.getString(_questionHistoryKey);
      if (historyJson != null) {
        try {
          final list = jsonDecode(historyJson) as List;
          for (final item in list) {
            _history
                .add(QuestionInstance.fromJson(item as Map<String, dynamic>));
          }
        } catch (e) {
          debugPrint('Failed to load question history: $e');
        }
      }

      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing QuestionFreshnessService: $e');
      _initialized = true;
    }
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Persist stats
      final statsMap = {
        for (final e in _stats.entries) e.key: e.value.toJson()
      };
      await prefs.setString(_questionStatsKey, jsonEncode(statsMap));

      // Persist history
      final historyList = _history.map((q) => q.toJson()).toList();
      await prefs.setString(_questionHistoryKey, jsonEncode(historyList));
    } catch (e) {
      debugPrint('Error persisting question freshness data: $e');
    }
  }

  // ── Utility Methods ───────────────────────────────────────────────────────

  /// Generate a fingerprint/hash for a question
  /// Used to detect if same question is being asked
  ///
  /// Override this if you need custom hash logic
  static String generateQuestionHash(
    String questionText, {
    required List<dynamic> options,
  }) {
    // Simple hash based on question + options
    final combined = '$questionText|${options.join('|')}';
    return combined.hashCode.toString();
  }

  /// Export stats for analytics (privacy-respecting)
  Map<String, dynamic> exportAnalytics() {
    return {
      'summary': getSummaryStats(),
      'questionStats': _stats.entries
          .map((e) => {
                'questionHash': e.key,
                'timesShown': e.value.timesShown,
                'successRate': e.value.successRate,
                'lastShownAt': e.value.lastShownAt?.toIso8601String(),
              })
          .toList(),
    };
  }
}
