import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/data/zone_guardian_data.dart';
import 'package:brightbound_adventures/core/utils/word_woods_generator.dart';
import 'package:brightbound_adventures/core/services/achievement_service.dart';
import 'package:brightbound_adventures/core/services/daily_challenge_service.dart';
import 'package:brightbound_adventures/core/services/streak_service.dart';
import 'package:brightbound_adventures/ui/widgets/streak_milestone_modal.dart';
import 'package:brightbound_adventures/features/literacy/models/question.dart';
import 'package:brightbound_adventures/features/literacy/widgets/multiple_choice_game.dart';
import 'package:brightbound_adventures/features/literacy/widgets/quiz_results_screen.dart';

/// Skill practice screen that connects skills to their games
class SkillPracticeScreen extends StatefulWidget {
  final Skill skill;
  final Color themeColor;
  final String? zoneId;
  final String? zoneName;

  const SkillPracticeScreen({
    super.key,
    required this.skill,
    required this.themeColor,
    this.zoneId,
    this.zoneName,
  });

  @override
  State<SkillPracticeScreen> createState() => _SkillPracticeScreenState();
}

class _SkillPracticeScreenState extends State<SkillPracticeScreen> {
  bool _showResults = false;
  int _correctAnswers = 0;
  int _totalQuestions = 0;
  double _accuracy = 0;
  int _hintsUsed = 0;
  String? _guardianMessage;
  String? _guardianEmoji;

  List<LiteracyQuestion> _getQuestionsForSkill() {
    switch (widget.skill.id) {
      case 'skill_homophones':
        return HomophoneQuestions.getByDifficulty(widget.skill.difficulty);
      case 'skill_apostrophes':
        return ApostropheQuestions.getByDifficulty(widget.skill.difficulty);
      case 'skill_comma_usage':
        return PunctuationQuestions.getByDifficulty(widget.skill.difficulty);
      default:
        // Return generic questions for skills without specific question banks
        return _getGenericQuestions();
    }
  }

  List<LiteracyQuestion> _getGenericQuestions() {
    // Use question generator for skills without specific banks
    try {
      return WordWoodsQuestionGenerator.generate(
        skill: widget.skill.name,
        difficulty: widget.skill.difficulty,
        count: 10,
      );
    } catch (e) {
      // Fallback to placeholder if generator fails
      return [
        LiteracyQuestion(
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
      
      // Stars earned achievement (10 stars per correct answer)
      final starsEarned = correct * 10;
      achievementService.updateProgress('achievement_stars_25', starsEarned);
      achievementService.updateProgress('achievement_stars_50', starsEarned);
      achievementService.updateProgress('achievement_stars_100', starsEarned);
      
      // Perfect game achievement
      if (accuracy == 1.0) {
        achievementService.updateProgress('achievement_perfect_1', 1);
        achievementService.updateProgress('achievement_perfect_5', 1);
      }
      
      // Quick learner achievement (3+ correct)
      if (correct >= 3) {
        achievementService.updateProgress('achievement_quick_learner', 1);
      }
    } catch (e) {
      // Achievement service not available
    }
    
    // Update daily challenges - update progress for each correct answer
    try {
      final dailyService = context.read<DailyChallengeService>();
      for (int i = 0; i < correct; i++) {
        // Find matching daily challenge for this skill zona
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
    } catch (e) {
      // Daily challenge service not available
    }
    
    setState(() {
      _showResults = true;
      _accuracy = accuracy;
      _correctAnswers = correct;
      _totalQuestions = total;
      // Pick the guardian skill-complete message for this zone
      final guardian = guardianForZone(widget.zoneId ?? '');
      if (guardian != null) {
        _guardianMessage = guardian.skillCompleteMessage(correct);
        _guardianEmoji = guardian.emoji;
      }
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
      return QuizResultsScreen(
        skillName: widget.skill.name,
        skillId: widget.skill.id,
        correctAnswers: _correctAnswers,
        totalQuestions: _totalQuestions,
        accuracy: _accuracy,
        hintsUsed: _hintsUsed,
        themeColor: widget.themeColor,
        onPlayAgain: _playAgain,
        onExit: _exitToZone,
        guardianMessage: _guardianMessage,
        guardianEmoji: _guardianEmoji,
        zoneId: widget.zoneId,
        zoneName: widget.zoneName,
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
              const Icon(Icons.construction, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Questions coming soon!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Zone'),
              ),
            ],
          ),
        ),
      );
    }

    return MultipleChoiceGame(
      questions: questions,
      skillName: widget.skill.name,
      themeColor: widget.themeColor,
      onComplete: _onGameComplete,
      onCancel: _exitToZone,
    );
  }
}
