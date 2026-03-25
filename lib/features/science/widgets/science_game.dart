import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import 'package:brightbound_adventures/core/services/ai_learning_assistant_service.dart';
import 'package:brightbound_adventures/core/services/avatar_provider.dart';
import 'package:brightbound_adventures/core/services/haptic_service.dart';
import 'package:brightbound_adventures/core/services/adaptive_difficulty_service.dart';
import 'package:brightbound_adventures/core/services/tts_service.dart';
import 'package:brightbound_adventures/core/controllers/game_session_controller.dart';
import 'package:brightbound_adventures/core/utils/question_variation_helper.dart';
import 'package:brightbound_adventures/ui/widgets/responsive_quiz_layout.dart';
import 'package:brightbound_adventures/ui/widgets/difficulty_indicator.dart';
import 'package:brightbound_adventures/ui/widgets/confetti_burst.dart';
import 'package:brightbound_adventures/ui/widgets/visual_effects/adventure_pattern_overlay.dart';
import 'package:brightbound_adventures/ui/widgets/visual_effects/screen_shaker.dart';
import 'package:brightbound_adventures/ui/widgets/animated_answer_option.dart';
import 'package:brightbound_adventures/ui/widgets/quiz_widgets.dart';
import 'package:brightbound_adventures/ui/themes/app_theme.dart';

class ScienceGame extends StatefulWidget {
  final List<dynamic>
      questions; // Using dynamic to be safe, or Question if we are sure
  final String skillName;
  final Color themeColor;
  final void Function(double accuracy, int correct, int total)? onComplete;
  final VoidCallback? onCancel;

  const ScienceGame({
    super.key,
    required this.questions,
    this.skillName = 'Science Lab',
    this.themeColor = Colors.teal, // AppColors.scienceLabColor
    this.onComplete,
    this.onCancel,
  });

  @override
  State<ScienceGame> createState() => _ScienceGameState();
}

class _ScienceGameState extends State<ScienceGame>
    with TickerProviderStateMixin {
  late GameSessionController _gameController;
  late List<dynamic> _shuffledQuestions;
  late FocusNode _focusNode;

  int _currentIndex = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _autoReadQuestions = false;
  bool _aiHintsEnabled = false;
  bool _aiExplanationsEnabled = false;
  bool _aiCloudMode = false;
  String? _aiExplanationText;

  int _discoveryMeter = 0;
  bool _streakShieldAvailable = false;
  String _coachMessage = 'Observe closely and test your hypothesis!';
  int _hintsRemaining = 3;
  bool _hintUsedThisQuestion = false;
  String? _revealedHint;

  final AudioManager _audioManager = AudioManager();
  final AiLearningAssistantService _aiAssistant = AiLearningAssistantService();

  late AnimationController _feedbackController;
  late Animation<double> _feedbackAnimation;
  late AnimationController _starController;
  late ScreenShakeController _shakeController;

  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _shuffledQuestions =
        QuestionVariationHelper.buildSessionQuestionSet<dynamic>(
      sessionKey:
          'science_${widget.skillName.toLowerCase().replaceAll(' ', '_')}',
      source: widget.questions,
      idOf: (q) => '${q.id}',
      promptOf: (q) => '${q.question}',
      groupKeyOf: (q) => '${q.topic ?? 'general'}',
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

  dynamic get _currentQuestion => _shuffledQuestions[_currentIndex];

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
    final questionText = '${_currentQuestion.question}'.trim();
    if (questionText.isEmpty) return;
    await TtsService().speak(questionText);
  }

  static const List<String> _optionLetters = ['A', 'B', 'C', 'D', 'E'];

  AnswerState _getOptionState(int index) {
    if (!_answered) {
      return _selectedIndex == index ? AnswerState.selected : AnswerState.idle;
    }
    if ((_currentQuestion.correctIndex as int) == index) {
      return AnswerState.correct;
    }
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

    // Access properties dynamically as we're using dynamic/generic Question
    final int correctIndex = _currentQuestion.correctIndex;
    final isCorrect = index == correctIndex;

    _gameController.submitAnswer(isCorrect);
    _prepareAiExplanation();

    if (isCorrect) {
      hapticService.onCorrectAnswer();
      _audioManager.playCorrectAnswer();
      _starController.forward(from: 0);
      showFloatingReward(context, '+10 ⭐', color: Colors.purpleAccent);

      setState(() {
        _discoveryMeter = (_discoveryMeter + 22).clamp(0, 100);
        _coachMessage = _nextCoachMessage(isCorrect: true);
      });

      if (_gameController.streak >= 4 && !_streakShieldAvailable) {
        setState(() {
          _streakShieldAvailable = true;
          _coachMessage = 'Great streak! You earned a Science Shield.';
        });
      }

      if (_discoveryMeter >= 100) {
        _gameController
          ..addBonusScore(200)
          ..addTime(5);
        setState(() {
          _discoveryMeter = 0;
          _coachMessage = 'Discovery Boost activated: +200 score and +5s!';
        });
      }

      setState(() {
        _showConfetti = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showConfetti = false);
      });

      Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
    } else {
      hapticService.onWrongAnswer();

      var shieldSavedLife = false;
      if (_streakShieldAvailable) {
        _gameController.addExtraLife();
        shieldSavedLife = true;
        setState(() {
          _streakShieldAvailable = false;
        });
      }

      setState(() {
        _discoveryMeter = (_discoveryMeter - 28).clamp(0, 100);
        _coachMessage = shieldSavedLife
            ? 'Science Shield blocked a life loss. Keep experimenting!'
            : _nextCoachMessage(isCorrect: false);
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
        _hintUsedThisQuestion = false;
        _revealedHint = null;
        _aiExplanationText = null;
        _coachMessage = 'New clue found. Investigate this question!';
      });
      _gameController.startQuestionTimer();
      _readCurrentQuestionAloud();
    } else {
      _completeGame();
    }
  }

  String _nextCoachMessage({required bool isCorrect}) {
    const success = [
      'Excellent observation!',
      'Brilliant science thinking!',
      'You connected the clues perfectly!',
      'Great experiment result!',
    ];
    const retry = [
      'Close one. Check the details and try again.',
      'Every scientist learns from misses.',
      'Review the evidence and test another option.',
      'Stay curious. You are improving each round.',
    ];

    final list = isCorrect ? success : retry;
    return list[Random().nextInt(list.length)];
  }

  String _questionTopic(dynamic question) {
    final topic = '${question.topic ?? ''}'.trim();
    return topic.isEmpty ? 'general science' : topic;
  }

  int _questionDifficulty(dynamic question) {
    final value = question.difficulty;
    if (value is int) return value;
    return int.tryParse('$value') ?? 1;
  }

  String _buildHintText() {
    final options =
        (_currentQuestion.options as List).map((e) => '$e').toList();
    final correctIndex = _currentQuestion.correctIndex as int;
    final wrongIndexes = List<int>.generate(options.length, (i) => i)
        .where((i) => i != correctIndex)
        .toList();

    if (wrongIndexes.isNotEmpty) {
      final eliminated = wrongIndexes[Random().nextInt(wrongIndexes.length)];
      return 'Hint: Option ${eliminated + 1} is unlikely based on the evidence.';
    }

    final topic = _questionTopic(_currentQuestion);
    return 'Hint: Re-check the core concept in $topic and compare each choice carefully.';
  }

  Future<void> _prepareAiExplanation() async {
    if (!_aiExplanationsEnabled || _selectedIndex == null) {
      return;
    }

    final questionIndex = _currentIndex;
    final options = (_currentQuestion.options as List).map((e) => '$e').toList();
    final selectedAnswer = options[_selectedIndex!];
    final correctAnswer = options[_currentQuestion.correctIndex as int];

    final explanation = await _aiAssistant.explainAnswer(
      question: '${_currentQuestion.question}',
      selectedAnswer: selectedAnswer,
      correctAnswer: correctAnswer,
    );

    if (!mounted || questionIndex != _currentIndex) return;

    setState(() {
      _aiExplanationText = explanation;
    });
  }

  Future<void> _useHint() async {
    if (_answered || _hintUsedThisQuestion || _hintsRemaining <= 0) return;

    String hintText = _buildHintText();
    if (_aiHintsEnabled) {
      hintText = await _aiAssistant.generateHint(
        question: '${_currentQuestion.question}',
        options: (_currentQuestion.options as List).map((e) => '$e').toList(),
      );
    }

    if (!mounted) return;

    setState(() {
      _hintsRemaining--;
      _hintUsedThisQuestion = true;
      _revealedHint = hintText;
      _coachMessage = 'Hint deployed. Test your best hypothesis now.';
    });
  }

  void _completeGame({bool forced = false}) {
    final accuracy = _gameController.correctAnswers / _shuffledQuestions.length;
    if (accuracy == 1.0) {
      _audioManager.playPerfectScore();
    }
    widget.onComplete?.call(
        accuracy, _gameController.correctAnswers, _shuffledQuestions.length);
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
        title: const Text('Quit Science Lab?'),
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

                        _buildScienceSystemsPanel(),

                        // Quiz Layout
                        Expanded(
                          child: ResponsiveQuizLayout(
                            questionCard: _buildQuestionCard(),
                            optionsArea: _buildOptionsArea(),
                            feedbackWidget: _answered
                                ? _buildFeedback(_selectedIndex ==
                                    _currentQuestion.correctIndex)
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

    final qText = _currentQuestion.question as String;
    final topic = _questionTopic(_currentQuestion);
    final difficulty = _questionDifficulty(_currentQuestion);

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
          SizedBox(height: isCompact ? 14 : 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration:
                BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(
              Icons.science,
              size: isCompact ? 48 : 60,
              color: widget.themeColor.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: isCompact ? 14 : 20),
          Text(
            qText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isCompact ? 22 : 26,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _ScienceChip(icon: '🔬', label: topic, color: widget.themeColor),
              _ScienceChip(
                  icon: '📈',
                  label: 'Difficulty $difficulty',
                  color: Colors.indigo),
            ],
          ),
          if (_revealedHint != null) ...[
            const SizedBox(height: 14),
            AnimatedContainer(
              duration: AppMotion.standard,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(AppBorders.md),
                border: Border.all(color: Colors.amber.shade300),
                boxShadow: AppShadows.sm(Colors.amber),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(Icons.lightbulb, color: Colors.amber, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _revealedHint!,
                      style: TextStyle(
                        fontSize: isCompact ? 13 : 14,
                        color: Colors.brown.shade800,
                        fontWeight: FontWeight.w600,
                      ),
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
    final options = _currentQuestion.options as List<String>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(options.length, (index) {
        return AnimatedAnswerOption(
          key: ValueKey('${_currentIndex}_$index'),
          label: options[index],
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
    final avatar = context.watch<AvatarProvider>().avatar;
    final playerName = avatar?.name ?? 'Scientist';

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
                  color: widget.themeColor.withValues(alpha: 0.10),
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
                  color: widget.themeColor.withValues(alpha: 0.10),
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
            text: '${_currentQuestion.question}',
            color: widget.themeColor,
            size: isCompact ? 38 : 42,
          ),
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
                    color: widget.themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: isCompact ? 14 : 18,
                  ),
                ),
                // Difficulty indicator
                Consumer<AdaptiveDifficultyService>(
                  builder: (context, difficultySvc, _) {
                    final difficulty = widget.questions.isNotEmpty
                        ? difficultySvc.getDifficultyForSkill('science')
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
                Text(
                  'Pilot: $playerName',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: isCompact ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              color: (isCorrect ? Colors.green : Colors.red)
                  .withValues(alpha: 0.4),
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
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect
                        ? (_gameController.streak > 2
                            ? 'Streak x${_gameController.streak}!!'
                            : 'Correct!')
                        : 'Nice try!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

  Widget _buildScienceSystemsPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.themeColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Discovery Meter',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const Spacer(),
              TextButton.icon(
                onPressed: (!_answered &&
                        !_hintUsedThisQuestion &&
                        _hintsRemaining > 0)
                    ? _useHint
                    : null,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.lightbulb_outline, size: 16),
                label: Text(
                  'Hint $_hintsRemaining',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              if (_streakShieldAvailable)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🛡️ Shield Ready',
                      style:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: _discoveryMeter / 100,
              backgroundColor: Colors.blueGrey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                _discoveryMeter >= 70 ? Colors.orange : widget.themeColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _coachMessage,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScienceChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _ScienceChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
