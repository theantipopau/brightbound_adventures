import 'package:equatable/equatable.dart';

class Avatar extends Equatable {
  final String id;
  final String name;
  final String baseCharacter; // 'bear', 'fox', 'rabbit', etc.
  final String skinColor;
  final String outfitId;
  final List<String> unlockedOutfits;
  final List<String> unlockedAccessories;
  final int experiencePoints;
  final int level;
  final DateTime createdAt;
  final DateTime lastModified;

  const Avatar({
    required this.id,
    required this.name,
    required this.baseCharacter,
    required this.skinColor,
    required this.outfitId,
    this.unlockedOutfits = const [],
    this.unlockedAccessories = const [],
    this.experiencePoints = 0,
    this.level = 1,
    required this.createdAt,
    required this.lastModified,
  });

  int get nextLevelXP => (level * 100);

  Avatar copyWith({
    String? id,
    String? name,
    String? baseCharacter,
    String? skinColor,
    String? outfitId,
    List<String>? unlockedOutfits,
    List<String>? unlockedAccessories,
    int? experiencePoints,
    int? level,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    return Avatar(
      id: id ?? this.id,
      name: name ?? this.name,
      baseCharacter: baseCharacter ?? this.baseCharacter,
      skinColor: skinColor ?? this.skinColor,
      outfitId: outfitId ?? this.outfitId,
      unlockedOutfits: unlockedOutfits ?? this.unlockedOutfits,
      unlockedAccessories: unlockedAccessories ?? this.unlockedAccessories,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        baseCharacter,
        skinColor,
        outfitId,
        unlockedOutfits,
        unlockedAccessories,
        experiencePoints,
        level,
        createdAt,
        lastModified,
      ];
}
