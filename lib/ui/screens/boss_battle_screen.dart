import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/index.dart';

// ────────────────────────────────────────────────────────────────────────────
// Data model
// ────────────────────────────────────────────────────────────────────────────
class _BossQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String zone;

  const _BossQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.zone,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Question bank — 2 questions per zone, difficulty ~3/5
// ────────────────────────────────────────────────────────────────────────────
const _allQuestions = <_BossQuestion>[
  // Word Woods
  _BossQuestion(
    question: 'Which sentence is written correctly?',
    options: [
      "The dog ran quickly through it's yard.",
      "The dog ran quickly through its yard.",
      "The dog ran quickly through there yard.",
    ],
    correctIndex: 1,
    zone: '🌲 Word Woods',
  ),
  _BossQuestion(
    question: 'Which word is a homophone for "here"?',
    options: ['hear', 'hair', 'hare'],
    correctIndex: 0,
    zone: '🌲 Word Woods',
  ),
  // Number Nebula
  _BossQuestion(
    question: 'What is 7 × 8?',
    options: ['54', '56', '63'],
    correctIndex: 1,
    zone: '🌌 Number Nebula',
  ),
  _BossQuestion(
    question: 'What is the place value of 6 in 3,642?',
    options: ['Hundreds', 'Tens', 'Ones'],
    correctIndex: 0,
    zone: '🌌 Number Nebula',
  ),
  // Puzzle Peaks
  _BossQuestion(
    question: 'What comes next in the pattern: 3, 6, 12, 24, _?',
    options: ['36', '48', '40'],
    correctIndex: 1,
    zone: '🧠 Puzzle Peaks',
  ),
  _BossQuestion(
    question: 'If all cats are animals, and Mittens is a cat, what is Mittens?',
    options: ['A plant', 'An animal', 'We cannot tell'],
    correctIndex: 1,
    zone: '🧠 Puzzle Peaks',
  ),
  // Story Springs
  _BossQuestion(
    question: 'In a story, the "climax" is:',
    options: [
      'The beginning where characters are introduced',
      'The turning point of highest tension',
      'The resolution at the very end',
    ],
    correctIndex: 1,
    zone: '📖 Story Springs',
  ),
  _BossQuestion(
    question: 'Which of these best describes the "setting" of a story?',
    options: [
      'The main character\'s name',
      'The lesson the story teaches',
      'The time and place where the story happens',
    ],
    correctIndex: 2,
    zone: '📖 Story Springs',
  ),
  // Science Explorers
  _BossQuestion(
    question: 'What do plants need to make food through photosynthesis?',
    options: [
      'Soil and rain only',
      'Sunlight, water, and carbon dioxide',
      'Sunlight, oxygen, and sugar',
    ],
    correctIndex: 1,
    zone: '🔬 Science Explorers',
  ),
  _BossQuestion(
    question: 'Which force pulls objects towards the Earth?',
    options: ['Magnetism', 'Friction', 'Gravity'],
    correctIndex: 2,
    zone: '🔬 Science Explorers',
  ),
];

// ────────────────────────────────────────────────────────────────────────────
// Screen widget
// ────────────────────────────────────────────────────────────────────────────
class BossBattleScreen extends StatefulWidget {
  const BossBattleScreen({super.key});

  @override
  State<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends State<BossBattleScreen>
    with TickerProviderStateMixin {
  late List<_BossQuestion> _questions;
  int _index = 0;
  int _playerLives = 3;
  int _bossHpRemaining = 10;
  int? _selectedIndex;
  bool _answered = false;
  bool _showIntro = true;
  bool _won = false;
  bool _lost = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _hitController;

  final AudioManager _audio = AudioManager();

  @override
  void initState() {
    super.initState();
    _questions = List.of(_allQuestions)..shuffle(Random());
    _questions = _questions.take(10).toList();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _hitController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _hitController.dispose();
    super.dispose();
  }

  void _selectAnswer(int idx) {
    if (_answered) return;
    setState(() {
      _selectedIndex = idx;
      _answered = true;
    });

    final isCorrect = idx == _questions[_index].correctIndex;

    if (isCorrect) {
      _audio.playCorrectAnswer();
      _hitController.forward(from: 0);
      setState(() => _bossHpRemaining--);
    } else {
      _audio.playIncorrectAnswer();
      _shakeController.forward(from: 0);
      setState(() => _playerLives--);
    }

    Future.delayed(const Duration(milliseconds: 900), _advanceOrEnd);
  }

  void _advanceOrEnd() {
    if (!mounted) return;
    if (_playerLives <= 0) {
      setState(() => _lost = true);
      return;
    }
    if (_bossHpRemaining <= 0) {
      _awardXp();
      setState(() => _won = true);
      return;
    }
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      // Ran out of questions — if boss still alive, player wins on attrition
      _awardXp();
      setState(() => _won = true);
    }
  }

  void _awardXp() {
    final shopService = context.read<ShopService>();
    shopService.addStars(75);
  }

  void _restart() {
    setState(() {
      _questions = List.of(_allQuestions)..shuffle(Random());
      _questions = _questions.take(10).toList();
      _index = 0;
      _playerLives = 3;
      _bossHpRemaining = 10;
      _selectedIndex = null;
      _answered = false;
      _won = false;
      _lost = false;
    });
  }

  // ──────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_showIntro) return _buildIntroScreen();
    if (_won) return _buildVictoryScreen();
    if (_lost) return _buildDefeatScreen();
    return _buildBattleScreen();
  }

  // ── Intro ────────────────────────────────────────
  Widget _buildIntroScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A2340), Color(0xFF3B1F5E), Color(0xFF0D0D2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 72)),
                  const SizedBox(height: 24),
                  const Text(
                    'BOSS BATTLE',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '10 questions across all zones.\n3 lives. No mercy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Defeat the Shadow Champion to win\n75 Bonus XP!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.amber, fontSize: 15),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 18),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => setState(() => _showIntro = false),
                    child: const Text('Begin Challenge'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back',
                        style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Battle ───────────────────────────────────────
  Widget _buildBattleScreen() {
    final question = _questions[_index];
    final progress = (_index + 1) / _questions.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A2340), Color(0xFF0D0D2B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── HUD ──────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Player lives
                    Row(
                      children: List.generate(3, (i) {
                        return Icon(
                          i < _playerLives
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: i < _playerLives
                              ? Colors.redAccent
                              : Colors.white24,
                          size: 26,
                        );
                      }),
                    ),
                    const Spacer(),
                    // Question counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_index + 1} / ${_questions.length}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Boss HP bar ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('👾 Shadow Champion',
                            style: TextStyle(
                                color: Colors.purpleAccent,
                                fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('$_bossHpRemaining / 10',
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    AnimatedBuilder(
                      animation: _hitController,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _bossHpRemaining / 10,
                            minHeight: 14,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation(
                              _bossHpRemaining > 6
                                  ? Colors.purpleAccent
                                  : _bossHpRemaining > 3
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Progress bar (questions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: Colors.white12,
                    valueColor:
                        const AlwaysStoppedAnimation(Colors.amberAccent),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Zone badge ───────────────────────────────────
              Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Text(
                    question.zone,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Question card ──────────────────────────────────
              Expanded(
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    final offset =
                        sin(_shakeAnimation.value * pi * 6) * 12;
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Question text
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 680),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.purpleAccent
                                    .withValues(alpha: 0.3),
                                width: 1.5),
                          ),
                          child: Text(
                            question.question,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Answer options
                        ...List.generate(question.options.length, (i) {
                          Color bgColor = Colors.white10;
                          Color borderColor = Colors.white24;
                          if (_answered) {
                            if (i == question.correctIndex) {
                              bgColor = Colors.green.withValues(alpha: 0.25);
                              borderColor = Colors.green;
                            } else if (i == _selectedIndex &&
                                i != question.correctIndex) {
                              bgColor = Colors.red.withValues(alpha: 0.25);
                              borderColor = Colors.red;
                            }
                          } else if (_selectedIndex == i) {
                            bgColor = Colors.purpleAccent.withValues(alpha: 0.2);
                            borderColor = Colors.purpleAccent;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap:
                                  _answered ? null : () => _selectAnswer(i),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                constraints:
                                    const BoxConstraints(maxWidth: 680),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: borderColor, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: borderColor.withValues(
                                            alpha: 0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        String.fromCharCode(65 + i),
                                        style: TextStyle(
                                          color: borderColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        question.options[i],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    if (_answered &&
                                        i == question.correctIndex)
                                      const Icon(Icons.check_circle,
                                          color: Colors.green, size: 22),
                                    if (_answered &&
                                        i == _selectedIndex &&
                                        i != question.correctIndex)
                                      const Icon(Icons.cancel,
                                          color: Colors.red, size: 22),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Victory ──────────────────────────────────────
  Widget _buildVictoryScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A3A1F), Color(0xFF0D2010)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 24),
                  const Text(
                    'VICTORY!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You defeated the Shadow Champion!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: const Text(
                      '+75 XP Awarded! ⭐',
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                        ),
                        onPressed: _restart,
                        child: const Text('Play Again',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back to Map',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Defeat ───────────────────────────────────────
  Widget _buildDefeatScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3A1A1A), Color(0xFF1A0D0D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💀', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 24),
                  const Text(
                    'DEFEATED',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'The Shadow Champion stands.\nTrain harder and try again!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                        ),
                        onPressed: _restart,
                        child: const Text('Try Again',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child:
                            const Text('Back', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
