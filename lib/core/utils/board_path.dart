import 'dart:ui';

/// One quadratic-bezier hop of the world-map board route between two
/// neighbouring zone islands.
///
/// The control point sits at the chord midpoint lifted vertically so the
/// route arcs "up" the screen — the same lift the board has always used —
/// which reads as depth on the 2.5D diorama.
class BoardSegment {
  const BoardSegment(this.start, this.control, this.end);

  final Offset start;
  final Offset control;
  final Offset end;

  /// Point on this hop at parametric position [t] (0 = start, 1 = end).
  Offset pointAt(double t) {
    final u = 1 - t;
    final a = u * u;
    final b = 2 * u * t;
    final c = t * t;
    return Offset(
      a * start.dx + b * control.dx + c * end.dx,
      a * start.dy + b * control.dy + c * end.dy,
    );
  }

  /// Unit-ish direction of travel at [t]; useful for banking/leaning the
  /// pawn while it walks the route.
  Offset tangentAt(double t) {
    final u = 1 - t;
    return Offset(
      2 * u * (control.dx - start.dx) + 2 * t * (end.dx - control.dx),
      2 * u * (control.dy - start.dy) + 2 * t * (end.dy - control.dy),
    );
  }

  /// The same curve traversed backwards (the control point is shared because
  /// a quadratic bezier is symmetric in its endpoints).
  BoardSegment reversed() => BoardSegment(end, control, start);
}

/// The full board route: an ordered chain of [BoardSegment]s connecting
/// zone islands in progression order.
///
/// This is the single source of truth for the route geometry — the painter
/// that draws the route and the pawn that walks it both read from here, so
/// the character always stands exactly on the track.
class BoardPath {
  BoardPath(this.segments) {
    _buildArcLengthTables();
  }

  /// Vertical lift applied to each hop's control point.
  static const double defaultLift = 30;

  /// Samples per hop used to approximate arc length (2026-10-10 pawn
  /// smoothness pass). Quadratic beziers are not uniform in their
  /// parameter, and islands sit unevenly, so progress has to be mapped by
  /// distance or the pawn's pace snaps at every waypoint.
  static const int _samplesPerSegment = 48;

  final List<BoardSegment> segments;

  /// Per-segment cumulative sampled lengths (index 0.._samplesPerSegment).
  late final List<List<double>> _segmentTables;

  /// Cumulative length after each segment: length == segments.length + 1.
  late final List<double> _cumulativeLengths;

  bool get isEmpty => segments.isEmpty;
  int get segmentCount => segments.length;

  /// Total arc length of the route.
  double get totalLength => _cumulativeLengths.last;

  /// Arc length of each hop, in order.
  List<double> get segmentLengths => [
        for (var i = 0; i < segments.length; i++)
          _cumulativeLengths[i + 1] - _cumulativeLengths[i],
      ];

  void _buildArcLengthTables() {
    _segmentTables = [];
    _cumulativeLengths = [0.0];
    for (final segment in segments) {
      final table = <double>[0.0];
      var previous = segment.pointAt(0);
      var accumulated = 0.0;
      for (var i = 1; i <= _samplesPerSegment; i++) {
        final point = segment.pointAt(i / _samplesPerSegment);
        accumulated += (point - previous).distance;
        table.add(accumulated);
        previous = point;
      }
      _segmentTables.add(table);
      _cumulativeLengths.add(_cumulativeLengths.last + accumulated);
    }
  }

  /// Full route through [positions] in list order.
  factory BoardPath.fromPositions(
    List<Offset> positions, {
    double lift = defaultLift,
  }) {
    final segments = <BoardSegment>[];
    for (var i = 0; i < positions.length - 1; i++) {
      segments.add(_segmentBetween(positions[i], positions[i + 1], lift));
    }
    return BoardPath(segments);
  }

  /// The stretch of route from zone index [fromIndex] to zone index
  /// [toIndex], oriented so index 0 of the result is the start of travel.
  /// Travelling backwards reuses the same curves in reverse.
  factory BoardPath.betweenZoneIndexes(
    List<Offset> positions,
    int fromIndex,
    int toIndex, {
    double lift = defaultLift,
  }) {
    if (fromIndex == toIndex || positions.isEmpty) return BoardPath([]);
    if (fromIndex < toIndex) {
      return BoardPath.fromPositions(
        positions.sublist(fromIndex, toIndex + 1),
        lift: lift,
      );
    }
    final backwards =
        positions.sublist(toIndex, fromIndex + 1).reversed.toList();
    return BoardPath.fromPositions(backwards, lift: lift);
  }

  static BoardSegment _segmentBetween(Offset a, Offset b, double lift) {
    return BoardSegment(
      a,
      Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 - lift),
      b,
    );
  }

  /// Which hop of the chain, and how far along it, a global progress value
  /// maps to. [t] is clamped to 0..1 across the whole path.
  ///
  /// Mapped by ARC LENGTH (both across hops and inside each hop), not by
  /// segment count: islands sit unevenly and quadratic beziers are not
  /// uniform in their parameter, so the old count-based mapping made the
  /// pawn visibly change pace at every waypoint.
  ({int segmentIndex, double localT}) locate(double t) {
    if (segments.isEmpty) return (segmentIndex: 0, localT: 0);
    final clamped = t.clamp(0.0, 1.0);
    final target = clamped * totalLength;

    var index = 0;
    while (
        index < segments.length - 1 && _cumulativeLengths[index + 1] < target) {
      index++;
    }
    final segmentStart = _cumulativeLengths[index];
    final segmentLength = _cumulativeLengths[index + 1] - segmentStart;
    if (segmentLength <= 0) return (segmentIndex: index, localT: 0);

    final withinSegment = target - segmentStart;
    final table = _segmentTables[index];
    var i = 0;
    while (i < _samplesPerSegment - 1 && table[i + 1] < withinSegment) {
      i++;
    }
    final low = table[i];
    final high = table[i + 1];
    final local = high > low ? (withinSegment - low) / (high - low) : 0.0;
    // Clamp: (cumLen[i+1] - cumLen[i]) can differ from the table's last
    // entry by an ulp, which would push localT a hair past 1 at exactly
    // the segment boundary.
    final localT = ((i + local) / _samplesPerSegment).clamp(0.0, 1.0);
    return (segmentIndex: index, localT: localT);
  }

  /// Point on the whole route at global progress [t] (0..1, evenly divided
  /// between hops so travel speed stays constant between islands).
  Offset pointAt(double t) {
    if (segments.isEmpty) return Offset.zero;
    final located = locate(t);
    return segments[located.segmentIndex].pointAt(located.localT);
  }

  /// Same as [pointAt], but only evaluates the underlying curves when the
  /// path is non-empty; callers fall back to their resting position.
  Offset? pointAtOrNull(double t) => isEmpty ? null : pointAt(t);

  /// Materialises the route as a [Path] for painting.
  Path toPath() {
    final path = Path();
    if (segments.isEmpty) return path;
    path.moveTo(segments.first.start.dx, segments.first.start.dy);
    for (final segment in segments) {
      path.quadraticBezierTo(
        segment.control.dx,
        segment.control.dy,
        segment.end.dx,
        segment.end.dy,
      );
    }
    return path;
  }
}
