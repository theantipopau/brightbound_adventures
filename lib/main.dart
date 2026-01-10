import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/index.dart';
import 'package:brightbound_adventures/ui/screens/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all services via registry
  final registry = ServiceRegistry();
  await registry.initializeAll();

  runApp(
    MultiProvider(
      providers: [
        Provider<LocalStorageService>(create: (_) => registry.storage),
        Provider<SoundEffectsService>(create: (_) => registry.soundEffects),
        ChangeNotifierProvider<AchievementService>.value(
            value: registry.achievements),
        ChangeNotifierProvider<ShopService>.value(value: registry.shop),
        ChangeNotifierProvider<AdaptiveDifficultyService>.value(
            value: registry.adaptiveDifficulty),
        ChangeNotifierProvider<AudioManager>.value(
            value: registry.audioManager),
        ChangeNotifierProvider<CosmeticUnlockService>.value(
            value: registry.cosmeticUnlock),
        ChangeNotifierProvider<StreakService>.value(value: registry.streak),
        ChangeNotifierProvider<AvatarProvider>(
          create: (_) {
            final provider = AvatarProvider();
            provider.setStorageService(registry.storage);
            return provider;
          },
        ),
        ChangeNotifierProvider<SkillProvider>(
          create: (_) => SkillProvider(registry.storage),
          // Lazy initialization: skills will be loaded on first zone entry
        ),
      ],
      child: const BrightBoundApp(),
    ),
  );
}

class BrightBoundApp extends StatelessWidget {
  const BrightBoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrightBound Adventures',
      theme: AppTheme.lightTheme(),
      builder: (context, child) {
        return ResponsiveWrapper(
          designSize: const Size(1280, 800), // Target desktop/tablet landscape
          minWidth: true,
          minHeight: true,
          child: child!,
        );
      },
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/avatar-creator': (context) => const AvatarCreatorScreen(),
        '/world-map': (context) => const WorldMapScreen(),
        '/world-entry': (context) => const WorldEntryScreen(),
        '/word-woods': (context) => const ZoneDetailScreen(
              zoneId: 'word_woods',
              zoneName: '🌲 Word Woods',
              zoneDescription:
                  'Explore literacy, reading, and communication skills',
              zoneColor: AppColors.wordWoodsColor,
            ),
        '/number-nebula': (context) => const ZoneDetailScreen(
              zoneId: 'number_nebula',
              zoneName: '🌌 Number Nebula',
              zoneDescription: 'Master numeracy, math, and problem solving',
              zoneColor: AppColors.numberNebulaColor,
            ),
        '/puzzle-peaks': (context) => const ZoneDetailScreen(
              zoneId: 'puzzle_peaks',
              zoneName: '🧠 Puzzle Peaks',
              zoneDescription: 'Challenge your logic, patterns, and reasoning',
              zoneColor: AppColors.puzzlePeaksColor,
            ),
        '/story-springs': (context) => const ZoneDetailScreen(
              zoneId: 'story_springs',
              zoneName: '📖 Story Springs',
              zoneDescription:
                  'Create stories, express emotions, develop characters',
              zoneColor: AppColors.storyspringsColor,
            ),
        '/adventure-arena': (context) => const ZoneDetailScreen(
              zoneId: 'adventure_arena',
              zoneName: '🏟️ Adventure Arena',
              zoneDescription: 'Improve hand-eye coordination and motor skills',
              zoneColor: AppColors.adventureArenaColor,
            ),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _starsController;
  late AnimationController _textController;
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Stars animation
    _starsController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Text animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Start animations in sequence
    _logoController.forward().then((_) {
      _textController.forward();
    });

    _checkAppState();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _starsController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _checkAppState() async {
    // Load avatar from storage
    await context.read<AvatarProvider>().loadAvatar();

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final avatarProvider = context.read<AvatarProvider>();

    if (!avatarProvider.hasAvatar) {
      // First time user - go to avatar creation
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/avatar-creator');
      }
    } else {
      // Existing user - go to world map
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/world-map');
      }
    }
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
              Color(0xFF1A1B4B), // Deep night blue
              Color(0xFF2D3A8C), // Rich purple-blue
              Color(0xFF4A6FA5), // Twilight blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated stars background
            AnimatedBuilder(
              animation: _starsController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _StarFieldPainter(_starsController.value),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated logo
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value,
                          child: Transform.rotate(
                            angle: _logoRotation.value,
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFF6B9D), // Pink
                                    Color(0xFFFF9A5C), // Orange
                                    Color(0xFFFFD93D), // Gold
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF6B9D)
                                        .withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer ring
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            Colors.white.withValues(alpha: 0.3),
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                  // Inner content
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '✨',
                                        style: TextStyle(fontSize: 40),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'BB',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 4,
                                              offset: const Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    // Animated title
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFFFD93D),
                                  Color(0xFFFF9A5C),
                                  Color(0xFFFF6B9D),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'BrightBound',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const Text(
                              '✨ Adventures ✨',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4ECDC4),
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Learn • Play • Grow',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Loading indicator
                    FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 200,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFF4ECDC4),
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading your adventure...',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom decorations
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildZoneIcon('🌲', 'Words'),
                    _buildZoneIcon('🌌', 'Numbers'),
                    _buildZoneIcon('📖', 'Stories'),
                    _buildZoneIcon('🧩', 'Puzzles'),
                    _buildZoneIcon('🏟️', 'Games'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneIcon(String emoji, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  final double animation;

  _StarFieldPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    // Draw twinkling stars
    for (int i = 0; i < 50; i++) {
      final x = (i * 37 % size.width.toInt()).toDouble();
      final y = (i * 53 % size.height.toInt()).toDouble();
      final twinkle =
          (0.3 + 0.7 * ((animation * 3 + i * 0.1) % 1.0)).clamp(0.0, 1.0);
      final starSize = 1.0 + (i % 3);

      paint.color = Colors.white.withValues(alpha: twinkle);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }

    // Draw a few larger glowing stars
    for (int i = 0; i < 8; i++) {
      final x = (i * 97 + 50) % size.width;
      final y = (i * 71 + 30) % size.height;
      final glow =
          (0.4 + 0.6 * ((animation * 2 + i * 0.3) % 1.0)).clamp(0.0, 1.0);

      // Glow effect
      paint.color = const Color(0xFFFFD93D).withValues(alpha: glow * 0.3);
      canvas.drawCircle(Offset(x, y), 8, paint);

      // Core
      paint.color = Colors.white.withValues(alpha: glow);
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
