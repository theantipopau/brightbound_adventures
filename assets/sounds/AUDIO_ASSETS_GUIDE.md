# Audio Assets Guide

## Required Audio Files

### Sound Effects (SFX)

#### Correct Answers
- `sounds/sfx/correct/correct1.mp3` - Basic correct answer beep
- `sounds/sfx/correct/correct2.mp3` - Alternative correct sound
- `sounds/sfx/correct/correct3.mp3` - Variation for variety

#### Wrong Answers  
- `sounds/sfx/incorrect/wrong1.mp3` - Gentle incorrect sound
- `sounds/sfx/incorrect/wrong2.mp3` - Alternative wrong sound

#### Celebrations (for streaks, perfect scores)
- `sounds/sfx/celebration/perfect.mp3` - All questions correct
- `sounds/sfx/celebration/streak3.mp3` - 3 in a row
- `sounds/sfx/celebration/streak5.mp3` - 5 in a row  
- `sounds/sfx/celebration/streak10.mp3` - 10 in a row
- `sounds/sfx/celebration/levelup.mp3` - Level up achievement
- `sounds/sfx/celebration/unlock.mp3` - New zone/cosmetic unlocked

#### UI Sounds
- `sounds/sfx/ui/click.mp3` - Button click
- `sounds/sfx/ui/whoosh.mp3` - Screen transition
- `sounds/sfx/ui/popup.mp3` - Dialog appears

### Background Music

#### Zone Themes (looping ambient tracks)
- `sounds/music/zones/word_woods.mp3` - Forest/nature theme
- `sounds/music/zones/number_nebula.mp3` - Space/electronic theme
- `sounds/music/zones/story_springs.mp3` - Magical/whimsical theme  
- `sounds/music/zones/puzzle_peaks.mp3` - Mountain/adventure theme
- `sounds/music/zones/adventure_arena.mp3` - Action/energetic theme

#### Menu Music
- `sounds/music/menu.mp3` - Main menu/world map music
- `sounds/music/splash.mp3` - Splash screen music

## Audio Sources

Free resources for game audio:
- **Freesound.org** - CC0 and CC-BY licensed sounds
- **OpenGameArt.org** - Game-specific audio
- **Incompetech.com** - Royalty-free music by Kevin MacLeod
- **ZapSplat.com** - Free sound effects
- **Pixabay Audio** - CC0 music and sounds

## Implementation Notes

- All files should be in MP3 format for web compatibility
- Keep file sizes small (under 200KB for SFX, under 2MB for music)
- Normalize audio levels (-3dB peak recommended)
- Loop points should be seamless for music tracks
- Consider creating variations to prevent repetition

## Fallback Strategy

If audio files don't exist, AudioManager will:
1. Log a warning to console
2. Continue without playing sound
3. Not interrupt gameplay
