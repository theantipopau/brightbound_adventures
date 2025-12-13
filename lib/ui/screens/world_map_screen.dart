import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:brightbound_adventures/core/services/index.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';
import 'package:brightbound_adventures/ui/widgets/fantasy_map.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> 
    with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late AnimationController _entranceController;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _scaleIn = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    
    // Start entrance animation
    _entranceController.forward();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  String _getCharacterEmoji(String character) {
    switch (character.toLowerCase()) {
      case 'bear':
        return '🐻';
      case 'fox':
        return '🦊';
      case 'rabbit':
        return '🐰';
      case 'deer':
        return '🦌';
      default:
        return '🐻';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AvatarProvider, SkillProvider>(
        builder: (context, avatarProvider, skillProvider, _) {
          final avatar = avatarProvider.avatar;
          final progressStats = skillProvider.isInitialized 
              ? skillProvider.getProgressionStats() 
              : null;

          if (avatar == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No avatar found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/avatar-creator');
                    },
                    child: const Text('Create Avatar'),
                  ),
                ],
              ),
            );
          }

          return AnimatedBuilder(
            animation: _entranceController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeIn,
                child: Transform.scale(
                  scale: _scaleIn.value.clamp(0.1, 2.0),
                  child: Stack(
                    children: [
                      // Animated fantasy map background
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedBuilder(
                            animation: _cloudController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: FantasyMapPainter(
                                  animationValue: _cloudController.value,
                                ),
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                              );
                    },
                  );
                },
              ),

              // Interactive zone markers
              SafeArea(
                child: Stack(
                  children: [
                    // Map title with logo
                    Positioned(
                      top: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFF8DC),
                                Color(0xFFFFEBC8),
                                Color(0xFFFFF8DC),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFF8B4513),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo (if available)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 32,
                                  height: 32,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to emoji if logo not found
                                    return const Text('🌟', style: TextStyle(fontSize: 24));
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BrightBound',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF8B4513),
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    '✨ Adventures ✨',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFD4A574),
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Settings button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5E6D3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF5D4037),
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Color(0xFF5D4037),
                          ),
                          onPressed: () {
                            _showSettingsDialog(context);
                          },
                        ),
                      ),
                    ),

                    // Word Woods - left side
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.05,
                      top: MediaQuery.of(context).size.height * 0.28,
                      child: ZoneMarker(
                        zoneName: 'Word Woods',
                        emoji: '🌲',
                        color: AppColors.wordWoodsColor,
                        progress: 0.0,
                        onTap: () => Navigator.pushNamed(context, '/word-woods'),
                      ),
                    ),

                    // Number Nebula - right side
                    Positioned(
                      right: MediaQuery.of(context).size.width * 0.05,
                      top: MediaQuery.of(context).size.height * 0.28,
                      child: ZoneMarker(
                        zoneName: 'Number Nebula',
                        emoji: '🌌',
                        color: AppColors.numberNebulaColor,
                        progress: 0.0,
                        onTap: () => Navigator.pushNamed(context, '/number-nebula'),
                      ),
                    ),

                    // Puzzle Peaks - top right
                    Positioned(
                      right: MediaQuery.of(context).size.width * 0.15,
                      top: MediaQuery.of(context).size.height * 0.08,
                      child: ZoneMarker(
                        zoneName: 'Puzzle Peaks',
                        emoji: '🧩',
                        color: AppColors.puzzlePeaksColor,
                        progress: 0.0,
                        onTap: () => Navigator.pushNamed(context, '/puzzle-peaks'),
                      ),
                    ),

                    // Story Springs - bottom center
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.32,
                      bottom: MediaQuery.of(context).size.height * 0.15,
                      child: ZoneMarker(
                        zoneName: 'Story Springs',
                        emoji: '📖',
                        color: AppColors.storyspringsColor,
                        progress: 0.0,
                        onTap: () => Navigator.pushNamed(context, '/story-springs'),
                      ),
                    ),

                    // Adventure Arena - bottom right
                    Positioned(
                      right: MediaQuery.of(context).size.width * 0.05,
                      bottom: MediaQuery.of(context).size.height * 0.1,
                      child: ZoneMarker(
                        zoneName: 'Adventure Arena',
                        emoji: '🏟️',
                        color: AppColors.adventureArenaColor,
                        progress: 0.0,
                        onTap: () => Navigator.pushNamed(context, '/adventure-arena'),
                      ),
                    ),

                    // Central hub with avatar
                    Positioned(
                      left: 0,
                      right: 0,
                      top: MediaQuery.of(context).size.height * 0.4,
                      child: Center(
                        child: CentralHub(
                          avatarEmoji: _getCharacterEmoji(avatar.baseCharacter),
                          avatarName: avatar.name,
                          level: avatar.level,
                        ),
                      ),
                    ),

                    // Quick stats panel at bottom
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 10,
                      child: _buildStatsPanel(avatar, progressStats),
                    ),
                  ],
                ),
              ),
            ],
          ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatsPanel(avatar, progressStats) {
    final masteredCount = progressStats?.mastered ?? 0;
    final totalSkills = progressStats != null 
        ? (progressStats.mastered + progressStats.practising + 
           progressStats.introduced + progressStats.locked)
        : 63;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF8DC),
            Color(0xFFFFEBC8),
            Color(0xFFFFF8DC),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B4513), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('⭐', 'Level', avatar.level.toString(), const Color(0xFFFFD700)),
          _buildStatItem('⚡', 'XP', '${avatar.experiencePoints}', const Color(0xFF9370DB)),
          _buildStatItem('👗', 'Outfits', '${avatar.unlockedOutfits.length}', const Color(0xFFFF69B4)),
          _buildStatItem('🏆', 'Skills', '$masteredCount/$totalSkills', const Color(0xFF32CD32)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color.lerp(color, Colors.black, 0.3),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color.lerp(color, Colors.black, 0.5),
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
        backgroundColor: const Color(0xFFF5E6D3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF5D4037), width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.settings, color: Color(0xFF5D4037)),
            SizedBox(width: 8),
            Text('Settings', style: TextStyle(color: Color(0xFF5D4037))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF5D4037)),
              title: const Text('Edit Avatar'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avatar editor coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_up, color: Color(0xFF5D4037)),
              title: const Text('Sound Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sound settings coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.family_restroom, color: Color(0xFF5D4037)),
              title: const Text('Parent Dashboard'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Parent dashboard coming soon!')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Reset Progress', style: TextStyle(color: Colors.red)),
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
            child: const Text('Close', style: TextStyle(color: Color(0xFF5D4037))),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Progress?'),
        content: const Text(
          'This will delete your avatar and all progress. This cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed('/avatar-creator');
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
