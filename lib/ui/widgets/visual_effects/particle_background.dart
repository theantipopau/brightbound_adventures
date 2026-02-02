import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A reusable widget that renders floating emoji particles in the background.
/// Can be used to create themes like "Space" (stars), "Forest" (leaves), etc.
class ParticleBackground extends StatefulWidget {
  final List<String> particles;
  final Color? baseColor;
  final int particleCount;
  final double speedMultiplier;

  const ParticleBackground({
    super.key,
    required this.particles,
    this.baseColor,
    this.particleCount = 20,
    this.speedMultiplier = 1.0,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _generatedParticles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    _initParticles();
  }

  void _initParticles() {
    final random = math.Random();
    _generatedParticles = List.generate(widget.particleCount, (index) {
      return _Particle(
        emoji: widget.particles[random.nextInt(widget.particles.length)],
        x: random.nextDouble(),
        y: random.nextDouble(), // Start anywhere on screen
        speed: (0.1 + random.nextDouble() * 0.2) * widget.speedMultiplier,
        size: 10 + random.nextDouble() * 20,
        opacity: 0.3 + random.nextDouble() * 0.4,
        wobbleOffset: random.nextDouble() * 2 * math.pi,
        wobbleSpeed: 1 + random.nextDouble() * 2,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.baseColor ?? Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ParticlePainter(
              particles: _generatedParticles,
              progress: _controller.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _Particle {
  final String emoji;
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;
  final double wobbleOffset;
  final double wobbleSpeed;

  _Particle({
    required this.emoji,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.wobbleOffset,
    required this.wobbleSpeed,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // We simulate movement by using the controller's progress, 
    // but since we want continuous looping, we just add speed * delta 
    // in a real game loop. However, for a simple declarative animation,
    // we can calculate position based on time.
    
    // Actually, to make them wrap properly without complex state management in painter,
    // let's just use the progress to advance them.
    // BUT: To make them independent, we better use stateful updates or time-based pos.
    // Let's stick to a simple vertical flow for now:
    // y = (initialY - progress * speed) % 1.0 (scrolling up)
    
    // Better: Update the generic "tick" and calculate positions.
    // Since `progress` loops 0->1, we can use that as a time delta 
    // if we tracked previous time. But simpler: just position = (start + time * speed) % 1.
    // Wait, the controller duration is 10s.
    
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (var particle in particles) {
      // Calculate position
      // Move UP: y decreases
      double currentY = (particle.y - (time * particle.speed)) % 1.2;
      // Map 1.2 range back to -0.2 to 1.0 so they start below and end above
      if (currentY < -0.2) currentY += 1.2;
      
      // Add wobble to X
      double currentX = particle.x + math.sin(time * particle.wobbleSpeed + particle.wobbleOffset) * 0.05;
      
      final offset = Offset(
        currentX * size.width,
        (currentY - 0.1) * size.height, // -0.1 to account for 1.2 range shift
      );

      // Draw
      textPainter.text = TextSpan(
        text: particle.emoji,
        style: TextStyle(
          fontSize: particle.size,
          color: Colors.white.withValues(alpha: particle.opacity), 
        ),
      );
      
      textPainter.layout();
      
      // Only draw if on screen
      if (offset.dy > -50 && offset.dy < size.height + 50) {
        textPainter.paint(
          canvas, 
          offset - Offset(textPainter.width / 2, textPainter.height / 2)
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true; // Always repaint for animation
}
