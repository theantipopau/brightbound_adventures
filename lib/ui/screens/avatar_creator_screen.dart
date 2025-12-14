import 'dart:math' as math;
import 'package:flutter/material.dart';
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
      'color': Color(0xFF8B4513),
    },
    {
      'id': 'fox',
      'emoji': '🦊',
      'name': 'Fiona Fox',
      'trait': 'Clever & Quick',
      'description': 'A smart fox who solves puzzles with ease!',
      'color': Color(0xFFFF6B35),
    },
    {
      'id': 'rabbit',
      'emoji': '🐰',
      'name': 'Ruby Rabbit',
      'trait': 'Kind & Fast',
      'description': 'A gentle rabbit who makes friends everywhere!',
      'color': Color(0xFFE8B4D4),
    },
    {
      'id': 'deer',
      'emoji': '🦌',
      'name': 'Danny Deer',
      'trait': 'Wise & Gentle',
      'description': 'A thoughtful deer who loves learning new things!',
      'color': Color(0xFFD2691E),
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
        SnackBar(
          content: const Text('Please enter your name first! ✏️'),
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
                      _getStepColor(_currentStep).withOpacity(0.3),
                      _getStepColor(_currentStep).withOpacity(0.1),
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
      'Welcome!',
      'Choose Character',
      'Pick Colors',
      'Ready to Go!'
    ];
    final emojis = ['👋', '🎭', '🎨', '🚀'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(emojis[_currentStep], style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step ${_currentStep + 1} of 4',
                style: TextStyle(
                  color: _getStepColor(_currentStep),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                titles[_currentStep],
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
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
                              color: _getStepColor(index).withOpacity(0.4),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Animated character showcase
          SizedBox(
            height: 180,
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
                    size: 100,
                    animation: CharacterAnimation.celebrating,
                    showParticles: true,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ).createShader(bounds),
            child: const Text(
              'Welcome, Adventurer!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your learning journey begins here.\nFirst, tell us your name!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Name input
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
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
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text('✨', style: TextStyle(fontSize: 24)),
                ),
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Text('✨', style: TextStyle(fontSize: 24)),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                      color: AppColors.primary.withOpacity(0.3), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 3),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              ),
              onSubmitted: (_) => _nextStep(),
            ),
          ),
          const SizedBox(height: 24),

          // Fun tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your character will walk around the world map!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Choose Your Companion! 🎭',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap a character to see them in action!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Animation control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimationButton('Idle', CharacterAnimation.idle, '😊'),
              _buildAnimationButton('Walk', CharacterAnimation.walking, '🚶'),
              _buildAnimationButton('Jump', CharacterAnimation.jumping, '🦘'),
              _buildAnimationButton(
                  'Celebrate', CharacterAnimation.celebrating, '🎉'),
            ],
          ),
          const SizedBox(height: 24),

          // Character grid with animated previews
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: _characters.length,
            itemBuilder: (context, index) {
              final character = _characters[index];
              final isSelected = _selectedCharacter == character['id'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCharacter = character['id'];
                    _selectedColor = CosmeticsLibrary.getSkinColorsForCharacter(
                        character['id'])[0];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                              color:
                                  (character['color'] as Color).withOpacity(0.3),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Stack(
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
                              size: isSelected ? 70 : 60,
                              animation: isSelected
                                  ? _previewAnimation
                                  : CharacterAnimation.idle,
                              showParticles:
                                  isSelected && _previewAnimation == CharacterAnimation.celebrating,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              character['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? character['color']
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              character['trait'],
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Selected character description
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(_selectedCharacter),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _characters
                    .firstWhere((c) => c['id'] == _selectedCharacter)['color']
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _characters.firstWhere(
                    (c) => c['id'] == _selectedCharacter)['description'],
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationButton(
      String label, CharacterAnimation animation, String emoji) {
    final isSelected = _previewAnimation == animation;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => setState(() => _previewAnimation = animation),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.secondary : Colors.grey.shade300,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Large animated preview
          AnimatedCharacter(
            character: _selectedCharacter,
            skinColor: _selectedColor,
            size: 120,
            animation: CharacterAnimation.celebrating,
            showParticles: true,
          ),
          const SizedBox(height: 24),

          Text(
            'Pick Your Style! 🎨',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a color for your ${_selectedCharacter}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),

          // Color options
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: colors.map((color) {
              final isSelected = _selectedColor == color;
              final colorValue =
                  Color(int.parse('0xFF${color.replaceFirst('#', '')}'));

              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: colorValue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.tertiary : Colors.white,
                      width: isSelected ? 5 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorValue.withOpacity(isSelected ? 0.5 : 0.3),
                        blurRadius: isSelected ? 16 : 8,
                        spreadRadius: isSelected ? 4 : 0,
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 32)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Large animated preview
          AnimatedCharacter(
            character: _selectedCharacter,
            skinColor: _selectedColor,
            size: 140,
            animation: CharacterAnimation.celebrating,
            showParticles: true,
          ),
          const SizedBox(height: 16),

          // Name badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _nameController.text,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Summary card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSummaryRow('🏷️', 'Name', _nameController.text),
                const Divider(height: 24),
                _buildSummaryRow(
                    '🎭',
                    'Character',
                    _characters.firstWhere(
                        (c) => c['id'] == _selectedCharacter)['name']),
                const Divider(height: 24),
                _buildSummaryRow(
                    '✨',
                    'Trait',
                    _characters.firstWhere(
                        (c) => c['id'] == _selectedCharacter)['trait']),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ready message
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  'Your adventure awaits!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your character will explore the world map\nand learn amazing things!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side:
                      BorderSide(color: _getStepColor(_currentStep), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, color: _getStepColor(_currentStep)),
                    const SizedBox(width: 8),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getStepColor(_currentStep),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < 3 ? _nextStep : _createAvatar,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getStepColor(_currentStep),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: _getStepColor(_currentStep).withOpacity(0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentStep < 3 ? 'Continue' : '🚀 Start Adventure!',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_currentStep < 3) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward),
                  ],
                ],
              ),
            ),
          ),
        ],
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
                    color: Colors.black.withOpacity(0.2),
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
                    shaderCallback: (bounds) => LinearGradient(
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
                  Text(
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

      paint.color = color.withOpacity(opacity);
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
      final startY = -50.0;
      final endX = startX + (random.nextDouble() - 0.5) * 100;
      final endY = size.height + 50;

      final x = startX + (endX - startX) * animation;
      final y = startY + (endY - startY) * animation;
      final rotation = animation * math.pi * 4 + i;
      final opacity = (1.0 - animation * 0.5).clamp(0.0, 1.0);

      paint.color = colors[i % colors.length].withOpacity(opacity);

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
