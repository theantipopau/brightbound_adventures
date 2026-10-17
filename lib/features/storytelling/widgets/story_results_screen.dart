import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:brightbound_adventures/core/models/quest_session_summary.dart';
import 'package:brightbound_adventures/ui/components/reward_reveal.dart';
import 'package:brightbound_adventures/ui/components/session_completion.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// Results screen for Story Springs with a magical book theme.
///
/// This is the single place a story quest applies its rewards: it runs
/// the shared `completeSession` orchestration (evidence updates + exactly
/// one `RewardTransactionService.apply()` per [sessionId]), then the earned
/// [SessionCompletion] is presented by [RewardReveal]. Rebuilding, resuming,
/// or revisiting this screen replays the same result instead of re-awarding
/// it.
class StoryResultsScreen extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final String skillName;

  /// Stable identity for this completion; the reward transaction is keyed
  /// on it, so one session awards exactly once.
  final String sessionId;

  /// Skill id for evidence updates and the recommendation engine.
  final String skillId;

  /// Zone context, for zone mastery and "what to do next".
  final String? zoneId;
  final String? zoneName;

  /// Session-history entry for zones whose games don't record their own.
  final QuestSessionSummary? history;

  /// Hints opened this session — the reward breakdown's effort bonus
  /// depends on it, so it must not default silently to a perfect run.
  final int hintsUsed;

  final VoidCallback onContinue;
  final VoidCallback? onRetry;

  const StoryResultsScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.skillName,
    required this.sessionId,
    required this.skillId,
    this.zoneId,
    this.zoneName,
    this.history,
    this.hintsUsed = 0,
    required this.onContinue,
    this.onRetry,
  });

  @override
  State<StoryResultsScreen> createState() => _StoryResultsScreenState();
}

class _StoryResultsScreenState extends State<StoryResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _bookController;
  late AnimationController _starsController;
  late AnimationController _confettiController;
  late Animation<double> _bookAnimation;
  late Animation<double> _starsAnimation;
  bool _reduceMotion = false;
  bool _motionSynced = false;

  SessionCompletion? _completion;
  bool _applying = true;
  Object? _error;

  @override
  void initState() {
    super.initState();

    _bookController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bookAnimation = CurvedAnimation(
      parent: _bookController,
      curve: Curves.elasticOut,
    );

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _starsAnimation = CurvedAnimation(
      parent: _starsController,
      curve: Curves.easeOut,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Start animations
    _bookController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_reduceMotion) _starsController.forward();
    });

    if (_isPerfect) {
      _confettiController.forward();
    }

    // Kick off after the first frame so reward work never runs during build,
    // and so the child sees an honest "packing your reward" beat rather than
    // a frozen screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _processResults();
    });
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
        accuracy: _percentage,
        correctAnswers: widget.correctAnswers,
        totalQuestions: widget.totalQuestions,
        hintsUsed: widget.hintsUsed,
        accent: _accent,
        zoneId: widget.zoneId,
        zoneName: widget.zoneName,
        history: widget.history,
      );

      if (!mounted) return;
      setState(() {
        _completion = completion;
        _applying = false;
      });
    } catch (error) {
      // Never pretend the reward landed: show a real error with a retry,
      // which is safe because the transaction is idempotent.
      if (!mounted) return;
      setState(() {
        _error = error;
        _applying = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (_motionSynced && _reduceMotion == reduceMotion) return;
    _motionSynced = true;
    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _bookController.value = 1;
      _starsController.value = 1;
      _confettiController.value = _isPerfect ? 1 : 0;
    } else {
      if (_bookController.value == 0) {
        _bookController.forward();
      }
      if (_starsController.value == 0) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_reduceMotion) _starsController.forward();
        });
      }
      if (_isPerfect && _confettiController.value == 0) {
        _confettiController.forward();
      }
    }
  }

  @override
  void dispose() {
    _bookController.dispose();
    _starsController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  bool get _isPerfect => widget.correctAnswers == widget.totalQuestions;
  double get _percentage => widget.totalQuestions <= 0
      ? 0.0
      : widget.correctAnswers / widget.totalQuestions;

  /// Zone accent, so the reveal matches the book theme. Shared with the
  /// action buttons below rather than restated as a second literal.
  Color get _accent => Colors.purple;

  int get _starsEarned {
    if (_percentage >= 1.0) return 3;
    if (_percentage >= 0.7) return 2;
    if (_percentage >= 0.4) return 1;
    return 0;
  }

  String get _titleText {
    if (_percentage >= 1.0) return '✨ Story Master! ✨';
    if (_percentage >= 0.7) return '📖 Great Storyteller!';
    if (_percentage >= 0.4) return '📚 Good Effort!';
    return '💪 Keep Practicing!';
  }

  String get _messageText {
    if (_percentage >= 1.0) {
      return 'Perfect! Your storytelling skills are legendary!';
    }
    if (_percentage >= 0.7) {
      return 'Amazing work! You\'re becoming a great writer!';
    }
    if (_percentage >= 0.4) {
      return 'Good job! Practice makes perfect!';
    }
    return 'Every author started somewhere. Keep reading and writing!';
  }

  @override
  Widget build(BuildContext context) {
    final completion = _completion;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF2d132c),
              Color(0xFF16213e),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background floating books
              ..._buildFloatingBooks(),

              // Confetti for perfect score
              if (_isPerfect)
                AnimatedBuilder(
                  animation: _confettiController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: _ConfettiPainter(_confettiController.value),
                    );
                  },
                ),

              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated book trophy
                      _buildBookTrophy(),

                      const SizedBox(height: 24),

                      // Title
                      AnimatedBuilder(
                        animation: _bookAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _bookAnimation.value.clamp(0.0, 1.0),
                            child: child,
                          );
                        },
                        child: Text(
                          _titleText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.purple,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Score card
                      _buildScoreCard(),

                      const SizedBox(height: 24),

                      // Stars earned
                      _buildStarsDisplay(),

                      const SizedBox(height: 16),

                      // Message
                      Text(
                        _messageText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // XP earned (from the shared breakdown once the
                      // transaction lands — never a private formula)
                      _buildXpDisplay(),

                      const SizedBox(height: 20),

                      // The one choreographed reward moment
                      if (_applying)
                        RewardApplyingCard(accent: _accent)
                      else if (_error != null)
                        RewardErrorCard(onRetry: _processResults)
                      else if (completion != null)
                        RewardReveal(
                          result: completion.reward,
                          breakdown: completion.breakdown,
                          starBalance: completion.starBalance,
                          levelProgressBefore: completion.levelProgressBefore,
                          levelProgressAfter: completion.levelProgressAfter,
                          accent: _accent,
                          skillName: widget.skillName,
                          skillAccuracyBefore: completion.skillAccuracyBefore,
                          skillAccuracyAfter: completion.skillAccuracyAfter,
                          recommendation: completion.recommendation,
                          unlockNames: completion.unlockNames,
                          onBackToMap: () => backToWorldMap(context),
                        ),

                      const SizedBox(height: 32),

                      // Buttons
                      _buildButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFloatingBooks() {
    final books = ['📚', '📖', '📕', '📗', '📘', '📙', '✏️', '🖊️'];
    final random = math.Random(42);

    return List.generate(10, (index) {
      final x = random.nextDouble();
      final y = random.nextDouble();
      final size = 20 + random.nextDouble() * 20;

      return AnimatedBuilder(
        animation: _starsController,
        builder: (context, child) {
          final offset =
              math.sin((_starsController.value * math.pi * 2) + index) * 10;
          return Positioned(
            left: MediaQuery.of(context).size.width * x,
            top: MediaQuery.of(context).size.height * y + offset,
            child: Opacity(
              opacity: 0.2,
              child: Text(
                books[index % books.length],
                style: TextStyle(fontSize: size),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildBookTrophy() {
    return AnimatedBuilder(
      animation: _bookAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bookAnimation.value.clamp(0.0, 1.2),
          child: Transform.rotate(
            angle: (1 - _bookAnimation.value.clamp(0.0, 1.0)) * 0.5,
            child: child,
          ),
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.purple.shade300,
              Colors.purple.shade700,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Text(
            _isPerfect ? '👑' : '📖',
            style: const TextStyle(fontSize: 70),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return AnimatedBuilder(
      animation: _starsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _starsAnimation.value.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade900.withValues(alpha: 0.8),
              Colors.indigo.shade900.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.purple.shade300.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              widget.skillName,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${widget.correctAnswers}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  ' / ${widget.totalQuestions}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_percentage * 100).round()}% correct',
              style: TextStyle(
                color: _percentage >= 0.7 ? Colors.greenAccent : Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarsDisplay() {
    return AnimatedBuilder(
      animation: _starsAnimation,
      builder: (context, child) {
        final visibleStars = (_starsAnimation.value * 3).ceil();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isEarned = index < _starsEarned;
            final isVisible = index < visibleStars;

            return Transform.scale(
              scale: isVisible ? 1.0 : 0.0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  isEarned ? Icons.star : Icons.star_border,
                  color: isEarned ? Colors.amber : Colors.white30,
                  size: 48,
                  shadows: isEarned
                      ? [
                          Shadow(
                            color: Colors.amber.withValues(alpha: 0.8),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildXpDisplay() {
    final totalXp = _completion?.breakdown.totalXp ?? 0;
    return AnimatedBuilder(
      animation: _starsAnimation,
      builder: (context, child) {
        final displayXp = (totalXp * _starsAnimation.value).round();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✨', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  '+$displayXp XP',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: InkTokens.on(_accent),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.purple.withValues(alpha: 0.5),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ),
        if (widget.onRetry != null && _percentage < 1.0) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: widget.onRetry,
            icon: SizedBox(
              width: 22,
              height: 22,
              child: Image.asset('assets/images/potion.webp',
                  cacheWidth: 128, fit: BoxFit.contain),
            ),
            label: const Text(
              'Try Again',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles = [];

  _ConfettiPainter(this.progress) {
    final random = math.Random(42);
    final colors = [
      Colors.purple,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.green,
    ];

    for (int i = 0; i < 50; i++) {
      particles.add(_ConfettiParticle(
        x: random.nextDouble(),
        startY: -0.1 - random.nextDouble() * 0.3,
        speed: 0.5 + random.nextDouble() * 0.5,
        wobble: random.nextDouble() * 2 * math.pi,
        wobbleSpeed: 2 + random.nextDouble() * 3,
        color: colors[random.nextInt(colors.length)],
        rotation: random.nextDouble() * 2 * math.pi,
        size: 8 + random.nextDouble() * 8,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y = particle.startY + (progress * particle.speed * 1.5);
      if (y > 1.1) continue;

      final wobbleOffset =
          math.sin(progress * particle.wobbleSpeed + particle.wobble) * 0.05;
      final x = particle.x + wobbleOffset;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: 1.0 - progress * 0.5)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(particle.rotation + progress * 3);

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  // Particles are deterministic (seeded Random(42)): only progress
  // changes the painting, so only repaint when it moves. The old
  // unconditional `=> true` repainted on every parent rebuild.
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ConfettiParticle {
  final double x;
  final double startY;
  final double speed;
  final double wobble;
  final double wobbleSpeed;
  final Color color;
  final double rotation;
  final double size;

  _ConfettiParticle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.wobble,
    required this.wobbleSpeed,
    required this.color,
    required this.rotation,
    required this.size,
  });
}
