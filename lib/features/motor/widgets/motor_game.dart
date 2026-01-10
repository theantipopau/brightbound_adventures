import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:brightbound_adventures/core/services/audio_manager.dart';
import '../models/motor_game.dart';

/// Interactive motor skills game with tap/drag gameplay
class MotorGame extends StatefulWidget {
  final MotorGameConfig config;
  final Function(MotorGameResult) onGameComplete;

  const MotorGame({
    super.key,
    required this.config,
    required this.onGameComplete,
  });

  @override
  State<MotorGame> createState() => _MotorGameState();
}

class _MotorGameState extends State<MotorGame> with TickerProviderStateMixin {
  List<MotorTarget> _targets = [];
  int _score = 0;
  int _targetsHit = 0;
  int _targetsMissed = 0;
  int _currentRound = 1;
  bool _isPlaying = false;
  bool _showCountdown = true;
  int _countdown = 3;
  Duration _timeRemaining = Duration.zero;
  Timer? _gameTimer;
  Timer? _targetSpawnTimer;
  Timer? _movementTimer;
  final AudioManager _audioManager = AudioManager();

  final List<Duration> _reactionTimes = [];
  DateTime? _targetSpawnTime;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // For tap feedback
  final List<_TapFeedback> _tapFeedbacks = [];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timeRemaining = widget.config.roundDuration;
    _startCountdown();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _targetSpawnTimer?.cancel();
    _movementTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          timer.cancel();
          _showCountdown = false;
          _startGame();
        }
      });
    });
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _timeRemaining = widget.config.roundDuration;
    });

    // Start game timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _timeRemaining = _timeRemaining - const Duration(seconds: 1);
        if (_timeRemaining.inSeconds <= 0) {
          timer.cancel();
          _endRound();
        }
      });
    });

    // Spawn initial targets
    _spawnTarget();

    // Schedule target spawning
    _targetSpawnTimer =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted || !_isPlaying) {
        timer.cancel();
        return;
      }
      if (_targets.length < widget.config.targetCount ~/ 2) {
        _spawnTarget();
      }
    });

    // Update moving targets
    _movementTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted || !_isPlaying) {
        timer.cancel();
        return;
      }
      _updateMovingTargets();
    });
  }

  void _spawnTarget() {
    if (!_isPlaying || !mounted) return;

    final screenSize = MediaQuery.of(context).size;
    final types = widget.config.targetTypes;
    final type = types[math.Random().nextInt(types.length)];

    final target = TargetGenerator.generateTarget(
      screenSize: screenSize,
      type: type,
      difficultyMultiplier: widget.config.difficultyMultiplier,
    );

    setState(() {
      _targets.add(target);
      _targetSpawnTime = DateTime.now();
    });

    // Auto-remove tap targets after a delay
    if (type == TargetType.tap || type == TargetType.moving) {
      Future.delayed(
          Duration(
              milliseconds:
                  (3000 / widget.config.difficultyMultiplier).round()), () {
        if (mounted && _targets.any((t) => t.id == target.id)) {
          setState(() {
            _targets.removeWhere((t) => t.id == target.id);
            _targetsMissed++;
          });
        }
      });
    }
  }

  void _updateMovingTargets() {
    if (!mounted) return;

    final screenSize = MediaQuery.of(context).size;
    const dt = 0.016; // ~60fps

    setState(() {
      _targets = _targets.map((target) {
        if (target.type != TargetType.moving ||
            target.direction == null ||
            target.speed == null) {
          return target;
        }

        var newX =
            target.position.dx + target.direction!.dx * target.speed! * dt;
        var newY =
            target.position.dy + target.direction!.dy * target.speed! * dt;
        var newDirection = target.direction!;

        // Bounce off walls
        if (newX < 20 || newX > screenSize.width - 20 - target.size) {
          newDirection = Offset(-newDirection.dx, newDirection.dy);
          newX = newX.clamp(20, screenSize.width - 20 - target.size);
        }
        if (newY < 120 || newY > screenSize.height - 120 - target.size) {
          newDirection = Offset(newDirection.dx, -newDirection.dy);
          newY = newY.clamp(120, screenSize.height - 120 - target.size);
        }

        return target.copyWith(
          position: Offset(newX, newY),
          direction: newDirection,
        );
      }).toList();
    });
  }

  void _onTargetHit(MotorTarget target) {
    if (!_isPlaying) return;

    // Record reaction time
    if (_targetSpawnTime != null) {
      _reactionTimes.add(DateTime.now().difference(_targetSpawnTime!));
    }

    // Play correct answer sound
    _audioManager.playCorrectAnswer();

    // Add tap feedback
    setState(() {
      _targets.removeWhere((t) => t.id == target.id);
      _score += target.points;
      _targetsHit++;

      _tapFeedbacks.add(_TapFeedback(
        position: target.position + Offset(target.size / 2, target.size / 2),
        points: target.points,
        createdAt: DateTime.now(),
      ));
    });

    // Clean up old tap feedbacks
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _tapFeedbacks.removeWhere((f) =>
              DateTime.now().difference(f.createdAt).inMilliseconds > 500);
        });
      }
    });

    // Spawn new target
    if (_targets.length < 3) {
      _spawnTarget();
    }
  }

  void _endRound() {
    setState(() {
      _isPlaying = false;
      _targets.clear();
    });

    _gameTimer?.cancel();
    _targetSpawnTimer?.cancel();
    _movementTimer?.cancel();

    if (_currentRound < widget.config.rounds) {
      // Next round
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _currentRound++;
            _countdown = 3;
            _showCountdown = true;
          });
          _startCountdown();
        }
      });
    } else {
      // Game complete
      _completeGame();
    }
  }

  void _completeGame() {
    final totalTargets = _targetsHit + _targetsMissed;
    final avgReaction = _reactionTimes.isNotEmpty
        ? Duration(
            milliseconds: _reactionTimes
                    .map((d) => d.inMilliseconds)
                    .reduce((a, b) => a + b) ~/
                _reactionTimes.length)
        : Duration.zero;

    widget.onGameComplete(MotorGameResult(
      targetsHit: _targetsHit,
      totalTargets: totalTargets,
      score: _score,
      averageReactionTime: avgReaction,
      accuracy: totalTargets > 0 ? _targetsHit / totalTargets : 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade900,
              Colors.deepOrange.shade800,
              Colors.red.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background pattern
              _buildBackgroundPattern(),

              // Game header
              _buildHeader(),

              // Targets
              ..._targets.map((target) => _buildTarget(target)),

              // Tap feedbacks
              ..._tapFeedbacks.map((feedback) => _buildTapFeedback(feedback)),

              // Countdown overlay
              if (_showCountdown) _buildCountdownOverlay(),

              // Round end overlay
              if (!_isPlaying &&
                  !_showCountdown &&
                  _currentRound <= widget.config.rounds)
                _buildRoundEndOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _ArenaPainter(),
    );
  }

  Widget _buildHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.5),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),

            // Round info
            Column(
              children: [
                Text(
                  widget.config.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Round $_currentRound of ${widget.config.rounds}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),

            // Score and timer
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$_score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '⏱️ ${_timeRemaining.inSeconds}s',
                  style: TextStyle(
                    color: _timeRemaining.inSeconds <= 5
                        ? Colors.red
                        : Colors.white70,
                    fontSize: 14,
                    fontWeight: _timeRemaining.inSeconds <= 5
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTarget(MotorTarget target) {
    return Positioned(
      left: target.position.dx,
      top: target.position.dy,
      child: GestureDetector(
        onTap: () => _onTargetHit(target),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final scale =
                target.type == TargetType.moving ? _pulseAnimation.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: Container(
            width: target.size,
            height: target.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  target.color.withValues(alpha: 0.9),
                  target.color,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: target.color.withValues(alpha: 0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 3,
              ),
            ),
            child: Center(
              child: Icon(
                target.type == TargetType.moving ? Icons.star : Icons.touch_app,
                color: Colors.white,
                size: target.size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTapFeedback(_TapFeedback feedback) {
    final age = DateTime.now().difference(feedback.createdAt).inMilliseconds;
    final progress = (age / 500).clamp(0.0, 1.0);

    return Positioned(
      left: feedback.position.dx - 20,
      top: feedback.position.dy - 40 - (progress * 30),
      child: Opacity(
        opacity: 1.0 - progress,
        child: Text(
          '+${feedback.points}',
          style: const TextStyle(
            color: Colors.amber,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Get Ready!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange.withValues(alpha: 0.3),
                border: Border.all(color: Colors.orange, width: 4),
              ),
              child: Center(
                child: Text(
                  '$_countdown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.config.description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundEndOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Round $_currentRound Complete!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '🎯 Targets Hit: $_targetsHit',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 20,
              ),
            ),
            Text(
              '⭐ Score: $_score',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 24),
            if (_currentRound < widget.config.rounds)
              const Text(
                'Next round starting...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TapFeedback {
  final Offset position;
  final int points;
  final DateTime createdAt;

  _TapFeedback({
    required this.position,
    required this.points,
    required this.createdAt,
  });
}

class _ArenaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw arena circles
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, size.width * 0.15 * i, paint);
    }

    // Draw crosshairs
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
