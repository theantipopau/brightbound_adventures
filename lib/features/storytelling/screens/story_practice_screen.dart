import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/achievement_service.dart';
import 'package:brightbound_adventures/core/services/daily_challenge_service.dart';
import 'package:brightbound_adventures/core/services/adaptive_difficulty_service.dart';
import 'package:brightbound_adventures/core/services/streak_service.dart';
import 'package:brightbound_adventures/ui/widgets/streak_milestone_modal.dart';
import '../models/question.dart';
import '../widgets/story_game.dart';
import '../widgets/story_results_screen.dart';
import 'package:brightbound_adventures/core/services/skill_provider.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/utils/story_springs_generator.dart';
import 'package:brightbound_adventures/ui/widgets/branded_back_button.dart';

/// Main screen for Story Springs skill practice
/// Routes to appropriate story game based on skill selected
class StoryPracticeScreen extends StatefulWidget {
  final String skillId;
  final String skillName;
  final String? zoneId;
  final String? zoneName;

  const StoryPracticeScreen({
    super.key,
    required this.skillId,
    required this.skillName,
    this.zoneId,
    this.zoneName,
  });

  @override
  State<StoryPracticeScreen> createState() => _StoryPracticeScreenState();
}

class _StoryPracticeScreenState extends State<StoryPracticeScreen> {
  bool _showResults = false;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  int _xpEarned = 0;

  List<StoryQuestion> _getQuestionsForSkill() {
    // Get adaptive difficulty level
    final adaptiveDifficulty = context.read<AdaptiveDifficultyService>();
    final difficulty = adaptiveDifficulty.getDifficultyForSkill(widget.skillId);

    try {
      // Use generator for varied questions based on skill
      return StorySpringsQuestionGenerator.generate(
        skill: widget.skillId,
        difficulty: difficulty,
        count: 10,
      );
    } catch (e) {
      // Fallback to hardcoded questions if generator fails
      switch (widget.skillId) {
        case 'skill_story_sequencing':
          return StorySequencingQuestions.getByDifficulty(difficulty);
        case 'skill_emotion_recognition':
          return EmotionRecognitionQuestions.getByDifficulty(difficulty);
        case 'skill_descriptive_language':
          return DescriptiveLanguageQuestions.getByDifficulty(difficulty);
        case 'skill_dialogue_creation':
          return DialogueCreationQuestions.getByDifficulty(difficulty);
        case 'skill_plot_structure':
          return PlotStructureQuestions.getByDifficulty(difficulty);
        case 'skill_character_development':
          return CharacterDevelopmentQuestions.getByDifficulty(difficulty);
        default:
          return StorySequencingQuestions.getByDifficulty(difficulty);
      }
    }
  }

  String _getSkillDescription() {
    switch (widget.skillId) {
      case 'skill_story_sequencing':
        return 'Put story events in the right order!';
      case 'skill_emotion_recognition':
        return 'Identify how characters feel!';
      case 'skill_descriptive_language':
        return 'Use vivid words to paint pictures!';
      case 'skill_dialogue_creation':
        return 'Write character conversations!';
      case 'skill_plot_structure':
        return 'Build stories with beginning, middle, end!';
      case 'skill_character_development':
        return 'Create memorable characters!';
      case 'skill_dialogue_punctuation':
        return 'Punctuate dialogue correctly!';
      case 'skill_voice_recording':
        return 'Tell stories with your voice!';
      default:
        return 'Practice your storytelling skills!';
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
    } catch (e) {}

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
    } catch (e) {}
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
      return StoryResultsScreen(
        correctAnswers: _correctAnswers,
        totalQuestions: _totalQuestions,
        xpEarned: _xpEarned,
        skillName: widget.skillName,
        onContinue: _onContinue,
        onRetry: _onRetry,
      );
    }

    final questions = _getQuestionsForSkill();

    // If no questions available for this skill, show coming soon
    if (questions.isEmpty) {
      return _buildComingSoonScreen();
    }

    return StoryGame(
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
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📚', style: TextStyle(fontSize: 80)),
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
                    color: Colors.purple.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple.shade300),
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
                    borderColor: Colors.purple.shade300.withValues(alpha: 0.7),
                    tokenBackgroundColor: Colors.purple.withValues(alpha: 0.24),
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
