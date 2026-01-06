import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../widgets/logic_game.dart';
import '../widgets/logic_results_screen.dart';
import 'package:brightbound_adventures/core/services/skill_provider.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/utils/puzzle_peaks_generator.dart';

/// Main screen for Puzzle Peaks skill practice
/// Routes to appropriate logic game based on skill selected
class LogicPracticeScreen extends StatefulWidget {
  final String skillId;
  final String skillName;

  const LogicPracticeScreen({
    super.key,
    required this.skillId,
    required this.skillName,
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
    try {
      // Use generator for varied questions based on skill
      return PuzzlePeaksQuestionGenerator.generate(
        skill: widget.skillId,
        difficulty: 3,
        count: 10,
      );
    } catch (e) {
      // Fallback to hardcoded questions if generator fails
      switch (widget.skillId) {
        case 'skill_pattern_recognition':
          return PatternRecognitionQuestions.getByDifficulty(3);
        case 'skill_shape_matching':
          return ShapeMatchingQuestions.getByDifficulty(3);
        case 'skill_spatial_reasoning':
          return SpatialReasoningQuestions.getByDifficulty(3);
        case 'skill_logic_puzzles':
          return LogicPuzzleQuestions.getByDifficulty(3);
        case 'skill_problem_solving':
          return ProblemSolvingQuestions.getByDifficulty(3);
        case 'skill_sequence_logic':
          return SequenceLogicQuestions.getByDifficulty(3);
        default:
          return PatternRecognitionQuestions.getByDifficulty(3);
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

    // Award XP
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    avatarProvider.addExperience(xp);
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
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  label: const Text(
                    'Go Back',
                    style: TextStyle(color: Colors.white70),
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
