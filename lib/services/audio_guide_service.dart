import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Owns the single guided-audio player used throughout MindMate.
///
/// A single shared player prevents two screens or timer callbacks from talking
/// over each other. Screens still own their session timers; this service only
/// handles safe asset playback and basic controls.
class AudioGuideService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  late final StreamSubscription<PlayerState> _playerStateSubscription;

  String? _currentAsset;
  int _requestGeneration = 0;
  bool _isDisposed = false;

  AudioGuideService() {
    _playerStateSubscription = _player.playerStateStream.listen(
      (_) => _notifyIfActive(),
      onError: (_) => _clearAfterPlaybackFailure(),
    );
  }

  String? get currentAsset => _currentAsset;
  bool get isPlaying => _player.playing;
  bool get hasLoadedAudio => _currentAsset != null;
  bool get isCompleted =>
      _player.processingState == ProcessingState.completed;

  bool isCurrentAsset(String assetPath) => _currentAsset == assetPath;

  /// Stops any existing narration, loads [assetPath], and starts playback.
  /// Returns false when the asset could not be loaded.
  Future<bool> playAsset(String assetPath) async {
    final generation = ++_requestGeneration;

    try {
      await _player.stop();
      if (generation != _requestGeneration) return false;

      await _player.setAsset(assetPath);
      if (generation != _requestGeneration) return false;

      _currentAsset = assetPath;
      _notifyIfActive();
      unawaited(_playLoadedAudio(generation));
      return true;
    } catch (_) {
      if (generation == _requestGeneration) {
        _currentAsset = null;
        _notifyIfActive();
      }
      return false;
    }
  }

  Future<void> pause() async {
    if (!_player.playing) return;
    await _player.pause();
    _notifyIfActive();
  }

  Future<void> resume() async {
    if (_currentAsset == null || _player.playing) return;

    if (isCompleted) {
      await _player.seek(Duration.zero);
    }
    unawaited(_playLoadedAudio(_requestGeneration));
  }

  Future<void> replayCurrent() async {
    if (_currentAsset == null) return;
    await _player.seek(Duration.zero);
    unawaited(_playLoadedAudio(_requestGeneration));
  }

  Future<void> stop() async {
    _requestGeneration++;
    _currentAsset = null;
    await _player.stop();
    _notifyIfActive();
  }

  Future<void> _playLoadedAudio(int generation) async {
    try {
      await _player.play();
    } catch (_) {
      if (generation == _requestGeneration) {
        _clearAfterPlaybackFailure();
      }
    }
  }

  void _clearAfterPlaybackFailure() {
    _currentAsset = null;
    _notifyIfActive();
  }

  void _notifyIfActive() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unawaited(_playerStateSubscription.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }
}
