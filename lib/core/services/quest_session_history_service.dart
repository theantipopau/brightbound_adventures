import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/core/models/quest_session_summary.dart';

class QuestSessionHistoryService extends ChangeNotifier {
  static const String _prefsKey = 'quest_session_history_v1';
  static const int _maxStoredSessions = 200;

  final List<QuestSessionSummary> _sessions = [];
  bool _initialized = false;

  bool get initialized => _initialized;

  List<QuestSessionSummary> get sessions => List.unmodifiable(_sessions);

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List;
        _sessions
          ..clear()
          ..addAll(
            decoded
                .whereType<Map>()
                .map((entry) => QuestSessionSummary.fromJson(
                      Map<String, dynamic>.from(entry),
                    )),
          )
          ..sort((a, b) => b.endedAt.compareTo(a.endedAt));
      }
    } catch (error) {
      debugPrint('Failed to load quest session history: $error');
      _sessions.clear();
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> recordQuizSession({
    required String zoneId,
    required String skillId,
    required String skillName,
    required DateTime startedAt,
    required int totalQuestions,
    required int correctAnswers,
    required int score,
    required int hintsUsed,
    required int difficulty,
    required List<String> questionIds,
    int freshQuestionCount = 0,
    int repeatedQuestionCount = 0,
    String mode = 'practice',
    bool forced = false,
    DateTime? endedAt,
  }) {
    final now = endedAt ?? DateTime.now();
    final summary = QuestSessionSummary(
      id: '${now.microsecondsSinceEpoch}_$skillId',
      zoneId: zoneId,
      skillId: skillId,
      skillName: skillName,
      mode: mode,
      startedAt: startedAt,
      endedAt: now,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      score: score,
      hintsUsed: hintsUsed,
      difficulty: difficulty,
      forced: forced,
      questionIds: questionIds,
      freshQuestionCount: freshQuestionCount,
      repeatedQuestionCount: repeatedQuestionCount,
    );

    return recordSession(summary);
  }

  Future<void> recordSession(QuestSessionSummary summary) async {
    await initialize();

    _sessions
      ..removeWhere((session) => session.id == summary.id)
      ..insert(0, summary)
      ..sort((a, b) => b.endedAt.compareTo(a.endedAt));

    if (_sessions.length > _maxStoredSessions) {
      _sessions.removeRange(_maxStoredSessions, _sessions.length);
    }

    await _persist();
    notifyListeners();
  }

  List<QuestSessionSummary> recentSessions({
    String? zoneId,
    String? skillId,
    int limit = 10,
  }) {
    Iterable<QuestSessionSummary> filtered = _sessions;
    if (zoneId != null) {
      filtered = filtered.where((session) => session.zoneId == zoneId);
    }
    if (skillId != null) {
      filtered = filtered.where((session) => session.skillId == skillId);
    }
    return filtered.take(limit).toList();
  }

  List<String> weakSkillIds({int minSessions = 2, double threshold = 0.7}) {
    final bySkill = <String, List<QuestSessionSummary>>{};
    for (final session in _sessions.take(80)) {
      bySkill.putIfAbsent(session.skillId, () => []).add(session);
    }

    final weak = <String>[];
    for (final entry in bySkill.entries) {
      if (entry.value.length < minSessions) continue;
      final averageAccuracy =
          entry.value.fold<double>(0, (sum, s) => sum + s.accuracy) /
              entry.value.length;
      if (averageAccuracy < threshold ||
          entry.value.take(3).any((session) => session.needsReview)) {
        weak.add(entry.key);
      }
    }

    return weak;
  }

  int sessionsToday({String? zoneId}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _sessions.where((session) {
      if (zoneId != null && session.zoneId != zoneId) return false;
      return !session.endedAt.isBefore(today);
    }).length;
  }

  double recentAccuracyForSkill(String skillId, {int limit = 5}) {
    final recent = recentSessions(skillId: skillId, limit: limit);
    if (recent.isEmpty) return 0.0;
    return recent.fold<double>(0, (sum, session) => sum + session.accuracy) /
        recent.length;
  }

  Future<void> clearHistory() async {
    await initialize();
    _sessions.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(_sessions.map((session) => session.toJson()).toList()),
    );
  }
}
