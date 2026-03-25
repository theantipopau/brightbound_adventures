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
  late AnimationController _particleController;
  late AnimationController _characterBounceController;
  late AnimationController _transitionController;
  late Animation<double> _portalScale;
  late Animation<double> _portalRotation;
  late Animation<double> _textOpacity;
  late Animation<double> _zoneStagger;
  late Animation<double> _particleOpacity;
  late Animation<double> _transitionScale;

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

    // NEW: Particle effects controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _particleOpacity = Tween<double>(begin: 0.8, end: 0.2).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    // NEW: Character bounce controller
    _characterBounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    // NEW: Transition controller for final animation
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _transitionScale = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInCubic),
    );
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

    // Navigate to world map with transition animation
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      _transitionController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/world-map');
      }
    }
  }

  @override
  void dispose() {
    _portalController.dispose();
    _textController.dispose();
    _zoneController.dispose();
    _particleController.dispose();
    _characterBounceController.dispose();
    _transitionController.dispose();
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenW = constraints.maxWidth;
                final isPhone = screenW < 480;
                final isMid = screenW < 800;
                final portalSize = isPhone ? 130.0 : isMid ? 155.0 : 180.0;
                final particleOrbit = isPhone ? 80.0 : isMid ? 95.0 : 110.0;
                final topPad = isPhone ? 24.0 : 40.0;
                final midPad = isPhone ? 28.0 : 48.0;
                final bottomPad = isPhone ? 32.0 : 60.0;
                final welcomeSize = isPhone ? 24.0 : isMid ? 28.0 : 36.0;
                final msgSize = isPhone ? 13.0 : 16.0;
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: topPad),
                  // Portal with avatar
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _portalController,
                      _characterBounceController,
                      _particleController,
                      _transitionController,
                    ]),
                    builder: (context, child) {
                      // Clamp scale to reasonable bounds (elasticOut can overshoot)
                      final scale = _portalScale.value.clamp(0.0, 1.5);
                      
                      // Character bounce effect
                      final characterBounce = math.sin(
                        _characterBounceController.value * math.pi * 2,
                      ) * 8;

                      return Transform.scale(
                        scale: scale * _transitionScale.value,
                        child: Opacity(
                          opacity: 1.0 - (_transitionController.value * 0.3),
                          child: Transform.rotate(
                            angle: _portalRotation.value * 0.1,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Particle effects layer
                                ...List.generate(8, (index) {
                                  final angle = (index / 8) * 2 * math.pi;
                                  final pDist = particleOrbit + (index % 2) * 20;
                                  final particleX = math.cos(angle) * pDist;
                                  final particleY = math.sin(angle + _particleController.value * math.pi * 2) * pDist;

                                  return Transform.translate(
                                    offset: Offset(particleX, particleY),
                                    child: Opacity(
                                      opacity: _particleOpacity.value,
                                      child: Container(
                                        width: isPhone ? 6 : 8,
                                        height: isPhone ? 6 : 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: [
                                            AppColors.primary,
                                            AppColors.secondary,
                                            Colors.purpleAccent,
                                          ][index % 3],
                                          boxShadow: [
                                            BoxShadow(
                                              color: [
                                                AppColors.primary,
                                                AppColors.secondary,
                                                Colors.purpleAccent,
                                              ][index % 3].withValues(alpha: 0.6),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                // Outer glow rings
                                ...List.generate(3, (index) {
                                  final delay = index * 0.15;
                                  final progress =
                                      ((_portalController.value - delay)
                                          .clamp(0.0, 1.0));
                                  final ringSize = (portalSize * 1.4) + (index * (isPhone ? 22 : 36));
                                  return Container(
                                    width: ringSize,
                                    height: ringSize,
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

                                // Portal center (responsive size)
                                Transform.translate(
                                  offset: Offset(0, characterBounce),
                                  child: Container(
                                    width: portalSize,
                                    height: portalSize,
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
                                        style: TextStyle(
                                            fontSize: portalSize * 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: midPad),

                  // Welcome text
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.symmetric(
                            horizontal: isPhone ? 14 : 18,
                            vertical: isPhone ? 10 : 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: isPhone ? 42 : 52,
                                height: isPhone ? 42 : 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Text('✨', style: TextStyle(fontSize: 24)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'BrightBound Adventures',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: isPhone ? 16 : 20,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Text(
                                    'Choose a hero. Enter the realms. Learn by playing.',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: isPhone ? 10 : 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Enhanced welcome text with glow
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ShaderMask(
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
                              style: TextStyle(
                                fontSize: welcomeSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Loading message with enhanced styling
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Container(
                            key: ValueKey(_currentPhase),
                            padding: EdgeInsets.symmetric(
                              horizontal: isPhone ? 16 : 24,
                              vertical: isPhone ? 10 : 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
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
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: msgSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: bottomPad),

                  // Zone previews - Enhanced
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
                            return Wrap(
                              alignment: WrapAlignment.center,
                              runSpacing: 8,
                              spacing: 8,
                              children: List.generate(5, (index) {
                                final zones = ['🌲', '🌌', '🧠', '📖', '🏟️'];
                                final bounce = math.sin(
                                      (_zoneStagger.value * math.pi * 2) +
                                          (index * 0.5),
                                    ) *
                                    8;

                                // Enhanced with stagger
                                final scale = 0.9 + math.sin(
                                  (_zoneStagger.value * math.pi * 2) +
                                  (index * 0.4),
                                ) * 0.15;

                                return Transform.translate(
                                  offset: Offset(0, bounce),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              Colors.white.withValues(alpha: 0.4),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withValues(alpha: 0.1 * scale),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          zones[index],
                                          style: const TextStyle(fontSize: 24),
                                        ),
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
            );
              },
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
      case 'cat':
        return '🐱';
      case 'penguin':
        return '🐧';
      case 'koala':
        return '🐨';
      case 'panda':
        return '🐼';
      case 'owl':
        return '🦉';
      case 'otter':
        return '🦦';
      case 'wolf':
        return '🐺';
      case 'tiger':
        return '🐯';
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
