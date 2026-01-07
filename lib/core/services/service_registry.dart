import 'package:brightbound_adventures/core/services/index.dart';

/// Centralized service initialization and access
/// 
/// Consolidates all service initialization logic in one place,
/// making the app dependency graph clear and testable.
/// 
/// Usage:
/// ```dart
/// // In main():
/// final registry = ServiceRegistry();
/// await registry.initializeAll();
/// 
/// // Access services:
/// registry.storage
/// registry.achievements
/// registry.shop
/// ```
class ServiceRegistry {
  static final _instance = ServiceRegistry._internal();

  factory ServiceRegistry() => _instance;

  ServiceRegistry._internal();

  // Services (initialized on demand)
  late LocalStorageService _storage;
  late AchievementService _achievements;
  late ShopService _shop;
  late AdaptiveDifficultyService _adaptiveDifficulty;
  late AudioManager _audioManager;
  late CosmeticUnlockService _cosmeticUnlock;

  // Getters
  LocalStorageService get storage => _storage;
  AchievementService get achievements => _achievements;
  ShopService get shop => _shop;
  AdaptiveDifficultyService get adaptiveDifficulty => _adaptiveDifficulty;
  AudioManager get audioManager => _audioManager;
  CosmeticUnlockService get cosmeticUnlock => _cosmeticUnlock;

  /// Initialize all services in dependency order
  /// 
  /// Storage must be initialized first, as other services depend on it.
  Future<void> initializeAll() async {
    // 1. Initialize storage first (required by other services)
    _storage = LocalStorageService();
    await _storage.initializeHive();

    // 2. Initialize services that depend on storage
    _achievements = AchievementService();
    await _achievements.initialize();

    _shop = ShopService();
    await _shop.initialize();

    _adaptiveDifficulty = AdaptiveDifficultyService();
    await _adaptiveDifficulty.initialize();

    // 3. Initialize independent services
    _audioManager = AudioManager();
    await _audioManager.initialize();

    _cosmeticUnlock = CosmeticUnlockService();
    // No async init needed for cosmetics
  }
}
