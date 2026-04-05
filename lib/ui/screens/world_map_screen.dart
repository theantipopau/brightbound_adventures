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
import 'package:brightbound_adventures/ui/widgets/visual_effects/animated_cloud_background.dart';
import 'package:brightbound_adventures/ui/widgets/visual_effects/particle_background.dart';
import 'package:brightbound_adventures/ui/widgets/visual_effects/adventure_pattern_overlay.dart';
import 'package:brightbound_adventures/ui/widgets/animated_character.dart';
import 'package:brightbound_adventures/ui/widgets/juicy_button.dart';
import 'package:brightbound_adventures/ui/widgets/glowing_card.dart';
import 'package:brightbound_adventures/ui/widgets/animated_score_counter.dart';
import 'package:brightbound_adventures/ui/widgets/transitions.dart';
import 'package:brightbound_adventures/ui/screens/trophy_room_screen.dart';
import 'package:brightbound_adventures/ui/screens/daily_challenge_screen.dart';
import 'package:brightbound_adventures/ui/screens/mini_games_screen.dart';
import 'package:brightbound_adventures/ui/screens/settings_screen.dart';
import 'package:brightbound_adventures/ui/screens/parent_dashboard_screen.dart';
import 'package:brightbound_adventures/ui/screens/profile_stats_screen.dart';
import 'package:brightbound_adventures/ui/painters/shadow_painter.dart';
import 'package:brightbound_adventures/ui/painters/terrain_painter.dart';
import 'package:brightbound_adventures/ui/painters/path_painter.dart';

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
  bool _isCompactLayout = false;
  double _uiScale = 1.0;
  late AudioManager _audioManager;
  bool _audioSetupDone = false;

  // Avatar state
  int _currentZoneIndex = 0;
  int? _targetZoneIndex;
  bool _isMoving = false;

  // Isometric 3D state
  late Map<String, IsometricPosition> _zoneIsometricPositions;

  // Zone definitions with progression order - FULL MAP SPREAD
  final List<ZoneData> _zones = [
    const ZoneData(
      id: 'word-woods',
      name: 'Word Woods',
      emoji: '🌲',
      color: AppColors.wordWoodsColor,
      // Bottom left - starter zone
      position: Offset(0.15, 0.85),
      description: 'Master letters & reading!',
      order: 0,
      requiredStars: 0,
    ),
    const ZoneData(
      id: 'number-nebula',
      name: 'Number Nebula',
      emoji: '🌌',
      color: AppColors.numberNebulaColor,
      // Bottom right
      position: Offset(0.85, 0.80),
      description: 'Explore math & numbers!',
      order: 1,
      requiredStars: 3,
    ),
    const ZoneData(
      id: 'math-facts',
      name: 'Math Facts',
      emoji: '🔢',
      color: Color(0xFFFF6B6B),
      // Middle left
      position: Offset(0.20, 0.50),
      description: 'Master multiplication & addition!',
      order: 2,
      requiredStars: 6,
    ),
    const ZoneData(
      id: 'story-springs',
      name: 'Story Springs',
      emoji: '📖',
      color: AppColors.storyspringsColor,
      // Middle right
      position: Offset(0.80, 0.45),
      description: 'Create amazing stories!',
      order: 3,
      requiredStars: 10,
    ),
    const ZoneData(
      id: 'science-explorers',
      name: 'Science Explorers',
      emoji: '🔬',
      color: Color(0xFF4DB6AC), // Teal
      // Upper left
      position: Offset(0.18, 0.32),
      description: 'Discover the world!',
      order: 4,
      requiredStars: 15,
    ),
    const ZoneData(
      id: 'creative-corner',
      name: 'Creative Corner',
      emoji: '🎨',
      color: Color(0xFFFFB74D), // Orange
      // Upper right
      position: Offset(0.78, 0.28),
      description: 'Draw and make music!',
      order: 5,
      requiredStars: 20,
    ),
    const ZoneData(
      id: 'puzzle-peaks',
      name: 'Puzzle Peaks',
      emoji: '🧩',
      color: AppColors.puzzlePeaksColor,
      // Top centre-left
      position: Offset(0.38, 0.12),
      description: 'Solve tricky puzzles!',
      order: 6,
      requiredStars: 22,
    ),
    const ZoneData(
      id: 'adventure-arena',
      name: 'Adventure Arena',
      emoji: '🏆',
      color: AppColors.adventureArenaColor,
      // Top centre-right - final zone
      position: Offset(0.62, 0.10),
      description: 'Ultimate challenges!',
      order: 7,
      requiredStars: 28,
    ),
  ];

  // Zone elevation map (Z-height for true 3D)
  final Map<String, double> _zoneElevations = {
    'word-woods': 0.0,
    'number-nebula': 0.5,
    'math-facts': 0.3,
    'story-springs': 0.8,
    'science-explorers': 1.0,
    'creative-corner': 1.1,
    'puzzle-peaks': 1.3,
    'adventure-arena': 1.6,
  };

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initIsometricPositions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detectDevice();
    if (!_audioSetupDone) {
      _audioManager = Provider.of<AudioManager>(context, listen: false);
      _audioManager.playMenuMusic();
      _audioSetupDone = true;
    }
  }

  void _initIsometricPositions() {
    // Convert all zones to isometric grid positions with elevation
    _zoneIsometricPositions = {};
    for (final zone in _zones) {
      final basePos = WorldMapIsometricHelper.offsetToIsometric(zone.position);
      final elevation = _zoneElevations[zone.id] ?? 0.0;
      _zoneIsometricPositions[zone.id] = IsometricPosition(
        basePos.x,
        basePos.y,
        elevation,
      );
    }
  }

  void _detectDevice() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPhone = screenWidth < 600;
    if (isPhone != _isPhoneDevice) {
      setState(() {
        _isPhoneDevice = isPhone;
      });
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
    if (_audioSetupDone) {
      _audioManager.stopMusic();
    }
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
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedZoneIndex = (_selectedZoneIndex + 1) % _zones.length;
      });
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedZoneIndex =
            (_selectedZoneIndex - 1 + _zones.length) % _zones.length;
      });
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
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

  bool _isZoneUnlocked(int zoneIndex, int totalStars,
      [SkillProvider? skillProvider]) {
    if (totalStars < _zones[zoneIndex].requiredStars) return false;
    final group = _zones[zoneIndex].requiredSkillGroup;
    if (group == null || skillProvider == null) return true;
    return skillProvider
        .getSkillsByStrand(group)
        .any((s) => s.state == SkillState.mastered);
  }

  void _moveToZone(int targetIndex) {
    if (_isMoving) return;

    if (_selectedZoneIndex != targetIndex) {
      setState(() {
        _selectedZoneIndex = targetIndex;
      });
    }

    // If already at this zone, navigate directly without animation
    if (targetIndex == _currentZoneIndex) {
      debugPrint('Already at zone $targetIndex - navigating directly');
      Navigator.pushNamed(context, '/${_zones[targetIndex].id}');
      return;
    }

    debugPrint(
        'Moving avatar from zone $_currentZoneIndex to zone $targetIndex');
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
                        final shortest = constraints.biggest.shortestSide;
                        final isPortrait = constraints.maxHeight > constraints.maxWidth;
                        _isCompactLayout = constraints.maxWidth < 980;
                        
                        // Improved scaling for portrait phones
                        if (isPortrait) {
                          // Portrait: scale based on height, but keep it reasonable
                          _uiScale = (constraints.maxHeight / 800).clamp(0.70, 1.10);
                        } else {
                          // Landscape: scale based on shortest side
                          _uiScale = (shortest / 760).clamp(0.75, 1.20);
                        }

                        // Calculate avatar position for shadows
                        IsometricPosition? avatarIsoPos;
                        if (_isMoving && _targetZoneIndex != null) {
                          final currentZone = _zones[_currentZoneIndex];
                          final targetZone = _zones[_targetZoneIndex!];
                          final startIso =
                              _zoneIsometricPositions[currentZone.id]!;
                          final endIso =
                              _zoneIsometricPositions[targetZone.id]!;
                          double t = Curves.easeInOutCubic
                              .transform(_avatarMoveController.value);
                          avatarIsoPos = startIso.lerp(endIso, t);
                        } else {
                          final currentZone = _zones[_currentZoneIndex];
                          avatarIsoPos =
                              _zoneIsometricPositions[currentZone.id];
                        }

                        return Stack(
                          children: [
                            // Terrain patches showing biome regions under each zone
                            RepaintBoundary(
                              child: CustomPaint(
                                painter: TerrainPainter(zones: _zones),
                                size: Size(constraints.maxWidth,
                                    constraints.maxHeight),
                              ),
                            ),

                            // Shadows for 3D depth
                            RepaintBoundary(
                              child: CustomPaint(
                                painter: ShadowPainter(
                                  zones: _zones,
                                  avatarPosition: avatarIsoPos,
                                ),
                                size: Size(constraints.maxWidth,
                                    constraints.maxHeight),
                              ),
                            ),

                            // Animated paths between zones (optimized)
                            RepaintBoundary(
                              child: CustomPaint(
                                painter: PathPainter(
                                  zones: _zones,
                                  zoneScreenPositions: {
                                    for (final z in _zones)
                                      z.id:
                                          WorldMapIsometricHelper.gridToScreen(
                                        _zoneIsometricPositions[z.id]!,
                                        Size(constraints.maxWidth,
                                            constraints.maxHeight),
                                      ),
                                  },
                                  animation: _pathController,
                                  totalStars: totalStars,
                                ),
                                size: Size(constraints.maxWidth,
                                    constraints.maxHeight),
                              ),
                            ),

                            // Combined isometric render layer (Zones + Avatar)
                            ..._build3DMapLayer(
                                constraints, totalStars, skillProvider, avatar),

                            // Top HUD
                            _buildTopHUD(
                              avatar,
                              totalStars,
                              compact: _isCompactLayout,
                              uiScale: _uiScale,
                            ),

                            _buildStreakRiskBanner(
                              compact: _isCompactLayout,
                              uiScale: _uiScale,
                            ),

                            // Bottom quick actions
                            _buildBottomActions(
                              totalStars,
                              compact: _isCompactLayout,
                              uiScale: _uiScale,
                            ),

                            _buildQuickZoneRail(
                              totalStars,
                              compact: _isCompactLayout,
                              uiScale: _uiScale,
                            ),

                            _buildZoneSpotlightPanel(
                              totalStars,
                              skillProvider,
                              compact: _isCompactLayout,
                              uiScale: _uiScale,
                            ),

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
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/avatar-creator'),
              icon: const Icon(Icons.person_add),
              label: const Text('Get Started'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    final activeZoneColor = _resolveActiveZoneColor();

    return Stack(
      children: [
        // 1. Dynamic Animated Sky (New)
        const AnimatedCloudBackground(),

        // 2. Existing Detailed Background Painter (Ground details etc)
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return CustomPaint(
              painter:
                  _EnhancedBackgroundPainter(animation: _floatController.value),
              size: Size.infinite,
            );
          },
        ),

        // 3. Floating Atmosphere Particles (New)
        ParticleBackground(
          particles: [
            '✨',
            '🍃',
            '☁️',
            '⭐',
            if (activeZoneColor == AppColors.numberNebulaColor) '🪐',
            if (activeZoneColor == AppColors.wordWoodsColor) '🌿',
            if (activeZoneColor == AppColors.adventureArenaColor) '🏆',
          ],
          particleCount: _isCompactLayout ? 10 : 15,
          speedMultiplier: 0.3,
        ),

        // 4. Decorative map pattern overlay
        Positioned.fill(
          child: AdventurePatternOverlay(
            color: activeZoneColor,
            opacity: 0.08,
            tileSize: _isCompactLayout ? 56 : 68,
          ),
        ),

        // 5. Ambient radial tint for active zone identity
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.2, -0.2),
                  radius: 1.1,
                  colors: [
                    activeZoneColor.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _resolveActiveZoneColor() {
    final index = _targetZoneIndex ?? _selectedZoneIndex;
    if (index >= 0 && index < _zones.length) {
      return _zones[index].color;
    }
    return _zones[_currentZoneIndex].color;
  }

  double _zoneProgressFraction(int masteredSkills, int totalSkills) {
    if (totalSkills <= 0) return 0;
    return (masteredSkills / totalSkills).clamp(0, 1).toDouble();
  }

  String _zoneMoodText(ZoneData zone) {
    switch (zone.id) {
      case 'word-woods':
        return 'Calm forest trails with vocabulary quests';
      case 'number-nebula':
        return 'Cosmic routes with number missions';
      case 'math-facts':
        return 'Fast-paced drills with combo rewards';
      case 'story-springs':
        return 'Creative paths and storytelling prompts';
      case 'science-explorers':
        return 'Experiment tracks and discovery boosts';
      case 'creative-corner':
        return 'Art and rhythm activities';
      case 'puzzle-peaks':
        return 'Logic climbs and pattern challenges';
      case 'adventure-arena':
        return 'Boss-level mixed mastery challenges';
      default:
        return 'New adventures await here';
    }
  }

  List<String> _zoneFeatureTags(ZoneData zone) {
    switch (zone.id) {
      case 'word-woods':
        return const ['Phonics', 'Sight Words', 'Reading Trails'];
      case 'number-nebula':
        return const ['Counting', 'Patterns', 'Number Boosts'];
      case 'math-facts':
        return const ['Speed Rounds', 'Combos', 'Fact Mastery'];
      case 'story-springs':
        return const ['Story Seeds', 'Characters', 'Creative Quests'];
      case 'science-explorers':
        return const ['Experiments', 'Nature Lab', 'Discoveries'];
      case 'creative-corner':
        return const ['Drawing', 'Music', 'Maker Mode'];
      case 'puzzle-peaks':
        return const ['Logic', 'Shapes', 'Pattern Paths'];
      case 'adventure-arena':
        return const ['Boss Trials', 'Mixed Skills', 'Mastery Cups'];
      default:
        return const ['Adventure', 'Skills', 'Rewards'];
    }
  }

  List<String> _zoneFeatureIcons(ZoneData zone) {
    switch (zone.id) {
      case 'word-woods':
        return const ['🔤', '📚', '🍃'];
      case 'number-nebula':
        return const ['➕', '🌠', '🔢'];
      case 'math-facts':
        return const ['⚡', '🎯', '🧮'];
      case 'story-springs':
        return const ['✍️', '📖', '💭'];
      case 'science-explorers':
        return const ['🔬', '🧪', '🌍'];
      case 'creative-corner':
        return const ['🎨', '🎵', '✨'];
      case 'puzzle-peaks':
        return const ['🧩', '🗻', '♟️'];
      case 'adventure-arena':
        return const ['🏆', '⚔️', '🔥'];
      default:
        return const ['✨', '⭐', '🎯'];
    }
  }

  List<Widget> _build3DMapLayer(
    BoxConstraints constraints,
    int totalStars,
    SkillProvider skillProvider,
    Avatar avatar,
  ) {
    return [
      AnimatedBuilder(
        animation:
            Listenable.merge([_avatarMoveController, _entranceController]),
        builder: (context, child) {
          // 1. Calculate Avatar Isometric Position
          IsometricPosition avatarIsoPos;
          if (_isMoving && _targetZoneIndex != null) {
            final currentZone = _zones[_currentZoneIndex];
            final targetZone = _zones[_targetZoneIndex!];

            final startIso = _zoneIsometricPositions[currentZone.id]!;
            final endIso = _zoneIsometricPositions[targetZone.id]!;

            // Use 3D lerp logic
            // Curved path simulation:
            // t is linear progress (0->1)
            // We can just lerp linearly in grid space for depth sorting
            // But visual position might have arc

            double t =
                Curves.easeInOutCubic.transform(_avatarMoveController.value);
            avatarIsoPos = startIso.lerp(endIso, t);

            // Add artificial Z height for jump arc if needed for depth?
            // Actually depth = x+y-z. Higher Z = lower depth value?
            // Isometric engine says: depth => x + y - z;
            // If we jump up (increase Z), depth decreases (objects behind us might become in front?)
            // Usually jumping shouldn't change sort order significantly unless we jump OVER something.
            // Let's keep Z=0 for sorting purposes to avoid flickering.
          } else {
            final currentZone = _zones[_currentZoneIndex];
            avatarIsoPos = _zoneIsometricPositions[currentZone.id]!;
          }

          // 2. Prepare Render Items
          final List<dynamic> renderItems = [..._zones, avatar];

          // Helper to get depth position
          IsometricPosition getPos(dynamic item) {
            if (item is ZoneData) {
              return _zoneIsometricPositions[item.id]!;
            } else {
              return avatarIsoPos;
            }
          }

          // 3. Sort by Depth
          // We can use WorldMapIsometricHelper logic, leveraging engine
          // Manual sort here since helper expects generic list
          renderItems.sort((a, b) {
            final posA = getPos(a);
            final posB = getPos(b);
            // Higher depth value = closer to camera (drawn LAST)
            // Painter/Stack draws first items at bottom, last items on top.
            // So we want smallest depth first (background), largest depth last (foreground).
            // Engine.depth = x + y - z.
            // Small x,y (top-left of grid) = Background?
            // Let's check transformation:
            // screenY = (x+y) * tileHeight/2.
            // Larger (x+y) means larger Screen Y (down the screen).
            // Objects lower on screen are "closer".
            // So larger (x+y) should be drawn LAST.
            // Hence sort ascending by depth.
            return posA.depth.compareTo(posB.depth);
          });

          // 4. Build Widgets
          return Stack(
            children: renderItems.map((item) {
              if (item is ZoneData) {
                return _buildZoneItem(
                    item, constraints, totalStars, skillProvider);
              } else {
                return _buildAvatarItem(avatar, avatarIsoPos, constraints);
              }
            }).toList(),
          );
        },
      ),
    ];
  }

  Widget _buildZoneItem(ZoneData zone, BoxConstraints constraints,
      int totalStars, SkillProvider skillProvider) {
    final index = _zones.indexOf(zone);
    final isUnlocked = _isZoneUnlocked(index, totalStars, skillProvider);
    final isCurrentZone = _currentZoneIndex == index;
    final zoneStats = skillProvider.getZoneStats(zone.id.replaceAll('-', '_'));

    // Use isometric position
    final isoPos = _zoneIsometricPositions[zone.id]!;
    final screenPos = WorldMapIsometricHelper.gridToScreen(
      isoPos,
      Size(constraints.maxWidth, constraints.maxHeight),
    );

    // Animation calculations (reused from original)
    final delay = index * 0.15;
    final progress =
        ((_entranceController.value - delay) / 0.4).clamp(0.0, 1.0);

    // Atmospheric perspective: fade distant zones (higher Y = further back)
    final atmosphericOpacity =
        1.0 - (zone.position.dy * 0.3); // 0-30% fade for depth
    final finalOpacity = progress * atmosphericOpacity;

    final visualScale = (_isCompactLayout ? 0.84 : 1.0) * _uiScale;
    
    // Adaptive zone sizing for very small screens
    double baseWidth = 160.0;
    double baseHeight = 180.0;
    if (constraints.maxWidth < 320) {
      baseWidth = 135.0;
      baseHeight = 150.0;
    } else if (constraints.maxWidth < 400) {
      baseWidth = 145.0;
      baseHeight = 165.0;
    }
    
    final sideInset = constraints.maxWidth < 300 ? 2.0 : (constraints.maxWidth < 340 ? 4.0 : 10.0);
    final minTopInset = constraints.maxHeight < 600 ? 30.0 : (constraints.maxHeight < 620 ? 40.0 : 52.0);
    final maxBottomInset = constraints.maxHeight < 600 ? 70.0 : (constraints.maxHeight < 620 ? 88.0 : 110.0);
    // Use layout dimensions (baseWidth/baseHeight) for clamping — the island widget
    // always claims that much layout space regardless of the visual Transform.scale.
    final left = (screenPos.dx - (baseWidth / 2))
      .clamp(sideInset, constraints.maxWidth - baseWidth - sideInset)
      .toDouble();
    final top =
      (screenPos.dy - (baseHeight * 0.55) + (1 - progress) * 50).clamp(
        minTopInset, constraints.maxHeight - baseHeight - maxBottomInset)
        .toDouble();

    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: finalOpacity,
        child: _ZoneIsland(
          zone: zone,
          isUnlocked: isUnlocked,
          isCurrentZone: isCurrentZone,
          isSelected: _selectedZoneIndex == index,
          starsEarned: zoneStats.masteredSkills,
          totalSkills: zoneStats.totalSkills,
          assetIcons: _zoneFeatureIcons(zone),
          floatAnimation: _floatController,
            visualScale: visualScale,
          onTap: isUnlocked
              ? () {
                  setState(() {
                    _selectedZoneIndex = index;
                  });
                  debugPrint(
                      'Tapped zone ${zone.name} - moving to index $index');
                  _moveToZone(index);
                }
              : () {
                  setState(() {
                    _selectedZoneIndex = index;
                  });
                  debugPrint('Tapped locked zone ${zone.name}');
                  _showLockedDialog(zone, totalStars);
                },
        ),
      ),
    );
  }

  Widget _buildAvatarItem(
      Avatar avatar, IsometricPosition isoPos, BoxConstraints constraints) {
    final screenPos = WorldMapIsometricHelper.gridToScreen(
      isoPos,
      Size(constraints.maxWidth, constraints.maxHeight),
    );

    // Add jump arc if moving
    double arcHeight = 0;
    if (_isMoving) {
      double t = Curves.easeInOutCubic.transform(_avatarMoveController.value);
      arcHeight = -40 * math.sin(t * math.pi);
    }

    return Positioned(
      left: screenPos.dx - 35,
      top: screenPos.dy - 70 + arcHeight,
      child: IgnorePointer(
        ignoring: false,
        child: _build3DAvatar(avatar, _isMoving),
      ),
    );
  }

  Widget _build3DAvatar(Avatar avatar, bool isMoving) {
    // Scale avatar down slightly on higher-elevation zones for depth perception.
    // Elevation range 0.0 (Word Woods) → 1.6 (Adventure Arena).
    final double destElevation = _isMoving && _targetZoneIndex != null
        ? (_zoneElevations[_zones[_targetZoneIndex!].id] ?? 0.0)
        : (_zoneElevations[_zones[_currentZoneIndex].id] ?? 0.0);
    // 6% shrink per elevation unit, max 30%
    final double elevScale = 1.0 - (destElevation * 0.065).clamp(0.0, 0.30);
    // Slight opacity drop for depth fog
    final double elevOpacity = 1.0 - (destElevation * 0.04).clamp(0.0, 0.20);

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final bounce =
            isMoving ? 0.0 : math.sin(_floatController.value * math.pi) * 3;

        return GestureDetector(
          onTap: () => _showAvatarInfo(context, avatar),
          child: Opacity(
            opacity: elevOpacity,
            child: Transform.scale(
              scale: elevScale,
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
            offset: Offset(0, bounce),
            child: SizedBox(
              width: 85,
              height: 105,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Character with enhanced container
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.2),
                          AppColors.secondary.withValues(alpha: 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedCharacter(
                          character: avatar.baseCharacter,
                          skinColor: avatar.skinColor,
                          size: 60,
                          animation: isMoving
                              ? CharacterAnimation.walking
                              : CharacterAnimation.idle,
                          showParticles: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Enhanced name tag
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 72),
                      child: Text(
                        avatar.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Level badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      'Lv.${avatar.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopHUD(Avatar avatar, int totalStars,
      {required bool compact, required double uiScale}) {
    final streakService = Provider.of<StreakService>(context);
    final hudButtonSize = compact ? 36.0 : 40.0;
    final hudIconSize = compact ? 20.0 : 22.0;
    final hudButtonGap = compact ? 6.0 : 8.0;
    final hudRightMargin = compact ? 8.0 : 12.0;

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Transform.scale(
        alignment: Alignment.topCenter,
        scale: uiScale,
        child: Row(
          children: [
            // Logo & Title
            GlowingCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.primary,
              onTap: () => _showAppInfoDialog(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, color: Colors.white, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'BrightBound',
                    style: AppTypography.displaySmall.copyWith(
                      fontSize: 18,
                      letterSpacing: 0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Settings & Parent access
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'My Profile',
                  child: Semantics(
                    button: true,
                    label: 'My Profile',
                    child: GestureDetector(
                      onTap: () => _showProfileStats(),
                      child: Container(
                        width: hudButtonSize,
                        height: hudButtonSize,
                        margin: EdgeInsets.only(right: hudButtonGap),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.sm(AppColors.primary),
                        ),
                        child: Icon(Icons.person_rounded,
                            size: hudIconSize, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Settings',
                  child: Semantics(
                    button: true,
                    label: 'Settings',
                    child: GestureDetector(
                      onTap: () => _showSettings(),
                      child: Container(
                        width: hudButtonSize,
                        height: hudButtonSize,
                        margin: EdgeInsets.only(right: hudButtonGap),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.sm(AppColors.primary),
                        ),
                        child: Icon(Icons.settings_rounded,
                            size: compact ? 18 : 20,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Parent Dashboard',
                  child: Semantics(
                    button: true,
                    label: 'Parent Dashboard',
                    child: GestureDetector(
                      onTap: () => _showParentDashboard(),
                      child: Container(
                        width: hudButtonSize,
                        height: hudButtonSize,
                        margin: EdgeInsets.only(right: hudRightMargin),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.sm(Colors.indigo),
                        ),
                        child: Icon(Icons.supervised_user_circle_rounded,
                            size: hudIconSize, color: Colors.indigo),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Stats
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: AnimatedScoreCounter(
                    key: ValueKey<int>(totalStars),
                    value: totalStars,
                    label: 'Stars',
                    emoji: '⭐',
                    color: AppColors.reward,
                  ),
                ),
                const SizedBox(width: 12),
                if (streakService.currentStreak > 0) ...[
                  AnimatedScoreCounter(
                    value: streakService.currentStreak,
                    label: 'Days',
                    emoji: '🔥',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                ],

                // Daily Challenge badge
                Consumer<DailyChallengeService>(
                  builder: (context, challengeSvc, _) {
                    final completed = challengeSvc.todaysCompletionCount;
                    final total = challengeSvc.todaysChallenges.length;
                    return Tooltip(
                      message: 'Daily Challenges',
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          FadeSlidePageRoute(page: const DailyChallengeScreen()),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: completed == total && total > 0
                                ? Colors.amber.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: completed == total && total > 0
                                  ? Colors.amber
                                  : Colors.blueAccent.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                            boxShadow: AppShadows.sm(Colors.blueAccent),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                completed == total && total > 0 ? '🏆' : '🎯',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$completed/$total',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: completed == total && total > 0
                                      ? Colors.amber[800]
                                      : Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Avatar/Profile Circle
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/avatar-creator'),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.md(AppColors.primary),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(int.parse(avatar.skinColor.replaceAll('#', '0xFF'))),
                      child: Text(
                        _getCharacterEmoji(avatar.baseCharacter),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakRiskBanner(
      {required bool compact, required double uiScale}) {
    final streakService = context.watch<StreakService>();
    final now = DateTime.now();
    final isAtRisk = now.hour >= 17 &&
        streakService.currentStreak > 0 &&
        !streakService.playedToday;

    if (!isAtRisk) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: compact ? 78 : 88,
      left: 16,
      right: 16,
      child: Transform.scale(
        alignment: Alignment.topCenter,
        scale: uiScale,
        child: Semantics(
          container: true,
          label:
              'Streak at risk warning. Play today to keep your streak alive.',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange.withValues(alpha: 0.95),
                  Colors.orange.withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: AppShadows.md(Colors.deepOrange),
            ),
            child: Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Last chance today to keep your 🔥 ${streakService.currentStreak}-day streak!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.1,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(int totalStars,
      {required bool compact, required double uiScale}) {
    final isNarrow = MediaQuery.of(context).size.width < 760;

    final actionsRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        JuicyButton(
          label: 'Daily\nChallenge',
          emoji: '🎯',
          width: 160,
          height: 72,
          color: Colors.orange,
          onPressed: () => _showDailyChallenges(),
          shimmer: true,
        ),
        const SizedBox(width: 16),
        JuicyButton(
          label: 'Mini\nGames',
          emoji: '🎮',
          width: 160,
          height: 72,
          color: AppColors.secondary,
          onPressed: () => _showMiniGamesMenu(),
        ),
        const SizedBox(width: 16),
        JuicyButton(
          label: 'My\nAchievements',
          emoji: '🏆',
          width: 180,
          height: 72,
          color: AppColors.reward,
          onPressed: () => _showAchievements(),
        ),
      ],
    );

    return Positioned(
      bottom: compact ? 24 : 32,
      left: 16,
      right: 16,
      child: Transform.scale(
        alignment: Alignment.bottomCenter,
        scale: uiScale,
        child: isNarrow
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: actionsRow,
                ),
              )
            : actionsRow,
      ),
    );
  }

  Widget _buildQuickZoneRail(int totalStars,
      {required bool compact, required double uiScale}) {
    return Positioned(
      bottom: compact ? 178 : 120,
      left: 16,
      right: 16,
      height: 56,
      child: Transform.scale(
        alignment: Alignment.bottomCenter,
        scale: uiScale,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_zones.length, (index) {
              final zone = _zones[index];
              final isUnlocked = _isZoneUnlocked(index, totalStars);
              final isSelected = _selectedZoneIndex == index;
              final isCurrent = _currentZoneIndex == index;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label:
                      '${zone.name}, ${isUnlocked ? 'unlocked' : 'locked'}, requires ${zone.requiredStars} stars',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() {
                          _selectedZoneIndex = index;
                        });
                        if (isUnlocked) {
                          _moveToZone(index);
                        } else {
                          _showLockedDialog(zone, totalStars);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? zone.color.withValues(alpha: 0.95)
                              : (isCurrent
                                  ? zone.color.withValues(alpha: 0.18)
                                  : Colors.white.withValues(alpha: 0.92)),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : (isCurrent
                                    ? zone.color.withValues(alpha: 0.65)
                                    : zone.color.withValues(alpha: 0.35)),
                            width: isSelected ? 2.5 : (isCurrent ? 2 : 1.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: zone.color.withValues(
                                  alpha: isSelected
                                      ? 0.35
                                      : (isCurrent ? 0.22 : 0.12)),
                              blurRadius: isSelected ? 14 : (isCurrent ? 11 : 8),
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(zone.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              zone.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isUnlocked ? Icons.lock_open : Icons.lock,
                              size: 14,
                              color: isSelected
                                  ? Colors.white
                                  : (isUnlocked ? Colors.green : Colors.red),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : zone.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildZoneSpotlightPanel(
    int totalStars,
    SkillProvider skillProvider, {
    required bool compact,
    required double uiScale,
  }) {
    final selected = _zones[_selectedZoneIndex];
    final isUnlocked = _isZoneUnlocked(_selectedZoneIndex, totalStars);
    final stats = skillProvider.getZoneStats(selected.id.replaceAll('-', '_'));
    final progress =
        _zoneProgressFraction(stats.masteredSkills, stats.totalSkills);

    // Position the card on the OPPOSITE side from the selected zone so it never
    // covers the zone whose info it is showing, nor the nearby zones on that side.
    final isRightSideZone = selected.position.dx >= 0.5;
    return Positioned(
      top: compact ? 82 : 96,
      left: isRightSideZone ? 16 : null,
      right: isRightSideZone ? null : 16,
      child: Transform.scale(
        alignment: isRightSideZone ? Alignment.topLeft : Alignment.topRight,
        scale: uiScale,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: compact ? 220 : 270),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: selected.color.withValues(alpha: 0.35), width: 2),
              boxShadow: [
                BoxShadow(
                  color: selected.color.withValues(alpha: 0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Zone header with coloured gradient banner
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        selected.color,
                        selected.color.withValues(alpha: 0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      // Emoji in circle
                      Container(
                        width: compact ? 36 : 44,
                        height: compact ? 36 : 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            selected.emoji,
                            style: TextStyle(fontSize: compact ? 20 : 26),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selected.name,
                              style: TextStyle(
                                fontSize: compact ? 13 : 15,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            if (isUnlocked)
                              Row(
                                children: List.generate(3, (i) {
                                  final maxPer = stats.totalSkills > 0
                                      ? stats.totalSkills / 3
                                      : 1;
                                  final filled = i <
                                      (stats.masteredSkills / maxPer).ceil();
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 2),
                                    child: Icon(
                                      filled
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 12,
                                      color: Colors.amber.shade200,
                                    ),
                                  );
                                }),
                              ),
                          ],
                        ),
                      ),
                      if (!isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock,
                                  size: 10, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                '${selected.requiredStars}⭐',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _zoneMoodText(selected),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: progress,
                    backgroundColor: Colors.blueGrey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(selected.color),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mastered ${stats.masteredSkills}/${stats.totalSkills} skills',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blueGrey.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_zoneFeatureIcons(selected).length,
                      (index) {
                    final icon = _zoneFeatureIcons(selected)[index];
                    return AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, _) {
                        final bob =
                            math.sin((_floatController.value * math.pi * 2) + index) *
                                2;
                        return Transform.translate(
                          offset: Offset(0, bob),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: selected.color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected.color.withValues(alpha: 0.30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: selected.color.withValues(alpha: 0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(icon, style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _zoneFeatureTags(selected)
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selected.color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: selected.color.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: selected.color,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isMoving
                        ? null
                        : () {
                            if (isUnlocked) {
                              _moveToZone(_selectedZoneIndex);
                            } else {
                              _showLockedDialog(selected, totalStars);
                            }
                          },
                    icon: Icon(isUnlocked ? Icons.rocket_launch : Icons.lock),
                    label: Text(
                      isUnlocked
                          ? (_currentZoneIndex == _selectedZoneIndex
                              ? 'Enter Zone'
                              : 'Travel Here')
                          : 'Need ${selected.requiredStars}⭐',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      minimumSize: const Size.fromHeight(48),
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

  void _showLockedDialog(ZoneData zone, int totalStars) {
    final starsNeeded = zone.requiredStars - totalStars;
    final progress =
        zone.requiredStars <= 0 ? 1.0 : (totalStars / zone.requiredStars).clamp(0.0, 1.0);

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
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(zone.color),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$totalStars / ${zone.requiredStars} stars collected',
              style: TextStyle(
                color: Colors.blueGrey.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0.1)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Version 2.0.0 Alpha',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created with ❤️ by Matt Hurley',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Made with ❤️ for kids who love learning',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Connect With Us',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              // Links
              _buildLinkTile(
                  '🌐', 'Developer Website', 'https://matthurley.dev'),
              const SizedBox(height: 8),
              _buildLinkTile(
                  '☕', 'Buy Us a Coffee', 'https://ko-fi.com/theantipopau'),
              const SizedBox(height: 8),
              _buildLinkTile(
                  '💬', 'Community Forum', 'https://forum.playbrightbound.com'),
              const SizedBox(height: 8),
              _buildLinkTile('🐛', 'Report a Bug',
                  'https://github.com/theantipopau/brightbound_adventures/issues'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.pink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.pink.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Text('💖', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your support helps us make learning fun for kids everywhere!',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
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

  void _showProfileStats() {
    Navigator.push(
      context,
      FadeSlidePageRoute(page: const ProfileStatsScreen()),
    );
  }

  void _showSettings() {
    Navigator.push(
      context,
      FadeSlidePageRoute(page: const SettingsScreen()),
    );
  }

  void _showParentDashboard() {
    Navigator.push(
      context,
      FadeSlidePageRoute(page: const ParentDashboardScreen()),
    );
  }

  void _showMiniGamesMenu() {    Navigator.push(
      context,
      FadeSlidePageRoute(
        page: const MiniGamesScreen(),
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
                _buildStatChip(
                    '⚡', '${avatar.experiencePoints} XP', Colors.purple),
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

  void _showDailyChallenges() {
    Navigator.push(
      context,
      FadeSlidePageRoute(
        page: const DailyChallengeScreen(),
      ),
    );
  }

  void _showAchievements() {
    Navigator.push(
      context,
      FadeSlidePageRoute(
        page: const TrophyRoomScreen(),
      ),
    );
  }

  String _getCharacterEmoji(String character) {
    switch (character.toLowerCase()) {
      case 'fox':
        return '🦊';
      case 'deer':
        return '🦌';
      case 'rabbit':
      case 'bunny':
        return '🐰';
      case 'bear':
        return '🐻';
      case 'owl':
        return '🦉';
      case 'cat':
        return '🐱';
      case 'penguin':
        return '🐧';
      case 'koala':
        return '🐨';
      case 'panda':
        return '🐼';
      case 'otter':
        return '🦦';
      case 'wolf':
        return '🐺';
      case 'tiger':
        return '🐯';
      default:
        return '🦊';
    }
  }

  Widget _buildKeyboardHint() {
    // Hide keyboard hints on phones - they don't have physical keyboards
    if (_isPhoneDevice) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 246,
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

/// Zone island widget with 3D floating effect
class _ZoneIsland extends StatefulWidget {
  final ZoneData zone;
  final bool isUnlocked;
  final bool isCurrentZone;
  final bool isSelected;
  final int starsEarned;
  final int totalSkills;
  final List<String> assetIcons;
  final Animation<double> floatAnimation;
  final double visualScale;
  final VoidCallback onTap;

  const _ZoneIsland({
    required this.zone,
    required this.isUnlocked,
    required this.isCurrentZone,
    required this.isSelected,
    required this.starsEarned,
    required this.totalSkills,
    required this.assetIcons,
    required this.floatAnimation,
    this.visualScale = 1.0,
    required this.onTap,
  });

  @override
  State<_ZoneIsland> createState() => _ZoneIslandState();
}

class _ZoneIslandState extends State<_ZoneIsland> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.floatAnimation,
      builder: (context, child) {
        final float = math.sin(
                widget.floatAnimation.value * math.pi + widget.zone.order) *
            8; // Increased float for more dynamics
        final selectionPulse = widget.isSelected
            ? 1.0 + (math.sin(widget.floatAnimation.value * math.pi * 2) * 0.03)
            : 1.0;

        return Transform.translate(
          offset: Offset(0, float),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: Semantics(
              button: true,
              selected: widget.isSelected,
              label:
                  '${widget.zone.name}, ${widget.isUnlocked ? 'unlocked' : 'locked'}, ${widget.starsEarned} of ${widget.totalSkills} skills mastered',
              hint: widget.isUnlocked
                  ? 'Double tap to travel to this zone'
                  : 'Earn more stars to unlock this zone',
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: widget.onTap,
                  onLongPress: widget.onTap,
                  splashColor: widget.zone.color.withValues(alpha: 0.3),
                  highlightColor: widget.zone.color.withValues(alpha: 0.1),
                  child: Transform.scale(
                scale: widget.visualScale * selectionPulse,
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Throbbing focus halo for keyboard navigation
                    if (widget.isSelected)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: widget.floatAnimation,
                          builder: (context, _) {
                            final pulse = 0.6 + (math.sin(widget.floatAnimation.value * math.pi * 4) * 0.4);
                            return Container(
                              margin: EdgeInsets.all(-(16 * pulse)),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: pulse * 0.6),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.zone.color.withValues(alpha: pulse * 0.4),
                                    blurRadius: 20 * pulse,
                                    spreadRadius: 8 * pulse,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    // Expanding pulse ring for the zone where the avatar currently stands
                    if (widget.isCurrentZone)
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: widget.floatAnimation,
                          builder: (_, __) {
                            // Two rings offset by half a cycle create a continuous wave
                            final t1 = widget.floatAnimation.value;
                            final t2 = (widget.floatAnimation.value + 0.5) % 1.0;
                            return Stack(children: [
                              _PulseRing(
                                  progress: t1, color: widget.zone.color),
                              _PulseRing(
                                  progress: t2, color: widget.zone.color),
                            ]);
                          },
                        ),
                      ),
                    // Main island container
                    Container(
                    width: 160,
                    height: 180,
                    decoration: (widget.isSelected || _isHovered)
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white,
                            width: 5,
                          ),
                          boxShadow: [
                            // Primary glow
                            BoxShadow(
                              color: widget.zone.color
                                  .withValues(alpha: _isHovered ? 1.0 : 0.8),
                              blurRadius: widget.isSelected
                                ? 50
                                : (_isHovered ? 45 : 30),
                              spreadRadius: widget.isSelected
                                ? 14
                                : (_isHovered ? 12 : 8),
                            ),
                            // Secondary glow
                            BoxShadow(
                              color: widget.zone.color.withValues(alpha: 0.3),
                              blurRadius: _isHovered ? 60 : 40,
                              spreadRadius: _isHovered ? 20 : 12,
                            ),
                          ],
                        )
                      : null,
                    child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (widget.isUnlocked)
                      ...List.generate(widget.assetIcons.length, (index) {
                        final offsets = [
                          const Offset(-44, -28),
                          const Offset(42, -12),
                          const Offset(0, 32),
                        ];
                        final offset = offsets[index % offsets.length];
                        return Positioned(
                          left: 80 + offset.dx,
                          top: 70 + offset.dy,
                          child: Transform.translate(
                            offset: Offset(
                              math.sin(widget.floatAnimation.value * math.pi * 2 + index) * 3,
                              math.cos(widget.floatAnimation.value * math.pi * 2 + index) * 2,
                            ),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.zone.color.withValues(alpha: 0.4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.zone.color.withValues(alpha: 0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.assetIcons[index],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),

                    // Enhanced island shadow with depth
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 120,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.35),
                              Colors.black.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                    ),

                    // Island base with better 3D effect
                    Positioned(
                      bottom: 20,
                      child: Container(
                        width: 130,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              widget.isUnlocked
                                  ? widget.zone.color.withValues(alpha: 0.8)
                                  : Colors.grey.withValues(alpha: 0.6),
                              widget.isUnlocked
                                  ? widget.zone.color.withValues(alpha: 0.5)
                                  : Colors.grey.withValues(alpha: 0.4),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(60),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Animated progress ring surrounding island body
                    if (widget.isUnlocked)
                      Positioned(
                        bottom: 27,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: SizedBox(
                            width: 146,
                            height: 131,
                            child: AnimatedBuilder(
                              animation: widget.floatAnimation,
                              builder: (context, _) => CustomPaint(
                                painter: _ZoneProgressRingPainter(
                                  progress: widget.totalSkills > 0
                                      ? (widget.starsEarned /
                                              widget.totalSkills)
                                          .clamp(0.0, 1.0)
                                      : 0.0,
                                  color: widget.zone.color,
                                  animationValue: widget.floatAnimation.value,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Main island body with glow
                    Positioned(
                      bottom: 35,
                      child: Container(
                        width: 130,
                        height: 115,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0, -0.4),
                            colors: widget.isUnlocked
                                ? [
                                    widget.zone.color.withValues(alpha: 1.0),
                                    widget.zone.color.withValues(alpha: 0.95),
                                    widget.zone.color.withValues(alpha: 0.85),
                                  ]
                                : [
                                    Colors.grey.shade400,
                                    Colors.grey.shade600,
                                    Colors.grey.shade700,
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: widget.isCurrentZone
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.7),
                            width: widget.isCurrentZone ? 6 : 3.5,
                          ),
                          boxShadow: [
                            // Inner glow
                            BoxShadow(
                              color: (widget.isUnlocked
                                      ? widget.zone.color
                                      : Colors.grey)
                                  .withValues(alpha: 0.7),
                              blurRadius: widget.isCurrentZone ? 35 : 20,
                              spreadRadius: widget.isCurrentZone ? 8 : 4,
                            ),
                            // Outer shadow for depth
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ColorFiltered(
                          colorFilter: widget.isUnlocked
                              ? const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.srcOver,
                                )
                              : const ColorFilter.matrix(<double>[
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0, 0, 0, 1, 0,
                                ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Stack(
                              children: [
                              // Shimmer effect for unlocked zones - enhanced
                              if (widget.isUnlocked)
                                Positioned.fill(
                                  child: AnimatedBuilder(
                                    animation: widget.floatAnimation,
                                    builder: (context, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white
                                                  .withValues(alpha: 0.0),
                                              Colors.white
                                                  .withValues(alpha: 0.2),
                                              Colors.white
                                                  .withValues(alpha: 0.0),
                                            ],
                                            stops: [
                                              widget.floatAnimation.value - 0.3,
                                              widget.floatAnimation.value,
                                              widget.floatAnimation.value + 0.3,
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              // Content - centered both horizontally and vertically
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    // Emoji or lock with bounce animation
                                    AnimatedBuilder(
                                      animation: widget.floatAnimation,
                                      builder: (context, _) {
                                        final scale = 0.95 +
                                            math.sin(widget.floatAnimation
                                                    .value *
                                                3.14159) *
                                                0.08;
                                        return Transform.scale(
                                          scale: scale,
                                          child: Hero(
                                            tag:
                                                'zone_icon_${widget.zone.id}',
                                            child: Text(
                                              widget.isUnlocked
                                                  ? widget.zone.emoji
                                                  : '🔒',
                                              style: TextStyle(
                                                fontSize: widget.isUnlocked
                                                    ? 44
                                                    : 32,
                                                decoration: TextDecoration
                                                    .none, // Essential for Hero text flight
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                      const SizedBox(height: 6),
                                    // Zone name – full name with auto-scale
                                    SizedBox(
                                      width: 110,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          widget.zone.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.3,
                                            shadows: [
                                              Shadow(
                                                color: Color(0x99000000),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Stars progress - only show if unlocked
                                      if (widget.isUnlocked)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(3, (i) {
                                            // Safely calculate stars - avoid division by zero
                                            final maxStarsPerSection =
                                                widget.totalSkills > 0
                                                    ? widget.totalSkills / 3
                                                    : 1;
                                            final filled = i <
                                                (widget.starsEarned /
                                                        maxStarsPerSection)
                                                    .ceil();
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 2),
                                              child: Icon(
                                                filled
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                size: 14,
                                                color: Colors.amber.shade300,
                                              ),
                                            );
                                            }),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (widget.isUnlocked)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.amber.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.amber.shade400,
                            ),
                          ),
                          child: Text(
                            '⭐ ${widget.starsEarned}/${widget.totalSkills}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                    // Current zone indicator - enhanced
                    if (widget.isCurrentZone)
                      Positioned(
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.amber.shade100,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Text(
                            '📍 HERE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),

                    // Locked indicator - enhanced
                    if (!widget.isUnlocked)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: Colors.black.withValues(alpha: 0.22),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                '${widget.zone.requiredStars}⭐ to unlock',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (!widget.isUnlocked)
                      Positioned(
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Text(
                            '🔒',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                  ],
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PULSE RING — expanding translucent ring that emanates from a zone island when
// the avatar is currently standing there.
// ─────────────────────────────────────────────────────────────────────────────

/// Stateless helper that draws a single ring expanding from 100% → 160% and
/// fading 0.4 → 0.0 as `progress` goes from 0 → 1.
class _PulseRing extends StatelessWidget {
  final double progress;
  final Color color;

  const _PulseRing({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    final alpha = (0.55 * (1.0 - progress)).clamp(0.0, 1.0);
    if (alpha <= 0) return const SizedBox.shrink();
    return CustomPaint(
      painter: _PulseRingPainter(progress: progress, color: color),
    );
  }
}

class _PulseRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _PulseRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Ring expands from diagonal/2 (= outer edge of island) outward by 60%
    final baseR = math.sqrt(size.width * size.width + size.height * size.height) / 2;
    final radius = baseR * (1.0 + progress * 0.65);
    final alpha = (0.55 * (1.0 - progress)).clamp(0.0, 1.0);
    final strokeW = math.max(1.0, 3.5 * (1.0 - progress));

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );
  }

  @override
  bool shouldRepaint(_PulseRingPainter old) =>
      old.progress != progress || old.color != color;
}

/// Enhanced 3D background painter with parallax layers
class _EnhancedBackgroundPainter extends CustomPainter {
  final double animation;

  _EnhancedBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 0: Sky gradient with sun/moon
    _drawSky(canvas, size);

    // Layer 0b: Rainbow arc
    _drawRainbow(canvas, size);

    // Layer 0c: Aurora glow bands
    _drawAurora(canvas, size);

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
      final start =
          sunPosition + Offset(math.cos(angle) * 35, math.sin(angle) * 35);
      final end =
          sunPosition + Offset(math.cos(angle) * 50, math.sin(angle) * 50);
      canvas.drawLine(start, end, rayPaint);
    }

    // Wide atmospheric sun halo for added warmth
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.yellow.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: sunPosition, radius: 120));
    canvas.drawCircle(sunPosition, 120, haloPaint);
  }

  void _drawRainbow(Canvas canvas, Size size) {
    // Gentle rainbow arc sitting just above the horizon
    final cx = size.width * 0.38;
    final cy = size.height * 0.55;
    final baseRadius = size.width * 0.38;

    final rainbowColors = [
      Colors.red.withValues(alpha: 0.18),
      Colors.orange.withValues(alpha: 0.18),
      Colors.yellow.withValues(alpha: 0.18),
      Colors.green.withValues(alpha: 0.18),
      Colors.blue.withValues(alpha: 0.18),
      Colors.indigo.withValues(alpha: 0.16),
      Colors.purple.withValues(alpha: 0.14),
    ];

    for (int i = 0; i < rainbowColors.length; i++) {
      final r = baseRadius - i * 6.0;
      if (r <= 0) continue;
      final paint = Paint()
        ..color = rainbowColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, cy), width: r * 2, height: r * 2),
        math.pi,
        math.pi,
        false,
        paint,
      );
    }
  }

  void _drawAurora(Canvas canvas, Size size) {
    // Shimmering aurora bands near the top of the sky
    final auroraAlpha =
        0.07 + math.sin(animation * math.pi * 1.5) * 0.04; // gentle pulse

    final bands = [
      (0.05, 0.10, const Color(0xFF00E5FF)),
      (0.07, 0.16, const Color(0xFF69F0AE)),
      (0.04, 0.22, const Color(0xFFE040FB)),
    ];

    for (final band in bands) {
      final (yFrac, heightFrac, color) = band;
      final rect = Rect.fromLTWH(
        0,
        size.height * yFrac,
        size.width,
        size.height * heightFrac,
      );
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: auroraAlpha),
            color.withValues(alpha: auroraAlpha * 0.5),
            Colors.transparent,
          ],
        ).createShader(rect);
      canvas.drawRect(rect, paint);
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
      size.width * 0.2 + float,
      size.height * 0.38,
      size.width * 0.4,
      size.height * 0.48,
    );
    backPath.quadraticBezierTo(
      size.width * 0.6 + float,
      size.height * 0.32,
      size.width * 0.8,
      size.height * 0.45,
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
      size.width * 0.15 + float,
      size.height * 0.35,
      size.width * 0.3,
      size.height * 0.45,
    );
    frontPath.quadraticBezierTo(
      size.width * 0.45 + float,
      size.height * 0.3,
      size.width * 0.6,
      size.height * 0.42,
    );
    frontPath.quadraticBezierTo(
      size.width * 0.8 + float,
      size.height * 0.28,
      size.width,
      size.height * 0.4,
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
      size.width * 0.2 + float,
      size.height * 0.6,
      size.width * 0.4,
      size.height * 0.68,
    );
    path.quadraticBezierTo(
      size.width * 0.6 + float,
      size.height * 0.55,
      size.width * 0.8,
      size.height * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.95 + float,
      size.height * 0.58,
      size.width,
      size.height * 0.62,
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
        cloud.position +
            Offset(float, math.sin(animation * math.pi * 0.5 + i) * 3),
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

    canvas.drawCircle(
        center + Offset(-size * 0.2, -size * 0.3), size * 0.4, highlightPaint);
    canvas.drawCircle(center + Offset(size * 0.15, -size * 0.35), size * 0.35,
        highlightPaint);
  }

  void _drawCloudShape(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size, paint);
    canvas.drawCircle(
        center + Offset(-size * 0.7, size * 0.1), size * 0.75, paint);
    canvas.drawCircle(
        center + Offset(size * 0.7, size * 0.1), size * 0.75, paint);
    canvas.drawCircle(
        center + Offset(-size * 0.35, -size * 0.35), size * 0.65, paint);
    canvas.drawCircle(
        center + Offset(size * 0.35, -size * 0.35), size * 0.65, paint);
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
      size.width * 0.15 + float,
      size.height * 0.72,
      size.width * 0.3,
      size.height * 0.78,
    );
    waterPath.quadraticBezierTo(
      size.width * 0.5 + float,
      size.height * 0.74,
      size.width * 0.7,
      size.height * 0.8,
    );
    waterPath.quadraticBezierTo(
      size.width * 0.85 + float,
      size.height * 0.77,
      size.width,
      size.height * 0.79,
    );
    waterPath.lineTo(size.width, size.height * 0.85);
    waterPath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.83,
      size.width * 0.7,
      size.height * 0.86,
    );
    waterPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.8,
      size.width * 0.3,
      size.height * 0.84,
    );
    waterPath.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.78,
      0,
      size.height * 0.81,
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
      size.width * 0.15 + float,
      size.height * 0.72,
      size.width * 0.3,
      size.height * 0.78,
    );
    edgePath.quadraticBezierTo(
      size.width * 0.5 + float,
      size.height * 0.74,
      size.width * 0.7,
      size.height * 0.8,
    );
    edgePath.quadraticBezierTo(
      size.width * 0.85 + float,
      size.height * 0.77,
      size.width,
      size.height * 0.79,
    );
    canvas.drawPath(edgePath, edgePaint);

    // Water shimmer with more sparkle
    final shimmerPaint = Paint()
      ..color = Colors.white
          .withValues(alpha: 0.3 + math.sin(animation * math.pi * 3) * 0.2)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final shimmerX = size.width * (0.1 + i * 0.11) +
          math.sin(animation * math.pi * 2 + i) * 12;
      final shimmerY =
          size.height * 0.77 + math.sin(animation * math.pi + i) * 4;
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
        ripplePaint
          ..color = Colors.white.withValues(alpha: 0.2 * (1 - ripplePhase)),
      );
    }
  }

  void _drawTrees(Canvas canvas, Size size) {
    final trees = [
      _TreeData(Offset(size.width * 0.08, size.height * 0.68), 35,
          Colors.green.shade700),
      _TreeData(Offset(size.width * 0.22, size.height * 0.58), 42,
          Colors.green.shade600),
      _TreeData(Offset(size.width * 0.35, size.height * 0.72), 38,
          Colors.green.shade700),
      _TreeData(Offset(size.width * 0.62, size.height * 0.55), 45,
          Colors.green.shade800),
      _TreeData(Offset(size.width * 0.78, size.height * 0.7), 40,
          Colors.green.shade700),
      _TreeData(Offset(size.width * 0.92, size.height * 0.62), 36,
          Colors.green.shade600),
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
    canvas.drawCircle(
        position + Offset(-size * 0.2, -size * 0.15), size * 0.35, leafPaint);
    canvas.drawCircle(
        position + Offset(size * 0.2, -size * 0.15), size * 0.35, leafPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position + Offset(-size * 0.15, -size * 0.2), size * 0.15,
        highlightPaint);
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
        final bladeEnd = center +
            Offset(
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
    canvas.drawCircle(
        position + Offset(-size * 0.5, size * 0.2), size * 0.8, bushPaint);
    canvas.drawCircle(
        position + Offset(size * 0.5, size * 0.2), size * 0.8, bushPaint);
    canvas.drawCircle(position + Offset(0, -size * 0.4), size * 0.7, bushPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.green.shade300.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position + Offset(-size * 0.3, -size * 0.3), size * 0.4,
        highlightPaint);
  }

  void _drawFlowers(Canvas canvas, Size size) {
    final flowers = [
      _FlowerData(
          Offset(size.width * 0.12, size.height * 0.74), Colors.pink, 6),
      _FlowerData(
          Offset(size.width * 0.16, size.height * 0.71), Colors.yellow, 5),
      _FlowerData(
          Offset(size.width * 0.29, size.height * 0.68), Colors.purple, 6),
      _FlowerData(Offset(size.width * 0.33, size.height * 0.76), Colors.red, 5),
      _FlowerData(
          Offset(size.width * 0.46, size.height * 0.79), Colors.orange, 6),
      _FlowerData(
          Offset(size.width * 0.59, size.height * 0.63), Colors.pink, 5),
      _FlowerData(
          Offset(size.width * 0.65, size.height * 0.73), Colors.yellow, 6),
      _FlowerData(
          Offset(size.width * 0.74, size.height * 0.76), Colors.purple, 5),
      _FlowerData(Offset(size.width * 0.83, size.height * 0.69), Colors.red, 6),
      _FlowerData(
          Offset(size.width * 0.89, size.height * 0.72), Colors.orange, 5),
    ];

    for (int i = 0; i < flowers.length; i++) {
      final bob = math.sin(animation * math.pi * 1.5 + i * 0.7) * 2;
      _drawFlower(canvas, flowers[i].position + Offset(0, bob),
          flowers[i].color, flowers[i].petalCount);
    }
  }

  void _drawFlower(
      Canvas canvas, Offset position, Color color, int petalCount) {
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
      final petalPos = position +
          Offset(
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
      ).createShader(Rect.fromCircle(
          center: position + Offset(-5 * wingFlap, -3), radius: 8));

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
      ).createShader(Rect.fromCircle(
          center: position + Offset(5 * wingFlap, -3), radius: 8));

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
        position.dx - 8,
        position.dy - 6 * wingFlap,
        position.dx - 12,
        position.dy - 4 * wingFlap,
      );
    canvas.drawPath(leftWing, birdPaint);

    // Right wing
    final rightWing = Path()
      ..moveTo(position.dx, position.dy)
      ..quadraticBezierTo(
        position.dx + 8,
        position.dy - 6 * wingFlap,
        position.dx + 12,
        position.dy - 4 * wingFlap,
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
      final outer =
          center + Offset(math.cos(angle) * size, math.sin(angle) * size);
      final inner = center +
          Offset(math.cos(angle + math.pi / 4) * size * 0.3,
              math.sin(angle + math.pi / 4) * size * 0.3);

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

/// Animated progress ring drawn around a zone island
class _ZoneProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double animationValue;

  _ZoneProgressRingPainter({
    required this.progress,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width - 6,
      height: size.height - 6,
    );

    // Faint background track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawOval(rect, trackPaint);

    if (progress <= 0) return;

    // Shimmering progress arc in amber/gold
    final shimmer = 0.65 + math.sin(animationValue * math.pi * 2) * 0.35;
    final progressPaint = Paint()
      ..color = Colors.amber.withValues(alpha: shimmer)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addArc(rect, -math.pi / 2, progress * 2 * math.pi);
    canvas.drawPath(path, progressPaint);
  }

  @override
  bool shouldRepaint(_ZoneProgressRingPainter old) =>
      old.progress != progress || old.animationValue != animationValue;
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
