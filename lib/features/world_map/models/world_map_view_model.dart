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
    if (zoneIndex < 0 || zoneIndex >= zones.length) return false;
    final zone = zones[zoneIndex];
    if (totalStars < zone.requiredStars) return false;

    final group = zone.requiredSkillGroup;
    if (group == null || skillProvider == null) return true;

    return skillProvider
        .getSkillsByStrand(group)
        .any((s) => s.state == SkillState.mastered);
  }

  /// Evaluate the visible state of a zone using consistent semantic rules.
  WorldMapZoneStatus evaluateZoneState({
    required int zoneIndex,
    required int totalStars,
    SkillProvider? skillProvider,
    required int recommendedZoneIndex,
  }) {
    if (zoneIndex < 0 || zoneIndex >= zones.length) {
      return const WorldMapZoneStatus(
        state: WorldMapZoneState.locked,
        label: 'Locked',
        reason: 'This zone is not available.',
      );
    }

    final zone = zones[zoneIndex];
    if (!isZoneUnlocked(zoneIndex, totalStars, skillProvider)) {
      return WorldMapZoneStatus(
        state: WorldMapZoneState.locked,
        label: zoneStateLabel(WorldMapZoneState.locked),
        reason: 'Needs ${zone.requiredStars} stars and progress to unlock.',
      );
    }

    if (skillProvider == null) {
      final state = zoneIndex == recommendedZoneIndex
          ? WorldMapZoneState.recommended
          : WorldMapZoneState.available;
      return WorldMapZoneStatus(
        state: state,
        label: zoneStateLabel(state),
        reason: state == WorldMapZoneState.recommended
            ? 'Recommended for your next quest.'
            : 'Ready to explore.',
      );
    }

    final stats = skillProvider.getZoneStats(zone.skillZoneId);
    final progress =
        zoneProgressFraction(stats.masteredSkills, stats.totalSkills);
    final masteryReached = stats.totalSkills > 0 && progress >= 1.0;
    final recommended = zoneIndex == recommendedZoneIndex;

    if (masteryReached) {
      return const WorldMapZoneStatus(
        state: WorldMapZoneState.mastered,
        label: 'Mastered',
        reason: 'This zone is fully mastered.',
      );
    }

    if (recommended) {
      return const WorldMapZoneStatus(
        state: WorldMapZoneState.recommended,
        label: 'Recommended',
        reason: 'Recommended for your next quest.',
      );
    }

    if (stats.totalSkills > 0 && progress > 0.0) {
      return WorldMapZoneStatus(
        state: progress >= 0.75
            ? WorldMapZoneState.bossReady
            : WorldMapZoneState.inProgress,
        label: zoneStateLabel(
          progress >= 0.75
              ? WorldMapZoneState.bossReady
              : WorldMapZoneState.inProgress,
        ),
        reason: progress >= 0.75
            ? 'Boss-ready challenge and reward path.'
            : 'Quest progress is underway.',
      );
    }

    return const WorldMapZoneStatus(
      state: WorldMapZoneState.available,
      label: 'Available',
      reason: 'Ready to explore.',
    );
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
      final progress =
          zoneProgressFraction(stats.masteredSkills, stats.totalSkills);

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

  String zoneStateLabel(WorldMapZoneState state) {
    switch (state) {
      case WorldMapZoneState.locked:
        return 'Locked';
      case WorldMapZoneState.available:
        return 'Available';
      case WorldMapZoneState.recommended:
        return 'Recommended';
      case WorldMapZoneState.inProgress:
        return 'In progress';
      case WorldMapZoneState.needsReview:
        return 'Needs review';
      case WorldMapZoneState.bossReady:
        return 'Boss ready';
      case WorldMapZoneState.mastered:
        return 'Mastered';
    }
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

enum WorldMapZoneState {
  locked,
  available,
  recommended,
  inProgress,
  needsReview,
  bossReady,
  mastered,
}

class WorldMapZoneStatus {
  final WorldMapZoneState state;
  final String label;
  final String reason;

  const WorldMapZoneStatus({
    required this.state,
    required this.label,
    required this.reason,
  });
}
