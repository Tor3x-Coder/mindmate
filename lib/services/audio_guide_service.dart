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
  Future<void> _sourceOperation = Future<void>.value();
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
  ///
  /// Source changes are serialized. Without this queue, a timer can request a
  /// new prompt while the previous setAsset/play operation is still settling,
  /// which caused Web to keep replaying the first loaded clip.
  Future<bool> playAsset(
    String assetPath, {
    double speed = 1.0,
  }) {
    final generation = ++_requestGeneration;
    final playbackSpeed = speed.clamp(0.5, 2.0).toDouble();

    return _enqueueSourceOperation(() async {
      if (generation != _requestGeneration || _isDisposed) return false;

      try {
        if (_currentAsset != null ||
            _player.processingState != ProcessingState.idle) {
          await _player.stop();
        }
        if (generation != _requestGeneration || _isDisposed) return false;

        _currentAsset = null;
        if (kDebugMode) {
          debugPrint(
            'AudioGuideService loading $assetPath at ${playbackSpeed}x',
          );
        }
        await _player.setAsset(assetPath);
        if (generation != _requestGeneration || _isDisposed) return false;
        await _player.setSpeed(playbackSpeed);
        if (generation != _requestGeneration || _isDisposed) return false;

        _currentAsset = assetPath;
        _notifyIfActive();
        unawaited(_playLoadedAudio(generation));
        return true;
      } catch (error, stackTrace) {
        if (kDebugMode) {
          debugPrint('AudioGuideService could not load $assetPath: $error');
          debugPrintStack(stackTrace: stackTrace);
        }
        if (generation == _requestGeneration) {
          _currentAsset = null;
          _notifyIfActive();
        }
        return false;
      }
    });
  }

  Future<T> _enqueueSourceOperation<T>(Future<T> Function() operation) {
    final completer = Completer<T>();

    _sourceOperation = _sourceOperation.then((_) async {
      try {
        completer.complete(await operation());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
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

  Future<void> stop() {
    final generation = ++_requestGeneration;

    return _enqueueSourceOperation(() async {
      if (_isDisposed) return;
      await _player.stop();
      if (generation != _requestGeneration) return;
      _currentAsset = null;
      _notifyIfActive();
    });
  }

  Future<void> _playLoadedAudio(int generation) async {
    try {
      await _player.play();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('AudioGuideService playback failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
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
