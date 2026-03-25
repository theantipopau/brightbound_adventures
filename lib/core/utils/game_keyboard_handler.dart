import 'package:flutter/services.dart';

/// Reusable keyboard handler mixin for game screens with multiple choice answers
/// 
/// Provides standardized keyboard shortcuts:
/// - Arrow Up/Down: Navigate answer options
/// - Enter: Submit selected answer
/// - Escape: Pause/Exit
mixin GameKeyboardHandler {
  /// Handle keyboard shortcuts for game screens
  /// 
  /// Returns true if key was handled, false otherwise
  bool handleGameKeyPress(
    KeyEvent event, {
    required bool isAnswered,
    required int? selectedIndex,
    required int optionCount,
    required Function(int) onSelectOption,
    required Function() onSubmitAnswer,
    required Function() onTogglePause,
  }) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey;

    // Arrow Up: Select previous answer option
    if (key == LogicalKeyboardKey.arrowUp && !isAnswered) {
      if (selectedIndex == null) {
        onSelectOption(optionCount - 1);
      } else if (selectedIndex > 0) {
        onSelectOption(selectedIndex - 1);
      }
      return true;
    }

    // Arrow Down: Select next answer option
    if (key == LogicalKeyboardKey.arrowDown && !isAnswered) {
      if (selectedIndex == null) {
        onSelectOption(0);
      } else if (selectedIndex < optionCount - 1) {
        onSelectOption(selectedIndex + 1);
      }
      return true;
    }

    // Enter: Submit selected answer
    if (key == LogicalKeyboardKey.enter &&
        !isAnswered &&
        selectedIndex != null) {
      onSubmitAnswer();
      return true;
    }

    // Escape: Pause/Exit
    if (key == LogicalKeyboardKey.escape) {
      onTogglePause();
      return true;
    }

    return false;
  }
}
