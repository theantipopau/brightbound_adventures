import 'package:flutter/material.dart';
import 'package:brightbound_adventures/core/models/index.dart';
import 'package:brightbound_adventures/core/utils/constants.dart';
import 'package:brightbound_adventures/ui/themes/index.dart';

class AvatarDisplayCard extends StatelessWidget {
  final Avatar avatar;
  final VoidCallback? onTap;

  const AvatarDisplayCard({
    super.key,
    required this.avatar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar visual representation
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(int.parse('0xFF${_getSkinColorHex(avatar.skinColor)}')),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getCharacterEmoji(avatar.baseCharacter),
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Avatar name
              Text(
                avatar.name,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Character type
              Text(
                _formatCharacterName(avatar.baseCharacter),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 12),
              
              // Level and XP bar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Level ${avatar.level}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: avatar.experiencePoints / Constants.xpPerLevel,
                            minHeight: 6,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${avatar.experiencePoints}/${Constants.xpPerLevel} XP',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
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

  String _formatCharacterName(String character) {
    return character[0].toUpperCase() + character.substring(1).toLowerCase();
  }

  String _getSkinColorHex(String color) {
    // Remove # if present
    return color.replaceFirst('#', '');
  }
}

class AvatarCharacterSelector extends StatelessWidget {
  final String selectedCharacter;
  final ValueChanged<String> onCharacterChanged;

  const AvatarCharacterSelector({
    super.key,
    required this.selectedCharacter,
    required this.onCharacterChanged,
  });

  @override
  Widget build(BuildContext context) {
    const characters = ['bear', 'fox', 'rabbit', 'deer'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your character:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: characters
              .map((character) => _CharacterOption(
                    character: character,
                    isSelected: character == selectedCharacter,
                    onTap: () => onCharacterChanged(character),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _CharacterOption extends StatelessWidget {
  final String character;
  final bool isSelected;
  final VoidCallback onTap;

  const _CharacterOption({
    required this.character,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getEmoji(character),
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              _formatName(character),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getEmoji(String character) {
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

  String _formatName(String character) {
    return character[0].toUpperCase() + character.substring(1).toLowerCase();
  }
}

class SkinColorPicker extends StatelessWidget {
  final String selectedCharacter;
  final String selectedColor;
  final ValueChanged<String> onColorChanged;

  const SkinColorPicker({
    super.key,
    required this.selectedCharacter,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = CosmeticsLibrary.getSkinColorsForCharacter(selectedCharacter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose your skin color:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: colors
              .map((color) => _ColorOption(
                    color: color,
                    isSelected: color == selectedColor,
                    onTap: () => onColorChanged(color),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  final String color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(int.parse('0xFF${color.replaceFirst('#', '')}')),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 24,
              )
            : null,
      ),
    );
  }
}
