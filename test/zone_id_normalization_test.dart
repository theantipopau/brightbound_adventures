import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/core/models/skill_database.dart';
import 'package:brightbound_adventures/core/services/skill_provider.dart';

void main() {
  group('Zone ID normalization', () {
    test('SkillProvider accepts route and curriculum ID formats', () {
      expect(SkillProvider.normalizeZoneId('number-nebula'), 'number_nebula');
      expect(SkillProvider.normalizeZoneId('number_nebula'), 'number_nebula');
      expect(SkillProvider.normalizeZoneId('Number Nebula'), 'number_nebula');
      expect(
          SkillProvider.normalizeZoneId('🌌 Number Nebula'), 'number_nebula');
    });

    test('SkillDatabase returns the same zone skills for kebab and snake IDs',
        () {
      final snakeIds = SkillDatabase.getZoneSkills('science_explorers')
          .map((skill) => skill.id)
          .toList();
      final kebabIds = SkillDatabase.getZoneSkills('science-explorers')
          .map((skill) => skill.id)
          .toList();

      expect(kebabIds, snakeIds);
      expect(kebabIds, isNotEmpty);
    });

    test('Math Facts remains a focused subset of Number Nebula', () {
      final numberIds = SkillDatabase.getZoneSkills('number_nebula')
          .map((skill) => skill.id)
          .toSet();
      final mathFactIds = SkillDatabase.getZoneSkills('math_facts')
          .map((skill) => skill.id)
          .toSet();

      expect(mathFactIds, isNotEmpty);
      expect(numberIds.containsAll(mathFactIds), isTrue);
      expect(mathFactIds.length, lessThan(numberIds.length));
    });
  });
}
