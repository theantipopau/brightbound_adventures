import 'dart:math' as math;

/// Shared copy and scoring helpers for child-friendly learning feedback.
///
/// Keep this logic UI-agnostic so question screens, result screens, and future
/// adaptive learning services can all speak the same language.
class LearningFeedbackHelper {
  const LearningFeedbackHelper._();

  static String encouragement({
    required bool isCorrect,
    required int streak,
  }) {
    if (isCorrect && streak >= 10) return 'Amazing streak!';
    if (isCorrect && streak >= 5) return 'You are on fire!';
    if (isCorrect && streak >= 3) return 'Great pattern!';
    if (isCorrect) return 'Nice work!';
    return 'Good try. Keep going!';
  }

  static String masteryMessage({
    required int correct,
    required int answered,
  }) {
    if (answered <= 0) return 'Ready to begin.';
    final accuracy = correct / math.max(answered, 1);
    if (accuracy >= 0.95) return 'Mastery level work.';
    if (accuracy >= 0.8) return 'Strong progress.';
    if (accuracy >= 0.6) return 'Keep practising.';
    return 'Let us build this skill together.';
  }

  static int suggestedDifficultyDelta({
    required int correct,
    required int answered,
    required int streak,
  }) {
    if (answered < 4) return 0;
    final accuracy = correct / answered;
    if (accuracy >= 0.9 && streak >= 3) return 1;
    if (accuracy <= 0.45) return -1;
    return 0;
  }

  static String hintPrompt({
    required int incorrectAttempts,
    required bool hintAvailable,
  }) {
    if (!hintAvailable) return '';
    if (incorrectAttempts <= 0) return 'Need a clue?';
    if (incorrectAttempts == 1) return 'Try a hint before the next choice.';
    return 'A hint can help you spot the pattern.';
  }
}
