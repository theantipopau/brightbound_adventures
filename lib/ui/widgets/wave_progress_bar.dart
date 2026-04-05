import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium animated progress bar with a liquid wave fill.
///
/// Drop-in replacement for [LinearProgressIndicator] wherever a more polished
/// look is needed — skill screens, zone progress, daily challenges, etc.
///
/// ```dart
/// WaveProgressBar(
///   progress: 0.65,
///   color: AppColors.wordWoodsColor,
///   height: 20,
/// )
/// ```
class WaveProgressBar extends StatefulWidget {
  /// Fill progress from 0.0 (empty) to 1.0 (full).
  final double progress;

  /// Primary fill colour. A lighter tint is derived automatically for the
  /// wave highlight and background track.
  final Color color;

  /// Height of the bar in logical pixels.
  final double height;

  /// Corner radius. Defaults to half the height (pill shape).
  final double? borderRadius;

  /// Background track colour. Defaults to [color] at 12% opacity.
  final Color? trackColor;

  /// Amplitude of the wave as a fraction of [height] (default 0.25).
  final double waveAmplitude;

  const WaveProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 18,
    this.borderRadius,
    this.trackColor,
    this.waveAmplitude = 0.25,
  });

  @override
  State<WaveProgressBar> createState() => _WaveProgressBarState();
}

class _WaveProgressBarState extends State<WaveProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fillController;
  late Animation<double> _fillAnimation;

  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _previousProgress = widget.progress;

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fillAnimation = Tween<double>(
      begin: widget.progress,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(WaveProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _fillAnimation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic));
      _previousProgress = widget.progress;
      _fillController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? widget.height / 2;
    final track = widget.trackColor ?? widget.color.withValues(alpha: 0.12);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        height: widget.height,
        child: AnimatedBuilder(
          animation: Listenable.merge([_waveController, _fillController]),
          builder: (_, __) => CustomPaint(
            painter: _WavePainter(
              wavePhase: _waveController.value,
              fillLevel: _fillAnimation.value.clamp(0.0, 1.0),
              color: widget.color,
              trackColor: track,
              amplitude: widget.waveAmplitude,
            ),
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double wavePhase;
  final double fillLevel;
  final Color color;
  final Color trackColor;
  final double amplitude;

  const _WavePainter({
    required this.wavePhase,
    required this.fillLevel,
    required this.color,
    required this.trackColor,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ── Background track ────────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = trackColor,
    );

    if (fillLevel <= 0) return;

    // ── Wave fill ──────────────────────────────────────────────────────────
    final amp = size.height * amplitude;
    // y-position of the water surface (measured from the top)
    final surfaceY = size.height * (1.0 - fillLevel);

    // Build the wave path
    final path = Path();
    path.moveTo(0, size.height);

    // Trace the wave surface left → right
    const segments = 60;
    for (int i = 0; i <= segments; i++) {
      final x = size.width * i / segments;
      // Two overlapping sine waves for a more organic look
      final y = surfaceY
          + amp * math.sin(x / size.width * math.pi * 2.5 + wavePhase * math.pi * 2)
          + amp * 0.4 * math.sin(x / size.width * math.pi * 4.2 + wavePhase * math.pi * 2 * 0.7 + 1.0);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    // Primary gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: 0.85),
        color,
      ],
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    // Highlight — a slightly lighter wave drawn on top to create depth
    final highlightPath = Path();
    highlightPath.moveTo(0, size.height);
    for (int i = 0; i <= segments; i++) {
      final x = size.width * i / segments;
      final y = surfaceY - amp * 0.3
          + amp * 0.5 * math.sin(x / size.width * math.pi * 3.1 + wavePhase * math.pi * 2 * 1.3 + 2.5)
          + amp * 0.25 * math.sin(x / size.width * math.pi * 5.7 + wavePhase * math.pi * 2 * 0.9);
      highlightPath.lineTo(x, y);
    }
    highlightPath.lineTo(size.width, size.height);
    highlightPath.close();

    canvas.drawPath(
      highlightPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.wavePhase != wavePhase ||
      old.fillLevel != fillLevel ||
      old.color != color;
}
