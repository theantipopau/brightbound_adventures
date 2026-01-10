import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/utils/word_woods_generator.dart';
import 'package:brightbound_adventures/features/literacy/models/question.dart';
import 'package:brightbound_adventures/features/literacy/widgets/multiple_choice_game.dart';
import 'package:brightbound_adventures/features/literacy/widgets/quiz_results_screen.dart';

/// Skill practice screen that connects skills to their games
class SkillPracticeScreen extends StatefulWidget {
  final Skill skill;
  final Color themeColor;

  const SkillPracticeScreen({
    super.key,
    required this.skill,
    required this.themeColor,
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
