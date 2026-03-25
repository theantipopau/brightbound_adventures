import 'package:flutter/material.dart';

/// Widget to display current difficulty level
/// Shows visual indicator with stars/badges for difficulty 1-3
class DifficultyIndicator extends StatelessWidget {
  final int difficulty;
  final Color color;
  final bool compact;

  const DifficultyIndicator({
    super.key,
    required this.difficulty,
    this.color = Colors.amber,
    this.compact = false,
  });

  String _getDifficultyLabel() {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Level $difficulty';
    }
  }

  String _getDifficultyEmoji() {
    switch (difficulty) {
      case 1:
        return '⭐';
      case 2:
        return '⭐⭐';
      case 3:
        return '⭐⭐⭐';
      default:
        return '⭐' * difficulty;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Tooltip(
        message: '${_getDifficultyLabel()} Difficulty',
        child: Text(
          _getDifficultyEmoji(),
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getDifficultyEmoji(),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            _getDifficultyLabel(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
