import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// A polished, animated button with press-scale and glow feedback.
///
/// Drop-in replacement for ElevatedButton anywhere in the game.
/// Provides:
///   - Scale-down on press (0.95), spring-back on release
///   - Hover glow (web/desktop)
///   - Configurable gradient, icon, size, and color
///   - Optional "shimmer" animated border for call-to-action buttons
class JuicyButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? emoji;
  final Color? color;
  final Gradient? gradient;
  final double? width;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;
  final bool shimmer;   // animated glow border for CTA
  final Color? textColor;

  const JuicyButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.emoji,
    this.color,
    this.gradient,
    this.width,
    this.height = 52,
    this.fontSize = 16,
    this.padding,
    this.isLoading = false,
    this.shimmer = false,
    this.textColor,
  });

  /// Factory: primary pink (default)
  factory JuicyButton.primary({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    String? emoji,
    double? width,
    bool shimmer = false,
  }) =>
      JuicyButton(
        key: key,
        label: label,
        onPressed: onPressed,
        icon: icon,
        emoji: emoji,
        gradient: AppGradients.primary,
        textColor: Colors.white,
        width: width,
        shimmer: shimmer,
      );

  /// Factory: success green
  factory JuicyButton.success({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    String? emoji,
    double? width,
  }) =>
      JuicyButton(
        key: key,
        label: label,
        onPressed: onPressed,
        icon: icon,
        emoji: emoji,
        gradient: AppGradients.success,
        textColor: Colors.white,
        width: width,
      );

  /// Factory: world-themed
  factory JuicyButton.world({
    Key? key,
    required String label,
    required WorldTokens world,
    VoidCallback? onPressed,
    IconData? icon,
    double? width,
    bool shimmer = false,
  }) =>
      JuicyButton(
        key: key,
        label: label,
        onPressed: onPressed,
        icon: icon,
        gradient: world.headerGradient,
        textColor: Colors.white,
        width: width,
        shimmer: shimmer,
      );

  @override
  State<JuicyButton> createState() => _JuicyButtonState();
}

class _JuicyButtonState extends State<JuicyButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: AppMotion.fast,
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: AppMotion.hover),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.shimmer) _shimmerController.repeat();
  }

  @override
  void didUpdateWidget(JuicyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shimmer && !_shimmerController.isAnimating) {
      _shimmerController.repeat();
    } else if (!widget.shimmer && _shimmerController.isAnimating) {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressController.forward();
  void _onTapUp(TapUpDetails _) => _pressController.reverse();
  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final effectiveGradient = disabled
        ? const LinearGradient(colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)])
        : widget.gradient ??
            LinearGradient(
              colors: [
                widget.color ?? AppColors.primary,
                (widget.color ?? AppColors.primary).withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: disabled ? null : _onTapDown,
        onTapUp: disabled ? null : _onTapUp,
        onTapCancel: disabled ? null : _onTapCancel,
        onTap: disabled ? null : widget.onPressed,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pressController, _shimmerController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnim.value,
              child: AnimatedContainer(
                duration: AppMotion.fast,
                width: widget.width,
                height: widget.height,
                padding: widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 0),
                decoration: BoxDecoration(
                  gradient: effectiveGradient,
                  borderRadius: BorderRadius.circular(AppBorders.lg),
                  boxShadow: disabled
                      ? null
                      : (_isHovered
                          ? AppShadows.md(
                              (widget.color ?? AppColors.primary))
                          : AppShadows.sm(
                              (widget.color ?? AppColors.primary))),
                ),
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    final textColor = widget.onPressed == null
        ? Colors.white70
        : (widget.textColor ?? Colors.white);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.emoji != null) ...[
          Text(widget.emoji!, style: TextStyle(fontSize: widget.fontSize + 2)),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, color: textColor, size: widget.fontSize + 4),
          const SizedBox(width: 8),
        ],
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: AppTheme.fontPrimary,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED COUNTER TEXT — animates from 0 to a target integer value
// ─────────────────────────────────────────────────────────────────────────────

/// Counts from 0 up to [targetValue], applying optional [prefix] and [suffix].
/// Use for large score/accuracy displays on results screens.
class AnimatedCounterText extends StatefulWidget {
  final int targetValue;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final Curve curve;

  const AnimatedCounterText({
    super.key,
    required this.targetValue,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedCounterText> createState() => _AnimatedCounterTextState();
}

class _AnimatedCounterTextState extends State<AnimatedCounterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int> _countAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _countAnim = IntTween(begin: 0, end: widget.targetValue).animate(
      CurvedAnimation(parent: _ctrl, curve: widget.curve),
    );
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounterText old) {
    super.didUpdateWidget(old);
    if (old.targetValue != widget.targetValue) {
      _countAnim = IntTween(begin: _countAnim.value, end: widget.targetValue)
          .animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _countAnim,
      builder: (_, __) => Text(
        '${widget.prefix}${_countAnim.value}${widget.suffix}',
        style: widget.style,
      ),
    );
  }
}
