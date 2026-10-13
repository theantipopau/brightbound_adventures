import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:brightbound_adventures/core/data/zone_guardian_data.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/skill_provider.dart';
import 'package:brightbound_adventures/ui/components/quest_intro.dart';

/// The quest-briefing beat shared by every zone practice screen.
///
/// The literacy slice established the session rhythm as
/// *intro → activity → results*; this wrapper gives the other five zones
/// (numeracy, science, logic, storytelling, motor) the same briefing without
/// re-deriving the zone pill, guardian companion, and reward framing per
/// screen. Rewards mirror the literacy slice (135 XP / 3 stars for a perfect
/// run — the shared `RewardBreakdown` confirms the same totals across zones).
///
/// Holds no colour literals of its own: the accent comes from the caller
/// (usually `WorldTokens.fromZoneId(...).primaryColor`).
class ZoneQuestIntro extends StatelessWidget {
  const ZoneQuestIntro({
    super.key,
    required this.zoneId,
    required this.zoneName,
    required this.title,
    required this.objective,
    required this.questionCount,
    required this.accent,
    required this.onStart,
    this.onBack,
    this.reason,
    this.difficulty,
    this.naplanLabel,
  });

  /// Normalised zone id (underscore format, as `zone_detail` passes it).
  final String? zoneId;

  /// Display name of the zone; the pill adds the emoji when it is missing.
  final String? zoneName;

  /// Skill / quest title.
  final String title;

  /// What the child will do this session.
  final String objective;

  /// Questions (or rounds) promised by the briefing chip.
  final int questionCount;

  /// Zone accent colour for the briefing.
  final Color accent;

  final VoidCallback onStart;
  final VoidCallback? onBack;

  /// Why this quest is being recommended; falls back to a zone-flavoured
  /// default so a screen without the recommendation engine still reads well.
  final String? reason;

  final int? difficulty;

  /// NAPLAN area label for the gold chip, when the skill has one.
  final String? naplanLabel;

  ZoneData get _zone {
    final normalized = (zoneId ?? '').replaceAll('_', '-').toLowerCase();
    for (final zone in ZoneCatalog.zones) {
      if (zone.id == normalized) return zone;
    }
    return ZoneCatalog.zones.first;
  }

  /// Zone label for the intro chip: zone routes already arrive as
  /// "🌲 Word Woods", catalogue-derived ones need their emoji adding.
  String get _zonePill {
    final label = zoneName ?? _zone.name;
    if (label.contains(_zone.name)) return label;
    return '${_zone.emoji} $label';
  }

  @override
  Widget build(BuildContext context) {
    final guardian = guardianForZone(zoneId ?? '');
    return QuestIntro(
      zoneLabel: _zonePill,
      title: title,
      objective: objective,
      reason: reason ?? 'Strengthen $title and light up more of ${_zone.name}.',
      questionCount: questionCount,
      rewardXp: 135,
      rewardStars: 3,
      accent: accent,
      companionEmoji: guardian?.emoji,
      companionLine: guardian?.questHook,
      difficulty: difficulty,
      naplanLabel: naplanLabel,
      onBack: onBack,
      onStart: onStart,
    );
  }
}

/// Looks up the authored [Skill] for an id-based practice screen so the
/// briefing can show its description, difficulty and NAPLAN label.
///
/// Returns null when the provider is unavailable (embedded demos) or the
/// skill is unknown — callers fall back to skill-name-only copy.
Skill? findZoneSkill(BuildContext context, String? zoneId, String skillId) {
  if (zoneId == null || zoneId.isEmpty) return null;
  try {
    final skills = context.read<SkillProvider>().getZoneSkills(zoneId);
    for (final skill in skills) {
      if (skill.id == skillId) return skill;
    }
  } catch (_) {
    // Provider not available — briefing falls back to name-only copy.
  }
  return null;
}
