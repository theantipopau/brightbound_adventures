import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/animated_character.dart';

class AvatarCreatorScreen extends StatefulWidget {
  const AvatarCreatorScreen({super.key});

  @override
  State<AvatarCreatorScreen> createState() => _AvatarCreatorScreenState();
}

class _AvatarCreatorScreenState extends State<AvatarCreatorScreen>
    with TickerProviderStateMixin {
  late TextEditingController _nameController;
  late PageController _pageController;
  late AnimationController _backgroundController;
  late AnimationController _sparkleController;
  late AnimationController _characterShowcaseController;

  String _selectedCharacter = 'bear';
  String _selectedColor = '#E8C4A0';
  int _currentStep = 0;
  CharacterAnimation _previewAnimation = CharacterAnimation.idle;

  final List<Map<String, dynamic>> _characters = [
    {
      'id': 'bear',
      'emoji': '🐻',
      'name': 'Benny Bear',
      'trait': 'Brave & Strong',
      'description': 'A friendly bear who loves to explore and help others!',
      'color': const Color(0xFF8B4513),
    },
    {
      'id': 'fox',
      'emoji': '🦊',
      'name': 'Fiona Fox',
      'trait': 'Clever & Quick',
      'description': 'A smart fox who solves puzzles with ease!',
      'color': const Color(0xFFFF6B35),
    },
    {
      'id': 'rabbit',
      'emoji': '🐰',
      'name': 'Ruby Rabbit',
      'trait': 'Kind & Fast',
      'description': 'A gentle rabbit who makes friends everywhere!',
      'color': const Color(0xFFE8B4D4),
    },
    {
      'id': 'deer',
      'emoji': '🦌',
      'name': 'Danny Deer',
      'trait': 'Wise & Gentle',
      'description': 'A thoughtful deer who loves learning new things!',
      'color': const Color(0xFFD2691E),
    },
    {
      'id': 'cat',
      'emoji': '🐱',
      'name': 'Cleo Cat',
      'trait': 'Curious & Agile',
      'description': 'A playful cat who loves mysteries and adventures!',
      'color': const Color(0xFFFF8C94),
    },
    {
      'id': 'penguin',
      'emoji': '🐧',
      'name': 'Pip Penguin',
      'trait': 'Friendly & Cool',
      'description': 'A cheerful penguin who makes everyone smile!',
      'color': const Color(0xFF4A90E2),
    },
    {
      'id': 'koala',
      'emoji': '🐨',
      'name': 'Kenny Koala',
      'trait': 'Calm & Smart',
      'description': 'A relaxed koala who thinks before acting!',
      'color': const Color(0xFF9E9E9E),
    },
    {
      'id': 'panda',
      'emoji': '🐼',
      'name': 'Penny Panda',
      'trait': 'Fun & Caring',
      'description': 'A sweet panda who loves helping friends!',
      'color': const Color(0xFF000000),
    },
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _pageController = PageController();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _sparkleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _characterShowcaseController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _selectedColor =
        CosmeticsLibrary.getSkinColorsForCharacter(_selectedCharacter)[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    _backgroundController.dispose();
    _sparkleController.dispose();
    _characterShowcaseController.dispose();
    super.dispose();
  }

  Future<void> _createAvatar() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Please enter your name!'),
            ],
          ),
          backgroundColor: AppColors.tertiary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      await context.read<AvatarProvider>().createAvatar(
            name: _nameController.text,
            baseCharacter: _selectedCharacter,
            skinColor: _selectedColor,
          );

      if (mounted) {
        await _showCelebration();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showCelebration() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CelebrationDialog(
        character: _selectedCharacter,
        skinColor: _selectedColor,
        name: _nameController.text,
        onComplete: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/world-entry');
        },
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0 && _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name first! ✏️'),
          backgroundColor: AppColors.tertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStepColor(_currentStep).withValues(alpha: 0.3),
                      _getStepColor(_currentStep).withValues(alpha: 0.1),
                      Colors.white,
                    ],
                    transform: GradientRotation(
                        _backgroundController.value * 2 * math.pi),
                  ),
                ),
              );
            },
          ),

          // Floating particles
          AnimatedBuilder(
            animation: _sparkleController,
            builder: (context, child) {
              return CustomPaint(
                painter: _FloatingParticlesPainter(
                  _sparkleController.value,
                  _getStepColor(_currentStep),
                ),
                size: Size.infinite,
              );
            },
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildProgressBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildWelcomeStep(),
                      _buildCharacterStep(),
                      _buildColorStep(),
                      _buildReviewStep(),
                    ],
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStepColor(int step) {
    switch (step) {
      case 0:
        return AppColors.primary;
      case 1:
        return AppColors.secondary;
      case 2:
        return AppColors.tertiary;
      case 3:
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildAppBar() {
    final titles = [
      '👋 Welcome!',
      '🎭 Choose Your Hero',
      '🎨 Pick Your Style',
      '🚀 Ready to Learn!'
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStepColor(_currentStep).withValues(alpha: 0.1),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStepColor(_currentStep).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              titles[_currentStep].split(' ')[0],
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Step ${_currentStep + 1} of 4',
                  style: TextStyle(
                    color: _getStepColor(_currentStep),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  titles[_currentStep].split(' ').skip(1).join(' '),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isActive ? _getStepColor(index) : Colors.grey.shade300,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color:
                                  _getStepColor(index).withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: index < _currentStep
                            ? _getStepColor(index)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 600;
        final isTinyScreen = constraints.maxHeight < 500; // Very small phones

        return SingleChildScrollView(
          padding: EdgeInsets.all(isTinyScreen ? 12 : (isCompact ? 16 : 24)),
          child: Column(
            children: [
              SizedBox(height: isTinyScreen ? 4 : (isCompact ? 10 : 20)),
              // Animated character showcase - reduced size for tiny screens
              SizedBox(
                height: isTinyScreen ? 100 : (isCompact ? 120 : 180),
                child: AnimatedBuilder(
                  animation: _characterShowcaseController,
                  builder: (context, child) {
                    final index =
                        (_characterShowcaseController.value * 4).floor() % 4;
                    final char = _characters[index];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: AnimatedCharacter(
                        key: ValueKey(char['id']),
                        character: char['id'],
                        size: isTinyScreen ? 60 : (isCompact ? 80 : 100),
                        animation: CharacterAnimation.celebrating,
                        showParticles: true,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: isTinyScreen ? 8 : (isCompact ? 12 : 24)),

              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ).createShader(bounds),
                child: Text(
                  'Welcome, Adventurer!',
                  style: TextStyle(
                    fontSize: isTinyScreen ? 20 : (isCompact ? 24 : 32),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isTinyScreen ? 4 : (isCompact ? 8 : 12)),
              Text(
                'Your learning journey begins here.\nFirst, tell us your name!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                      fontSize: isTinyScreen ? 12 : (isCompact ? 14 : 16),
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTinyScreen ? 12 : (isCompact ? 20 : 40)),

              // Name input
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTinyScreen ? 18 : (isCompact ? 20 : 24),
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your name...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.normal,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text('✨',
                          style: TextStyle(
                              fontSize:
                                  isTinyScreen ? 18 : (isCompact ? 20 : 24))),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text('✨',
                          style: TextStyle(
                              fontSize:
                                  isTinyScreen ? 18 : (isCompact ? 20 : 24))),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 3),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: isCompact ? 16 : 20, horizontal: 24),
                  ),
                  onSubmitted: (_) => _nextStep(),
                ),
              ),
              SizedBox(height: isCompact ? 16 : 24),

              // Fun tip
              Container(
                padding: EdgeInsets.all(isCompact ? 12 : 16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: isCompact ? 24 : 28)),
                    SizedBox(width: isCompact ? 8 : 12),
                    Expanded(
                      child: Text(
                        'Your character will walk around the world map!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.secondary,
                              fontSize: isCompact ? 13 : 14,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCharacterStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 600;
        final isTiny = constraints.maxHeight < 500;
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

        return Column(
          children: [
            // Header section
            Padding(
              padding: EdgeInsets.all(isCompact ? 12 : 24),
              child: Column(
                children: [
                  Text(
                    'Choose Your Companion! 🎭',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isTiny ? 18 : (isCompact ? 20 : 24),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTiny ? 2 : (isCompact ? 4 : 8)),
                  Text(
                    'Tap a character to see them in action!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: isTiny ? 12 : (isCompact ? 13 : 14),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTiny ? 8 : (isCompact ? 12 : 16)),

                  // Animation control buttons
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimationButton(
                            'Idle', CharacterAnimation.idle, '😊', isCompact),
                        _buildAnimationButton('Walk',
                            CharacterAnimation.walking, '🚶', isCompact),
                        _buildAnimationButton('Jump',
                            CharacterAnimation.jumping, '🦘', isCompact),
                        _buildAnimationButton('Celebrate',
                            CharacterAnimation.celebrating, '🎉', isCompact),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Character grid - fits available space
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: isCompact ? 12 : 16,
                  mainAxisSpacing: isCompact ? 12 : 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: _characters.length,
                itemBuilder: (context, index) {
                  final character = _characters[index];
                  final isSelected = _selectedCharacter == character['id'];

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 300 + (index * 50)),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCharacter = character['id'];
                          _selectedColor =
                              CosmeticsLibrary.getSkinColorsForCharacter(
                                  character['id'])[0];
                        });
                        HapticFeedback.mediumImpact();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    (character['color'] as Color)
                                        .withValues(alpha: 0.1),
                                    Colors.white,
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? character['color']
                                : Colors.grey.shade200,
                            width: isSelected ? 4 : 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: (character['color'] as Color)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: LayoutBuilder(
                          builder: (context, cardConstraints) {
                            final isNarrow = cardConstraints.maxWidth < 150;

                            return Stack(
                              children: [
                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: character['color'],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check,
                                          color: Colors.white, size: 18),
                                    ),
                                  ),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Animated character preview
                                      AnimatedCharacter(
                                        character: character['id'],
                                        size: isNarrow
                                            ? 50
                                            : (isSelected ? 70 : 60),
                                        animation: isSelected
                                            ? _previewAnimation
                                            : CharacterAnimation.idle,
                                        showParticles: isSelected &&
                                            _previewAnimation ==
                                                CharacterAnimation.celebrating,
                                      ),
                                      SizedBox(height: isNarrow ? 4 : 8),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Text(
                                          character['name'],
                                          style: TextStyle(
                                            fontSize: isNarrow ? 12 : 14,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? character['color']
                                                : AppColors.textPrimary,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Text(
                                          character['trait'],
                                          style: TextStyle(
                                            fontSize: isNarrow ? 10 : 11,
                                            color: AppColors.textSecondary,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Selected character description
            Padding(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 12 : 24,
                isTiny ? 4 : (isCompact ? 8 : 16),
                isCompact ? 12 : 24,
                isCompact ? 12 : 24,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_selectedCharacter),
                  padding: EdgeInsets.all(isCompact ? 12 : 16),
                  decoration: BoxDecoration(
                    color: _characters
                        .firstWhere(
                            (c) => c['id'] == _selectedCharacter)['color']
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _characters.firstWhere(
                        (c) => c['id'] == _selectedCharacter)['description'],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: isTiny ? 12 : (isCompact ? 13 : 14),
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimationButton(String label, CharacterAnimation animation,
      String emoji, bool isCompact) {
    final isSelected = _previewAnimation == animation;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 2 : 4),
      child: GestureDetector(
        onTap: () {
          setState(() => _previewAnimation = animation);
          HapticFeedback.lightImpact();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 12,
            vertical: isCompact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.secondary : Colors.grey.shade300,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: isCompact ? 16 : 18)),
              SizedBox(width: isCompact ? 4 : 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: isCompact ? 12 : 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorStep() {
    final colors =
        CosmeticsLibrary.getSkinColorsForCharacter(_selectedCharacter);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 600;
        final isTiny = constraints.maxHeight < 500;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 1),

            // Large animated preview
            AnimatedCharacter(
              character: _selectedCharacter,
              skinColor: _selectedColor,
              size: isTiny ? 100 : (isCompact ? 120 : 140),
              animation: CharacterAnimation.celebrating,
              showParticles: true,
            ),
            SizedBox(height: isTiny ? 12 : (isCompact ? 16 : 24)),

            Text(
              'Pick Your Style! 🎨',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTiny ? 18 : (isCompact ? 20 : 24),
                  ),
            ),
            SizedBox(height: isTiny ? 4 : 8),
            Text(
              'Choose a color for your $_selectedCharacter',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: isTiny ? 12 : (isCompact ? 13 : 14),
                  ),
            ),
            SizedBox(height: isTiny ? 16 : (isCompact ? 20 : 32)),

            // Color options
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: isCompact ? 12 : 16,
                  runSpacing: isCompact ? 12 : 16,
                  alignment: WrapAlignment.center,
                  children: colors.map((color) {
                    final isSelected = _selectedColor == color;
                    final colorValue =
                        Color(int.parse('0xFF${color.replaceFirst('#', '')}'));

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedColor = color);
                        HapticFeedback.selectionClick();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isCompact ? 50 : 70,
                        height: isCompact ? 50 : 70,
                        decoration: BoxDecoration(
                          color: colorValue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? AppColors.tertiary : Colors.white,
                            width: isSelected ? 4 : 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorValue.withValues(
                                  alpha: isSelected ? 0.5 : 0.3),
                              blurRadius: isSelected ? 12 : 8,
                              spreadRadius: isSelected ? 3 : 0,
                            ),
                          ],
                        ),
                        child: isSelected
                            ? Icon(Icons.check,
                                color: Colors.white, size: isCompact ? 24 : 32)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const Spacer(flex: 1),
          ],
        );
      },
    );
  }

  Widget _buildReviewStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 600;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isCompact ? 12 : 24),
          child: Column(
            children: [
              // Large animated preview with enhanced visuals
              Container(
                padding: EdgeInsets.all(isCompact ? 16 : 24),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _getStepColor(_currentStep).withValues(alpha: 0.2),
                      _getStepColor(_currentStep).withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: AnimatedCharacter(
                  character: _selectedCharacter,
                  skinColor: _selectedColor,
                  size: isCompact ? 100 : 140, // Reduced from 120:180
                  animation: CharacterAnimation.celebrating,
                  showParticles: true,
                ),
              ),
              SizedBox(height: isCompact ? 8 : 12), // Reduced spacing

              // Name badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 16 : 24,
                  vertical: isCompact ? 6 : 10, // Reduced vertical padding
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _nameController.text,
                  style: TextStyle(
                    fontSize: isCompact ? 20 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: isCompact ? 12 : 24),

              // Summary card
              Container(
                padding:
                    EdgeInsets.all(isCompact ? 12 : 16), // Reduced from 16:20
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                        '🏷️', 'Name', _nameController.text, isCompact),
                    Divider(height: isCompact ? 12 : 16), // Reduced height
                    _buildSummaryRow(
                        '🎭',
                        'Character',
                        _characters.firstWhere(
                            (c) => c['id'] == _selectedCharacter)['name'],
                        isCompact),
                    Divider(height: isCompact ? 12 : 16), // Reduced height
                    _buildSummaryRow(
                        '✨',
                        'Trait',
                        _characters.firstWhere(
                            (c) => c['id'] == _selectedCharacter)['trait'],
                        isCompact),
                  ],
                ),
              ),
              SizedBox(height: isCompact ? 8 : 16), // Reduced from 12:24

              // Ready message
              Container(
                padding:
                    EdgeInsets.all(isCompact ? 10 : 16), // Reduced from 12:20
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text('🎉', style: TextStyle(fontSize: isCompact ? 32 : 40)),
                    SizedBox(height: isCompact ? 8 : 12),
                    Text(
                      'Your adventure awaits!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                            fontSize: isCompact ? 18 : 22,
                          ),
                    ),
                    SizedBox(height: isCompact ? 4 : 8),
                    Text(
                      'Your character will explore the world map\nand learn amazing things!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: isCompact ? 13 : 14,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
      String emoji, String label, String value, bool isCompact) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: isCompact ? 20 : 24)),
        SizedBox(width: isCompact ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isCompact ? 11 : 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: isCompact ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 400;

          return Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _previousStep();
                      HapticFeedback.lightImpact();
                    },
                    style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: isCompact ? 12 : 16),
                      side: BorderSide(
                          color: _getStepColor(_currentStep), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back,
                            color: _getStepColor(_currentStep),
                            size: isCompact ? 20 : 24),
                        SizedBox(width: isCompact ? 4 : 8),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: isCompact ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: _getStepColor(_currentStep),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_currentStep > 0) SizedBox(width: isCompact ? 8 : 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep < 3) {
                      _nextStep();
                    } else {
                      _createAvatar();
                    }
                    HapticFeedback.mediumImpact();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getStepColor(_currentStep),
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: isCompact ? 12 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor:
                        _getStepColor(_currentStep).withValues(alpha: 0.4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentStep < 3 ? 'Continue' : '🚀 Start Adventure!',
                        style: TextStyle(
                          fontSize: isCompact ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_currentStep < 3) ...[
                        SizedBox(width: isCompact ? 4 : 8),
                        Icon(Icons.arrow_forward, size: isCompact ? 20 : 24),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Celebration dialog with animated character
class _CelebrationDialog extends StatefulWidget {
  final String character;
  final String skinColor;
  final String name;
  final VoidCallback onComplete;

  const _CelebrationDialog({
    required this.character,
    required this.skinColor,
    required this.name,
    required this.onComplete,
  });

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scale =
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleController.forward();
    _confettiController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(_confettiController.value),
                size: const Size(300, 400),
              );
            },
          ),
          ScaleTransition(
            scale: _scale,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 50)),
                  const SizedBox(height: 16),
                  AnimatedCharacter(
                    character: widget.character,
                    skinColor: widget.skinColor,
                    size: 80,
                    animation: CharacterAnimation.celebrating,
                    showParticles: true,
                  ),
                  const SizedBox(height: 16),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ).createShader(bounds),
                    child: const Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your adventure begins now!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Floating particles painter
class _FloatingParticlesPainter extends CustomPainter {
  final double animation;
  final Color color;

  _FloatingParticlesPainter(this.animation, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = (i * 73 + animation * 50) % size.width;
      final y = size.height * (0.2 + 0.6 * math.sin(i * 0.5 + animation * 2));
      final opacity =
          (0.2 + 0.3 * math.sin(animation * math.pi * 2 + i)).clamp(0.0, 1.0);
      final particleSize = 4.0 + (i % 4) * 2;

      paint.color = color.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

// Confetti painter
class _ConfettiPainter extends CustomPainter {
  final double animation;

  _ConfettiPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.success,
      Colors.purple,
      Colors.orange,
    ];

    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);

    for (int i = 0; i < 40; i++) {
      final startX = random.nextDouble() * size.width;
      const startY = -50.0;
      final endX = startX + (random.nextDouble() - 0.5) * 100;
      final endY = size.height + 50;

      final x = startX + (endX - startX) * animation;
      final y = startY + (endY - startY) * animation;
      final rotation = animation * math.pi * 4 + i;
      final opacity = (1.0 - animation * 0.5).clamp(0.0, 1.0);

      paint.color = colors[i % colors.length].withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      if (i % 3 == 0) {
        canvas.drawRect(const Rect.fromLTWH(-4, -8, 8, 16), paint);
      } else if (i % 3 == 1) {
        canvas.drawCircle(Offset.zero, 5, paint);
      } else {
        final path = Path()
          ..moveTo(0, -6)
          ..lineTo(6, 6)
          ..lineTo(-6, 6)
          ..close();
        canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
