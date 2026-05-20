import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Data class for zone information in the world map
class ZoneData extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final Offset position;
  final String description;
  final int order;
  final int requiredStars;

  /// Optional skill group that must have at least one mastered skill before
  /// this zone becomes accessible. e.g. 'literacy', 'numeracy'.
  final String? requiredSkillGroup;

  /// Canonical ID used by curriculum/progression systems.
  ///
  /// The route/map layer historically uses kebab-case (`word-woods`) while
  /// skills and content use snake_case (`word_woods`). Keeping the conversion
  /// here prevents each screen from inventing its own mapping rule.
  String get skillZoneId => id.replaceAll('-', '_');

  const ZoneData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.position,
    required this.description,
    required this.order,
    required this.requiredStars,
    this.requiredSkillGroup,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        emoji,
        color,
        position,
        description,
        order,
        requiredStars,
        requiredSkillGroup,
      ];
}
