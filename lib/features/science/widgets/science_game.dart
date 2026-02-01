import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/models/index.dart'; // Ensure index exports Question or similar
import 'package:brightbound_adventures/core/models/naplan/naplan_question_set.dart'; // Import the new model
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import 'package:brightbound_adventures/core/services/haptic_service.dart';
import 'package:brightbound_adventures/ui/themes/index.dart'; // For AppColors
// Use a generic game widget or copy logic from others.
// Ideally, we'd refactor MultipleChoiceGame to be generic. 
// For now, I'll create a simplified version for Science.

class ScienceGame extends StatefulWidget {
  final List<Question> questions;
  final VoidCallback onComplete;

  const ScienceGame({
    super.key,
    required this.questions,
    required this.onComplete,
  });

  @override
  State<ScienceGame> createState() => _ScienceGameState();
}

class _ScienceGameState extends State<ScienceGame> {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedCorrectly;

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Science Lab 🔬'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.questions.length,
              color: Colors.teal,
            ),
            const SizedBox(height: 20),
            Text(
              question.question,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...List.generate(question.options.length, (index) {
              final isCorrect = index == question.correctIndex;
              final isSelected = _answered; // Simplified for demo
              
              Color color = Colors.white;
              if (_answered) {
                if (isCorrect) color = Colors.green.shade100;
                else color = Colors.red.shade50;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.all(20),
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _answered ? null : () => _handleAnswer(index),
                    child: Text(
                      question.options[index],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              );
            }),
            if (_answered)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton.icon(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              )
          ],
        ),
      ),
    );
  }

  void _handleAnswer(int index) {
    final question = widget.questions[_currentIndex];
    final isCorrect = index == question.correctIndex;
    
    // Haptic Feedback
    final haptic = context.read<HapticService>();
    if (isCorrect) {
      haptic.onCorrectAnswer();
      _score++;
    } else {
      haptic.onWrongAnswer();
    }

    setState(() {
      _answered = true;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
      });
    } else {
      widget.onComplete();
    }
  }
}
