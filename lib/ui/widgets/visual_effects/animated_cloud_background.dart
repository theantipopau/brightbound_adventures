import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders a soft, animated background with moving gradients/clouds.
/// Perfect for the "World Map" to give it depth.
class AnimatedCloudBackground extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;

  const AnimatedCloudBackground({
    super.key,
    this.primaryColor = const Color(0xFF4FC3F7), // Sky blue
    this.secondaryColor = const Color(0xFFE1F5FE), // Light sky
  });

  @override
  State<AnimatedCloudBackground> createState() => _AnimatedCloudBackgroundState();
}

class _AnimatedCloudBackgroundState extends State<AnimatedCloudBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
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
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.primaryColor,
                widget.secondaryColor,
                widget.primaryColor.withValues(alpha: 0.8),
              ],
              stops: [
                0.0,
                0.5 + math.sin(_controller.value * math.pi) * 0.2, // Move the center stop
                1.0,
              ],
            ),
          ),
          child: CustomPaint(
            painter: _CloudPainter(time: _controller.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _CloudPainter extends CustomPainter {
  final double time;

  _CloudPainter({required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw some soft white orbs to simulate clouds/atmosphere
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);

    // Orb 1 - Top Left moving Right
    canvas.drawCircle(
      Offset(size.width * (0.2 + time * 0.1), size.height * 0.3),
      size.width * 0.4,
      paint,
    );

    // Orb 2 - Bottom Right moving Left
    canvas.drawCircle(
      Offset(size.width * (0.8 - time * 0.1), size.height * 0.7),
      size.width * 0.5,
      paint,
    );
    
    // Orb 3 - Pulsing center
    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
      
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * (0.3 + math.sin(time * math.pi * 2) * 0.05),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CloudPainter oldDelegate) => true;
}
