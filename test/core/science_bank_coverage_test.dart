import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/core/utils/science_question_bank.dart';

/// Audit B3 gate: Science Explorers is a content surface, not just code —
/// the bank must hold ≥ 100 questions with unique ids and texts, valid
/// answer keys, and enough depth for every session slice.
void main() {
  final questions = ScienceQuestionBank.all;

  test('science bank holds ≥ 100 questions', () {
    expect(questions.length, greaterThanOrEqualTo(100));
    expect(ScienceQuestionBank.totalCount, questions.length);
  });

  test('science bank ids and texts are unique; options and keys valid', () {
    final ids = <String>{};
    final texts = <String>{};
    for (final q in questions) {
      expect(ids.add(q.id), isTrue, reason: 'duplicate id: ${q.id}');
      expect(texts.add(q.question), isTrue,
          reason: 'duplicate text: ${q.question}');
      expect(q.options.length, 4, reason: '${q.id} must offer 4 options');
      expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
          reason: '${q.id} answer key out of range');
      expect(q.explanation, isNotEmpty, reason: '${q.id} missing explanation');
      expect(q.hint, isNotEmpty, reason: '${q.id} missing hint');
    }
    // No duplicate option lists inside a question.
    for (final q in questions) {
      expect(q.options.toSet().length, q.options.length,
          reason: '${q.id} has duplicate options');
    }
  });

  test('every skill × difficulty slice has enough depth for a session', () {
    // A default session draws 10 questions with ±1 difficulty tolerance;
    // every exact slice must carry at least 5 so get() rarely falls back.
    for (final skillId in const [
      'skill_biological_sciences',
      'skill_earth_sciences',
      'skill_physical_sciences',
    ]) {
      for (final difficulty in const [1, 2, 3]) {
        final n = questions
            .where((q) => q.skillId == skillId && q.difficulty == difficulty)
            .length;
        expect(n, greaterThanOrEqualTo(5),
            reason: '$skillId d$difficulty has only $n questions');
      }
    }
  });
}
