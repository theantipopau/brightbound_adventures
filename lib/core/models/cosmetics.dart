import 'package:equatable/equatable.dart';

class Outfit extends Equatable {
  final String id;
  final String name;
  final String description;
  final String color; // Hex color
  final bool isUnlocked;
  final int? unlockedAtLevel; // null = default unlocked

  const Outfit({
    required this.id,
    required this.name,
    required this.description,
    required this.color,
    required this.isUnlocked,
    this.unlockedAtLevel,
  });

  Outfit copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    bool? isUnlocked,
    int? unlockedAtLevel,
  }) {
    return Outfit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAtLevel: unlockedAtLevel ?? this.unlockedAtLevel,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, description, color, isUnlocked, unlockedAtLevel];
}

class Accessory extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon; // Emoji or icon identifier
  final bool isUnlocked;
  final int? unlockedAtLevel; // null = default unlocked

  const Accessory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    this.unlockedAtLevel,
  });

  Accessory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    bool? isUnlocked,
    int? unlockedAtLevel,
  }) {
    return Accessory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAtLevel: unlockedAtLevel ?? this.unlockedAtLevel,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, description, icon, isUnlocked, unlockedAtLevel];
}

class CosmeticsLibrary {
  static final List<Outfit> defaultOutfits = [
    const Outfit(
      id: 'outfit_adventure',
      name: 'Adventure Outfit',
      description: 'Perfect for exploring',
      color: '#FF6B9D',
      isUnlocked: true,
    ),
    const Outfit(
      id: 'outfit_forest',
      name: 'Forest Outfit',
      description: 'Green and natural',
      color: '#2D5016',
      isUnlocked: false,
      unlockedAtLevel: 3,
    ),
    const Outfit(
      id: 'outfit_ocean',
      name: 'Ocean Outfit',
      description: 'Cool and calming',
      color: '#4ECDC4',
      isUnlocked: false,
      unlockedAtLevel: 5,
    ),
    const Outfit(
      id: 'outfit_sunset',
      name: 'Sunset Outfit',
      description: 'Warm and cozy',
      color: '#FFA500',
      isUnlocked: false,
      unlockedAtLevel: 7,
    ),
    const Outfit(
      id: 'outfit_royal',
      name: 'Royal Outfit',
      description: 'Elegant and regal',
      color: '#9B59B6',
      isUnlocked: false,
      unlockedAtLevel: 10,
    ),
  ];

  static final List<Accessory> defaultAccessories = [
    const Accessory(
      id: 'acc_bow',
      name: 'Bow',
      description: 'A cute bow',
      icon: '🎀',
      isUnlocked: true,
    ),
    const Accessory(
      id: 'acc_hat',
      name: 'Explorer Hat',
      description: 'For adventures',
      icon: '🎩',
      isUnlocked: false,
      unlockedAtLevel: 2,
    ),
    const Accessory(
      id: 'acc_glasses',
      name: 'Smart Glasses',
      description: 'For learning',
      icon: '👓',
      isUnlocked: false,
      unlockedAtLevel: 4,
    ),
    const Accessory(
      id: 'acc_crown',
      name: 'Crown',
      description: 'Rule the world',
      icon: '👑',
      isUnlocked: false,
      unlockedAtLevel: 8,
    ),
    const Accessory(
      id: 'acc_star',
      name: 'Star',
      description: 'You\'re a star',
      icon: '⭐',
      isUnlocked: false,
      unlockedAtLevel: 6,
    ),
  ];

  static final Map<String, List<String>> characterSkinColors = {
    'bear': ['#D4A574', '#8B6F47', '#E8C4A0', '#A0826D'],
    'fox': ['#FF6B35', '#C85A23', '#FF8A50', '#D9553E'],
    'rabbit': ['#FFB6C1', '#FFC0CB', '#F0F8FF', '#E6F3FF'],
    'deer': ['#8B5A3C', '#A0682A', '#B8860B', '#CD853F'],
    'cat': ['#FF8C94', '#FFA07A', '#FFD700', '#D3D3D3'],
    'penguin': ['#4A90E2', '#87CEEB', '#000000', '#708090'],
    'koala': ['#9E9E9E', '#BDBDBD', '#757575', '#607D8B'],
    'panda': ['#000000', '#333333', '#FFFFFF', '#F5F5F5'],
  };

  static List<String> getSkinColorsForCharacter(String character) {
    return characterSkinColors[character] ?? characterSkinColors['bear']!;
  }
}
