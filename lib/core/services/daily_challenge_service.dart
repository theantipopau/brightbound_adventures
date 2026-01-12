import 'package:flutter/foundation.dart';
import 'package:brightbound_adventures/core/models/daily_challenge.dart';
import 'package:brightbound_adventures/core/services/local_storage_service.dart';

/// Service for managing daily challenges
class DailyChallengeService extends ChangeNotifier {
  final LocalStorageService _storage;

  List<DailyChallenge> _todaysChallenges = [];
  DailyChallenge? _selectedChallenge;
  Map<String, DailyChallenge> _completedChallenges = {}; // Date -> Challenge

  DailyChallengeService(this._storage);

  List<DailyChallenge> get todaysChallenges => _todaysChallenges;
  DailyChallenge? get selectedChallenge => _selectedChallenge;
  Map<String, DailyChallenge> get completedChallenges => _completedChallenges;

  /// Initialize service and load today's challenges
  Future<void> initialize() async {
    await loadTodaysChallenges();
    await loadCompletedChallenges();
  }

  /// Load today's challenges
  Future<void> loadTodaysChallenges() async {
    try {
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';

      // Check if challenges for today already exist
      final savedChallenges = _storage.getDailyChallenges(todayString);
      
      if (savedChallenges.isNotEmpty) {
        _todaysChallenges = savedChallenges;
      } else {
        // Generate new challenges for today
        _todaysChallenges = DailyChallengeGenerator.generateDailyChallenges(today);
        // Save them
        await _storage.saveDailyChallenges(todayString, _todaysChallenges);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading daily challenges: $e');
    }
  }

  /// Load completed challenges history
  Future<void> loadCompletedChallenges() async {
    try {
      _completedChallenges = await _storage.getCompletedChallenges();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading completed challenges: $e');
    }
  }

  /// Select a challenge to take
  void selectChallenge(DailyChallenge challenge) {
    _selectedChallenge = challenge;
    notifyListeners();
  }

  /// Deselect current challenge
  void deselectChallenge() {
    _selectedChallenge = null;
    notifyListeners();
  }

  /// Update challenge progress (called after each question answered)
  Future<void> updateProgress({
    required String challengeId,
    required bool correct,
  }) async {
    try {
      final index = _todaysChallenges.indexWhere((c) => c.id == challengeId);
      if (index == -1) return;

      final challenge = _todaysChallenges[index];
      final updated = challenge.copyWith(
        currentProgress: challenge.currentProgress + 1,
      );

      _todaysChallenges[index] = updated;

      // Update selected challenge if it matches
      if (_selectedChallenge?.id == challengeId) {
        _selectedChallenge = updated;
      }

      // Check if challenge is completed
      if (updated.progressPercent >= 1.0) {
        await completeChallenge(updated);
      }

      // Save progress
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      await _storage.saveDailyChallenges(todayString, _todaysChallenges);

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating challenge progress: $e');
    }
  }

  /// Complete a challenge
  Future<void> completeChallenge(DailyChallenge challenge) async {
    try {
      final completed = challenge.copyWith(
        isCompleted: true,
      );

      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';

      // Store in completed challenges
      _completedChallenges[todayString] = completed;
      await _storage.saveCompletedChallenges(_completedChallenges);

      notifyListeners();
    } catch (e) {
      debugPrint('Error completing challenge: $e');
    }
  }

  /// Get today's completion count
  int get todaysCompletionCount {
    return _todaysChallenges.where((c) => c.isCompleted).length;
  }

  /// Check if challenge was completed today
  bool isChallengeCompletedToday(String challengeId) {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    final challenge = _completedChallenges[todayString];
    return challenge?.id == challengeId && challenge?.isCompleted == true;
  }

  /// Get challenges completed this week
  int getChallengesCompletedThisWeek() {
    final today = DateTime.now();
    int count = 0;

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dateString = '${date.year}-${date.month}-${date.day}';
      final challenge = _completedChallenges[dateString];
      if (challenge?.isCompleted == true) count++;
    }

    return count;
  }

  /// Get total challenges completed
  int get totalChallengesCompleted {
    return _completedChallenges.values.where((c) => c.isCompleted).length;
  }

  /// Get total XP earned from daily challenges
  int getTotalXpFromChallenges() {
    return _completedChallenges.values
        .where((c) => c.isCompleted)
        .fold<int>(0, (sum, c) => sum + c.xpReward);
  }
}
