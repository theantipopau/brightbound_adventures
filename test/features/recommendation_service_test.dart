import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/features/world_map/services/recommendation_service.dart';

Skill _skill(
  String id, {
  double accuracy = 0.0,
  int attempts = 0,
  SkillState state = SkillState.introduced,
}) {
  return Skill(
    id: id,
    name: id.replaceAll('skill_', '').replaceAll('_', ' '),
    description: 'Test skill',
    strand: 'Literacy',
    state: state,
    accuracy: accuracy,
    attempts: attempts,
    lastPracticed: DateTime(2026, 1, 1),
  );
}

QuestSessionSummary _session(
  String skillId, {
  required double accuracy,
  int total = 10,
  DateTime? endedAt,
}) {
  final end = endedAt ?? DateTime(2026, 10, 1, 9);
  return QuestSessionSummary(
    id: '${end.microsecondsSinceEpoch}_$skillId',
    zoneId: 'word-woods',
    skillId: skillId,
    skillName: skillId,
    mode: 'practice',
    startedAt: end.subtract(const Duration(minutes: 5)),
    endedAt: end,
    totalQuestions: total,
    correctAnswers: (accuracy * total).round(),
    score: (accuracy * total).round(),
    hintsUsed: 0,
    difficulty: 2,
    forced: false,
    questionIds: const ['q1'],
  );
}

void main() {
  const service = RecommendationService();

  List<Skill> zoneSkills() => [
        _skill('skill_homophones'),
        _skill('skill_apostrophes'),
        _skill('skill_comma_usage'),
      ];

  group('RecommendationService', () {
    test('defaults to the first unpractised skill when history is empty', () {
      final rec = service.recommend(
        zoneId: 'word-woods',
        zoneName: 'Word Woods',
        zoneSkills: zoneSkills(),
      );

      expect(rec.kind, QuestRecommendationKind.newSkill);
      expect(rec.skillId, 'skill_homophones');
      expect(rec.childReason, contains('homophones'));
      expect(rec.parentReason, contains('has not been practised yet'));
      expect(rec.hasActivity, isTrue);
      expect(rec.chipLabel, 'New');
    });

    test('prefers a due spaced review and explains it to parents', () {
      final rec = service.recommend(
        zoneId: 'word-woods',
        zoneName: 'Word Woods',
        zoneSkills: zoneSkills(),
        dueSkillIds: {'skill_comma_usage'},
      );

      expect(rec.kind, QuestRecommendationKind.review);
      expect(rec.skillId, 'skill_comma_usage');
      expect(rec.parentReason, contains('due for spaced review'));
      expect(rec.childReason, contains('revisit'));
      expect(rec.chipLabel, 'Review');
    });

    test('a skill averaging under 70% across two sessions needs review', () {
      final rec = service.recommend(
        zoneId: 'word-woods',
        zoneName: 'Word Woods',
        zoneSkills: zoneSkills(),
        recentSessions: [
          _session('skill_apostrophes', accuracy: 0.4),
          _session('skill_apostrophes', accuracy: 0.5),
        ],
      );

      expect(rec.kind, QuestRecommendationKind.review);
      expect(rec.skillId, 'skill_apostrophes');
      expect(rec.accuracy, closeTo(0.45, 0.001));
      expect(rec.sessionCount, 2);
      expect(rec.parentReason, contains('45%'));
      expect(rec.parentReason, contains('below the 70% review threshold'));
    });

    test('one weak session is not enough to demand a review', () {
      final rec = service.recommend(
        zoneId: 'word-woods',
        zoneName: 'Word Woods',
        zoneSkills: zoneSkills(),
        recentSessions: [_session('skill_apostrophes', accuracy: 0.3)],
      );

      expect(rec.kind, isNot(QuestRecommendationKind.review));
    });

    test('continues the weakest practised skill and skips the one just done',
        () {
      final rec = service.recommend(
        zoneId: 'word-woods',
        zoneName: 'Word Woods',
        zoneSkills: [
          _skill('skill_homophones',
              accuracy: 0.9, attempts: 3, state: SkillState.practising),
          _skill('skill_apostrophes',
              accuracy: 0.75, attempts: 2, state: SkillState.practising),
          _skill('skill_comma_usage',
              accuracy: 0.8, attempts: 4, state: SkillState.practising),
        ],
        justCompletedSkillId: 'skill_comma_usage',
      );

      expect(rec.kind, QuestRecommendationKind.continuePractice);
      expect(rec.skillId, 'skill_apostrophes',
          reason: 'weakest remaining skill, not the one just finished');
      expect(rec.parentReason, contains('accuracy 75%'));
      expect(rec.childReason, contains('part way there'));
    });

    test('a three-quarter-mastered zone recommends the boss challenge', () {
      final rec = service.recommend(
        zoneId: 'word-woods',
        zoneName: 'Word Woods',
        zoneSkills: [
          _skill('skill_a',
              accuracy: 0.95, attempts: 5, state: SkillState.mastered),
          _skill('skill_b',
              accuracy: 0.9, attempts: 5, state: SkillState.mastered),
          _skill('skill_c',
              accuracy: 0.92, attempts: 5, state: SkillState.mastered),
          _skill('skill_d',
              accuracy: 0.7, attempts: 1, state: SkillState.practising),
        ],
      );

      expect(rec.kind, QuestRecommendationKind.challenge);
      expect(rec.hasActivity, isFalse);
      expect(rec.zoneProgress, closeTo(0.75, 0.001));
      expect(rec.parentReason, contains('75%'));
      expect(rec.childReason, contains('Boss Challenge'));
    });

    test('a just-completed skill under 70% is offered an immediate repeat', () {
      final rec = service.recommend(
        zoneId: 'word-woods',
        zoneName: 'Word Woods',
        zoneSkills: [
          _skill('skill_homophones', accuracy: 0.5, attempts: 1),
          _skill('skill_apostrophes'),
        ],
        justCompletedSkillId: 'skill_homophones',
      );

      expect(rec.kind, QuestRecommendationKind.review);
      expect(rec.skillId, 'skill_homophones');
      expect(rec.parentReason, contains('below the 70% confidence threshold'));
    });

    test('locked skills are never recommended', () {
      final rec = service.recommend(
        zoneId: 'word-woods',
        zoneName: 'Word Woods',
        zoneSkills: [
          _skill('skill_locked', state: SkillState.locked),
          _skill('skill_open'),
        ],
      );

      expect(rec.skillId, 'skill_open');
    });

    test('a zone with nothing unlocked says so instead of inventing advice',
        () {
      final rec = service.recommend(
        zoneId: 'word-woods',
        zoneName: 'Word Woods',
        zoneSkills: [_skill('skill_locked', state: SkillState.locked)],
      );

      expect(rec.kind, QuestRecommendationKind.freshStart);
      expect(rec.hasActivity, isFalse);
      expect(rec.parentReason, contains('No unlocked skills'));
      expect(rec.childReason, contains('Word Woods'));
    });

    test('identical inputs always produce an identical recommendation', () {
      final skills = zoneSkills();
      final sessions = [
        _session('skill_homophones', accuracy: 0.8),
        _session('skill_homophones', accuracy: 0.6),
      ];

      final first = service.recommend(
        zoneId: 'word-woods',
        zoneName: 'Word Woods',
        zoneSkills: skills,
        recentSessions: sessions,
        dueSkillIds: const {'skill_comma_usage'},
      );
      final second = service.recommend(
        zoneId: 'word-woods',
        zoneName: 'Word Woods',
        zoneSkills: skills,
        recentSessions: sessions,
        dueSkillIds: const {'skill_comma_usage'},
      );

      expect(second.kind, first.kind);
      expect(second.skillId, first.skillId);
      expect(second.childReason, first.childReason);
      expect(second.parentReason, first.parentReason);
    });

    test('every recommendation carries a child and a parent reason', () {
      final cases = <List<Skill>>[
        zoneSkills(),
        [
          _skill('skill_a',
              accuracy: 0.9, attempts: 2, state: SkillState.practising)
        ],
        [
          _skill('skill_a',
              state: SkillState.mastered, accuracy: 1, attempts: 4),
          _skill('skill_b',
              state: SkillState.mastered, accuracy: 1, attempts: 4),
          _skill('skill_c',
              state: SkillState.mastered, accuracy: 1, attempts: 4),
          _skill('skill_d',
              state: SkillState.mastered, accuracy: 1, attempts: 4),
        ],
      ];

      for (final skills in cases) {
        final rec = service.recommend(
          zoneId: 'word-woods',
          zoneName: 'Word Woods',
          zoneSkills: skills,
        );
        expect(rec.childReason.trim(), isNotEmpty);
        expect(rec.parentReason.trim(), isNotEmpty);
        expect(rec.childReason, isNot(contains('%')),
            reason: 'child-facing text should stay free of raw evidence');
        expect(rec.parentReason.contains('Recommended'), isTrue,
            reason: 'parent-facing text must state why it was recommended');
      }
    });
  });
}
