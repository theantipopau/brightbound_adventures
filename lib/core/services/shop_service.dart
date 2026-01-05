import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:brightbound_adventures/core/models/shop_item.dart';

/// Service for managing shop purchases and currency
class ShopService extends ChangeNotifier {
  static final ShopService _instance = ShopService._internal();
  factory ShopService() => _instance;
  ShopService._internal();

  List<ShopItem> _items = [];
  int _starBalance = 0;
  
  List<ShopItem> get items => _items;
  int get starBalance => _starBalance;
  
  List<ShopItem> get purchasedItems => 
      _items.where((item) => item.isPurchased).toList();
  
  List<ShopItem> get availableItems => 
      _items.where((item) => !item.isPurchased).toList();
  
  /// Initialize shop from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Start with all items from database
    _items = ShopDatabase.allItems.map((item) => item.copyWith()).toList();
    
    // Load star balance
    _starBalance = prefs.getInt('star_balance') ?? 0;
    
    // Load purchased items
    final purchasedIds = prefs.getStringList('purchased_items') ?? [];
    final purchasedData = prefs.getString('purchased_items_data');
    
    if (purchasedData != null) {
      try {
        final Map<String, dynamic> data = json.decode(purchasedData);
        
        for (int i = 0; i < _items.length; i++) {
          final item = _items[i];
          if (purchasedIds.contains(item.id)) {
            final itemData = data[item.id];
            _items[i] = item.copyWith(
              isPurchased: true,
              purchasedAt: itemData != null && itemData['purchasedAt'] != null
                  ? DateTime.parse(itemData['purchasedAt'])
                  : DateTime.now(),
            );
          }
        }
      } catch (e) {
        debugPrint('Error loading shop data: $e');
      }
    }
    
    notifyListeners();
  }
  
  /// Save shop state to storage
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save star balance
    await prefs.setInt('star_balance', _starBalance);
    
    // Save purchased items
    final purchasedIds = _items
        .where((item) => item.isPurchased)
        .map((item) => item.id)
        .toList();
    await prefs.setStringList('purchased_items', purchasedIds);
    
    // Save purchase dates
    final Map<String, dynamic> data = {};
    for (final item in _items.where((i) => i.isPurchased)) {
      data[item.id] = {
        'purchasedAt': item.purchasedAt?.toIso8601String(),
      };
    }
    await prefs.setString('purchased_items_data', json.encode(data));
  }
  
  /// Check if player can afford an item
  bool canAfford(ShopItem item) {
    return _starBalance >= item.starCost;
  }
  
  /// Purchase an item
  Future<bool> purchaseItem(String itemId) async {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index == -1) return false;
    
    final item = _items[index];
    
    // Check if already purchased
    if (item.isPurchased) return false;
    
    // Check if player can afford it
    if (!canAfford(item)) return false;
    
    // Deduct stars
    _starBalance -= item.starCost;
    
    // Mark as purchased
    _items[index] = item.copyWith(
      isPurchased: true,
      purchasedAt: DateTime.now(),
    );
    
    await _save();
    notifyListeners();
    
    return true;
  }
  
  /// Add stars to balance (from earning in games)
  Future<void> addStars(int amount) async {
    _starBalance += amount;
    await _save();
    notifyListeners();
  }
  
  /// Spend stars (for consumable items)
  Future<bool> spendStars(int amount) async {
    if (_starBalance < amount) return false;
    
    _starBalance -= amount;
    await _save();
    notifyListeners();
    
    return true;
  }
  
  /// Get items by category
  List<ShopItem> getItemsByCategory(ShopCategory category) {
    return _items.where((item) => item.category == category).toList();
  }
  
  /// Check if item is purchased
  bool isPurchased(String itemId) {
    final item = _items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => _items[0],
    );
    
    if (item.id == _items[0].id && item.id != itemId) {
      return false; // Not found
    }
    
    return item.isPurchased;
  }
  
  /// Reset shop (for testing)
  Future<void> reset() async {
    _items = ShopDatabase.allItems.map((item) => item.copyWith()).toList();
    _starBalance = 0;
    await _save();
    notifyListeners();
  }
  
  /// Award stars for completing activities
  Future<void> awardStarsForActivity({
    required int score,
    required int maxScore,
    required double accuracy,
  }) async {
    // Calculate stars based on performance
    int stars = 0;
    
    if (accuracy >= 0.9) {
      stars = 3; // Excellent
    } else if (accuracy >= 0.7) {
      stars = 2; // Good
    } else if (accuracy >= 0.5) {
      stars = 1; // Keep trying
    }
    
    if (stars > 0) {
      await addStars(stars);
    }
  }
}
