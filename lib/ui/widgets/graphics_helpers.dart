import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';

/// SVG and custom paint-based visual assets for BrightBound
/// All graphics are vector-based for perfect scaling and minimal file size

class BrightBoundGraphics {
  /// Star rating widget for skill mastery display
  static Widget buildStarRating({
    required int rating, // 0-5
    required double size,
    Color filledColor = const Color(0xFFFFA500),
    Color emptyColor = const Color(0xFFE0E0E0),
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          color: filled ? filledColor : emptyColor,
          size: size,
        );
      }),
    );
  }

  /// Difficulty level indicator (1-5 bars)
  static Widget buildDifficultyBars({
    required int level, // 1-5
    required double barHeight,
    Color filledColor = const Color(0xFFFF6B9D),
    Color emptyColor = const Color(0xFFE0E0E0),
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < level;
        return Container(
          width: 6,
          height: barHeight,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: filled ? filledColor : emptyColor,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  /// Progress ring (circular progress indicator with custom styling)
  static Widget buildProgressRing({
    required double progress, // 0.0-1.0
    required double size,
    required Color backgroundColor,
    required Color progressColor,
    required String centerText,
    TextStyle? textStyle,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor.withValues(alpha: 0.1),
              border: Border.all(
                color: backgroundColor,
                width: 3,
              ),
            ),
          ),
          // Progress arc
          CustomPaint(
            painter: _ProgressRingPainter(
              progress: progress,
              color: progressColor,
              strokeWidth: 3,
            ),
            size: Size(size, size),
          ),
          // Center text
          Text(
            centerText,
            textAlign: TextAlign.center,
            style: textStyle ??
                const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// Skill card badge (zone category indicator)
  static Widget buildSkillBadge({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    double padding = 8,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding + 4, vertical: padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Mastery level indicator (visual badge)
  static Widget buildMasteryBadge(SkillState state) {
    final colors = _getMasteryColors(state);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors['bg'],
      ),
      child: Icon(
        _getMasteryIcon(state),
        color: colors['color'],
        size: 24,
      ),
    );
  }

  /// Lockable skill card (shows lock if not available)
  static Widget buildLockedOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: const Center(
        child: Icon(
          Icons.lock,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }
}

/// Custom painter for circular progress indicator
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -90 * 3.14159 / 180, // Start at top
      progress * 360 * 3.14159 / 180,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Helper function to get mastery colors
Map<String, Color> _getMasteryColors(SkillState state) {
  switch (state) {
    case SkillState.locked:
      return {
        'bg': Colors.grey.withValues(alpha: 0.2),
        'color': Colors.grey,
      };
    case SkillState.introduced:
      return {
        'bg': const Color(0xFF4ECDC4).withValues(alpha: 0.2),
        'color': const Color(0xFF4ECDC4),
      };
    case SkillState.practising:
      return {
        'bg': const Color(0xFFFFA500).withValues(alpha: 0.2),
        'color': const Color(0xFFFFA500),
      };
    case SkillState.mastered:
      return {
        'bg': const Color(0xFF06A77D).withValues(alpha: 0.2),
        'color': const Color(0xFF06A77D),
      };
  }
}

/// Helper function to get mastery icon
IconData _getMasteryIcon(SkillState state) {
  switch (state) {
    case SkillState.locked:
      return Icons.lock;
    case SkillState.introduced:
      return Icons.play_arrow;
    case SkillState.practising:
      return Icons.repeat;
    case SkillState.mastered:
      return Icons.check_circle;
  }
}
