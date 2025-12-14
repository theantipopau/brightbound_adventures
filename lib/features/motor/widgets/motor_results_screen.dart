import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Results screen for Adventure Arena with arena/sports theme
class MotorResultsScreen extends StatefulWidget {
  final int targetsHit;
  final int totalTargets;
  final int score;
  final Duration avgReactionTime;
  final double accuracy;
  final int xpEarned;
  final String skillName;
  final VoidCallback onContinue;
  final VoidCallback? onRetry;

  const MotorResultsScreen({
    super.key,
    required this.targetsHit,
    required this.totalTargets,
    required this.score,
    required this.avgReactionTime,
    required this.accuracy,
    required this.xpEarned,
    required this.skillName,
    required this.onContinue,
    this.onRetry,
  });

  @override
  State<MotorResultsScreen> createState() => _MotorResultsScreenState();
}

class _MotorResultsScreenState extends State<MotorResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _trophyController;
  late AnimationController _statsController;
  late AnimationController _medalController;
  late Animation<double> _trophyAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _medalRotation;

  @override
  void initState() {
    super.initState();

    _trophyController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _trophyAnimation = CurvedAnimation(
      parent: _trophyController,
      curve: Curves.elasticOut,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutCubic,
    );

    _medalController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _medalRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _medalController, curve: Curves.linear),
    );

    _trophyController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _statsController.forward();
    });
  }

  @override
  void dispose() {
    _trophyController.dispose();
    _statsController.dispose();
    _medalController.dispose();
    super.dispose();
  }

  bool get _isPerfect => widget.accuracy >= 1.0;
  
  int get _starsEarned {
    if (widget.accuracy >= 0.9) return 3;
    if (widget.accuracy >= 0.7) return 2;
    if (widget.accuracy >= 0.4) return 1;
    return 0;
  }

  String get _rankTitle {
    if (widget.accuracy >= 0.95) return '🏆 Champion!';
    if (widget.accuracy >= 0.85) return '🥇 Expert!';
    if (widget.accuracy >= 0.70) return '🥈 Skilled!';
    if (widget.accuracy >= 0.50) return '🥉 Improving!';
    return '💪 Keep Training!';
  }

  String get _messageText {
    if (widget.accuracy >= 0.95) return 'Incredible reflexes! You\'re unstoppable!';
    if (widget.accuracy >= 0.85) return 'Amazing coordination! Keep it up!';
    if (widget.accuracy >= 0.70) return 'Great job! Your skills are improving!';
    if (widget.accuracy >= 0.50) return 'Good effort! Practice makes perfect!';
    return 'Don\'t give up! Every champion started somewhere!';
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
              Colors.orange.shade900,
              Colors.deepOrange.shade800,
              Colors.red.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Confetti for high scores
              if (widget.accuracy >= 0.8)
                AnimatedBuilder(
                  animation: _medalRotation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: MediaQuery.of(context).size,
                      painter: _ConfettiPainter(_medalRotation.value / (2 * math.pi)),
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
                      // Trophy/Medal
                      _buildTrophy(),

                      const SizedBox(height: 24),

                      // Rank title
                      AnimatedBuilder(
                        animation: _trophyAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _trophyAnimation.value.clamp(0.0, 1.0),
                            child: child,
                          );
                        },
                        child: Text(
                          _rankTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.orange, blurRadius: 20),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        widget.skillName,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stats grid
                      _buildStatsGrid(),

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

  Widget _buildTrophy() {
    return AnimatedBuilder(
      animation: _trophyAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _trophyAnimation.value.clamp(0.0, 1.2),
          child: child,
        );
      },
      child: AnimatedBuilder(
        animation: _medalRotation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_isPerfect ? math.sin(_medalRotation.value) * 0.2 : 0),
            alignment: Alignment.center,
            child: child,
          );
        },
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.orange.shade300,
                Colors.deepOrange,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.6),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Text(
              _isPerfect ? '🏆' : (_starsEarned >= 2 ? '🎯' : '⚡'),
              style: const TextStyle(fontSize: 70),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _statsAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _statsAnimation.value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  icon: '🎯',
                  label: 'Targets Hit',
                  value: '${widget.targetsHit}/${widget.totalTargets}',
                ),
                _buildStatItem(
                  icon: '⭐',
                  label: 'Score',
                  value: '${widget.score}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  icon: '📊',
                  label: 'Accuracy',
                  value: '${(widget.accuracy * 100).round()}%',
                ),
                _buildStatItem(
                  icon: '⚡',
                  label: 'Avg. Reaction',
                  value: '${widget.avgReactionTime.inMilliseconds}ms',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStarsDisplay() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isEarned = index < _starsEarned;
            final delay = index * 0.2;
            final animValue = ((_statsAnimation.value - delay) / 0.6).clamp(0.0, 1.0);

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
      animation: _statsAnimation,
      builder: (context, child) {
        final displayXp = (widget.xpEarned * _statsAnimation.value).round();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 24)),
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
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.orange.withValues(alpha: 0.5),
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
        if (widget.onRetry != null) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onRetry,
            child: const Text(
              '🔄 Play Again',
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

  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final colors = [
      Colors.orange,
      Colors.amber,
      Colors.red,
      Colors.yellow,
      Colors.deepOrange,
    ];

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * 0.3;
      final y = (baseY + progress) * size.height * 1.5;
      
      if (y > size.height) continue;

      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;

      final confettiSize = 4 + random.nextDouble() * 8;
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 4 + i);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: confettiSize,
          height: confettiSize * 0.5,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
