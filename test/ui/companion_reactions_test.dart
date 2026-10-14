import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/services/local_storage_service.dart';
import 'package:brightbound_adventures/ui/widgets/companion_reactions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SeededStorage extends LocalStorageService {
  Avatar? _avatar;
  @override
  Future<Avatar?> getAvatar() async => _avatar;
  @override
  Future<void> saveAvatar(Avatar avatar) async => _avatar = avatar;
}

Avatar _avatar() => Avatar(
      id: 'a1',
      name: 'Testy',
      baseCharacter: 'bear',
      skinColor: '#E8C4A0',
      outfitId: 'outfit_adventure',
      unlockedOutfits: const ['outfit_adventure'],
      unlockedAccessories: const ['acc_bow'],
      experiencePoints: 0,
      level: 1,
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

Widget _host({
  required AvatarProvider provider,
  bool disableAnimations = false,
}) {
  return MultiProvider(
    providers: [ChangeNotifierProvider<AvatarProvider>.value(value: provider)],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(
          body: Stack(
            children: const [
              Positioned(
                top: 0,
                right: 0,
                child: QuizCompanionCorner(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(const {});
  });

  testWidgets('wrong answer emotion renders the encourage droop, then resets',
      (tester) async {
    final storage = _SeededStorage();
    final provider = AvatarProvider()..setStorageService(storage);
    await storage.saveAvatar(_avatar());
    await provider.loadAvatar();

    await tester.pumpWidget(_host(provider: provider));
    await tester.pump();

    provider.setEmotion(AvatarEmotion.encourage);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // The reaction badge shows the encourage reaction while animating.
    expect(find.text('💪'), findsOneWidget);

    // Idle float loops forever, so settle explicitly: advance past the
    // encourage reset window and confirm the companion returns to idle.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 200));
    expect(provider.emotion, AvatarEmotion.neutral);
  });

  testWidgets('level-up emotion plays the hop + glow ring choreography',
      (tester) async {
    final storage = _SeededStorage();
    final provider = AvatarProvider()..setStorageService(storage);
    await storage.saveAvatar(_avatar());
    await provider.loadAvatar();

    await tester.pumpWidget(_host(provider: provider));
    await tester.pump();

    await provider.addExperience(20000); // several levels at once

    expect(provider.emotion, AvatarEmotion.levelUp);
    await tester.pump(); // flush the reaction rebuild
    expect(find.text('🚀'), findsOneWidget);
    // Complete the choreography and the provider reset inside the test
    // environment, then confirm the companion returned to idle cleanly.
    await tester.pump(const Duration(seconds: 3));
    expect(provider.emotion, AvatarEmotion.neutral);
  });

  testWidgets('reduced motion renders a static pose with badge only',
      (tester) async {
    final storage = _SeededStorage();
    final provider = AvatarProvider()..setStorageService(storage);
    await storage.saveAvatar(_avatar());
    await provider.loadAvatar();

    await tester.pumpWidget(_host(provider: provider, disableAnimations: true));
    await tester.pump();

    provider.setEmotion(AvatarEmotion.celebrate);
    await tester.pump();
    // Badge still communicates the reaction, without tween motion.
    expect(find.text('🎉'), findsOneWidget);
    expect(provider.emotion, AvatarEmotion.celebrate);

    // Advance past the reset window so the provider's timer completes
    // inside the test environment (no pending timer at dispose).
    await tester.pump(const Duration(seconds: 3));
    expect(provider.emotion, AvatarEmotion.neutral);
  });
}
