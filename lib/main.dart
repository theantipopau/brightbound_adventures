import 'dart:math' as math;
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
        ChangeNotifierProvider<DailyChallengeService>.value(
            value: registry.dailyChallenge),
        Provider<HapticService>(create: (_) => registry.haptic),
        ChangeNotifierProvider<SpacedRepetitionService>.value(
            value: registry.srs),
        ChangeNotifierProvider<AiQuestionService>.value(
            value: registry.aiQuestions),
        ChangeNotifierProvider<ThemeModeService>.value(
            value: registry.themeMode),
        ChangeNotifierProvider<VisualAccessibilityService>.value(
            value: registry.visualAccessibility),
      ],
      child: const BrightBoundApp(),
    ),
  );
}

class BrightBoundApp extends StatelessWidget {
  const BrightBoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeModeService, VisualAccessibilityService>(
      builder: (context, themeModeService, visualAccessibility, _) {
        final lightTheme = visualAccessibility.highContrast
            ? _highContrastTheme(AppTheme.lightTheme())
            : AppTheme.lightTheme();
        final darkTheme = visualAccessibility.highContrast
            ? _highContrastTheme(AppTheme.darkTheme())
            : AppTheme.darkTheme();
        return MaterialApp(
          title: 'BrightBound Adventures',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeModeService.themeMode,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final platformReducedMotion = mediaQuery.disableAnimations ||
                WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
                    .disableAnimations;
            final textScale = visualAccessibility.largeText ? 1.16 : 1.0;
            final adjustedMediaQuery = mediaQuery.copyWith(
              disableAnimations:
                  platformReducedMotion || visualAccessibility.reduceMotion,
              textScaler: TextScaler.linear(
                (mediaQuery.textScaler.scale(1) * textScale).clamp(1.0, 1.28),
              ),
            );
            // DefaultTextStyle.merge ensures the bundled NotoEmoji font is listed
            // as a fallback for every Text widget, preventing Flutter Web CanvasKit
            // from spinning in requestAnimationFrame trying to download Noto fonts.
            return MediaQuery(
              data: adjustedMediaQuery,
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontFamilyFallback: ['NotoEmoji']),
                child: ResponsiveWrapper(
                  designSize: const Size(1280, 800),
                  minWidth: true,
                  minHeight: true,
                  child: child!,
                ),
              ),
            );
          },
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          onGenerateRoute: (settings) {
            final routes = <String, WidgetBuilder>{
              '/avatar-creator': (_) => const AvatarCreatorScreen(),
              '/world-map': (_) => const WorldMapScreen(),
              '/world-entry': (_) => const WorldEntryScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/profile-stats': (_) => const ProfileStatsScreen(),
              '/parent-dashboard': (_) => const ParentDashboardScreen(),
              '/word-woods': (_) => const ZoneDetailScreen(
                    zoneId: 'word_woods',
                    zoneName: '🌲 Word Woods',
                    zoneDescription:
                        'Explore literacy, reading, and communication skills',
                    zoneColor: AppColors.wordWoodsColor,
                  ),
              '/number-nebula': (_) => const ZoneDetailScreen(
                    zoneId: 'math_facts',
                    zoneName: '🌌 Number Nebula',
                    zoneDescription:
                        'Master numeracy, math, and problem solving',
                    zoneColor: AppColors.numberNebulaColor,
                  ),
              '/math-facts': (_) => const ZoneDetailScreen(
                    zoneId: 'number_nebula',
                    zoneName: '⚡ Math Facts',
                    zoneDescription: 'Speed rounds, combos, and fact mastery',
                    zoneColor: AppColors.numberNebulaColor,
                  ),
              '/puzzle-peaks': (_) => const ZoneDetailScreen(
                    zoneId: 'puzzle_peaks',
                    zoneName: '🧠 Puzzle Peaks',
                    zoneDescription:
                        'Challenge your logic, patterns, and reasoning',
                    zoneColor: AppColors.puzzlePeaksColor,
                  ),
              '/story-springs': (_) => const ZoneDetailScreen(
                    zoneId: 'story_springs',
                    zoneName: '📖 Story Springs',
                    zoneDescription:
                        'Create stories, express emotions, develop characters',
                    zoneColor: AppColors.storyspringsColor,
                  ),
              '/adventure-arena': (_) => const ZoneDetailScreen(
                    zoneId: 'adventure_arena',
                    zoneName: '🏟️ Adventure Arena',
                    zoneDescription:
                        'Improve hand-eye coordination and motor skills',
                    zoneColor: AppColors.adventureArenaColor,
                  ),
              '/science-explorers': (_) => const ZoneDetailScreen(
                    zoneId: 'science_explorers',
                    zoneName: '🔬 Science Explorers',
                    zoneDescription: 'Discover the world around you!',
                    zoneColor: Color(0xFF4DB6AC),
                  ),
              '/creative-corner': (_) => const ZoneDetailScreen(
                    zoneId: 'creative_corner',
                    zoneName: '🎨 Creative Corner',
                    zoneDescription: 'Express yourself with art and music',
                    zoneColor: Color(0xFFFFB74D),
                  ),
            };
            final builder = routes[settings.name];
            if (builder != null) {
              return FadeSlidePageRoute(page: Builder(builder: builder));
            }
            return null;
          },
        );
      },
    );
  }

  ThemeData _highContrastTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final adjustedScheme = scheme.copyWith(
      primary: isDark ? const Color(0xFFFFD6E5) : const Color(0xFF9A003F),
      secondary: isDark ? const Color(0xFFD8C8FF) : const Color(0xFF3200A3),
      tertiary: isDark ? const Color(0xFFB9FAFF) : const Color(0xFF006B78),
      surface: isDark ? Colors.black : Colors.white,
      onSurface: isDark ? Colors.white : Colors.black,
      error: isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB00020),
    );

    return theme.copyWith(
      colorScheme: adjustedScheme,
      scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
      dividerColor: adjustedScheme.onSurface.withValues(alpha: 0.42),
      focusColor: adjustedScheme.tertiary.withValues(alpha: 0.55),
      highlightColor: adjustedScheme.tertiary.withValues(alpha: 0.18),
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
  late AnimationController _shimmerController;
  late AnimationController _orbitController;
  late bool _prefersReducedMotion;
  bool _startedSplashMusic = false;

  @override
  void initState() {
    super.initState();

    _prefersReducedMotion = WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;

    final logoDuration = _prefersReducedMotion
        ? const Duration(milliseconds: 300)
        : const Duration(milliseconds: 1500);
    final textDuration = _prefersReducedMotion
        ? const Duration(milliseconds: 120)
        : const Duration(milliseconds: 800);
    final shimmerDuration = _prefersReducedMotion
        ? const Duration(milliseconds: 120)
        : const Duration(milliseconds: 900);

    // Logo animation
    _logoController = AnimationController(
      duration: logoDuration,
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
    );
    if (!_prefersReducedMotion) {
      _starsController.repeat();
    }

    // Text animation
    _textController = AnimationController(
      duration: textDuration,
      vsync: this,
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Shimmer sweep across logo once it lands
    _shimmerController = AnimationController(
      duration: shimmerDuration,
      vsync: this,
    );
    // Floating orbit for bottom zone icons
    _orbitController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    if (!_prefersReducedMotion) {
      _orbitController.repeat();
    }

    // Start animations in sequence
    _logoController.forward().then((_) {
      _textController.forward();
      _shimmerController.forward();
    });

    // Best-effort splash audio: silently falls back when no bundled asset exists.
    _startSplashAudio();

    _checkAppState();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _starsController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  Future<void> _checkAppState() async {
    final startedAt = DateTime.now();

    // Load avatar from storage
    await context.read<AvatarProvider>().loadAvatar();

    // Keep the splash long enough to feel intentional, but do not force every
    // returning player to wait three seconds after the app is already ready.
    const minimumSplash = Duration(milliseconds: 900);
    final elapsed = DateTime.now().difference(startedAt);
    if (elapsed < minimumSplash) {
      await Future.delayed(minimumSplash - elapsed);
    }

    if (!mounted) return;

    final avatarProvider = context.read<AvatarProvider>();

    if (!avatarProvider.hasAvatar) {
      // First time user - go to avatar creation
      if (mounted) {
        await _stopSplashAudio();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/avatar-creator');
      }
    } else {
      // Existing user - go to world map
      if (mounted) {
        await _stopSplashAudio();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/world-map');
      }
    }
  }

  Future<void> _startSplashAudio() async {
    if (_startedSplashMusic) return;
    _startedSplashMusic = true;
    await context.read<AudioManager>().playSplashMusic();
  }

  Future<void> _stopSplashAudio() async {
    if (!_startedSplashMusic) return;
    await context.read<AudioManager>().stopMusic();
    _startedSplashMusic = false;
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
                                  // Actual logo image
                                  ClipOval(
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 128,
                                      height: 128,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Shimmer sweep overlay
                                  AnimatedBuilder(
                                    animation: _shimmerController,
                                    builder: (context, child) {
                                      final t = _shimmerController.value;
                                      return ClipOval(
                                        child: SizedBox(
                                          width: 128,
                                          height: 128,
                                          child: IgnorePointer(
                                            child: Transform.translate(
                                              offset: Offset(192 * t - 48, 0),
                                              child: Container(
                                                width: 48,
                                                height: 128,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.white
                                                          .withValues(alpha: 0),
                                                      Colors.white.withValues(
                                                          alpha: 0.5),
                                                      Colors.white
                                                          .withValues(alpha: 0),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
                              'Adventures',
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
                            const SizedBox(height: 20),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: const [
                                _SplashFeatureChip(
                                  icon: Icons.lock_outline,
                                  label: 'Offline first',
                                ),
                                _SplashFeatureChip(
                                  icon: Icons.school_outlined,
                                  label: 'Curriculum aligned',
                                ),
                                _SplashFeatureChip(
                                  icon: Icons.emoji_events_outlined,
                                  label: 'Rewards and streaks',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Loading indicator
                    FadeTransition(
                      opacity: _textOpacity,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 420),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 220,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.16),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Color(0xFF4ECDC4),
                                  ),
                                  minHeight: 7,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Loading your adventure...',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom decorations
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textOpacity,
                child: AnimatedBuilder(
                  animation: _orbitController,
                  builder: (context, child) {
                    const zoneIcons = ['🌲', '🌌', '📖', '🧩', '🏟️'];
                    const zoneLabels = [
                      'Words',
                      'Numbers',
                      'Stories',
                      'Puzzles',
                      'Games'
                    ];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(zoneIcons.length, (i) {
                        final yFloat = math.sin(
                              _orbitController.value * math.pi * 2 + i * 1.2,
                            ) *
                            4.0;
                        return Transform.translate(
                          offset: Offset(0, yFloat),
                          child: _buildZoneIcon(zoneIcons[i], zoneLabels[i]),
                        );
                      }),
                    );
                  },
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

class _SplashFeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SplashFeatureChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
