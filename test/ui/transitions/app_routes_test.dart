import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/ui/transitions/app_routes.dart';

void main() {
  group('ZoneEntryRoute', () {
    testWidgets('navigates to the target page', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              ZoneEntryRoute(
                context: context,
                builder: (context) => const Text('Destination'),
              ),
            ),
            child: const Text('Go'),
          ),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.text('Destination'), findsOneWidget);
    });

    testWidgets('completes instantly under reduced motion', (tester) async {
      await tester.pumpWidget(MaterialApp(
        // MediaQuery must wrap MaterialApp's `child` (via `builder`), not
        // sit outside MaterialApp, to actually reach pushed routes.
        builder: (context, child) => MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: child!,
        ),
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              ZoneEntryRoute(
                context: context,
                builder: (context) => const Text('Destination'),
              ),
            ),
            child: const Text('Go'),
          ),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pump(); // process the tap and start the push
      // A short duration pump should be enough for a reduced-motion
      // (instant) transition, unlike the full-motion case which needs
      // pumpAndSettle.
      await tester.pump(const Duration(milliseconds: 120));

      expect(find.text('Destination'), findsOneWidget);
    });
  });

  group('SheetRoute', () {
    testWidgets('navigates to the target page', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              SheetRoute(
                context: context,
                builder: (context) => const Text('Settings'),
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('CelebrationRoute', () {
    testWidgets('navigates to the target page', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              CelebrationRoute(
                context: context,
                builder: (context) => const Text('Results'),
              ),
            ),
            child: const Text('Finish'),
          ),
        ),
      ));

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(find.text('Results'), findsOneWidget);
    });
  });
}
