import 'package:flutter/material.dart';

/// A widget that adds a subtle pulsing glow effect to its child.
/// Useful for drawing attention to important UI elements like unlocked zones.
class PulseEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? pulseColor;
  final double minOpacity;
  final double maxOpacity;

  const PulseEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.pulseColor,
    this.minOpacity = 0.3,
    this.maxOpacity = 0.8,
  });

  @override
  State<PulseEffect> createState() => _PulseEffectState();
}

class _PulseEffectState extends State<PulseEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.pulseColor ?? Colors.white;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing background glow
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: _animation.value),
                    blurRadius: 20,
                    spreadRadius: 8,
                  ),
                ],
              ),
            );
          },
        ),
        // The actual child widget
        widget.child,
      ],
    );
  }
}
