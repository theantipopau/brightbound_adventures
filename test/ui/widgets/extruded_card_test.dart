// Safety-net tests for the 2.5D game-feel widgets introduced in the
// phase-C visual pass: ExtrudedCard (physical slab under question cards,
// banners and pedestals) and PunchIn (one-shot feedback entrance).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/ui/widgets/extruded_card.dart';

void main() {
  Widget wrap(Widget child, {bool disableAnimations = false}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: Scaffold(body: Center(child: child)),
        ),
      );

  Finder slabFinder(WidgetTester tester) => find.descendant(
        of: find.byType(ExtrudedCard),
        matching: find.byType(Positioned),
      );

  group('ExtrudedCard', () {
    testWidgets('renders the child and an offset side-face slab',
        (tester) async {
      await tester.pumpWidget(wrap(
        const ExtrudedCard(
          accent: Colors.deepPurple,
          depth: 7,
          radius: BorderRadius.all(Radius.circular(16)),
          child: SizedBox(width: 200, height: 100, child: Text('face')),
        ),
      ));

      expect(find.text('face'), findsOneWidget);

      final stack = tester.widget<Stack>(find.descendant(
        of: find.byType(ExtrudedCard),
        matching: find.byType(Stack),
      ));
      expect(stack.clipBehavior, Clip.none,
          reason: 'the slab and its AO shadow paint outside the card bounds');
      expect(stack.children.length, 2, reason: 'slab + child face');

      final slab = stack.children.first as Positioned;
      expect(slab.top, 7.0);
      expect(slab.bottom, -7.0,
          reason: 'side face peeks out below the card by `depth`');
      expect(slab.left, 0);
      expect(slab.right, 0);
    });

    testWidgets('side face derives a darker shade of the accent',
        (tester) async {
      const accent = Color(0xFF7E57C2); // medium violet
      await tester.pumpWidget(wrap(
        const ExtrudedCard(
          accent: accent,
          child: SizedBox(width: 100, height: 50),
        ),
      ));

      final slab = tester.widget<Positioned>(slabFinder(tester));
      final box = tester.widget<DecoratedBox>(find.descendant(
        of: find.byWidget(slab),
        matching: find.byType(DecoratedBox),
      ));
      final gradient = box.decoration as BoxDecoration;
      expect(gradient.gradient, isA<LinearGradient>());

      final hsl = HSLColor.fromColor(accent);
      for (final color in (gradient.gradient as LinearGradient).colors) {
        final side = HSLColor.fromColor(color);
        expect(side.hue, closeTo(hsl.hue, 0.5));
        expect(side.lightness, lessThan(hsl.lightness),
            reason: 'the extruded side must be darker than the face accent');
      }
    });

    testWidgets('does not block hits on the child face', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        ExtrudedCard(
          accent: Colors.teal,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => tapped = true,
            child: const SizedBox(width: 200, height: 100),
          ),
        ),
      ));

      await tester.tap(find.descendant(
        of: find.byType(ExtrudedCard),
        matching: find.byType(GestureDetector),
      ));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('PunchIn', () {
    testWidgets('scales and fades in, then settles at rest', (tester) async {
      await tester.pumpWidget(wrap(
        const PunchIn(child: Text('feedback')),
      ));

      final punchScale = find.descendant(
        of: find.byType(PunchIn),
        matching: find.byType(Transform),
      );
      final punchOpacity = find.descendant(
        of: find.byType(PunchIn),
        matching: find.byType(Opacity),
      ); // First frame of the entrance: still scaled below rest. (Read the
      // x-axis scale directly — getMaxScaleOnAxis() would return the
      // matrix's z scale of 1.0 and mask the entrance.)
      final early = tester.widget<Transform>(punchScale).transform.storage[0];
      expect(early, lessThan(1.0));

      await tester.pumpAndSettle();

      final settled = tester.widget<Transform>(punchScale).transform.storage[0];
      expect(settled, closeTo(1.0, 0.001));
      expect(tester.widget<Opacity>(punchOpacity).opacity, 1.0);
      expect(find.text('feedback'), findsOneWidget);
    });

    testWidgets('renders statically under reduced motion', (tester) async {
      await tester.pumpWidget(wrap(
        const PunchIn(child: Text('feedback')),
        disableAnimations: true,
      ));
      await tester.pump();

      expect(find.text('feedback'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PunchIn),
          matching: find.byType(Transform),
        ),
        findsNothing,
        reason: 'reduced motion must bypass the entrance entirely',
      );
      expect(
        find.descendant(
          of: find.byType(PunchIn),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
    });

    testWidgets('child updates do not restart the entrance', (tester) async {
      const key = ValueKey('panel');
      Widget build(String label) => wrap(
            PunchIn(child: Text(label, key: key)),
          );
      double scaleX(WidgetTester t) => t
          .widget<Transform>(find.descendant(
            of: find.byType(PunchIn),
            matching: find.byType(Transform),
          ))
          .transform
          .storage[0];

      await tester.pumpWidget(build('first'));
      await tester.pumpAndSettle();
      final settledScale = scaleX(tester);

      await tester.pumpWidget(build('second'));
      await tester.pump();

      expect(scaleX(tester), closeTo(settledScale, 0.001));
      expect(find.text('second'), findsOneWidget);
    });
  });
}
