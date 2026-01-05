import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/achievement.dart';

/// Widget to display a single achievement/trophy
class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tierColor = AchievementHelper.getTierColor(achievement.tier);
    final isLocked = !achievement.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked ? Colors.grey[300]! : tierColor,
            width: 2,
          ),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: tierColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Achievement icon/emoji
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isLocked 
                    ? Colors.grey[400] 
                    : tierColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLocked ? Colors.grey[500]! : tierColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: isLocked
                    ? Icon(
                        Icons.lock,
                        color: Colors.grey[600],
                        size: 28,
                      )
                    : Text(
                        achievement.emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Achievement details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? Colors.grey[600] : Colors.black87,
                          ),
                        ),
                      ),
                      // Tier badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLocked 
                              ? Colors.grey[400] 
                              : tierColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AchievementHelper.getTierName(achievement.tier),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: achievement.tier == AchievementTier.gold 
                                ? Colors.black87 
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isLocked ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  if (!achievement.isUnlocked) ...[
                    const SizedBox(height: 8),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: achievement.progressPercent,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(tierColor),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${achievement.currentProgress}/${achievement.requirement}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else if (achievement.unlockedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Unlocked ${_formatDate(achievement.unlockedAt!)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: tierColor,
                        fontWeight: FontWeight.bold,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Grid/List view of achievements
class AchievementsList extends StatelessWidget {
  final List<Achievement> achievements;
  final Function(Achievement)? onAchievementTap;

  const AchievementsList({
    super.key,
    required this.achievements,
    this.onAchievementTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sort: unlocked first, then by tier
    final sorted = List<Achievement>.from(achievements)
      ..sort((a, b) {
        if (a.isUnlocked != b.isUnlocked) {
          return a.isUnlocked ? -1 : 1;
        }
        return b.tier.index.compareTo(a.tier.index);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final achievement = sorted[index];
        return AchievementCard(
          achievement: achievement,
          onTap: onAchievementTap != null 
              ? () => onAchievementTap!(achievement) 
              : null,
        );
      },
    );
  }
}

/// Achievement showcase for displaying recently earned achievements
class AchievementShowcase extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementShowcase({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final tierColor = AchievementHelper.getTierColor(achievement.tier);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              tierColor.withValues(alpha: 0.9),
              tierColor.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: tierColor.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Trophy/sparkle animation placeholder
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            
            Text(
              'Achievement Unlocked!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            
            // Achievement emoji
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: tierColor,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  achievement.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Achievement name
            Text(
              achievement.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Achievement description
            Text(
              achievement.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Tier badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${AchievementHelper.getTierName(achievement.tier)} Trophy',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: tierColor,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Dismiss button
            ElevatedButton(
              onPressed: onDismiss,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: tierColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Awesome!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
