import 'package:flutter/services.dart';

/// Reusable keyboard handler mixin for game screens with multiple choice answers
///
/// Provides standardized keyboard shortcuts (PC + keyboard users):
/// - Arrow Up/Down/Left/Right: Navigate answer options
/// - 1-4 (top row + numpad): Jump directly to an option
/// - Enter/Space: Submit selected answer
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

    // 1-4: jump directly to an option (PC shortcut, incl. numpad).
    if (!isAnswered) {
      int? digit;
      if (key == LogicalKeyboardKey.digit1 ||
          key == LogicalKeyboardKey.numpad1) {
        digit = 0;
      }
      if (key == LogicalKeyboardKey.digit2 ||
          key == LogicalKeyboardKey.numpad2) {
        digit = 1;
      }
      if (key == LogicalKeyboardKey.digit3 ||
          key == LogicalKeyboardKey.numpad3) {
        digit = 2;
      }
      if (key == LogicalKeyboardKey.digit4 ||
          key == LogicalKeyboardKey.numpad4) {
        digit = 3;
      }
      if (digit != null && digit < optionCount) {
        onSelectOption(digit);
        return true;
      }
    }

    // Left/Right also move between options for PC users.
    if ((key == LogicalKeyboardKey.arrowLeft ||
            key == LogicalKeyboardKey.arrowRight) &&
        !isAnswered) {
      final delta = key == LogicalKeyboardKey.arrowRight ? 1 : -1;
      if (selectedIndex == null) {
        onSelectOption(delta > 0 ? 0 : optionCount - 1);
      } else {
        final next = (selectedIndex + delta).clamp(0, optionCount - 1);
        onSelectOption(next);
      }
      return true;
    }

    // Enter/Space: Submit selected answer
    if ((key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) &&
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
