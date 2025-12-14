import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Results screen for Puzzle Peaks with mountain climbing theme
class LogicResultsScreen extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int xpEarned;
  final String skillName;
  final VoidCallback onContinue;
  final VoidCallback? onRetry;

  const LogicResultsScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.xpEarned,
    required this.skillName,
    required this.onContinue,
    this.onRetry,
  });

  @override
  State<LogicResultsScreen> createState() => _LogicResultsScreenState();
}

class _LogicResultsScreenState extends State<LogicResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _mountainController;
  late AnimationController _flagController;
  late AnimationController _scoreController;
  late Animation<double> _mountainClimbAnimation;
  late Animation<double> _flagWaveAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();

    _mountainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _mountainClimbAnimation = CurvedAnimation(
      parent: _mountainController,
      curve: Curves.easeOutCubic,
    );

    _flagController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _flagWaveAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _flagController, curve: Curves.easeInOut),
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.elasticOut,
    );

    _mountainController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _scoreController.forward();
    });
  }

  @override
  void dispose() {
    _mountainController.dispose();
    _flagController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  double get _percentage => widget.correctAnswers / widget.totalQuestions;
  bool get _isPerfect => widget.correctAnswers == widget.totalQuestions;

  int get _starsEarned {
    if (_percentage >= 1.0) return 3;
    if (_percentage >= 0.7) return 2;
    if (_percentage >= 0.4) return 1;
    return 0;
  }

  String get _titleText {
    if (_percentage >= 1.0) return '⛰️ Summit Master! ⛰️';
    if (_percentage >= 0.7) return '🏔️ Great Climber!';
    if (_percentage >= 0.4) return '🧗 Good Progress!';
    return '💪 Keep Climbing!';
  }

  String get _messageText {
    if (_percentage >= 1.0) return 'You conquered the peak! Your logic is unbeatable!';
    if (_percentage >= 0.7) return 'Amazing climb! You\'re getting close to the summit!';
    if (_percentage >= 0.4) return 'Good effort! Every step gets you closer!';
    return 'The mountain awaits! Keep practicing your logic skills!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF2C3E50),
              Color(0xFF34495E),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Mountain background with climb animation
              AnimatedBuilder(
                animation: _mountainClimbAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: MediaQuery.of(context).size,
                    painter: _MountainResultsPainter(
                      _mountainClimbAnimation.value,
                      _percentage,
                    ),
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
                      // Flag at summit
                      _buildSummitFlag(),

                      const SizedBox(height: 24),

                      // Title
                      AnimatedBuilder(
                        animation: _scoreAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scoreAnimation.value.clamp(0.0, 1.0),
                            child: child,
                          );
                        },
                        child: Text(
                          _titleText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.teal, blurRadius: 20),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Score card
                      _buildScoreCard(),

                      const SizedBox(height: 24),

                      // Stars display
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

                      // XP earned
                      _buildXpDisplay(),

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

  Widget _buildSummitFlag() {
    return AnimatedBuilder(
      animation: _flagWaveAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _isPerfect ? _flagWaveAnimation.value : 0,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.teal.shade300,
                  Colors.teal.shade700,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _isPerfect ? '🏆' : '🚩',
                style: const TextStyle(fontSize: 60),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCard() {
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scoreAnimation.value.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.shade800.withValues(alpha: 0.9),
              Colors.blueGrey.shade900.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.teal.withValues(alpha: 0.5),
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
            Row(
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
            const SizedBox(height: 8),
            // Progress bar showing climb height
            Container(
              width: 200,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _percentage * _scoreAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal, Colors.tealAccent],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(_percentage * 100).round()}% of peak reached',
              style: TextStyle(
                color: _percentage >= 0.7 ? Colors.tealAccent : Colors.orange,
                fontSize: 14,
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
      animation: _scoreAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isEarned = index < _starsEarned;
            final delay = index * 0.3;
            final animValue =
                ((_scoreAnimation.value - delay) / 0.7).clamp(0.0, 1.0);

            return Transform.scale(
              scale: animValue,
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
    return AnimatedBuilder(
      animation: _scoreAnimation,
      builder: (context, child) {
        final displayXp = (widget.xpEarned * _scoreAnimation.value).round();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.teal.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚡', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                '+$displayXp XP',
                style: const TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.teal.withValues(alpha: 0.5),
            ),
            child: const Row(
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
        if (widget.onRetry != null && _percentage < 1.0) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onRetry,
            child: const Text(
              '🔄 Climb Again',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ],
    );
  }
}

class _MountainResultsPainter extends CustomPainter {
  final double animProgress;
  final double climbProgress;

  _MountainResultsPainter(this.animProgress, this.climbProgress);

  @override
  void paint(Canvas canvas, Size size) {
    // Back mountains
    final backPaint = Paint()
      ..color = const Color(0xFF1A2634)
      ..style = PaintingStyle.fill;

    final backPath = Path()
      ..moveTo(0, size.height * 0.8)
      ..lineTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.4, size.height * 0.75)
      ..lineTo(size.width * 0.5, size.height * 0.45)
      ..lineTo(size.width * 0.65, size.height * 0.6)
      ..lineTo(size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(backPath, backPaint);

    // Draw climb path
    final pathPaint = Paint()
      ..color = Colors.tealAccent.withValues(alpha: 0.6 * animProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final climbPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.7,
        size.width * 0.35,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.55,
        size.width * 0.5,
        size.height * 0.48,
      );

    // Only draw portion of path based on climb progress
    final pathMetrics = climbPath.computeMetrics().first;
    final extractPath =
        pathMetrics.extractPath(0, pathMetrics.length * climbProgress * animProgress);
    canvas.drawPath(extractPath, pathPaint);

    // Climber position
    if (animProgress > 0.3) {
      final climbPoint = pathMetrics
          .getTangentForOffset(pathMetrics.length * climbProgress * math.min(1.0, animProgress * 1.2))
          ?.position;

      if (climbPoint != null) {
        final climberPaint = Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.fill;

        canvas.drawCircle(climbPoint, 8, climberPaint);
      }
    }

    // Snow on peaks
    final snowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final snow1 = Path()
      ..moveTo(size.width * 0.5, size.height * 0.45)
      ..lineTo(size.width * 0.45, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.5)
      ..close();
    canvas.drawPath(snow1, snowPaint);

    final snow2 = Path()
      ..moveTo(size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width * 0.75, size.height * 0.55)
      ..lineTo(size.width * 0.85, size.height * 0.55)
      ..close();
    canvas.drawPath(snow2, snowPaint);
  }

  @override
  bool shouldRepaint(covariant _MountainResultsPainter oldDelegate) {
    return oldDelegate.animProgress != animProgress ||
        oldDelegate.climbProgress != climbProgress;
  }
}
