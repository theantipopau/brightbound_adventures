import 'package:brightbound_adventures/core/utils/adventure_arena_generator.dart';
import 'package:brightbound_adventures/core/utils/creative_corner_generator.dart';
import 'package:brightbound_adventures/core/utils/number_nebula_generator.dart';
import 'package:brightbound_adventures/core/utils/puzzle_peaks_generator.dart';
import 'package:flutter_test/flutter_test.dart';

/// Zone-content audit gates (same discipline as `science_bank_coverage_test`):
/// every zone generator must return
/// structurally valid questions that are unique within a session, and fixed
/// pools must be *sampled* (shuffled) rather than served in list order.
///
/// Content floors are deliberately set at today's measured reality — they
/// stop silent shrinkage, not a fixed content target. Expansion beyond the
/// floors is tracked in the audit report, not encoded here.
void main() {
  group('Creative Corner — five fixed pools', () {
    test('all five pools exist with depth and unique ids and texts', () {
      final names = <String, List>{
        'visual_arts': CreativeCornerQuestions.visualArts,
        'music': CreativeCornerQuestions.music,
        'art_elements': CreativeCornerQuestions.artElements,
        'creative_expression': CreativeCornerQuestions.creativeExpression,
        'famous_artists': CreativeCornerQuestions.famousArtists,
      };

      final ids = <String>{};
      final texts = <String>{};
      for (final entry in names.entries) {
        expect(entry.value.length, greaterThanOrEqualTo(5),
            reason: '${entry.key} pool shrank below the depth floor');
        for (final q in entry.value) {
          expect(ids.add(q.id), isTrue,
              reason: 'duplicate id ${q.id} (${entry.key})');
          expect(texts.add(q.question), isTrue,
              reason: 'duplicate text in ${entry.key}: ${q.question}');
          expect(q.options.length, greaterThanOrEqualTo(2),
              reason: '${q.id} offers too few options');
          expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
              reason: '${q.id} answer key out of range');
        }
      }
      expect(ids.length, 43,
          reason: 'the bank has been audited at 43 questions — fix it');
      expect(texts.length, 43,
          reason: 'the bank has been audited at 43 texts — fix it');
    });

    test('getBySkillId samples the pool instead of serving list order', () {
      final draws = <String>[];
      for (var i = 0; i < 3; i++) {
        draws.add(CreativeCornerQuestions.getBySkillId('skill_music',
                difficulty: 5)
            .map((q) => q.id)
            .join('|'));
      }
      expect(draws.toSet().length, greaterThanOrEqualTo(2),
          reason:
              'three full-pool draws in identical order means the shuffle is gone');
    });
  });

  group('Puzzle Peaks — bank + procedural logic', () {
    test('one session of 10 is unique, valid and answer positions vary', () {
      final questions = PuzzlePeaksQuestionGenerator.generate(
          skill: '', difficulty: 1, count: 10);

      expect(questions.length, 10);
      final ids = <String>{};
      final texts = <String>{};
      var answerNotFirst = 0;
      for (final q in questions) {
        expect(ids.add(q.id), isTrue, reason: 'duplicate id in-session: ${q.id}');
        expect(texts.add(q.question), isTrue,
            reason: 'duplicate text in-session: ${q.question}');
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
            reason: '${q.id} answer key out of range');
        if (q.correctIndex != 0) answerNotFirst++;
      }
      // The audit found easy templates pinning the answer to options[0] —
      // a position-guessable session must not come back.
      expect(answerNotFirst, greaterThanOrEqualTo(2),
          reason:
              'answers pinned to the first row (position-guessable session)');
    });
  });

  group('Number Nebula — procedural numeracy', () {
    test('a mixed-difficulty session of 10 is unique and valid', () {
      final questions = NumberNebulaQuestionGenerator.generate(
          skill: '', difficulty: 3, count: 10);

      expect(questions.length, 10);
      final ids = <String>{};
      final texts = <String>{};
      for (final q in questions) {
        expect(ids.add(q.id), isTrue, reason: 'duplicate id in-session: ${q.id}');
        expect(texts.add(q.question), isTrue,
            reason: 'duplicate text in-session: ${q.question}');
        expect(q.options.length, greaterThanOrEqualTo(2));
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1),
            reason: '${q.id} answer key out of range');
      }
    });
  });

  group('Adventure Arena — motor config tiers', () {
    test('easy/mid/hard configs stay inside their calibrated brackets', () {
      for (final tier in [1, 3, 5]) {
        final config = AdventureArenaGenerator.generate(
            skill: 'skill_motor', difficulty: tier);
        expect(config.rounds, greaterThanOrEqualTo(1));
        expect(config.targetCount, greaterThanOrEqualTo(1));
        expect(config.roundDuration, greaterThan(Duration.zero));
        expect(config.skillId, 'skill_motor');
      }

      // Difficulty brackets by construction: every easy config is <= 0.9x,
      // every hard config is >= 1.8x — regressions to those brackets fail.
      final easy = AdventureArenaGenerator.generate(
          skill: 's', difficulty: 1);
      final hard = AdventureArenaGenerator.generate(
          skill: 's', difficulty: 5);
      expect(easy.difficultyMultiplier, lessThanOrEqualTo(0.9));
      expect(hard.difficultyMultiplier, greaterThanOrEqualTo(1.8));
    });
  });
}
