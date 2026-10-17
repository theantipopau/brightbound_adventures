import 'package:brightbound_adventures/core/models/naplan/naplan_question_set.dart'
    as naplan_models;
import 'package:brightbound_adventures/features/numeracy/models/question.dart';

/// Bridge between the curated NAPLAN JSON banks
/// (`lib/core/data/naplan_year3_numeracy.json`, loaded via
/// `QuestionLoaderService`) and the synchronous numeracy generators.
///
/// The JSON file is the single source of truth — this file carries no
/// question text, only the topic/skill mapping, difficulty matching, and
/// model conversion. A dedicated test (`test/core/naplan_curated_bank_test`)
/// reads the JSON off disk and cross-references it: every entry must have
/// a valid `correct_index`, unique options, a hint, and a topic this bridge
/// knows how to route to a Number Nebula skill.
class NaplanCuratedBank {
/// JSON topic -> skill-id fragments used by `NumberNebulaQuestionGenerator`
/// and `NumeracyPracticeScreen._getQuestionsForSkill`.
  static const Map<String, List<String>> topicSkillHints = {
    'number': ['addition', 'subtraction', 'multiplication', 'division', 'counting', 'place_value', 'number'],
    'money': ['money'],
    'geometry': ['geometry', 'shapes'],
    'time': ['time'],
    'measurement': ['measurement', 'conversion'],
    'patterns': ['patterns'],
    'fractions': ['fraction'],
  };

  /// Returns true when a curated question's topic can serve [skillName].
  /// Matching is case-insensitive substring matching over both the topic
  /// hint fragments and the raw topic string, so generic skills like
  /// "all" still match everything.
  static bool topicMatchesSkill(String topic, String skillName) {
    final s = skillName.toLowerCase();
    if (s == 'all' || s.isEmpty) return true;
    final t = topic.toLowerCase();
    if (s.contains(t) || t.contains(s)) return true;
    final fragments = topicSkillHints[t] ?? const <String>[];
    return fragments.any((f) => s.contains(f) || f.contains(s));
  }

  /// Adaptive difficulty window: curated difficulty is 1-5, generator
  /// difficulties are 1-5. Allow a ±1 window so a difficulty-2 quest can
  /// still draw on difficulty-1 warmups and difficulty-3 stretches —
  /// mirroring the adaptive mix in `NumberNebulaQuestionGenerator`.
  static bool difficultyMatches(int curatedDifficulty, int targetDifficulty) {
    return (curatedDifficulty - targetDifficulty).abs() <= 1;
  }

/// Converts one curated `Question` into a playable `NumeracyQuestion`.
/// The JSON `correct_index` is preserved verbatim
  /// (never re-derived from answer text), the JSON `hint` is kept, and the
  /// explanation falls back to the hint so the "why" surface never renders
  /// empty for curated questions.
  ///
  /// [idSuffix] keeps session IDs unique when the same curated question is
  /// drawn into several sessions (`wasRecentlyUsed` keys on id).
  static NumeracyQuestion toNumeracyQuestion(
    naplan_models.Question curated, {
    required String skillId,
    String idSuffix = '',
  }) {
    final suffix = idSuffix.isEmpty ? '' : '_$idSuffix';
    return NumeracyQuestion(
      id: '${curated.id}$suffix',
      skillId: skillId,
      question: curated.question,
      options: List<String>.from(curated.options),
      correctIndex: curated.correctIndex,
      hint: curated.hint,
      explanation: curated.hint,
      difficulty: curated.difficulty.clamp(1, 5),
    );
  }

  /// Filters [candidates] to questions serving [skillName] at
  /// [targetDifficulty], converts them, shuffles, and takes up to [count].
  /// Pure function so it is unit-testable without asset bundles.
  static List<NumeracyQuestion> pickForSkill(
    List<naplan_models.Question> candidates, {
    required String skillId,
    required String skillName,
    required int targetDifficulty,
    int count = 3,
  }) {
    final matching = candidates
        .where((q) =>
            topicMatchesSkill(q.topic, skillName) &&
            difficultyMatches(q.difficulty, targetDifficulty.clamp(1, 5)))
        .toList()
      ..shuffle();
    return matching
        .take(count)
        .map((q) => toNumeracyQuestion(q, skillId: skillId))
        .toList();
  }

  /// Validates one curated question. Returns a human-readable error, or
  /// null when valid. Used by the cross-reference test and available to
  /// any future content-matrix CI gate.
  static String? validate(naplan_models.Question q) {
    if (q.id.isEmpty) return 'empty id';
    if (q.question.isEmpty) return '${q.id}: empty question text';
    if (q.options.length < 2) return '${q.id}: fewer than 2 options';
    if (q.correctIndex < 0 || q.correctIndex >= q.options.length) {
      return '${q.id}: correct_index ${q.correctIndex} out of range '
          'for ${q.options.length} options';
    }
    final seen = <String>{};
    for (final o in q.options) {
      if (!seen.add(o.trim().toLowerCase())) {
        return '${q.id}: duplicate option "$o"';
      }
    }
    if ((q.hint ?? '').trim().isEmpty) return '${q.id}: missing hint';
    if (!topicSkillHints.containsKey(q.topic.toLowerCase())) {
      return '${q.id}: unroutable topic "${q.topic}"';
    }
    if (q.difficulty < 1 || q.difficulty > 5) {
      return '${q.id}: difficulty ${q.difficulty} outside 1-5';
    }
    return null;
  }
}
