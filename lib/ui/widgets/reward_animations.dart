import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated star burst effect for earning rewards
class StarBurstAnimation extends StatefulWidget {
  final int starCount;
  final VoidCallback? onComplete;
  final Color color;

  const StarBurstAnimation({
    super.key,
    this.starCount = 1,
    this.onComplete,
    this.color = Colors.amber,
  });

  @override
  State<StarBurstAnimation> createState() => _StarBurstAnimationState();
}

class _StarBurstAnimationState extends State<StarBurstAnimation>
    with TickerProviderStateMixin {
  late AnimationController _burstController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  final List<_StarParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _burstController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _burstController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    // Create particles
    final random = math.Random();
    for (int i = 0; i < 12; i++) {
      _particles.add(_StarParticle(
        angle: (i / 12) * 2 * math.pi,
        speed: 80 + random.nextDouble() * 60,
        size: 8 + random.nextDouble() * 8,
        rotationSpeed: (random.nextDouble() - 0.5) * 4,
      ));
    }

    _burstController.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _burstController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_burstController, _pulseController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Particles
            ..._particles.map((particle) {
              final progress = _burstController.value;
              final distance = particle.speed * progress;
              final dx = math.cos(particle.angle) * distance;
              final dy = math.sin(particle.angle) * distance;
              final rotation = particle.rotationSpeed * progress * math.pi;

              return Transform.translate(
                offset: Offset(dx, dy),
                child: Transform.rotate(
                  angle: rotation,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: _StarShape(
                      size: particle.size,
                      color: widget.color,
                    ),
                  ),
                ),
              );
            }),
            // Central star
            Transform.scale(
              scale: _scaleAnimation.value * (1 + _pulseController.value * 0.1),
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.6),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      widget.starCount > 1 ? '+${widget.starCount}⭐' : '⭐',
                      style: TextStyle(
                        fontSize: widget.starCount > 1 ? 24 : 40,
                        shadows: [
                          Shadow(
                            color: widget.color,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StarParticle {
  final double angle;
  final double speed;
  final double size;
  final double rotationSpeed;

  _StarParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.rotationSpeed,
  });
}

class _StarShape extends StatelessWidget {
  final double size;
  final Color color;

  const _StarShape({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StarPainter(color: color),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;

  _StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;

    final path = Path();
    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi / points) - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floating XP gain animation
class XPGainAnimation extends StatefulWidget {
  final int amount;
  final VoidCallback? onComplete;

  const XPGainAnimation({
    super.key,
    required this.amount,
    this.onComplete,
  });

  @override
  State<XPGainAnimation> createState() => _XPGainAnimationState();
}

class _XPGainAnimationState extends State<XPGainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translateAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _translateAnimation = Tween<double>(
      begin: 0,
      end: -80,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.2),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.8),
        weight: 50,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: 1),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1, end: 1),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1, end: 0),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translateAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.blue.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  '+${widget.amount} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Level up celebration animation
class LevelUpAnimation extends StatefulWidget {
  final int newLevel;
  final VoidCallback? onComplete;

  const LevelUpAnimation({
    super.key,
    required this.newLevel,
    this.onComplete,
  });

  @override
  State<LevelUpAnimation> createState() => _LevelUpAnimationState();
}

class _LevelUpAnimationState extends State<LevelUpAnimation>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _glowAnimation;
  final List<_ConfettiParticle> _confetti = [];

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0, end: 1.3),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0),
        weight: 10,
      ),
    ]).animate(CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0, 0.3, curve: Curves.easeOut),
    ));

    _glowAnimation = Tween<double>(
      begin: 10,
      end: 30,
    ).animate(_glowController);

    // Create confetti
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _confetti.add(_ConfettiParticle(
        x: random.nextDouble() * 300 - 150,
        y: random.nextDouble() * -200 - 50,
        vx: (random.nextDouble() - 0.5) * 100,
        vy: random.nextDouble() * 150 + 100,
        color: [
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.yellow,
          Colors.purple,
          Colors.orange,
          Colors.pink,
        ][random.nextInt(7)],
        rotation: random.nextDouble() * math.pi * 2,
        rotationSpeed: (random.nextDouble() - 0.5) * 10,
        size: 8 + random.nextDouble() * 8,
      ));
    }

    _mainController.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _glowController]),
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Confetti
            ..._confetti.map((particle) {
              final progress = _mainController.value;
              final x = particle.x + particle.vx * progress;
              final y = particle.y + particle.vy * progress;
              final rotation =
                  particle.rotation + particle.rotationSpeed * progress;
              final opacity = (1 - progress).clamp(0.0, 1.0);

              return Positioned(
                left: 150 + x,
                top: 150 + y,
                child: Transform.rotate(
                  angle: rotation,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: particle.size,
                      height: particle.size * 0.6,
                      decoration: BoxDecoration(
                        color: particle.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              );
            }),
            // Level badge
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade300,
                        Colors.orange.shade400,
                        Colors.deepOrange.shade500,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.8),
                        blurRadius: _glowAnimation.value,
                        spreadRadius: _glowAnimation.value / 3,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'LEVEL UP!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${widget.newLevel}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 48,
                          height: 1,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '🎉',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final double size;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
  });
}

/// Overlay helper to show reward animations
class RewardAnimationOverlay {
  static OverlayEntry? _currentOverlay;

  /// Show star burst animation
  static void showStarBurst(
    BuildContext context, {
    int starCount = 1,
    VoidCallback? onComplete,
  }) {
    _removeCurrentOverlay();

    final overlay = Overlay.of(context);
    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black26,
          child: Center(
            child: StarBurstAnimation(
              starCount: starCount,
              onComplete: () {
                _removeCurrentOverlay();
                onComplete?.call();
              },
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentOverlay!);
  }

  /// Show XP gain animation at a specific position
  static void showXPGain(
    BuildContext context,
    int amount, {
    Offset? position,
    VoidCallback? onComplete,
  }) {
    _removeCurrentOverlay();

    final overlay = Overlay.of(context);
    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: position?.dx ?? MediaQuery.of(context).size.width / 2 - 40,
        top: position?.dy ?? MediaQuery.of(context).size.height / 2,
        child: XPGainAnimation(
          amount: amount,
          onComplete: () {
            _removeCurrentOverlay();
            onComplete?.call();
          },
        ),
      ),
    );

    overlay.insert(_currentOverlay!);
  }

  /// Show level up animation
  static void showLevelUp(
    BuildContext context,
    int newLevel, {
    VoidCallback? onComplete,
  }) {
    _removeCurrentOverlay();

    final overlay = Overlay.of(context);
    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black54,
          child: Center(
            child: LevelUpAnimation(
              newLevel: newLevel,
              onComplete: () {
                _removeCurrentOverlay();
                onComplete?.call();
              },
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentOverlay!);
  }

  static void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }
}
