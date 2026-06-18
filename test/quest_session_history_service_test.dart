import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/core/models/quest_session_summary.dart';
import 'package:brightbound_adventures/core/services/quest_session_history_service.dart';

QuestSessionSummary _summary({
  required String id,
  required String skillId,
  required int correct,
  int total = 10,
  DateTime? endedAt,
}) {
  final end = endedAt ?? DateTime.now();
  return QuestSessionSummary(
    id: id,
    zoneId: 'number-nebula',
    skillId: skillId,
    skillName: 'Addition',
    mode: 'practice',
    startedAt: end.subtract(const Duration(minutes: 4)),
    endedAt: end,
    totalQuestions: total,
    correctAnswers: correct,
    score: correct * 100,
    hintsUsed: 1,
    difficulty: 3,
    forced: false,
    questionIds: List.generate(total, (index) => 'q_$index'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuestSessionHistoryService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('records recent sessions newest first', () async {
      final service = QuestSessionHistoryService();
      await service.initialize();

      await service.recordSession(_summary(
        id: 'older',
        skillId: 'skill_addition',
        correct: 8,
        endedAt: DateTime(2026, 6, 18, 9),
      ));
      await service.recordSession(_summary(
        id: 'newer',
        skillId: 'skill_addition',
        correct: 9,
        endedAt: DateTime(2026, 6, 18, 10),
      ));

      expect(service.sessions.map((session) => session.id), ['newer', 'older']);
      expect(service.recentSessions(skillId: 'skill_addition').length, 2);
    });

    test('detects weak skills from repeated low accuracy', () async {
      final service = QuestSessionHistoryService();
      await service.initialize();

      await service.recordSession(
          _summary(id: 'a', skillId: 'skill_fractions', correct: 5));
      await service.recordSession(
          _summary(id: 'b', skillId: 'skill_fractions', correct: 6));

      expect(service.weakSkillIds(), contains('skill_fractions'));
      expect(service.recentAccuracyForSkill('skill_fractions'), 0.55);
    });

    test('persists summaries across service instances', () async {
      final first = QuestSessionHistoryService();
      await first.initialize();
      await first.recordSession(
          _summary(id: 'persisted', skillId: 'skill_time', correct: 7));

      final second = QuestSessionHistoryService();
      await second.initialize();

      expect(second.sessions.single.id, 'persisted');
      expect(second.sessions.single.skillId, 'skill_time');
    });
  });
}
