import 'package:hive/hive.dart';
import '../models/player_stats.dart';

class StatsService {
  static const String _boxName = 'player_stats';
  late Box<Map> _box;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _box = await Hive.openBox<Map>(_boxName);
    _initialized = true;
  }

  /// Get stats for a player
  Future<PlayerStats> getStats(String playerId) async {
    await initialize();
    
    final data = _box.get(playerId);
    if (data != null) {
      return PlayerStats.fromJson(Map<String, dynamic>.from(data));
    }
    
    // Create new stats for new player
    final newStats = PlayerStats(playerId: playerId);
    await saveStats(newStats);
    return newStats;
  }

  /// Save player stats
  Future<void> saveStats(PlayerStats stats) async {
    await initialize();
    await _box.put(stats.playerId, stats.toJson());
  }

  /// Add XP to player and handle level ups
  Future<LevelUpResult> addXp(String playerId, int xp, {String? zone}) async {
    final stats = await getStats(playerId);
    final oldLevel = stats.currentLevel;
    final leveledUp = stats.addXp(xp, zone: zone);
    await saveStats(stats);
    
    return LevelUpResult(
      leveledUp: leveledUp,
      oldLevel: oldLevel,
      newLevel: stats.currentLevel,
      xpGained: xp,
      totalXp: stats.totalXp,
    );
  }

  /// Award XP for completing an activity
  Future<LevelUpResult> awardActivityXp({
    required String playerId,
    required int score,
    required int maxScore,
    required String zone,
    bool isFirstTime = false,
    bool isDailyChallenge = false,
  }) async {
    final xp = XpRewards.calculateActivityXp(
      score: score,
      maxScore: maxScore,
      isFirstTime: isFirstTime,
      isDailyChallenge: isDailyChallenge,
    );
    
    final stats = await getStats(playerId);
    stats.incrementActivities();
    stats.addStars((score * 3 / maxScore).round()); // Convert score to stars
    
    await saveStats(stats);
    return await addXp(playerId, xp, zone: zone);
  }

  /// Add play time in minutes
  Future<void> addPlayTime(String playerId, int minutes) async {
    final stats = await getStats(playerId);
    stats.addPlayTime(minutes);
    await saveStats(stats);
  }

  /// Check if zone is unlocked
  Future<bool> isZoneUnlocked(String playerId, String zoneId) async {
    final stats = await getStats(playerId);
    return stats.isZoneUnlocked(zoneId);
  }

  /// Try to unlock a zone
  Future<bool> tryUnlockZone(String playerId, String zoneId) async {
    final stats = await getStats(playerId);
    final unlocked = stats.tryUnlockZone(zoneId);
    if (unlocked) {
      await saveStats(stats);
    }
    return unlocked;
  }

  /// Check all zones and unlock any that meet requirements
  Future<List<String>> checkAndUnlockZones(String playerId) async {
    final stats = await getStats(playerId);
    final newlyUnlocked = <String>[];
    
    for (final zoneId in stats.unlockedZones.keys) {
      if (!stats.isZoneUnlocked(zoneId) && stats.canUnlockZone(zoneId)) {
        stats.unlockZone(zoneId);
        newlyUnlocked.add(zoneId);
      }
    }
    
    if (newlyUnlocked.isNotEmpty) {
      await saveStats(stats);
    }
    
    return newlyUnlocked;
  }

  /// Get zone unlock requirements
  Map<String, ZoneUnlockRequirement> getZoneRequirements() {
    return PlayerStats.getZoneRequirements();
  }

  /// Update last played time
  Future<void> updateLastPlayed(String playerId) async {
    final stats = await getStats(playerId);
    final updated = stats.copyWith(lastPlayed: DateTime.now());
    await saveStats(updated);
  }

  /// Delete player stats
  Future<void> deleteStats(String playerId) async {
    await initialize();
    await _box.delete(playerId);
  }

  /// Clear all stats (for testing)
  Future<void> clearAll() async {
    await initialize();
    await _box.clear();
  }
}

class LevelUpResult {
  final bool leveledUp;
  final int oldLevel;
  final int newLevel;
  final int xpGained;
  final int totalXp;

  LevelUpResult({
    required this.leveledUp,
    required this.oldLevel,
    required this.newLevel,
    required this.xpGained,
    required this.totalXp,
  });
  
  int get levelsGained => newLevel - oldLevel;
}
