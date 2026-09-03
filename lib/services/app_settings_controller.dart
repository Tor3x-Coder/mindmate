import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  final Completer<void> _loadCompleter = Completer<void>();

  static const _themeModeKey = 'theme_mode';
  static const _textScaleKey = 'text_scale';
  static const _animationIntensityKey = 'animation_intensity';
  static const _hapticsEnabledKey = 'haptics_enabled';
  static const _soundEnabledKey = 'sound_enabled';
  static const _checkInWindowKey = 'check_in_window';
  static const _preferredSessionMinutesKey = 'preferred_session_minutes';
  static const _completedTourVersionKey = 'completed_tour_version';
  static const _accountDeletionPendingKey = 'account_deletion_pending';
  static const _learnAddedArticleIdsKey = 'learn_added_article_ids';

  ThemeMode _themeMode = ThemeMode.light;
  double _textScale = 1.0;
  double _animationIntensity = 1.0;
  bool _hapticsEnabled = true;
  bool _soundEnabled = false;
  String _checkInWindow = 'Evening';
  int _preferredSessionMinutes = 5;
  int _completedTourVersion = 0;
  int _tourReplayRequest = 0;
  bool _accountDeletionPending = false;
  Set<String> _addedLearnArticleIds = <String>{};
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
  bool get accountDeletionPending => _accountDeletionPending;
  Set<String> get addedLearnArticleIds =>
      Set.unmodifiable(_addedLearnArticleIds);
  bool get isLoaded => _isLoaded;
  Future<void> get loaded => _loadCompleter.future;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _themeMode = _themeModeFromString(prefs.getString(_themeModeKey));
      _textScale = prefs.getDouble(_textScaleKey) ?? 1.0;
      _animationIntensity = prefs.getDouble(_animationIntensityKey) ?? 1.0;
      _hapticsEnabled = prefs.getBool(_hapticsEnabledKey) ?? true;
      _soundEnabled = prefs.getBool(_soundEnabledKey) ?? false;
      _checkInWindow = prefs.getString(_checkInWindowKey) ?? 'Evening';
      _preferredSessionMinutes =
          prefs.getInt(_preferredSessionMinutesKey) ?? 5;
      _completedTourVersion = prefs.getInt(_completedTourVersionKey) ?? 0;
      _accountDeletionPending =
          prefs.getBool(_accountDeletionPendingKey) ?? false;
      _addedLearnArticleIds =
          (prefs.getStringList(_learnAddedArticleIdsKey) ?? const <String>[])
              .toSet();
    } finally {
      // Never leave Splash waiting forever if local preferences are damaged.
      _isLoaded = true;
      if (!_loadCompleter.isCompleted) _loadCompleter.complete();
      notifyListeners();
    }
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

  Future<void> updateAccountDeletionPending(bool value) async {
    _accountDeletionPending = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_accountDeletionPendingKey, value);
  }

  Future<void> addLearnArticle(String articleId) async {
    final cleanId = articleId.trim();
    if (cleanId.isEmpty || _addedLearnArticleIds.contains(cleanId)) return;

    _addedLearnArticleIds = {..._addedLearnArticleIds, cleanId};
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _learnAddedArticleIdsKey,
      _addedLearnArticleIds.toList(),
    );
  }

  Future<void> removeLearnArticle(String articleId) async {
    if (!_addedLearnArticleIds.contains(articleId)) return;

    _addedLearnArticleIds = {..._addedLearnArticleIds}..remove(articleId);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _learnAddedArticleIdsKey,
      _addedLearnArticleIds.toList(),
    );
  }

  Future<void> clearAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _themeMode = ThemeMode.light;
    _textScale = 1.0;
    _animationIntensity = 1.0;
    _hapticsEnabled = true;
    _soundEnabled = false;
    _checkInWindow = 'Evening';
    _preferredSessionMinutes = 5;
    _completedTourVersion = 0;
    _tourReplayRequest = 0;
    _accountDeletionPending = false;
    _addedLearnArticleIds = <String>{};
    _isLoaded = true;
    notifyListeners();
  }

  ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }
}
