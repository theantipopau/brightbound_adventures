import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/core/utils/constants.dart';

class AvatarProvider extends ChangeNotifier {
  Avatar? _avatar;
  late LocalStorageService _storageService;

  Avatar? get avatar => _avatar;
  bool get hasAvatar => _avatar != null;

  void setStorageService(LocalStorageService storageService) {
    _storageService = storageService;
  }

  Future<void> loadAvatar() async {
    _avatar = await _storageService.getAvatar();
    notifyListeners();
  }

  Future<void> createAvatar({
    required String name,
    required String baseCharacter,
    required String skinColor,
  }) async {
    debugPrint('AvatarProvider.createAvatar called');
    
    _avatar = Avatar(
      id: 'avatar_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      baseCharacter: baseCharacter,
      skinColor: skinColor,
      outfitId: 'outfit_adventure', // Default outfit
      unlockedOutfits: const ['outfit_adventure'],
      unlockedAccessories: const ['acc_bow'],
      experiencePoints: 0,
      level: 1,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    debugPrint('Avatar object created: ${_avatar!.name}');
    
    await _storageService.saveAvatar(_avatar!);
    
    debugPrint('Avatar saved to storage');
    
    notifyListeners();
    
    debugPrint('Listeners notified');
  }

  Future<void> updateAvatarName(String newName) async {
    if (_avatar == null) return;
    
    _avatar = _avatar!.copyWith(
      name: newName,
      lastModified: DateTime.now(),
    );

    await _storageService.saveAvatar(_avatar!);
    notifyListeners();
  }

  Future<void> changeOutfit(String outfitId) async {
    if (_avatar == null) return;
    
    _avatar = _avatar!.copyWith(
      outfitId: outfitId,
      lastModified: DateTime.now(),
    );

    await _storageService.saveAvatar(_avatar!);
    notifyListeners();
  }

  Future<void> unlockOutfit(String outfitId) async {
    if (_avatar == null) return;

    final updated = _avatar!.unlockedOutfits.toList();
    if (!updated.contains(outfitId)) {
      updated.add(outfitId);
    }

    _avatar = _avatar!.copyWith(
      unlockedOutfits: updated,
      lastModified: DateTime.now(),
    );

    await _storageService.saveAvatar(_avatar!);
    notifyListeners();
  }

  Future<void> unlockAccessory(String accessoryId) async {
    if (_avatar == null) return;

    final updated = _avatar!.unlockedAccessories.toList();
    if (!updated.contains(accessoryId)) {
      updated.add(accessoryId);
    }

    _avatar = _avatar!.copyWith(
      unlockedAccessories: updated,
      lastModified: DateTime.now(),
    );

    await _storageService.saveAvatar(_avatar!);
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

    _avatar = _avatar!.copyWith(
      experiencePoints: newXP,
      level: newLevel,
      lastModified: DateTime.now(),
    );

    await _storageService.saveAvatar(_avatar!);
    notifyListeners();
  }

  void resetAvatar() {
    _avatar = null;
    notifyListeners();
  }
}
