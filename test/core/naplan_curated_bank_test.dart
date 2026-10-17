import 'dart:convert';
import 'dart:io';

import 'package:brightbound_adventures/core/models/naplan/naplan_question_set.dart'
    as naplan_models;
import 'package:brightbound_adventures/core/utils/naplan_curated_bank.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cross-reference gate for the curated NAPLAN JSON bank
/// (`lib/core/data/naplan_year3_numeracy.json`) against the numeracy backend.
///
/// The JSON file is the single source of truth; this test reads it off disk
/// (no asset bundle needed) and fails CI on the exact defect classes found
/// during the audit: wrong `correct_index`, duplicate options, missing
/// hints, and topics the [NaplanCuratedBank] cannot route to a skill.
void main() {
  late naplan_models.NaplanQuestionSet bank;

  setUpAll(() {
    final file = File('lib/core/data/naplan_year3_numeracy.json');
    expect(file.existsSync(), isTrue,
        reason: 'curated NAPLAN JSON bank must exist at '
            'lib/core/data/naplan_year3_numeracy.json');
    final jsonMap =
        json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    bank = naplan_models.NaplanQuestionSet.fromJson(jsonMap);
  });

  test('bank loads with unique IDs and covers multiple year levels', () {
    expect(bank.questions.length, greaterThanOrEqualTo(40));
    final ids = bank.questions.map((q) => q.id).toList();
    expect(ids.toSet().length, ids.length,
        reason: 'duplicate question IDs in curated bank');
    // File started as Year-3 only but now spans Years 3-7.
    expect(ids.any((id) => id.startsWith('NUM-Y3-')), isTrue);
    expect(ids.any((id) => id.startsWith('NUM-Y7-')), isTrue);
  });

  test('every curated question validates (index, options, hint, topic)', () {
    final errors = <String>[];
    for (final q in bank.questions) {
      final error = NaplanCuratedBank.validate(q);
      if (error != null) errors.add(error);
    }
    expect(errors, isEmpty,
        reason: 'curated bank defects:\n${errors.join('\n')}');
  });

  test('NUM-Y5-004 regression: cricket fraction is 1/2, no duplicate options',
      () {
    final q = bank.questions.firstWhere((q) => q.id == 'NUM-Y5-004');
    // 30 cricket of 60 total = 30/60 = 1/2.
    expect(q.options[q.correctIndex], '1/2');
    expect(q.options.toSet().length, q.options.length,
        reason: 'duplicate options in NUM-Y5-004');
  });

  test('NUM-Y3-011 regression: correct article for echidna', () {
    final q = bank.questions.firstWhere((q) => q.id == 'NUM-Y3-011');
    expect(q.options.any((o) => o.contains('an echidna')), isTrue,
        reason: 'expected "an echidna", got: ${q.options}');
    expect(q.options.any((o) => o.contains('a echidna')), isFalse);
  });

  test('conversion preserves correct_index, hint, and explanation fallback',
      () {
    final q = bank.questions.firstWhere((q) => q.id == 'NUM-Y3-005');
    final converted = NaplanCuratedBank.toNumeracyQuestion(
      q,
      skillId: 'skill_multiplication',
    );
    expect(converted.options[converted.correctIndex], '56');
    expect(converted.hint, isNotNull);
    expect(converted.hint, isNotEmpty);
    expect(converted.explanation, isNotNull);
    expect(converted.difficulty, inInclusiveRange(1, 5));
  });

  test('pickForSkill routes topics and honours the difficulty window', () {
    final picked = NaplanCuratedBank.pickForSkill(
      bank.questions,
      skillId: 'skill_money',
      skillName: 'Money',
      targetDifficulty: 2,
      count: 3,
    );
    expect(picked.length, greaterThanOrEqualTo(1));
    for (final q in picked) {
      expect(q.skillId, 'skill_money');
      expect(q.difficulty, inInclusiveRange(1, 3));
      expect(q.options[q.correctIndex], isNotEmpty);
    }
  });

  test('topic matching covers every bank topic', () {
    final topics = bank.questions.map((q) => q.topic).toSet();
    for (final topic in topics) {
      expect(NaplanCuratedBank.topicSkillHints.containsKey(topic.toLowerCase()),
          isTrue,
          reason: 'unroutable topic "$topic"');
    }
  });
}
