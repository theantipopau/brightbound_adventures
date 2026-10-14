import 'package:brightbound_adventures/ui/widgets/reward_animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('level-up overlay shows the Lottie burst and auto-dismisses',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () => showLevelUpOverlay(context, 2),
          child: const Text('go'),
        );
      }),
    ));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Level 2'), findsOneWidget);
    expect(find.byType(LevelUpOverlay), findsOneWidget);

    // Auto-dismiss after the choreography (route pops).
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(LevelUpOverlay), findsNothing);
  });

  testWidgets('reduced motion shows the static reward frame, no motion',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () => showBadgeUnlockOverlay(context, 'Streak Star'),
            child: const Text('go'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Streak Star'), findsOneWidget);
    expect(find.textContaining('Badge unlocked'), findsOneWidget);
    // Reduced motion: the frame is static; the overlay still auto-dismisses
    // on its fixture timer so it can never trap the child.
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(BadgeUnlockOverlay), findsNothing);
  });
}
