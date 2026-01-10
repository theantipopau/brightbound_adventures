import 'package:flutter/services.dart';

/// Service for managing keyboard navigation throughout the app
/// Supports desktop and browser users with arrow keys, enter, escape
class KeyboardNavigationService {
  static final KeyboardNavigationService _instance =
      KeyboardNavigationService._internal();
  factory KeyboardNavigationService() => _instance;
  KeyboardNavigationService._internal();

  // Track current focus index for list/grid navigation
  int _currentFocusIndex = 0;
  int _maxFocusIndex = 0;

  // Callbacks for navigation actions
  Function(int)? _onIndexChanged;
  Function()? _onSelect;
  Function()? _onBack;

  /// Initialize navigation for a screen with multiple focusable items
  void init({
    required int itemCount,
    Function(int)? onIndexChanged,
    Function()? onSelect,
    Function()? onBack,
    int initialIndex = 0,
  }) {
    _currentFocusIndex = initialIndex;
    _maxFocusIndex = itemCount - 1;
    _onIndexChanged = onIndexChanged;
    _onSelect = onSelect;
    _onBack = onBack;
  }

  /// Handle keyboard events for navigation
  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        _moveFocus(-1);
        return true;
      case LogicalKeyboardKey.arrowDown:
        _moveFocus(1);
        return true;
      case LogicalKeyboardKey.arrowLeft:
        _moveFocus(-1);
        return true;
      case LogicalKeyboardKey.arrowRight:
        _moveFocus(1);
        return true;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.space:
        _onSelect?.call();
        return true;
      case LogicalKeyboardKey.escape:
        _onBack?.call();
        return true;
      case LogicalKeyboardKey.digit1:
      case LogicalKeyboardKey.numpad1:
        _selectIndex(0);
        return true;
      case LogicalKeyboardKey.digit2:
      case LogicalKeyboardKey.numpad2:
        _selectIndex(1);
        return true;
      case LogicalKeyboardKey.digit3:
      case LogicalKeyboardKey.numpad3:
        _selectIndex(2);
        return true;
      case LogicalKeyboardKey.digit4:
      case LogicalKeyboardKey.numpad4:
        _selectIndex(3);
        return true;
      default:
        return false;
    }
  }

  void _moveFocus(int delta) {
    final newIndex = (_currentFocusIndex + delta).clamp(0, _maxFocusIndex);
    if (newIndex != _currentFocusIndex) {
      _currentFocusIndex = newIndex;
      _onIndexChanged?.call(_currentFocusIndex);
    }
  }

  void _selectIndex(int index) {
    if (index <= _maxFocusIndex) {
      _currentFocusIndex = index;
      _onIndexChanged?.call(_currentFocusIndex);
      _onSelect?.call();
    }
  }

  /// Get current focus index
  int get currentIndex => _currentFocusIndex;

  /// Reset navigation state
  void reset() {
    _currentFocusIndex = 0;
    _maxFocusIndex = 0;
    _onIndexChanged = null;
    _onSelect = null;
    _onBack = null;
  }
}
