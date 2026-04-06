import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking daily play streaks
class StreakService extends ChangeNotifier {
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastPlayDate;
  bool _playedToday = false;
  int _totalDaysPlayed = 0;
  Set<String> _playedDates = {};

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  DateTime? get lastPlayDate => _lastPlayDate;
  bool get playedToday => _playedToday;
  int get totalDaysPlayed => _totalDaysPlayed;

  /// Streak milestones for bonus rewards
  static const List<int> milestones = [3, 7, 14, 30, 50, 100, 365];

  /// Get bonus stars for current streak
  int get streakBonus {
    if (_currentStreak >= 30) return 50;
    if (_currentStreak >= 14) return 25;
    if (_currentStreak >= 7) return 15;
    if (_currentStreak >= 3) return 5;
    return 0;
  }

  /// Get emoji for current streak level
  String get streakEmoji {
    if (_currentStreak >= 100) return '🌟';
    if (_currentStreak >= 30) return '🔥';
    if (_currentStreak >= 14) return '💪';
    if (_currentStreak >= 7) return '⭐';
    if (_currentStreak >= 3) return '✨';
    return '🎯';
  }

  /// Get message for streak
  String get streakMessage {
    if (_currentStreak == 0) return 'Start your streak today!';
    if (_currentStreak == 1) return 'Great start! Come back tomorrow!';
    if (_currentStreak < 3) return 'Keep it going!';
    if (_currentStreak < 7) return 'You\'re on fire!';
    if (_currentStreak < 14) return 'Amazing dedication!';
    if (_currentStreak < 30) return 'Incredible streak!';
    if (_currentStreak < 100) return 'Legendary learner!';
    return 'Ultimate champion!';
  }

  /// Initialize service and load saved data
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentStreak = prefs.getInt('currentStreak') ?? 0;
      _longestStreak = prefs.getInt('longestStreak') ?? 0;
      _totalDaysPlayed = prefs.getInt('totalDaysPlayed') ?? 0;

      final lastPlayString = prefs.getString('lastPlayDate');
      if (lastPlayString != null) {
        _lastPlayDate = DateTime.tryParse(lastPlayString);
      }

      // Load played dates history
      final datesList = prefs.getStringList('playedDatesList') ?? [];
      _playedDates = datesList.toSet();
      // Migration: ensure lastPlayDate is in set if played today
      if (_lastPlayDate != null) {
        _playedDates.add(_dateKey(_lastPlayDate!));
      }

      // Check if streak is still valid
      _checkStreak();
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing streak service: $e');
    }
  }

  /// Check and update streak based on current date
  void _checkStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastPlayDate == null) {
      _playedToday = false;
      return;
    }

    final lastPlay =
        DateTime(_lastPlayDate!.year, _lastPlayDate!.month, _lastPlayDate!.day);
    final difference = today.difference(lastPlay).inDays;

    if (difference == 0) {
      // Played today
      _playedToday = true;
    } else if (difference == 1) {
      // Yesterday - streak continues but need to play today
      _playedToday = false;
    } else if (difference > 1) {
      // Streak broken
      _currentStreak = 0;
      _playedToday = false;
    }
  }

  /// Record that user played today
  Future<bool> recordPlay() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Already played today
    if (_playedToday) {
      return false;
    }

    // Check if this continues or starts a streak
    bool isNewMilestone = false;

    if (_lastPlayDate != null) {
      final lastPlay = DateTime(
          _lastPlayDate!.year, _lastPlayDate!.month, _lastPlayDate!.day);
      final difference = today.difference(lastPlay).inDays;

      if (difference == 1) {
        // Continuing streak
        _currentStreak++;
      } else if (difference > 1) {
        // Starting new streak (streak was broken)
        _currentStreak = 1;
      } else {
        // Same day, shouldn't happen but handle it
        return false;
      }
    } else {
      // First time playing
      _currentStreak = 1;
    }

    _playedToday = true;
    _lastPlayDate = now;
    _totalDaysPlayed++;

    // Record this date and prune old data
    _playedDates.add(_dateKey(today));
    final cutoff = today.subtract(const Duration(days: 90));
    _playedDates.removeWhere((ds) {
      final parsed = DateTime.tryParse(ds);
      return parsed != null && parsed.isBefore(cutoff);
    });

    // Check for longest streak
    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }

    // Check for milestone
    isNewMilestone = milestones.contains(_currentStreak);

    // Save data
    await _saveData();
    notifyListeners();

    return isNewMilestone;
  }

  /// Save streak data to persistent storage
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentStreak', _currentStreak);
      await prefs.setInt('longestStreak', _longestStreak);
      await prefs.setInt('totalDaysPlayed', _totalDaysPlayed);
      if (_lastPlayDate != null) {
        await prefs.setString('lastPlayDate', _lastPlayDate!.toIso8601String());
      }
      await prefs.setStringList('playedDatesList', _playedDates.toList());
    } catch (e) {
      debugPrint('Error saving streak data: $e');
    }
  }

  /// Get days until next milestone
  int get daysToNextMilestone {
    for (final milestone in milestones) {
      if (_currentStreak < milestone) {
        return milestone - _currentStreak;
      }
    }
    return 0; // Already at max milestone
  }

  /// Returns a list of 7 booleans for the last 7 days.
  /// Index 0 = six days ago, index 6 = today.
  List<bool> getWeeklyActivity() {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return _playedDates.contains(_dateKey(day));
    });
  }

  /// Get next milestone
  int get nextMilestone {
    for (final milestone in milestones) {
      if (_currentStreak < milestone) {
        return milestone;
      }
    }
    return milestones.last;
  }

  /// Reset streak (for testing or special cases)
  Future<void> resetStreak() async {
    _currentStreak = 0;
    _playedToday = false;
    _lastPlayDate = null;
    await _saveData();
    notifyListeners();
  }
}
