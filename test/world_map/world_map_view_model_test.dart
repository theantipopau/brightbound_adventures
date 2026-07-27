import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/features/world_map/models/world_map_view_model.dart';

void main() {
  group('WorldMapViewModel pure logic', () {
    late WorldMapViewModel viewModel;
    late List<ZoneData> testZones;

    setUp(() {
      testZones = [
        const ZoneData(
          id: 'word-woods',
          name: 'Word Woods',
          emoji: '🌲',
          color: Color(0xFFB8A85F),
          position: Offset(0.06, 0.86),
          description: 'Master letters & reading!',
          order: 0,
          requiredStars: 0,
        ),
        const ZoneData(
          id: 'number-nebula',
          name: 'Number Nebula',
          emoji: '🌌',
          color: Color(0xFF6E5BA8),
          position: Offset(0.25, 0.74),
          description: 'Numeric mastery!',
          order: 1,
          requiredStars: 3,
        ),
      ];
      viewModel = WorldMapViewModel(zones: testZones);
    });

    test('isZoneUnlocked returns false when index out of bounds', () {
      final unlocked = viewModel.isZoneUnlocked(10, 0, null);
      expect(unlocked, isFalse);
    });

    test('isZoneUnlocked returns false when star requirement not met', () {
      final unlocked = viewModel.isZoneUnlocked(1, 2, null);
      expect(unlocked, isFalse);
    });

    test('isZoneUnlocked returns true when star requirement is met (no skill group)', () {
      final unlocked = viewModel.isZoneUnlocked(1, 3, null);
      expect(unlocked, isTrue);
    });

    test('zoneProgressFraction returns 0 for zero total skills', () {
      final fraction = viewModel.zoneProgressFraction(5, 0);
      expect(fraction, 0);
    });

    test('zoneProgressFraction clamps to [0, 1]', () {
      expect(viewModel.zoneProgressFraction(3, 5), 0.6);
      expect(viewModel.zoneProgressFraction(5, 5), 1.0);
      expect(viewModel.zoneProgressFraction(0, 5), 0.0);
    });

    test('zoneMoodText returns flavor text for each zone', () {
      expect(
        viewModel.zoneMoodText(testZones[0]),
        'Calm forest trails with vocabulary quests',
      );
      expect(
        viewModel.zoneMoodText(testZones[1]),
        'Cosmic routes with number missions',
      );
    });

    test('zoneFeatureTags returns correct tags per zone', () {
      expect(
        viewModel.zoneFeatureTags(testZones[0]),
        ['Reading', 'Spelling', 'Vocabulary'],
      );
      expect(
        viewModel.zoneFeatureTags(testZones[1]),
        ['Counting', 'Place Value', 'Numeracy'],
      );
    });
  });
}
