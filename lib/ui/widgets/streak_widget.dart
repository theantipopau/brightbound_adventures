import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/services/streak_service.dart';
import 'package:brightbound_adventures/core/services/streak_enhanced_service.dart';

/// Widget to display the current streak with animation
class StreakWidget extends StatefulWidget {
  final StreakService streakService;
  final bool compact;

  const StreakWidget({
    super.key,
    required this.streakService,
    this.compact = false,
  });

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStreakColor() {
    final streak = widget.streakService.currentStreak;
    if (streak >= 100) return Colors.purple;
    if (streak >= 30) return Colors.orange;
    if (streak >= 14) return Colors.amber;
    if (streak >= 7) return Colors.blue;
    if (streak >= 3) return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactStreak();
    }
    return _buildFullStreak();
  }

  Widget _buildCompactStreak() {
    final streak = widget.streakService.currentStreak;
    final color = _getStreakColor();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.8),
                color.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: _glowAnimation.value,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: streak > 0 ? _scaleAnimation.value : 1.0,
                child: Text(
                  widget.streakService.streakEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullStreak() {
    final streak = widget.streakService.currentStreak;
    final color = _getStreakColor();
    final bonus = widget.streakService.streakBonus;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.3),
                color.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: _glowAnimation.value,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: streak > 0 ? _scaleAnimation.value : 1.0,
                    child: Text(
                      widget.streakService.streakEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streak Day${streak == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        widget.streakService.streakMessage,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (bonus > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '+$bonus bonus stars!',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _buildProgressToMilestone(color),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressToMilestone(Color color) {
    final streak = widget.streakService.currentStreak;
    final nextMilestone = widget.streakService.nextMilestone;
    final daysToGo = widget.streakService.daysToNextMilestone;

    if (daysToGo == 0) {
      return const Text(
        '🏆 You\'ve reached all milestones!',
        style: TextStyle(
          color: Colors.purple,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final progress = streak / nextMilestone;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next: $nextMilestone days',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              '$daysToGo to go',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// Enhanced compact streak display with growing flame animation
class EnhancedStreakWidget extends StatefulWidget {
  final StreakService streakService;
  final VoidCallback? onMilestoneReached;

  const EnhancedStreakWidget({
    super.key,
    required this.streakService,
    this.onMilestoneReached,
  });

  @override
  State<EnhancedStreakWidget> createState() => _EnhancedStreakWidgetState();
}

class _EnhancedStreakWidgetState extends State<EnhancedStreakWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flameScaleAnimation;
  late Animation<double> _pulseAnimation;
  late StreakEnhancedService _enhancedService;

  @override
  void initState() {
    super.initState();
    _enhancedService = StreakEnhancedService(widget.streakService);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    // Flame scale grows with streak
    _flameScaleAnimation = Tween<double>(
      begin: _enhancedService.getFlameScale() * 0.9,
      end: _enhancedService.getFlameScale() * 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(EnhancedStreakWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update animation if streak changed
    if (oldWidget.streakService.currentStreak !=
        widget.streakService.currentStreak) {
      _flameScaleAnimation = Tween<double>(
        begin: _enhancedService.getFlameScale() * 0.9,
        end: _enhancedService.getFlameScale() * 1.1,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streak = widget.streakService.currentStreak;
    final nextMilestone = _enhancedService.getNextMilestone();
    final color = _enhancedService.getStreakColor(streak);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.85),
                color.withValues(alpha: 0.65),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(
                    alpha: 0.3 + (_pulseAnimation.value * 0.4)),
                blurRadius: 12 + (_pulseAnimation.value * 8),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Growing flame icon
              Transform.scale(
                scale: streak > 0 ? _flameScaleAnimation.value : 0.8,
                child: Text(
                  _enhancedService.getMilestoneEmoji(),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 8),
              // Streak counter
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${nextMilestone.daysUntil} to ${nextMilestone.nextMilestone}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Milestone celebration card (displayed when streak milestone reached)
class StreakMilestoneCard extends StatefulWidget {
  final int milestone;
  final VoidCallback onDismiss;

  const StreakMilestoneCard({
    super.key,
    required this.milestone,
    required this.onDismiss,
  });

  @override
  State<StreakMilestoneCard> createState() => _StreakMilestoneCardState();
}

class _StreakMilestoneCardState extends State<StreakMilestoneCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine milestone level and reward
    String? rewardOutfitId;
    String celebrationMessage;
    Color celebrationColor;

    switch (widget.milestone) {
      case 3:
        rewardOutfitId = 'outfit_fire_starter';
        celebrationMessage = '🎉 3-Day Streak! You\'re on fire!';
        celebrationColor = const Color(0xFF00BCD4);
        break;
      case 7:
        rewardOutfitId = 'outfit_week_warrior';
        celebrationMessage = '👏 Week Warrior! 7 Days!';
        celebrationColor = const Color(0xFF4CAF50);
        break;
      case 14:
        rewardOutfitId = 'outfit_fortnight_hero';
        celebrationMessage = '⭐ Fortnight Hero! 14 Days!';
        celebrationColor = const Color(0xFF2196F3);
        break;
      case 30:
        rewardOutfitId = 'outfit_monthly_legend';
        celebrationMessage = '👑 Monthly Legend! 30 Days!';
        celebrationColor = const Color(0xFFFFC400);
        break;
      case 50:
        rewardOutfitId = 'outfit_epic_challenger';
        celebrationMessage = '🏆 Epic Challenger! 50 Days!';
        celebrationColor = const Color(0xFFFF6F00);
        break;
      case 100:
        rewardOutfitId = 'outfit_legendary_master';
        celebrationMessage = '🏆 LEGENDARY MASTER! 100 DAYS!';
        celebrationColor = const Color(0xFF9C27B0);
        break;
      default:
        celebrationMessage = '🎊 Milestone Reached!';
        celebrationColor = Colors.blue;
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                celebrationColor.withValues(alpha: 0.2),
                celebrationColor.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: celebrationColor.withValues(alpha: 0.6),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: celebrationColor.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration text
              Text(
                celebrationMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: celebrationColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              // Reward outfit preview (text for now)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
              ),
                decoration: BoxDecoration(
                  color: celebrationColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: celebrationColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '🎁 New Outfit Unlocked!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: celebrationColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rewardOutfitId ?? 'Special Reward',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Dismiss button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: celebrationColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: widget.onDismiss,
                child: const Text(
                  'Awesome! Keep Going! 🚀',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
