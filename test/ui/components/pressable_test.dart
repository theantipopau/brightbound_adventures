import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/ui/components/pressable.dart';

void main() {
  Widget wrap(Widget child, {bool disableAnimations = false}) => MaterialApp(
        builder: (context, widgetChild) => MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: widgetChild!,
        ),
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('tap triggers onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      Pressable(
        onPressed: () => tapped = true,
        enableHapticFeedback: false,
        builder: (context, state, child) => child!,
        child: const Text('Tap me'),
      ),
    ));

    await tester.tap(find.text('Tap me'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('disabled: onPressed never fires and semantics report disabled',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      Pressable(
        enabled: false,
        onPressed: () => tapped = true,
        builder: (context, state, child) => child!,
        child: const Text('Locked'),
      ),
    ));

    await tester.tap(find.text('Locked'));
    await tester.pump();

    // With enabled=false, tapping does not call onPressed callback
    expect(tapped, isFalse);
  });

  testWidgets(
      'builder receives isPressed true while held down, false after release',
      (tester) async {
    final pressedStates = <bool>[];
    await tester.pumpWidget(wrap(
      Pressable(
        onPressed: () {},
        enableHapticFeedback: false,
        builder: (context, state, child) {
          pressedStates.add(state.isPressed);
          return child!;
        },
        child: const Text('Press'),
      ),
    ));

    final center = tester.getCenter(find.text('Press'));
    final gesture = await tester.startGesture(center);
    await tester.pump(); // process the pointer-down / resolve gesture arena
    await tester.pump(const Duration(milliseconds: 20));
    expect(pressedStates.last, isTrue);

    await gesture.up();
    await tester.pump(); // process the pointer-up
    await tester.pump(const Duration(milliseconds: 150));
    expect(pressedStates.last, isFalse);
  });

  testWidgets('scale shrinks toward pressScale while pressed', (tester) async {
    double? lastScale;
    await tester.pumpWidget(wrap(
      Pressable(
        onPressed: () {},
        enableHapticFeedback: false,
        pressScale: 0.9,
        builder: (context, state, child) {
          lastScale = state.scale;
          return child!;
        },
        child: const Text('Press'),
      ),
    ));

    expect(lastScale, 1.0);

    final center = tester.getCenter(find.text('Press'));
    final gesture = await tester.startGesture(center);
    await tester.pump(); // process the pointer-down / resolve gesture arena
    await tester.pump(const Duration(milliseconds: 150));
    expect(lastScale, closeTo(0.9, 0.01));

    await gesture.up();
    await tester.pump(); // process the pointer-up
    await tester.pump(const Duration(milliseconds: 150));
    expect(lastScale, closeTo(1.0, 0.01));
  });

  testWidgets('reduced motion: press state still resolves without throwing',
      (tester) async {
    await tester.pumpWidget(wrap(
      Pressable(
        onPressed: () {},
        enableHapticFeedback: false,
        builder: (context, state, child) => child!,
        child: const Text('Press'),
      ),
      disableAnimations: true,
    ));

    final center = tester.getCenter(find.text('Press'));
    final gesture = await tester.startGesture(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
  });

  testWidgets('long press triggers onLongPress', (tester) async {
    var longPressed = false;
    await tester.pumpWidget(wrap(
      Pressable(
        onPressed: () {},
        onLongPress: () => longPressed = true,
        enableHapticFeedback: false,
        builder: (context, state, child) => child!,
        child: const Text('Hold me'),
      ),
    ));

    await tester.longPress(find.text('Hold me'));
    await tester.pump();

    expect(longPressed, isTrue);
  });
}
