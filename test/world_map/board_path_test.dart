import 'dart:math' as math;

import 'package:brightbound_adventures/core/utils/board_path.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the shared board route geometry: the same curves
/// `PathPainter` paints, `WorldMapBoardPainter` tracks, and the pawn walks.
void main() {
  const anchors = <Offset>[
    Offset(100, 200),
    Offset(300, 260),
    Offset(520, 180),
    Offset(700, 320),
  ];

  void expectOffset(Offset actual, Offset expected, {double epsilon = 0.001}) {
    expect(actual.dx, closeTo(expected.dx, epsilon),
        reason: 'x mismatch: $actual vs $expected');
    expect(actual.dy, closeTo(expected.dy, epsilon),
        reason: 'y mismatch: $actual vs $expected');
  }

  group('BoardPath.fromPositions', () {
    test('builds one segment per island hop with the lifted control point', () {
      final path = BoardPath.fromPositions(anchors);

      expect(path.segmentCount, 3);
      expect(path.segments.first.start, anchors[0]);
      expect(path.segments.first.end, anchors[1]);
      // Chord midpoint lifted straight up by the default 30px.
      expect(path.segments.first.control, const Offset(200, 200));
      expect(
        path.segments.last.control,
        Offset((520 + 700) / 2, (180 + 320) / 2 - BoardPath.defaultLift),
      );
    });

    test('pointAt(0) and pointAt(1) land on the first and last anchor', () {
      final path = BoardPath.fromPositions(anchors);
      expectOffset(path.pointAt(0), anchors.first);
      expectOffset(path.pointAt(1), anchors.last);
    });

    // 2026-10-10 pawn-smoothness pass: progress is mapped by arc length
    // (hops sit unevenly and quad beziers are not uniform in t), so
    // boundaries fall at cumulative-length fractions instead of i/n.
    test('each segment boundary lands exactly on its zone anchor', () {
      final path = BoardPath.fromPositions(anchors);
      var running = 0.0;
      for (var i = 0; i < path.segmentCount; i++) {
        running += path.segmentLengths[i];
        expectOffset(path.pointAt(running / path.totalLength), anchors[i + 1]);
      }
    });

    test('mid-hop sample arcs above the straight chord', () {
      final path = BoardPath.fromPositions(anchors);
      final midChord = (anchors[0] + anchors[1]) / 2;
      // Sample the first hop's own arc-length midpoint: the quadratic's
      // speed profile means that is *near*, not exactly, parametric 0.5.
      final midHop =
          path.pointAt(path.segmentLengths.first / 2 / path.totalLength);
      expect(midHop.dy, lessThan(midChord.dy),
          reason: 'route must lift upward between islands');
      expect(midHop.dx, closeTo(200, 8),
          reason: 'hop apex sits above the chord midpoint');
    });

    test('empty/one-position input produces an empty path', () {
      expect(BoardPath.fromPositions([]).isEmpty, isTrue);
      expect(BoardPath.fromPositions([anchors.first]).isEmpty, isTrue);
    });
  });

  group('BoardPath.locate', () {
    test('maps global progress to arc-length-uniform positions', () {
      final path = BoardPath.fromPositions(anchors);
      expect(path.locate(0), (segmentIndex: 0, localT: 0));
      expect(path.locate(1), (segmentIndex: 2, localT: 1.0));
      // Progress 0.5 covers half the total DISTANCE, not half the hops.
      // Measure by dense sampling: localT is parametric within the hop,
      // so arc distance must be walked, not multiplied out.
      double distanceUpTo(double t) {
        var accumulated = 0.0;
        var previous = path.pointAt(0);
        const n = 400;
        for (var i = 1; i <= (n * t).round(); i++) {
          final point = path.pointAt(i / n);
          accumulated += (point - previous).distance;
          previous = point;
        }
        return accumulated;
      }

      expect(distanceUpTo(0.5) / path.totalLength, closeTo(0.5, 0.01),
          reason: 'half progress must mean half the arc length');
    });

    test('clamps out-of-range progress instead of throwing', () {
      final path = BoardPath.fromPositions(anchors);
      expect(path.locate(-0.5).segmentIndex, 0);
      expect(path.locate(1.5).segmentIndex, 2);
      expect(path.locate(1.5).localT, 1.0);
    });
  });

  group('BoardPath.betweenZoneIndexes', () {
    test('forward travel samples the same curve as the full route', () {
      final full = BoardPath.fromPositions(anchors);
      final hop = BoardPath.betweenZoneIndexes(anchors, 1, 2);
      expect(hop.segmentCount, 1);
      // The single hop is full-route segment 1; with arc-length mapping,
      // hop progress t maps to the slice of full-route DISTANCE that the
      // second segment occupies.
      final start = full.segmentLengths[0] / full.totalLength;
      final span = full.segmentLengths[1] / full.totalLength;
      for (final t in const [0.0, 0.25, 0.5, 0.75, 1.0]) {
        expectOffset(hop.pointAt(t), full.pointAt(start + t * span));
      }
    });

    test('backwards travel mirrors forwards progress along the same curves',
        () {
      final forward = BoardPath.betweenZoneIndexes(anchors, 1, 3);
      final backward = BoardPath.betweenZoneIndexes(anchors, 3, 1);
      expect(backward.segmentCount, forward.segmentCount);
      for (final t in const [0.0, 0.1, 0.33, 0.5, 0.9, 1.0]) {
        expectOffset(backward.pointAt(t), forward.pointAt(1 - t));
      }
    });

    test('same-index travel is empty', () {
      final path = BoardPath.betweenZoneIndexes(anchors, 2, 2);
      expect(path.isEmpty, isTrue);
      expect(path.pointAtOrNull(0.5), isNull);
    });
  });

  // 2026-10-10 pawn-smoothness pass: this is the regression guard for the
  // pace snap the old count-based `locate` produced — with islands spaced
  // unevenly, equal progress steps moved unequal distances (about 2.5x
  // between a short and a long hop), which read as the pawn jerking at
  // every waypoint. Arc-length mapping keeps per-step distance ~uniform.
  test('travel pace is uniform: equal progress steps move equal distances',
      () {
    final uneven = <Offset>[
      const Offset(0, 0),
      const Offset(100, 0),
      const Offset(350, 0),
      const Offset(430, 0),
    ];
    final path = BoardPath.fromPositions(uneven);
    const steps = 120;
    var previous = path.pointAt(0);
    final stepLengths = <double>[];
    for (var i = 1; i <= steps; i++) {
      final point = path.pointAt(i / steps);
      stepLengths.add((point - previous).distance);
      previous = point;
    }
    final maxStep = stepLengths.reduce(math.max);
    final minStep = stepLengths.reduce(math.min);
    expect(minStep, greaterThan(0));
    expect(maxStep / minStep, lessThan(1.15),
        reason: 'per-step distance should be ~uniform along the route, '
            'not scaled by hop size');
  });

  test('toPath starts at the first anchor and bounds every anchor', () {
    final path = BoardPath.fromPositions(anchors).toPath();
    final bounds = path.getBounds();
    for (final anchor in anchors) {
      expect(bounds.inflate(0.001).contains(anchor), isTrue,
          reason: '$anchor should fall inside $bounds');
    }
  });
}
