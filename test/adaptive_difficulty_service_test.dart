import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/core/services/adaptive_difficulty_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdaptiveDifficultyService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('starts new skills at a balanced difficulty', () async {
      final service = AdaptiveDifficultyService();
      await service.initialize();

      expect(service.getDifficultyForSkill('skill_addition'), 3);
      expect(service.getDifficultyMessage('skill_addition'),
          'Starting at level 3');
    });

    test('raises difficulty after a strong recent run', () async {
      final service = AdaptiveDifficultyService();
      await service.initialize();

      for (var i = 0; i < 4; i++) {
        await service.recordAnswer(skillId: 'skill_addition', wasCorrect: true);
      }

      expect(service.getDifficultyForSkill('skill_addition'), 4);
    });

    test('lowers difficulty after sustained struggle', () async {
      final service = AdaptiveDifficultyService();
      await service.initialize();

      await service.recordAnswer(skillId: 'skill_addition', wasCorrect: true);
      for (var i = 0; i < 3; i++) {
        await service.recordAnswer(
            skillId: 'skill_addition', wasCorrect: false);
      }

      expect(service.getDifficultyForSkill('skill_addition'), 2);
    });
  });
}
