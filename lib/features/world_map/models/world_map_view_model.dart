import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';

/// Pure model logic for world map state: zone unlock/progress, recommendations.
/// Zero Flutter imports — unit-testable without widgets.
class WorldMapViewModel {
  final List<ZoneData> zones;

  const WorldMapViewModel({required this.zones});

  /// Calculate total stars from a SkillProvider snapshot.
  int calculateTotalStars(SkillProvider skillProvider) {
    final stats = skillProvider.getProgressionStats();
    return stats.mastered * 3 + stats.practising;
  }

  /// Check if a zone is unlocked based on star requirement and skill prerequisites.
  bool isZoneUnlocked(
    int zoneIndex,
    int totalStars, [
    SkillProvider? skillProvider,
  ]) {
    if (zoneIndex >= zones.length) return false;
    final zone = zones[zoneIndex];
    if (totalStars < zone.requiredStars) return false;

    final group = zone.requiredSkillGroup;
    if (group == null || skillProvider == null) return true;

    return skillProvider
        .getSkillsByStrand(group)
        .any((s) => s.state == SkillState.mastered);
  }

  /// Recommend the next zone to work on: lowest progress unlocked zone.
  /// Falls back to currentZoneIndex if all unlocked zones are complete.
  int recommendedZoneIndex(
    int currentZoneIndex,
    int totalStars,
    SkillProvider skillProvider,
  ) {
    var fallback = currentZoneIndex;
    var lowestProgress = 2.0;

    for (var i = 0; i < zones.length; i++) {
      if (!isZoneUnlocked(i, totalStars, skillProvider)) continue;

      final stats = skillProvider.getZoneStats(zones[i].skillZoneId);
      final progress = zoneProgressFraction(stats.masteredSkills, stats.totalSkills);

      if (progress < 1.0 && progress < lowestProgress) {
        fallback = i;
        lowestProgress = progress;
      }
    }

    return fallback;
  }

  /// Progress as a fraction [0, 1] of mastered/total skills in a zone.
  double zoneProgressFraction(int masteredSkills, int totalSkills) {
    if (totalSkills <= 0) return 0;
    return (masteredSkills / totalSkills).clamp(0, 1).toDouble();
  }

  /// Human-readable mood/flavor text for a zone.
  String zoneMoodText(ZoneData zone) {
    switch (zone.id) {
      case 'word-woods':
        return 'Calm forest trails with vocabulary quests';
      case 'number-nebula':
        return 'Cosmic routes with number missions';
      case 'math-facts':
        return 'Fast-paced drills with combo rewards';
      case 'story-springs':
        return 'Creative paths and storytelling prompts';
      case 'science-explorers':
        return 'Experiment tracks and discovery boosts';
      case 'creative-corner':
        return 'Art and rhythm activities';
      case 'puzzle-peaks':
        return 'Logic climbs and pattern challenges';
      case 'adventure-arena':
        return 'Boss-level mixed mastery challenges';
      default:
        return 'New adventures await here';
    }
  }

  /// Feature tags describing a zone's activity type.
  List<String> zoneFeatureTags(ZoneData zone) {
    switch (zone.id) {
      case 'word-woods':
        return ['Reading', 'Spelling', 'Vocabulary'];
      case 'number-nebula':
        return ['Counting', 'Place Value', 'Numeracy'];
      case 'math-facts':
        return ['Fast Facts', 'Times Tables', 'Fluency'];
      case 'story-springs':
        return ['Story Build', 'Comprehension', 'Writing'];
      case 'science-explorers':
        return ['Discovery', 'Experiments', 'Critical Thinking'];
      case 'creative-corner':
        return ['Art', 'Music', 'Expression'];
      case 'puzzle-peaks':
        return ['Logic', 'Patterns', 'Problem Solving'];
      case 'adventure-arena':
        return ['Boss Battles', 'Mixed Skills', 'Challenge'];
      default:
        return [];
    }
  }
}
