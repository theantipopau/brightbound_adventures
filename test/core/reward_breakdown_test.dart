import 'package:flutter_test/flutter_test.dart';
import 'package:brightbound_adventures/core/models/index.dart';

/// The XP formula is what the results screen displayed before rewards were
/// consolidated into `RewardTransactionService`, so these numbers are a
/// contract: changing them silently changes what children earn.
void main() {
  group('RewardBreakdown.forSession', () {
    test('participation XP scales with accuracy', () {
      expect(RewardBreakdown.forSession(accuracy: 0).baseXp, 0);
      expect(RewardBreakdown.forSession(accuracy: 0.5).baseXp, 50);
      expect(RewardBreakdown.forSession(accuracy: 0.73).baseXp, 73);
      expect(RewardBreakdown.forSession(accuracy: 1).baseXp, 100);

      // 73% without hints also picks up the independence bonus.
      expect(RewardBreakdown.forSession(accuracy: 0.73).totalXp, 83);
      expect(
        RewardBreakdown.forSession(accuracy: 0.73, hintsUsed: 2).totalXp,
        73,
      );
    });

    test('mastery bonus applies at 85% and above only', () {
      expect(RewardBreakdown.forSession(accuracy: 0.84).masteryBonus, 0);
      expect(RewardBreakdown.forSession(accuracy: 0.85).masteryBonus, 25);
      expect(RewardBreakdown.forSession(accuracy: 1).masteryBonus, 25);
    });

    test('effort bonus rewards independence, never removes base XP', () {
      final withHints = RewardBreakdown.forSession(accuracy: 0.9, hintsUsed: 3);
      final withoutHints = RewardBreakdown.forSession(accuracy: 0.9);

      expect(withHints.effortBonus, 0);
      expect(withoutHints.effortBonus, 10);
      // Hints cost only the optional bonus — the participation reward is
      // identical, so scaffolding is always safe to use.
      expect(withHints.baseXp, withoutHints.baseXp);
      expect(withHints.totalXp, withoutHints.totalXp - 10);
    });

    test('a struggling session still earns participation XP', () {
      final breakdown = RewardBreakdown.forSession(accuracy: 0.2);
      expect(breakdown.totalXp, greaterThan(0),
          reason: 'a child who struggles must still move forward');
      expect(breakdown.masteryBonus, 0);
      expect(breakdown.effortBonus, 0);
    });

    test('accuracy is clamped and NaN-safe', () {
      expect(RewardBreakdown.forSession(accuracy: 1.7).baseXp, 100);
      expect(RewardBreakdown.forSession(accuracy: -0.5).baseXp, 0);
      expect(RewardBreakdown.forSession(accuracy: double.nan).totalXp, 0);
    });

    test('lines explain only what was actually earned', () {
      final plain = RewardBreakdown.forSession(accuracy: 0.6, hintsUsed: 1);
      expect(plain.lines, ['+60 for taking part']);

      final rich = RewardBreakdown.forSession(accuracy: 1.0);
      expect(rich.lines, [
        '+100 for taking part',
        '+25 accuracy bonus',
        '+10 for working it out yourself',
      ]);
      expect(
        rich.baseXp + rich.masteryBonus + rich.effortBonus,
        rich.totalXp,
      );

      final none = RewardBreakdown.forSession(accuracy: 0);
      expect(none.lines, isEmpty);
    });
  });
}
