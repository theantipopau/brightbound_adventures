import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/widgets/confetti_burst.dart';

/// A fullscreen modal that celebrates a streak milestone.
/// Shows when the player hits 3, 7, 14, 30, 50, 100, or 365 days.
class StreakMilestoneModal extends StatefulWidget {
  final int streakDays;
  final int bonusStars;
  final VoidCallback onDismiss;

  const StreakMilestoneModal({
    super.key,
    required this.streakDays,
    required this.bonusStars,
    required this.onDismiss,
  });

  @override
  State<StreakMilestoneModal> createState() => _StreakMilestoneModalState();
}

class _StreakMilestoneModalState extends State<StreakMilestoneModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _headline {
    if (widget.streakDays >= 365) return '🏆 One Full Year!';
    if (widget.streakDays >= 100) return '💯 100 Day Legend!';
    if (widget.streakDays >= 50) return '🔥 50 Day Streak!';
    if (widget.streakDays >= 30) return '🌟 30 Day Master!';
    if (widget.streakDays >= 14) return '⚡ 2-Week Champion!';
    if (widget.streakDays >= 7) return '🎉 One Week Strong!';
    return '🔥 3 Days in a Row!';
  }

  String get _subline {
    if (widget.streakDays >= 365) {
      return 'You\'ve been adventuring every single day for a whole year. Amazing!';
    }
    if (widget.streakDays >= 100) {
      return '100 days of incredible learning! You\'re a BrightBound legend!';
    }
    if (widget.streakDays >= 50) {
      return '50 days! Your dedication is out of this world!';
    }
    if (widget.streakDays >= 30) {
      return 'A whole month of adventures! You are a true champion!';
    }
    if (widget.streakDays >= 14) {
      return 'Two weeks of awesome learning! Keep the flame burning!';
    }
    if (widget.streakDays >= 7) {
      return 'A full week! Every day you\'re getting smarter!';
    }
    return 'Three days in a row! The adventure begins!';
  }

  String get _streakEmoji {
    if (widget.streakDays >= 365) return '🏆';
    if (widget.streakDays >= 100) return '💯';
    if (widget.streakDays >= 50) return '🔥';
    if (widget.streakDays >= 30) return '🌟';
    if (widget.streakDays >= 14) return '⚡';
    if (widget.streakDays >= 7) return '🎉';
    return '🔥';
  }

  Color get _accentColor {
    if (widget.streakDays >= 100) return const Color(0xFFFFD700);
    if (widget.streakDays >= 30) return const Color(0xFFFF6B35);
    if (widget.streakDays >= 7) return const Color(0xFF7B2FFF);
    return const Color(0xFFFF9500);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          FadeTransition(
            opacity: _fadeAnim,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
          // Confetti
          LayoutBuilder(
            builder: (_, constraints) => IgnorePointer(
              child: ConfettiBurst(
                center: Offset(
                  constraints.maxWidth / 2,
                  constraints.maxHeight / 3,
                ),
                particleCount: 120,
                duration: const Duration(seconds: 4),
              ),
            ),
          ),
          // Card
          Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.35),
                      blurRadius: 40,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Giant emoji
                    Text(
                      _streakEmoji,
                      style: const TextStyle(fontSize: 72),
                    ),
                    const SizedBox(height: 12),
                    // Streak days badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _accentColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department,
                              color: _accentColor, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.streakDays} DAY STREAK',
                            style: TextStyle(
                              color: _accentColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _headline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF555577),
                        height: 1.5,
                      ),
                    ),
                    if (widget.bonusStars > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFFD700).withValues(alpha: 0.2),
                              const Color(0xFFFFAA00).withValues(alpha: 0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⭐',
                                style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 8),
                            Text(
                              '+${widget.bonusStars} Bonus Stars!',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: Color(0xFFCC8800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onDismiss,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Keep Going! 🚀',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows a [StreakMilestoneModal] as an overlay on top of current route.
void showStreakMilestoneModal(
  BuildContext context, {
  required int streakDays,
  required int bonusStars,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => StreakMilestoneModal(
      streakDays: streakDays,
      bonusStars: bonusStars,
      onDismiss: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}
