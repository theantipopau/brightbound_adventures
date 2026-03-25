import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/widgets/streak_milestone_modal.dart';
import 'package:brightbound_adventures/core/utils/number_nebula_generator.dart';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';
import 'package:brightbound_adventures/features/numeracy/widgets/numeracy_game.dart';
import 'package:brightbound_adventures/features/numeracy/widgets/numeracy_results_screen.dart';
import 'package:brightbound_adventures/ui/widgets/branded_back_button.dart';

/// Skill practice screen for numeracy skills
class NumeracyPracticeScreen extends StatefulWidget {
  final Skill skill;
  final Color themeColor;
  final String? zoneId;
  final String? zoneName;

  const NumeracyPracticeScreen({
    super.key,
    required this.skill,
    required this.themeColor,
    this.zoneId,
    this.zoneName,
  });

  @override
  State<NumeracyPracticeScreen> createState() => _NumeracyPracticeScreenState();
}

class _NumeracyPracticeScreenState extends State<NumeracyPracticeScreen> {
  bool _showResults = false;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  double _accuracy = 0;
  int _hintsUsed = 0;

  List<NumeracyQuestion> _getQuestionsForSkill() {
    // Get adaptive difficulty level
    final adaptiveDifficulty = context.read<AdaptiveDifficultyService>();
    final difficulty =
        adaptiveDifficulty.getDifficultyForSkill(widget.skill.id);

    switch (widget.skill.id) {
      case 'skill_counting':
      case 'skill_number_recognition':
        return CountingQuestions.getByDifficulty(difficulty);
      case 'skill_addition':
        return AdditionQuestions.getByDifficulty(difficulty);
      case 'skill_subtraction':
        return SubtractionQuestions.getByDifficulty(difficulty);
      case 'skill_multiplication':
        return MultiplicationQuestions.getByDifficulty(difficulty);
      case 'skill_patterns':
        return PatternQuestions.getByDifficulty(difficulty);
      case 'skill_place_value':
        return PlaceValueQuestions.getByDifficulty(difficulty);
      default:
        // Return generic questions for skills without specific question banks
        return _getGenericQuestions();
    }
  }

  List<NumeracyQuestion> _getGenericQuestions() {
    // Use question generator for skills without specific banks
    final adaptiveDifficulty = context.read<AdaptiveDifficultyService>();
    final difficulty =
        adaptiveDifficulty.getDifficultyForSkill(widget.skill.id);

    try {
      return NumberNebulaQuestionGenerator.generate(
        skill: widget.skill.name,
        difficulty: difficulty,
        count: 10,
      );
    } catch (e) {
      // Fallback to placeholder if generator fails
      return [
        NumeracyQuestion(
          id: '${widget.skill.id}_1',
          skillId: widget.skill.id,
          question:
              'This skill is coming soon!\nWould you like to practice anyway?',
          options: ['Yes, let\'s practice!', 'I\'ll wait', 'Tell me more'],
          correctIndex: 0,
          hint: 'The first option is always ready to go!',
          explanation:
              'More questions for ${widget.skill.name} are being added.',
          difficulty: 1,
        ),
      ];
    }
  }

  void _onGameComplete(double accuracy, int correct, int total) {
    // Update achievements
    try {
      final achievementService = context.read<AchievementService>();
      final starsEarned = correct * 10;
      achievementService.updateProgress('achievement_stars_25', starsEarned);
      achievementService.updateProgress('achievement_stars_50', starsEarned);
      achievementService.updateProgress('achievement_stars_100', starsEarned);
      if (accuracy == 1.0) {
        achievementService.updateProgress('achievement_perfect_1', 1);
        achievementService.updateProgress('achievement_perfect_5', 1);
      }
      if (correct >= 3) {
        achievementService.updateProgress('achievement_quick_learner', 1);
      }
    } catch (e) {}

    // Update daily challenges
    try {
      final dailyService = context.read<DailyChallengeService>();
      for (int i = 0; i < correct; i++) {
        for (final challenge in dailyService.todaysChallenges) {
          if (challenge.skillId == widget.skill.id) {
            dailyService.updateProgress(
              challengeId: challenge.id,
              correct: true,
            );
            break;
          }
        }
      }
    } catch (e) {}

    setState(() {
      _showResults = true;
      _accuracy = accuracy;
      _correctAnswers = correct;
      _totalQuestions = total;
    });
    _checkStreak();
  }

  Future<void> _checkStreak() async {
    try {
      final streakService = context.read<StreakService>();
      final isNewMilestone = await streakService.recordPlay();
      if (isNewMilestone && mounted) {
        showStreakMilestoneModal(
          context,
          streakDays: streakService.currentStreak,
          bonusStars: streakService.streakBonus,
        );
      }
    } catch (_) {}
  }

  void _playAgain() {
    setState(() {
      _showResults = false;
      _correctAnswers = 0;
      _totalQuestions = 0;
      _accuracy = 0;
      _hintsUsed = 0;
    });
  }

  void _exitToZone() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return NumeracyResultsScreen(
        skillName: widget.skill.name,
        skillId: widget.skill.id,
        correctAnswers: _correctAnswers,
        totalQuestions: _totalQuestions,
        accuracy: _accuracy,
        hintsUsed: _hintsUsed,
        themeColor: widget.themeColor,
        onPlayAgain: _playAgain,
        onExit: _exitToZone,
      );
    }

    final questions = _getQuestionsForSkill();

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.skill.name),
          backgroundColor: widget.themeColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌌', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Questions coming soon!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'We\'re preparing new challenges for ${widget.skill.name}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              BrandedBackButton(
                label: 'Back to Zone',
                onPressed: () => Navigator.pop(context),
                backgroundColor: widget.themeColor,
                foregroundColor: Colors.white,
                borderColor: widget.themeColor.withValues(alpha: 0.85),
                tokenBackgroundColor: Colors.white.withValues(alpha: 0.16),
              ),
            ],
          ),
        ),
      );
    }

    return NumeracyGame(
      questions: questions,
      skillName: widget.skill.name,
      themeColor: widget.themeColor,
      onComplete: _onGameComplete,
      onCancel: _exitToZone,
    );
  }
}
