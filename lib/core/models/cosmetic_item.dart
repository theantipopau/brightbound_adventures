import 'package:equatable/equatable.dart';

enum CosmeticType { outfit, accessory, skin }

enum UnlockType { zoneCompletion, levelMilestone, achievement }

class CosmeticItem extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final CosmeticType type;
  final String description;
  final UnlockType unlockType;
  final String
      unlockRequirement; // e.g., 'word-woods', 'level_5', 'achievement_100'
  final List<String> applicableCharacters; // Empty = all characters

  const CosmeticItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
    required this.description,
    required this.unlockType,
    required this.unlockRequirement,
    this.applicableCharacters = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        emoji,
        type,
        description,
        unlockType,
        unlockRequirement,
        applicableCharacters,
      ];
}

class CosmeticManager {
  static final List<CosmeticItem> availableItems = [
    // Zone-based outfit unlocks
    CosmeticItem(
      id: 'outfit_scholar',
      name: 'Scholar Outfit',
      emoji: '🎓',
      type: CosmeticType.outfit,
      description: 'Unlock by completing Word Woods!',
      unlockType: UnlockType.zoneCompletion,
      unlockRequirement: 'word-woods',
    ),
    CosmeticItem(
      id: 'outfit_astronomer',
      name: 'Astronomer Outfit',
      emoji: '🔭',
      type: CosmeticType.outfit,
      description: 'Unlock by completing Number Nebula!',
      unlockType: UnlockType.zoneCompletion,
      unlockRequirement: 'number-nebula',
    ),
    CosmeticItem(
      id: 'outfit_storyteller',
      name: 'Storyteller Outfit',
      emoji: '📚',
      type: CosmeticType.outfit,
      description: 'Unlock by completing Story Springs!',
      unlockType: UnlockType.zoneCompletion,
      unlockRequirement: 'story-springs',
    ),
    CosmeticItem(
      id: 'outfit_adventurer',
      name: 'Adventure Outfit',
      emoji: '🧗',
      type: CosmeticType.outfit,
      description: 'Unlock by completing Logic Peaks!',
      unlockType: UnlockType.zoneCompletion,
      unlockRequirement: 'logic-peaks',
    ),

    // Level-based accessories
    CosmeticItem(
      id: 'accessory_crown',
      name: 'Golden Crown',
      emoji: '👑',
      type: CosmeticType.accessory,
      description: 'Unlock by reaching Level 5!',
      unlockType: UnlockType.levelMilestone,
      unlockRequirement: 'level_5',
    ),
    CosmeticItem(
      id: 'accessory_medal',
      name: 'Medal of Honor',
      emoji: '🏅',
      type: CosmeticType.accessory,
      description: 'Unlock by reaching Level 10!',
      unlockType: UnlockType.levelMilestone,
      unlockRequirement: 'level_10',
    ),
    CosmeticItem(
      id: 'accessory_wings',
      name: 'Wings of Learning',
      emoji: '🪶',
      type: CosmeticType.accessory,
      description: 'Unlock by reaching Level 15!',
      unlockType: UnlockType.levelMilestone,
      unlockRequirement: 'level_15',
    ),

    // Skins (colors)
    CosmeticItem(
      id: 'skin_golden',
      name: 'Golden Glow',
      emoji: '✨',
      type: CosmeticType.skin,
      description: 'Unlock by completing 3 zones!',
      unlockType: UnlockType.zoneCompletion,
      unlockRequirement: 'zones_3',
    ),
    CosmeticItem(
      id: 'skin_rainbow',
      name: 'Rainbow Shimmer',
      emoji: '🌈',
      type: CosmeticType.skin,
      description: 'Unlock by reaching Level 20!',
      unlockType: UnlockType.levelMilestone,
      unlockRequirement: 'level_20',
    ),
  ];

  /// Check if cosmetic should be unlocked based on player progress
  static bool shouldUnlock(
    CosmeticItem item, {
    required List<String> completedZones,
    required int playerLevel,
    List<String> unlockedAchievements = const [],
  }) {
    switch (item.unlockType) {
      case UnlockType.zoneCompletion:
        if (item.unlockRequirement == 'zones_3') {
          return completedZones.length >= 3;
        }
        return completedZones.contains(item.unlockRequirement);

      case UnlockType.levelMilestone:
        final levelStr = item.unlockRequirement.split('_').last;
        final requiredLevel = int.tryParse(levelStr) ?? 0;
        return playerLevel >= requiredLevel;

      case UnlockType.achievement:
        // Supports exact ids like `achievement_100` or raw achievement ids.
        final requirement = item.unlockRequirement;
        if (unlockedAchievements.contains(requirement)) {
          return true;
        }
        if (requirement.startsWith('achievement_')) {
          final normalized = requirement.replaceFirst('achievement_', '');
          return unlockedAchievements.contains(normalized);
        }
        return false;
    }
  }

  /// Get all unlocked cosmetics for player
  static List<CosmeticItem> getUnlockedCosmetics({
    required List<String> completedZones,
    required int playerLevel,
    List<String> unlockedAchievements = const [],
  }) {
    return availableItems.where((item) {
      return shouldUnlock(
        item,
        completedZones: completedZones,
        playerLevel: playerLevel,
        unlockedAchievements: unlockedAchievements,
      );
    }).toList();
  }

  /// Get all items by type
  static List<CosmeticItem> getByType(CosmeticType type) {
    return availableItems.where((item) => item.type == type).toList();
  }
}
