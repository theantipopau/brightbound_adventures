import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/core/utils/constants.dart';

/// Emotional state for avatar reactions during gameplay.
enum AvatarEmotion {
  neutral,
  happy,
  proud,
  surprised,
  thinking,
  sad,
}

class AvatarProvider extends ChangeNotifier {
  Avatar? _avatar;
  late LocalStorageService _storageService;

  AvatarEmotion _emotion = AvatarEmotion.neutral;

  AvatarEmotion get emotion => _emotion;

  /// Set a transient emotion — automatically resets to neutral after [resetAfter].
  void setEmotion(AvatarEmotion emotion,
      {Duration resetAfter = const Duration(seconds: 2)}) {
    _emotion = emotion;
    notifyListeners();
    Future.delayed(resetAfter, () {
      if (_emotion == emotion) {
        _emotion = AvatarEmotion.neutral;
        notifyListeners();
      }
    });
  }

  /// Emoji overlay for the current emotion state.
  String get emotionEmoji {
    switch (_emotion) {
      case AvatarEmotion.happy:
        return '😄';
      case AvatarEmotion.proud:
        return '🤩';
      case AvatarEmotion.surprised:
        return '😲';
      case AvatarEmotion.thinking:
        return '🤔';
      case AvatarEmotion.sad:
        return '😟';
      case AvatarEmotion.neutral:
        return '';
    }
  }

  Avatar? get avatar => _avatar;
  bool get hasAvatar => _avatar != null;

  void setStorageService(LocalStorageService storageService) {
    _storageService = storageService;
  }

  Future<void> loadAvatar() async {
    _avatar = await _storageService.getAvatar();
    notifyListeners();
  }

  // Every mutator below builds the new Avatar value locally and only
  // assigns it to `_avatar` (and notifies) *after* `saveAvatar` succeeds.
  // Previously `_avatar` was mutated first and persisted second: if
  // `saveAvatar` threw (storage error, disk full), the in-memory avatar
  // had already "succeeded" even though nothing was written — the app
  // would behave as if the change worked until the next restart silently
  // reverted it. Building-then-saving-then-committing means a failed save
  // leaves `_avatar` at its last known-persisted value, so in-memory state
  // can never drift ahead of what's actually on disk. Callers still see
  // the exception (nothing here swallows it) and can react to it.

  Future<void> createAvatar({
    required String name,
    required String baseCharacter,
    required String skinColor,
    String outfitId = 'outfit_adventure',
    List<String> unlockedOutfits = const [
      'outfit_adventure',
      'outfit_sky_scout',
      'outfit_garden_hero',
    ],
    List<String> unlockedAccessories = const ['acc_bow'],
  }) async {
    final created = Avatar(
      id: 'avatar_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      baseCharacter: baseCharacter,
      skinColor: skinColor,
      outfitId: outfitId,
      unlockedOutfits: unlockedOutfits,
      unlockedAccessories: unlockedAccessories,
      experiencePoints: 0,
      level: 1,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    await _storageService.saveAvatar(created);

    _avatar = created;
    notifyListeners();
  }

  Future<void> updateAvatarName(String newName) async {
    if (_avatar == null) return;

    final updated = _avatar!.copyWith(
      name: newName,
      lastModified: DateTime.now(),
    );

    await _storageService.saveAvatar(updated);

    _avatar = updated;
    notifyListeners();
  }

  Future<void> changeOutfit(String outfitId) async {
    if (_avatar == null) return;

    final updated = _avatar!.copyWith(
      outfitId: outfitId,
      lastModified: DateTime.now(),
    );

    await _storageService.saveAvatar(updated);

    _avatar = updated;
    notifyListeners();
  }

  Future<void> unlockOutfit(String outfitId) async {
    if (_avatar == null) return;

    final unlockedOutfits = _avatar!.unlockedOutfits.toList();
    if (!unlockedOutfits.contains(outfitId)) {
      unlockedOutfits.add(outfitId);
    }

    final updated = _avatar!.copyWith(
      unlockedOutfits: unlockedOutfits,
      lastModified: DateTime.now(),
    );

    await _storageService.saveAvatar(updated);

    _avatar = updated;
    notifyListeners();
  }

  Future<void> unlockAccessory(String accessoryId) async {
    if (_avatar == null) return;

    final unlockedAccessories = _avatar!.unlockedAccessories.toList();
    if (!unlockedAccessories.contains(accessoryId)) {
      unlockedAccessories.add(accessoryId);
    }

    final updated = _avatar!.copyWith(
      unlockedAccessories: unlockedAccessories,
      lastModified: DateTime.now(),
    );

    await _storageService.saveAvatar(updated);

    _avatar = updated;
    notifyListeners();
  }

  Future<void> addExperience(int xp) async {
    if (_avatar == null) return;

    var newXP = _avatar!.experiencePoints + xp;
    var newLevel = _avatar!.level;

    while (newXP >= Constants.xpPerLevel) {
      newXP = newXP - Constants.xpPerLevel;
      if (newLevel < Constants.maxLevel) {
        newLevel++;
      }
    }

    final updated = _avatar!.copyWith(
      experiencePoints: newXP,
      level: newLevel,
      lastModified: DateTime.now(),
    );

    await _storageService.saveAvatar(updated);

    _avatar = updated;
    notifyListeners();
  }

  void resetAvatar() {
    _avatar = null;
    notifyListeners();
  }
}
