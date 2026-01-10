import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

class WorldEntryScreen extends StatefulWidget {
  const WorldEntryScreen({super.key});

  @override
  State<WorldEntryScreen> createState() => _WorldEntryScreenState();
}

class _WorldEntryScreenState extends State<WorldEntryScreen>
    with TickerProviderStateMixin {
  late AnimationController _portalController;
  late AnimationController _textController;
  late AnimationController _zoneController;
  late Animation<double> _portalScale;
  late Animation<double> _portalRotation;
  late Animation<double> _textOpacity;
  late Animation<double> _zoneStagger;

  int _currentPhase = 0;
  final List<String> _loadingMessages = [
    'Opening the portal...',
    'Preparing your adventure...',
    'Loading the magical lands...',
    'Almost ready!',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startEntrySequence();
  }

  void _initializeAnimations() {
    _portalController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Use a simple Tween instead of TweenSequence to avoid easeOutBack overshoot issues
    _portalScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _portalController,
        curve: Curves.elasticOut,
      ),
    );

    _portalRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _portalController, curve: Curves.easeInOutCubic),
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _zoneController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _zoneStagger = Tween<double>(begin: 0, end: 1).animate(_zoneController);
  }

  Future<void> _startEntrySequence() async {
    // Phase 1: Portal opening
    _portalController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    // Phase transitions
    for (int i = 0; i < _loadingMessages.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _currentPhase = i);
      }
    }

    // Navigate to world map
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/world-map');
    }
  }

  @override
  void dispose() {
    _portalController.dispose();
    _textController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = context.watch<AvatarProvider>().avatar;
    final characterEmoji = _getCharacterEmoji(avatar?.baseCharacter ?? 'bear');

    return Scaffold(
      body: Stack(
        children: [
          // Animated galaxy background
          AnimatedBuilder(
            animation: _zoneController,
            builder: (context, child) {
              return CustomPaint(
                painter: _GalaxyPainter(_zoneStagger.value),
                size: Size.infinite,
              );
            },
          ),

          // Main content
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Portal with avatar
                  AnimatedBuilder(
                    animation: _portalController,
                    builder: (context, child) {
                      // Clamp scale to reasonable bounds (elasticOut can overshoot)
                      final scale = _portalScale.value.clamp(0.0, 1.5);
                      return Transform.scale(
                        scale: scale,
                        child: Transform.rotate(
                          angle: _portalRotation.value * 0.1,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer glow rings
                              ...List.generate(3, (index) {
                                final delay = index * 0.15;
                                final progress =
                                    ((_portalController.value - delay)
                                        .clamp(0.0, 1.0));
                                return Container(
                                  width: 200 + (index * 40),
                                  height: 200 + (index * 40),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _getPortalColor(index).withValues(
                                        alpha: ((0.6 - index * 0.15) * progress)
                                            .clamp(0.0, 1.0),
                                      ),
                                      width: 4 - index.toDouble(),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _getPortalColor(index)
                                            .withValues(
                                                alpha: (0.3 * progress)
                                                    .clamp(0.0, 1.0)),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                );
                              }),

                              // Portal center
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppColors.primary.withValues(alpha: 0.9),
                                      AppColors.secondary
                                          .withValues(alpha: 0.7),
                                      Colors.purple.withValues(alpha: 0.5),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.5),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    characterEmoji,
                                    style: const TextStyle(fontSize: 90),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Welcome text
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondary,
                              Colors.purpleAccent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            'Welcome, ${avatar?.name ?? 'Adventurer'}!',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Loading message
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            key: ValueKey(_currentPhase),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _loadingMessages[_currentPhase],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Zone previews
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _zoneController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: 0.7 +
                                  (math.sin(_zoneStagger.value * math.pi * 2) +
                                          1) *
                                      0.15,
                              child: child,
                            );
                          },
                          child: const Text(
                            'Discover Amazing Worlds',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedBuilder(
                          animation: _zoneController,
                          builder: (context, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                final zones = ['🌲', '🌌', '🧠', '📖', '🏟️'];
                                final bounce = math.sin(
                                      (_zoneStagger.value * math.pi * 2) +
                                          (index * 0.5),
                                    ) *
                                    8;

                                return Transform.translate(
                                  offset: Offset(0, bounce),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        zones[index],
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPortalColor(int index) {
    switch (index) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.secondary;
      case 2:
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  String _getCharacterEmoji(String character) {
    switch (character.toLowerCase()) {
      case 'bear':
        return '🐻';
      case 'fox':
        return '🦊';
      case 'rabbit':
        return '🐰';
      case 'deer':
        return '🦌';
      default:
        return '🐻';
    }
  }
}

// Galaxy background painter
class _GalaxyPainter extends CustomPainter {
  final double animation;

  _GalaxyPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Dark gradient background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0D1B2A),
          Color(0xFF1B263B),
          Color(0xFF2D3A4A),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Stars
    final starPaint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final twinkle = (math.sin(animation * math.pi * 2 + i * 0.5) + 1) / 2;
      final starSize = 1.0 + random.nextDouble() * 2;

      starPaint.color =
          Colors.white.withValues(alpha: (0.3 + twinkle * 0.7).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), starSize, starPaint);
    }

    // Nebula clouds
    final nebulaPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    for (int i = 0; i < 4; i++) {
      final centerX = size.width * (0.2 + i * 0.25);
      final centerY =
          size.height * (0.3 + math.sin(animation * math.pi + i) * 0.1);

      final colors = [
        AppColors.primary.withValues(alpha: 0.15),
        AppColors.secondary.withValues(alpha: 0.1),
        Colors.purple.withValues(alpha: 0.12),
        AppColors.tertiary.withValues(alpha: 0.08),
      ];

      nebulaPaint.color = colors[i % colors.length];
      canvas.drawCircle(Offset(centerX, centerY), 100 + i * 30, nebulaPaint);
    }

    // Shooting stars
    final shootingStarPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final progress = ((animation * 2 + i * 0.33) % 1);
      if (progress < 0.3) {
        final startX = size.width * (0.1 + i * 0.3);
        final startY = size.height * 0.1;
        final endX = startX + 80 * progress * 3;
        final endY = startY + 60 * progress * 3;

        final gradient = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: (1 - progress * 3).clamp(0.0, 1.0)),
            Colors.white.withValues(alpha: 0),
          ],
        );

        shootingStarPaint.shader = gradient.createShader(
          Rect.fromPoints(Offset(startX, startY), Offset(endX, endY)),
        );

        canvas.drawLine(
            Offset(startX, startY), Offset(endX, endY), shootingStarPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxyPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
