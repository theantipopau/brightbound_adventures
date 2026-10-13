/// Explains exactly what a completed session earned and why.
///
/// Kept as a pure value object (no Flutter imports) so it can be unit tested
/// and so the reward reveal can *describe* the award rather than only showing
/// a total. The numbers intentionally reproduce the XP formula the results
/// screen used before rewards were consolidated into
/// `RewardTransactionService`, so migrating the call site does not change
/// what a child earns.
class RewardBreakdown {
  const RewardBreakdown({
    required this.baseXp,
    required this.masteryBonus,
    required this.effortBonus,
  });

  /// Participation reward, scaled by accuracy: `round(accuracy * 100)`.
  /// Every child earns this for taking part — it never drops to zero for a
  /// poor score, so a struggle still moves the adventure forward.
  final int baseXp;

  /// Strong-accuracy bonus, earned at 85% or better.
  final int masteryBonus;

  /// Independence bonus for finishing without hints at 70% or better.
  /// Hints themselves never remove the base reward — they only forgo this
  /// optional extra, which keeps scaffolding a safe thing to use.
  final int effortBonus;

  int get totalXp => baseXp + masteryBonus + effortBonus;

  bool get hasMasteryBonus => masteryBonus > 0;
  bool get hasEffortBonus => effortBonus > 0;

  /// The XP formula in one place. `hintsUsed` is the number of hints the
  /// child opened during the session.
  static RewardBreakdown forSession({
    required double accuracy,
    int hintsUsed = 0,
  }) {
    final clamped = accuracy.isNaN ? 0.0 : accuracy.clamp(0.0, 1.0);
    return RewardBreakdown(
      baseXp: (clamped * 100).round(),
      masteryBonus: clamped >= 0.85 ? 25 : 0,
      effortBonus: (hintsUsed == 0 && clamped >= 0.70) ? 10 : 0,
    );
  }

  /// Child-facing lines explaining each component that was actually earned.
  /// Empty when nothing beyond the base reward applied, because a plain
  /// "+N XP" reads better than a list of zeros.
  List<String> get lines {
    return [
      if (baseXp > 0) '+$baseXp for taking part',
      if (hasMasteryBonus) '+$masteryBonus accuracy bonus',
      if (hasEffortBonus) '+$effortBonus for working it out yourself',
    ];
  }
}
