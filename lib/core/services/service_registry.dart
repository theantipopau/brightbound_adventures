import 'package:brightbound_adventures/core/services/index.dart';

/// Centralized service initialization and access.
class ServiceRegistry {
  static final _instance = ServiceRegistry._internal();

  factory ServiceRegistry() => _instance;

  ServiceRegistry._internal();

  late LocalStorageService _storage;
  late AchievementService _achievements;
  late ShopService _shop;
  late AdaptiveDifficultyService _adaptiveDifficulty;
  late AudioManager _audioManager;
  late CosmeticUnlockService _cosmeticUnlock;
  late StreakService _streak;
  late SoundEffectsService _soundEffects;
  late DailyChallengeService _dailyChallenge;
  late HapticService _haptic;
  late SpacedRepetitionService _srs;
  late AiQuestionService _aiQuestions;
  late QuestionFreshnessService _questionFreshness;
  late ThemeModeService _themeMode;

  LocalStorageService get storage => _storage;
  AchievementService get achievements => _achievements;
  ShopService get shop => _shop;
  AdaptiveDifficultyService get adaptiveDifficulty => _adaptiveDifficulty;
  AudioManager get audioManager => _audioManager;
  CosmeticUnlockService get cosmeticUnlock => _cosmeticUnlock;
  StreakService get streak => _streak;
  SoundEffectsService get soundEffects => _soundEffects;
  DailyChallengeService get dailyChallenge => _dailyChallenge;
  HapticService get haptic => _haptic;
  SpacedRepetitionService get srs => _srs;
  AiQuestionService get aiQuestions => _aiQuestions;
  QuestionFreshnessService get questionFreshness => _questionFreshness;
  ThemeModeService get themeMode => _themeMode;

  Future<void> initializeAll() async {
    _storage = LocalStorageService();
    await _storage.initializeHive();

    _achievements = AchievementService();
    await _achievements.initialize();

    _shop = ShopService();
    await _shop.initialize();

    _adaptiveDifficulty = AdaptiveDifficultyService();
    await _adaptiveDifficulty.initialize();

    _audioManager = AudioManager();
    await _audioManager.initialize();

    _cosmeticUnlock = CosmeticUnlockService();

    _streak = StreakService();
    await _streak.initialize();

    _soundEffects = SoundEffectsService();
    await _soundEffects.initialize();

    _dailyChallenge = DailyChallengeService(_storage);
    await _dailyChallenge.initialize();

    _haptic = HapticService();

    _srs = SpacedRepetitionService();
    await _srs.initialize();

    _aiQuestions = AiQuestionService();
    await _aiQuestions.initialize();

    _questionFreshness = QuestionFreshnessService();
    await _questionFreshness.initialize();

    _themeMode = ThemeModeService();
    await _themeMode.initialize();
  }
}
