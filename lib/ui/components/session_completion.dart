import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/core/utils/constants.dart';
import 'package:brightbound_adventures/features/world_map/services/recommendation_service.dart';
import 'package:brightbound_adventures/ui/widgets/zone_mastered_celebration.dart';

/// Everything a results screen needs after a session finishes, produced by
/// exactly one code path — [completeSession].
///
/// Split into *evidence* (skill progress, spaced repetition, session history:
/// safe to repeat) and *rewards* (XP, stars, streak, achievements, cosmetics:
/// applied once through `RewardTransactionService`).
class SessionCompletion {
  const SessionCompletion({
    required this.breakdown,
    required this.reward,
    required this.starBalance,
    required this.levelProgressBefore,
    required this.levelProgressAfter,
    required this.skillAccuracyBefore,
    required this.skillAccuracyAfter,
    required this.recommendation,
    required this.unlockNames,
  });

  /// Why the XP is what it is.
  final RewardBreakdown breakdown;

  /// The persisted reward transaction (idempotent per session).
  final RewardResult reward;

  /// Star balance after the award.
  final int starBalance;

  /// Level progress (0–1) immediately before and after this award.
  final double levelProgressBefore;
  final double levelProgressAfter;

  /// Skill accuracy before/after this session's evidence update — drives the
  /// reveal's mastery movement card. Null when the skill isn't stored yet.
  final double? skillAccuracyBefore;
  final double? skillAccuracyAfter;

  /// What to do next, or null when it can't be derived.
  final QuestRecommendation? recommendation;

  /// Friendly names for any achievement/cosmetic unlocks from this award.
  final List<String> unlockNames;
}

/// Runs the shared post-session orchestration for any learning zone:
///
///  1. evidence updates — skill progress, spaced repetition, zone mastery;
///  2. optional session-history entry (zones whose games don't record their
///     own summaries);
///  3. the single idempotent reward transaction;
///  4. the presentation data `RewardReveal` needs.
///
/// Called once per results screen after the first frame. Throwing here is
/// safe for the caller: `RewardTransactionService.apply` persists before
/// returning and returns the cached result on retry, so re-running never
/// double-awards.
Future<SessionCompletion> completeSession(
  BuildContext context, {
  required String sessionId,
  required String skillId,
  required String skillName,
  required double accuracy,
  required int correctAnswers,
  required int totalQuestions,
  required Color accent,
  int hintsUsed = 0,
  String? zoneId,
  String? zoneName,
  QuestSessionSummary? history,
}) async {
  final breakdown = RewardBreakdown.forSession(
    accuracy: accuracy,
    hintsUsed: hintsUsed,
  );

  // Read every provider up front so no `BuildContext` is used across an
  // await below.
  final skillProvider = context.read<SkillProvider>();
  final spaced = context.read<SpacedRepetitionService>();
  final rewards = context.read<RewardTransactionService>();
  final avatarProvider = context.read<AvatarProvider>();
  QuestSessionHistoryService? historyService;
  try {
    historyService = context.read<QuestSessionHistoryService>();
  } catch (_) {
    // Embedded demos/tests may not provide it — history is optional.
  }

  // --- Evidence. Not rewards, so they run outside the transaction and are
  // safe to repeat on an error retry.
  final accuracyBefore = skillProvider.getSkill(skillId)?.accuracy;
  skillProvider.updateSkillProgress(
    skillId: skillId,
    sessionAccuracy: accuracy,
    sessionHints: hintsUsed,
  );
  final accuracyAfter = skillProvider.getSkill(skillId)?.accuracy;

  spaced.recordSession(
    skillId: skillId,
    accuracy: accuracy,
  );

  checkAndShowZoneMastered(
    context,
    skillProvider,
    zoneId: zoneId,
    zoneName: zoneName,
    themeColor: accent,
  );

  if (history != null && historyService != null) {
    // Recorded keyed on the session id, so a retry replaces rather than
    // duplicates the entry.
    await historyService.recordSession(history);
  }

  final recommendation = _recommendation(
    skillProvider: skillProvider,
    historyService: historyService,
    spaced: spaced,
    zoneId: zoneId,
    zoneName: zoneName,
    justCompletedSkillId: skillId,
  );

  // --- The single reward application.
  final reward = await rewards.apply(
    QuestOutcome(
      outcomeId: sessionId,
      xpEarned: breakdown.totalXp,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      accuracy: accuracy,
      zoneId: zoneId,
    ),
    avatarProvider: avatarProvider,
  );

  // --- Presentation data.
  final (progressBefore, progressAfter) =
      _levelProgress(avatarProvider, reward);

  return SessionCompletion(
    breakdown: breakdown,
    reward: reward,
    starBalance: ShopService().starBalance,
    levelProgressBefore: progressBefore,
    levelProgressAfter: progressAfter,
    skillAccuracyBefore: accuracyBefore,
    skillAccuracyAfter: accuracyAfter,
    recommendation: recommendation,
    unlockNames: _unlockNames(reward),
  );
}

/// Returns to the living world map (the route the adventure runs on).
void backToWorldMap(BuildContext context) {
  Navigator.of(context).popUntil(
    (route) => route.isFirst || route.settings.name == '/world-map',
  );
}

/// `(level progress before, level progress after)` for the XP bar.
(double, double) _levelProgress(AvatarProvider avatars, RewardResult reward) {
  final avatar = avatars.avatar;
  if (avatar == null) return (0, 0);

  const perLevel = Constants.xpPerLevel;
  final after = avatar.experiencePoints / perLevel;
  final leveled = reward.newLevel - reward.previousLevel;
  final beforeXp =
      avatar.experiencePoints + leveled * perLevel - reward.xpAwarded;
  final before = (beforeXp.clamp(0, perLevel)) / perLevel;
  return (before, after.clamp(0.0, 1.0));
}

QuestRecommendation? _recommendation({
  required SkillProvider skillProvider,
  required QuestSessionHistoryService? historyService,
  required SpacedRepetitionService spaced,
  required String? zoneId,
  required String? zoneName,
  required String justCompletedSkillId,
}) {
  try {
    if (zoneId == null || historyService == null) return null;
    return const RecommendationService().recommend(
      zoneId: zoneId,
      zoneName: zoneName ?? zoneId,
      zoneSkills: skillProvider.getZoneSkills(zoneId),
      recentSessions: historyService.recentSessions(limit: 40),
      dueSkillIds: spaced.dueSkillIds.toSet(),
      justCompletedSkillId: justCompletedSkillId,
    );
  } catch (_) {
    // Recommendation is optional presentation — never block the reward.
    return null;
  }
}

List<String> _unlockNames(RewardResult reward) {
  final names = <String>[];
  try {
    final achievements = AchievementService();
    for (final id in reward.newlyUnlockedAchievementIds) {
      String resolved = id;
      for (final achievement in achievements.achievements) {
        if (achievement.id == id) {
          resolved = achievement.name;
          break;
        }
      }
      names.add(resolved);
    }
  } catch (_) {
    // Achievement service unavailable — fall through to cosmetic names.
  }
  try {
    final cosmetics = CosmeticUnlockService();
    final unlocked = cosmetics.getNewlyUnlocked();
    for (final id in reward.newlyUnlockedCosmeticIds) {
      String resolved = id;
      for (final item in unlocked) {
        if (item.id == id) {
          resolved = item.name;
          break;
        }
      }
      names.add(resolved);
    }
  } catch (_) {
    // Cosmetic service unavailable — the reveal simply shows fewer chips.
  }
  return names;
}

/// Shown while the reward transaction runs — an honest beat rather than a
/// frozen screen. Never claims a reward that hasn't landed.
class RewardApplyingCard extends StatelessWidget {
  const RewardApplyingCard({super.key, this.accent});

  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final border = accent ?? scheme.primary;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Packing your reward…',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown when the transaction fails. The transaction is idempotent, so the
/// retry is always safe — and the answers are never lost.
class RewardErrorCard extends StatelessWidget {
  const RewardErrorCard({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.error, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 36, color: scheme.error),
          const SizedBox(height: 10),
          Text(
            'We could not pack your reward just now. Your answers are safe — '
            'try again.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
