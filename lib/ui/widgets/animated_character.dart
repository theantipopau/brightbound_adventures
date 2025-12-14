import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// Animated character widget that displays RPG-style sprite animations
class AnimatedCharacter extends StatefulWidget {
  final String character;
  final String skinColor;
  final double size;
  final CharacterAnimation animation;
  final bool showShadow;
  final bool showParticles;
  final VoidCallback? onTap;

  const AnimatedCharacter({
    super.key,
    required this.character,
    this.skinColor = '#E8C4A0',
    this.size = 80,
    this.animation = CharacterAnimation.idle,
    this.showShadow = true,
    this.showParticles = false,
    this.onTap,
  });

  @override
  State<AnimatedCharacter> createState() => _AnimatedCharacterState();
}

enum CharacterAnimation {
  idle,
  walking,
  jumping,
  celebrating,
  thinking,
  sleeping,
}

class _AnimatedCharacterState extends State<AnimatedCharacter>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _walkController;
  late AnimationController _particleController;
  late AnimationController _blinkController;
  
  late Animation<double> _bounce;
  late Animation<double> _walkSway;
  late Animation<double> _legAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Bounce animation (idle)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _bounce = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Walk animation
    _walkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _walkSway = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _walkController, curve: Curves.easeInOut),
    );
    _legAnimation = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(parent: _walkController, curve: Curves.easeInOut),
    );

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Blink animation
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _startAnimation();
  }

  void _startAnimation() {
    switch (widget.animation) {
      case CharacterAnimation.idle:
        _bounceController.repeat(reverse: true);
        _startBlinking();
        break;
      case CharacterAnimation.walking:
        _walkController.repeat(reverse: true);
        _bounceController.repeat(reverse: true);
        break;
      case CharacterAnimation.jumping:
        _bounceController.duration = const Duration(milliseconds: 600);
        _bounceController.repeat(reverse: true);
        break;
      case CharacterAnimation.celebrating:
        _bounceController.duration = const Duration(milliseconds: 300);
        _bounceController.repeat(reverse: true);
        if (widget.showParticles) _particleController.repeat();
        break;
      case CharacterAnimation.thinking:
        _bounceController.duration = const Duration(milliseconds: 2000);
        _bounceController.repeat(reverse: true);
        break;
      case CharacterAnimation.sleeping:
        _bounceController.duration = const Duration(milliseconds: 3000);
        _bounceController.repeat(reverse: true);
        break;
    }
  }

  void _startBlinking() {
    Future.delayed(Duration(milliseconds: 2000 + math.Random().nextInt(3000)), () {
      if (mounted && widget.animation == CharacterAnimation.idle) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      _bounceController.stop();
      _walkController.stop();
      _particleController.stop();
      _bounceController.duration = const Duration(milliseconds: 1200);
      _startAnimation();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _walkController.dispose();
    _particleController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size * 1.5,
        height: widget.size * 1.8,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Particles (if enabled)
            if (widget.showParticles)
              AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ParticlePainter(
                      _particleController.value,
                      _getCharacterColor(),
                    ),
                    size: Size(widget.size * 1.5, widget.size * 1.8),
                  );
                },
              ),

            // Shadow
            if (widget.showShadow)
              Positioned(
                bottom: 0,
                child: AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    final shadowScale = 1.0 - (_bounce.value.abs() / 20);
                    return Container(
                      width: widget.size * 0.6 * shadowScale,
                      height: widget.size * 0.15,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(widget.size),
                      ),
                    );
                  },
                ),
              ),

            // Character body
            AnimatedBuilder(
              animation: Listenable.merge([_bounceController, _walkController]),
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    widget.animation == CharacterAnimation.walking ? _walkSway.value : 0,
                    _bounce.value,
                  ),
                  child: _buildCharacterBody(),
                );
              },
            ),

            // Status indicators
            if (widget.animation == CharacterAnimation.sleeping)
              Positioned(
                top: 0,
                right: 0,
                child: _buildSleepingZzz(),
              ),
            if (widget.animation == CharacterAnimation.thinking)
              Positioned(
                top: 0,
                right: 0,
                child: _buildThinkingBubble(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterBody() {
    final skinColor = Color(int.parse('0xFF${widget.skinColor.replaceFirst('#', '')}'));
    
    // Use FittedBox to ensure the character fits within constraints
    return FittedBox(
      fit: BoxFit.contain,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Head with face
          Stack(
            alignment: Alignment.center,
            children: [
              // Head background
              Container(
                width: widget.size * 0.55,
                height: widget.size * 0.55,
                decoration: BoxDecoration(
                  color: skinColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: skinColor.withOpacity(0.7),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: skinColor.withOpacity(0.3),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              // Character emoji face
              Text(
                _getCharacterEmoji(),
                style: TextStyle(fontSize: widget.size * 0.35),
              ),
            ],
          ),

          // Body
          Container(
            width: widget.size * 0.35,
            height: widget.size * 0.25,
            decoration: BoxDecoration(
              color: _getCharacterColor(),
              borderRadius: BorderRadius.circular(widget.size * 0.1),
            ),
          ),

          // Legs (animated when walking)
          if (widget.animation == CharacterAnimation.walking)
            AnimatedBuilder(
              animation: _walkController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: _legAnimation.value * math.pi / 180,
                      child: Container(
                        width: widget.size * 0.1,
                        height: widget.size * 0.15,
                        decoration: BoxDecoration(
                          color: _getCharacterColor().withOpacity(0.8),
                          borderRadius: BorderRadius.circular(widget.size * 0.03),
                        ),
                      ),
                    ),
                    SizedBox(width: widget.size * 0.06),
                    Transform.rotate(
                      angle: -_legAnimation.value * math.pi / 180,
                      child: Container(
                        width: widget.size * 0.1,
                        height: widget.size * 0.15,
                        decoration: BoxDecoration(
                          color: _getCharacterColor().withOpacity(0.8),
                          borderRadius: BorderRadius.circular(widget.size * 0.03),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: widget.size * 0.1,
                  height: widget.size * 0.12,
                  decoration: BoxDecoration(
                    color: _getCharacterColor().withOpacity(0.8),
                    borderRadius: BorderRadius.circular(widget.size * 0.03),
                  ),
                ),
                SizedBox(width: widget.size * 0.06),
                Container(
                  width: widget.size * 0.1,
                  height: widget.size * 0.12,
                  decoration: BoxDecoration(
                    color: _getCharacterColor().withOpacity(0.8),
                    borderRadius: BorderRadius.circular(widget.size * 0.03),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSleepingZzz() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Column(
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final opacity = ((value - delay) % 1.0).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(index * 5.0, -index * 10.0 * opacity),
                child: Text(
                  'Z',
                  style: TextStyle(
                    fontSize: 12 + index * 4.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildThinkingBubble() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: const Text('💭', style: TextStyle(fontSize: 20)),
    );
  }

  String _getCharacterEmoji() {
    switch (widget.character.toLowerCase()) {
      case 'bear': return '🐻';
      case 'fox': return '🦊';
      case 'rabbit': return '🐰';
      case 'deer': return '🦌';
      default: return '🐻';
    }
  }

  Color _getCharacterColor() {
    switch (widget.character.toLowerCase()) {
      case 'bear': return const Color(0xFF8B4513);
      case 'fox': return const Color(0xFFFF6B35);
      case 'rabbit': return const Color(0xFFE0E0E0);
      case 'deer': return const Color(0xFFD2691E);
      default: return const Color(0xFF8B4513);
    }
  }
}

// Particle painter for celebration effects
class _ParticlePainter extends CustomPainter {
  final double animation;
  final Color color;

  _ParticlePainter(this.animation, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi + animation * math.pi * 2;
      final radius = 30 + animation * 40;
      final x = size.width / 2 + math.cos(angle) * radius;
      final y = size.height / 2 + math.sin(angle) * radius - 20;
      final particleSize = 3 + random.nextDouble() * 4;
      final opacity = (1 - animation).clamp(0.0, 1.0);

      final colors = [
        AppColors.primary,
        AppColors.secondary,
        AppColors.tertiary,
        Colors.purple,
      ];
      paint.color = colors[i % colors.length].withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Walking avatar that moves across the screen
class WalkingAvatar extends StatefulWidget {
  final String character;
  final String skinColor;
  final double size;
  final Offset startPosition;
  final Offset endPosition;
  final Duration duration;
  final VoidCallback? onArrived;

  const WalkingAvatar({
    super.key,
    required this.character,
    this.skinColor = '#E8C4A0',
    this.size = 60,
    required this.startPosition,
    required this.endPosition,
    this.duration = const Duration(seconds: 2),
    this.onArrived,
  });

  @override
  State<WalkingAvatar> createState() => _WalkingAvatarState();
}

class _WalkingAvatarState extends State<WalkingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _moveController;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _position = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOut,
    ));

    _moveController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onArrived?.call();
      }
    });

    _moveController.forward();
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _moveController,
      builder: (context, child) {
        final isMoving = _moveController.isAnimating;
        final direction = widget.endPosition.dx > widget.startPosition.dx ? 1.0 : -1.0;
        
        return Positioned(
          left: _position.value.dx,
          top: _position.value.dy,
          child: Transform.scale(
            scaleX: direction,
            child: AnimatedCharacter(
              character: widget.character,
              skinColor: widget.skinColor,
              size: widget.size,
              animation: isMoving 
                  ? CharacterAnimation.walking 
                  : CharacterAnimation.idle,
            ),
          ),
        );
      },
    );
  }
}
