import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP COLORS — consistent palette for the whole app
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  // Brand - Vibrant & Playful
  static const Color primary = Color(0xFFFF4081); // Vibrant Pink
  static const Color primaryLight = Color(0xFFFF80AB);
  static const Color primaryDark = Color(0xFFC51162);
  static const Color secondary = Color(0xFF7C4DFF); // Deep Purple
  static const Color secondaryLight = Color(0xFFB388FF);
  static const Color secondaryDark = Color(0xFF6200EA);
  static const Color tertiary = Color(0xFF00E5FF); // Cyan Accent
  static const Color tertiaryLight = Color(0xFF84FFFF);
  static const Color tertiaryDark = Color(0xFF00B8D4);

  // Backgrounds
  static const Color background = Color(0xFFF8F9FE);
  static const Color bgDark = Color(0xFF1A1B2E);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;

  // Semantic
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF1744);
  static const Color warning = Color(0xFFFFAB00);
  static const Color info = Color(0xFF2979FF);
  static const Color reward = Color(0xFFFFD600); // Gold

  // Text colors
  static const Color textPrimary = Color(0xFF1A1B2E);
  static const Color textSecondary = Color(0xFF626480);
  static const Color textHint = Color(0xFFBBBBCC);

  // Semantic feedback
  static const Color correctFeedback = Color(0xFFE8F5E9);
  static const Color correctFeedbackBorder = Color(0xFF4CAF50);
  static const Color incorrectFeedback = Color(0xFFFFEBEE);
  static const Color incorrectFeedbackBorder = Color(0xFFE53935);

  // Neutral surface states
  static const Color surfaceDisabled = Color(0xFFE8E8F0);
  static const Color surfaceSubtle = Color(0xFFF0F0F8);

  // Shadows and dividers
  static const Color shadowLight = Color(0x1F000000);
  static const Color divider = Color(0xFFE0E5F0);

  // Zone Fallbacks (Reference for WorldTokens)
  static const Color wordWoodsColor = Color(0xFF2D7D32);
  static const Color numberNebulaColor = Color(0xFF3949AB);
  static const Color storyspringsColor = Color(0xFF1565C0);
  static const Color puzzlePeaksColor = Color(0xFF6A1B9A);
  static const Color adventureArenaColor = Color(0xFFF9A825);
}

// ─────────────────────────────────────────────────────────────────────────────
// APP TYPOGRAPHY — clear, playful, and legible
// ─────────────────────────────────────────────────────────────────────────────
class AppTypography {
  static const String fontPrimary = 'Fredoka';
  static const String fontBody = 'Comfortaa';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontBody,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontPrimary,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    color: Colors.white,
  );

  // Keep responsive helpers
  static TextStyle responsiveDisplay(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return displaySmall;
    if (width < 900) return displayMedium;
    return displayLarge;
  }

  // Define missing responsive helpers used in lightTheme if they were there
  static TextStyle titleSmall = titleLarge.copyWith(fontSize: 16);
  static TextStyle titleMedium = titleLarge.copyWith(fontSize: 18);
  static TextStyle headlineMedium = headlineLarge.copyWith(fontSize: 20);
  static TextStyle headlineSmall = headlineLarge.copyWith(fontSize: 18);
  static TextStyle bodySmall = bodyMedium.copyWith(fontSize: 14);
  static TextStyle labelMedium = labelLarge.copyWith(fontSize: 14);
  static TextStyle labelSmall = labelLarge.copyWith(fontSize: 12);
}

// ─────────────────────────────────────────────────────────────────────────────
// APP BORDERS & SPACING — consistent layout system
// ─────────────────────────────────────────────────────────────────────────────
class AppBorders {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double pill = 50.0;

  static Radius smRadius = const Radius.circular(sm);
  static Radius mdRadius = const Radius.circular(md);
  static Radius lgRadius = const Radius.circular(lg);
  static Radius xlRadius = const Radius.circular(xl);
  static Radius pillRadius = const Radius.circular(pill);

  static BorderRadius radiusSm = BorderRadius.circular(sm);
  static BorderRadius radiusMd = BorderRadius.circular(md);
  static BorderRadius radiusLg = BorderRadius.circular(lg);
  static BorderRadius radiusXl = BorderRadius.circular(xl);
  static BorderRadius radiusPill = BorderRadius.circular(pill);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ─────────────────────────────────────────────────────────────────────────────
// APP MOTION — standard durations and curves for consistent animation feel
// ─────────────────────────────────────────────────────────────────────────────
class AppMotion {
  // Durations
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration standard = Duration(milliseconds: 280);
  static const Duration smooth = Duration(milliseconds: 400);
  static const Duration deliberate = Duration(milliseconds: 600);
  static const Duration dramatic = Duration(milliseconds: 900);
  static const Duration epic = Duration(milliseconds: 1400);

  // Curves
  static const Curve enter = Curves.easeOutCubic;
  static const Curve pop = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;
  static const Curve hover = Curves.easeInOut;
  static const Curve press = Curves.easeInBack;
  static const Curve bounce = Curves.bounceOut;
  static const Curve spring = Curves.fastLinearToSlowEaseIn;
}

// ─────────────────────────────────────────────────────────────────────────────
// APP SHADOWS — standardized elevation and glow effects
// ─────────────────────────────────────────────────────────────────────────────
class AppShadows {
  /// Subtle card lift
  static List<BoxShadow> sm(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.12),
      blurRadius: 8,
      offset: const Offset(0, 3),
    ),
  ];

  /// Standard card shadow
  static List<BoxShadow> md(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.18),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 1,
    ),
  ];

  /// Elevated panel
  static List<BoxShadow> lg(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.22),
      blurRadius: 28,
      offset: const Offset(0, 10),
      spreadRadius: 2,
    ),
  ];

  /// Glow effect (no offset, spread-based)
  static List<BoxShadow> glow(Color color, {double intensity = 0.5}) => [
    BoxShadow(
      color: color.withValues(alpha: intensity * 0.6),
      blurRadius: 20,
      spreadRadius: 4,
    ),
    BoxShadow(
      color: color.withValues(alpha: intensity * 0.25),
      blurRadius: 40,
      spreadRadius: 8,
    ),
  ];

  /// Outer ring glow for stars/trophies
  static List<BoxShadow> pulse(Color color, double progress) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3 + progress * 0.3),
      blurRadius: 12 + progress * 20,
      spreadRadius: progress * 6,
    ),
  ];

  /// Neutral soft shadow
  static const List<BoxShadow> neutral = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// WORLD TOKENS — design tokens per zone for consistent world identity
// ─────────────────────────────────────────────────────────────────────────────
class WorldTokens {
  final String zoneId;
  final String displayName;
  final String emoji;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final List<Color> skyGradient;
  final List<String> ambientParticles;
  final String subject;

  const WorldTokens({
    required this.zoneId,
    required this.displayName,
    required this.emoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.skyGradient,
    required this.ambientParticles,
    required this.subject,
  });

  // ── Quick access for quiz/detail backgrounds ──────────────────
  LinearGradient get quizBackground => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      skyGradient.first.withValues(alpha: 0.18),
      skyGradient.last.withValues(alpha: 0.06),
    ],
  );

  LinearGradient get headerGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomCenter,
    colors: [primaryColor, secondaryColor],
  );

  BoxDecoration cardDecoration({bool hovered = false}) => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, primaryColor.withValues(alpha: 0.06)],
    ),
    borderRadius: BorderRadius.circular(AppBorders.lg),
    border: Border.all(
      color: primaryColor.withValues(alpha: hovered ? 0.55 : 0.25),
      width: hovered ? 2.5 : 1.5,
    ),
    boxShadow: hovered
        ? AppShadows.md(primaryColor)
        : AppShadows.sm(primaryColor),
  );

  // ── Static instances per zone ──────────────────────────────────
  static const WordWoods = WorldTokens(
    zoneId: 'word-woods',
    displayName: 'Word Woods',
    emoji: '🌲',
    primaryColor: Color(0xFF2D7D32),   // Forest green
    secondaryColor: Color(0xFF1B5E20),
    accentColor: Color(0xFF81C784),
    skyGradient: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    ambientParticles: ['🍃', '🌿', '🌲', '🦋', '✨', '📚'],
    subject: 'literacy',
  );

  static const NumberNebula = WorldTokens(
    zoneId: 'number-nebula',
    displayName: 'Number Nebula',
    emoji: '🌌',
    primaryColor: Color(0xFF3949AB),   // Indigo
    secondaryColor: Color(0xFF1A237E),
    accentColor: Color(0xFF7986CB),
    skyGradient: [Color(0xFFE8EAF6), Color(0xFFC5CAE9)],
    ambientParticles: ['⭐', '✨', '🌟', '💫', '🔢', '➕'],
    subject: 'numeracy',
  );

  static const MathFacts = WorldTokens(
    zoneId: 'math-facts',
    displayName: 'Math Facts',
    emoji: '🔢',
    primaryColor: Color(0xFFE53935),   // Red
    secondaryColor: Color(0xFFB71C1C),
    accentColor: Color(0xFFEF9A9A),
    skyGradient: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
    ambientParticles: ['➕', '➖', '✖️', '➗', '🔢', '💡'],
    subject: 'numeracy',
  );

  static const StorySprings = WorldTokens(
    zoneId: 'story-springs',
    displayName: 'Story Springs',
    emoji: '📖',
    primaryColor: Color(0xFF1565C0),   // Blue
    secondaryColor: Color(0xFF0D47A1),
    accentColor: Color(0xFF64B5F6),
    skyGradient: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    ambientParticles: ['📖', '✨', '💭', '🎭', '🌊', '💫'],
    subject: 'storytelling',
  );

  static const ScienceExplorers = WorldTokens(
    zoneId: 'science-explorers',
    displayName: 'Science Explorers',
    emoji: '🔬',
    primaryColor: Color(0xFF00695C),   // Teal
    secondaryColor: Color(0xFF004D40),
    accentColor: Color(0xFF4DB6AC),
    skyGradient: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
    ambientParticles: ['🔬', '🧬', '🧪', '🔭', '🪐', '✨'],
    subject: 'science',
  );

  static const CreativeCorner = WorldTokens(
    zoneId: 'creative-corner',
    displayName: 'Creative Corner',
    emoji: '🎨',
    primaryColor: Color(0xFFE65100),   // Deep orange
    secondaryColor: Color(0xFFBF360C),
    accentColor: Color(0xFFFFB74D),
    skyGradient: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    ambientParticles: ['🎨', '🖌️', '🎵', '🎹', '🌈', '✨'],
    subject: 'creative',
  );

  static const PuzzlePeaks = WorldTokens(
    zoneId: 'puzzle-peaks',
    displayName: 'Puzzle Peaks',
    emoji: '🧩',
    primaryColor: Color(0xFF6A1B9A),   // Purple
    secondaryColor: Color(0xFF4A148C),
    accentColor: Color(0xFFCE93D8),
    skyGradient: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
    ambientParticles: ['🧩', '⚡', '💡', '🎯', '🔮', '✨'],
    subject: 'logic',
  );

  static const AdventureArena = WorldTokens(
    zoneId: 'adventure-arena',
    displayName: 'Adventure Arena',
    emoji: '🏆',
    primaryColor: Color(0xFFF9A825),   // Gold
    secondaryColor: Color(0xFFF57F17),
    accentColor: Color(0xFFFFEE58),
    skyGradient: [Color(0xFFFFFDE7), Color(0xFFFFF9C4)],
    ambientParticles: ['🏆', '⭐', '🎖️', '🌟', '🎯', '🔥'],
    subject: 'mixed',
  );

  static const List<WorldTokens> all = [
    WordWoods, NumberNebula, MathFacts, StorySprings,
    ScienceExplorers, CreativeCorner, PuzzlePeaks, AdventureArena,
  ];

  /// Resolve from a zone ID or subject string (fallback gracefully)
  static WorldTokens fromZoneId(String zoneId) {
    for (final w in all) {
      if (w.zoneId == zoneId) return w;
    }
    // Subject fallback
    return WordWoods;
  }

  static WorldTokens fromColor(Color color) {
    // Find nearest world token by primary color
    double best = double.infinity;
    WorldTokens result = WordWoods;
    for (final w in all) {
      final dr = (w.primaryColor.r - color.r).abs();
      final dg = (w.primaryColor.g - color.g).abs();
      final db = (w.primaryColor.b - color.b).abs();
      final dist = dr + dg + db;
      if (dist < best) { best = dist; result = w; }
    }
    return result;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP GRADIENTS — reusable gradients
// ─────────────────────────────────────────────────────────────────────────────
class AppGradients {
  static LinearGradient primary = const LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient success = const LinearGradient(
    colors: [Color(0xFF06A77D), Color(0xFF048A68)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient warning = const LinearGradient(
    colors: [Color(0xFFFFB703), Color(0xFFE09600)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient error = const LinearGradient(
    colors: [Color(0xFFE63946), Color(0xFFBF2930)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient gold = const LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient sky = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF87CEEB), Color(0xFFE0F7FA)],
  );

  static LinearGradient playBackground = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0F4FF), Color(0xFFFDF6FF)],
  );
}

class AppTheme {
  // Font families
  static const String fontPrimary = 'Fredoka';
  static const String fontBody = 'Comfortaa';
  static const String fontEmoji = 'NotoEmoji';

  static ThemeData lightTheme() {
    const primaryColor = AppColors.primary;
    const secondaryColor = AppColors.secondary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: fontPrimary,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.tertiary,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.tertiaryLight,
        onTertiaryContainer: AppColors.tertiaryDark,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineLarge.copyWith(
          color: Colors.white,
        ),
      ),
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      // Text theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
      ),
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return AppColors.surface;
        }),
        side: const BorderSide(color: AppColors.divider, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
