import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/services/animation_service.dart';

/// Widget that displays a confetti burst animation
/// 
/// Used to celebrate correct answers and achievements
class ConfettiBurst extends StatefulWidget {
  /// Center point where confetti bursts from
  final Offset center;

  /// Duration of the animation
  final Duration duration;

  /// Callback when animation completes
  final VoidCallback? onComplete;

  /// Custom colors for confetti particles
  /// If null, uses rainbow colors
  final List<Color>? colors;

  /// Number of particles to display
  final int particleCount;

  const ConfettiBurst({
    super.key,
    required this.center,
    this.duration = const Duration(milliseconds: 2000),
    this.onComplete,
    this.colors,
    this.particleCount = 40,
  }) : super();

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();

    // Generate confetti particles
    _particles = AnimationService.generateConfetti(
      center: widget.center,
      count: widget.particleCount,
      colors: widget.colors,
    );

    // Create animation controller
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Start animation
    _controller.forward().then((_) {
      // Notify completion
      widget.onComplete?.call();
      // Note: Widget will be removed by parent, so don't setState here
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
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            elapsed: _controller.value * widget.duration.inMilliseconds / 1000.0,
            totalDuration: widget.duration.inMilliseconds / 1000.0,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

/// Custom painter that renders confetti particles
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double elapsed; // in seconds
  final double totalDuration; // in seconds

  ConfettiPainter({
    required this.particles,
    required this.elapsed,
    required this.totalDuration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final position = particle.getPosition(elapsed);

      // Skip particles that are off-screen
      if (position.dx < -20 || position.dx > size.width + 20 ||
          position.dy > size.height + 20) {
        continue;
      }

      // Calculate opacity with fade-out
      final opacity = particle.getOpacity(elapsed, totalDuration);

      // Get rotation
      final rotation = particle.getRotation(elapsed);

      // Paint the particle with opacity
      _paintParticle(
        canvas,
        position,
        particle.size,
        particle.color.withValues(alpha: opacity),
        rotation,
      );
    }
  }

  void _paintParticle(
    Canvas canvas,
    Offset position,
    double size,
    Color color,
    double rotation,
  ) {
    // Save canvas state
    canvas.save();

    // Translate to particle position
    canvas.translate(position.dx, position.dy);

    // Rotate around center
    canvas.rotate(rotation);

    // Draw rectangle/square confetti piece
    final paint = Paint()..color = color;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size,
        height: size,
      ),
      paint,
    );

    // Restore canvas state
    canvas.restore();
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.elapsed != elapsed;
  }
}
