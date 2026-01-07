import 'package:flutter/material.dart';

/// Data class for zone information in the world map
class ZoneData {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final Offset position;
  final String description;
  final int order;
  final int requiredStars;

  const ZoneData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.position,
    required this.description,
    required this.order,
    required this.requiredStars,
  });
}
