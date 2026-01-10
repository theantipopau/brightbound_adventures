import 'package:flutter/material.dart';

class TracingWidget extends StatefulWidget {
  final String character;
  final Color color;
  final VoidCallback onComplete;

  const TracingWidget({
    super.key,
    required this.character,
    required this.color,
    required this.onComplete,
  });

  @override
  State<TracingWidget> createState() => _TracingWidgetState();
}

class _TracingWidgetState extends State<TracingWidget> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  void _startStroke(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
      _strokes.add(_currentStroke);
    });
  }

  void _updateStroke(DragUpdateDetails details) {
    setState(() {
      _currentStroke.add(details.localPosition);
    });
  }

  void _endStroke(DragEndDetails details) {
    // Simple validation: if we have enough points, consider it progress
    // In a real app, we'd check if the points match the character shape
  }

  void _clear() {
    setState(() {
      _strokes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: widget.color.withValues(alpha: 0.3), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Character (Guide)
              Center(
                child: Text(
                  widget.character,
                  style: TextStyle(
                    fontSize: 200,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade200,
                    fontFamily:
                        'Fredoka', // Assuming this font exists or use default
                  ),
                ),
              ),
              // Drawing Layer
              GestureDetector(
                key: const Key('tracing_gesture_detector'),
                onPanStart: _startStroke,
                onPanUpdate: _updateStroke,
                onPanEnd: _endStroke,
                child: CustomPaint(
                  painter: _TracingPainter(
                    strokes: _strokes,
                    color: widget.color,
                  ),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              key: const Key('clear_button'),
              onPressed: _clear,
              icon: const Icon(Icons.refresh),
              label: const Text('Clear'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              key: const Key('done_button'),
              onPressed: _strokes.isNotEmpty ? widget.onComplete : null,
              icon: const Icon(Icons.check),
              label: const Text('Done!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TracingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;

  _TracingPainter({required this.strokes, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracingPainter oldDelegate) {
    return true;
  }
}
