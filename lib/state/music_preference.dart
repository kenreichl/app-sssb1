// Global music On/Off preference persisted via SharedPreferences.
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the session-wide music preference (default On).
class MusicPreference extends ChangeNotifier {
  MusicPreference();

  static const _prefsKey = 'music_on';

  bool _musicOn = true;
  bool _loaded = false;

  bool get musicOn => _musicOn;
  bool get isLoaded => _loaded;

  /// Load from disk; defaults to true on first launch.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _musicOn = prefs.getBool(_prefsKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  /// Toggle and persist immediately.
  Future<void> setMusicOn(bool value) async {
    if (_musicOn == value) return;
    _musicOn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }

  Future<void> toggle() => setMusicOn(!_musicOn);
}
