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
    RawKeyEvent event, {
    required bool isAnswered,
    required int? selectedIndex,
    required int optionCount,
    required Function(int) onSelectOption,
    required Function() onSubmitAnswer,
    required Function() onTogglePause,
  }) {
    // Arrow Up: Select previous answer option
    if (event.isKeyPressed(LogicalKeyboardKey.arrowUp) && !isAnswered) {
      if (selectedIndex == null) {
        onSelectOption(optionCount - 1);
      } else if (selectedIndex > 0) {
        onSelectOption(selectedIndex - 1);
      }
      return true;
    }

    // Arrow Down: Select next answer option
    if (event.isKeyPressed(LogicalKeyboardKey.arrowDown) && !isAnswered) {
      if (selectedIndex == null) {
        onSelectOption(0);
      } else if (selectedIndex < optionCount - 1) {
        onSelectOption(selectedIndex + 1);
      }
      return true;
    }

    // Enter: Submit selected answer
    if (event.isKeyPressed(LogicalKeyboardKey.enter) &&
        !isAnswered &&
        selectedIndex != null) {
      onSubmitAnswer();
      return true;
    }

    // Escape: Pause/Exit
    if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
      onTogglePause();
      return true;
    }

    return false;
  }
}
