import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SM-2 Spaced Repetition algorithm.
///
/// After a practice session with accuracy ≥ 0.8 a skill is *scheduled* for
/// review.  The review interval grows after each successful repetition using
/// the standard SM-2 formula:
///
///   I(1) = 1 day
///   I(2) = 6 days
///   I(n) = I(n-1) × easeFactor   (easeFactor starts at 2.5)
///
/// Ease factor is nudged up/down based on session accuracy:
///   accuracy ≥ 0.9  → ef += 0.1
///   accuracy ≥ 0.8  → ef unchanged
///   accuracy ≥ 0.6  → ef -= 0.15  (partial recall)
///   accuracy < 0.6  → reset repetitions to 0, ef -= 0.2
///
/// Usage:
///   final srs = context.read<SpacedRepetitionService>();
///   await srs.recordSession(skillId: 'skill_abc', accuracy: 0.92);
///   final due = srs.dueCount;
///   final isDue = srs.isDue('skill_abc');
class SpacedRepetitionService extends ChangeNotifier {
  static const _prefsKey = 'srs_schedule_v1';

  // skillId → SrsEntry
  final Map<String, SrsEntry> _schedule = {};
  bool _initialized = false;

  // ── Public API ────────────────────────────────────────────────────────────

  bool get isInitialized => _initialized;

  /// Number of skills whose review date is today or earlier.
  int get dueCount {
    final today = _today();
    return _schedule.values
        .where((e) => !e.nextReview.isAfter(today))
        .length;
  }

  /// Skill IDs whose review date is today or earlier.
  List<String> get dueSkillIds {
    final today = _today();
    return _schedule.entries
        .where((kv) => !kv.value.nextReview.isAfter(today))
        .map((kv) => kv.key)
        .toList();
  }

  /// Whether a specific skill is currently due for review.
  bool isDue(String skillId) {
    final entry = _schedule[skillId];
    if (entry == null) return false;
    return !entry.nextReview.isAfter(_today());
  }

  /// The next scheduled review date for a skill (null if not yet scheduled).
  DateTime? nextReviewDate(String skillId) => _schedule[skillId]?.nextReview;

  // ── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in map.entries) {
          _schedule[entry.key] = SrsEntry.fromJson(entry.value as Map<String, dynamic>);
        }
      } catch (_) {
        // corrupt data — start fresh
      }
    }
    _initialized = true;
    notifyListeners();
  }

  // ── Core: record a session result ─────────────────────────────────────────

  /// Call this after every practice session.
  ///
  /// Only skills with [accuracy] ≥ 0.6 enter / stay in the schedule.
  /// Skills below that threshold reset their repetition counter.
  Future<void> recordSession({
    required String skillId,
    required double accuracy,
  }) async {
    final existing = _schedule[skillId] ?? SrsEntry.initial();
    final updated = _applyReview(existing, accuracy);
    _schedule[skillId] = updated;
    await _persist();
    notifyListeners();
  }

  // ── SM-2 logic ─────────────────────────────────────────────────────────────

  SrsEntry _applyReview(SrsEntry entry, double accuracy) {
    double ef = entry.easeFactor;
    int reps = entry.repetitions;
    int interval;

    if (accuracy >= 0.6) {
      // Successful recall
      if (reps == 0) {
        interval = 1;
      } else if (reps == 1) {
        interval = 6;
      } else {
        interval = (entry.intervalDays * ef).round();
      }
      reps += 1;

      // Adjust ease factor
      if (accuracy >= 0.9) {
        ef = (ef + 0.1).clamp(1.3, 2.5);
      } else if (accuracy < 0.8) {
        ef = (ef - 0.15).clamp(1.3, 2.5);
      }
    } else {
      // Failed recall — restart repetitions, keep (reduced) ease factor
      reps = 0;
      interval = 1;
      ef = (ef - 0.2).clamp(1.3, 2.5);
    }

    return SrsEntry(
      repetitions: reps,
      intervalDays: interval,
      easeFactor: ef,
      nextReview: _today().add(Duration(days: interval)),
      lastReviewed: _today(),
    );
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      for (final e in _schedule.entries) e.key: e.value.toJson()
    };
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data model for a single skill's SM-2 state
// ─────────────────────────────────────────────────────────────────────────────

class SrsEntry {
  final int repetitions;
  final int intervalDays;
  final double easeFactor;
  final DateTime nextReview;
  final DateTime lastReviewed;

  const SrsEntry({
    required this.repetitions,
    required this.intervalDays,
    required this.easeFactor,
    required this.nextReview,
    required this.lastReviewed,
  });

  factory SrsEntry.initial() {
    final today = DateTime.now();
    final d = DateTime(today.year, today.month, today.day);
    return SrsEntry(
      repetitions: 0,
      intervalDays: 1,
      easeFactor: 2.5,
      nextReview: d,
      lastReviewed: d,
    );
  }

  Map<String, dynamic> toJson() => {
        'reps': repetitions,
        'interval': intervalDays,
        'ef': easeFactor,
        'nextReview': nextReview.toIso8601String(),
        'lastReviewed': lastReviewed.toIso8601String(),
      };

  factory SrsEntry.fromJson(Map<String, dynamic> j) => SrsEntry(
        repetitions: (j['reps'] as num).toInt(),
        intervalDays: (j['interval'] as num).toInt(),
        easeFactor: (j['ef'] as num).toDouble(),
        nextReview: DateTime.parse(j['nextReview'] as String),
        lastReviewed: DateTime.parse(j['lastReviewed'] as String),
      );
}
