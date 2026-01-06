import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/motor_game.dart';
import '../widgets/motor_game.dart';
import '../widgets/motor_results_screen.dart';
import 'package:brightbound_adventures/core/services/skill_provider.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/utils/adventure_arena_generator.dart';

/// Main screen for Adventure Arena motor skills practice
/// Routes to appropriate motor game based on skill selected
class MotorPracticeScreen extends StatefulWidget {
  final String skillId;
  final String skillName;

  const MotorPracticeScreen({
    super.key,
    required this.skillId,
    required this.skillName,
  });

  @override
  State<MotorPracticeScreen> createState() => _MotorPracticeScreenState();
}

class _MotorPracticeScreenState extends State<MotorPracticeScreen> {
  bool _showResults = false;
  MotorGameResult? _gameResult;

  void _onGameComplete(MotorGameResult result) {
    setState(() {
      _gameResult = result;
      _showResults = true;
    });

    // Update skill progress
    final skillProvider = Provider.of<SkillProvider>(context, listen: false);
    
    skillProvider.updateSkillProgress(
      skillId: widget.skillId,
      sessionAccuracy: result.accuracy,
      sessionHints: 0,
    );

    // Award XP
    final avatarProvider = Provider.of<AvatarProvider>(context, listen: false);
    avatarProvider.addExperience(result.xpEarned);
  }

  void _onContinue() {
    Navigator.of(context).pop();
  }

  void _onRetry() {
    setState(() {
      _showResults = false;
      _gameResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults && _gameResult != null) {
      return MotorResultsScreen(
        targetsHit: _gameResult!.targetsHit,
        totalTargets: _gameResult!.totalTargets,
        score: _gameResult!.score,
        avgReactionTime: _gameResult!.averageReactionTime,
        accuracy: _gameResult!.accuracy,
        xpEarned: _gameResult!.xpEarned,
        skillName: widget.skillName,
        onContinue: _onContinue,
        onRetry: _onRetry,
      );
    }

    final config = AdventureArenaGenerator.generate(
      skill: widget.skillId,
      difficulty: 3,
    );

    return MotorGame(
      config: config,
      onGameComplete: _onGameComplete,
    );
  }
}
