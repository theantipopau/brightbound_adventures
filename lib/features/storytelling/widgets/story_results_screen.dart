import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Results screen for Story Springs with a magical book theme
class StoryResultsScreen extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final int xpEarned;
  final String skillName;
  final VoidCallback onContinue;
  final VoidCallback? onRetry;

  const StoryResultsScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.xpEarned,
    required this.skillName,
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
      _starsController.forward();
    });
    
    if (_isPerfect) {
      _confettiController.forward();
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
  double get _percentage => widget.correctAnswers / widget.totalQuestions;
  
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
    if (_percentage >= 1.0) return 'Perfect! Your storytelling skills are legendary!';
    if (_percentage >= 0.7) return 'Amazing work! You\'re becoming a great writer!';
    if (_percentage >= 0.4) return 'Good job! Practice makes perfect!';
    return 'Every author started somewhere. Keep reading and writing!';
  }

  @override
  Widget build(BuildContext context) {
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
          final offset = math.sin(DateTime.now().millisecondsSinceEpoch / 1000 + index) * 10;
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
    return AnimatedBuilder(
      animation: _starsAnimation,
      builder: (context, child) {
        final displayXp = (widget.xpEarned * _starsAnimation.value).round();
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
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.purple.withValues(alpha: 0.5),
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
              '🔄 Try Again',
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
      
      final wobbleOffset = math.sin(progress * particle.wobbleSpeed + particle.wobble) * 0.05;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
