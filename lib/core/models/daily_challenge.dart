import 'dart:math';
import 'package:flutter/material.dart';

/// Types of daily challenge modifier — adds variety and replayability.
enum ChallengeType {
  /// Standard: answer N questions correctly (existing behaviour).
  normal,
  /// Speed: complete N questions within a tight time limit bonus.
  timed,
  /// Combo: get N correct in a row without a wrong answer.
  combo,
  /// No-hints: complete N questions without using any hints.
  noHints,
  /// Mixed: questions drawn from two different zones.
  mixed,
}

extension ChallengeTypeDetails on ChallengeType {
  String get label {
    switch (this) {
      case ChallengeType.normal:
        return 'Standard';
      case ChallengeType.timed:
        return '⏱️ Speed Run';
      case ChallengeType.combo:
        return '🔥 Combo';
      case ChallengeType.noHints:
        return '💡 No Hints';
      case ChallengeType.mixed:
        return '🌀 Mixed';
    }
  }

  String get descriptionSuffix {
    switch (this) {
      case ChallengeType.normal:
        return '';
      case ChallengeType.timed:
        return ' (speed bonus!)';
      case ChallengeType.combo:
        return ' in a row without mistakes!';
      case ChallengeType.noHints:
        return ' — no hints allowed!';
      case ChallengeType.mixed:
        return ' across two zones!';
    }
  }
}

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
  final ChallengeType challengeType;
  /// Optional secondary zone for mixed challenges
  final String? secondaryZoneId;

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
    this.challengeType = ChallengeType.normal,
    this.secondaryZoneId,
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
    ChallengeType? challengeType,
    String? secondaryZoneId,
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
      challengeType: challengeType ?? this.challengeType,
      secondaryZoneId: secondaryZoneId ?? this.secondaryZoneId,
    );
  }

  /// Serialize to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'zoneId': zoneId,
    'skillId': skillId,
    'targetScore': targetScore,
    'xpReward': xpReward,
    'emoji': emoji,
    'date': date.toIso8601String(),
    'isCompleted': isCompleted,
    'currentProgress': currentProgress,
    'challengeType': challengeType.name,
    'secondaryZoneId': secondaryZoneId,
  };

  /// Deserialize from JSON
  static DailyChallenge fromJson(Map<String, dynamic> json) {
    final typeStr = json['challengeType'] as String? ?? 'normal';
    final challengeType = ChallengeType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => ChallengeType.normal,
    );
    return DailyChallenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      zoneId: json['zoneId'] as String,
      skillId: json['skillId'] as String,
      targetScore: json['targetScore'] as int,
      xpReward: json['xpReward'] as int,
      emoji: json['emoji'] as String,
      date: DateTime.parse(json['date'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      currentProgress: json['currentProgress'] as int? ?? 0,
      challengeType: challengeType,
      secondaryZoneId: json['secondaryZoneId'] as String?,
    );
  }
}
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

  /// Challenge type rotation — cycles through variants day by day so players
  /// experience a different mechanic every session.
  static const List<ChallengeType> _typeRotation = [
    ChallengeType.normal,
    ChallengeType.combo,
    ChallengeType.timed,
    ChallengeType.noHints,
    ChallengeType.mixed,
    ChallengeType.normal,
    ChallengeType.combo,
  ];

  /// Generate today's challenges (3 challenges, one easy, one medium, one hard)
  static List<DailyChallenge> generateDailyChallenges(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed); // Deterministic for same day

    final challenges = <DailyChallenge>[];

    // Generate 3 challenges from different zones
    final shuffledTemplates = List.from(_challengeTemplates)..shuffle(random);

    // Derive challenge types: easy is always normal, medium/hard rotate
    final dayIndex = date.difference(DateTime(2026, 1, 1)).inDays;
    final mediumType = _typeRotation[dayIndex % _typeRotation.length];
    final hardType =
        _typeRotation[(dayIndex + 2) % _typeRotation.length];

    final types = [ChallengeType.normal, mediumType, hardType];

    for (var i = 0; i < 3 && i < shuffledTemplates.length; i++) {
      final template = shuffledTemplates[i];
      final difficulty = i; // 0=easy, 1=medium, 2=hard
      final challengeType = types[i];

      final titles = template['titles'] as List;
      final descriptions = template['descriptions'] as List;
      final skillIds = template['skillIds'] as List;

      final targetScore = switch (difficulty) {
        0 => 3,
        1 => 5,
        _ => 7,
      };

      // XP bonus for harder challenge types
      final baseXp = switch (difficulty) {
        0 => 25,
        1 => 50,
        _ => 100,
      };
      final xpReward = challengeType == ChallengeType.normal
          ? baseXp
          : (baseXp * 1.4).round();

      // Build description incorporating challenge type suffix
      final baseDesc =
          (descriptions[random.nextInt(descriptions.length)] as String)
              .replaceAll('{count}', targetScore.toString());
      final description = '$baseDesc${challengeType.descriptionSuffix}';

      // For mixed challenges pick a second zone
      String? secondaryZoneId;
      if (challengeType == ChallengeType.mixed &&
          shuffledTemplates.length > 3) {
        secondaryZoneId =
            shuffledTemplates[3 + i % (shuffledTemplates.length - 3)]
                ['zone'] as String;
      }

      challenges.add(DailyChallenge(
        id: 'daily_${date.toIso8601String()}_$i',
        title: '${challengeType == ChallengeType.normal ? '' : '${challengeType.label} '}${titles[random.nextInt(titles.length)]}'.trim(),
        description: description,
        zoneId: template['zone'] as String,
        skillId: skillIds[random.nextInt(skillIds.length)] as String,
        targetScore: targetScore,
        xpReward: xpReward,
        emoji: template['emoji'] as String,
        date: date,
        challengeType: challengeType,
        secondaryZoneId: secondaryZoneId,
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
