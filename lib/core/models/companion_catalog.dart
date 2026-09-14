/// Single source of truth mapping a companion ID (`Avatar.baseCharacter`) to
/// its display emoji.
///
/// Before this existed, three separate switch statements did this mapping
/// and had drifted out of sync:
/// - `avatar_creator_screen.dart`'s own `_characters` list (the canonical
///   16 companions actually offered to players) used placeholder single
///   letters ('D', 'T', 'Q', 'P') for dragon/turtle/quokka/platypus even
///   though real emoji exist for dragon (🐉) and turtle (🐢).
/// - `world_map_screen/world_map_adventure_bar.dart`'s `_characterEmoji`
///   only handled 4 of the 16 real companion IDs (fox/bear/rabbit/dragon)
///   and silently fell back to a generic compass (🧭) for the other 12 —
///   so most companions showed the wrong icon in the world map HUD.
/// - `world_entry_screen.dart`'s `_getCharacterEmoji` handled 10, missing
///   wolf/tiger/quokka/platypus/turtle/dragon.
///
/// Any screen that needs to render a companion by ID should use
/// [CompanionCatalog.emojiFor] instead of re-declaring this mapping.
class CompanionCatalog {
  const CompanionCatalog._();

  /// Companion IDs a player can actually select in the avatar creator,
  /// in the order they're offered there.
  static const List<String> ids = [
    'bear',
    'fox',
    'rabbit',
    'deer',
    'cat',
    'penguin',
    'koala',
    'panda',
    'owl',
    'otter',
    'wolf',
    'tiger',
    'quokka',
    'platypus',
    'turtle',
    'dragon',
  ];

  static const Map<String, String> _emoji = {
    'bear': '🐻',
    'fox': '🦊',
    'rabbit': '🐰',
    'deer': '🦌',
    'cat': '🐱',
    'penguin': '🐧',
    'koala': '🐨',
    'panda': '🐼',
    'owl': '🦉',
    'otter': '🦦',
    'wolf': '🐺',
    'tiger': '🐯',
    // No widely-supported dedicated emoji exists for these two animals;
    // an initial is a deliberate, documented fallback, not an oversight.
    'quokka': 'Q',
    'platypus': 'P',
    'turtle': '🐢',
    'dragon': '🐉',
  };

  /// Default shown for an unrecognised or legacy companion ID.
  static const String fallbackEmoji = '🧭';

  static String emojiFor(String companionId) =>
      _emoji[companionId.toLowerCase()] ?? fallbackEmoji;
}
