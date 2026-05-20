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
  final FocusNode _screenFocusNode = FocusNode(debugLabel: 'avatar_creator');

  String _selectedCharacter = 'bear';
  String _selectedColor = '#E8C4A0';
  String _selectedOutfit = 'outfit_adventure';
  int _currentStep = 0;
  CharacterAnimation _previewAnimation = CharacterAnimation.idle;
  String? _hoveredColor;

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
    {
      'id': 'owl',
      'emoji': '🦉',
      'name': 'Olive Owl',
      'trait': 'Bright & Curious',
      'description': 'A wise owl who spots patterns and loves big ideas!',
      'color': const Color(0xFF8D6E63),
    },
    {
      'id': 'otter',
      'emoji': '🦦',
      'name': 'Ollie Otter',
      'trait': 'Playful & Bold',
      'description':
          'A splashy otter who turns learning into lively adventures!',
      'color': const Color(0xFFB87333),
    },
    {
      'id': 'wolf',
      'emoji': '🐺',
      'name': 'Willow Wolf',
      'trait': 'Focused & Fearless',
      'description':
          'A confident wolf who stays calm and tackles every challenge!',
      'color': const Color(0xFF607D8B),
    },
    {
      'id': 'tiger',
      'emoji': '🐯',
      'name': 'Tilly Tiger',
      'trait': 'Energetic & Brave',
      'description': 'A high-energy tiger who charges into every new lesson!',
      'color': const Color(0xFFFF8F00),
    },
    {
      'id': 'quokka',
      'emoji': 'Q',
      'name': 'Quinn Quokka',
      'trait': 'Cheerful & Curious',
      'description': 'A sunny quokka who helps every challenge feel possible!',
      'color': const Color(0xFFC98A5A),
    },
    {
      'id': 'platypus',
      'emoji': 'P',
      'name': 'Perry Platypus',
      'trait': 'Inventive & Calm',
      'description':
          'A clever platypus who loves experiments, patterns, and surprises!',
      'color': const Color(0xFF7B5E57),
    },
    {
      'id': 'turtle',
      'emoji': 'T',
      'name': 'Tara Turtle',
      'trait': 'Patient & Steady',
      'description':
          'A thoughtful turtle who proves slow, careful thinking wins!',
      'color': const Color(0xFF2E7D32),
    },
    {
      'id': 'dragon',
      'emoji': 'D',
      'name': 'Nova Dragon',
      'trait': 'Imaginative & Bold',
      'description':
          'A magical dragon who turns learning goals into epic quests!',
      'color': const Color(0xFF7E57C2),
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
    _screenFocusNode.dispose();
    super.dispose();
  }

  int get _selectedCharacterIndex =>
      _characters.indexWhere((c) => c['id'] == _selectedCharacter);

  void _selectCharacterAt(int index) {
    final wrappedIndex = (index + _characters.length) % _characters.length;
    final character = _characters[wrappedIndex];
    setState(() {
      _selectedCharacter = character['id'];
      _selectedColor =
          CosmeticsLibrary.getSkinColorsForCharacter(character['id'])[0];
      _previewAnimation = CharacterAnimation.celebrating;
    });
    HapticFeedback.selectionClick();
  }

  void _selectRelativeColor(int direction) {
    final colors =
        CosmeticsLibrary.getSkinColorsForCharacter(_selectedCharacter);
    final index = colors.indexOf(_selectedColor);
    final nextIndex = (index + direction + colors.length) % colors.length;
    setState(() => _selectedColor = colors[nextIndex]);
    HapticFeedback.selectionClick();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _previousStep();
      return;
    }

    if (_currentStep == 1) {
      if (key == LogicalKeyboardKey.arrowLeft) {
        _selectCharacterAt(_selectedCharacterIndex - 1);
      } else if (key == LogicalKeyboardKey.arrowRight) {
        _selectCharacterAt(_selectedCharacterIndex + 1);
      } else if (key == LogicalKeyboardKey.arrowUp) {
        _selectCharacterAt(_selectedCharacterIndex - 2);
      } else if (key == LogicalKeyboardKey.arrowDown) {
        _selectCharacterAt(_selectedCharacterIndex + 2);
      } else if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.space) {
        _nextStep();
      }
    } else if (_currentStep == 2) {
      if (key == LogicalKeyboardKey.arrowLeft) {
        _selectRelativeColor(-1);
      } else if (key == LogicalKeyboardKey.arrowRight) {
        _selectRelativeColor(1);
      } else if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.space) {
        _nextStep();
      }
    } else if (_currentStep == 3 &&
        (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space)) {
      _createAvatar();
    }
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
            outfitId: _selectedOutfit,
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
      _screenFocusNode.requestFocus();
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
      _screenFocusNode.requestFocus();
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _cyclePreviewAnimation() {
    setState(() {
      _previewAnimation = switch (_previewAnimation) {
        CharacterAnimation.idle => CharacterAnimation.walking,
        CharacterAnimation.walking => CharacterAnimation.jumping,
        CharacterAnimation.jumping => CharacterAnimation.celebrating,
        CharacterAnimation.celebrating => CharacterAnimation.idle,
        CharacterAnimation.thinking => CharacterAnimation.idle,
        CharacterAnimation.sleeping => CharacterAnimation.idle,
      };
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final isSmallScreen = screenHeight < 700;

    return KeyboardListener(
      focusNode: _screenFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
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
                  _buildAppBar(isSmallScreen: isSmallScreen),
                  _buildProgressBar(),
                  if (!isSmallScreen) _buildLivePreviewBanner(scale: 1.0),
                  if (isSmallScreen) _buildLivePreviewBanner(scale: 0.75),
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
                  _buildNavigationButtons(isCompact: isSmallScreen),
                ],
              ),
            ),
          ],
        ),
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

  String _characterPropAsset(String characterId) {
    switch (characterId) {
      case 'bear':
      case 'deer':
        return 'assets/images/logpile.PNG';
      case 'fox':
      case 'wolf':
        return 'assets/images/goldkey.PNG';
      case 'rabbit':
      case 'cat':
        return 'assets/images/pinkcrystal.PNG';
      case 'penguin':
        return 'assets/images/bluecrystal.PNG';
      case 'koala':
      case 'panda':
        return 'assets/images/greencrystal.PNG';
      case 'owl':
        return 'assets/images/scroll.PNG';
      case 'otter':
        return 'assets/images/potion.PNG';
      case 'tiger':
        return 'assets/images/goldpile.PNG';
      case 'quokka':
        return 'assets/images/questsandtasks.PNG';
      case 'platypus':
        return 'assets/images/bluecrystal.PNG';
      case 'turtle':
        return 'assets/images/greencrystal.PNG';
      case 'dragon':
        return 'assets/images/chest_open.PNG';
      default:
        return 'assets/images/chest_closed.PNG';
    }
  }

  Widget _buildAppBar({bool isSmallScreen = false}) {
    final titles = [
      '👋 Welcome!',
      '🎭 Choose Your Hero',
      '🎨 Pick Your Style',
      '🚀 Ready to Learn!'
    ];

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
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
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: _getStepColor(_currentStep).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              titles[_currentStep].split(' ')[0],
              style: TextStyle(fontSize: isSmallScreen ? 20 : 28),
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Step ${_currentStep + 1} of 4',
                  style: TextStyle(
                    color: _getStepColor(_currentStep),
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  titles[_currentStep].split(' ').skip(1).join(' '),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 16 : 22,
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

  Widget _buildLivePreviewBanner({double scale = 1.0}) {
    final selectedCharacter =
        _characters.firstWhere((c) => c['id'] == _selectedCharacter);
    final previewName = _nameController.text.trim().isEmpty
        ? selectedCharacter['name'] as String
        : _nameController.text.trim();

    final circleDiameter = 68.0 * scale;
    final charSize = 44.0 * scale;
    final padding = 14.0 * scale;
    final spacing = 14.0 * scale;

    return Padding(
      padding:
          EdgeInsets.fromLTRB(20 * scale, 10 * scale, 20 * scale, 6 * scale),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _cyclePreviewAnimation,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.96),
                  (selectedCharacter['color'] as Color).withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: (selectedCharacter['color'] as Color)
                    .withValues(alpha: 0.25),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (selectedCharacter['color'] as Color)
                      .withValues(alpha: 0.18),
                  blurRadius: 18 * scale,
                  offset: Offset(0, 10 * scale),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: circleDiameter,
                  height: circleDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (selectedCharacter['color'] as Color)
                            .withValues(alpha: 0.25),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: AnimatedCharacter(
                    character: _selectedCharacter,
                    skinColor: _selectedColor,
                    size: charSize,
                    animation: _previewAnimation,
                    showParticles:
                        _previewAnimation == CharacterAnimation.celebrating,
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        previewName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 13 * scale,
                            ),
                      ),
                      SizedBox(height: 3 * scale),
                      Text(
                        '${selectedCharacter['emoji']} ${selectedCharacter['trait']}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Tap preview to animate',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: selectedCharacter['color'] as Color,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: (selectedCharacter['color'] as Color)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${_characters.length} heroes',
                    style: TextStyle(
                      color: selectedCharacter['color'] as Color,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 600;
        final isTinyScreen = constraints.maxHeight < 500; // Very small phones
        final showcaseHeight =
            (constraints.maxHeight * 0.24).clamp(88.0, 180.0).toDouble();
        final showcaseSize =
            (showcaseHeight * 0.58).clamp(56.0, 100.0).toDouble();
        final trimmedName = _nameController.text.trim();
        final nameLength = trimmedName.length;
        final hasValidName = nameLength >= 2;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isTinyScreen ? 12 : (isCompact ? 16 : 24)),
          child: Column(
            children: [
              SizedBox(height: isTinyScreen ? 4 : (isCompact ? 10 : 20)),
              // Animated character showcase - reduced size for tiny screens
              SizedBox(
                height: showcaseHeight,
                child: AnimatedBuilder(
                  animation: _characterShowcaseController,
                  builder: (context, child) {
                    final index = (_characterShowcaseController.value *
                                _characters.length)
                            .floor() %
                        _characters.length;
                    final char = _characters[index];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: AnimatedCharacter(
                        key: ValueKey(char['id']),
                        character: char['id'],
                        size: showcaseSize,
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
                  maxLength: 16,
                  buildCounter: (
                    context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    return const SizedBox.shrink();
                  },
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
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _nextStep(),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: hasValidName
                      ? AppColors.success.withValues(alpha: 0.12)
                      : Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasValidName
                        ? AppColors.success.withValues(alpha: 0.35)
                        : Colors.orange.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasValidName ? '✅ Ready!' : '✍️ Add 2+ letters',
                      style: TextStyle(
                        color: hasValidName
                            ? AppColors.success
                            : Colors.orange.shade800,
                        fontWeight: FontWeight.w700,
                        fontSize: isTinyScreen ? 12 : 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$nameLength/16',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                        fontSize: isTinyScreen ? 11 : 12,
                      ),
                    ),
                  ],
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
        final selectorRows = isTiny ? 1 : 2;
        final cardExtent = constraints.maxWidth < 420
            ? 132.0
            : (constraints.maxWidth < 760 ? 156.0 : 176.0);

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
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: selectorRows,
                  crossAxisSpacing: isCompact ? 12 : 16,
                  mainAxisSpacing: isCompact ? 12 : 16,
                  mainAxisExtent: cardExtent,
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
                    child: Semantics(
                      button: true,
                      selected: isSelected,
                      label:
                          '${character['name']}, ${character['trait']}. ${character['description']}',
                      hint: 'Use arrow keys to choose a companion.',
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            setState(() {
                              _selectedCharacter = character['id'];
                              _selectedColor =
                                  CosmeticsLibrary.getSkinColorsForCharacter(
                                      character['id'])[0];
                              _previewAnimation =
                                  CharacterAnimation.celebrating;
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
                                            .withValues(alpha: 0.18),
                                        Colors.white,
                                        (character['color'] as Color)
                                            .withValues(alpha: 0.08),
                                      ],
                                    )
                                  : LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        (character['color'] as Color)
                                            .withValues(alpha: 0.04),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected
                                    ? character['color']
                                    : Colors.grey.shade200,
                                width: isSelected ? 4 : 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (character['color'] as Color)
                                      .withValues(
                                          alpha: isSelected ? 0.34 : 0.10),
                                  blurRadius: isSelected ? 18 : 9,
                                  spreadRadius: isSelected ? 2 : 0,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, cardConstraints) {
                                final isNarrow = cardConstraints.maxWidth < 150;

                                return Stack(
                                  children: [
                                    Positioned(
                                      left: 8,
                                      top: 8,
                                      child: Container(
                                        width: isNarrow ? 26 : 32,
                                        height: isNarrow ? 26 : 32,
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.92),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: (character['color'] as Color)
                                                .withValues(alpha: 0.25),
                                          ),
                                        ),
                                        child: Image.asset(
                                          _characterPropAsset(character['id']),
                                          fit: BoxFit.contain,
                                          filterQuality: FilterQuality.medium,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                            Icons.auto_awesome_rounded,
                                            color: character['color'] as Color,
                                            size: isNarrow ? 16 : 20,
                                          ),
                                        ),
                                      ),
                                    ),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                                    CharacterAnimation
                                                        .celebrating,
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() => _previewAnimation = animation);
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 8 : 12,
              vertical: isCompact ? 8 : 10,
            ),
            constraints: const BoxConstraints(minHeight: 48),
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
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
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
            Container(
              width: isTiny ? 128 : (isCompact ? 156 : 184),
              height: isTiny ? 128 : (isCompact ? 156 : 184),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(int.parse(
                            '0xFF${_selectedColor.replaceFirst('#', '')}'))
                        .withValues(alpha: 0.24),
                    Colors.white.withValues(alpha: 0.92),
                  ],
                ),
                border: Border.all(
                  color: _getStepColor(_currentStep).withValues(alpha: 0.28),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getStepColor(_currentStep).withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    right: isTiny ? 18 : 24,
                    bottom: isTiny ? 14 : 20,
                    child: Opacity(
                      opacity: 0.72,
                      child: Image.asset(
                        _characterPropAsset(_selectedCharacter),
                        width: isTiny ? 34 : 44,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                  ),
                  AnimatedCharacter(
                    character: _selectedCharacter,
                    skinColor: _selectedColor,
                    size: isTiny ? 100 : (isCompact ? 120 : 140),
                    animation: CharacterAnimation.celebrating,
                    showParticles: true,
                  ),
                ],
              ),
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
            if (!isTiny) ...[
              const SizedBox(height: 6),
              Text(
                'Arrow keys switch colors. Tap or click any swatch.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
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
                    final isHovered = _hoveredColor == color;
                    final colorValue =
                        Color(int.parse('0xFF${color.replaceFirst('#', '')}'));

                    return Semantics(
                      button: true,
                      selected: isSelected,
                      label:
                          'Avatar color ${colors.indexOf(color) + 1} of ${colors.length}',
                      hint: 'Use left and right arrows to change colors.',
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onHover: (hovering) {
                            setState(() {
                              _hoveredColor = hovering ? color : null;
                            });
                          },
                          onTap: () {
                            setState(() => _selectedColor = color);
                            HapticFeedback.selectionClick();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isCompact
                                ? (isHovered ? 56 : 50)
                                : (isHovered ? 76 : 70),
                            height: isCompact
                                ? (isHovered ? 56 : 50)
                                : (isHovered ? 76 : 70),
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  colorValue.withValues(alpha: 0.78),
                                  colorValue,
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.tertiary
                                    : Colors.white,
                                width: isSelected ? 4 : 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorValue.withValues(
                                      alpha: isSelected
                                          ? 0.5
                                          : (isHovered ? 0.4 : 0.3)),
                                  blurRadius:
                                      isSelected ? 12 : (isHovered ? 11 : 8),
                                  spreadRadius:
                                      isSelected ? 3 : (isHovered ? 1 : 0),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? Icon(Icons.check,
                                    color: Colors.white,
                                    size: isCompact ? 24 : 32)
                                : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            SizedBox(height: isTiny ? 10 : 16),
            _buildOutfitSelector(isCompact: isCompact),
            if (!isTiny) ...[
              const SizedBox(height: 10),
              _buildUnlockPreview(isCompact: isCompact),
            ],

            const Spacer(flex: 1),
          ],
        );
      },
    );
  }

  Widget _buildOutfitSelector({required bool isCompact}) {
    final starterOutfits =
        CosmeticsLibrary.defaultOutfits.where((outfit) => outfit.isUnlocked);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: starterOutfits.map((outfit) {
          final isSelected = _selectedOutfit == outfit.id;
          final outfitColor =
              Color(int.parse('0xFF${outfit.color.replaceFirst('#', '')}'));

          return Semantics(
            button: true,
            selected: isSelected,
            label: '${outfit.name}. ${outfit.description}',
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedOutfit = outfit.id);
                  HapticFeedback.selectionClick();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 12 : 16,
                    vertical: isCompact ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? outfitColor.withValues(alpha: 0.16)
                        : Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? outfitColor
                          : AppColors.divider.withValues(alpha: 0.8),
                      width: isSelected ? 2.5 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: outfitColor.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: outfitColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        outfit.name,
                        style: TextStyle(
                          color:
                              isSelected ? outfitColor : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: isCompact ? 12 : 13,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.check_circle, size: 16, color: outfitColor),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUnlockPreview({required bool isCompact}) {
    final lockedOutfits =
        CosmeticsLibrary.defaultOutfits.where((outfit) => !outfit.isUnlocked);
    final lockedAccessories = CosmeticsLibrary.defaultAccessories
        .where((accessory) => !accessory.isUnlocked);

    return SizedBox(
      height: isCompact ? 58 : 68,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24),
        children: [
          _buildUnlockChip(
            icon: Icons.lock_open_rounded,
            title: 'Starter styles unlocked',
            subtitle: '3 outfits ready now',
            color: AppColors.success,
            isCompact: isCompact,
          ),
          ...lockedOutfits.take(3).map(
                (outfit) => _buildUnlockChip(
                  icon: Icons.checkroom_rounded,
                  title: outfit.name,
                  subtitle: 'Level ${outfit.unlockedAtLevel}',
                  color: Color(
                    int.parse('0xFF${outfit.color.replaceFirst('#', '')}'),
                  ),
                  isCompact: isCompact,
                ),
              ),
          ...lockedAccessories.take(2).map(
                (accessory) => _buildUnlockChip(
                  icon: Icons.auto_awesome_rounded,
                  title: accessory.name,
                  subtitle: 'Level ${accessory.unlockedAtLevel}',
                  color: AppColors.secondary,
                  isCompact: isCompact,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildUnlockChip({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isCompact,
  }) {
    return Container(
      width: isCompact ? 150 : 176,
      margin: const EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isCompact ? 32 : 38,
            height: isCompact ? 32 : 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isCompact ? 18 : 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: isCompact ? 11 : 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: isCompact ? 10 : 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                        'Style',
                        'Outfit',
                        CosmeticsLibrary.defaultOutfits
                            .firstWhere((o) => o.id == _selectedOutfit)
                            .name,
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

  Widget _buildNavigationButtons({bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 20),
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
          final compact = isCompact || constraints.maxWidth < 400;

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
                          EdgeInsets.symmetric(vertical: compact ? 10 : 16),
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
                            size: compact ? 18 : 24),
                        SizedBox(width: compact ? 4 : 8),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: compact ? 13 : 16,
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
