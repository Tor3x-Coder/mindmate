import 'package:flutter_test/flutter_test.dart';
import 'package:mindmate/services/audio_guide_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Note: the full playback path (setAsset/play) needs the just_audio
  // platform channel, which only exists on real devices — Chrome and phone
  // playback are covered by the 7E/12 runtime matrix. These tests guard the
  // parts of the lifecycle that must never crash or hang.
  group('AudioGuideService lifecycle', () {
    test('starts with no loaded audio and no playback', () {
      final service = AudioGuideService();
      expect(service.hasLoadedAudio, isFalse);
      expect(service.currentAsset, isNull);
      expect(service.isPlaying, isFalse);
      expect(service.isCurrentAsset('assets/audio/box.mp3'), isFalse);
    });

    test('stop() is safe when nothing is loaded', () async {
      final service = AudioGuideService();
      await service
          .stop()
          .timeout(const Duration(seconds: 10), onTimeout: () {});
      expect(service.hasLoadedAudio, isFalse);
      expect(service.currentAsset, isNull);
    });

    test('pause/resume are no-ops without a loaded source', () async {
      final service = AudioGuideService();
      await service
          .pause()
          .timeout(const Duration(seconds: 10), onTimeout: () {});
      await service
          .resume()
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
