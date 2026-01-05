import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:brightbound_adventures/core/models/achievement.dart';

/// Service for tracking and managing achievements
class AchievementService extends ChangeNotifier {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  List<Achievement> _achievements = [];
  final List<Achievement> _recentlyUnlocked = [];
  
  List<Achievement> get achievements => _achievements;
  List<Achievement> get recentlyUnlocked => _recentlyUnlocked;
  
  int get unlockedCount => _achievements.where((a) => a.isUnlocked).length;
  int get totalCount => _achievements.length;
  
  /// Initialize achievements from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Start with all achievements from database
    _achievements = AchievementDatabase.allAchievements.map((a) {
      return a.copyWith();
    }).toList();
    
    // Load saved progress
    final savedData = prefs.getString('achievements');
    if (savedData != null) {
      try {
        final Map<String, dynamic> data = json.decode(savedData);
        
        for (int i = 0; i < _achievements.length; i++) {
          final achievement = _achievements[i];
          final saved = data[achievement.id];
          
          if (saved != null) {
            _achievements[i] = achievement.copyWith(
              currentProgress: saved['progress'] ?? 0,
              isUnlocked: saved['unlocked'] ?? false,
              unlockedAt: saved['unlockedAt'] != null 
                  ? DateTime.parse(saved['unlockedAt']) 
                  : null,
            );
          }
        }
      } catch (e) {
        debugPrint('Error loading achievements: $e');
      }
    }
    
    notifyListeners();
  }
  
  /// Save achievements to storage
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    
    final Map<String, dynamic> data = {};
    for (final achievement in _achievements) {
      data[achievement.id] = {
        'progress': achievement.currentProgress,
        'unlocked': achievement.isUnlocked,
        'unlockedAt': achievement.unlockedAt?.toIso8601String(),
      };
    }
    
    await prefs.setString('achievements', json.encode(data));
  }
  
  /// Update progress for a specific achievement type
  Future<void> updateProgress(String achievementId, int progress) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;
    
    final achievement = _achievements[index];
    if (achievement.isUnlocked) return; // Already unlocked
    
    final newProgress = progress.clamp(0, achievement.requirement);
    final updated = achievement.copyWith(currentProgress: newProgress);
    
    // Check if achievement should be unlocked
    if (newProgress >= achievement.requirement && !achievement.isUnlocked) {
      _achievements[index] = updated.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      _recentlyUnlocked.add(_achievements[index]);
      notifyListeners();
    } else {
      _achievements[index] = updated;
    }
    
    await _save();
    notifyListeners();
  }
  
  /// Increment progress by 1
  Future<void> incrementProgress(String achievementId) async {
    final achievement = _achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => _achievements[0],
    );
    
    if (achievement.id == _achievements[0].id && achievement.id != achievementId) {
      return; // Not found
    }
    
    await updateProgress(achievementId, achievement.currentProgress + 1);
  }
  
  /// Track question answered correctly
  Future<void> trackQuestionAnswered(bool correct) async {
    if (!correct) return;
    
    // Update learning achievements
    await incrementProgress('first_question');
    await incrementProgress('ten_correct');
    await incrementProgress('fifty_correct');
    await incrementProgress('one_hundred_correct');
    await incrementProgress('five_hundred_correct');
  }
  
  /// Track perfect quiz score
  Future<void> trackPerfectScore() async {
    await incrementProgress('perfect_score');
    await incrementProgress('five_perfect');
  }
  
  /// Track zone visited
  Future<void> trackZoneVisited(int zoneCount) async {
    await updateProgress('first_zone', zoneCount);
    await updateProgress('all_zones', zoneCount);
  }
  
  /// Track daily streak
  Future<void> trackStreak(int streakDays) async {
    await updateProgress('streak_3', streakDays);
    await updateProgress('streak_7', streakDays);
    await updateProgress('streak_30', streakDays);
  }
  
  /// Track skill mastered
  Future<void> trackSkillMastered(int masteredCount) async {
    await updateProgress('first_skill_mastered', masteredCount);
    await updateProgress('five_skills_mastered', masteredCount);
    await updateProgress('all_skills_mastered', masteredCount);
  }
  
  /// Track level reached
  Future<void> trackLevelReached(int level) async {
    await updateProgress('level_5', level);
    await updateProgress('level_10', level);
  }
  
  /// Track special achievements
  Future<void> trackAvatarCreated() async {
    await updateProgress('avatar_created', 1);
  }
  
  Future<void> trackDailyChallenge() async {
    await incrementProgress('daily_challenge');
  }
  
  /// Clear recently unlocked list (after showing notifications)
  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
  }
  
  /// Get achievements by category
  List<Achievement> getByCategory(AchievementCategory category) {
    return _achievements.where((a) => a.category == category).toList();
  }
  
  /// Get achievements by tier
  List<Achievement> getByTier(AchievementTier tier) {
    return _achievements.where((a) => a.tier == tier).toList();
  }
  
  /// Get unlocked achievements
  List<Achievement> getUnlocked() {
    return _achievements.where((a) => a.isUnlocked).toList();
  }
  
  /// Get locked achievements
  List<Achievement> getLocked() {
    return _achievements.where((a) => !a.isUnlocked).toList();
  }
  
  /// Reset all achievements (for testing)
  Future<void> resetAll() async {
    _achievements = AchievementDatabase.allAchievements.map((a) {
      return a.copyWith();
    }).toList();
    _recentlyUnlocked.clear();
    await _save();
    notifyListeners();
  }
}
