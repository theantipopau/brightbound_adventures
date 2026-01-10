import 'package:flutter/material.dart';

/// Achievement/Trophy model for tracking player accomplishments
class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final AchievementCategory category;
  final AchievementTier tier;
  final int requirement;
  final int currentProgress;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    this.tier = AchievementTier.bronze,
    required this.requirement,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progressPercent => (currentProgress / requirement).clamp(0.0, 1.0);

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    AchievementCategory? category,
    AchievementTier? tier,
    int? requirement,
    int? currentProgress,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      tier: tier ?? this.tier,
      requirement: requirement ?? this.requirement,
      currentProgress: currentProgress ?? this.currentProgress,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }
}

enum AchievementCategory {
  learning, // Skill-related achievements
  exploration, // Zone exploration achievements
  streak, // Daily streak achievements
  social, // Player interaction achievements
  mastery, // Mastery-level achievements
  special, // Special/seasonal achievements
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}

/// Pre-defined achievements database
class AchievementDatabase {
  static const List<Achievement> allAchievements = [
    // Learning Achievements
    Achievement(
      id: 'first_question',
      name: 'First Steps',
      description: 'Answer your first question correctly',
      emoji: '👣',
      category: AchievementCategory.learning,
      tier: AchievementTier.bronze,
      requirement: 1,
    ),
    Achievement(
      id: 'ten_correct',
      name: 'Quick Learner',
      description: 'Answer 10 questions correctly',
      emoji: '📚',
      category: AchievementCategory.learning,
      tier: AchievementTier.bronze,
      requirement: 10,
    ),
    Achievement(
      id: 'fifty_correct',
      name: 'Knowledge Seeker',
      description: 'Answer 50 questions correctly',
      emoji: '🧠',
      category: AchievementCategory.learning,
      tier: AchievementTier.silver,
      requirement: 50,
    ),
    Achievement(
      id: 'hundred_correct',
      name: 'Wisdom Warrior',
      description: 'Answer 100 questions correctly',
      emoji: '🦉',
      category: AchievementCategory.learning,
      tier: AchievementTier.gold,
      requirement: 100,
    ),
    Achievement(
      id: 'five_hundred_correct',
      name: 'Scholar Supreme',
      description: 'Answer 500 questions correctly',
      emoji: '🎓',
      category: AchievementCategory.learning,
      tier: AchievementTier.platinum,
      requirement: 500,
    ),

    // Exploration Achievements
    Achievement(
      id: 'first_zone',
      name: 'Explorer',
      description: 'Visit your first zone',
      emoji: '🗺️',
      category: AchievementCategory.exploration,
      tier: AchievementTier.bronze,
      requirement: 1,
    ),
    Achievement(
      id: 'all_zones',
      name: 'World Traveler',
      description: 'Visit all 5 zones',
      emoji: '🌍',
      category: AchievementCategory.exploration,
      tier: AchievementTier.gold,
      requirement: 5,
    ),

    // Streak Achievements
    Achievement(
      id: 'streak_3',
      name: 'On a Roll',
      description: 'Play 3 days in a row',
      emoji: '🔥',
      category: AchievementCategory.streak,
      tier: AchievementTier.bronze,
      requirement: 3,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Week Warrior',
      description: 'Play 7 days in a row',
      emoji: '⚡',
      category: AchievementCategory.streak,
      tier: AchievementTier.silver,
      requirement: 7,
    ),
    Achievement(
      id: 'streak_14',
      name: 'Fortnight Fighter',
      description: 'Play 14 days in a row',
      emoji: '💪',
      category: AchievementCategory.streak,
      tier: AchievementTier.gold,
      requirement: 14,
    ),
    Achievement(
      id: 'streak_30',
      name: 'Dedicated Learner',
      description: 'Play 30 days in a row',
      emoji: '🌟',
      category: AchievementCategory.streak,
      tier: AchievementTier.platinum,
      requirement: 30,
    ),
    Achievement(
      id: 'streak_100',
      name: 'Unstoppable',
      description: 'Play 100 days in a row',
      emoji: '🔱',
      category: AchievementCategory.streak,
      tier: AchievementTier.platinum,
      requirement: 100,
    ),

    // Star Milestone Achievements
    Achievement(
      id: 'stars_10',
      name: 'Stargazer',
      description: 'Collect 10 stars',
      emoji: '⭐',
      category: AchievementCategory.learning,
      tier: AchievementTier.bronze,
      requirement: 10,
    ),
    Achievement(
      id: 'stars_25',
      name: 'Star Collector',
      description: 'Collect 25 stars',
      emoji: '🌠',
      category: AchievementCategory.learning,
      tier: AchievementTier.bronze,
      requirement: 25,
    ),
    Achievement(
      id: 'stars_50',
      name: 'Constellation',
      description: 'Collect 50 stars',
      emoji: '✨',
      category: AchievementCategory.learning,
      tier: AchievementTier.silver,
      requirement: 50,
    ),
    Achievement(
      id: 'stars_100',
      name: 'Supernova',
      description: 'Collect 100 stars',
      emoji: '💫',
      category: AchievementCategory.learning,
      tier: AchievementTier.gold,
      requirement: 100,
    ),
    Achievement(
      id: 'stars_250',
      name: 'Stellar Champion',
      description: 'Collect 250 stars',
      emoji: '🌟',
      category: AchievementCategory.learning,
      tier: AchievementTier.gold,
      requirement: 250,
    ),
    Achievement(
      id: 'stars_500',
      name: 'Cosmic Legend',
      description: 'Collect 500 stars',
      emoji: '🌌',
      category: AchievementCategory.learning,
      tier: AchievementTier.platinum,
      requirement: 500,
    ),

    // Mastery Achievements
    Achievement(
      id: 'first_skill_mastered',
      name: 'Skill Master',
      description: 'Master your first skill',
      emoji: '🏅',
      category: AchievementCategory.mastery,
      tier: AchievementTier.silver,
      requirement: 1,
    ),
    Achievement(
      id: 'five_skills_mastered',
      name: 'Multi-Talented',
      description: 'Master 5 skills',
      emoji: '🏆',
      category: AchievementCategory.mastery,
      tier: AchievementTier.gold,
      requirement: 5,
    ),
    Achievement(
      id: 'ten_skills_mastered',
      name: 'Ultimate Champion',
      description: 'Master 10 skills',
      emoji: '👑',
      category: AchievementCategory.mastery,
      tier: AchievementTier.platinum,
      requirement: 10,
    ),

    // Perfect Score Achievements
    Achievement(
      id: 'perfect_game',
      name: 'Perfectionist',
      description: 'Get a perfect score in any game',
      emoji: '💯',
      category: AchievementCategory.learning,
      tier: AchievementTier.silver,
      requirement: 1,
    ),
    Achievement(
      id: 'five_perfect_games',
      name: 'Flawless',
      description: 'Get 5 perfect scores',
      emoji: '⭐',
      category: AchievementCategory.learning,
      tier: AchievementTier.gold,
      requirement: 5,
    ),

    // Special Achievements
    Achievement(
      id: 'avatar_created',
      name: 'New Adventure',
      description: 'Create your first avatar',
      emoji: '🎭',
      category: AchievementCategory.special,
      tier: AchievementTier.bronze,
      requirement: 1,
    ),
    Achievement(
      id: 'daily_challenge',
      name: 'Challenge Accepted',
      description: 'Complete a daily challenge',
      emoji: '🎯',
      category: AchievementCategory.special,
      tier: AchievementTier.bronze,
      requirement: 1,
    ),
    Achievement(
      id: 'level_5',
      name: 'Rising Star',
      description: 'Reach level 5',
      emoji: '⬆️',
      category: AchievementCategory.special,
      tier: AchievementTier.silver,
      requirement: 5,
    ),
    Achievement(
      id: 'level_10',
      name: 'Superstar',
      description: 'Reach level 10',
      emoji: '🌠',
      category: AchievementCategory.special,
      tier: AchievementTier.gold,
      requirement: 10,
    ),
  ];

  /// Get achievements by category
  static List<Achievement> getByCategory(AchievementCategory category) {
    return allAchievements.where((a) => a.category == category).toList();
  }

  /// Get achievements by tier
  static List<Achievement> getByTier(AchievementTier tier) {
    return allAchievements.where((a) => a.tier == tier).toList();
  }
}

/// Helper functions for achievement UI
class AchievementHelper {
  static Color getTierColor(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  static String getTierName(AchievementTier tier) {
    switch (tier) {
      case AchievementTier.bronze:
        return 'Bronze';
      case AchievementTier.silver:
        return 'Silver';
      case AchievementTier.gold:
        return 'Gold';
      case AchievementTier.platinum:
        return 'Platinum';
    }
  }

  static String getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.learning:
        return 'Learning';
      case AchievementCategory.exploration:
        return 'Exploration';
      case AchievementCategory.streak:
        return 'Streak';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.mastery:
        return 'Mastery';
      case AchievementCategory.special:
        return 'Special';
    }
  }

  static IconData getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.learning:
        return Icons.school;
      case AchievementCategory.exploration:
        return Icons.explore;
      case AchievementCategory.streak:
        return Icons.local_fire_department;
      case AchievementCategory.social:
        return Icons.people;
      case AchievementCategory.mastery:
        return Icons.emoji_events;
      case AchievementCategory.special:
        return Icons.star;
    }
  }
}
