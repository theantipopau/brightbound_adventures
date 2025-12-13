import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

/// Results screen shown after completing a quiz
class QuizResultsScreen extends StatefulWidget {
  final String skillName;
  final String skillId;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final int hintsUsed;
  final Color themeColor;
  final VoidCallback? onPlayAgain;
  final VoidCallback? onExit;

  const QuizResultsScreen({
    super.key,
    required this.skillName,
    required this.skillId,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    this.hintsUsed = 0,
    this.themeColor = AppColors.wordWoodsColor,
    this.onPlayAgain,
    this.onExit,
  });

  @override
  State<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends State<QuizResultsScreen>
    with TickerProviderStateMixin {
  late AnimationController _celebrationController;
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;
  
  int _xpAwarded = 0;
  bool _leveledUp = false;
  int? _previousLevel;

  @override
  void initState() {
    super.initState();
    
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
    
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scoreAnimation = CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutBack,
    );
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreController.forward();
    });
    
    _processResults();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  void _processResults() {
    // Calculate XP based on performance
    _xpAwarded = (widget.accuracy * 100).round();
    if (widget.accuracy >= 0.85) {
      _xpAwarded += 25; // Bonus for mastery-level performance
    }
    if (widget.hintsUsed == 0 && widget.accuracy >= 0.7) {
      _xpAwarded += 10; // Bonus for no hints
    }
    
    // Update skill progress
    final skillProvider = context.read<SkillProvider>();
    skillProvider.updateSkillProgress(
      skillId: widget.skillId,
      sessionAccuracy: widget.accuracy,
      sessionHints: widget.hintsUsed,
    );
    
    // Award XP
    final avatarProvider = context.read<AvatarProvider>();
    if (avatarProvider.hasAvatar) {
      _previousLevel = avatarProvider.avatar!.level;
      avatarProvider.addExperience(_xpAwarded);
      _leveledUp = avatarProvider.avatar!.level > _previousLevel!;
    }
  }

  String get _performanceMessage {
    if (widget.accuracy >= 0.95) return 'Perfect! You\'re a star! ⭐';
    if (widget.accuracy >= 0.85) return 'Excellent work! 🎉';
    if (widget.accuracy >= 0.70) return 'Good job! Keep practicing! 💪';
    if (widget.accuracy >= 0.50) return 'Nice try! You\'re improving! 📈';
    return 'Keep learning! You\'ll get there! 🌱';
  }

  String get _performanceEmoji {
    if (widget.accuracy >= 0.95) return '🏆';
    if (widget.accuracy >= 0.85) return '🌟';
    if (widget.accuracy >= 0.70) return '👍';
    if (widget.accuracy >= 0.50) return '💡';
    return '📚';
  }

  int get _starCount {
    if (widget.accuracy >= 0.95) return 3;
    if (widget.accuracy >= 0.70) return 2;
    if (widget.accuracy >= 0.40) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.themeColor.withOpacity(0.05),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Performance emoji
              ScaleTransition(
                scale: _scoreAnimation,
                child: Text(
                  _performanceEmoji,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                'Quiz Complete!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.skillName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),
              
              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: AnimatedBuilder(
                      animation: _celebrationController,
                      builder: (context, child) {
                        final delay = index * 0.2;
                        final progress = ((_celebrationController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
                        return Transform.scale(
                          scale: index < _starCount ? (0.5 + 0.5 * progress) : 0.8,
                          child: Icon(
                            index < _starCount ? Icons.star : Icons.star_border,
                            size: 48,
                            color: index < _starCount 
                                ? Colors.amber 
                                : Colors.grey.shade300,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              
              // Score card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: widget.themeColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Accuracy
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _scoreAnimation,
                          child: Text(
                            '${(widget.accuracy * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              color: widget.themeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _performanceMessage,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          icon: Icons.check_circle,
                          color: AppColors.success,
                          value: '${widget.correctAnswers}/${widget.totalQuestions}',
                          label: 'Correct',
                        ),
                        _buildStatItem(
                          icon: Icons.lightbulb,
                          color: Colors.amber,
                          value: '${widget.hintsUsed}',
                          label: 'Hints Used',
                        ),
                        _buildStatItem(
                          icon: Icons.stars,
                          color: widget.themeColor,
                          value: '+$_xpAwarded',
                          label: 'XP Earned',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Level up notification
              if (_leveledUp) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade300,
                        Colors.orange.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Text('🎊', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LEVEL UP!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Consumer<AvatarProvider>(
                              builder: (context, provider, _) {
                                return Text(
                                  'You reached Level ${provider.avatar?.level ?? 0}!',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const Text('🎊', style: TextStyle(fontSize: 36)),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onExit,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: widget.themeColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Back to Zone',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.themeColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onPlayAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.replay),
                          SizedBox(width: 8),
                          Text(
                            'Play Again',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
