import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/services/streak_service.dart';

/// Enhanced streak mechanics with milestone rewards and cosmetics
class StreakEnhancedService {
  final StreakService streakService;

  StreakEnhancedService(this.streakService);

  /// Milestone levels with cosmetic rewards
  static const Map<int, String> milestoneCosmeticIds = {
    3: 'outfit_fire_starter', // 3-day streak outfit
    7: 'outfit_week_warrior', // 7-day streak outfit
    14: 'outfit_fortnight_hero', // 14-day streak outfit
    30: 'outfit_monthly_legend', // 30-day streak outfit
    50: 'outfit_epic_challenger', // 50-day streak outfit
    100: 'outfit_legendary_master', // 100-day streak outfit
  };

  /// Get next milestone and progress towards it
  ({int nextMilestone, int daysUntil, String? cosmeticReward})
      getNextMilestone() {
    final current = streakService.currentStreak;
    
    // Find next milestone
    for (final milestone in milestoneCosmeticIds.keys.toList()..sort()) {
      if (current < milestone) {
        return (
          nextMilestone: milestone,
          daysUntil: milestone - current,
          cosmeticReward: milestoneCosmeticIds[milestone],
        );
      }
    }

    // If all milestones passed, next is 365 days
    return (
      nextMilestone: 365,
      daysUntil: 365 - current,
      cosmeticReward: 'outfit_infinite_legend',
    );
  }

  /// Get milestone emoji based on streak
  String getMilestoneEmoji() {
    final streak = streakService.currentStreak;
    if (streak >= 100) return '🏆'; // Legend
    if (streak >= 50) return '👑'; // Epic
    if (streak >= 30) return '🔥'; // Monthly
    if (streak >= 14) return '⭐'; // Fortnight
    if (streak >= 7) return '💪'; // Week
    if (streak >= 3) return '✨'; // 3-day
    return '🎯';
  }

  /// Get animated flame size based on streak (0.5 to 2.0)
  double getFlameScale() {
    final streak = streakService.currentStreak;
    if (streak >= 100) return 2.0;
    if (streak >= 50) return 1.8;
    if (streak >= 30) return 1.6;
    if (streak >= 14) return 1.4;
    if (streak >= 7) return 1.2;
    if (streak >= 3) return 1.0;
    return 0.5;
  }

  /// Check if a milestone was just reached
  bool isMilestoneJustReached(int previousStreak, int currentStreak) {
    for (final milestone in milestoneCosmeticIds.keys) {
      if (previousStreak < milestone && currentStreak >= milestone) {
        return true;
      }
    }
    return false;
  }

  /// Get the milestone that was just reached
  int? getReachedMilestone(int previousStreak, int currentStreak) {
    for (final milestone in milestoneCosmeticIds.keys) {
      if (previousStreak < milestone && currentStreak >= milestone) {
        return milestone;
      }
    }
    return null;
  }

  /// Get bonus XP for streak
  int getStreakBonus(int streak) {
    if (streak >= 100) return 500;
    if (streak >= 50) return 250;
    if (streak >= 30) return 100;
    if (streak >= 14) return 50;
    if (streak >= 7) return 25;
    if (streak >= 3) return 10;
    return 0;
  }

  /// Get motivational message based on streak
  String getMotivationalMessage(int streak) {
    if (streak == 0) return '🌟 Start your journey today!';
    if (streak == 1) return '🚀 Great start! Keep it going!';
    if (streak < 3) return '⚡ You\'re building momentum!';
    if (streak == 3) return '🎉 3-Day Streak! You\'re on fire!';
    if (streak < 7) return '🔥 On Fire! Stay focused!';
    if (streak == 7) return '👏 Week 1 Champion! Amazing!';
    if (streak < 14) return '💪 Incredible dedication!';
    if (streak == 14) return '⭐ Two Weeks Strong!';
    if (streak < 30) return '🚀 You\'re unstoppable!';
    if (streak == 30) return '👑 Monthly Legend! Outstanding!';
    if (streak < 50) return '🌟 Legendary commitment!';
    if (streak == 50) return '🏆 Epic Challenger! 50 Days!';
    if (streak < 100) return '⚡ Nearly a Legendary Master!';
    if (streak == 100) return '🏆 LEGENDARY MASTER! 100 DAYS!';
    return '∞ Ultimate Champion!';
  }

  /// Get visual color based on streak intensity
  Color getStreakColor(int streak) {
    if (streak >= 100) return const Color(0xFF9C27B0); // Purple
    if (streak >= 50) return const Color(0xFFFF6F00); // Deep Orange
    if (streak >= 30) return const Color(0xFFFFC400); // Amber
    if (streak >= 14) return const Color(0xFF2196F3); // Blue
    if (streak >= 7) return const Color(0xFF4CAF50); // Green
    if (streak >= 3) return const Color(0xFF00BCD4); // Cyan
    return const Color(0xFF9E9E9E); // Grey
  }
}
