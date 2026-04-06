import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/achievement_service.dart';
import 'package:brightbound_adventures/core/services/daily_challenge_service.dart';
import 'package:brightbound_adventures/core/services/adaptive_difficulty_service.dart';
import 'package:brightbound_adventures/core/services/streak_service.dart';
import 'package:brightbound_adventures/ui/widgets/streak_milestone_modal.dart';
import '../models/question.dart';
import '../widgets/logic_game.dart';
import '../widgets/logic_results_screen.dart';
import 'package:brightbound_adventures/core/services/skill_provider.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/services/spaced_repetition_service.dart';
import 'package:brightbound_adventures/core/utils/puzzle_peaks_generator.dart';
import 'package:brightbound_adventures/ui/themes/app_theme.dart';
import 'package:brightbound_adventures/ui/widgets/branded_back_button.dart';
import 'package:brightbound_adventures/ui/widgets/zone_mastered_celebration.dart';

/// Main screen for Puzzle Peaks skill practice
/// Routes to appropriate logic game based on skill selected
class LogicPracticeScreen extends StatefulWidget {
  final String skillId;
  final String skillName;
  final String? zoneId;
  final String? zoneName;

  const LogicPracticeScreen({
    super.key,
    required this.skillId,
    required this.skillName,
    this.zoneId,
    this.zoneName,
  });

  @override
  State<LogicPracticeScreen> createState() => _LogicPracticeScreenState();
}

class _LogicPracticeScreenState extends State<LogicPracticeScreen> {
  bool _showResults = false;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  int _xpEarned = 0;

  List<LogicQuestion> _getQuestionsForSkill() {
    // Get adaptive difficulty level
    final adaptiveDifficulty = context.read<AdaptiveDifficultyService>();
    final difficulty = adaptiveDifficulty.getDifficultyForSkill(widget.skillId);

    try {
      // Use generator for varied questions based on skill
      return PuzzlePeaksQuestionGenerator.generate(
        skill: widget.skillId,
        difficulty: difficulty,
        count: 10,
      );
    } catch (e) {
      // Fallback to hardcoded questions if generator fails
      switch (widget.skillId) {
        case 'skill_pattern_recognition':
          return PatternRecognitionQuestions.getByDifficulty(difficulty);
        case 'skill_shape_matching':
          return ShapeMatchingQuestions.getByDifficulty(difficulty);
        case 'skill_spatial_reasoning':
          return SpatialReasoningQuestions.getByDifficulty(difficulty);
        case 'skill_logic_puzzles':
          return LogicPuzzleQuestions.getByDifficulty(difficulty);
        case 'skill_problem_solving':
          return ProblemSolvingQuestions.getByDifficulty(difficulty);
        case 'skill_sequence_logic':
          return SequenceLogicQuestions.getByDifficulty(difficulty);
        default:
          return PatternRecognitionQuestions.getByDifficulty(difficulty);
      }
    }
  }

  String _getSkillDescription() {
    switch (widget.skillId) {
      case 'skill_pattern_recognition':
        return 'Find and complete patterns!';
      case 'skill_shape_matching':
        return 'Match shapes and learn geometry!';
      case 'skill_spatial_reasoning':
        return 'Visualize rotations and perspectives!';
      case 'skill_logic_puzzles':
        return 'Solve puzzles with logical thinking!';
      case 'skill_problem_solving':
        return 'Break down complex problems!';
      case 'skill_sequence_logic':
        return 'Find the logical order!';
      default:
        return 'Challenge your logical thinking!';
    }
  }

  void _onGameFinish(int correct, int total, int xp) {
    setState(() {
      _correctAnswers = correct;
      _totalQuestions = total;
      _xpEarned = xp;
      _showResults = true;
    });

    // Update skill progress
    final skillProvider = Provider.of<SkillProvider>(context, listen: false);
    final percentage = correct / total;
    skillProvider.updateSkillProgress(
      skillId: widget.skillId,
      sessionAccuracy: percentage,
      sessionHints: 0,
    );

    // Schedule spaced repetition review
    Provider.of<SpacedRepetitionService>(context, listen: false).recordSession(
      skillId: widget.skillId,
      accuracy: percentage,
    );

    // Check if this session completed the whole zone
    if (widget.zoneId != null) {
      final themeColor =
          WorldTokens.fromZoneId(widget.zoneId!).primaryColor;
      checkAndShowZoneMastered(
        context,
        skillProvider,
        zoneId: widget.zoneId,
        zoneName: widget.zoneName,
        themeColor: themeColor,
      );
    }

    // Award XP
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    avatarProvider.addExperience(xp);

    // Update achievements
    try {
      final achievementService = context.read<AchievementService>();
      final starsEarned = correct * 10;
      achievementService.updateProgress('achievement_stars_25', starsEarned);
      achievementService.updateProgress('achievement_stars_50', starsEarned);
      achievementService.updateProgress('achievement_stars_100', starsEarned);
      if (percentage == 1.0) {
        achievementService.updateProgress('achievement_perfect_1', 1);
        achievementService.updateProgress('achievement_perfect_5', 1);
      }
      if (correct >= 3) {
        achievementService.updateProgress('achievement_quick_learner', 1);
      }
    } catch (e) {
      debugPrint('Failed to update logic achievements: $e');
    }

    // Update daily challenges
    try {
      final dailyService = context.read<DailyChallengeService>();
      for (int i = 0; i < correct; i++) {
        for (final challenge in dailyService.todaysChallenges) {
          if (challenge.skillId == widget.skillId) {
            dailyService.updateProgress(
              challengeId: challenge.id,
              correct: true,
            );
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to update logic daily challenges: $e');
    }
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

  void _onContinue() {
    Navigator.of(context).pop();
  }

  void _onRetry() {
    setState(() {
      _showResults = false;
      _correctAnswers = 0;
      _totalQuestions = 0;
      _xpEarned = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return LogicResultsScreen(
        correctAnswers: _correctAnswers,
        totalQuestions: _totalQuestions,
        xpEarned: _xpEarned,
        skillName: widget.skillName,
        onContinue: _onContinue,
        onRetry: _onRetry,
      );
    }

    final questions = _getQuestionsForSkill();

    if (questions.isEmpty) {
      return _buildComingSoonScreen();
    }

    return LogicGame(
      questions: questions,
      skillName: widget.skillName,
      onComplete: () {},
      onFinish: _onGameFinish,
    );
  }

  Widget _buildComingSoonScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50),
              Color(0xFF34495E),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏔️', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                Text(
                  widget.skillName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getSkillDescription(),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.tealAccent),
                  ),
                  child: const Text(
                    '🚀 Coming Soon!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 220,
                  child: BrandedBackButton(
                    label: 'Back to Zone',
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    foregroundColor: Colors.white,
                    borderColor: Colors.tealAccent.withValues(alpha: 0.7),
                    tokenBackgroundColor: Colors.teal.withValues(alpha: 0.24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
