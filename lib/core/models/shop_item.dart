import 'package:flutter/material.dart';

/// Shop item that can be purchased with stars
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final ShopCategory category;
  final int starCost;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final String? previewImage; // Optional image path

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.starCost,
    this.isPurchased = false,
    this.purchasedAt,
    this.previewImage,
  });

  ShopItem copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    ShopCategory? category,
    int? starCost,
    bool? isPurchased,
    DateTime? purchasedAt,
    String? previewImage,
  }) {
    return ShopItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      starCost: starCost ?? this.starCost,
      isPurchased: isPurchased ?? this.isPurchased,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      previewImage: previewImage ?? this.previewImage,
    );
  }
}

enum ShopCategory {
  avatarAccessories,
  backgrounds,
  effects,
  outfits,
  specialItems,
}

/// Shop item database with all available items
class ShopDatabase {
  static const List<ShopItem> allItems = [
    // Avatar Accessories
    ShopItem(
      id: 'accessory_crown',
      name: 'Royal Crown',
      description: 'Look like royalty with this shiny crown!',
      emoji: '👑',
      category: ShopCategory.avatarAccessories,
      starCost: 100,
    ),
    ShopItem(
      id: 'accessory_glasses',
      name: 'Smart Glasses',
      description: 'Look smart and stylish!',
      emoji: '👓',
      category: ShopCategory.avatarAccessories,
      starCost: 50,
    ),
    ShopItem(
      id: 'accessory_hat_wizard',
      name: 'Wizard Hat',
      description: 'Master of magical knowledge!',
      emoji: '🧙',
      category: ShopCategory.avatarAccessories,
      starCost: 150,
    ),
    ShopItem(
      id: 'accessory_hat_pirate',
      name: 'Pirate Hat',
      description: 'Adventure awaits on the high seas!',
      emoji: '🏴‍☠️',
      category: ShopCategory.avatarAccessories,
      starCost: 120,
    ),
    ShopItem(
      id: 'accessory_headphones',
      name: 'Cool Headphones',
      description: 'Listen to your favorite learning tunes!',
      emoji: '🎧',
      category: ShopCategory.avatarAccessories,
      starCost: 80,
    ),

    // Backgrounds
    ShopItem(
      id: 'bg_space',
      name: 'Space Background',
      description: 'Explore the stars and galaxies!',
      emoji: '🌌',
      category: ShopCategory.backgrounds,
      starCost: 200,
    ),
    ShopItem(
      id: 'bg_rainbow',
      name: 'Rainbow Sky',
      description: 'Bright and colorful rainbow background!',
      emoji: '🌈',
      category: ShopCategory.backgrounds,
      starCost: 150,
    ),
    ShopItem(
      id: 'bg_ocean',
      name: 'Ocean Waves',
      description: 'Relax with calming ocean waves!',
      emoji: '🌊',
      category: ShopCategory.backgrounds,
      starCost: 180,
    ),
    ShopItem(
      id: 'bg_forest',
      name: 'Magic Forest',
      description: 'Enchanted trees and glowing mushrooms!',
      emoji: '🌲',
      category: ShopCategory.backgrounds,
      starCost: 160,
    ),
    ShopItem(
      id: 'bg_castle',
      name: 'Castle Hall',
      description: 'Feel like learning in a grand castle!',
      emoji: '🏰',
      category: ShopCategory.backgrounds,
      starCost: 220,
    ),

    // Effects
    ShopItem(
      id: 'effect_sparkles',
      name: 'Sparkle Trail',
      description: 'Leave sparkles wherever you go!',
      emoji: '✨',
      category: ShopCategory.effects,
      starCost: 100,
    ),
    ShopItem(
      id: 'effect_fireworks',
      name: 'Fireworks',
      description: 'Celebrate every correct answer with fireworks!',
      emoji: '🎆',
      category: ShopCategory.effects,
      starCost: 150,
    ),
    ShopItem(
      id: 'effect_rainbow',
      name: 'Rainbow Effect',
      description: 'Add rainbow colors to everything!',
      emoji: '🌈',
      category: ShopCategory.effects,
      starCost: 130,
    ),
    ShopItem(
      id: 'effect_stars',
      name: 'Shooting Stars',
      description: 'Stars fly across your screen!',
      emoji: '⭐',
      category: ShopCategory.effects,
      starCost: 120,
    ),

    // Outfits
    ShopItem(
      id: 'outfit_superhero',
      name: 'Superhero Cape',
      description: 'Look like a learning superhero!',
      emoji: '🦸',
      category: ShopCategory.outfits,
      starCost: 250,
    ),
    ShopItem(
      id: 'outfit_scientist',
      name: 'Lab Coat',
      description: 'Dress like a scientist!',
      emoji: '🥼',
      category: ShopCategory.outfits,
      starCost: 200,
    ),
    ShopItem(
      id: 'outfit_astronaut',
      name: 'Space Suit',
      description: 'Explore space in style!',
      emoji: '👨‍🚀',
      category: ShopCategory.outfits,
      starCost: 300,
    ),
    ShopItem(
      id: 'outfit_detective',
      name: 'Detective Outfit',
      description: 'Solve mysteries with this classic look!',
      emoji: '🕵️',
      category: ShopCategory.outfits,
      starCost: 220,
    ),

    // Special Items
    ShopItem(
      id: 'special_hint_pack',
      name: 'Hint Pack (5)',
      description: 'Get 5 extra hints to use anytime!',
      emoji: '💡',
      category: ShopCategory.specialItems,
      starCost: 50,
    ),
    ShopItem(
      id: 'special_xp_boost',
      name: 'XP Boost (1 hour)',
      description: 'Double XP for one hour!',
      emoji: '⚡',
      category: ShopCategory.specialItems,
      starCost: 100,
    ),
    ShopItem(
      id: 'special_star_multiplier',
      name: 'Star Multiplier',
      description: 'Earn 1.5x stars for 3 games!',
      emoji: '🌟',
      category: ShopCategory.specialItems,
      starCost: 150,
    ),
  ];

  /// Get items by category
  static List<ShopItem> getByCategory(ShopCategory category) {
    return allItems.where((item) => item.category == category).toList();
  }

  /// Get purchased items
  static List<ShopItem> getPurchased(List<ShopItem> items) {
    return items.where((item) => item.isPurchased).toList();
  }

  /// Get available (not purchased) items
  static List<ShopItem> getAvailable(List<ShopItem> items) {
    return items.where((item) => !item.isPurchased).toList();
  }
}

/// Helper functions for shop UI
class ShopHelper {
  static String getCategoryName(ShopCategory category) {
    switch (category) {
      case ShopCategory.avatarAccessories:
        return 'Accessories';
      case ShopCategory.backgrounds:
        return 'Backgrounds';
      case ShopCategory.effects:
        return 'Effects';
      case ShopCategory.outfits:
        return 'Outfits';
      case ShopCategory.specialItems:
        return 'Special Items';
    }
  }

  static IconData getCategoryIcon(ShopCategory category) {
    switch (category) {
      case ShopCategory.avatarAccessories:
        return Icons.face;
      case ShopCategory.backgrounds:
        return Icons.wallpaper;
      case ShopCategory.effects:
        return Icons.auto_awesome;
      case ShopCategory.outfits:
        return Icons.checkroom;
      case ShopCategory.specialItems:
        return Icons.card_giftcard;
    }
  }

  static Color getCategoryColor(ShopCategory category) {
    switch (category) {
      case ShopCategory.avatarAccessories:
        return Colors.purple;
      case ShopCategory.backgrounds:
        return Colors.blue;
      case ShopCategory.effects:
        return Colors.amber;
      case ShopCategory.outfits:
        return Colors.green;
      case ShopCategory.specialItems:
        return Colors.red;
    }
  }
}
