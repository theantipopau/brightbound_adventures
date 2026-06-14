import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/achievement_notification.dart';
import 'package:brightbound_adventures/ui/widgets/branded_back_button.dart';
import 'package:brightbound_adventures/ui/widgets/zone_mastered_celebration.dart';

/// Completion summary for Science Explorers sessions.
class ScienceResultsScreen extends StatefulWidget {
  final String skillName;
  final String skillId;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final int hintsUsed;
  final Color themeColor;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;
  final String? zoneId;
  final String? zoneName;

  const ScienceResultsScreen({
    super.key,
    required this.skillName,
    required this.skillId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    this.hintsUsed = 0,
    this.themeColor = const Color(0xFF4DB6AC),
    required this.onPlayAgain,
    required this.onExit,
    this.zoneId,
    this.zoneName,
  });

  @override
  State<ScienceResultsScreen> createState() => _ScienceResultsScreenState();
}

class _ScienceResultsScreenState extends State<ScienceResultsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scoreController;
  late final AnimationController _pulseController;
  late final Animation<double> _scoreAnimation;

  int _xpAwarded = 0;
  bool _leveledUp = false;
  bool _reduceMotion = false;
  bool _motionSynced = false;

  @override
  void initState() {
    super.initState();
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 0, end: widget.accuracy).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    _scoreController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _processResults());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_motionSynced && _reduceMotion == reduceMotion) return;
    _motionSynced = true;
    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _pulseController.stop();
      _scoreController.value = 1;
    } else {
      _pulseController.repeat(reverse: true);
      if (_scoreController.value == 0) {
        _scoreController.forward();
      }
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _processResults() async {
    _xpAwarded = _calculateXp();

    final skillProvider = context.read<SkillProvider>();
    final spacedRepetitionService = context.read<SpacedRepetitionService>();
    final avatarProvider = context.read<AvatarProvider>();
    final shopService = context.read<ShopService>();
    final achievementService = context.read<AchievementService>();
    final dailyService = context.read<DailyChallengeService>();

    skillProvider.updateSkillProgress(
      skillId: widget.skillId,
      sessionAccuracy: widget.accuracy,
      sessionHints: widget.hintsUsed,
    );

    spacedRepetitionService.recordSession(
      skillId: widget.skillId,
      accuracy: widget.accuracy,
    );

    checkAndShowZoneMastered(
      context,
      skillProvider,
      zoneId: widget.zoneId,
      zoneName: widget.zoneName,
      themeColor: widget.themeColor,
    );

    final previousLevel = avatarProvider.avatar?.level;
    if (avatarProvider.hasAvatar) {
      avatarProvider.addExperience(_xpAwarded);
      _leveledUp = previousLevel != null &&
          avatarProvider.avatar != null &&
          avatarProvider.avatar!.level > previousLevel;
    }

    await shopService.awardStarsForActivity(
      score: widget.correctAnswers,
      maxScore: widget.totalQuestions,
      accuracy: widget.accuracy,
    );

    try {
      final starsEarned = widget.correctAnswers * 10;
      await achievementService.updateProgress(
          'achievement_stars_25', starsEarned);
      await achievementService.updateProgress(
          'achievement_stars_50', starsEarned);
      await achievementService.updateProgress(
          'achievement_stars_100', starsEarned);
      await achievementService.trackQuestionAnswered(widget.correctAnswers > 0);
      if (widget.accuracy >= 1.0) {
        await achievementService.updateProgress('achievement_perfect_1', 1);
        await achievementService.updateProgress('achievement_perfect_5', 1);
        await achievementService.trackPerfectScore();
      }
      if (widget.correctAnswers >= 3) {
        await achievementService.updateProgress('achievement_quick_learner', 1);
      }

      if (mounted) {
        for (final achievement in achievementService.recentlyUnlocked) {
          AchievementNotificationManager.show(context, achievement);
        }
        achievementService.clearRecentlyUnlocked();
      }
    } catch (e) {
      debugPrint('Failed to update science achievements: $e');
    }

    try {
      for (int i = 0; i < widget.correctAnswers; i++) {
        for (final challenge in dailyService.todaysChallenges) {
          if (challenge.skillId == widget.skillId) {
            dailyService.updateProgress(
              challengeId: challenge.id,
              correct: true,
            );
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to update science daily challenges: $e');
    }

    if (mounted) setState(() {});
  }

  int _calculateXp() {
    final base = (widget.accuracy * 95).round();
    final investigationBonus = widget.hintsUsed == 0 ? 15 : 5;
    final masteryBonus = widget.accuracy >= 0.85 ? 25 : 0;
    return base + investigationBonus + masteryBonus;
  }

  int get _starsEarned {
    if (widget.accuracy >= 0.9) return 3;
    if (widget.accuracy >= 0.7) return 2;
    if (widget.accuracy >= 0.5) return 1;
    return 0;
  }

  String get _headline {
    if (widget.accuracy >= 0.95) return 'Discovery confirmed!';
    if (widget.accuracy >= 0.8) return 'Brilliant investigation!';
    if (widget.accuracy >= 0.6) return 'Good science thinking!';
    return 'Keep experimenting!';
  }

  String get _subhead {
    if (_leveledUp) return 'Level up! Your explorer skills are growing.';
    if (widget.accuracy >= 0.8) {
      return 'You observed carefully and connected the clues.';
    }
    return 'Every result teaches you something for the next experiment.';
  }

  Color _scoreColor(double value) {
    if (value >= 0.9) return Colors.green;
    if (value >= 0.7) return Colors.lightGreen;
    if (value >= 0.5) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 560;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.themeColor.withValues(alpha: 0.9),
              widget.themeColor.withValues(alpha: 0.42),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(isCompact ? 18 : 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _reduceMotion
                                ? 1.0
                                : 1.0 + (_pulseController.value * 0.06),
                            child: child,
                          );
                        },
                        child: Container(
                          width: isCompact ? 108 : 128,
                          height: isCompact ? 108 : 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.38),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.science_rounded,
                            color: Colors.white,
                            size: 72,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _headline,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isCompact ? 30 : 38,
                          fontWeight: FontWeight.w900,
                          shadows: const [
                            Shadow(color: Colors.black26, blurRadius: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _subhead,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: isCompact ? 15 : 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildResultsCard(isCompact),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard(bool isCompact) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 760),
      padding: EdgeInsets.all(isCompact ? 18 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withValues(alpha: 0.26),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.skillName,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.themeColor,
              fontSize: isCompact ? 19 : 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: isCompact ? 118 : 136,
                    height: isCompact ? 118 : 136,
                    child: CircularProgressIndicator(
                      value: _scoreAnimation.value,
                      strokeWidth: 12,
                      backgroundColor: Colors.blueGrey.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _scoreColor(_scoreAnimation.value),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_scoreAnimation.value * 100).round()}%',
                        style: TextStyle(
                          color: widget.themeColor,
                          fontSize: isCompact ? 30 : 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'Accuracy',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final earned = index < _starsEarned;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Icon(
                  earned ? Icons.star_rounded : Icons.star_border_rounded,
                  color: earned
                      ? AppColors.reward
                      : Colors.blueGrey.withValues(alpha: 0.28),
                  size: isCompact ? 36 : 44,
                ),
              );
            }),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              _ResultChip(
                icon: Icons.check_circle_rounded,
                label:
                    '${widget.correctAnswers}/${widget.totalQuestions} correct',
                color: Colors.green,
              ),
              _ResultChip(
                icon: Icons.lightbulb_rounded,
                label: '${widget.hintsUsed} hints',
                color: Colors.amber.shade700,
              ),
              _ResultChip(
                icon: Icons.bolt_rounded,
                label: '+$_xpAwarded XP',
                color: widget.themeColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: isCompact ? double.infinity : 220,
                child: BrandedBackButton(
                  label: 'Back to Zone',
                  onPressed: widget.onExit,
                  backgroundColor: Colors.white,
                  foregroundColor: widget.themeColor,
                  borderColor: widget.themeColor,
                  tokenBackgroundColor:
                      widget.themeColor.withValues(alpha: 0.12),
                ),
              ),
              SizedBox(
                width: isCompact ? double.infinity : 220,
                child: ElevatedButton.icon(
                  onPressed: widget.onPlayAgain,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ResultChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
