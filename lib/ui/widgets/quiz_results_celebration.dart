import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Celebration overlay shown after completing a quiz
class QuizResultsCelebration extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int starsEarned;
  final int xpEarned;
  final VoidCallback onContinue;
  final bool isNewBest;

  const QuizResultsCelebration({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.starsEarned,
    required this.xpEarned,
    required this.onContinue,
    this.isNewBest = false,
  });

  @override
  State<QuizResultsCelebration> createState() => _QuizResultsCelebrationState();
}

class _QuizResultsCelebrationState extends State<QuizResultsCelebration>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _confettiController;
  late AnimationController _starController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final List<_ConfettiPiece> _confetti = [];

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Generate confetti if score is good
    if (_getScorePercentage() >= 70) {
      _generateConfetti();
      _confettiController.forward();
    }

    _entranceController.forward();
    _starController.forward();
  }

  void _generateConfetti() {
    final random = math.Random();
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
    ];

    for (int i = 0; i < 50; i++) {
      _confetti.add(_ConfettiPiece(
        x: random.nextDouble(),
        startY: -0.1 - random.nextDouble() * 0.2,
        vx: (random.nextDouble() - 0.5) * 0.3,
        vy: 0.3 + random.nextDouble() * 0.4,
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 8,
        color: colors[random.nextInt(colors.length)],
        size: 8 + random.nextDouble() * 8,
        shape: random.nextInt(3), // 0: square, 1: circle, 2: triangle
      ));
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _confettiController.dispose();
    _starController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  int _getScorePercentage() {
    return ((widget.correctAnswers / widget.totalQuestions) * 100).round();
  }

  String _getResultMessage() {
    final percentage = _getScorePercentage();
    if (percentage == 100) return 'PERFECT! 🌟';
    if (percentage >= 90) return 'AMAZING! 🎉';
    if (percentage >= 80) return 'GREAT JOB! 👏';
    if (percentage >= 70) return 'WELL DONE! 😊';
    if (percentage >= 50) return 'GOOD TRY! 💪';
    return 'KEEP PRACTICING! 📚';
  }

  Color _getResultColor() {
    final percentage = _getScorePercentage();
    if (percentage >= 90) return Colors.amber;
    if (percentage >= 70) return Colors.green;
    if (percentage >= 50) return Colors.blue;
    return Colors.orange;
  }

  String _getResultEmoji() {
    final percentage = _getScorePercentage();
    if (percentage == 100) return '🏆';
    if (percentage >= 90) return '🌟';
    if (percentage >= 80) return '⭐';
    if (percentage >= 70) return '😊';
    if (percentage >= 50) return '👍';
    return '💪';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entranceController,
        _confettiController,
        _starController,
        _pulseController,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            // Background overlay
            Opacity(
              opacity: _fadeAnimation.value * 0.85,
              child: Container(color: Colors.black),
            ),

            // Confetti layer
            ..._confetti.map((piece) => _buildConfettiPiece(piece)),

            // Main content
            Center(
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: _buildResultCard(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfettiPiece(_ConfettiPiece piece) {
    final progress = _confettiController.value;
    final x = piece.x + piece.vx * progress;
    final y = piece.startY + piece.vy * progress;
    final rotation = piece.rotation + piece.rotationSpeed * progress;
    final opacity = y < 1.1 ? 1.0 : 0.0;

    return Positioned(
      left: x * MediaQuery.of(context).size.width,
      top: y * MediaQuery.of(context).size.height,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rotation,
          child: _buildConfettiShape(piece),
        ),
      ),
    );
  }

  Widget _buildConfettiShape(_ConfettiPiece piece) {
    switch (piece.shape) {
      case 0: // Square
        return Container(
          width: piece.size,
          height: piece.size,
          color: piece.color,
        );
      case 1: // Circle
        return Container(
          width: piece.size,
          height: piece.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: piece.color,
          ),
        );
      case 2: // Triangle-ish (rotated square)
        return Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: piece.size * 0.8,
            height: piece.size * 0.8,
            color: piece.color,
          ),
        );
      default:
        return Container(
          width: piece.size,
          height: piece.size,
          color: piece.color,
        );
    }
  }

  Widget _buildResultCard() {
    final resultColor = _getResultColor();

    return Container(
      width: 340,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: resultColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Result emoji with pulse
          Transform.scale(
            scale: 1 + _pulseController.value * 0.1,
            child: Text(
              _getResultEmoji(),
              style: const TextStyle(fontSize: 64),
            ),
          ),

          const SizedBox(height: 8),

          // Result message
          Text(
            _getResultMessage(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: resultColor,
            ),
          ),

          if (widget.isNewBest) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🏆', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 4),
                  Text(
                    'NEW BEST!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Score display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreStat(
                  '${widget.correctAnswers}/${widget.totalQuestions}',
                  'Correct',
                  Colors.blue,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildScoreStat(
                  '${_getScorePercentage()}%',
                  'Score',
                  resultColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stars earned
          _buildStarsDisplay(),

          const SizedBox(height: 12),

          // XP earned
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.blue.shade400],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('✨', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '+${widget.xpEarned} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: resultColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
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

  Widget _buildStarsDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isEarned = index < widget.starsEarned;
        final delay = index * 0.2;
        final progress =
            (_starController.value - delay).clamp(0.0, 1.0) / (1.0 - delay);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Transform.scale(
            scale: isEarned
                ? Curves.elasticOut.transform(progress.clamp(0.0, 1.0))
                : 1.0,
            child: Text(
              isEarned ? '⭐' : '☆',
              style: TextStyle(
                fontSize: 40,
                color: isEarned ? null : Colors.grey[400],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double startY;
  final double vx;
  final double vy;
  final double rotation;
  final double rotationSpeed;
  final Color color;
  final double size;
  final int shape;

  _ConfettiPiece({
    required this.x,
    required this.startY,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
    required this.shape,
  });
}

/// Helper to show the celebration overlay
class QuizResultsOverlay {
  static void show(
    BuildContext context, {
    required int correctAnswers,
    required int totalQuestions,
    required int starsEarned,
    required int xpEarned,
    required VoidCallback onContinue,
    bool isNewBest = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => QuizResultsCelebration(
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        starsEarned: starsEarned,
        xpEarned: xpEarned,
        onContinue: () {
          Navigator.pop(context);
          onContinue();
        },
        isNewBest: isNewBest,
      ),
    );
  }
}
