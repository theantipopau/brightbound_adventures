import 'dart:js_interop';

@JS('BBSounds.play')
external void _playWebSound(JSString type);

/// Calls window.BBSounds.play(type) in the browser via dart:js_interop.
void playWebSound(String type) {
  try {
    _playWebSound(type.toJS);
  } catch (_) {
    // Silently ignore – audio is non-critical
  }
}
