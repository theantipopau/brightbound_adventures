import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisualAccessibilityService extends ChangeNotifier {
  static const String reduceMotionKey = 'visual.reduceMotion';
  static const String highContrastKey = 'visual.highContrast';
  static const String largeTextKey = 'visual.largeText';

  bool _reduceMotion = false;
  bool _highContrast = false;
  bool _largeText = false;

  bool get reduceMotion => _reduceMotion;
  bool get highContrast => _highContrast;
  bool get largeText => _largeText;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _reduceMotion = prefs.getBool(reduceMotionKey) ?? false;
    _highContrast = prefs.getBool(highContrastKey) ?? false;
    _largeText = prefs.getBool(largeTextKey) ?? false;
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    if (_reduceMotion == value) return;
    _reduceMotion = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(reduceMotionKey, value);
    notifyListeners();
  }

  Future<void> setHighContrast(bool value) async {
    if (_highContrast == value) return;
    _highContrast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(highContrastKey, value);
    notifyListeners();
  }

  Future<void> setLargeText(bool value) async {
    if (_largeText == value) return;
    _largeText = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(largeTextKey, value);
    notifyListeners();
  }
}
