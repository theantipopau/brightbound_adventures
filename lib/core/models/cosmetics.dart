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
    'bear': ['#D4A574', '#8B6F47', '#E8C4A0', '#A0826D', '#C68A58', '#5C4033'],
    'fox': ['#FF6B35', '#C85A23', '#FF8A50', '#D9553E', '#F6A04D', '#8B3E2F'],
    'rabbit': ['#FFB6C1', '#FFC0CB', '#F0F8FF', '#E6F3FF', '#DDA0DD', '#F5E6FF'],
    'deer': ['#8B5A3C', '#A0682A', '#B8860B', '#CD853F', '#D2B48C', '#6F4E37'],
    'cat': ['#FF8C94', '#FFA07A', '#FFD700', '#D3D3D3', '#C7A27C', '#8C8C8C'],
    'penguin': ['#4A90E2', '#87CEEB', '#000000', '#708090', '#B0E0E6', '#F8F8FF'],
    'koala': ['#9E9E9E', '#BDBDBD', '#757575', '#607D8B', '#CFCFCF', '#8A9AA5'],
    'panda': ['#000000', '#333333', '#FFFFFF', '#F5F5F5', '#E0E0E0', '#6D6D6D'],
    'owl': ['#8D6E63', '#A1887F', '#6D4C41', '#D7CCC8', '#BCAAA4', '#5D4037'],
    'otter': ['#B87333', '#C68642', '#D2A679', '#8C5A3C', '#E6BE8A', '#7A5230'],
    'wolf': ['#607D8B', '#90A4AE', '#B0BEC5', '#455A64', '#CFD8DC', '#78909C'],
    'tiger': ['#FF8F00', '#FFA726', '#FFB74D', '#E65100', '#F57C00', '#6D4C41'],
  };

  static List<String> getSkinColorsForCharacter(String character) {
    return characterSkinColors[character] ?? characterSkinColors['bear']!;
  }
}
