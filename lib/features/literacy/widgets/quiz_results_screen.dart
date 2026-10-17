import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/components/reward_reveal.dart';
import 'package:brightbound_adventures/ui/components/session_completion.dart';
import 'package:brightbound_adventures/ui/widgets/branded_back_button.dart';
import 'package:brightbound_adventures/ui/widgets/juicy_button.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// Results screen shown after completing a quiz.
///
/// This is the single place a literacy quest applies its rewards: it runs
/// the shared `completeSession` orchestration (evidence updates + exactly
/// one `RewardTransactionService.apply()` per [sessionId]), then the earned
/// [SessionCompletion] is presented by [RewardReveal]. Rebuilding, resuming,
/// or revisiting this screen replays the same result instead of re-awarding
/// it.
class QuizResultsScreen extends StatefulWidget {
  final String skillName;
  final String skillId;

  /// Stable identity for this completion; the reward transaction is keyed
  /// on it, so one session awards exactly once.
  final String sessionId;

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
    required this.sessionId,
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

  SessionCompletion? _completion;
  bool _applying = true;
  Object? _error;

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
      if (mounted) _scoreController.forward();
    });

    // Kick off after the first frame so progress/reward work never runs
    // during build, and so the child sees an honest "packing your reward"
    // beat rather than a frozen screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _processResults();
    });
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _processResults() async {
    setState(() {
      _applying = true;
      _error = null;
    });

    try {
      // The single shared orchestration path: evidence updates, then the
      // one idempotent reward transaction, then presentation data.
      final completion = await completeSession(
        context,
        sessionId: widget.sessionId,
        skillId: widget.skillId,
        skillName: widget.skillName,
        accuracy: widget.accuracy,
        correctAnswers: widget.correctAnswers,
        totalQuestions: widget.totalQuestions,
        hintsUsed: widget.hintsUsed,
        accent: widget.themeColor,
        zoneId: widget.zoneId,
        zoneName: widget.zoneName,
      );

      setState(() {
        _completion = completion;
        _applying = false;
      });
    } catch (error) {
      // Never pretend the reward landed: show a real error with a retry,
      // which is safe because the transaction is idempotent.
      setState(() {
        _error = error;
        _applying = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final world = WorldTokens.fromColor(widget.themeColor);
    final showCelebration = widget.accuracy >= 0.85;
    final completion = _completion;

    return Scaffold(
      body: Stack(
        children: [
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
          if (showCelebration)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _celebrationController,
                  builder: (context, _) {
                    if (_celebrationController.value < 0.05) {
                      return const SizedBox.shrink();
                    }
                    return CustomPaint(
                      painter: _ConfettiPainter(
                        progress: _celebrationController.value,
                        colors: [
                          widget.themeColor,
                          Colors.amber,
                          Colors.pink.shade300,
                          Colors.lightGreenAccent.shade400,
                          Colors.deepPurpleAccent.shade100,
                        ],
                        seed: widget.totalQuestions,
                      ),
                    );
                  },
                ),
              ),
            ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ScaleTransition(
                    scale: _scoreAnimation,
                    child: Text(
                      _performanceEmoji,
                      style: const TextStyle(fontSize: 72),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    header: true,
                    child: Text(
                      'Quest complete!',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: widget.themeColor,
                                fontFamily: AppTheme.fontPrimary,
                              ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.skillName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildScoreCard(context),
                  const SizedBox(height: 20),
                  if (_applying)
                    RewardApplyingCard(accent: widget.themeColor)
                  else if (_error != null)
                    RewardErrorCard(onRetry: _processResults)
                  else if (completion != null)
                    RewardReveal(
                      result: completion.reward,
                      breakdown: completion.breakdown,
                      starBalance: completion.starBalance,
                      levelProgressBefore: completion.levelProgressBefore,
                      levelProgressAfter: completion.levelProgressAfter,
                      accent: widget.themeColor,
                      skillName: widget.skillName,
                      skillAccuracyBefore: completion.skillAccuracyBefore,
                      skillAccuracyAfter: completion.skillAccuracyAfter,
                      recommendation: completion.recommendation,
                      unlockNames: completion.unlockNames,
                      onBackToMap: () => backToWorldMap(context),
                    ),
                  if (widget.guardianMessage != null) ...[
                    const SizedBox(height: 20),
                    _GuardianMessageBanner(
                      emoji: widget.guardianEmoji ?? '✨',
                      message: widget.guardianMessage!,
                      themeColor: widget.themeColor,
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: BrandedBackButton(
                          label: 'Back to Zone',
                          onPressed: widget.onExit,
                          backgroundColor: Colors.grey.shade400,
                          // Grey400 + white measured ~1.8:1; derive the ink.
                          foregroundColor: InkTokens.on(Colors.grey.shade400),
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
                          // Adaptive ink (JuicyButton): themeColor varies per
                          // subject and pale accents can't carry white.
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

  Widget _buildScoreCard(BuildContext context) {
    return Container(
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedCounterText(
                  targetValue: (widget.accuracy * 100).round(),
                  suffix: '%',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: widget.themeColor,
                    fontFamily: AppTheme.fontPrimary,
                  ),
                ),
              ],
            ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                value: '${widget.correctAnswers} / ${widget.totalQuestions}',
                label: 'Correct',
              ),
              Container(width: 1, height: 48, color: Colors.grey.shade200),
              _buildStatItem(
                icon: Icons.lightbulb_outline_rounded,
                color: Colors.amber.shade700,
                value: '${widget.hintsUsed}',
                label: 'Hints',
              ),
              Container(width: 1, height: 48, color: Colors.grey.shade200),
              _buildStatItem(
                icon: Icons.bolt_rounded,
                color: widget.themeColor,
                value: '+${_completion?.breakdown.totalXp ?? 0}',
                label: 'XP',
              ),
            ],
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
              // 18 px bold is normal-size text (AA 4.5:1): the accent itself
              // fails on white for bright tokens (success ≈ 2.2:1, amber ≈
              // 3.1:1, warm zone colours ≈ 3.0–4.0:1). Ink derives from the
              // tint instead; the icon keeps the accent.
              color: InkTokens.onTint(color),
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

// ─────────────────────────────────────────────────────────────────────────────
// Lightweight confetti painter for the results celebration
// ─────────────────────────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  final int seed;

  _ConfettiPainter(
      {required this.progress, required this.colors, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    for (int i = 0; i < 60; i++) {
      final c = colors[i % colors.length];
      final px = rng.nextDouble();
      final py = -rng.nextDouble() * 0.3;
      final speed = 0.4 + rng.nextDouble() * 0.6;
      final sz = 6.0 + rng.nextDouble() * 8.0;
      final angle = rng.nextDouble() * math.pi * 2;
      final spin = (rng.nextDouble() - 0.5) * 8;

      final t = (progress * speed).clamp(0.0, 1.0);
      final fade = (1.0 - (t * 1.6).clamp(0.0, 1.0));
      if (fade <= 0) continue;

      final cx = px * size.width;
      final cy = (py + t * 1.5) * size.height;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle + spin * t);
      final paint = Paint()
        ..color = c.withValues(alpha: fade)
        ..style = PaintingStyle.fill;
      if (i % 3 == 0) {
        canvas.drawCircle(Offset.zero, sz * 0.4, paint);
      } else {
        canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: sz, height: sz * 0.5),
            paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
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
