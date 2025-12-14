import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../widgets/story_game.dart';
import '../widgets/story_results_screen.dart';
import 'package:brightbound_adventures/core/services/skill_provider.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';

/// Main screen for Story Springs skill practice
/// Routes to appropriate story game based on skill selected
class StoryPracticeScreen extends StatefulWidget {
  final String skillId;
  final String skillName;
  
  const StoryPracticeScreen({
    super.key,
    required this.skillId,
    required this.skillName,
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
    switch (widget.skillId) {
      case 'skill_story_sequencing':
        return StorySequencingQuestions.getByDifficulty(3);
      case 'skill_emotion_recognition':
        return EmotionRecognitionQuestions.getByDifficulty(3);
      case 'skill_descriptive_language':
        return DescriptiveLanguageQuestions.getByDifficulty(3);
      case 'skill_dialogue_creation':
        return DialogueCreationQuestions.getByDifficulty(3);
      case 'skill_plot_structure':
        return PlotStructureQuestions.getByDifficulty(3);
      case 'skill_character_development':
        return CharacterDevelopmentQuestions.getByDifficulty(3);
      default:
        // For skills without question banks yet, return sequencing
        return StorySequencingQuestions.getByDifficulty(3);
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
    
    // Record practice session with proper API
    skillProvider.updateSkillProgress(
      skillId: widget.skillId,
      sessionAccuracy: percentage,
      sessionHints: 0, // Story games don't track hints the same way
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
