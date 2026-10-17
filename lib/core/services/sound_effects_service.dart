import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/core/services/audio_manager.dart';

/// Sound Effects Manager for UI feedback sounds
/// Handles button clicks, success/error sounds, and UI interactions
class SoundEffectsService {
  static final SoundEffectsService _instance = SoundEffectsService._internal();
  factory SoundEffectsService() => _instance;
  SoundEffectsService._internal();

  static const String _enabledKey = 'sound_effects_enabled';
  bool _isEnabled = true;
  bool _isInitialized = false;

  /// Initialize sound effects service
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_enabledKey) ?? true;
    _isInitialized = true;
  }

  /// Toggle sound effects on/off
  Future<void> toggleEnabled() async {
    _isEnabled = !_isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, _isEnabled);
  }

  /// Check if sound effects are enabled
  bool get isEnabled => _isEnabled;

  /// Play button click sound (real bundled asset via AudioManager).
  Future<void> playButtonClick() async {
    if (!_isEnabled) return;
    try {
      await AudioManager().playButtonClick();
    } catch (_) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Play success sound (real correct-answer chime + haptics).
  Future<void> playSuccess() async {
    if (!_isEnabled) return;
    try {
      await AudioManager().playCorrectAnswer();
    } catch (_) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Play error sound (real wrong-answer buzz + haptics).
  Future<void> playError() async {
    if (!_isEnabled) return;
    try {
      await AudioManager().playIncorrectAnswer();
    } catch (_) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Play UI interaction sound (toggle, swipe)
  Future<void> playInteraction() async {
    if (!_isEnabled) return;
    await HapticFeedback.selectionClick();
  }

  /// Play star earned sound (real unlock chime).
  Future<void> playStarEarned() async {
    if (!_isEnabled) return;
    try {
      await AudioManager().playUnlock();
    } catch (_) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Play level complete sound (real level-up fanfare).
  Future<void> playLevelComplete() async {
    if (!_isEnabled) return;
    try {
      await AudioManager().playLevelUp();
    } catch (_) {
      await SystemSound.play(SystemSoundType.click);
    }
  }

  /// Play navigation sound
  Future<void> playNavigation() async {
    if (!_isEnabled) return;
    await HapticFeedback.selectionClick();
  }
}

/// Mixin for widgets that need sound effects
mixin SoundEffectsMixin {
  final SoundEffectsService _soundEffects = SoundEffectsService();

  void playButtonClickSound() {
    _soundEffects.playButtonClick();
  }

  void playSuccessSound() {
    _soundEffects.playSuccess();
  }

  void playErrorSound() {
    _soundEffects.playError();
  }

  void playInteractionSound() {
    _soundEffects.playInteraction();
  }

  void playStarEarnedSound() {
    _soundEffects.playStarEarned();
  }

  void playLevelCompleteSound() {
    _soundEffects.playLevelComplete();
  }

  void playNavigationSound() {
    _soundEffects.playNavigation();
  }
}
