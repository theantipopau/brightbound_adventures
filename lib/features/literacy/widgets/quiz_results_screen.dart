import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/widgets/achievement_notification.dart';
import 'package:brightbound_adventures/ui/widgets/branded_back_button.dart';
import 'package:brightbound_adventures/ui/widgets/juicy_button.dart';
import 'package:brightbound_adventures/ui/widgets/zone_mastered_celebration.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// Results screen shown after completing a quiz
class QuizResultsScreen extends StatefulWidget {
  final String skillName;
  final String skillId;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final int hintsUsed;
  final Color themeColor;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onExit;
  /// Optional message from the zone guardian celebrating the skill completion.
  final String? guardianMessage;
  /// Optional guardian emoji for the banner.
  final String? guardianEmoji;
  /// Zone id used to check for zone mastery after the session.
  final String? zoneId;
  /// Display name of the zone (e.g. 'Word Woods').
  final String? zoneName;

  const QuizResultsScreen({
    super.key,
    required this.skillName,
    required this.skillId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    this.hintsUsed = 0,
    this.themeColor = AppColors.wordWoodsColor,
    this.onPlayAgain,
    this.onExit,
    this.guardianMessage,
    this.guardianEmoji,
    this.zoneId,
    this.zoneName,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  int _xpAwarded = 0;
  bool _leveledUp = false;
  int? _previousLevel;

  @override
  void initState() {
    super.initState();

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutBack,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreController.forward();
    });

    _processResults();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _processResults() async {
    // Calculate XP based on performance
    _xpAwarded = (widget.accuracy * 100).round();
    if (widget.accuracy >= 0.85) {
      _xpAwarded += 25; // Bonus for mastery-level performance
    }
    if (widget.hintsUsed == 0 && widget.accuracy >= 0.7) {
      _xpAwarded += 10; // Bonus for no hints
    }

    // Update skill progress
    final skillProvider = context.read<SkillProvider>();
    skillProvider.updateSkillProgress(
      skillId: widget.skillId,
      sessionAccuracy: widget.accuracy,
      sessionHints: widget.hintsUsed,
    );

    // Schedule spaced repetition review
    context.read<SpacedRepetitionService>().recordSession(
      skillId: widget.skillId,
      accuracy: widget.accuracy,
    );

    // Check if this session completed the whole zone
    checkAndShowZoneMastered(
      context,
      skillProvider,
      zoneId: widget.zoneId,
      zoneName: widget.zoneName,
      themeColor: widget.themeColor,
    );

    // Award XP
    final avatarProvider = context.read<AvatarProvider>();
    if (avatarProvider.hasAvatar) {
      _previousLevel = avatarProvider.avatar!.level;
      avatarProvider.addExperience(_xpAwarded);
      _leveledUp = avatarProvider.avatar!.level > _previousLevel!;
    }

    // Award stars
    final shopService = ShopService();
    await shopService.awardStarsForActivity(
      score: widget.correctAnswers,
      maxScore: widget.totalQuestions,
      accuracy: widget.accuracy,
    );

    // Track achievements
    final achievementService = AchievementService();
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

  String get _performanceMessage {
    if (widget.accuracy >= 0.95) return 'Perfect! You\'re a star! ⭐';
    if (widget.accuracy >= 0.85) return 'Excellent work! 🎉';
    if (widget.accuracy >= 0.70) return 'Good job! Keep practicing! 💪';
    if (widget.accuracy >= 0.50) return 'Nice try! You\'re improving! 📈';
    return 'Keep learning! You\'ll get there! 🌱';
  }

  String get _performanceEmoji {
    if (widget.accuracy >= 0.95) return '🏆';
    if (widget.accuracy >= 0.85) return '🌟';
    if (widget.accuracy >= 0.70) return '👍';
    if (widget.accuracy >= 0.50) return '💡';
    return '📚';
  }

  int get _starCount {
    if (widget.accuracy >= 0.95) return 3;
    if (widget.accuracy >= 0.70) return 2;
    if (widget.accuracy >= 0.40) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final world = WorldTokens.fromColor(widget.themeColor);
    return Scaffold(
      body: Stack(
        children: [
          // World-themed gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    world.skyGradient.first,
                    world.skyGradient.last,
                    Colors.white,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Performance emoji with scale entrance
                  ScaleTransition(
                    scale: _scoreAnimation,
                    child: Text(
                      _performanceEmoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    'Quiz Complete!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.themeColor,
                          fontFamily: AppTheme.fontPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.skillName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Stars with staggered entrance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: AnimatedBuilder(
                          animation: _celebrationController,
                          builder: (context, child) {
                            final delay = index * 0.22;
                            final progress =
                                ((_celebrationController.value - delay) /
                                        (1 - delay))
                                    .clamp(0.0, 1.0);
                            final earned = index < _starCount;
                            return Transform.scale(
                              scale: earned
                                  ? (0.3 +
                                      0.7 *
                                          Curves.elasticOut.transform(progress))
                                  : 0.75,
                              child: Icon(
                                earned
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 52,
                                color: earned
                                    ? Colors.amber.shade400
                                    : Colors.grey.shade300,
                                shadows: earned
                                    ? [
                                        Shadow(
                                          color: Colors.amber
                                              .withValues(alpha: 0.5),
                                          blurRadius: 12,
                                        )
                                      ]
                                    : null,
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Animated score card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppBorders.xl),
                      border: Border.all(
                        color: widget.themeColor.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                      boxShadow: AppShadows.lg(widget.themeColor),
                    ),
                    child: Column(
                      children: [
                        // Big animated accuracy
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedCounterText(
                              targetValue: (widget.accuracy * 100).round(),
                              suffix: '%',
                              style: TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: widget.themeColor,
                                fontFamily: AppTheme.fontPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _performanceMessage,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade100, thickness: 1.5),
                        const SizedBox(height: 16),

                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              icon: Icons.check_circle_outline_rounded,
                              color: AppColors.success,
                              value:
                                  '${widget.correctAnswers} / ${widget.totalQuestions}',
                              label: 'Correct',
                            ),
                            Container(
                                width: 1,
                                height: 48,
                                color: Colors.grey.shade200),
                            _buildStatItem(
                              icon: Icons.lightbulb_outline_rounded,
                              color: Colors.amber.shade700,
                              value: '${widget.hintsUsed}',
                              label: 'Hints',
                            ),
                            Container(
                                width: 1,
                                height: 48,
                                color: Colors.grey.shade200),
                            _buildStatItem(
                              icon: Icons.bolt_rounded,
                              color: widget.themeColor,
                              value: '+$_xpAwarded',
                              label: 'XP',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Level up notification
                  if (_leveledUp) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppGradients.gold,
                        borderRadius: BorderRadius.circular(AppBorders.lg),
                        boxShadow:
                            AppShadows.glow(Colors.amber, intensity: 0.4),
                      ),
                      child: Row(
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'LEVEL UP!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Consumer<AvatarProvider>(
                                  builder: (context, provider, _) => Text(
                                    'You reached Level ${provider.avatar?.level ?? 0}!',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text('🌟', style: TextStyle(fontSize: 32)),
                        ],
                      ),
                    ),
                  ],

                  // Guardian message banner
                  if (widget.guardianMessage != null) ...[                    const SizedBox(height: 20),
                    _GuardianMessageBanner(
                      emoji: widget.guardianEmoji ?? '✨',
                      message: widget.guardianMessage!,
                      themeColor: widget.themeColor,
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: BrandedBackButton(
                          label: 'Back to Zone',
                          onPressed: widget.onExit,
                          backgroundColor: Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          borderColor: Colors.grey.shade500,
                          tokenBackgroundColor:
                              Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 2,
                        child: JuicyButton(
                          label: 'Play Again',
                          emoji: '🔄',
                          onPressed: widget.onPlayAgain,
                          gradient: LinearGradient(
                            colors: [
                              widget.themeColor,
                              widget.themeColor.withValues(alpha: 0.85)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          textColor: Colors.white,
                          shimmer: widget.accuracy >= 0.85,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small themed banner displaying a message from the zone guardian.
class _GuardianMessageBanner extends StatelessWidget {
  final String emoji;
  final String message;
  final Color themeColor;

  const _GuardianMessageBanner({
    required this.emoji,
    required this.message,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
