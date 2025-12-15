import 'package:flutter/services.dart';

/// Simple audio service for game feedback
/// Note: For web, we use HapticFeedback as a placeholder for sound effects
/// In a full implementation, you'd use audioplayers package or web audio API
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _soundEnabled = true;
  bool _hapticEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
  }

  /// Play sound effect for correct answer
  Future<void> playCorrect() async {
    if (!_soundEnabled) return;
    // For web, use haptic feedback as placeholder
    if (_hapticEnabled) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Play sound effect for incorrect answer
  Future<void> playIncorrect() async {
    if (!_soundEnabled) return;
    if (_hapticEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }

  /// Play celebration sound
  Future<void> playCelebration() async {
    if (!_soundEnabled) return;
    if (_hapticEnabled) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
    }
  }

  /// Play tap/click sound
  Future<void> playTap() async {
    if (!_soundEnabled) return;
    if (_hapticEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Play level up sound
  Future<void> playLevelUp() async {
    if (!_soundEnabled) return;
    if (_hapticEnabled) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      await HapticFeedback.mediumImpact();
    }
  }

  /// Play countdown tick
  Future<void> playCountdownTick() async {
    if (!_soundEnabled) return;
    if (_hapticEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  /// Play game start
  Future<void> playGameStart() async {
    if (!_soundEnabled) return;
    if (_hapticEnabled) {
      await HapticFeedback.mediumImpact();
    }
  }
}
