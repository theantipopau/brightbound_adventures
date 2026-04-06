import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:brightbound_adventures/core/data/zone_guardian_data.dart';
import 'package:brightbound_adventures/core/services/skill_provider.dart';
import 'package:brightbound_adventures/ui/themes/app_theme.dart';

// ─────────────────────────────────────────────
//  Public API
// ─────────────────────────────────────────────

/// Shows a full-screen zone-mastered celebration dialog.
void showZoneMasteredCelebration(
  BuildContext context, {
  required String zoneId,
  required String zoneName,
  Color themeColor = AppColors.primary,
}) {
  final guardian = guardianForZone(zoneId);
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 600),
    transitionBuilder: (ctx, animation, _, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    pageBuilder: (ctx, _, __) => _ZoneMasteredDialog(
      zoneName: zoneName,
      guardian: guardian,
      themeColor: themeColor,
    ),
  );
}

/// Checks whether all skills in [zoneId] are now mastered (after a progress
/// update), and if so schedules the celebration overlay to appear [delay] ms
/// after the results screen has had time to animate in.
void checkAndShowZoneMastered(
  BuildContext context,
  SkillProvider skillProvider, {
  required String? zoneId,
  required String? zoneName,
  required Color themeColor,
  Duration delay = const Duration(seconds: 2),
}) {
  if (zoneId == null || zoneId.isEmpty) return;
  final stats = skillProvider.getZoneStats(zoneId);
  if (stats.totalSkills > 0 && stats.masteredSkills == stats.totalSkills) {
    Future.delayed(delay, () {
      if (context.mounted) {
        showZoneMasteredCelebration(
          context,
          zoneId: zoneId,
          zoneName: zoneName ?? '',
          themeColor: themeColor,
        );
      }
    });
  }
}

// ─────────────────────────────────────────────
//  Dialog widget
// ─────────────────────────────────────────────

class _ZoneMasteredDialog extends StatefulWidget {
  final String zoneName;
  final ZoneGuardian? guardian;
  final Color themeColor;

  const _ZoneMasteredDialog({
    required this.zoneName,
    required this.guardian,
    required this.themeColor,
  });

  @override
  State<_ZoneMasteredDialog> createState() => _ZoneMasteredDialogState();
}

class _ZoneMasteredDialogState extends State<_ZoneMasteredDialog>
    with TickerProviderStateMixin {
  late AnimationController _guardianController;
  late AnimationController _starsController;
  late AnimationController _confettiController;
  late Animation<double> _guardianBounce;
  late Animation<double> _starsScale;

  static const _confettiColors = [
    Color(0xFFFFD700),
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFF45B7D1),
    Color(0xFF96CEB4),
    Color(0xFFFF8E53),
    Color(0xFFA55EEA),
  ];

  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    // Guardian bounce (up-down loop)
    _guardianController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _guardianBounce = Tween<double>(begin: 0, end: -14).animate(
      CurvedAnimation(parent: _guardianController, curve: Curves.easeInOut),
    );

    // Stars pop-in after a short delay
    _starsController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _starsScale = CurvedAnimation(
      parent: _starsController,
      curve: Curves.elasticOut,
    );

    // Confetti falling loop
    _confettiController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Generate confetti particles
    final rng = math.Random();
    for (int i = 0; i < 80; i++) {
      _particles.add(_ConfettiParticle(random: rng, colors: _confettiColors));
    }

    // Sequence: stars appear after 400 ms
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _starsController.forward();
      });
    });
  }

  @override
  void dispose() {
    _guardianController.dispose();
    _starsController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guardian = widget.guardian;
    final emoji = guardian?.emoji ?? '🏆';
    final message = guardian?.completeMessage ?? 'Zone Mastered! Amazing work!';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Confetti ──────────────────────────────────
          AnimatedBuilder(
            animation: _confettiController,
            builder: (_, __) => CustomPaint(
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _confettiController.value,
              ),
              size: MediaQuery.of(context).size,
            ),
          ),

          // ── Content card ──────────────────────────────
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              padding:
                  const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(widget.themeColor, Colors.white, 0.88)!,
                    Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: widget.themeColor.withValues(alpha: 0.35),
                    blurRadius: 40,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Guardian emoji — bouncing
                  AnimatedBuilder(
                    animation: _guardianBounce,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _guardianBounce.value),
                      child: child,
                    ),
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 72),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // "ZONE MASTERED!" heading in gold gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                    ).createShader(bounds),
                    child: const Text(
                      'ZONE MASTERED!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Zone name
                  Text(
                    widget.zoneName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: widget.themeColor,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3 gold stars with elastic pop-in
                  ScaleTransition(
                    scale: _starsScale,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFFFD700),
                            size: 52,
                            shadows: const [
                              Shadow(
                                color: Color(0x99FFA000),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Guardian complete message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.themeColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.themeColor.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.55,
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Continue Adventure! 🗺️',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Confetti particle model
// ─────────────────────────────────────────────

class _ConfettiParticle {
  final double x; // 0-1 horizontal start
  final double speed;
  final double size;
  final double wobble; // horizontal sway amplitude fraction
  final double wobbleSpeed;
  final double phase;
  final double startY; // staggered vertical start (0-1)
  final Color color;

  _ConfettiParticle({
    required math.Random random,
    required List<Color> colors,
  })  : x = random.nextDouble(),
        speed = 0.18 + random.nextDouble() * 0.35,
        size = 6 + random.nextDouble() * 8,
        wobble = 0.015 + random.nextDouble() * 0.03,
        wobbleSpeed = 2 + random.nextDouble() * 3,
        phase = random.nextDouble() * math.pi * 2,
        startY = random.nextDouble(),
        color = colors[random.nextInt(colors.length)];
}

// ─────────────────────────────────────────────
//  Confetti painter
// ─────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      // Particle falls and loops
      final rawY = (p.startY + progress * p.speed) % 1.0;
      final y = rawY * size.height;

      // Horizontal wobble
      final xOff =
          math.sin(progress * math.pi * 2 * p.wobbleSpeed + p.phase) * p.wobble;
      final x = (p.x + xOff).clamp(0.0, 1.0) * size.width;

      // Fade near bottom
      final opacity = rawY > 0.85
          ? ((1.0 - rawY) / 0.15).clamp(0.0, 1.0)
          : 1.0;

      paint.color = p.color.withValues(alpha: opacity * 0.85);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, y),
            width: p.size,
            height: p.size * 0.55,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
