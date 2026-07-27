import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brightbound_adventures/ui/themes/motion_tokens.dart';

/// Interaction state exposed by [Pressable] to its [Pressable.builder].
@immutable
class PressableState {
  const PressableState({
    required this.scale,
    required this.isPressed,
    required this.isHovered,
    required this.isFocused,
    required this.enabled,
  });

  /// Current press-scale value, animating between 1.0 (rest) and the
  /// configured press scale (0.96 by default, from [MotionTokens.pressScale]).
  final double scale;
  final bool isPressed;
  final bool isHovered;
  final bool isFocused;
  final bool enabled;
}

/// A headless press/hover/focus interaction primitive: owns the gesture
/// detector, keyboard activation, hover/focus tracking, and one
/// [AnimationController] driving a press-scale value from [MotionTokens] —
/// but draws nothing itself. Callers provide [builder] to render their own
/// decoration (gradient, shadow, border, whatever) driven by the
/// [PressableState] it receives.
///
/// This exists so every pressable surface in the app (buttons, cards,
/// answer options, zone nodes) shares one interaction implementation
/// instead of each hand-rolling its own `GestureDetector` +
/// `AnimationController` + focus handling.
///
/// Example:
/// ```dart
/// Pressable(
///   onPressed: () => print('tapped'),
///   builder: (context, state, child) => AnimatedContainer(
///     duration: MotionTokens.of(context).quick,
///     transform: Matrix4.identity()..scale(state.scale),
///     decoration: BoxDecoration(
///       boxShadow: state.isPressed ? [] : AppShadows.sm(Colors.black),
///     ),
///     child: child,
///   ),
///   child: const Text('Press me'),
/// )
/// ```
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.builder,
    this.onPressed,
    this.onLongPress,
    this.child,
    this.enabled = true,
    this.enableHapticFeedback = true,
    this.onPressStart,
    this.semanticLabel,
    this.pressScale,
    this.cursor,
  });

  /// Renders the pressable surface given the current [PressableState].
  final Widget Function(
      BuildContext context, PressableState state, Widget? child) builder;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final Widget? child;

  /// When false, gestures/keyboard activation are disabled and [builder]
  /// receives `enabled: false` so it can render a disabled look.
  final bool enabled;

  /// Plays a light platform haptic on press-down. Disabled automatically
  /// has no effect since press-down never fires when [enabled] is false.
  final bool enableHapticFeedback;

  /// Optional hook fired on press-down, before [onPressed] fires on
  /// release — use for a sound effect or other side effect that should
  /// happen at touch-down rather than on tap completion. Deliberately not
  /// wired to a specific service (e.g. `SoundEffectsService`) so this
  /// widget stays dependency-free; callers pass whatever they need.
  final VoidCallback? onPressStart;

  final String? semanticLabel;

  /// Overrides the default press scale (from [MotionTokens.pressScale]).
  final double? pressScale;

  final MouseCursor? cursor;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHovered = false;
  bool _isFocused = false;

  // Resolved once in didChangeDependencies and cached, not read via
  // MotionTokens.of(context) from inside gesture callbacks: calling
  // context.dependOnInheritedWidgetOfExactType (which MotionTokens.of does
  // via MediaQuery.of) outside the build phase is unsafe - it can hit a
  // deactivated element if the widget is mid-teardown when a gesture
  // callback fires (e.g. a "spontaneous" onTapCancel after disposal).
  late MotionTokens _tokens;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, value: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tokens = MotionTokens.of(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setPressed(bool pressed) {
    _controller.animateTo(
      pressed ? 1.0 : 0.0,
      duration: _tokens.instant,
      curve: _tokens.standardCurve,
    );
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    _setPressed(true);
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
    widget.onPressStart?.call();
  }

  void _onTapUp(TapUpDetails _) => _setPressed(false);
  void _onTapCancel() => _setPressed(false);

  @override
  Widget build(BuildContext context) {
    final pressScale = widget.pressScale ?? _tokens.pressScale;

    return FocusableActionDetector(
      enabled: widget.enabled,
      mouseCursor: widget.enabled
          ? (widget.cursor ?? SystemMouseCursors.click)
          : MouseCursor.defer,
      onShowHoverHighlight: (hovered) {
        if (mounted) setState(() => _isHovered = hovered);
      },
      onShowFocusHighlight: (focused) {
        if (mounted) setState(() => _isFocused = focused);
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            if (widget.enabled) widget.onPressed?.call();
            return null;
          },
        ),
      },
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      child: Semantics(
        button: true,
        enabled: widget.enabled,
        label: widget.semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.enabled ? _onTapDown : null,
          onTapUp: widget.enabled ? _onTapUp : null,
          onTapCancel: widget.enabled ? _onTapCancel : null,
          onTap: widget.enabled ? widget.onPressed : null,
          onLongPress: widget.enabled ? widget.onLongPress : null,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final scale = 1.0 - (_controller.value * (1.0 - pressScale));
              return widget.builder(
                context,
                PressableState(
                  scale: scale,
                  isPressed: _controller.value > 0,
                  isHovered: _isHovered,
                  isFocused: _isFocused,
                  enabled: widget.enabled,
                ),
                child,
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
