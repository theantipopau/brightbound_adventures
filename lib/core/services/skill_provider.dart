import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/local_storage_service.dart';
import 'package:brightbound_adventures/core/services/learning_engine.dart';
import 'package:brightbound_adventures/core/utils/constants.dart';

class SkillProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  
  final Map<String, Skill> _skills = {};
  bool _isInitialized = false;

  SkillProvider(this._storageService);

  bool get isInitialized => _isInitialized;
  
  Map<String, Skill> get skills => _skills;

  /// Initialize skills from storage or create new ones
  Future<void> initializeSkills() async {
    // Try to load existing skills
    try {
      final existingSkills = await _storageService.getAllSkills();
      if (existingSkills.isNotEmpty) {
        for (final skill in existingSkills) {
          _skills[skill.id] = skill;
        }
      } else {
        // First time - seed with all skills from database
        await _seedSkillsFromDatabase();
      }
    } catch (e) {
      // Error loading - seed with defaults
      await _seedSkillsFromDatabase();
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Seed skills from the curriculum database
  Future<void> _seedSkillsFromDatabase() async {
    final allSkills = SkillDatabase.getAllSkills();
    for (final skill in allSkills) {
      _skills[skill.id] = skill;
      await _storageService.saveSkill(skill);
    }
  }

  /// Get skills for a specific zone
  List<Skill> getZoneSkills(String zoneId) {
    return _skills.values
        .where((skill) {
          if (zoneId == 'word_woods') {
            return skill.strand == Constants.strandLiteracy ||
                skill.strand == Constants.strandCommunication;
          } else if (zoneId == 'number_nebula') {
            return skill.strand == Constants.strandNumeracy;
          } else if (zoneId == 'story_springs') {
            return skill.strand == Constants.strandCommunication;
          } else if (zoneId == 'puzzle_peaks') {
            return skill.strand == Constants.strandLogic;
          } else if (zoneId == 'adventure_arena') {
            return skill.strand == Constants.strandMotor;
          }
          return false;
        })
        .toList();
  }

  /// Get all skills for a strand
  List<Skill> getSkillsByStrand(String strand) {
    return _skills.values.where((skill) => skill.strand == strand).toList();
  }

  /// Get NAPLAN high-risk skills
  List<Skill> getNaplanHighRiskSkills() {
    return _skills.values.where((skill) => skill.naplanArea != null).toList();
  }

  /// Get single skill by ID
  Skill? getSkill(String skillId) {
    return _skills[skillId];
  }

  /// Update skill progress after practice session
  Future<void> updateSkillProgress({
    required String skillId,
    required double sessionAccuracy,
    required int sessionHints,
  }) async {
    final skill = _skills[skillId];
    if (skill == null) return;

    final updated = ProgressionEngine.updateSkillProgress(
      skill: skill,
      sessionAccuracy: sessionAccuracy,
      sessionHints: sessionHints,
    );

    _skills[skillId] = updated;
    await _storageService.saveSkill(updated);
    notifyListeners();
  }

  /// Get skills available for practice (not locked/mastered)
  List<Skill> getAvailableSkills() {
    return ProgressionEngine.getAvailableSkills(_skills.values.toList());
  }

  /// Get recommended next skill to practice
  Skill? getNextSkillToPractice() {
    final available = getAvailableSkills();
    return ProgressionEngine.selectNextSkill(available);
  }

  /// Get skill progression stats
  SkillProgressionStats getProgressionStats() {
    final allSkills = _skills.values.toList();
    
    return SkillProgressionStats(
      totalSkills: allSkills.length,
      locked: allSkills.where((s) => s.state == SkillState.locked).length,
      introduced: allSkills.where((s) => s.state == SkillState.introduced).length,
      practising: allSkills.where((s) => s.state == SkillState.practising).length,
      mastered: allSkills.where((s) => s.state == SkillState.mastered).length,
      averageAccuracy: allSkills.isNotEmpty
          ? allSkills.map((s) => s.accuracy).reduce((a, b) => a + b) / allSkills.length
          : 0.0,
    );
  }

  /// Get zone-specific stats
  ZoneStats getZoneStats(String zoneId) {
    final zoneSkills = getZoneSkills(zoneId);
    
    return ZoneStats(
      zoneId: zoneId,
      totalSkills: zoneSkills.length,
      masteredSkills: zoneSkills.where((s) => s.state == SkillState.mastered).length,
      averageAccuracy: zoneSkills.isNotEmpty
          ? zoneSkills.map((s) => s.accuracy).reduce((a, b) => a + b) / zoneSkills.length
          : 0.0,
      nextSkill: ProgressionEngine.selectNextSkill(
        ProgressionEngine.getAvailableSkills(zoneSkills),
      ),
    );
  }

  /// Reset all skills (for testing)
  Future<void> resetAllSkills() async {
    for (final skill in _skills.values) {
      final reset = skill.copyWith(
        state: SkillState.locked,
        accuracy: 0.0,
        attempts: 0,
        hintsUsed: 0,
        difficulty: 1,
      );
      _skills[skill.id] = reset;
      await _storageService.saveSkill(reset);
    }
    notifyListeners();
  }
}

/// Statistics about overall skill progression
class SkillProgressionStats {
  final int totalSkills;
  final int locked;
  final int introduced;
  final int practising;
  final int mastered;
  final double averageAccuracy;

  SkillProgressionStats({
    required this.totalSkills,
    required this.locked,
    required this.introduced,
    required this.practising,
    required this.mastered,
    required this.averageAccuracy,
  });

  int get unlockedSkills => introduced + practising + mastered;
  
  double get masteryPercentage =>
      totalSkills > 0 ? (mastered / totalSkills) * 100 : 0.0;
  
  double get progressPercentage =>
      totalSkills > 0 ? (unlockedSkills / totalSkills) * 100 : 0.0;
}

/// Statistics for a specific zone
class ZoneStats {
  final String zoneId;
  final int totalSkills;
  final int masteredSkills;
  final double averageAccuracy;
  final Skill? nextSkill;

  ZoneStats({
    required this.zoneId,
    required this.totalSkills,
    required this.masteredSkills,
    required this.averageAccuracy,
    this.nextSkill,
  });

  double get completionPercentage =>
      totalSkills > 0 ? (masteredSkills / totalSkills) * 100 : 0.0;
}
