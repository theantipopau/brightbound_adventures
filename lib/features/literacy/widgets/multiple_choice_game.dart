import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/features/literacy/models/question.dart';
import 'package:brightbound_adventures/core/services/ai_learning_assistant_service.dart';
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import 'package:brightbound_adventures/core/services/haptic_service.dart';
import 'package:brightbound_adventures/core/services/adaptive_difficulty_service.dart';
import 'package:brightbound_adventures/core/services/tts_service.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/controllers/game_session_controller.dart';
import 'package:brightbound_adventures/core/utils/question_variation_helper.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/responsive_quiz_layout.dart';
import 'package:brightbound_adventures/ui/widgets/difficulty_indicator.dart';
import 'package:brightbound_adventures/ui/widgets/confetti_burst.dart';
import 'package:brightbound_adventures/ui/widgets/star_burst_overlay.dart';
import 'package:brightbound_adventures/ui/widgets/animated_answer_option.dart';
import 'package:brightbound_adventures/ui/widgets/quiz_widgets.dart';
import 'package:brightbound_adventures/ui/widgets/juicy_button.dart';
import 'package:brightbound_adventures/ui/widgets/visual_effects/adventure_pattern_overlay.dart';
import 'package:brightbound_adventures/ui/widgets/visual_effects/screen_shaker.dart';

/// Multiple choice quiz game for literacy skills (Word Woods)
class MultipleChoiceGame extends StatefulWidget {
  final List<LiteracyQuestion> questions;
  final String skillName;
  final Color themeColor;
  final void Function(double accuracy, int correct, int total)? onComplete;
  final VoidCallback? onCancel;

  const MultipleChoiceGame({
    super.key,
    required this.questions,
    required this.skillName,
    this.themeColor = AppColors.wordWoodsColor,
    this.onComplete,
    this.onCancel,
  });

  @override
  State<MultipleChoiceGame> createState() => _MultipleChoiceGameState();
}

class _MultipleChoiceGameState extends State<MultipleChoiceGame>
    with TickerProviderStateMixin {
  late GameSessionController _gameController;
  late List<LiteracyQuestion> _shuffledQuestions;
  late FocusNode _focusNode;

  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _showHint = false;
  bool _hintUsed = false;
  bool _autoReadQuestions = false;
  bool _aiHintsEnabled = false;
  bool _aiExplanationsEnabled = false;
  bool _aiCloudMode = false;
  String? _activeHintText;
  String? _aiExplanationText;

  final AudioManager _audioManager = AudioManager();
  final AiLearningAssistantService _aiAssistant = AiLearningAssistantService();

  late AnimationController _feedbackController;
  late AnimationController _starController;
// ignore: unused_field
  late Animation<double> _starAnimation;
  late ScreenShakeController _shakeController;

  bool _showConfetti = false;
  bool _showStarBurst = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _shuffledQuestions =
        QuestionVariationHelper.buildSessionQuestionSet<LiteracyQuestion>(
      sessionKey:
          'literacy_${widget.skillName.toLowerCase().replaceAll(' ', '_')}',
      source: widget.questions,
      idOf: (q) => q.id,
      promptOf: (q) => q.question,
      groupKeyOf: (q) => q.skillId,
      desiredCount: widget.questions.length.clamp(1, 12),
      random: Random(),
    );

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
    _loadAutoReadPreference();

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
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
    _focusNode.dispose();
    _gameController.dispose();
    _feedbackController.dispose();
    _starController.dispose();
    super.dispose();
  }

  LiteracyQuestion get _currentQuestion => _shuffledQuestions[_currentIndex];

  Future<void> _loadAutoReadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final autoRead = prefs.getBool('autoReadQuestions') ?? false;
    final aiHintsEnabled = prefs.getBool('aiHintsEnabled') ?? false;
    final aiExplanationsEnabled =
        prefs.getBool('aiExplanationsEnabled') ?? false;
    final aiCloudMode = prefs.getBool('aiCloudMode') ?? false;
    if (!mounted) return;

    setState(() {
      _autoReadQuestions = autoRead;
      _aiHintsEnabled = aiHintsEnabled;
      _aiExplanationsEnabled = aiExplanationsEnabled;
      _aiCloudMode = aiCloudMode;
    });

    _aiAssistant
      ..setEnabled(aiHintsEnabled || aiExplanationsEnabled)
      ..setCloudMode(_aiCloudMode);

    if (autoRead) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _readCurrentQuestionAloud();
      });
    }
  }

  Future<void> _readCurrentQuestionAloud() async {
    if (!_autoReadQuestions || _gameController.state != GameState.playing) {
      return;
    }
    final questionText = _currentQuestion.question.trim();
    if (questionText.isEmpty) return;
    await TtsService().speak(questionText);
  }

  void _selectAnswer(int index) {
    if (_answered || _gameController.state != GameState.playing) return;

    final hapticService = context.read<HapticService>();

    setState(() {
      _selectedIndex = index;
      _answered = true;
    });

    final isCorrect = _currentQuestion.isCorrect(index);
    _gameController.submitAnswer(isCorrect);
    _prepareAiExplanation();

    final avatarProvider = context.read<AvatarProvider>();

    if (isCorrect) {
      hapticService.onCorrectAnswer();
      _audioManager.playCorrectAnswer();
      _starController.forward(from: 0);
      showFloatingReward(context, '+10 ⭐');
      // Avatar reacts with pride on 3-streak, joy otherwise
      avatarProvider.setEmotion(
        _gameController.streak >= 3 ? AvatarEmotion.proud : AvatarEmotion.happy,
        resetAfter: const Duration(milliseconds: 1800),
      );
      setState(() {
        _showConfetti = true;
        // Star burst fires on every 3rd consecutive correct answer
        if (_gameController.streak >= 3 && _gameController.streak % 3 == 0) {
          _showStarBurst = true;
        }
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showConfetti = false);
      });

      Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
    } else {
      hapticService.onWrongAnswer();
      // Avatar looks sad then thoughtful
      avatarProvider.setEmotion(AvatarEmotion.sad,
          resetAfter: const Duration(milliseconds: 800));
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          avatarProvider.setEmotion(AvatarEmotion.thinking,
              resetAfter: const Duration(milliseconds: 1200));
        }
      });
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
        _activeHintText = null;
        _aiExplanationText = null;
      });
      _gameController.startQuestionTimer();
      _readCurrentQuestionAloud();
    } else {
      _completeGame();
    }
  }

  void _completeGame({bool forced = false}) {
    final accuracy = _gameController.correctAnswers / _shuffledQuestions.length;
    if (accuracy == 1.0) {
      _audioManager.playPerfectScore();
    }
    widget.onComplete?.call(
        accuracy, _gameController.correctAnswers, _shuffledQuestions.length);
  }

  Future<void> _showHintDialog() async {
    if (_hintUsed) return;

    String? hintText = _currentQuestion.hint;
    if (_aiHintsEnabled) {
      hintText = await _aiAssistant.generateHint(
        question: _currentQuestion.question,
        options: _currentQuestion.options,
      );
    }

    if (!mounted) return;

    setState(() {
      _activeHintText = hintText ?? _currentQuestion.hint;
      _showHint = true;
      _hintUsed = true;
    });
  }

  Future<void> _prepareAiExplanation() async {
    if (!_aiExplanationsEnabled || _selectedIndex == null) {
      return;
    }

    final questionIndex = _currentIndex;
    final selectedAnswer = _currentQuestion.options[_selectedIndex!];
    final correctAnswer = _currentQuestion.correctAnswer;

    final explanation = await _aiAssistant.explainAnswer(
      question: _currentQuestion.question,
      selectedAnswer: selectedAnswer,
      correctAnswer: correctAnswer,
    );

    if (!mounted || questionIndex != _currentIndex) return;

    setState(() {
      _aiExplanationText = explanation;
    });
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
        return KeyboardListener(
          focusNode: _focusNode,
          onKeyEvent: (event) {
            if (event is! KeyDownEvent) return;
            final key = event.logicalKey;
            if (key == LogicalKeyboardKey.arrowUp) {
              if (_selectedIndex != null && _selectedIndex! > 0) {
                setState(() => _selectedIndex = _selectedIndex! - 1);
              } else if (_selectedIndex == null) {
                setState(() => _selectedIndex = 0);
              }
            } else if (key == LogicalKeyboardKey.arrowDown) {
              if (_selectedIndex != null &&
                  _selectedIndex! < _currentQuestion.options.length - 1) {
                setState(() => _selectedIndex = _selectedIndex! + 1);
              } else if (_selectedIndex == null) {
                setState(() => _selectedIndex = 0);
              }
            } else if (key == LogicalKeyboardKey.enter &&
                !_answered) {
              _selectAnswer(_selectedIndex ?? -1);
            } else if (key == LogicalKeyboardKey.escape) {
              _togglePause();
            }
          },
          child: Scaffold(
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

                Positioned.fill(
                  child: AdventurePatternOverlay(
                    color: widget.themeColor,
                    opacity: 0.1,
                    tileSize: 52,
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
                                    letterSpacing: 1.1),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),

                        // Timer Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _gameController.remainingTime /
                                  _gameController.maxTimePerQuestion,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation(
                                  _gameController.remainingTime < 10
                                      ? Colors.red
                                      : widget.themeColor),
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
                                ? _buildFeedback(_currentQuestion
                                    .isCorrect(_selectedIndex ?? -1))
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
                        particleCount: 120,
                        duration: const Duration(milliseconds: 3000),
                      ),
                    ),
                  ),

                // 3b. Star burst — fires on every 3rd consecutive correct answer
                if (_showStarBurst)
                  Positioned.fill(
                    child: StarBurstOverlay(
                      color: widget.themeColor,
                      armCount: 10,
                      duration: const Duration(milliseconds: 850),
                      onComplete: () {
                        if (mounted) setState(() => _showStarBurst = false);
                      },
                    ),
                  ),

                // 4. Pause Menu Overlay
                if (_gameController.state == GameState.paused)
                  _buildPauseOverlay(),
              ],
            ),

            // Floating Action Button for Hints
            floatingActionButton: (((_currentQuestion.hint?.isNotEmpty ?? false) ||
                  _aiHintsEnabled) &&
                    !_answered &&
                    _gameController.state == GameState.playing)
                ? FloatingActionButton(
                    backgroundColor: _hintUsed ? Colors.grey : Colors.amber,
                    onPressed: _hintUsed ? null : _showHintDialog,
                    child: const Icon(Icons.lightbulb),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, 10))
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('PAUSED',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                    const SizedBox(height: 32),
                    JuicyButton.primary(
                      label: 'RESUME',
                      onPressed: _togglePause,
                      icon: Icons.play_arrow,
                      width: 200,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _showExitConfirmation,
                      icon: const Icon(Icons.exit_to_app, color: Colors.red),
                      label: const Text('QUIT GAME',
                          style: TextStyle(color: Colors.red)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuestionCard(
          question: _currentQuestion.question,
          accentColor: widget.themeColor,
          questionNumber: _currentIndex + 1,
          totalQuestions: _shuffledQuestions.length,
        ),
        if (_showHint) ...[
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: AppMotion.smooth,
            curve: AppMotion.enter,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border: Border.all(color: Colors.amber.shade300, width: 1.5),
              borderRadius: BorderRadius.circular(AppBorders.md),
              boxShadow: AppShadows.sm(Colors.amber),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _activeHintText ?? _currentQuestion.hint ?? '',
                    style: TextStyle(
                      color: Colors.brown.shade800,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  AnswerState _getOptionState(int index) {
    if (!_answered) {
      return _selectedIndex == index ? AnswerState.selected : AnswerState.idle;
    }
    if (_currentQuestion.correctIndex == index) return AnswerState.correct;
    if (_selectedIndex == index) return AnswerState.incorrect;
    return AnswerState.idle;
  }

  static const List<String> _optionLetters = ['A', 'B', 'C', 'D', 'E'];

  Widget _buildOptionsArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(_currentQuestion.options.length, (index) {
        return AnimatedAnswerOption(
          key: ValueKey('${_currentIndex}_$index'),
          label: _currentQuestion.options[index],
          optionLetter: _optionLetters[index % _optionLetters.length],
          state: _getOptionState(index),
          isSelected: _selectedIndex == index,
          onTap: _answered ? null : () => _selectAnswer(index),
          accentColor: widget.themeColor,
          animationDelay: index * 60,
        );
      }),
    );
  }

  Widget _buildHeader() {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 760;

    return Container(
      padding:
          EdgeInsets.fromLTRB(12, isCompact ? 6 : 8, 12, isCompact ? 6 : 8),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2))
      ]),
      child: Row(
        children: [
          // Left: Home Button
          Tooltip(
            message: 'Go home',
            child: GestureDetector(
              onTap: _goHome,
              child: Container(
                width: isCompact ? 38 : 42,
                height: isCompact ? 38 : 42,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: widget.themeColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Image.asset('assets/images/scroll.PNG', fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Pause Button
          Tooltip(
            message: 'Pause Game',
            child: GestureDetector(
              onTap: _togglePause,
              child: Container(
                width: isCompact ? 38 : 42,
                height: isCompact ? 38 : 42,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: widget.themeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: widget.themeColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: _gameController.state == GameState.paused
                    ? Icon(Icons.play_arrow, color: widget.themeColor, size: 22)
                    : Image.asset('assets/images/questsandtasks.PNG', fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(width: 4),
          TtsSpeakerButton(
            text: _currentQuestion.question,
            color: widget.themeColor,
            size: isCompact ? 38 : 42,
          ),

          // Center: Skill Title + Difficulty
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.skillName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: isCompact ? 14 : 18,
                    )),
                // Difficulty Indicator
                Consumer<AdaptiveDifficultyService>(
                  builder: (context, difficultySvc, _) {
                    final difficulty = _shuffledQuestions.isNotEmpty
                        ? difficultySvc.getDifficultyForSkill(
                            _shuffledQuestions[0].skillId)
                        : 1;
                    return Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: DifficultyIndicator(
                        difficulty: difficulty,
                        color: widget.themeColor,
                        compact: true,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Right: Stats (Hearts + Score)
          Row(
            mainAxisSize: MainAxisSize.min,
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
                          index < _gameController.lives
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: index < _gameController.lives
                              ? Colors.redAccent
                              : Colors.grey[300],
                          size: isCompact ? 18 : 24),
                    ),
                  );
                }),
              ),
              SizedBox(width: isCompact ? 6 : 12),
              // Score Pills
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 8 : 12,
                    vertical: isCompact ? 4 : 6),
                decoration: BoxDecoration(
                    color: widget.themeColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: widget.themeColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ]),
                child: Row(
                  children: [
                    Icon(Icons.star,
                        color: Colors.yellow, size: isCompact ? 14 : 16),
                    SizedBox(width: isCompact ? 2 : 4),
                    Text(
                      '${_gameController.score}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isCompact ? 13 : 16,
                          color: Colors.white),
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

  /// Navigate home with confirmation dialog
  Future<void> _goHome() async {
    // Pause the game first
    if (_gameController.state != GameState.paused) {
      _togglePause();
    }

    final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Exit to Home?'),
            content:
                const Text('Your progress in this activity will not be saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child:
                    Text('Cancel', style: TextStyle(color: widget.themeColor)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text('Exit Home',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldExit && mounted) {
      // Pop back to zone detail screen
      Navigator.pop(context);
    }
  }

  Widget _buildFeedback(bool isCorrect) {
    final msg = isCorrect
        ? (_gameController.streak > 2
            ? '🔥 Streak x${_gameController.streak}!'
            : '✅ Correct!')
        : '❌ Not quite!';
    return AnimatedContainer(
      duration: AppMotion.standard,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: isCorrect ? AppGradients.success : AppGradients.error,
        borderRadius: BorderRadius.circular(AppBorders.pill),
        boxShadow: AppShadows.md(
            isCorrect ? const Color(0xFF06A77D) : const Color(0xFFE63946)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            msg,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          if (_aiExplanationText != null) ...[
            const SizedBox(height: 6),
            Text(
              _aiExplanationText!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFF6E8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
