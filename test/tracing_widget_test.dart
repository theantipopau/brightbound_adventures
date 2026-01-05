import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/ui/widgets/tracing_widget.dart';

void main() {
  testWidgets('TracingWidget captures strokes', (WidgetTester tester) async {
    bool completed = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TracingWidget(
            character: 'A',
            color: Colors.blue,
            onComplete: () {
              completed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Done!'), findsOneWidget);

    // Verify "Done!" button is disabled initially
    final doneButtonFinder = find.byKey(const Key('done_button'));
    expect(doneButtonFinder, findsOneWidget);
    
    final doneButton = tester.widget<ElevatedButton>(doneButtonFinder);
    expect(doneButton.onPressed, isNull);

    // Simulate drawing
    final drawingAreaFinder = find.byKey(const Key('tracing_gesture_detector'));
    final center = tester.getCenter(drawingAreaFinder);
    
    final gesture = await tester.startGesture(center);
    await gesture.moveBy(const Offset(0, 50));
    await gesture.up();
    await tester.pump();

    // Verify "Done!" button is enabled after drawing
    final doneButtonEnabled = tester.widget<ElevatedButton>(doneButtonFinder);
    expect(doneButtonEnabled.onPressed, isNotNull);

    // Tap "Done!"
    await tester.tap(doneButtonFinder);
    await tester.pump();

    expect(completed, isTrue);
    
    // Tap "Clear"
    await tester.tap(find.text('Clear'));
    await tester.pump();
    
    // Verify "Done!" button is disabled again
    final doneButtonCleared = tester.widget<ElevatedButton>(doneButtonFinder);
    expect(doneButtonCleared.onPressed, isNull);
  });
}
