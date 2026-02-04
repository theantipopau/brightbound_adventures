import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import 'package:brightbound_adventures/core/services/haptic_service.dart';
import 'package:brightbound_adventures/core/controllers/game_session_controller.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/responsive_quiz_layout.dart';
import 'package:brightbound_adventures/ui/widgets/confetti_burst.dart';
import 'package:brightbound_adventures/ui/widgets/visual_effects/screen_shaker.dart';

/// Multiple choice quiz game for numeracy skills
class NumeracyGame extends StatefulWidget {
  final List<NumeracyQuestion> questions;
  final String skillName;
  final Color themeColor;
  final void Function(double accuracy, int correct, int total)? onComplete;
  final VoidCallback? onCancel;

  const NumeracyGame({
    super.key,
    required this.questions,
    required this.skillName,
    this.themeColor = AppColors.numberNebulaColor,
    this.onComplete,
    this.onCancel,
  });

  @override
  State<NumeracyGame> createState() => _NumeracyGameState();
}

class _NumeracyGameState extends State<NumeracyGame> with TickerProviderStateMixin {
  late GameSessionController _gameController;
  late List<NumeracyQuestion> _shuffledQuestions;
  
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _showHint = false;
  bool _hintUsed = false;
  
  final AudioManager _audioManager = AudioManager();

  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  late AnimationController _starController;
// ignore: unused_field
  late Animation<double> _starAnimation;
  late ScreenShakeController _shakeController;
  
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _shuffledQuestions = List.from(widget.questions)..shuffle(Random());

    _gameController = GameSessionController(
      maxLives: 3,
      totalQuestions: _shuffledQuestions.length,
      maxTimePerQuestion: 60,
      onLifeLost: () {
        _audioManager.playIncorrectAnswer();
        _shakeController.shake();
      },
      onGameOver: () {
         _completeGame(forced: true);
      },
      onLevelComplete: () {
        _completeGame();
      },
    );
    _gameController.startGame();
    _gameController.startQuestionTimer();

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _feedbackAnimation = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    );

    _starController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _starAnimation = CurvedAnimation(
      parent: _starController,
      curve: Curves.elasticOut,
    );

    _shakeController = ScreenShakeController();
  }

  @override
  void dispose() {
    _gameController.dispose();
    _feedbackController.dispose();
    _starController.dispose();
    super.dispose();
  }

  NumeracyQuestion get _currentQuestion => _shuffledQuestions[_currentIndex];

  void _selectAnswer(int index) {
    if (_answered || _gameController.state != GameState.playing) return;

    final hapticService = context.read<HapticService>();

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    final isCorrect = _currentQuestion.isCorrect(index);
    _gameController.submitAnswer(isCorrect);

    if (isCorrect) {
      hapticService.onCorrectAnswer();
      _audioManager.playCorrectAnswer();
      _starController.forward(from: 0);
      setState(() {
        _showConfetti = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showConfetti = false);
      });
      
      Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
    } else {
      hapticService.onWrongAnswer();
      Future.delayed(const Duration(milliseconds: 2000), _nextQuestion);
    }

    _feedbackController.forward(from: 0);
  }

  void _nextQuestion() {
    if (_gameController.state == GameState.finished) return;

    if (_currentIndex < _shuffledQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
        _showHint = false;
        _hintUsed = false;
      });
      _gameController.startQuestionTimer();
    } else {
      _completeGame();
    }
  }

  void _completeGame({bool forced = false}) {
    final accuracy = _gameController.correctAnswers / _shuffledQuestions.length;
    if (accuracy == 1.0) {
      _audioManager.playPerfectScore();
    }
    widget.onComplete?.call(accuracy, _gameController.correctAnswers, _shuffledQuestions.length);
  }

  void _showHintDialog() {
    if (!_hintUsed && _currentQuestion.hint != null) {
      setState(() {
        _showHint = true;
        _hintUsed = true;
      });
    }
  }
  
  void _togglePause() {
    if (_gameController.state == GameState.playing) {
      _gameController.pauseGame();
    } else if (_gameController.state == GameState.paused) {
      _gameController.resumeGame();
    }
  }

  void _showExitConfirmation() {
    bool wasPlaying = _gameController.state == GameState.playing;
    if (wasPlaying) _gameController.pauseGame();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quit Practice?'),
        content: const Text('You will lose your current streak and points.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (wasPlaying) _gameController.resumeGame();
            },
            child: const Text('Keep Playing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              widget.onCancel?.call();
            },
            child: const Text('Quit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate center for confetti
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 3);

    return AnimatedBuilder(
      animation: _gameController,
      builder: (context, _) {
      return Scaffold(
        body: Stack(
          children: [
            // 1. Gradient Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      widget.themeColor.withValues(alpha: 0.15),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
            
            // 2. Main Game Content
            SafeArea(
              child: ScreenShaker(
                controller: _shakeController,
                child: Column(
                  children: [
                    _buildHeader(),
                    
                    // Streak Banner
                    if (_gameController.streak > 1)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 32,
                        width: double.infinity,
                        color: Colors.orange.withValues(alpha: 0.15),
                        child: Center(
                          child: Text(
                            '🔥 STREAK x${_gameController.streak} (${_gameController.multiplier}x Multiplier!) 🔥',
                            style: TextStyle(
                              color: Colors.orange[800],
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1
                            ),
                          ),
                        ),
                      ),
                      
                    // Timer Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _gameController.remainingTime / _gameController.maxTimePerQuestion,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(
                            _gameController.remainingTime < 10 ? Colors.red : widget.themeColor
                          ),
                          minHeight: 12,
                        ),
                      ),
                    ),

                    // Quiz Layout
                    Expanded(
                      child: ResponsiveQuizLayout(
                        questionCard: _buildQuestionCard(),
                        optionsArea: _buildOptionsArea(),
                        feedbackWidget: _answered
                            ? _buildFeedback(_currentQuestion.isCorrect(_selectedIndex ?? -1))
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // 3. Confetti Effects
            if (_showConfetti)
              Positioned.fill(
                child: IgnorePointer(
                  child: ConfettiBurst(
                    center: center,
                    particleCount: 40,
                  ),
                ),
              ),
              
            // 4. Pause Menu Overlay
            if (_gameController.state == GameState.paused)
              _buildPauseOverlay(),
          ],
        ),
        
        // Floating Action Button for Hints
        floatingActionButton: (_currentQuestion.hint != null && !_answered && _gameController.state == GameState.playing)
           ? FloatingActionButton(
               backgroundColor: _hintUsed ? Colors.grey : Colors.amber,
               onPressed: _hintUsed ? null : _showHintDialog,
               child: const Icon(Icons.lightbulb),
             )
           : null
      );
    });
  }

  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(24),
                 boxShadow: [
                   BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0,10))
                 ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('PAUSED', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _togglePause, 
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('RESUME'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      textStyle: const TextStyle(fontSize: 20)
                    )
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _showExitConfirmation, 
                    icon: const Icon(Icons.exit_to_app, color: Colors.red),
                    label: const Text('QUIT GAME', style: TextStyle(color: Colors.red)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return HoverCard(
      enabled: false,
      child: Container(
        padding: const EdgeInsets.all(32),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIllustration(),
            const SizedBox(height: 32),
            Text(
              _currentQuestion.question,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            if (_showHint) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentQuestion.hint ?? '',
                        style: TextStyle(color: Colors.brown.shade800, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(_currentQuestion.options.length, (index) {
         final isSelected = _selectedIndex == index;
         final isCorrect = _currentQuestion.correctIndex == index;
         
         Color btnColor = Colors.white;
         Color hoverColor = widget.themeColor.withValues(alpha: 0.1);

         if (_answered) {
            if (isCorrect) {
              btnColor = Colors.green.shade100;
              hoverColor = Colors.green.shade200;
            }
            else if (isSelected) {
              btnColor = Colors.red.shade100;
              hoverColor = Colors.red.shade200;
            }
         } else if (isSelected) {
            btnColor = widget.themeColor.withValues(alpha: 0.1);
         }
         
         return Padding(
           padding: const EdgeInsets.only(bottom: 16),
           child: HoverButton(
              onPressed: () => _selectAnswer(index),
              enabled: !_answered,
              backgroundColor: btnColor,
              hoverColor: hoverColor,
              height: 72,
              child: Text(
                 _currentQuestion.options[index],
                 style: TextStyle(
                    fontSize: 22, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: Colors.black87
                 )
              )
           ) 
         );
      })
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
             color: Colors.black.withValues(alpha: 0.05),
             blurRadius: 4,
             offset: const Offset(0, 2)
          )
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Pause Button
          IconButton(
            icon: Icon(_gameController.state == GameState.paused ? Icons.play_arrow : Icons.pause),
            color: Colors.grey[700],
            onPressed: _togglePause,
            tooltip: 'Pause Game',
          ),
          
          // Center: Skill Title
          Expanded(
            child: Text(
              widget.skillName, 
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.themeColor,
                fontWeight: FontWeight.bold,
                fontSize: 18
              )
            ),
          ),
          
          // Right: Stats (Hearts + Score)
          Row(
            children: [
               // Lives
               Row(
                 children: List.generate(3, (index) {
                   return Padding(
                     padding: const EdgeInsets.only(right: 2),
                     child: AnimatedScale(
                       duration: const Duration(milliseconds: 300),
                       scale: index < _gameController.lives ? 1.0 : 0.8,
                       child: Icon(
                         index < _gameController.lives ? Icons.favorite : Icons.favorite_border,
                         color: index < _gameController.lives ? Colors.redAccent : Colors.grey[300], 
                         size: 24
                       ),
                     ),
                   );
                 }),
               ),
               const SizedBox(width: 12),
               // Score Pills
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                 decoration: BoxDecoration(
                   color: widget.themeColor, 
                   borderRadius: BorderRadius.circular(20),
                   boxShadow: [
                     BoxShadow(
                       color: widget.themeColor.withValues(alpha: 0.3),
                       blurRadius: 4,
                       offset: const Offset(0, 2)
                     )
                   ]
                 ),
                 child: Row(
                   children: [
                     const Icon(Icons.star, color: Colors.yellow, size: 16),
                     const SizedBox(width: 4),
                     Text(
                       '${_gameController.score}',
                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                     ),
                   ],
                 ),
               )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeedback(bool isCorrect) {
    return ScaleTransition(
      scale: _feedbackAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (isCorrect ? Colors.green : Colors.red).withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              isCorrect 
                ? (_gameController.streak > 2 ? 'Streak x${_gameController.streak}!!' : 'Correct!')
                : 'Nice try!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    // Attempt to render visual based on question logic
    try {
      final qStr = _currentQuestion.question;
      // 1. Check if simple addition: "5 + 3 = ?"
      if (qStr.contains('+') && qStr.contains('=')) {
        final parts = qStr.split(' ');
        final num1 = int.tryParse(parts[0]);
        final num2 = int.tryParse(parts[2]);
        if (num1 != null && num2 != null && (num1 + num2 <= 12)) {
           return Row(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               _buildDotGroup(num1, Colors.blue),
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 12),
                 child: Icon(Icons.add, size: 32, color: widget.themeColor),
               ),
               _buildDotGroup(num2, Colors.purple),
             ],
           );
        }
      }
      
      // 2. Check for Geometry: "Hexagon"
      if (qStr.toLowerCase().contains('sides')) {
        if (qStr.contains('Triangle')) return const Icon(Icons.change_history, size: 100, color: Colors.orange);
        if (qStr.contains('Square')) return const Icon(Icons.crop_square, size: 100, color: Colors.blue);
        if (qStr.contains('Circle')) return const Icon(Icons.circle_outlined, size: 100, color: Colors.red);
        if (qStr.contains('Rectangle')) return const Icon(Icons.rectangle_outlined, size: 100, color: Colors.green);
        return const Icon(Icons.category, size: 100, color: Colors.teal);
      }
      
      // 3. Time
      if (qStr.contains('time') || qStr.contains('clock')) {
         return const Icon(Icons.access_time_filled, size: 100, color: Colors.blueGrey);
      }
      
    } catch (_) {}

    // Fallback generic icon
    return Container(
      padding: const EdgeInsets.all(20),
      // ignore: deprecated_member_use
      decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
      child: Icon(
        Icons.functions,
        size: 60,
        color: widget.themeColor.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildDotGroup(int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: List.generate(
          count,
          (index) => Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
