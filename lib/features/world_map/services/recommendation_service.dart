import 'package:flutter/foundation.dart';
import 'package:brightbound_adventures/core/models/index.dart';

/// What kind of activity the recommendation engine settled on.
enum QuestRecommendationKind {
  /// The learner is due to revisit something they have already met.
  review,

  /// The learner is mid-way through a skill and should keep going.
  continuePractice,

  /// The zone is close to mastery; the boss challenge is the right next step.
  challenge,

  /// A fresh, unlocked skill has never been practised.
  newSkill,

  /// No stronger signal exists — fall back to the first unlocked skill.
  freshStart,
}

/// An explainable "what to do next" suggestion.
///
/// Always carries two reasons on purpose (product pillar: TRUST):
/// [childReason] is short, warm, and free of pressure; [parentReason] cites
/// the actual stored evidence so an adult can see *why* the app suggested it.
/// Neither may claim more than the inputs support — if there is no evidence,
/// the kind is [QuestRecommendationKind.freshStart] and the parent reason
/// says so.
@immutable
class QuestRecommendation {
  const QuestRecommendation({
    required this.kind,
    required this.skillId,
    required this.skillName,
    required this.zoneId,
    required this.childReason,
    required this.parentReason,
    this.accuracy,
    this.sessionCount,
    this.zoneProgress,
  });

  final QuestRecommendationKind kind;

  /// Null only for zone-level fallbacks where no concrete skill applies.
  final String? skillId;
  final String skillName;
  final String? zoneId;

  final String childReason;
  final String parentReason;

  /// Evidence backing the suggestion, when one exists.
  final double? accuracy;
  final int? sessionCount;
  final double? zoneProgress;

  /// Whether this recommendation points at a concrete activity the learner
  /// can start right away.
  bool get hasActivity => skillId != null;

  /// Short label for status chips.
  String get chipLabel {
    switch (kind) {
      case QuestRecommendationKind.review:
        return 'Review';
      case QuestRecommendationKind.continuePractice:
        return 'Keep going';
      case QuestRecommendationKind.challenge:
        return 'Challenge';
      case QuestRecommendationKind.newSkill:
        return 'New';
      case QuestRecommendationKind.freshStart:
        return 'Explore';
    }
  }
}

/// Suggests the next activity from real learner history.
///
/// A pure function of its inputs (skills, past sessions, due reviews), so it
/// is deterministic under test. Ordering rules are total — ties break on
/// skill id — so identical inputs always produce the identical suggestion.
class RecommendationService {
  const RecommendationService();

  /// Best next activity for [zoneSkills], using:
  ///  * [dueSkillIds] — spaced-repetition reviews that are due today;
  ///  * [recentSessions] — persisted session history (newest first);
  ///  * [justCompletedSkillId] — the skill finished most recently, so a
  ///    session can point at what comes *next* instead of repeating what
  ///    just happened.
  QuestRecommendation recommend({
    required String zoneId,
    required String zoneName,
    required List<Skill> zoneSkills,
    List<QuestSessionSummary> recentSessions = const [],
    Set<String> dueSkillIds = const {},
    String? justCompletedSkillId,
  }) {
    final playable =
        zoneSkills.where((s) => s.state != SkillState.locked).toList();

    // Input order is curriculum order, so "new skill" suggestions follow the
    // syllabus rather than an alphabetical accident of id. Ties elsewhere
    // break on this same order, keeping results deterministic.
    final order = <String, int>{
      for (var i = 0; i < playable.length; i++) playable[i].id: i,
    };
    int rankOf(Skill skill) => order[skill.id] ?? 0;

    if (playable.isEmpty) {
      return QuestRecommendation(
        kind: QuestRecommendationKind.freshStart,
        skillId: null,
        skillName: zoneName,
        zoneId: zoneId,
        childReason: '$zoneName is getting ready for you. Check back soon!',
        parentReason:
            'No unlocked skills are available in $zoneName, so no activity can be recommended yet.',
      );
    }

    final mastered =
        playable.where((s) => s.state == SkillState.mastered).length;
    final progress = mastered / playable.length;

    // 1. Review — spaced review due, or two-plus recent sessions under 70%.
    final review = _reviewTarget(
      playable: playable,
      rankOf: rankOf,
      recentSessions: recentSessions,
      dueSkillIds: dueSkillIds,
      justCompletedSkillId: justCompletedSkillId,
    );
    if (review != null) return review;

    // 2. Challenge — zone three-quarters mastered means the boss is ready.
    if (progress >= 0.75 && mastered < playable.length) {
      return QuestRecommendation(
        kind: QuestRecommendationKind.challenge,
        skillId: null,
        skillName: zoneName,
        zoneId: zoneId,
        childReason:
            '$zoneName is nearly mastered — the Boss Challenge is ready for you!',
        parentReason:
            'Recommended because ${(progress * 100).round()}% of $zoneName skills are mastered, which is the threshold for a mixed-mastery challenge.',
        zoneProgress: progress,
      );
    }

    // 3. Continue — already started, weakest first, skipping the skill the
    //    learner just finished so "next" really means next.
    final started = playable
        .where((s) =>
            s.attempts > 0 &&
            s.state != SkillState.mastered &&
            s.id != justCompletedSkillId)
        .toList()
      ..sort((a, b) {
        final byAccuracy = a.accuracy.compareTo(b.accuracy);
        return byAccuracy != 0 ? byAccuracy : rankOf(a) - rankOf(b);
      });
    if (started.isNotEmpty) {
      final skill = started.first;
      final sessions =
          recentSessions.where((session) => session.skillId == skill.id).length;
      return QuestRecommendation(
        kind: QuestRecommendationKind.continuePractice,
        skillId: skill.id,
        skillName: skill.name,
        zoneId: zoneId,
        childReason: 'Keep going with ${skill.name} — you are part way there.',
        parentReason:
            'Recommended to continue ${skill.name}: accuracy ${(skill.accuracy * 100).round()}% over ${skill.attempts} attempt${skill.attempts == 1 ? '' : 's'}'
            '${sessions > 0 ? ', $sessions recorded session${sessions == 1 ? '' : 's'}' : ''}.',
        accuracy: skill.accuracy,
        sessionCount: sessions,
        zoneProgress: progress,
      );
    }

    // 4. New — never practised, in curriculum order.
    final untouched = playable.where((s) => s.attempts == 0).toList();
    if (untouched.isNotEmpty) {
      final skill = untouched.first;
      return QuestRecommendation(
        kind: QuestRecommendationKind.newSkill,
        skillId: skill.id,
        skillName: skill.name,
        zoneId: zoneId,
        childReason: 'A new skill is waiting for you: ${skill.name}.',
        parentReason:
            'Recommended because ${skill.name} has not been practised yet and is already unlocked.',
        zoneProgress: progress,
      );
    }

    // 5. Everything is practised/mastered — hand back the weakest skill so
    //    the suggestion is still actionable, and say plainly that this is a
    //    default rather than an evidence-based call.
    final fallback = [...playable]..sort((a, b) {
        final byAccuracy = a.accuracy.compareTo(b.accuracy);
        return byAccuracy != 0 ? byAccuracy : rankOf(a) - rankOf(b);
      });
    final skill = fallback.first;
    return QuestRecommendation(
      kind: QuestRecommendationKind.freshStart,
      skillId: skill.id,
      skillName: skill.name,
      zoneId: zoneId,
      childReason: 'Another round of ${skill.name} to keep it sharp!',
      parentReason:
          'Recommended by default: no review, in-progress, or new skill is outstanding in $zoneName, so this falls back to the lowest-accuracy skill (${skill.name}, ${(skill.accuracy * 100).round()}%).',
      accuracy: skill.accuracy,
      zoneProgress: progress,
    );
  }

  /// Picks the skill most in need of review, or null when nothing qualifies.
  ///
  /// Selection order (total, so results are deterministic): due reviews beat
  /// non-due, then lower average accuracy wins, then skill id ascending.
  QuestRecommendation? _reviewTarget({
    required List<Skill> playable,
    required int Function(Skill) rankOf,
    required List<QuestSessionSummary> recentSessions,
    required Set<String> dueSkillIds,
    String? justCompletedSkillId,
  }) {
    final perSkill = <String, List<QuestSessionSummary>>{};
    for (final session in recentSessions) {
      perSkill.putIfAbsent(session.skillId, () => []).add(session);
    }

    Skill? best;
    bool bestDue = false;
    double bestAccuracy = 1.0;
    int bestSessions = 0;

    for (final skill in playable) {
      final sessions = perSkill[skill.id] ?? const <QuestSessionSummary>[];
      final due = dueSkillIds.contains(skill.id);
      double? average;
      if (sessions.isNotEmpty) {
        average = sessions.fold<double>(0, (sum, s) => sum + s.accuracy) /
            sessions.length;
      }
      final shaky = average != null && sessions.length >= 2 && average < 0.70;
      if (!due && !shaky) continue;

      final accuracy = average ?? skill.accuracy;
      final better = best == null ||
          (due && !bestDue) ||
          (due == bestDue &&
              (accuracy < bestAccuracy ||
                  (accuracy == bestAccuracy && rankOf(skill) < rankOf(best))));
      if (better) {
        best = skill;
        bestDue = due;
        bestAccuracy = accuracy;
        bestSessions = sessions.length;
      }
    }

    if (best != null) {
      return QuestRecommendation(
        kind: QuestRecommendationKind.review,
        skillId: best.id,
        skillName: best.name,
        zoneId: null,
        childReason: bestDue
            ? 'It is time to revisit ${best.name} so it stays fresh.'
            : 'Let us practise ${best.name} once more so it really sticks.',
        parentReason: bestDue
            ? 'Recommended because ${best.name} is due for spaced review'
                '${bestSessions > 0 ? ' and averages ${(bestAccuracy * 100).round()}% across the last $bestSessions session${bestSessions == 1 ? '' : 's'}' : ''}.'
            : 'Recommended because ${best.name} averages ${(bestAccuracy * 100).round()}% across the last $bestSessions session${bestSessions == 1 ? '' : 's'}, below the 70% review threshold.',
        accuracy: bestAccuracy,
        sessionCount: bestSessions,
      );
    }

    // Nothing in history says "review", but the skill just attempted came in
    // under 70% — offer an immediate confidence-building repeat.
    if (justCompletedSkillId != null) {
      Skill? justDone;
      for (final skill in playable) {
        if (skill.id == justCompletedSkillId) {
          justDone = skill;
          break;
        }
      }
      if (justDone != null &&
          justDone.attempts > 0 &&
          justDone.accuracy < 0.70) {
        return QuestRecommendation(
          kind: QuestRecommendationKind.review,
          skillId: justDone.id,
          skillName: justDone.name,
          zoneId: null,
          childReason:
              'Let us practise ${justDone.name} once more so it really sticks.',
          parentReason:
              'Recommended because ${justDone.name} is sitting at ${(justDone.accuracy * 100).round()}% accuracy after ${justDone.attempts} attempt${justDone.attempts == 1 ? '' : 's'}, below the 70% confidence threshold.',
          accuracy: justDone.accuracy,
          sessionCount: 0,
        );
      }
    }

    return null;
  }
}
