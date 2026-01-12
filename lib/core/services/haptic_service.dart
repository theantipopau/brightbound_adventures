import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service for providing haptic feedback across the app.
/// 
/// Provides different vibration patterns for different events:
/// - Correct answers: Heavy single vibration
/// - Wrong answers: Light double vibration
/// - Milestone reached: Pattern vibration
/// - UI interactions: Light taps
class HapticService {
  /// Heavy vibration for correct answers
  /// Provides strong, satisfying feedback
  Future<void> onCorrectAnswer() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      // Gracefully handle devices without haptic support
      debugPrint('Haptic feedback unavailable: $e');
    }
  }

  /// Light double vibration for wrong answers
  /// Creates a pattern that feels like a "no" signal
  Future<void> onWrongAnswer() async {
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Haptic feedback unavailable: $e');
    }
  }

  /// Success pattern for milestone achievements
  /// Light vibration, pause, then heavy vibration
  Future<void> onMilestone() async {
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Haptic feedback unavailable: $e');
    }
  }

  /// Light tap for UI interactions (button presses, etc)
  Future<void> onTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Haptic feedback unavailable: $e');
    }
  }

  /// Medium impact for transitions or important events
  Future<void> onMediumImpact() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Haptic feedback unavailable: $e');
    }
  }

  /// Selection changed feedback
  Future<void> onSelectionChanged() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Haptic feedback unavailable: $e');
    }
  }
}
