import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode';
  static const _textScaleKey = 'text_scale';
  static const _animationIntensityKey = 'animation_intensity';
  static const _hapticsEnabledKey = 'haptics_enabled';
  static const _soundEnabledKey = 'sound_enabled';
  static const _checkInWindowKey = 'check_in_window';
  static const _preferredSessionMinutesKey = 'preferred_session_minutes';
  static const _completedTourVersionKey = 'completed_tour_version';

  ThemeMode _themeMode = ThemeMode.light;
  double _textScale = 1.0;
  double _animationIntensity = 1.0;
  bool _hapticsEnabled = true;
  bool _soundEnabled = false;
  String _checkInWindow = 'Evening';
  int _preferredSessionMinutes = 5;
  int _completedTourVersion = 0;
  int _tourReplayRequest = 0;
  bool _isLoaded = false;

  AppSettingsController() {
    _load();
  }

  ThemeMode get themeMode => _themeMode;
  double get textScale => _textScale;
  double get animationIntensity => _animationIntensity;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get soundEnabled => _soundEnabled;
  String get checkInWindow => _checkInWindow;
  int get preferredSessionMinutes => _preferredSessionMinutes;
  int get completedTourVersion => _completedTourVersion;
  int get tourReplayRequest => _tourReplayRequest;
  bool get isLoaded => _isLoaded;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _themeModeFromString(prefs.getString(_themeModeKey));
    _textScale = prefs.getDouble(_textScaleKey) ?? 1.0;
    _animationIntensity = prefs.getDouble(_animationIntensityKey) ?? 1.0;
    _hapticsEnabled = prefs.getBool(_hapticsEnabledKey) ?? true;
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? false;
    _checkInWindow = prefs.getString(_checkInWindowKey) ?? 'Evening';
    _preferredSessionMinutes = prefs.getInt(_preferredSessionMinutesKey) ?? 5;
    _completedTourVersion = prefs.getInt(_completedTourVersionKey) ?? 0;
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode value) async {
    _themeMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, value.name);
  }

  Future<void> updateTextScale(double value) async {
    _textScale = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, value);
  }

  Future<void> updateAnimationIntensity(double value) async {
    _animationIntensity = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_animationIntensityKey, value);
  }

  Future<void> updateHapticsEnabled(bool value) async {
    _hapticsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsEnabledKey, value);
  }

  Future<void> updateSoundEnabled(bool value) async {
    _soundEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, value);
  }

  Future<void> updateCheckInWindow(String value) async {
    _checkInWindow = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_checkInWindowKey, value);
  }

  Future<void> updatePreferredSessionMinutes(int value) async {
    _preferredSessionMinutes = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_preferredSessionMinutesKey, value);
  }

  Future<void> markTourCompleted(int version) async {
    if (version <= _completedTourVersion) return;
    _completedTourVersion = version;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_completedTourVersionKey, version);
  }

  void requestTourReplay() {
    _tourReplayRequest++;
    notifyListeners();
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }
}
