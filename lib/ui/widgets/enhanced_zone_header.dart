import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/avatar.dart';

/// Enhanced zone header with animated character and themed decorations
class EnhancedZoneHeader extends StatefulWidget {
  final String zoneId;
  final String zoneName;
  final String zoneDescription;
  final Color zoneColor;
  final Avatar? avatar;

  const EnhancedZoneHeader({
    super.key,
    required this.zoneId,
    required this.zoneName,
    required this.zoneDescription,
    required this.zoneColor,
    this.avatar,
  });

  @override
  State<EnhancedZoneHeader> createState() => _EnhancedZoneHeaderState();
}

class _EnhancedZoneHeaderState extends State<EnhancedZoneHeader>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _particleController;
  late AnimationController _characterWaveController;

  final List<_FloatingParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    _characterWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _initParticles();
  }

  void _initParticles() {
    final random = math.Random();
    final particleData = _getZoneParticles();

    for (int i = 0; i < 15; i++) {
      _particles.add(_FloatingParticle(
        emoji: particleData[random.nextInt(particleData.length)],
        x: random.nextDouble(),
        startY: 0.8 + random.nextDouble() * 0.4,
        speed: 0.3 + random.nextDouble() * 0.4,
        size: 14 + random.nextDouble() * 10,
        wobble: random.nextDouble() * 2 * math.pi,
        wobbleSpeed: 1 + random.nextDouble() * 2,
      ));
    }
  }

  List<String> _getZoneParticles() {
    switch (widget.zoneId) {
      case 'word_woods':
      case 'word-woods':
        return ['🍃', '🌿', '🌲', '📚', '✨', '🦋'];
      case 'number_nebula':
      case 'number-nebula':
        return ['⭐', '✨', '🌟', '💫', '🔢', '➕'];
      case 'math-facts':
        return ['➕', '➖', '✖️', '➗', '🔢', '💡'];
      case 'story_springs':
      case 'story-springs':
        return ['📖', '✨', '💭', '🎭', '🌊', '💫'];
      case 'puzzle_peaks':
      case 'puzzle-peaks':
        return ['🧩', '⚡', '💡', '🎯', '🔮', '✨'];
      case 'adventure_arena':
      case 'adventure-arena':
        return ['🏆', '⭐', '🎖️', '🌟', '🎯', '🔥'];
      default:
        return ['✨', '⭐', '💫', '🌟'];
    }
  }

  String _getZoneEmoji() {
    switch (widget.zoneId) {
      case 'word_woods':
      case 'word-woods':
        return '🌲';
      case 'number_nebula':
      case 'number-nebula':
        return '🌌';
      case 'math-facts':
        return '🔢';
      case 'story_springs':
      case 'story-springs':
        return '📖';
      case 'puzzle_peaks':
      case 'puzzle-peaks':
        return '🧩';
      case 'adventure_arena':
      case 'adventure-arena':
        return '🏆';
      default:
        return '🎮';
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _particleController.dispose();
    _characterWaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_floatController, _particleController, _characterWaveController]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.zoneColor,
                widget.zoneColor.withValues(alpha: 0.8),
                widget.zoneColor.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background decorations
              ..._buildBackgroundDecorations(),

              // Floating particles
              ..._particles.map((p) => _buildParticle(p)),

              // Main content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Left side - Zone info
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Zone emoji with animation
                          Transform.translate(
                            offset: Offset(0,
                                math.sin(_floatController.value * math.pi) * 5),
                            child: Text(
                              _getZoneEmoji(),
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.zoneName
                                .replaceFirst(RegExp(r'^[^\s]+\s'), ''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.zoneDescription,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right side - Animated character
                    if (widget.avatar != null)
                      Expanded(
                        flex: 1,
                        child: _buildAnimatedCharacter(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildBackgroundDecorations() {
    return [
      // Large decorative shapes
      Positioned(
        right: -30,
        top: -30,
        child: Opacity(
          opacity: 0.1,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
      Positioned(
        left: -20,
        bottom: -20,
        child: Opacity(
          opacity: 0.08,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildParticle(_FloatingParticle particle) {
    final progress = _particleController.value;
    // Calculate Y position (moving upward)
    final y = (particle.startY - progress * particle.speed) % 1.2;
    // Horizontal wobble
    final wobbleOffset = math.sin(
            (progress * particle.wobbleSpeed + particle.wobble) * math.pi * 2) *
        0.05;
    final x = particle.x + wobbleOffset;
    // Fade based on position
    final opacity = y > 0.1 ? (y < 0.9 ? 1.0 : (1.2 - y) / 0.3) : y / 0.1;

    return Positioned(
      left: x * MediaQuery.of(context).size.width * 0.5,
      top: y * 200,
      child: Opacity(
        opacity: opacity.clamp(0.0, 0.6),
        child: Text(
          particle.emoji,
          style: TextStyle(fontSize: particle.size),
        ),
      ),
    );
  }

  Widget _buildAnimatedCharacter() {
    final avatar = widget.avatar!;
    final waveAngle = math.sin(_characterWaveController.value * math.pi) * 0.2;

    // Parse color from string (format: #RRGGBB or color name)
    Color skinColor = const Color(0xFFFFDAB9); // peach puff
    try {
      if (avatar.skinColor.startsWith('#')) {
        skinColor = Color(
            int.parse(avatar.skinColor.substring(1), radix: 16) + 0xFF000000);
      }
    } catch (_) {}

    return Transform.translate(
      offset: Offset(0, math.sin(_floatController.value * math.pi) * 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Character body
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: skinColor,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Eyes
                Positioned(
                  left: 15,
                  top: 22,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.brown,
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  top: 22,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.brown,
                    ),
                  ),
                ),
                // Smile
                Positioned(
                  left: 20,
                  bottom: 15,
                  child: Container(
                    width: 30,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      color: Colors.brown[300],
                    ),
                  ),
                ),
                // Hair on top
                Positioned(
                  top: -5,
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.brown,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // Waving hand
          Transform.rotate(
            angle: waveAngle,
            origin: const Offset(0, 10),
            child: const Text('👋', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 4),
          // Name badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              avatar.name,
              style: TextStyle(
                color: widget.zoneColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingParticle {
  final String emoji;
  final double x;
  final double startY;
  final double speed;
  final double size;
  final double wobble;
  final double wobbleSpeed;

  _FloatingParticle({
    required this.emoji,
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.wobble,
    required this.wobbleSpeed,
  });
}
