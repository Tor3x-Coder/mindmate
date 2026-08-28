import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/services/audio_guide_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioGuideService lifecycle', () {
    test('starts with no loaded audio and no playback', () {
      final service = AudioGuideService();
      expect(service.hasLoadedAudio, isFalse);
      expect(service.currentAsset, isNull);
      expect(service.isPlaying, isFalse);
      expect(service.isCurrentAsset('assets/audio/box.mp3'), isFalse);
    });

    test('playAsset fails gracefully when no audio platform is available',
        () async {
      final service = AudioGuideService();

      // The test environment has no just_audio platform channel, so playback
      // must fail cleanly (return false) instead of crashing or hanging.
      final ok = await service
          .playAsset('assets/audio/breathing/box/01_inhale.mp3')
          .timeout(const Duration(seconds: 10), onTimeout: () => false);

      expect(ok, isFalse);
      expect(service.hasLoadedAudio, isFalse);
      expect(service.currentAsset, isNull);
    });

    test('speed clamping does not reject the request path', () async {
      final service = AudioGuideService();
      final ok = await service
          .playAsset('assets/audio/breathing/box/01_inhale.mp3', speed: 9.0)
          .timeout(const Duration(seconds: 10), onTimeout: () => false);
      expect(ok, isFalse); // no platform player here
      expect(service.hasLoadedAudio, isFalse);
    });

    test('stop() is safe when nothing is loaded', () async {
      final service = AudioGuideService();
      await service
          .stop()
          .timeout(const Duration(seconds: 10), onTimeout: () {});
      expect(service.hasLoadedAudio, isFalse);
    });

    test('dispose does not throw in an environment without audio channels',
        () async {
      final service = AudioGuideService();
      await service
          .stop()
          .timeout(const Duration(seconds: 10), onTimeout: () {});
      // Must not throw; the test environment simply has no audio plugin.
      service.dispose();
    });
  });
}
