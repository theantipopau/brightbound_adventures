import 'package:flutter/foundation.dart';
import 'package:brightbound_adventures/core/models/index.dart';

/// Service to manage cosmetic unlocking based on player progress
class CosmeticUnlockService extends ChangeNotifier {
  static final CosmeticUnlockService _instance =
      CosmeticUnlockService._internal();

  factory CosmeticUnlockService() => _instance;
  CosmeticUnlockService._internal();

  late final List<String> _completedZones;
  int _playerLevel = 1;
  List<String> _unlockedCosmeticIds = [];

  List<String> get completedZones => _completedZones;
  int get playerLevel => _playerLevel;
  List<String> get unlockedCosmeticIds => _unlockedCosmeticIds;

  /// Initialize with player avatar data
  void initialize({
    required int level,
    required List<String> unlockedOutfits,
    required List<String> unlockedAccessories,
  }) {
    _playerLevel = level;
    _unlockedCosmeticIds = [...unlockedOutfits, ...unlockedAccessories];
    _checkAllUnlocks();
  }

  /// Mark a zone as completed and check for new unlocks
  Future<void> completeZone(String zoneId) async {
    if (!_completedZones.contains(zoneId)) {
      _completedZones.add(zoneId);
      _checkAllUnlocks();
    }
  }

  /// Update player level and check for unlocks
  Future<void> updateLevel(int newLevel) async {
    if (newLevel > _playerLevel) {
      _playerLevel = newLevel;
      _checkAllUnlocks();
    }
  }

  /// Check all cosmetics and unlock any that should be available
  void _checkAllUnlocks() {
    final previousCount = _unlockedCosmeticIds.length;

    for (final item in CosmeticManager.availableItems) {
      if (!_unlockedCosmeticIds.contains(item.id)) {
        if (CosmeticManager.shouldUnlock(
          item,
          completedZones: _completedZones,
          playerLevel: _playerLevel,
        )) {
          _unlockedCosmeticIds.add(item.id);
        }
      }
    }

    // Only notify if something changed
    if (_unlockedCosmeticIds.length > previousCount) {
      notifyListeners();
    }
  }

  /// Get newly unlocked cosmetics since last check
  List<CosmeticItem> getNewlyUnlocked() {
    return CosmeticManager.availableItems
        .where((item) => _unlockedCosmeticIds.contains(item.id))
        .toList();
  }

  /// Get list of cosmetics that can be unlocked next
  List<CosmeticItem> getNextUnlockables() {
    return CosmeticManager.availableItems
        .where((item) =>
            !_unlockedCosmeticIds.contains(item.id) &&
            _canUnlockSoon(item))
        .toList();
  }

  /// Check if a cosmetic is close to being unlockable
  bool _canUnlockSoon(CosmeticItem item) {
    switch (item.unlockType) {
      case UnlockType.zoneCompletion:
        // Show if < 2 zones away
        return _completedZones.isNotEmpty;

      case UnlockType.levelMilestone:
        final levelStr = item.unlockRequirement.split('_').last;
        final requiredLevel = int.tryParse(levelStr) ?? 0;
        return _playerLevel >= (requiredLevel - 3);

      case UnlockType.achievement:
        return false;
    }
  }

  /// Get unlock requirement description for UI
  String getUnlockDescription(CosmeticItem item) {
    switch (item.unlockType) {
      case UnlockType.zoneCompletion:
        if (item.unlockRequirement == 'zones_3') {
          return 'Complete 3 zones (${_completedZones.length}/3)';
        }
        return 'Complete ${item.unlockRequirement.replaceAll('-', ' ')}';

      case UnlockType.levelMilestone:
        final levelStr = item.unlockRequirement.split('_').last;
        return 'Reach Level $levelStr (Level $_playerLevel)';

      case UnlockType.achievement:
        return 'Unlock achievement';
    }
  }

  /// Get progress percentage for unlock
  double getUnlockProgress(CosmeticItem item) {
    switch (item.unlockType) {
      case UnlockType.zoneCompletion:
        if (item.unlockRequirement == 'zones_3') {
          return (_completedZones.length / 3).clamp(0.0, 1.0);
        }
        return _completedZones.contains(item.unlockRequirement) ? 1.0 : 0.0;

      case UnlockType.levelMilestone:
        final levelStr = item.unlockRequirement.split('_').last;
        final requiredLevel = int.tryParse(levelStr) ?? 0;
        return (_playerLevel / requiredLevel).clamp(0.0, 1.0);

      case UnlockType.achievement:
        return 0.0;
    }
  }
}
