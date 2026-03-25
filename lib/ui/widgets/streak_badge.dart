import 'package:flutter/material.dart';

/// A reusable widget displaying player streak count with visual emphasis.
/// Shows streak count with animated updates and optional theme color styling.
class StreakBadge extends StatefulWidget {
  final int streakCount;
  final double multiplier;
  final Color? themeColor;
  final double size;

  const StreakBadge({
    super.key,
    required this.streakCount,
    this.multiplier = 1.0,
    this.themeColor,
    this.size = 56,
  });

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Animate in on first display or when streak changes
    _scaleController.forward();
  }

  @override
  void didUpdateWidget(StreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when streak count changes
    if (oldWidget.streakCount != widget.streakCount) {
      _scaleController.forward(from: 0.8);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.themeColor ?? Colors.orange;
    final multiplierText =
        widget.multiplier > 1 ? 'x${widget.multiplier.toStringAsFixed(1)}' : '';

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              backgroundColor.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(widget.size / 2),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🔥',
              style: TextStyle(fontSize: widget.size * 0.4),
            ),
            Text(
              widget.streakCount.toString(),
              style: TextStyle(
                fontSize: widget.size * 0.35,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (multiplierText.isNotEmpty)
              Text(
                multiplierText,
                style: TextStyle(
                  fontSize: widget.size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
