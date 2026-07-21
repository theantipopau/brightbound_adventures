import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/core/services/achievement_service.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/services/cosmetic_unlock_service.dart';
import 'package:brightbound_adventures/core/services/shop_service.dart';
import 'package:brightbound_adventures/core/services/streak_service.dart';

/// Immutable description of what a completed quest/session earned, before
/// any of it has been applied to persisted player state.
@immutable
class QuestOutcome {
  const QuestOutcome({
    required this.outcomeId,
    required this.xpEarned,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    this.zoneId,
  });

  /// Stable identity for this specific completion, e.g.
  /// `'${skillId}_${sessionStartedAt.millisecondsSinceEpoch}'`. Calling
  /// [RewardTransactionService.apply] twice with the same id returns the
  /// same result instead of re-earning rewards.
  final String outcomeId;

  final int xpEarned;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final String? zoneId;

  bool get isPerfectScore => accuracy >= 1.0;
}

/// What was actually earned by a [QuestOutcome], after being applied.
///
/// Pure data (no service references), so it can be cached, persisted, and
/// re-shown without re-running any reward logic.
@immutable
class RewardResult {
  const RewardResult({
    required this.outcomeId,
    required this.xpAwarded,
    required this.starsAwarded,
    required this.previousLevel,
    required this.newLevel,
    required this.currentStreak,
    required this.newStreakMilestone,
    required this.newlyUnlockedAchievementIds,
    required this.newlyUnlockedCosmeticIds,
  });

  final String outcomeId;
  final int xpAwarded;
  final int starsAwarded;
  final int previousLevel;
  final int newLevel;
  final int currentStreak;
  final bool newStreakMilestone;
  final List<String> newlyUnlockedAchievementIds;
  final List<String> newlyUnlockedCosmeticIds;

  bool get leveledUp => newLevel > previousLevel;
  bool get hasNewUnlocks =>
      newlyUnlockedAchievementIds.isNotEmpty ||
      newlyUnlockedCosmeticIds.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'outcomeId': outcomeId,
        'xpAwarded': xpAwarded,
        'starsAwarded': starsAwarded,
        'previousLevel': previousLevel,
        'newLevel': newLevel,
        'currentStreak': currentStreak,
        'newStreakMilestone': newStreakMilestone,
        'newlyUnlockedAchievementIds': newlyUnlockedAchievementIds,
        'newlyUnlockedCosmeticIds': newlyUnlockedCosmeticIds,
      };

  factory RewardResult.fromJson(Map<String, dynamic> json) => RewardResult(
        outcomeId: json['outcomeId'] as String,
        xpAwarded: json['xpAwarded'] as int,
        starsAwarded: json['starsAwarded'] as int,
        previousLevel: json['previousLevel'] as int,
        newLevel: json['newLevel'] as int,
        currentStreak: json['currentStreak'] as int,
        newStreakMilestone: json['newStreakMilestone'] as bool,
        newlyUnlockedAchievementIds:
            (json['newlyUnlockedAchievementIds'] as List).cast<String>(),
        newlyUnlockedCosmeticIds:
            (json['newlyUnlockedCosmeticIds'] as List).cast<String>(),
      );
}

/// Applies quest-completion rewards (XP/level, stars, streak, achievements,
/// cosmetic unlocks) as a single, idempotent operation.
///
/// Before this service existed, each results screen independently called
/// `avatarProvider.addExperience(...)`, `shopService.awardStarsForActivity(...)`,
/// and `achievementService.track...(...)` with no shared coordination and no
/// guard against re-applying if the screen was rebuilt or revisited. This
/// service is the single place that does it, persists the result first,
/// and returns the same [RewardResult] on every subsequent call for the
/// same [QuestOutcome.outcomeId] — so calling it again (rebuild, resumed
/// session, revisited results screen) never double-awards anything.
class RewardTransactionService extends ChangeNotifier {
  RewardTransactionService({
    required ShopService shop,
    required AchievementService achievements,
    required StreakService streak,
    required CosmeticUnlockService cosmeticUnlock,
    SharedPreferences? preferences,
  })  : _shop = shop,
        _achievements = achievements,
        _streak = streak,
        _cosmeticUnlock = cosmeticUnlock,
        _preferencesOverride = preferences;

  static const _prefsKey = 'reward_transactions_v1';
  static const _maxCachedResults = 50;

  final ShopService _shop;
  final AchievementService _achievements;
  final StreakService _streak;
  final CosmeticUnlockService _cosmeticUnlock;
  final SharedPreferences? _preferencesOverride;

  final Map<String, RewardResult> _appliedResults = {};
  bool _loaded = false;

  Future<SharedPreferences> _prefs() async =>
      _preferencesOverride ?? await SharedPreferences.getInstance();

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await _prefs();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        _appliedResults[key] =
            RewardResult.fromJson(value as Map<String, dynamic>);
      });
    } catch (e) {
      debugPrint('RewardTransactionService: discarding corrupt cache: $e');
    }
  }

  Future<void> _persist() async {
    final prefs = await _prefs();
    var entries = _appliedResults.entries.toList();
    if (entries.length > _maxCachedResults) {
      entries = entries.sublist(entries.length - _maxCachedResults);
    }
    final encoded = {for (final e in entries) e.key: e.value.toJson()};
    await prefs.setString(_prefsKey, json.encode(encoded));
  }

  /// Returns the cached result for [outcomeId] if this outcome has already
  /// been applied, without touching any reward state.
  Future<RewardResult?> peek(String outcomeId) async {
    await _ensureLoaded();
    return _appliedResults[outcomeId];
  }

  /// Applies [outcome]'s rewards exactly once and returns the result.
  ///
  /// Persists before returning, so if the app is killed between this call
  /// completing and the caller animating/showing the result, the next call
  /// with the same `outcomeId` (e.g. on next launch) returns the identical
  /// result instead of re-earning anything.
  Future<RewardResult> apply(
    QuestOutcome outcome, {
    required AvatarProvider avatarProvider,
  }) async {
    await _ensureLoaded();

    final cached = _appliedResults[outcome.outcomeId];
    if (cached != null) return cached;

    final previousLevel = avatarProvider.avatar?.level ?? 1;
    if (avatarProvider.hasAvatar && outcome.xpEarned > 0) {
      await avatarProvider.addExperience(outcome.xpEarned);
    }
    final newLevel = avatarProvider.avatar?.level ?? previousLevel;
    final leveledUp = newLevel > previousLevel;

    final starsAwarded = await _shop.awardStarsForActivity(
      score: outcome.correctAnswers,
      maxScore: outcome.totalQuestions,
      accuracy: outcome.accuracy,
    );

    final newStreakMilestone = await _streak.recordPlay();

    await _achievements.trackQuestionAnswered(true);
    if (outcome.isPerfectScore) {
      await _achievements.trackPerfectScore();
    }
    if (leveledUp) {
      await _achievements.trackLevelReached(newLevel);
    }
    final newlyUnlockedAchievementIds =
        _achievements.recentlyUnlocked.map((a) => a.id).toList();
    _achievements.clearRecentlyUnlocked();

    if (leveledUp) {
      await _cosmeticUnlock.updateLevel(newLevel);
    }
    final newlyUnlockedCosmeticIds =
        _cosmeticUnlock.getNewlyUnlocked().map((c) => c.id).toList();

    final result = RewardResult(
      outcomeId: outcome.outcomeId,
      xpAwarded: outcome.xpEarned,
      starsAwarded: starsAwarded,
      previousLevel: previousLevel,
      newLevel: newLevel,
      currentStreak: _streak.currentStreak,
      newStreakMilestone: newStreakMilestone,
      newlyUnlockedAchievementIds: newlyUnlockedAchievementIds,
      newlyUnlockedCosmeticIds: newlyUnlockedCosmeticIds,
    );

    _appliedResults[outcome.outcomeId] = result;
    await _persist();
    notifyListeners();
    return result;
  }
}
