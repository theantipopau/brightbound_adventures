import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import 'package:brightbound_adventures/main.dart';
import 'package:brightbound_adventures/ui/screens/avatar_creator_screen.dart';
import 'package:brightbound_adventures/ui/screens/onboarding_screen.dart';
import 'package:brightbound_adventures/ui/screens/world_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  final viewportCases = <Size>[
    const Size(390, 844),
    const Size(768, 1024),
    const Size(1366, 768),
  ];

  Future<void> pumpResponsiveShell(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(390, 844),
    bool withAvatarProvider = false,
    bool withAppProviders = false,
    TextScaler textScaler = TextScaler.noScaling,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget content = MediaQuery(
      data: MediaQueryData(
        size: size,
        disableAnimations: true,
        textScaler: textScaler,
      ),
      child: child,
    );

    if (withAppProviders) {
      content = MultiProvider(
        providers: [
          ChangeNotifierProvider<AudioManager>.value(value: AudioManager()),
          ChangeNotifierProvider<AvatarProvider>(
            create: (_) => _SmokeTestAvatarProvider(),
          ),
        ],
        child: content,
      );
    } else if (withAvatarProvider) {
      content = ChangeNotifierProvider<AvatarProvider>(
        create: (_) => _SmokeTestAvatarProvider(),
        child: content,
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/world-map': (_) => const Scaffold(body: Text('World map loaded')),
          '/avatar-creator': (_) => const Scaffold(body: Text('Avatar route')),
        },
        home: content,
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));
  }

  for (final size in viewportCases) {
    testWidgets('splash renders at ${size.width}x${size.height}',
        (tester) async {
      await pumpResponsiveShell(
        tester,
        const SplashScreen(),
        size: size,
        withAppProviders: true,
      );

      expect(find.text('BrightBound'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('onboarding renders at ${size.width}x${size.height}',
        (tester) async {
      await pumpResponsiveShell(
        tester,
        OnboardingScreen(onComplete: () {}),
        size: size,
      );

      expect(find.textContaining('Welcome to BrightBound'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets(
        'onboarding renders without overflow at ${size.width}x${size.height} @200% text',
        (tester) async {
      await pumpResponsiveShell(
        tester,
        OnboardingScreen(onComplete: () {}),
        size: size,
        textScaler: const TextScaler.linear(2.0),
      );

      expect(find.textContaining('Welcome to BrightBound'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('avatar creator renders at ${size.width}x${size.height}',
        (tester) async {
      await pumpResponsiveShell(
        tester,
        const AvatarCreatorScreen(),
        size: size,
      );

      expect(find.textContaining('Welcome'), findsWidgets);
      expect(find.byTooltip('Surprise me'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
        'avatar creator renders without overflow at ${size.width}x${size.height} @200% text',
        (tester) async {
      await pumpResponsiveShell(
        tester,
        const AvatarCreatorScreen(),
        size: size,
        textScaler: const TextScaler.linear(2.0),
      );

      expect(find.textContaining('Welcome'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('world entry renders at ${size.width}x${size.height}',
        (tester) async {
      await pumpResponsiveShell(
        tester,
        const WorldEntryScreen(),
        size: size,
        withAvatarProvider: true,
      );

      expect(find.text('Enter now'), findsOneWidget);
      expect(find.text('Discover Amazing Worlds'), findsOneWidget);
      await tester.tap(find.text('Enter now'));
      await tester.pump(const Duration(milliseconds: 320));
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets(
        'world entry renders without overflow at ${size.width}x${size.height} @200% text',
        (tester) async {
      await pumpResponsiveShell(
        tester,
        const WorldEntryScreen(),
        size: size,
        withAvatarProvider: true,
        textScaler: const TextScaler.linear(2.0),
      );

      expect(find.text('Discover Amazing Worlds'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // At 200% scale the content can be taller than the viewport, so
      // "Enter now" may start outside the visible area — same as a real
      // user needing to scroll before they can see and tap it. Scroll to
      // it first (as a real user would) rather than tapping blind, to
      // prove it's genuinely reachable and not just present in the tree.
      // Deliberately a bounded pump, not pumpAndSettle(): this screen's
      // own entry sequence auto-navigates away after ~2.3s, and
      // pumpAndSettle() would drain that whole timer chain first,
      // removing "Enter now" from the tree before this check runs.
      await tester.ensureVisible(find.text('Enter now'));
      await tester.pump(const Duration(milliseconds: 200));
      final buttonRect = tester.getRect(find.text('Enter now'));
      final screenRect = Offset.zero & size;
      expect(screenRect.contains(buttonRect.center), isTrue,
          reason: 'Enter now should be scrollable into view, not just '
              'present somewhere outside the reachable viewport');

      // This screen schedules its own entry-sequence Future.delayed chain
      // independently of the tap below; whichever step is in flight must
      // be allowed to actually resolve before the tree is torn down, or
      // the binding fails teardown with "A Timer is still pending". The
      // un-scaled test above tolerates 320ms; give this one more headroom
      // since which step is in flight when the tap lands is inherently a
      // little timing-dependent, not something to cut close.
      await tester.tap(find.text('Enter now'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}

class _SmokeTestAvatarProvider extends AvatarProvider {
  @override
  bool get hasAvatar => true;

  @override
  Future<void> loadAvatar() async {}
}
