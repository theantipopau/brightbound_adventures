import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/core/utils/isometric_engine.dart';
import 'package:brightbound_adventures/core/utils/world_map_isometric_helper.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/animated_character.dart';
import 'package:brightbound_adventures/ui/widgets/daily_challenge_card.dart';
import 'package:brightbound_adventures/ui/screens/trophy_room_screen.dart';

/// Enhanced World Map with 3D-style visuals and progressive unlocking
class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _entranceController;
  late AnimationController _floatController;
  late AnimationController _pathController;
  late AnimationController _avatarMoveController;
  
  // Keyboard focus
  final FocusNode _focusNode = FocusNode();
  int _selectedZoneIndex = 0;
  
  // Device detection
  bool _isPhoneDevice = false;
  
  // Avatar state
  int _currentZoneIndex = 0;
  int? _targetZoneIndex;
  bool _isMoving = false;

  // Isometric 3D state
  late Map<String, IsometricPosition> _zoneIsometricPositions;

  // Zone definitions with progression order
  final List<ZoneData> _zones = [
    const ZoneData(
      id: 'word-woods',
      name: 'Word Woods',
      emoji: '🌲',
      color: AppColors.wordWoodsColor,
      position: Offset(0.15, 0.40),
      description: 'Master letters & reading!',
      order: 0,
      requiredStars: 0, // First zone - always unlocked
    ),
    const ZoneData(
      id: 'number-nebula',
      name: 'Number Nebula',
      emoji: '🌌',
      color: AppColors.numberNebulaColor,
      position: Offset(0.50, 0.25),
      description: 'Explore math & numbers!',
      order: 1,
      requiredStars: 3, // Need 3 stars to unlock
    ),
    const ZoneData(
      id: 'math-facts',
      name: 'Math Facts',
      emoji: '🔢',
      color: Color(0xFFFF6B6B),
      position: Offset(0.25, 0.55),
      description: 'Master multiplication & addition!',
      order: 2,
      requiredStars: 6,
    ),
    const ZoneData(
      id: 'story-springs',
      name: 'Story Springs',
      emoji: '📖',
      color: AppColors.storyspringsColor,
      position: Offset(0.85, 0.40),
      description: 'Create amazing stories!',
      order: 3,
      requiredStars: 10,
    ),
    const ZoneData(
      id: 'puzzle-peaks',
      name: 'Puzzle Peaks',
      emoji: '🧩',
      color: AppColors.puzzlePeaksColor,
      position: Offset(0.65, 0.65),
      description: 'Solve tricky puzzles!',
      order: 4,
      requiredStars: 15,
    ),
    const ZoneData(
      id: 'adventure-arena',
      name: 'Adventure Arena',
      emoji: '🏆',
      color: AppColors.adventureArenaColor,
      position: Offset(0.30, 0.75),
      description: 'Ultimate challenges!',
      order: 5,
      requiredStars: 25,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _detectDevice();
    _initAnimations();
    _initIsometricPositions();
  }

  void _initIsometricPositions() {
    // Convert all zones to isometric grid positions
    _zoneIsometricPositions = WorldMapIsometricHelper.getZonePositions(_zones);
  }

  Future<void> _detectDevice() async {
    try {
      if (Theme.of(context).platform == TargetPlatform.iOS ||
          Theme.of(context).platform == TargetPlatform.android) {
        // Check screen size to distinguish phone from tablet
        final screenWidth = MediaQuery.of(context).size.width;
        setState(() {
          _isPhoneDevice = screenWidth < 600; // Phones are typically < 600dp
        });
      }
    } catch (e) {
      debugPrint('Error detecting device: $e');
    }
  }

  void _initAnimations() {
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pathController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _avatarMoveController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _avatarMoveController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAvatarArrived();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _pathController.dispose();
    _avatarMoveController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Handle keyboard navigation
  void _handleKeyEvent(KeyEvent event, int totalStars) {
    if (event is! KeyDownEvent) return;
    if (_isMoving) return;
    
    final key = event.logicalKey;
    
    // Arrow keys to select zone
    if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedZoneIndex = (_selectedZoneIndex + 1) % _zones.length;
      });
    } else if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedZoneIndex = (_selectedZoneIndex - 1 + _zones.length) % _zones.length;
      });
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      // Enter/Space to go to selected zone
      final isUnlocked = _isZoneUnlocked(_selectedZoneIndex, totalStars);
      if (isUnlocked) {
        _moveToZone(_selectedZoneIndex);
      } else {
        _showLockedDialog(_zones[_selectedZoneIndex], totalStars);
      }
    } else if (key == LogicalKeyboardKey.digit1) {
      _selectZoneByNumber(0, totalStars);
    } else if (key == LogicalKeyboardKey.digit2) {
      _selectZoneByNumber(1, totalStars);
    } else if (key == LogicalKeyboardKey.digit3) {
      _selectZoneByNumber(2, totalStars);
    } else if (key == LogicalKeyboardKey.digit4) {
      _selectZoneByNumber(3, totalStars);
    } else if (key == LogicalKeyboardKey.digit5) {
      _selectZoneByNumber(4, totalStars);
    }
  }
  
  void _selectZoneByNumber(int index, int totalStars) {
    if (index >= _zones.length) return;
    setState(() {
      _selectedZoneIndex = index;
    });
    final isUnlocked = _isZoneUnlocked(index, totalStars);
    if (isUnlocked) {
      _moveToZone(index);
    } else {
      _showLockedDialog(_zones[index], totalStars);
    }
  }

  int _calculateTotalStars(SkillProvider skillProvider) {
    // Calculate stars based on mastered skills
    final stats = skillProvider.getProgressionStats();
    return stats.mastered * 3 + stats.practising;
  }

  bool _isZoneUnlocked(int zoneIndex, int totalStars) {
    final isUnlocked = totalStars >= _zones[zoneIndex].requiredStars;
    debugPrint('Zone ${_zones[zoneIndex].name}: totalStars=$totalStars, required=${_zones[zoneIndex].requiredStars}, unlocked=$isUnlocked');
    return isUnlocked;
  }

  void _moveToZone(int targetIndex) {
    if (_isMoving) return;
    
    // If already at this zone, navigate directly without animation
    if (targetIndex == _currentZoneIndex) {
      debugPrint('Already at zone $targetIndex - navigating directly');
      Navigator.pushNamed(context, '/${_zones[targetIndex].id}');
      return;
    }
    
    debugPrint('Moving avatar from zone $_currentZoneIndex to zone $targetIndex');
    setState(() {
      _targetZoneIndex = targetIndex;
      _isMoving = true;
    });
    
    _avatarMoveController.forward(from: 0);
  }

  void _onAvatarArrived() {
    final targetZone = _targetZoneIndex;
    
    setState(() {
      _currentZoneIndex = _targetZoneIndex ?? _currentZoneIndex;
      _targetZoneIndex = null;
      _isMoving = false;
    });

    // Navigate to zone after a brief pause
    if (targetZone != null) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          Navigator.pushNamed(context, '/${_zones[targetZone].id}');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AvatarProvider, SkillProvider>(
        builder: (context, avatarProvider, skillProvider, _) {
          final avatar = avatarProvider.avatar;
          final totalStars = skillProvider.isInitialized 
              ? _calculateTotalStars(skillProvider) 
              : 0;

          if (avatar == null) {
            return _buildNoAvatarScreen();
          }

          return KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (event) => _handleKeyEvent(event, totalStars),
            child: GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: Stack(
                children: [
                  // Animated gradient background
                  _buildAnimatedBackground(),

                  // 3D-style map with islands
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            // Animated paths between zones
                            CustomPaint(
                              painter: _PathPainter(
                                zones: _zones,
                                animation: _pathController.value,
                                totalStars: totalStars,
                              ),
                              size: Size(constraints.maxWidth, constraints.maxHeight),
                            ),

                            // Zone islands
                            ..._buildZoneIslands(constraints, totalStars, skillProvider),

                            // Animated avatar on path
                            _buildMovingAvatar(constraints, avatar),

                            // Top HUD
                            _buildTopHUD(avatar, totalStars),

                            // Bottom quick actions
                            _buildBottomActions(totalStars),
                            
                            // Keyboard navigation hint
                            _buildKeyboardHint(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoAvatarScreen() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.3),
            AppColors.secondary.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎮', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            Text(
              'Create Your Character!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushReplacementNamed(context, '/avatar-creator'),
              icon: const Icon(Icons.person_add),
              label: const Text('Get Started'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // Vibrant sky blue at top
                Color.lerp(
                  const Color(0xFF4FC3F7),
                  const Color(0xFF29B6F6),
                  _floatController.value,
                )!,
                // Bright cyan-green middle
                Color.lerp(
                  const Color(0xFF80DEEA),
                  const Color(0xFFA5D6A7),
                  _floatController.value,
                )!,
                // Warm sunset orange-pink at bottom
                Color.lerp(
                  const Color(0xFFFFCC80),
                  const Color(0xFFF8BBD9),
                  _floatController.value,
                )!,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: _EnhancedBackgroundPainter(animation: _floatController.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  List<Widget> _buildZoneIslands(
    BoxConstraints constraints, 
    int totalStars,
    SkillProvider skillProvider,
  ) {
    // Sort zones by depth for proper 3D layering
    final sortedZones = WorldMapIsometricHelper.sortByDepth(
      _zones,
      (zone) => _zoneIsometricPositions[zone.id]!,
    );
    
    return sortedZones.map((zone) {
      final index = _zones.indexOf(zone);
      final isUnlocked = _isZoneUnlocked(index, totalStars);
      final isCurrentZone = _currentZoneIndex == index;
      final zoneStats = skillProvider.getZoneStats(zone.id.replaceAll('-', '_'));

      // Use isometric position instead of normalized 2D position
      final isoPos = _zoneIsometricPositions[zone.id]!;
      final screenPos = WorldMapIsometricHelper.gridToScreen(
        isoPos,
        Size(constraints.maxWidth, constraints.maxHeight),
      );

      return AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) {
          // Staggered entrance animation
          final delay = index * 0.15;
          final progress = ((_entranceController.value - delay) / 0.4).clamp(0.0, 1.0);
          
          return Positioned(
            left: screenPos.dx - 60,
            top: screenPos.dy - 70 + (1 - progress) * 50,
            child: Opacity(
              opacity: progress,
              child: _ZoneIsland(
                zone: zone,
                isUnlocked: isUnlocked,
                isCurrentZone: isCurrentZone,
                isSelected: _selectedZoneIndex == index,
                starsEarned: zoneStats.masteredSkills,
                totalSkills: zoneStats.totalSkills,
                floatAnimation: _floatController,
                onTap: isUnlocked 
                    ? () {
                        debugPrint('Tapped zone ${zone.name} - moving to index $index');
                        _moveToZone(index);
                      }
                    : () {
                        debugPrint('Tapped locked zone ${zone.name}');
                        _showLockedDialog(zone, totalStars);
                      },
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildMovingAvatar(BoxConstraints constraints, Avatar avatar) {
    return AnimatedBuilder(
      animation: _avatarMoveController,
      builder: (context, child) {
        final currentZone = _zones[_currentZoneIndex];
        final targetZone = _targetZoneIndex != null ? _zones[_targetZoneIndex!] : currentZone;
        
        // Use isometric positions
        final currentIsoPos = _zoneIsometricPositions[currentZone.id]!;
        final targetIsoPos = _zoneIsometricPositions[targetZone.id]!;
        
        final startPos = WorldMapIsometricHelper.gridToScreen(
          currentIsoPos,
          Size(constraints.maxWidth, constraints.maxHeight),
        );
        final endPos = WorldMapIsometricHelper.gridToScreen(
          targetIsoPos,
          Size(constraints.maxWidth, constraints.maxHeight),
        );

        // Curved path with bounce
        final t = Curves.easeInOutCubic.transform(_avatarMoveController.value);
        final pos = Offset.lerp(startPos, endPos, t)!;
        
        // Add arc to movement (jump effect)
        final arcHeight = -40 * math.sin(t * math.pi);
        
        return Positioned(
          left: pos.dx - 35,
          top: pos.dy - 70 + arcHeight,
          child: IgnorePointer(
            ignoring: false,
            child: _build3DAvatar(avatar, _isMoving),
          ),
        );
      },
    );
  }

  Widget _build3DAvatar(Avatar avatar, bool isMoving) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final bounce = isMoving ? 0.0 : math.sin(_floatController.value * math.pi) * 3;
        
        return GestureDetector(
          onTap: () => _showAvatarInfo(context, avatar),
          child: Transform.translate(
            offset: Offset(0, bounce),
            child: SizedBox(
              width: 70,
              height: 90,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Character
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: AnimatedCharacter(
                      character: avatar.baseCharacter,
                      skinColor: avatar.skinColor,
                      size: 50,
                      animation: isMoving 
                          ? CharacterAnimation.walking 
                          : CharacterAnimation.idle,
                      showParticles: false,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Name tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      avatar.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHUD(Avatar avatar, int totalStars) {
    return Positioned(
      top: 10,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Logo and title - clickable for info
          GestureDetector(
            onTap: () => _showAppInfoDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Text('🌟', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'BrightBound',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Player switcher button
          GestureDetector(
            onTap: () => _showPlayerSwitcher(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('👤', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    avatar.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.swap_horiz, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // Star counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('⭐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Text(
                  '$totalStars',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Settings button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, size: 22),
              onPressed: () => _showSettingsDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(int totalStars) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Daily Challenge button
          _buildActionButton(
            icon: '🎯',
            label: 'Daily\nChallenge',
            color: Colors.orange,
            onTap: () => _showDailyChallenges(),
          ),
          const SizedBox(width: 12),
          
          // Mini Games button
          _buildActionButton(
            icon: '🎮',
            label: 'Mini\nGames',
            color: Colors.purple,
            onTap: () => _showMiniGamesMenu(),
          ),
          const SizedBox(width: 12),
          
          // Achievements button
          _buildActionButton(
            icon: '🏆',
            label: 'My\nTrophies',
            color: Colors.amber,
            onTap: () => _showAchievements(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLockedDialog(ZoneData zone, int totalStars) {
    final starsNeeded = zone.requiredStars - totalStars;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: zone.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                const Text('🔒', style: TextStyle(fontSize: 48)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${zone.name} is Locked!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                children: [
                  const TextSpan(text: 'Earn '),
                  TextSpan(
                    text: '$starsNeeded more ⭐',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const TextSpan(text: ' to unlock this world!'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keep practicing in unlocked zones!',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'BrightBound Adventures',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Version info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Alpha Release',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Made with ❤️ for learning',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Quick Links',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              // Links
              _buildLinkTile('🔗', 'Developer Website', 'https://matthurley.dev'),
              const SizedBox(height: 8),
              _buildLinkTile('❤️', 'Support the Project', 'https://ko-fi.com/theantipopau'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLinkTile(String emoji, String label, String url) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.open_in_new, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showMiniGamesMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '🎮 Mini Games',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildMiniGameTile('🎯', 'Target\nPractice', Colors.red),
                _buildMiniGameTile('🧠', 'Memory\nMatch', Colors.purple),
                _buildMiniGameTile('⏱️', 'Speed\nRound', Colors.orange),
                _buildMiniGameTile('🎨', 'Color\nSplash', Colors.blue),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniGameTile(String emoji, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _showComingSoon(label.replaceAll('\n', ' '));
      },
      child: Container(
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.7), color],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarInfo(BuildContext context, avatar) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedCharacter(
              character: avatar.baseCharacter,
              skinColor: avatar.skinColor,
              size: 100,
              animation: CharacterAnimation.celebrating,
              showParticles: true,
            ),
            const SizedBox(height: 16),
            Text(
              avatar.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatChip('⭐', 'Level ${avatar.level}', Colors.amber),
                const SizedBox(width: 8),
                _buildStatChip('⚡', '${avatar.experiencePoints} XP', Colors.purple),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.explore),
              label: const Text('Keep Exploring!'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('⚙️ ', style: TextStyle(fontSize: 24)),
            Text('Settings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🔊', style: TextStyle(fontSize: 24)),
              title: const Text('Sound Effects'),
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            ListTile(
              leading: const Text('🎵', style: TextStyle(fontSize: 24)),
              title: const Text('Music'),
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
            const Divider(),
            ListTile(
              leading: const Text('🔄', style: TextStyle(fontSize: 24)),
              title: const Text('Reset Progress'),
              onTap: () {
                Navigator.pop(context);
                _showResetConfirmation(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Reset Progress?'),
        content: const Text(
          'This will delete ALL your progress and stars. This cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/avatar-creator');
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon! 🚀'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  void _showDailyChallenges() {
    final challenges = DailyChallengeGenerator.generateDailyChallenges(DateTime.now());
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade900,
              Colors.purple.shade900,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🎯', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daily Challenges',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Complete challenges for bonus XP!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Timer until reset
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeUntilReset(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Challenge cards
            Flexible(
              child: DailyChallengesList(
                challenges: challenges,
                onChallengeTap: (challenge) {
                  Navigator.pop(context);
                  // Navigate to the zone
                  Navigator.pushNamed(
                    context, 
                    '/${challenge.zoneId.replaceAll('_', '-')}',
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  String _getTimeUntilReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final difference = tomorrow.difference(now);
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    
    return '${hours}h ${minutes}m';
  }
  
  void _showAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TrophyRoomScreen(),
      ),
    );
  }

  void _showPlayerSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '👥 Switch Player',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage profiles for different players',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            
            // Current player
            Consumer<AvatarProvider>(
              builder: (context, avatarProvider, _) {
                final avatar = avatarProvider.avatar;
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getCharacterEmoji(avatar?.baseCharacter ?? 'fox'),
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              avatar?.name ?? 'Player',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Level ${avatar?.level ?? 1} • Current Player',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Create new player button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/avatar-creator');
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create New Player'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Edit current player
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to edit avatar
                  Navigator.pushNamed(context, '/avatar-creator');
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Current Player'),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  String _getCharacterEmoji(String character) {
    switch (character.toLowerCase()) {
      case 'fox': return '🦊';
      case 'deer': return '🦌';
      case 'bunny': return '🐰';
      case 'bear': return '🐻';
      case 'owl': return '🦉';
      case 'cat': return '🐱';
      default: return '🦊';
    }
  }
  
  Widget _buildKeyboardHint() {
    // Hide keyboard hints on phones - they don't have physical keyboards
    if (_isPhoneDevice) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: 100,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.keyboard, color: Colors.white70, size: 16),
            SizedBox(width: 8),
            Text(
              '←→ Navigate  •  Enter/Tap to Enter',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for zone information
class ZoneData {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final Offset position;
  final String description;
  final int order;
  final int requiredStars;

  const ZoneData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.position,
    required this.description,
    required this.order,
    required this.requiredStars,
  });
}

/// Zone island widget with 3D floating effect
class _ZoneIsland extends StatelessWidget {
  final ZoneData zone;
  final bool isUnlocked;
  final bool isCurrentZone;
  final bool isSelected;
  final int starsEarned;
  final int totalSkills;
  final Animation<double> floatAnimation;
  final VoidCallback onTap;

  const _ZoneIsland({
    required this.zone,
    required this.isUnlocked,
    required this.isCurrentZone,
    required this.isSelected,
    required this.starsEarned,
    required this.totalSkills,
    required this.floatAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatAnimation,
      builder: (context, child) {
        final float = math.sin(floatAnimation.value * math.pi + zone.order) * 4;
        
        return Transform.translate(
          offset: Offset(0, float),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 120,
              height: 140,
              decoration: isSelected ? BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: zone.color.withValues(alpha: 0.6),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ) : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Island shadow
                  Positioned(
                    bottom: 0,
                    child: Container(
                      width: 90,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(45),
                      ),
                    ),
                  ),
                  
                  // Island base (3D effect)
                  Positioned(
                    bottom: 15,
                    child: Container(
                      width: 100,
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            isUnlocked 
                                ? zone.color.withValues(alpha: 0.6)
                                : Colors.grey.withValues(alpha: 0.4),
                            isUnlocked
                                ? zone.color.withValues(alpha: 0.3)
                                : Colors.grey.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(50),
                        ),
                      ),
                    ),
                  ),
                  
                  // Main island body
                  Positioned(
                    bottom: 25,
                    child: Container(
                      width: 100,
                      height: 85,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.5),
                          colors: isUnlocked
                              ? [
                                  zone.color.withValues(alpha: 0.9),
                                  zone.color,
                                ]
                              : [
                                  Colors.grey.shade400,
                                  Colors.grey.shade600,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCurrentZone 
                              ? Colors.white 
                              : Colors.white.withValues(alpha: 0.5),
                          width: isCurrentZone ? 4 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isUnlocked ? zone.color : Colors.grey)
                                .withValues(alpha: 0.4),
                            blurRadius: isCurrentZone ? 20 : 12,
                            spreadRadius: isCurrentZone ? 4 : 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Emoji or lock
                            Text(
                              isUnlocked ? zone.emoji : '🔒',
                              style: TextStyle(
                                fontSize: isUnlocked ? 28 : 22,
                              ),
                            ),
                            // Zone name
                            Text(
                              zone.name.split(' ').first,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                            // Stars progress - only show if unlocked
                            if (isUnlocked)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(3, (i) {
                                  // Safely calculate stars - avoid division by zero
                                  final maxStarsPerSection = totalSkills > 0 ? totalSkills / 3 : 1;
                                  final filled = i < (starsEarned / maxStarsPerSection).ceil();
                                  return Icon(
                                    filled ? Icons.star : Icons.star_border,
                                    size: 10,
                                    color: Colors.amber,
                                  );
                                }),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Current zone indicator
                  if (isCurrentZone)
                    Positioned(
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Text(
                          '📍 HERE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  
                  // Locked indicator
                  if (!isUnlocked)
                    Positioned(
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${zone.requiredStars}⭐',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated path painter connecting zones
class _PathPainter extends CustomPainter {
  final List<ZoneData> zones;
  final double animation;
  final int totalStars;

  _PathPainter({
    required this.zones,
    required this.animation,
    required this.totalStars,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < zones.length - 1; i++) {
      final start = Offset(
        size.width * zones[i].position.dx,
        size.height * zones[i].position.dy,
      );
      final end = Offset(
        size.width * zones[i + 1].position.dx,
        size.height * zones[i + 1].position.dy,
      );
      
      final isUnlocked = totalStars >= zones[i + 1].requiredStars;
      
      // Draw path
      final pathPaint = Paint()
        ..color = isUnlocked 
            ? Colors.amber.withValues(alpha: 0.6)
            : Colors.grey.withValues(alpha: 0.3)
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      // Create curved path
      final path = Path();
      path.moveTo(start.dx, start.dy);
      
      final controlX = (start.dx + end.dx) / 2;
      final controlY = math.min(start.dy, end.dy) - 30;
      
      path.quadraticBezierTo(controlX, controlY, end.dx, end.dy);
      
      // Draw dashed path
      final dashPath = _createDashedPath(path, 15, 10);
      canvas.drawPath(dashPath, pathPaint);
      
      // Draw animated dots on unlocked paths
      if (isUnlocked) {
        final dotPaint = Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.fill;
        
        final pathMetrics = path.computeMetrics().first;
        final progress = (animation + i * 0.2) % 1.0;
        final pos = pathMetrics.getTangentForOffset(
          pathMetrics.length * progress,
        )?.position;
        
        if (pos != null) {
          canvas.drawCircle(pos, 6, dotPaint);
        }
      }
    }
  }

  Path _createDashedPath(Path source, double dashLength, double gapLength) {
    final path = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final nextDash = distance + dashLength;
        path.addPath(
          metric.extractPath(distance, nextDash.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = nextDash + gapLength;
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.animation != animation || 
           oldDelegate.totalStars != totalStars;
  }
}

/// Enhanced 3D background painter with parallax layers
class _EnhancedBackgroundPainter extends CustomPainter {
  final double animation;

  _EnhancedBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 0: Sky gradient with sun/moon
    _drawSky(canvas, size);
    
    // Layer 1: Distant castles and buildings
    _drawDistantStructures(canvas, size);
    
    // Layer 2: Distant mountains with snow caps
    _drawDistantMountains(canvas, size);
    
    // Layer 3: Rolling hills with more detail
    _drawRollingHills(canvas, size);
    
    // Layer 4: Puffy clouds with depth
    _drawClouds(canvas, size);
    
    // Layer 5: Flying birds
    _drawBirds(canvas, size);
    
    // Layer 6: Butterflies
    _drawButterflies(canvas, size);
    
    // Layer 7: Water features with reflections
    _drawWaterFeatures(canvas, size);
    
    // Layer 8: Trees and foliage
    _drawTrees(canvas, size);
    
    // Layer 9: Bushes
    _drawBushes(canvas, size);
    
    // Layer 10: Grass patches
    _drawGrassPatches(canvas, size);
    
    // Layer 11: Flowers
    _drawFlowers(canvas, size);
    
    // Layer 12: Floating particles/sparkles
    _drawSparkles(canvas, size);
  }
  
  void _drawSky(Canvas canvas, Size size) {
    // Beautiful gradient sky
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF87CEEB), // Sky blue
          const Color(0xFFB0E0E6), // Powder blue
          const Color(0xFFFFF8DC), // Cornsilk (horizon)
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);
    
    // Sun with glow
    final sunPosition = Offset(size.width * 0.85, size.height * 0.12);
    
    // Outer glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.orange.withValues(alpha: 0.3),
          Colors.orange.withValues(alpha: 0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: sunPosition, radius: 60));
    canvas.drawCircle(sunPosition, 60, glowPaint);
    
    // Sun body
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFF00), // Bright yellow
          const Color(0xFFFFA500), // Orange
        ],
      ).createShader(Rect.fromCircle(center: sunPosition, radius: 30));
    canvas.drawCircle(sunPosition, 30, sunPaint);
    
    // Sun rays
    final rayPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6) + animation * math.pi * 0.2;
      final start = sunPosition + Offset(math.cos(angle) * 35, math.sin(angle) * 35);
      final end = sunPosition + Offset(math.cos(angle) * 50, math.sin(angle) * 50);
      canvas.drawLine(start, end, rayPaint);
    }
  }
  
  void _drawDistantStructures(Canvas canvas, Size size) {
    // Distant castle/buildings on horizon
    final structures = [
      Offset(size.width * 0.15, size.height * 0.42),
      Offset(size.width * 0.45, size.height * 0.38),
      Offset(size.width * 0.72, size.height * 0.4),
    ];
    
    for (final structure in structures) {
      _drawCastle(canvas, structure, 25.0);
    }
  }
  
  void _drawCastle(Canvas canvas, Offset position, double size) {
    final castlePaint = Paint()
      ..color = Colors.purple.shade900.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    
    // Main tower
    canvas.drawRect(
      Rect.fromCenter(center: position, width: size, height: size * 1.5),
      castlePaint,
    );
    
    // Side towers
    canvas.drawRect(
      Rect.fromCenter(
        center: position + Offset(-size * 0.7, size * 0.2),
        width: size * 0.6,
        height: size * 1.2,
      ),
      castlePaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: position + Offset(size * 0.7, size * 0.2),
        width: size * 0.6,
        height: size * 1.2,
      ),
      castlePaint,
    );
    
    // Cone roofs
    final roofPath = Path()
      ..moveTo(position.dx - size * 0.6, position.dy - size * 0.75)
      ..lineTo(position.dx, position.dy - size * 1.2)
      ..lineTo(position.dx + size * 0.6, position.dy - size * 0.75)
      ..close();
    canvas.drawPath(roofPath, castlePaint);
  }
  
  void _drawDistantMountains(Canvas canvas, Size size) {
    final float = math.sin(animation * math.pi * 0.3) * 3;
    
    // Back mountain range (bluish)
    final backPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.indigo.shade300.withValues(alpha: 0.4),
          Colors.blue.shade200.withValues(alpha: 0.3),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final backPath = Path();
    backPath.moveTo(0, size.height * 0.52);
    backPath.quadraticBezierTo(
      size.width * 0.2 + float, size.height * 0.38,
      size.width * 0.4, size.height * 0.48,
    );
    backPath.quadraticBezierTo(
      size.width * 0.6 + float, size.height * 0.32,
      size.width * 0.8, size.height * 0.45,
    );
    backPath.lineTo(size.width, size.height * 0.45);
    backPath.lineTo(size.width, size.height);
    backPath.lineTo(0, size.height);
    backPath.close();
    canvas.drawPath(backPath, backPaint);
    
    // Front mountain range with snow caps
    final frontPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blueGrey.shade400.withValues(alpha: 0.5),
          Colors.blueGrey.shade300.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final frontPath = Path();
    frontPath.moveTo(0, size.height * 0.5);
    frontPath.quadraticBezierTo(
      size.width * 0.15 + float, size.height * 0.35,
      size.width * 0.3, size.height * 0.45,
    );
    frontPath.quadraticBezierTo(
      size.width * 0.45 + float, size.height * 0.3,
      size.width * 0.6, size.height * 0.42,
    );
    frontPath.quadraticBezierTo(
      size.width * 0.8 + float, size.height * 0.28,
      size.width, size.height * 0.4,
    );
    frontPath.lineTo(size.width, size.height);
    frontPath.lineTo(0, size.height);
    frontPath.close();
    canvas.drawPath(frontPath, frontPaint);
    
    // Snow caps on peaks
    final snowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    
    final snowCaps = [
      Offset(size.width * 0.15 + float, size.height * 0.35),
      Offset(size.width * 0.45 + float, size.height * 0.3),
      Offset(size.width * 0.8 + float, size.height * 0.28),
    ];
    
    for (final cap in snowCaps) {
      final snowPath = Path()
        ..moveTo(cap.dx - 15, cap.dy + 8)
        ..lineTo(cap.dx, cap.dy)
        ..lineTo(cap.dx + 15, cap.dy + 8)
        ..close();
      canvas.drawPath(snowPath, snowPaint);
    }
  }
  
  void _drawRollingHills(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.green.shade200.withValues(alpha: 0.25),
          Colors.green.shade100.withValues(alpha: 0.15),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final float = math.sin(animation * math.pi * 0.5) * 5; // Medium parallax
    
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.2 + float, size.height * 0.6,
      size.width * 0.4, size.height * 0.68,
    );
    path.quadraticBezierTo(
      size.width * 0.6 + float, size.height * 0.55,
      size.width * 0.8, size.height * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.95 + float, size.height * 0.58,
      size.width, size.height * 0.62,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  void _drawClouds(Canvas canvas, Size size) {
    // Large fluffy clouds with 3D shading
    final clouds = [
      _CloudData(Offset(size.width * 0.1, size.height * 0.12), 45, 0.7),
      _CloudData(Offset(size.width * 0.55, size.height * 0.06), 55, 0.8),
      _CloudData(Offset(size.width * 0.85, size.height * 0.15), 40, 0.6),
      _CloudData(Offset(size.width * 0.25, size.height * 0.88), 50, 0.5),
      _CloudData(Offset(size.width * 0.75, size.height * 0.85), 45, 0.55),
    ];

    for (int i = 0; i < clouds.length; i++) {
      final cloud = clouds[i];
      final float = math.sin(animation * math.pi + i * 0.5) * 12;
      
      _draw3DCloud(
        canvas,
        cloud.position + Offset(float, math.sin(animation * math.pi * 0.5 + i) * 3),
        cloud.size,
        cloud.opacity,
      );
    }
  }

  void _draw3DCloud(Canvas canvas, Offset center, double size, double opacity) {
    // Shadow layer (offset and darker)
    final shadowPaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: opacity * 0.15)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    const shadowOffset = Offset(4, 4);
    _drawCloudShape(canvas, center + shadowOffset, size, shadowPaint);
    
    // Main cloud (white with gradient feel)
    final mainPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.85)
      ..style = PaintingStyle.fill;
    
    _drawCloudShape(canvas, center, size, mainPaint);
    
    // Highlight layer (top portion, brighter)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: opacity * 0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center + Offset(-size * 0.2, -size * 0.3), size * 0.4, highlightPaint);
    canvas.drawCircle(center + Offset(size * 0.15, -size * 0.35), size * 0.35, highlightPaint);
  }
  
  void _drawCloudShape(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size, paint);
    canvas.drawCircle(center + Offset(-size * 0.7, size * 0.1), size * 0.75, paint);
    canvas.drawCircle(center + Offset(size * 0.7, size * 0.1), size * 0.75, paint);
    canvas.drawCircle(center + Offset(-size * 0.35, -size * 0.35), size * 0.65, paint);
    canvas.drawCircle(center + Offset(size * 0.35, -size * 0.35), size * 0.65, paint);
  }
  
  void _drawWaterFeatures(Canvas canvas, Size size) {
    final float = math.sin(animation * math.pi * 0.4) * 8;
    
    // Winding river/stream with depth
    final waterPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade300.withValues(alpha: 0.5),
          Colors.blue.shade400.withValues(alpha: 0.6),
          Colors.cyan.shade200.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    final waterPath = Path();
    waterPath.moveTo(0, size.height * 0.75);
    waterPath.quadraticBezierTo(
      size.width * 0.15 + float, size.height * 0.72,
      size.width * 0.3, size.height * 0.78,
    );
    waterPath.quadraticBezierTo(
      size.width * 0.5 + float, size.height * 0.74,
      size.width * 0.7, size.height * 0.8,
    );
    waterPath.quadraticBezierTo(
      size.width * 0.85 + float, size.height * 0.77,
      size.width, size.height * 0.79,
    );
    waterPath.lineTo(size.width, size.height * 0.85);
    waterPath.quadraticBezierTo(
      size.width * 0.85, size.height * 0.83,
      size.width * 0.7, size.height * 0.86,
    );
    waterPath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.8,
      size.width * 0.3, size.height * 0.84,
    );
    waterPath.quadraticBezierTo(
      size.width * 0.15, size.height * 0.78,
      0, size.height * 0.81,
    );
    waterPath.close();
    canvas.drawPath(waterPath, waterPaint);
    
    // Water edge highlights
    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final edgePath = Path();
    edgePath.moveTo(0, size.height * 0.75);
    edgePath.quadraticBezierTo(
      size.width * 0.15 + float, size.height * 0.72,
      size.width * 0.3, size.height * 0.78,
    );
    edgePath.quadraticBezierTo(
      size.width * 0.5 + float, size.height * 0.74,
      size.width * 0.7, size.height * 0.8,
    );
    edgePath.quadraticBezierTo(
      size.width * 0.85 + float, size.height * 0.77,
      size.width, size.height * 0.79,
    );
    canvas.drawPath(edgePath, edgePaint);
    
    // Water shimmer with more sparkle
    final shimmerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3 + math.sin(animation * math.pi * 3) * 0.2)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 8; i++) {
      final shimmerX = size.width * (0.1 + i * 0.11) + math.sin(animation * math.pi * 2 + i) * 12;
      final shimmerY = size.height * 0.77 + math.sin(animation * math.pi + i) * 4;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(shimmerX, shimmerY),
          width: 18 + math.sin(animation * math.pi * 2 + i) * 5,
          height: 6,
        ),
        shimmerPaint,
      );
    }
    
    // Water ripples
    final ripplePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    for (int i = 0; i < 4; i++) {
      final ripplePhase = (animation * 2 + i * 0.5) % 1;
      final rippleX = size.width * (0.2 + i * 0.2);
      final rippleY = size.height * 0.78;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(rippleX, rippleY),
          width: 20 * ripplePhase,
          height: 10 * ripplePhase,
        ),
        ripplePaint..color = Colors.white.withValues(alpha: 0.2 * (1 - ripplePhase)),
      );
    }
  }
  
  void _drawTrees(Canvas canvas, Size size) {
    final trees = [
      _TreeData(Offset(size.width * 0.08, size.height * 0.68), 35, Colors.green.shade700),
      _TreeData(Offset(size.width * 0.22, size.height * 0.58), 42, Colors.green.shade600),
      _TreeData(Offset(size.width * 0.35, size.height * 0.72), 38, Colors.green.shade700),
      _TreeData(Offset(size.width * 0.62, size.height * 0.55), 45, Colors.green.shade800),
      _TreeData(Offset(size.width * 0.78, size.height * 0.7), 40, Colors.green.shade700),
      _TreeData(Offset(size.width * 0.92, size.height * 0.62), 36, Colors.green.shade600),
    ];
    
    for (final tree in trees) {
      final sway = math.sin(animation * math.pi * 0.5) * 2;
      _drawTree(canvas, tree.position + Offset(sway, 0), tree.size, tree.color);
    }
  }
  
  void _drawTree(Canvas canvas, Offset position, double size, Color leafColor) {
    // Tree trunk
    final trunkPaint = Paint()
      ..color = Colors.brown.shade700
      ..style = PaintingStyle.fill;
    
    final trunkRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: position + Offset(0, size * 0.3),
        width: size * 0.15,
        height: size * 0.5,
      ),
      Radius.circular(size * 0.05),
    );
    canvas.drawRRect(trunkRect, trunkPaint);
    
    // Tree leaves (3 circles)
    final leafPaint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawCircle(position + Offset(2, 2), size * 0.4, shadowPaint);
    canvas.drawCircle(position, size * 0.4, leafPaint);
    canvas.drawCircle(position + Offset(-size * 0.2, -size * 0.15), size * 0.35, leafPaint);
    canvas.drawCircle(position + Offset(size * 0.2, -size * 0.15), size * 0.35, leafPaint);
    
    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position + Offset(-size * 0.15, -size * 0.2), size * 0.15, highlightPaint);
  }
  
  void _drawGrassPatches(Canvas canvas, Size size) {
    final patches = [
      Offset(size.width * 0.12, size.height * 0.73),
      Offset(size.width * 0.28, size.height * 0.65),
      Offset(size.width * 0.45, size.height * 0.78),
      Offset(size.width * 0.58, size.height * 0.61),
      Offset(size.width * 0.73, size.height * 0.75),
      Offset(size.width * 0.88, size.height * 0.68),
    ];
    
    for (int i = 0; i < patches.length; i++) {
      final sway = math.sin(animation * math.pi * 0.7 + i * 0.5) * 1.5;
      final center = patches[i] + Offset(sway, 0);
      
      // Draw grass blades
      for (int j = 0; j < 8; j++) {
        final angle = (j / 8) * math.pi * 2;
        final bladeHeight = 8 + math.sin(animation * math.pi + j) * 2;
        final bladeEnd = center + Offset(
          math.cos(angle) * 12,
          -bladeHeight + math.sin(angle) * 3,
        );
        
        final bladePath = Path()
          ..moveTo(center.dx, center.dy)
          ..quadraticBezierTo(
            center.dx + math.cos(angle) * 6,
            center.dy - bladeHeight * 0.5,
            bladeEnd.dx,
            bladeEnd.dy,
          );
        
        final bladePaint = Paint()
          ..color = Colors.green.shade400.withValues(alpha: 0.5 + j * 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        
        canvas.drawPath(bladePath, bladePaint);
      }
    }
  }
  
  void _drawBushes(Canvas canvas, Size size) {
    final bushes = [
      Offset(size.width * 0.05, size.height * 0.72),
      Offset(size.width * 0.18, size.height * 0.67),
      Offset(size.width * 0.32, size.height * 0.75),
      Offset(size.width * 0.55, size.height * 0.64),
      Offset(size.width * 0.68, size.height * 0.72),
      Offset(size.width * 0.82, size.height * 0.68),
      Offset(size.width * 0.95, size.height * 0.71),
    ];
    
    for (int i = 0; i < bushes.length; i++) {
      final sway = math.sin(animation * math.pi * 0.3 + i * 0.8) * 1;
      _drawBush(canvas, bushes[i] + Offset(sway, 0), 15.0 + (i % 3) * 5);
    }
  }
  
  void _drawBush(Canvas canvas, Offset position, double size) {
    final bushPaint = Paint()
      ..color = Colors.green.shade700.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    // Multiple overlapping circles for fluffy bush
    canvas.drawCircle(position, size, bushPaint);
    canvas.drawCircle(position + Offset(-size * 0.5, size * 0.2), size * 0.8, bushPaint);
    canvas.drawCircle(position + Offset(size * 0.5, size * 0.2), size * 0.8, bushPaint);
    canvas.drawCircle(position + Offset(0, -size * 0.4), size * 0.7, bushPaint);
    
    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.green.shade300.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position + Offset(-size * 0.3, -size * 0.3), size * 0.4, highlightPaint);
  }
  
  void _drawFlowers(Canvas canvas, Size size) {
    final flowers = [
      _FlowerData(Offset(size.width * 0.12, size.height * 0.74), Colors.pink, 6),
      _FlowerData(Offset(size.width * 0.16, size.height * 0.71), Colors.yellow, 5),
      _FlowerData(Offset(size.width * 0.29, size.height * 0.68), Colors.purple, 6),
      _FlowerData(Offset(size.width * 0.33, size.height * 0.76), Colors.red, 5),
      _FlowerData(Offset(size.width * 0.46, size.height * 0.79), Colors.orange, 6),
      _FlowerData(Offset(size.width * 0.59, size.height * 0.63), Colors.pink, 5),
      _FlowerData(Offset(size.width * 0.65, size.height * 0.73), Colors.yellow, 6),
      _FlowerData(Offset(size.width * 0.74, size.height * 0.76), Colors.purple, 5),
      _FlowerData(Offset(size.width * 0.83, size.height * 0.69), Colors.red, 6),
      _FlowerData(Offset(size.width * 0.89, size.height * 0.72), Colors.orange, 5),
    ];
    
    for (int i = 0; i < flowers.length; i++) {
      final bob = math.sin(animation * math.pi * 1.5 + i * 0.7) * 2;
      _drawFlower(canvas, flowers[i].position + Offset(0, bob), flowers[i].color, flowers[i].petalCount);
    }
  }
  
  void _drawFlower(Canvas canvas, Offset position, Color color, int petalCount) {
    // Stem
    final stemPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(position, position + const Offset(0, 12), stemPaint);
    
    // Petals
    final petalPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < petalCount; i++) {
      final angle = (i * 2 * math.pi / petalCount);
      final petalPos = position + Offset(
        math.cos(angle) * 4,
        math.sin(angle) * 4,
      );
      canvas.drawCircle(petalPos, 3, petalPaint);
    }
    
    // Center
    final centerPaint = Paint()
      ..color = Colors.yellow.shade700
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 2.5, centerPaint);
  }
  
  void _drawButterflies(Canvas canvas, Size size) {
    final butterflies = [
      Offset(size.width * 0.25, size.height * 0.35),
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.28),
    ];
    
    for (int i = 0; i < butterflies.length; i++) {
      final flyX = math.sin(animation * math.pi * 1.5 + i * 2) * 40;
      final flyY = math.sin(animation * math.pi * 2 + i) * 20;
      final position = butterflies[i] + Offset(flyX, flyY);
      
      _drawButterfly(canvas, position, animation + i * 0.5);
    }
  }
  
  void _drawButterfly(Canvas canvas, Offset position, double animPhase) {
    final wingFlap = math.sin(animPhase * math.pi * 12) * 0.3 + 0.7;
    
    // Body
    final bodyPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: position, width: 3, height: 8),
      bodyPaint,
    );
    
    // Left wings
    final leftWingPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.purple.shade300,
          Colors.pink.shade200,
          Colors.white.withValues(alpha: 0.8),
        ],
      ).createShader(Rect.fromCircle(center: position + Offset(-5 * wingFlap, -3), radius: 8));
    
    canvas.drawOval(
      Rect.fromCenter(
        center: position + Offset(-5 * wingFlap, -3),
        width: 8 * wingFlap,
        height: 10,
      ),
      leftWingPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: position + Offset(-4 * wingFlap, 3),
        width: 6 * wingFlap,
        height: 8,
      ),
      leftWingPaint,
    );
    
    // Right wings
    final rightWingPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.purple.shade300,
          Colors.pink.shade200,
          Colors.white.withValues(alpha: 0.8),
        ],
      ).createShader(Rect.fromCircle(center: position + Offset(5 * wingFlap, -3), radius: 8));
    
    canvas.drawOval(
      Rect.fromCenter(
        center: position + Offset(5 * wingFlap, -3),
        width: 8 * wingFlap,
        height: 10,
      ),
      rightWingPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: position + Offset(4 * wingFlap, 3),
        width: 6 * wingFlap,
        height: 8,
      ),
      rightWingPaint,
    );
  }
  
  void _drawBirds(Canvas canvas, Size size) {
    final birds = [
      Offset(size.width * 0.2, size.height * 0.18),
      Offset(size.width * 0.5, size.height * 0.22),
      Offset(size.width * 0.75, size.height * 0.13),
    ];
    
    for (int i = 0; i < birds.length; i++) {
      final flyOffset = math.sin(animation * math.pi * 2 + i * 1.5) * 30;
      final bobOffset = math.sin(animation * math.pi * 4 + i) * 5;
      final position = birds[i] + Offset(flyOffset, bobOffset);
      
      _drawBird(canvas, position, animation + i * 0.5);
    }
  }
  
  void _drawBird(Canvas canvas, Offset position, double animPhase) {
    final wingFlap = math.sin(animPhase * math.pi * 8);
    
    final birdPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    
    // Left wing
    final leftWing = Path()
      ..moveTo(position.dx, position.dy)
      ..quadraticBezierTo(
        position.dx - 8, position.dy - 6 * wingFlap,
        position.dx - 12, position.dy - 4 * wingFlap,
      );
    canvas.drawPath(leftWing, birdPaint);
    
    // Right wing
    final rightWing = Path()
      ..moveTo(position.dx, position.dy)
      ..quadraticBezierTo(
        position.dx + 8, position.dy - 6 * wingFlap,
        position.dx + 12, position.dy - 4 * wingFlap,
      );
    canvas.drawPath(rightWing, birdPaint);
  }
  
  void _drawSparkles(Canvas canvas, Size size) {
    final sparkles = [
      Offset(size.width * 0.15, size.height * 0.25),
      Offset(size.width * 0.4, size.height * 0.15),
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width * 0.9, size.height * 0.45),
      Offset(size.width * 0.2, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.75),
      Offset(size.width * 0.8, size.height * 0.65),
    ];
    
    for (int i = 0; i < sparkles.length; i++) {
      final twinkle = (math.sin(animation * math.pi * 2 + i * 0.8) + 1) / 2;
      final sparkleOpacity = 0.2 + twinkle * 0.5;
      final sparkleSize = 2 + twinkle * 3;
      
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: sparkleOpacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(sparkles[i], sparkleSize, paint);
      
      // Star shape for some sparkles
      if (i % 2 == 0) {
        _drawStar(canvas, sparkles[i], sparkleSize * 1.5, paint);
      }
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i * math.pi / 2) + animation * math.pi * 0.5;
      final outer = center + Offset(math.cos(angle) * size, math.sin(angle) * size);
      final inner = center + Offset(math.cos(angle + math.pi / 4) * size * 0.3, math.sin(angle + math.pi / 4) * size * 0.3);
      
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _EnhancedBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class _CloudData {
  final Offset position;
  final double size;
  final double opacity;
  
  _CloudData(this.position, this.size, this.opacity);
}

class _TreeData {
  final Offset position;
  final double size;
  final Color color;
  
  _TreeData(this.position, this.size, this.color);
}

class _FlowerData {
  final Offset position;
  final Color color;
  final int petalCount;
  
  _FlowerData(this.position, this.color, this.petalCount);
}
