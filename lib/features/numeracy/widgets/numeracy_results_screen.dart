import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/widgets/achievement_notification.dart';
import 'package:brightbound_adventures/ui/widgets/branded_back_button.dart';
import 'package:brightbound_adventures/ui/widgets/zone_mastered_celebration.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// Quiz results screen for numeracy games
class NumeracyResultsScreen extends StatefulWidget {
  final String skillName;
  final String skillId;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final int hintsUsed;
  final Color themeColor;
  final VoidCallback onPlayAgain;
  final VoidCallback onExit;
  /// Zone id used to check for zone mastery after the session.
  final String? zoneId;
  /// Display name of the zone (e.g. 'Number Nebula').
  final String? zoneName;

  const NumeracyResultsScreen({
    super.key,
    required this.skillName,
    required this.skillId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    this.hintsUsed = 0,
    this.themeColor = AppColors.numberNebulaColor,
    required this.onPlayAgain,
    required this.onExit,
    this.zoneId,
    this.zoneName,
  });

  @override
  State<NumeracyResultsScreen> createState() => _NumeracyResultsScreenState();
}

class _NumeracyResultsScreenState extends State<NumeracyResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(begin: 0, end: widget.accuracy).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    // Start animations
    _celebrationController.repeat();
    _scoreController.forward();

    // Record progress
    _recordProgress();
  }

  void _recordProgress() async {
    final skillProvider = context.read<SkillProvider>();
    final achievementService = AchievementService();
    final shopService = ShopService();

    // Record practice session and update skill progress
    skillProvider.updateSkillProgress(
      skillId: widget.skillId,
      sessionAccuracy: widget.accuracy,
      sessionHints: widget.hintsUsed,
    );

    // Check if this session completed the whole zone
    checkAndShowZoneMastered(
      context,
      skillProvider,
      zoneId: widget.zoneId,
      zoneName: widget.zoneName,
      themeColor: widget.themeColor,
    );

    // Award stars
    await shopService.awardStarsForActivity(
      score: widget.correctAnswers,
      maxScore: widget.totalQuestions,
      accuracy: widget.accuracy,
    );

    // Track achievements
    await achievementService
        .trackQuestionAnswered(true); // Track correct answers

    // Check for perfect score
    if (widget.accuracy >= 1.0) {
      await achievementService.trackPerfectScore();
    }

    // Show any newly unlocked achievements
    if (mounted) {
      for (final achievement in achievementService.recentlyUnlocked) {
        AchievementNotificationManager.show(context, achievement);
      }
      achievementService.clearRecentlyUnlocked();
    }
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  String _getPerformanceEmoji() {
    if (widget.accuracy >= 0.9) return '🌟';
    if (widget.accuracy >= 0.7) return '🚀';
    if (widget.accuracy >= 0.5) return '✨';
    return '🌙';
  }

  String _getPerformanceMessage() {
    if (widget.accuracy >= 0.9) return 'Superstar!';
    if (widget.accuracy >= 0.7) return 'Great Job!';
    if (widget.accuracy >= 0.5) return 'Good Effort!';
    return 'Keep Exploring!';
  }

  String _getPerformanceSubtext() {
    if (widget.accuracy >= 0.9) return 'You\'re a math wizard! ✨';
    if (widget.accuracy >= 0.7) return 'You\'re doing amazing! Keep it up!';
    if (widget.accuracy >= 0.5) return 'Practice makes perfect!';
    return 'Every star was once in the dark. Keep trying!';
  }

  int _getStarsEarned() {
    if (widget.accuracy >= 0.9) return 3;
    if (widget.accuracy >= 0.7) return 2;
    if (widget.accuracy >= 0.5) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.themeColor.withValues(alpha: 0.8),
              widget.themeColor.withValues(alpha: 0.4),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Animated celebration icon
                AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_celebrationController.value * 0.1),
                      child: Text(
                        _getPerformanceEmoji(),
                        style: const TextStyle(fontSize: 80),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Performance message
                Text(
                  _getPerformanceMessage(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _getPerformanceSubtext(),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 30),

                // Stars earned
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final earned = index < _getStarsEarned();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: AnimatedBuilder(
                        animation: _scoreController,
                        builder: (context, child) {
                          final delay = index * 0.2;
                          final progress =
                              ((_scoreController.value - delay) / 0.3)
                                  .clamp(0.0, 1.0);
                          return Transform.scale(
                            scale: earned ? progress : 0.8,
                            child: Icon(
                              earned ? Icons.star : Icons.star_border,
                              size: 60,
                              color: earned
                                  ? Colors.amber
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 30),

                // Score card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: widget.themeColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.skillName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.themeColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Animated score circle
                        AnimatedBuilder(
                          animation: _scoreAnimation,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CircularProgressIndicator(
                                    value: _scoreAnimation.value,
                                    strokeWidth: 12,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation(
                                      _getScoreColor(_scoreAnimation.value),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '${(_scoreAnimation.value * 100).round()}%',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: widget.themeColor,
                                      ),
                                    ),
                                    Text(
                                      'Accuracy',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              '✅',
                              '${widget.correctAnswers}/${widget.totalQuestions}',
                              'Correct',
                            ),
                            _buildStatItem(
                              '💡',
                              '${widget.hintsUsed}',
                              'Hints Used',
                            ),
                            _buildStatItem(
                              '⭐',
                              '+${_getXpEarned()}',
                              'XP Earned',
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.onPlayAgain,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: widget.themeColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 6,
                                  shadowColor: widget.themeColor.withValues(alpha: 0.4),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Image.asset('assets/images/potion.PNG', fit: BoxFit.contain),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text('Play Again', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.9) return Colors.green;
    if (score >= 0.7) return Colors.lightGreen;
    if (score >= 0.5) return Colors.orange;
    return Colors.red;
  }

  int _getXpEarned() {
    if (widget.accuracy >= 0.9) return 30;
    if (widget.accuracy >= 0.7) return 20;
    if (widget.accuracy >= 0.5) return 10;
    return 5;
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: widget.themeColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
