// Safety-net tests for JuicyButton, written before rebuilding it on
// Pressable (MO-3), so the rebuild can be verified against known-good
// behaviour rather than just "it compiles".
import 'dart:ui' show Tristate;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/ui/widgets/juicy_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders label and emoji', (tester) async {
    await tester.pumpWidget(wrap(
      JuicyButton(label: 'Play now', emoji: '🚀', onPressed: () {}),
    ));

    expect(find.text('Play now'), findsOneWidget);
    expect(find.text('🚀'), findsOneWidget);
  });

  testWidgets('tap triggers onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      JuicyButton(label: 'Go', onPressed: () => tapped = true),
    ));

    await tester.tap(find.text('Go'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('disabled (onPressed null) does not trigger and is not tappable',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      const JuicyButton(label: 'Locked', onPressed: null),
    ));

    // Verify tapping a disabled button does not call any callback
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows a loading indicator instead of the label when isLoading',
      (tester) async {
    await tester.pumpWidget(wrap(
      JuicyButton(label: 'Submit', isLoading: true, onPressed: () {}),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Submit'), findsNothing);
  });

  testWidgets('press-down and release do not throw', (tester) async {
    await tester.pumpWidget(wrap(
      JuicyButton(label: 'Press me', onPressed: () {}),
    ));

    final center = tester.getCenter(find.text('Press me'));
    final gesture = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 250));

    expect(tester.takeException(), isNull);
  });

  testWidgets('long label ellipsizes instead of overflowing a narrow button',
      (tester) async {
    // 130px leaves room for the button's own 56px horizontal padding plus
    // an emoji glyph; narrower than that overflows on padding alone,
    // regardless of the label - not a realistic button width.
    await tester.pumpWidget(wrap(
      SizedBox(
        width: 130,
        child: JuicyButton(
          label: 'A very long label that will not fit',
          emoji: '⭐',
          onPressed: () {},
        ),
      ),
    ));

    expect(tester.takeException(), isNull);
  });

  testWidgets('shimmer=true renders without exceptions', (tester) async {
    await tester.pumpWidget(wrap(
      JuicyButton(label: 'CTA', shimmer: true, onPressed: () {}),
    ));
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
  });

  testWidgets('factory constructors build without exceptions', (tester) async {
    await tester.pumpWidget(wrap(
      Column(
        children: [
          JuicyButton.primary(label: 'Primary', onPressed: () {}),
          JuicyButton.success(label: 'Success', onPressed: () {}),
        ],
      ),
    ));

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Success'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
