import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// A score counter that animates when the value changes.
class AnimatedScoreCounter extends StatefulWidget {
  final int value;
  final String label;
  final String emoji;
  final Color color;

  const AnimatedScoreCounter({
    super.key,
    required this.value,
    this.label = '',
    this.emoji = '⭐',
    this.color = AppColors.reward,
  });

  @override
  State<AnimatedScoreCounter> createState() => _AnimatedScoreCounterState();
}

class _AnimatedScoreCounterState extends State<AnimatedScoreCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _oldValue = widget.value;
    _controller = AnimationController(
      duration: AppMotion.standard,
      vsync: this,
    );
    _animation = IntTween(begin: _oldValue, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: AppMotion.enter),
    );
  }

  @override
  void didUpdateWidget(AnimatedScoreCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _animation = IntTween(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: AppMotion.enter),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: AppBorders.radiusPill,
        border: Border.all(color: widget.color.withValues(alpha: 0.4), width: 2),
        boxShadow: AppShadows.sm(widget.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                _animation.value.toString(),
                style: AppTypography.displaySmall.copyWith(
                  color: widget.color,
                  fontSize: 20,
                ),
              );
            },
          ),
          if (widget.label.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              widget.label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
