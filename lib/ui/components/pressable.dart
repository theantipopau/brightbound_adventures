import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:brightbound_adventures/core/services/audio_manager.dart';
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

  /// Current scale multiplier applied to the surface: 1.0 at rest, dips to
  /// the press scale on press-down, and bounces past 1.0 (through the
  /// [MotionTokens.juiceOvershoot], 1.12) elastically on release — unless
  /// reduced motion collapses everything to instant states.
  final double scale;
  final bool isPressed;
  final bool isHovered;
  final bool isFocused;
  final bool enabled;
}

/// A headless press/hover/focus interaction primitive: owns the gesture
/// detector, keyboard activation, hover/focus tracking, the press and
/// release "juice" choreography — but draws nothing itself. Callers provide
/// [builder] to render their own decoration (gradient, shadow, border,
/// whatever) driven by the [PressableState] it receives.
///
/// This exists so every pressable surface in the app (buttons, cards,
/// answer options, zone nodes) shares one interaction implementation
/// instead of each hand-rolling its own `GestureDetector` +
/// `AnimationController` + focus handling.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.builder,
    this.onPressed,
    this.onLongPress,
    this.child,
    this.enabled = true,
    this.enableHapticFeedback = true,
    this.enableTapSound = true,
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

  /// Plays the bundled button-tap sound on press-down (A4/A5), gated by the
  /// audio settings inside [AudioManager]. Test/browsers without the asset
  /// fall back to haptics automatically.
  final bool enableTapSound;

  /// Optional hook fired on press-down, before [onPressed] fires on
  /// release — use for other side effects that should happen at touch-down.
  final VoidCallback? onPressStart;

  final String? semanticLabel;

  /// Overrides the default press scale (from [MotionTokens.pressScale]).
  final double? pressScale;

  final MouseCursor? cursor;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with TickerProviderStateMixin {
  /// 0 = rest, 1 = fully pressed.
  late final AnimationController _pressCtrl;

  /// 0 = no bounce, 1 = bounce choreography complete.
  late final AnimationController _bounceCtrl;

  bool _isHovered = false;
  bool _isFocused = false;

  /// Pointer is physically down on this surface. Tracked independently of
  /// the press controller's animated value because a quick tap-down/tap-up
  /// can arrive while the press-down animation is still ramping — a value
  /// snapshot would miss the release entirely and leave the button stuck.
  bool _pointerDown = false;

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
    _pressCtrl = AnimationController(vsync: this, value: 0);
    _bounceCtrl = AnimationController(vsync: this, value: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tokens = MotionTokens.of(context);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  /// A5 button juice. Press-down is instant (the finger is already on the
  /// surface — delay reads as lag). Release bounces from the pressed scale
  /// up past rest to the juice overshoot (1.12) and settles with
  /// elasticOut. Reduced motion collapses to instant state changes with no
  /// scale, tilt, or bounce.
  void _setPressed(bool pressed) {
    _pointerDown = pressed;
    if (_tokens.reduced) {
      _pressCtrl.value = pressed ? 1.0 : 0.0;
      _bounceCtrl.value = 0.0;
      return;
    }
    if (pressed) {
      _bounceCtrl.stop();
      _bounceCtrl.value = 0.0;
      _pressCtrl.animateTo(1.0,
          duration: _tokens.instant, curve: _tokens.exitCurve);
      return;
    }
    _bounceCtrl.animateTo(1.0, duration: _tokens.juiceBounce).whenComplete(() {
      if (mounted) _pressCtrl.value = 0.0;
    });
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    _setPressed(true);
    if (widget.enableTapSound) {
      // Fire-and-forget: sound is feedback, never a gate for the action.
      AudioManager().playButtonClick();
    }
    if (widget.enableHapticFeedback) {
      HapticFeedback.selectionClick();
    }
    widget.onPressStart?.call();
  }

  void _onTapUp(TapUpDetails _) => _setPressed(false);
  void _onTapCancel() => _setPressed(false);

  /// Composite scale from the two controllers.
  ///
  /// Phase A (bounce 0 → 0.3): rise from the pressed scale to the overshoot
  /// peak, easeOut. Phase B (bounce 0.3 → 1): settle back to rest with an
  /// elastic tail. Outside the bounce the scale is just the press-scale.
  double _scaleFor(MotionTokens tokens) {
    final pressScale = widget.pressScale ?? tokens.pressScale;
    final pressedScale = 1.0 - (_pressCtrl.value * (1.0 - pressScale));
    if (_bounceCtrl.value <= 0.0) return pressedScale;

    final overshoot = tokens.juiceOvershoot;
    const peak = 0.3;
    final t = _bounceCtrl.value;
    double bounceScale;
    if (t < peak) {
      final u = t / peak;
      bounceScale = pressScale + (overshoot - pressScale) * Curves.easeOut.transform(u);
    } else {
      final u = ((t - peak) / (1 - peak)).clamp(0.0, 1.0);
      bounceScale = overshoot + (1.0 - overshoot) * Curves.elasticOut.transform(u);
    }
    // Blend out the pressed component as the bounce begins, so choreography
    // owns the motion from the moment of release.
    return pressedScale * 0.0 + bounceScale;
  }

  @override
  Widget build(BuildContext context) {
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
            animation: Listenable.merge([_pressCtrl, _bounceCtrl]),
            builder: (context, child) {
              return widget.builder(
                context,
                PressableState(
                  scale: _scaleFor(_tokens),
                  isPressed: _pointerDown,
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
