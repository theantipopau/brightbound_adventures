import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/screens/profile_stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('ProfileStatsScreen shows an empty state when no avatar exists',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      Provider<LocalStorageService>.value(
        value: _NoAvatarStorageService(),
        child: const MaterialApp(
          home: ProfileStatsScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('No progress yet'), findsOneWidget);
    expect(find.textContaining('Create an avatar'), findsOneWidget);
  });
}

class _NoAvatarStorageService extends LocalStorageService {
  @override
  Future<Avatar?> getAvatar() async => null;
}
