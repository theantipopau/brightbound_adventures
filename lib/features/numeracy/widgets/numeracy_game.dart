import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/features/numeracy/models/question.dart';
import 'package:brightbound_adventures/core/services/ai_learning_assistant_service.dart';
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import 'package:brightbound_adventures/core/services/haptic_service.dart';
import 'package:brightbound_adventures/core/services/adaptive_difficulty_service.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/services/tts_service.dart';
import 'package:brightbound_adventures/core/controllers/game_session_controller.dart';
import 'package:brightbound_adventures/core/utils/question_variation_helper.dart';
import 'package:brightbound_adventures/ui/themes/app_theme.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/responsive_quiz_layout.dart';
import 'package:brightbound_adventures/ui/widgets/difficulty_indicator.dart';
import 'package:brightbound_adventures/ui/widgets/confetti_burst.dart';
import 'package:brightbound_adventures/ui/widgets/visual_effects/adventure_pattern_overlay.dart';
import 'package:brightbound_adventures/ui/widgets/visual_effects/screen_shaker.dart';
import 'package:brightbound_adventures/ui/widgets/animated_answer_option.dart';
import 'package:brightbound_adventures/ui/widgets/quiz_widgets.dart';

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

class _NumeracyGameState extends State<NumeracyGame>
    with TickerProviderStateMixin {
  late GameSessionController _gameController;
  late List<NumeracyQuestion> _shuffledQuestions;
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
  late Animation<double> _feedbackAnimation;
  late AnimationController _starController;
// ignore: unused_field
  late Animation<double> _starAnimation;
  late ScreenShakeController _shakeController;

  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _shuffledQuestions =
        QuestionVariationHelper.buildSessionQuestionSet<NumeracyQuestion>(
      sessionKey:
          'numeracy_${widget.skillName.toLowerCase().replaceAll(' ', '_')}',
      source: widget.questions,
      idOf: (q) => q.id,
      promptOf: (q) => q.question,
      groupKeyOf: (q) => q.type.name,
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

    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _gameController.dispose();
    _feedbackController.dispose();
    _starController.dispose();
    super.dispose();
  }

  NumeracyQuestion get _currentQuestion => _shuffledQuestions[_currentIndex];

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

  static const List<String> _optionLetters = ['A', 'B', 'C', 'D', 'E'];

  AnswerState _getOptionState(int index) {
    if (!_answered) {
      return _selectedIndex == index ? AnswerState.selected : AnswerState.idle;
    }
    if (_currentQuestion.correctIndex == index) return AnswerState.correct;
    if (_selectedIndex == index) return AnswerState.incorrect;
    return AnswerState.idle;
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
      showFloatingReward(context, '+10 ⭐', color: Colors.amber);
      avatarProvider.setEmotion(
        _gameController.streak >= 3 ? AvatarEmotion.proud : AvatarEmotion.happy,
        resetAfter: const Duration(milliseconds: 1800),
      );
      setState(() {
        _showConfetti = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showConfetti = false);
      });

      Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
    } else {
      hapticService.onWrongAnswer();
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
                  ElevatedButton.icon(
                      onPressed: _togglePause,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('RESUME'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          textStyle: const TextStyle(fontSize: 20))),
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
    );
  }

  Widget _buildQuestionCard() {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 700;

    return Container(
      padding: EdgeInsets.all(isCompact ? 20 : 28),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, widget.themeColor.withValues(alpha: 0.07)],
        ),
        borderRadius: BorderRadius.circular(AppBorders.xl),
        border: Border.all(
          color: widget.themeColor.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: AppShadows.md(widget.themeColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Q number chip
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppBorders.pill),
              ),
              child: Text(
                'Q${_currentIndex + 1} of ${_shuffledQuestions.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: widget.themeColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SizedBox(height: isCompact ? 16 : 24),
          _buildIllustration(),
          SizedBox(height: isCompact ? 16 : 24),
          Text(
            _currentQuestion.question,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 22 : 26,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          if (_showHint) ...[
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: AppMotion.standard,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade200),
                borderRadius: BorderRadius.circular(AppBorders.md),
                boxShadow: AppShadows.sm(Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _activeHintText ?? _currentQuestion.hint ?? '',
                      style: TextStyle(color: Colors.brown.shade800, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

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
      padding: EdgeInsets.fromLTRB(4, isCompact ? 4 : 6, 12, isCompact ? 4 : 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.themeColor,
            widget.themeColor.withValues(alpha: 0.80),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.themeColor.withValues(alpha: 0.45),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
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
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                ),
                child: _gameController.state == GameState.paused
                    ? const Icon(Icons.play_arrow, color: Colors.white, size: 22)
                    : Image.asset('assets/images/questsandtasks.PNG', fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(width: 4),
          TtsSpeakerButton(
            text: _currentQuestion.question,
            color: Colors.white,
            size: isCompact ? 38 : 42,
          ),

          // Center: Skill Title + Difficulty
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.skillName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isCompact ? 14 : 18,
                    shadows: const [
                      Shadow(
                        color: Color(0x44000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
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
                        color: Colors.white,
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
                            ? Colors.red.shade300
                            : Colors.white.withValues(alpha: 0.4),
                        size: isCompact ? 18 : 24,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(width: isCompact ? 6 : 12),
              // Score Pill
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 8 : 12,
                    vertical: isCompact ? 4 : 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star,
                        color: Colors.amber.shade300,
                        size: isCompact ? 14 : 16),
                    SizedBox(width: isCompact ? 2 : 4),
                    Text(
                      '${_gameController.score}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isCompact ? 13 : 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedback(bool isCorrect) {
    // Varied correct messages for variety
    final correctMessages = [
      'Brilliant! 🌟',
      'Amazing! 🎉',
      'You got it! 🏆',
      'Correct! ✅',
      'Well done! 💪',
    ];
    final streakMessages = [
      '${_gameController.streak} in a row! 🔥',
      'Streak x${_gameController.streak}!! ⚡',
      'On fire! x${_gameController.streak} 🔥',
    ];
    final wrongMessages = [
      'Nice try! Keep going 💛',
      "Almost! You've got this 💙",
      'Not quite – try the next one! 🌈',
    ];

    String message;
    if (isCorrect) {
      if (_gameController.streak >= 3) {
        message =
            streakMessages[_gameController.streak % streakMessages.length];
      } else {
        message = correctMessages[_currentIndex % correctMessages.length];
      }
    } else {
      message = wrongMessages[_currentIndex % wrongMessages.length];
    }

    final pts = _gameController.multiplier * 10;
    final bgColor = isCorrect ? Colors.green.shade500 : Colors.red.shade400;

    return ScaleTransition(
      scale: _feedbackAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isCorrect
                ? [Colors.green.shade500, Colors.teal.shade400]
                : [Colors.red.shade400, Colors.deepOrange.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.5),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.sentiment_neutral,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isCorrect)
                    Text(
                      '+$pts pts',
                      style: TextStyle(
                        color: Colors.yellow.shade200,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if (_aiExplanationText != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _aiExplanationText!,
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
        if (qStr.contains('Triangle')) {
          return const Icon(Icons.change_history,
              size: 100, color: Colors.orange);
        }
        if (qStr.contains('Square')) {
          return const Icon(Icons.crop_square, size: 100, color: Colors.blue);
        }
        if (qStr.contains('Circle')) {
          return const Icon(Icons.circle_outlined,
              size: 100, color: Colors.red);
        }
        if (qStr.contains('Rectangle')) {
          return const Icon(Icons.rectangle_outlined,
              size: 100, color: Colors.green);
        }
        return const Icon(Icons.category, size: 100, color: Colors.teal);
      }

      // 3. Time
      if (qStr.contains('time') || qStr.contains('clock')) {
        return const Icon(Icons.access_time_filled,
            size: 100, color: Colors.blueGrey);
      }
    } catch (_) {}

    // Fallback generic icon
    return Container(
      padding: const EdgeInsets.all(20),
      // ignore: deprecated_member_use
      decoration:
          BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
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
