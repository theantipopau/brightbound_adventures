import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/core/utils/number_nebula_generator.dart';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';
import 'package:brightbound_adventures/features/numeracy/widgets/numeracy_game.dart';
import 'package:brightbound_adventures/features/numeracy/widgets/numeracy_results_screen.dart';

/// Skill practice screen for numeracy skills
class NumeracyPracticeScreen extends StatefulWidget {
  final Skill skill;
  final Color themeColor;

  const NumeracyPracticeScreen({
    super.key,
    required this.skill,
    required this.themeColor,
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
    setState(() {
      _showResults = true;
      _accuracy = accuracy;
      _correctAnswers = correct;
      _totalQuestions = total;
    });
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
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Zone'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.themeColor,
                  foregroundColor: Colors.white,
                ),
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
