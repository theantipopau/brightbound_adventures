import 'dart:math';
import 'package:flutter/material.dart';

/// Daily challenge system that provides a rotating set of activities
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String zoneId;
  final String skillId;
  final int targetScore;
  final int xpReward;
  final String emoji;
  final DateTime date;
  final bool isCompleted;
  final int currentProgress;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.zoneId,
    required this.skillId,
    required this.targetScore,
    required this.xpReward,
    required this.emoji,
    required this.date,
    this.isCompleted = false,
    this.currentProgress = 0,
  });

  double get progressPercent => (currentProgress / targetScore).clamp(0.0, 1.0);

  DailyChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? zoneId,
    String? skillId,
    int? targetScore,
    int? xpReward,
    String? emoji,
    DateTime? date,
    bool? isCompleted,
    int? currentProgress,
  }) {
    return DailyChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      zoneId: zoneId ?? this.zoneId,
      skillId: skillId ?? this.skillId,
      targetScore: targetScore ?? this.targetScore,
      xpReward: xpReward ?? this.xpReward,
      emoji: emoji ?? this.emoji,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      currentProgress: currentProgress ?? this.currentProgress,
    );
  }
}

/// Generator for daily challenges
class DailyChallengeGenerator {
  /// Challenge templates for each zone
  static const List<Map<String, dynamic>> _challengeTemplates = [
    // Word Woods challenges
    {
      'zone': 'word_woods',
      'titles': [
        'Word Warrior',
        'Spelling Champion',
        'Reading Rocket',
        'Grammar Guardian',
      ],
      'descriptions': [
        'Answer {count} questions correctly!',
        'Complete {count} literacy exercises!',
        'Master {count} word challenges!',
      ],
      'emoji': '📚',
      'skillIds': [
        'skill_homophones',
        'skill_apostrophes',
        'skill_comma_usage',
        'skill_letter_recognition',
      ],
    },
    // Number Nebula challenges
    {
      'zone': 'number_nebula',
      'titles': [
        'Math Master',
        'Number Ninja',
        'Calculation Champion',
        'Fraction Friend',
      ],
      'descriptions': [
        'Solve {count} math problems!',
        'Complete {count} number challenges!',
        'Master {count} calculations!',
      ],
      'emoji': '🔢',
      'skillIds': [
        'skill_basic_operations',
        'skill_fractions',
        'skill_word_problems',
        'skill_place_value',
      ],
    },
    // Story Springs challenges
    {
      'zone': 'story_springs',
      'titles': [
        'Story Star',
        'Tale Teller',
        'Narrative Navigator',
        'Character Creator',
      ],
      'descriptions': [
        'Complete {count} story activities!',
        'Build {count} creative narratives!',
        'Master {count} storytelling skills!',
      ],
      'emoji': '📖',
      'skillIds': [
        'skill_story_sequencing',
        'skill_emotion_recognition',
        'skill_character_development',
        'skill_plot_structure',
      ],
    },
    // Puzzle Peaks challenges
    {
      'zone': 'puzzle_peaks',
      'titles': [
        'Puzzle Pro',
        'Logic Legend',
        'Pattern Finder',
        'Brain Builder',
      ],
      'descriptions': [
        'Solve {count} logic puzzles!',
        'Complete {count} pattern challenges!',
        'Master {count} brain teasers!',
      ],
      'emoji': '🧩',
      'skillIds': [
        'skill_pattern_recognition',
        'skill_shape_matching',
        'skill_spatial_reasoning',
        'skill_logic_puzzles',
      ],
    },
    // Adventure Arena challenges
    {
      'zone': 'adventure_arena',
      'titles': [
        'Speed Star',
        'Reaction Hero',
        'Coordination King',
        'Precision Pro',
      ],
      'descriptions': [
        'Hit {count} targets!',
        'Complete {count} motor challenges!',
        'Master {count} coordination games!',
      ],
      'emoji': '🎯',
      'skillIds': [
        'skill_tap_accuracy',
        'skill_reaction_time',
        'skill_hand_eye_coordination',
        'skill_fine_motor',
      ],
    },
  ];

  /// Generate today's challenges (3 challenges, one easy, one medium, one hard)
  static List<DailyChallenge> generateDailyChallenges(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed); // Deterministic for same day

    final challenges = <DailyChallenge>[];

    // Generate 3 challenges from different zones
    final shuffledTemplates = List.from(_challengeTemplates)..shuffle(random);

    for (var i = 0; i < 3 && i < shuffledTemplates.length; i++) {
      final template = shuffledTemplates[i];
      final difficulty = i; // 0=easy, 1=medium, 2=hard

      final titles = template['titles'] as List;
      final descriptions = template['descriptions'] as List;
      final skillIds = template['skillIds'] as List;

      final targetScore = switch (difficulty) {
        0 => 3,
        1 => 5,
        _ => 7,
      };

      final xpReward = switch (difficulty) {
        0 => 25,
        1 => 50,
        _ => 100,
      };

      final description =
          (descriptions[random.nextInt(descriptions.length)] as String)
              .replaceAll('{count}', targetScore.toString());

      challenges.add(DailyChallenge(
        id: 'daily_${date.toIso8601String()}_$i',
        title: titles[random.nextInt(titles.length)] as String,
        description: description,
        zoneId: template['zone'] as String,
        skillId: skillIds[random.nextInt(skillIds.length)] as String,
        targetScore: targetScore,
        xpReward: xpReward,
        emoji: template['emoji'] as String,
        date: date,
      ));
    }

    return challenges;
  }

  /// Get the color for a zone
  static Color getZoneColor(String zoneId) {
    switch (zoneId) {
      case 'word_woods':
        return const Color(0xFF4CAF50);
      case 'number_nebula':
        return const Color(0xFF673AB7);
      case 'story_springs':
        return const Color(0xFF2196F3);
      case 'puzzle_peaks':
        return const Color(0xFFFF9800);
      case 'adventure_arena':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF607D8B);
    }
  }

  /// Get zone name from ID
  static String getZoneName(String zoneId) {
    switch (zoneId) {
      case 'word_woods':
        return 'Word Woods';
      case 'number_nebula':
        return 'Number Nebula';
      case 'story_springs':
        return 'Story Springs';
      case 'puzzle_peaks':
        return 'Puzzle Peaks';
      case 'adventure_arena':
        return 'Adventure Arena';
      default:
        return 'Unknown Zone';
    }
  }
}
