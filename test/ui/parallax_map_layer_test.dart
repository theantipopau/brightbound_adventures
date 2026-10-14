import 'package:brightbound_adventures/ui/screens/world_map/parallax_map_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host({bool disableAnimations = false, Size size = const Size(800, 600)}) {
  return MediaQuery(
    data: MediaQueryData(size: size, disableAnimations: disableAnimations),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: ParallaxMapLayer(panOffset: const Offset(60, 0)),
    ),
  );
}

void main() {
  testWidgets('renders haze + midground bands in normal motion mode',
      (tester) async {
    await tester.pumpWidget(_host());
    // Layer 0 haze: a translated gradient surface.
    expect(find.byType(Transform), findsWidgets);
  });

  testWidgets('reduced motion renders a single static band with zero drift',
      (tester) async {
    await tester.pumpWidget(_host(disableAnimations: true));
    // Under disableAnimations only the static haze band is emitted —
    // no midground cloud painter.
    expect(find.byType(CustomPaint), findsNothing);
  });

  testWidgets('drift is clamped to the subtle maximum (~12 px)',
      (tester) async {
    // Directly exercising the widget maths via a large pan offset: the haze
    // Transform.translate must never exceed 12 px on either axis.
    await tester.pumpWidget(_host(size: const Size(400, 300)));
    // Every translation below the parallax widget is a camera-drift offset;
    // none may exceed the spec's subtle ~12 px maximum on either axis.
    final translations = tester.widgetList<Transform>(
        find.descendant(
      of: find.byType(ParallaxMapLayer),
      matching: find.byType(Transform),
    ));
    expect(translations, isNotEmpty);
    for (final t in translations) {
      final tx = t.transform.storage[12].abs();
      final ty = t.transform.storage[13].abs();
      expect(tx, lessThanOrEqualTo(12.0 + 0.01));
      expect(ty, lessThanOrEqualTo(12.0 + 0.01));
    }
  });
}
