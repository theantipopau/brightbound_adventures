import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:brightbound_adventures/core/models/index.dart';

class LocalStorageService {
  static const String skillsBoxName = 'skills';
  static const String avatarBoxName = 'avatar';
  static const String progressBoxName = 'game_progress';
  static const String settingsBoxName = 'settings';

  Future<void> initializeHive() async {
    await Hive.initFlutter();
    
    // Open boxes
    await Hive.openBox(skillsBoxName);
    await Hive.openBox(avatarBoxName);
    await Hive.openBox(progressBoxName);
    await Hive.openBox(settingsBoxName);
  }

  // Skills operations
  Future<void> saveSkill(Skill skill) async {
    final box = Hive.box(skillsBoxName);
    await box.put(skill.id, _skillToMap(skill));
  }

  Future<Skill?> getSkill(String id) async {
    final box = Hive.box(skillsBoxName);
    final data = box.get(id);
    if (data == null) return null;
    return _mapToSkill(data);
  }

  Future<List<Skill>> getAllSkills() async {
    final box = Hive.box(skillsBoxName);
    return box.values.map((data) => _mapToSkill(data)).toList();
  }

  Future<void> deleteSkill(String id) async {
    final box = Hive.box(skillsBoxName);
    await box.delete(id);
  }

  // Avatar operations
  Future<void> saveAvatar(Avatar avatar) async {
    debugPrint('LocalStorageService.saveAvatar called');
    final box = Hive.box(avatarBoxName);
    final map = _avatarToMap(avatar);
    debugPrint('Avatar map: $map');
    await box.put('current', map);
    debugPrint('Avatar saved to Hive');
  }

  Future<Avatar?> getAvatar() async {
    debugPrint('LocalStorageService.getAvatar called');
    final box = Hive.box(avatarBoxName);
    final data = box.get('current');
    debugPrint('Avatar data from Hive: $data');
    if (data == null) return null;
    return _mapToAvatar(data);
  }

  // Game progress operations
  Future<void> saveGameProgress(GameProgress progress) async {
    final box = Hive.box(progressBoxName);
    await box.put(progress.id, _progressToMap(progress));
  }

  Future<GameProgress?> getGameProgress(String id) async {
    final box = Hive.box(progressBoxName);
    final data = box.get(id);
    if (data == null) return null;
    return _mapToProgress(data);
  }

  Future<List<GameProgress>> getAllGameProgress() async {
    final box = Hive.box(progressBoxName);
    return box.values.map((data) => _mapToProgress(data)).toList();
  }

  Future<void> deleteGameProgress(String id) async {
    final box = Hive.box(progressBoxName);
    await box.delete(id);
  }

  // Settings operations
  Future<void> saveSetting(String key, dynamic value) async {
    final box = Hive.box(settingsBoxName);
    await box.put(key, value);
  }

  Future<dynamic> getSetting(String key) async {
    final box = Hive.box(settingsBoxName);
    return box.get(key);
  }

  Future<void> deleteSetting(String key) async {
    final box = Hive.box(settingsBoxName);
    await box.delete(key);
  }

  // Helper methods for serialization
  Map<String, dynamic> _skillToMap(Skill skill) => {
        'id': skill.id,
        'name': skill.name,
        'description': skill.description,
        'strand': skill.strand,
        'naplanArea': skill.naplanArea,
        'state': skill.state.toString(),
        'accuracy': skill.accuracy,
        'attempts': skill.attempts,
        'hintsUsed': skill.hintsUsed,
        'lastPracticed': skill.lastPracticed.toIso8601String(),
        'difficulty': skill.difficulty,
      };

  Skill _mapToSkill(Map<dynamic, dynamic> data) => Skill(
        id: data['id'],
        name: data['name'],
        description: data['description'],
        strand: data['strand'],
        naplanArea: data['naplanArea'],
        state: SkillState.values.firstWhere(
          (e) => e.toString() == data['state'],
          orElse: () => SkillState.locked,
        ),
        accuracy: (data['accuracy'] as num).toDouble(),
        attempts: data['attempts'] ?? 0,
        hintsUsed: data['hintsUsed'] ?? 0,
        lastPracticed: DateTime.parse(data['lastPracticed']),
        difficulty: data['difficulty'] ?? 1,
      );

  Map<String, dynamic> _avatarToMap(Avatar avatar) => {
        'id': avatar.id,
        'name': avatar.name,
        'baseCharacter': avatar.baseCharacter,
        'skinColor': avatar.skinColor,
        'outfitId': avatar.outfitId,
        'unlockedOutfits': avatar.unlockedOutfits,
        'unlockedAccessories': avatar.unlockedAccessories,
        'experiencePoints': avatar.experiencePoints,
        'level': avatar.level,
        'createdAt': avatar.createdAt.toIso8601String(),
        'lastModified': avatar.lastModified.toIso8601String(),
      };

  Avatar _mapToAvatar(Map<dynamic, dynamic> data) => Avatar(
        id: data['id'],
        name: data['name'],
        baseCharacter: data['baseCharacter'],
        skinColor: data['skinColor'],
        outfitId: data['outfitId'],
        unlockedOutfits: List<String>.from(data['unlockedOutfits'] ?? []),
        unlockedAccessories: List<String>.from(data['unlockedAccessories'] ?? []),
        experiencePoints: data['experiencePoints'] ?? 0,
        level: data['level'] ?? 1,
        createdAt: DateTime.parse(data['createdAt']),
        lastModified: DateTime.parse(data['lastModified']),
      );

  Map<String, dynamic> _progressToMap(GameProgress progress) => {
        'id': progress.id,
        'zoneId': progress.zoneId,
        'gameId': progress.gameId,
        'sessionsCompleted': progress.sessionsCompleted,
        'totalScore': progress.totalScore,
        'averageAccuracy': progress.averageAccuracy,
        'lastPlayedAt': progress.lastPlayedAt.toIso8601String(),
      };

  GameProgress _mapToProgress(Map<dynamic, dynamic> data) => GameProgress(
        id: data['id'],
        zoneId: data['zoneId'],
        gameId: data['gameId'],
        sessionsCompleted: data['sessionsCompleted'] ?? 0,
        totalScore: data['totalScore'] ?? 0,
        averageAccuracy: (data['averageAccuracy'] as num).toDouble(),
        lastPlayedAt: DateTime.parse(data['lastPlayedAt']),
      );
}
