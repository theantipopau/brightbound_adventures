// Conditional export: dart:js available → use web implementation, otherwise stub.
export 'web_sound_player_stub.dart'
    if (dart.library.js) 'web_sound_player_web.dart';
