// ignore: avoid_web_libraries_in_flutter
// ignore: unused_import
// ignore: deprecated_member_use
import 'dart:js' as js;

/// Calls window.BBSounds.play(type) in the browser via dart:js.
void playWebSound(String type) {
  try {
    // Access window.BBSounds and call play(type)
    if (js.context.hasProperty('BBSounds')) {
      final bbSounds = js.context['BBSounds'];
      if (bbSounds != null && bbSounds.hasProperty('play')) {
        bbSounds.callMethod('play', [type]);
      }
    }
  } catch (_) {
    // Silently ignore – audio is non-critical
  }
}
