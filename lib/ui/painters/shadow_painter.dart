import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/utils/isometric_engine.dart';
import 'package:brightbound_adventures/core/utils/world_map_isometric_helper.dart';

/// Shadow painter for 3D depth
class ShadowPainter extends CustomPainter {
  final List<ZoneData> zones;
  final IsometricPosition? avatarPosition;
  
  ShadowPainter({required this.zones, this.avatarPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    // Draw zone shadows
    for (final zone in zones) {
      final isoPos = WorldMapIsometricHelper.offsetToIsometric(zone.position);
      final screenPos = WorldMapIsometricHelper.gridToScreen(isoPos, size);
      
      // Shadow offset based on light source (top-left)
      final shadowCenter = screenPos + const Offset(15, 50);
      
      canvas.drawOval(
        Rect.fromCenter(center: shadowCenter, width: 100, height: 40),
        shadowPaint,
      );
    }
    
    // Draw avatar shadow
    if (avatarPosition != null) {
      final avatarScreen = WorldMapIsometricHelper.gridToScreen(avatarPosition!, size);
      final shadowCenter = avatarScreen + const Offset(10, 35);
      
      canvas.drawOval(
        Rect.fromCenter(center: shadowCenter, width: 50, height: 20),
        shadowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ShadowPainter oldDelegate) {
    return avatarPosition != oldDelegate.avatarPosition;
  }
}
