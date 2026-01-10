class PlayerStats {
  final String playerId;
  int totalXp;
  int currentLevel;
  int starsEarned;
  int activitiesCompleted;
  int totalPlayTimeMinutes;
  Map<String, int> zoneXp; // XP earned per zone
  Map<String, bool> unlockedZones;
  DateTime lastPlayed;
  DateTime createdAt;

  PlayerStats({
    required this.playerId,
    this.totalXp = 0,
    this.currentLevel = 1,
    this.starsEarned = 0,
    this.activitiesCompleted = 0,
    this.totalPlayTimeMinutes = 0,
    Map<String, int>? zoneXp,
    Map<String, bool>? unlockedZones,
    DateTime? lastPlayed,
    DateTime? createdAt,
  })  : zoneXp = zoneXp ??
            {
              'word_woods': 0,
              'number_nebula': 0,
              'story_springs': 0,
              'puzzle_peaks': 0,
              'adventure_arena': 0,
            },
        unlockedZones = unlockedZones ??
            {
              'word_woods': true, // First zone always unlocked
              'number_nebula': false,
              'story_springs': false,
              'puzzle_peaks': false,
              'adventure_arena': false,
            },
        lastPlayed = lastPlayed ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// Calculate XP needed for next level (exponential growth)
  int get xpForNextLevel {
    return (100 * currentLevel * (1 + (currentLevel * 0.2))).round();
  }

  /// Calculate XP progress to next level (0.0 - 1.0)
  double get xpProgressToNextLevel {
    final previousLevelXp = totalXpForLevel(currentLevel - 1);
    final nextLevelXp = totalXpForLevel(currentLevel);
    final currentProgress = totalXp - previousLevelXp;
    final totalNeeded = nextLevelXp - previousLevelXp;
    return (currentProgress / totalNeeded).clamp(0.0, 1.0);
  }

  /// Calculate total XP needed to reach a level
  static int totalXpForLevel(int level) {
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += (100 * i * (1 + (i * 0.2))).round();
    }
    return total;
  }

  /// Calculate level from total XP
  static int calculateLevel(int xp) {
    int level = 1;
    while (totalXpForLevel(level + 1) <= xp) {
      level++;
    }
    return level;
  }

  /// Add XP and return true if leveled up
  bool addXp(int xp, {String? zone}) {
    final oldLevel = currentLevel;
    totalXp += xp;

    if (zone != null && zoneXp.containsKey(zone)) {
      zoneXp[zone] = (zoneXp[zone] ?? 0) + xp;
    }

    currentLevel = calculateLevel(totalXp);
    return currentLevel > oldLevel;
  }

  /// Add stars earned from activities
  void addStars(int stars) {
    starsEarned += stars;
  }

  /// Increment activities completed
  void incrementActivities() {
    activitiesCompleted++;
  }

  /// Add play time in minutes
  void addPlayTime(int minutes) {
    totalPlayTimeMinutes += minutes;
  }

  /// Check if zone is unlocked
  bool isZoneUnlocked(String zoneId) {
    return unlockedZones[zoneId] ?? false;
  }

  /// Unlock a zone
  void unlockZone(String zoneId) {
    unlockedZones[zoneId] = true;
  }

  /// Get zone unlock requirements
  static Map<String, ZoneUnlockRequirement> getZoneRequirements() {
    return {
      'word_woods': ZoneUnlockRequirement(
        level: 1,
        xp: 0,
        description: 'Available from start',
      ),
      'number_nebula': ZoneUnlockRequirement(
        level: 3,
        xp: 500,
        description: 'Reach level 3',
      ),
      'story_springs': ZoneUnlockRequirement(
        level: 5,
        xp: 1200,
        description: 'Reach level 5',
      ),
      'puzzle_peaks': ZoneUnlockRequirement(
        level: 7,
        xp: 2000,
        description: 'Reach level 7',
      ),
      'adventure_arena': ZoneUnlockRequirement(
        level: 10,
        xp: 3500,
        description: 'Reach level 10',
      ),
    };
  }

  /// Check if zone can be unlocked with current stats
  bool canUnlockZone(String zoneId) {
    final requirements = getZoneRequirements()[zoneId];
    if (requirements == null) return false;
    return currentLevel >= requirements.level && totalXp >= requirements.xp;
  }

  /// Try to unlock zone, returns true if successful
  bool tryUnlockZone(String zoneId) {
    if (isZoneUnlocked(zoneId)) return true;
    if (canUnlockZone(zoneId)) {
      unlockZone(zoneId);
      return true;
    }
    return false;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'totalXp': totalXp,
      'currentLevel': currentLevel,
      'starsEarned': starsEarned,
      'activitiesCompleted': activitiesCompleted,
      'totalPlayTimeMinutes': totalPlayTimeMinutes,
      'zoneXp': zoneXp,
      'unlockedZones': unlockedZones,
      'lastPlayed': lastPlayed.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      playerId: json['playerId'] as String,
      totalXp: json['totalXp'] as int? ?? 0,
      currentLevel: json['currentLevel'] as int? ?? 1,
      starsEarned: json['starsEarned'] as int? ?? 0,
      activitiesCompleted: json['activitiesCompleted'] as int? ?? 0,
      totalPlayTimeMinutes: json['totalPlayTimeMinutes'] as int? ?? 0,
      zoneXp: Map<String, int>.from(json['zoneXp'] as Map? ?? {}),
      unlockedZones:
          Map<String, bool>.from(json['unlockedZones'] as Map? ?? {}),
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Create a copy with updated fields
  PlayerStats copyWith({
    String? playerId,
    int? totalXp,
    int? currentLevel,
    int? starsEarned,
    int? activitiesCompleted,
    int? totalPlayTimeMinutes,
    Map<String, int>? zoneXp,
    Map<String, bool>? unlockedZones,
    DateTime? lastPlayed,
    DateTime? createdAt,
  }) {
    return PlayerStats(
      playerId: playerId ?? this.playerId,
      totalXp: totalXp ?? this.totalXp,
      currentLevel: currentLevel ?? this.currentLevel,
      starsEarned: starsEarned ?? this.starsEarned,
      activitiesCompleted: activitiesCompleted ?? this.activitiesCompleted,
      totalPlayTimeMinutes: totalPlayTimeMinutes ?? this.totalPlayTimeMinutes,
      zoneXp: zoneXp ?? Map.from(this.zoneXp),
      unlockedZones: unlockedZones ?? Map.from(this.unlockedZones),
      lastPlayed: lastPlayed ?? this.lastPlayed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ZoneUnlockRequirement {
  final int level;
  final int xp;
  final String description;

  ZoneUnlockRequirement({
    required this.level,
    required this.xp,
    required this.description,
  });
}

/// XP reward values for different actions
class XpRewards {
  static const int activityCompleted = 50;
  static const int perfectScore = 100;
  static const int firstTimeBonus = 150;
  static const int dailyChallengeCompleted = 200;
  static const int achievementUnlocked = 100;
  static const int streakBonus = 50; // Per day streak

  /// Calculate XP for activity based on performance
  static int calculateActivityXp({
    required int score,
    required int maxScore,
    bool isFirstTime = false,
    bool isDailyChallenge = false,
  }) {
    int xp = activityCompleted;

    // Bonus for high performance
    if (score == maxScore) {
      xp += perfectScore;
    } else {
      final performance = score / maxScore;
      if (performance >= 0.9) {
        xp += 75;
      } else if (performance >= 0.75) {
        xp += 50;
      } else if (performance >= 0.5) {
        xp += 25;
      }
    }

    // First time bonus
    if (isFirstTime) {
      xp += firstTimeBonus;
    }

    // Daily challenge bonus
    if (isDailyChallenge) {
      xp += dailyChallengeCompleted;
    }

    return xp;
  }
}
