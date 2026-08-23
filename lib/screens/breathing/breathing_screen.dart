import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_settings_controller.dart';
import '../../services/audio_guide_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/audio_assets.dart';

// Represents one breathing pattern, e.g. Box Breathing = 4s in, 4s hold,
// 4s out, 4s hold. Each entry in `phaseSeconds` pairs with a label in
// `phaseLabels` at the same position.
class _BreathingPattern {
  final String name;
  final String description;
  final List<String> phaseLabels;
  final List<int> phaseSeconds;
  final String benefit;
  final String? introAudioAsset;
  final List<String> phaseAudioAssets;
  final String? completionAudioAsset;

  const _BreathingPattern({
    required this.name,
    required this.description,
    required this.phaseLabels,
    required this.phaseSeconds,
    required this.benefit,
    this.introAudioAsset,
    this.phaseAudioAssets = const [],
    this.completionAudioAsset,
  });

  bool get hasGuidedAudio =>
      introAudioAsset != null &&
      completionAudioAsset != null &&
      phaseAudioAssets.length == phaseLabels.length;
}

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  static const double _narrationSpeed = 0.92;

  final List<_BreathingPattern> _patterns = const [
    _BreathingPattern(
      name: 'Box Breathing',
      description: 'Equal counts in, hold, out, hold. Great for calming down fast.',
      phaseLabels: ['Breathe In', 'Hold', 'Breathe Out', 'Hold'],
      phaseSeconds: [4, 4, 4, 4],
      benefit: 'Balanced and steady',
      introAudioAsset: MindMateAudioAssets.boxBreathingIntro,
      phaseAudioAssets: MindMateAudioAssets.boxBreathingPhasePrompts,
      completionAudioAsset: MindMateAudioAssets.boxBreathingComplete,
    ),
    _BreathingPattern(
      name: '4-7-8 Breathing',
      description: 'A longer exhale helps relax the nervous system before rest.',
      phaseLabels: ['Breathe In', 'Hold', 'Breathe Out'],
      phaseSeconds: [4, 7, 8],
      benefit: 'Best for winding down',
    ),
    _BreathingPattern(
      name: 'Simple Calm',
      description: 'Slow, even in-and-out breathing. Good for beginners.',
      phaseLabels: ['Breathe In', 'Breathe Out'],
      phaseSeconds: [5, 5],
      benefit: 'Easy and beginner friendly',
    ),
  ];

  // Same duration choices as Meditation.
  final List<int> _durationOptions = const [1, 3, 5];

  int _selectedPatternIndex = 0;
  int _selectedDurationMinutes = 3;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _isPreparingSession = false;
  int _currentPhaseIndex = 0;
  int _secondsRemainingInPhase = 0;
  int _secondsRemainingTotal = 0;
  int _completedCycles = 0;
  int _totalSessionSeconds = 0;

  Timer? _timer;
  AudioGuideService? _audioGuide;

  late AnimationController _circleController;

  _BreathingPattern get _selectedPattern => _patterns[_selectedPatternIndex];

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioGuide ??= context.read<AudioGuideService>();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _circleController.dispose();
    final audioGuide = _audioGuide;
    if (audioGuide != null) unawaited(audioGuide.stop());
    super.dispose();
  }

  Future<void> _startSession() async {
    if (_isPreparingSession) return;

    final totalSeconds = _selectedDurationMinutes * 60;
    final audioGuide = _audioGuide;
    setState(() => _isPreparingSession = true);

    try {
      // A preview introduction may still be playing. Stop it completely before
      // showing or timing the first breathing phase.
      if (audioGuide?.hasLoadedAudio == true) {
        await audioGuide?.stop();
      }
      if (!mounted) return;

      setState(() {
        _isRunning = true;
        _isPaused = false;
        _isPreparingSession = false;
        _currentPhaseIndex = 0;
        _completedCycles = 0;
        _totalSessionSeconds = totalSeconds;
        _secondsRemainingTotal = totalSeconds;
        _secondsRemainingInPhase = _selectedPattern.phaseSeconds[0];
      });

      _animateCircleForCurrentPhase();
      if (context.read<AppSettingsController>().soundEnabled &&
          _selectedPattern.hasGuidedAudio) {
        // Wait only until the first cue is loaded and started. The countdown
        // then begins in sync instead of racing the audio source change.
        await _playCurrentBreathingCue(showError: true);
      }
      if (!mounted) return;
      _tick();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPreparingSession = false;
        _isRunning = false;
        _isPaused = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The session could not start. Please try again.'),
        ),
      );
    }
  }

  void _stopSession() {
    _timer?.cancel();
    _circleController.stop();
    final audioGuide = _audioGuide;
    if (audioGuide != null) unawaited(audioGuide.stop());
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _secondsRemainingTotal = 0;
    });
  }

  void _finishSession() {
    _timer?.cancel();
    _circleController.stop();
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    final completionAsset = _selectedPattern.completionAudioAsset;
    if (completionAsset != null &&
        context.read<AppSettingsController>().soundEnabled) {
      unawaited(_playBreathingAsset(completionAsset));
    } else {
      final audioGuide = _audioGuide;
      if (audioGuide != null) unawaited(audioGuide.stop());
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Session Complete'),
        content: Text(
          'Nicely done. You completed a $_selectedDurationMinutes-minute '
          '${_selectedPattern.name} session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _playBreathingAsset(
    String assetPath, {
    bool showError = false,
  }) async {
    final audioGuide = _audioGuide;
    if (audioGuide == null) return;

    final played = await audioGuide.playAsset(
      assetPath,
      speed: _narrationSpeed,
    );
    if (!played && showError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guided audio could not start. Visual guidance is still available.'),
        ),
      );
    }
  }

  Future<void> _playCurrentBreathingCue({bool showError = false}) async {
    final pattern = _selectedPattern;
    if (!pattern.hasGuidedAudio ||
        _currentPhaseIndex >= pattern.phaseAudioAssets.length) {
      return;
    }
    await _playBreathingAsset(
      pattern.phaseAudioAssets[_currentPhaseIndex],
      showError: showError,
    );
  }

  Future<void> _previewBreathingIntro() async {
    final introAsset = _selectedPattern.introAudioAsset;
    if (introAsset == null) return;
    await _playBreathingAsset(introAsset, showError: true);
  }

  Future<void> _setSoundEnabled(bool enabled) async {
    final settings = context.read<AppSettingsController>();
    final audioGuide = _audioGuide;
    await settings.updateSoundEnabled(enabled);
    if (!mounted) return;

    if (!enabled) {
      await audioGuide?.stop();
      return;
    }

    if (_isRunning && !_isPaused && _selectedPattern.hasGuidedAudio) {
      await _playCurrentBreathingCue(showError: true);
    }
  }

  void _togglePause() {
    if (!_isRunning) return;

    setState(() => _isPaused = !_isPaused);
    final audioGuide = _audioGuide;

    if (_isPaused) {
      _circleController.stop();
      if (audioGuide != null) unawaited(audioGuide.pause());
    } else {
      _animateCircleForCurrentPhase(
        secondsOverride: _secondsRemainingInPhase,
      );
      if (audioGuide != null &&
          context.read<AppSettingsController>().soundEnabled) {
        if (audioGuide.hasLoadedAudio) {
          unawaited(audioGuide.resume());
        } else {
          unawaited(_playCurrentBreathingCue(showError: true));
        }
      }
    }
  }

  void _replayCurrentBreathingCue() {
    if (!_selectedPattern.hasGuidedAudio ||
        !context.read<AppSettingsController>().soundEnabled) {
      return;
    }
    unawaited(_playCurrentBreathingCue(showError: true));
  }

  // Grows the circle on "Breathe In", shrinks on "Breathe Out",
  // holds steady on "Hold".
  void _animateCircleForCurrentPhase({int? secondsOverride}) {
    final label = _selectedPattern.phaseLabels[_currentPhaseIndex];
    final seconds = secondsOverride ??
        _selectedPattern.phaseSeconds[_currentPhaseIndex];

    _circleController.duration = Duration(
      seconds: seconds.clamp(1, 999).toInt(),
    );

    if (label == 'Breathe In') {
      _circleController.forward(from: _circleController.value);
    } else if (label == 'Breathe Out') {
      _circleController.reverse(from: _circleController.value);
    }
    // "Hold" phases just leave the circle where it is.
  }

  void _tick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isPaused) return;

      var shouldFinish = false;
      var phaseChanged = false;

      setState(() {
        _secondsRemainingInPhase--;
        _secondsRemainingTotal--;

        if (_secondsRemainingTotal <= 0) {
          shouldFinish = true;
          return;
        }

        if (_secondsRemainingInPhase <= 0) {
          final isLastPhase =
              _currentPhaseIndex == _selectedPattern.phaseLabels.length - 1;

          if (isLastPhase) {
            _currentPhaseIndex = 0;
            _completedCycles++;
          } else {
            _currentPhaseIndex++;
          }

          _secondsRemainingInPhase =
              _selectedPattern.phaseSeconds[_currentPhaseIndex];
          phaseChanged = true;
        }
      });

      if (phaseChanged) {
        _animateCircleForCurrentPhase();
        if (context.read<AppSettingsController>().soundEnabled &&
            _selectedPattern.hasGuidedAudio) {
          unawaited(_playCurrentBreathingCue());
        }
      }

      if (shouldFinish) {
        timer.cancel();
        _finishSession();
      }
    });
  }

  String _formatClock(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _sessionProgress {
    if (_totalSessionSeconds <= 0) return 0;
    return 1 - (_secondsRemainingTotal / _totalSessionSeconds);
  }

  String get _currentPhaseLabel => _selectedPattern.phaseLabels[_currentPhaseIndex];

  String get _phaseSupportText {
    switch (_currentPhaseLabel) {
      case 'Breathe In':
        return 'Expand slowly and let your breath fill the space.';
      case 'Breathe Out':
        return 'Release tension gently and lengthen the exhale.';
      default:
        return 'Stay soft and still. Let the calm settle in.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing'),
      ),
      body: SafeArea(
        child: _isRunning ? _buildSessionView() : _buildSelectionView(),
      ),
    );
  }

  // Shown before starting: pick which pattern to use.
  Widget _buildSelectionView() {
    final pattern = _selectedPattern;

    return Stack(
      children: [
        const Positioned(
          top: -40,
          right: -40,
          child: _AmbientGlow(
            size: 180,
            color: Color(0x225B9A8B),
          ),
        ),
        const Positioned(
          top: 140,
          left: -60,
          child: _AmbientGlow(
            size: 220,
            color: Color(0x189B8ECF),
          ),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  final textColor = isDark ? Colors.white : AppTheme.textDark;
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppTheme.surfaceBorder.withValues(alpha: 0.9),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Breathing space',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Slow your body down with a visual rhythm that helps you settle into each inhale and exhale.',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.74),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _TopPill(
                              icon: Icons.air_rounded,
                              label: pattern.benefit,
                              isDark: isDark,
                            ),
                            _TopPill(
                              icon: Icons.timelapse_rounded,
                              label: '$_selectedDurationMinutes minute session',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Choose a pattern',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...List.generate(_patterns.length, (index) {
                final pattern = _patterns[index];
                final isSelected = _selectedPatternIndex == index;

                return GestureDetector(
                  onTap: () {
                    final audioGuide = _audioGuide;
                    if (audioGuide != null) unawaited(audioGuide.stop());
                    setState(() => _selectedPatternIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.surfaceBorder.withValues(alpha: 0.75),
                        width: isSelected ? 1.6 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.14),
                                blurRadius: 24,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.air_rounded,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pattern.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    pattern.benefit,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.primary,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          pattern.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(pattern.phaseLabels.length, (phaseIndex) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceAlt.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${pattern.phaseLabels[phaseIndex]} ${pattern.phaseSeconds[phaseIndex]}s',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              _buildBreathingAudioCard(pattern),
              const SizedBox(height: 22),
              Text(
                'Session length',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _durationOptions.map((minutes) {
                  final isSelected = _selectedDurationMinutes == minutes;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDurationMinutes = minutes),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.accentGradient : null,
                        color: isSelected
                            ? null
                            : AppTheme.surfaceAlt.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppTheme.surfaceBorder.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Text(
                        '$minutes min',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isPreparingSession ? null : _startSession,
                child: _isPreparingSession
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('Preparing guide...'),
                        ],
                      )
                    : const Text('Start session'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingAudioCard(_BreathingPattern pattern) {
    final settings = context.watch<AppSettingsController>();
    final audioGuide = context.watch<AudioGuideService>();
    final introAsset = pattern.introAudioAsset;
    final hasAudio = pattern.hasGuidedAudio;
    final previewPlaying = introAsset != null &&
        audioGuide.isCurrentAsset(introAsset) &&
        audioGuide.isPlaying;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasAudio
              ? AppTheme.primary.withValues(alpha: 0.35)
              : AppTheme.surfaceBorder.withValues(alpha: 0.78),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasAudio ? Icons.graphic_eq_rounded : Icons.visibility_outlined,
            color: hasAudio ? AppTheme.primary : AppTheme.textLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAudio ? 'Meet your breathing guide' : 'Visual guidance',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  hasAudio
                      ? 'Hear a short introduction. Phase cues begin after Start.'
                      : 'Natural narration is still being added to this pattern.',
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (hasAudio && settings.soundEnabled)
            IconButton(
              tooltip: previewPlaying ? 'Stop introduction' : 'Hear introduction',
              onPressed: () {
                if (previewPlaying) {
                  unawaited(audioGuide.stop());
                } else {
                  unawaited(_previewBreathingIntro());
                }
              },
              icon: Icon(
                previewPlaying
                    ? Icons.stop_circle_outlined
                    : Icons.play_circle_outline_rounded,
              ),
            ),
          if (hasAudio)
            Switch.adaptive(
              value: settings.soundEnabled,
              onChanged: _setSoundEnabled,
            ),
        ],
      ),
    );
  }

  // Shown while actively breathing along.
  Widget _buildSessionView() {
    final settings = context.watch<AppSettingsController>();
    final currentLabel = _currentPhaseLabel;
    final intensity = settings.animationIntensity;
    final orbScale = 0.62 + (_circleController.value * 0.38 * intensity.clamp(0.6, 1.3));

    return Stack(
      children: [
        Positioned(
          top: 110,
          left: -50,
          child: _AmbientGlow(
            size: 220,
            color: AppTheme.primary.withValues(alpha: 0.16),
          ),
        ),
        Positioned(
          top: 200,
          right: -40,
          child: _AmbientGlow(
            size: 200,
            color: AppTheme.secondary.withValues(alpha: 0.12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.surfaceBorder.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SessionStat(
                          label: 'Time left',
                          value: _formatClock(_secondsRemainingTotal),
                        ),
                      ),
                      Expanded(
                        child: _SessionStat(
                          label: 'Cycles',
                          value: '$_completedCycles',
                        ),
                      ),
                      Expanded(
                        child: _SessionStat(
                          label: 'Pattern',
                          value: _selectedPattern.name,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _circleController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: orbScale,
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size.square(300),
                              painter: _ProgressRingPainter(
                                progress: _sessionProgress,
                                activeColor: AppTheme.primary,
                                trackColor: AppTheme.surfaceBorder.withValues(alpha: 0.35),
                              ),
                            ),
                            CustomPaint(
                              size: const Size.square(220),
                              painter: _BreathingFigurePainter(
                                breathValue: _circleController.value,
                                color: AppTheme.primary,
                              ),
                            ),
                            Container(
                              width: 166,
                              height: 166,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF11202A).withValues(alpha: 0.30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    currentLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_secondsRemainingInPhase',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  _phaseSupportText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(_selectedPattern.phaseLabels.length, (index) {
                    final isActive = index == _currentPhaseIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isActive ? AppTheme.accentGradient : null,
                        color: isActive
                            ? null
                            : AppTheme.surfaceAlt.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _selectedPattern.phaseLabels[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                _buildBreathingSessionControls(settings),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _stopSession,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('End session'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreathingSessionControls(AppSettingsController settings) {
    final hasAudio = _selectedPattern.hasGuidedAudio;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: _togglePause,
          icon: Icon(
            _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          ),
          label: Text(_isPaused ? 'Resume session' : 'Pause session'),
        ),
        if (hasAudio)
          OutlinedButton.icon(
            onPressed: settings.soundEnabled
                ? _replayCurrentBreathingCue
                : null,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Replay cue'),
          ),
        if (hasAudio)
          IconButton.filledTonal(
            tooltip: settings.soundEnabled
                ? 'Turn guided voice off'
                : 'Turn guided voice on',
            onPressed: () => _setSoundEnabled(!settings.soundEnabled),
            icon: Icon(
              settings.soundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
            ),
          ),
      ],
    );
  }
}

class _TopPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _TopPill({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white : AppTheme.textDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.08 : 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionStat extends StatelessWidget {
  final String label;
  final String value;

  const _SessionStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textLight,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _AmbientGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  const _ProgressRingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width / 2) - 12;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppTheme.secondary.withValues(alpha: 0.5),
          activeColor,
          Colors.white,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708,
      6.28318 * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}

// Draws a simple human silhouette whose chest expands and contracts
// with the breathing animation — head, chest (scales with breathValue),
// and a hint of lower body.
class _BreathingFigurePainter extends CustomPainter {
  final double breathValue;
  final Color color;

  const _BreathingFigurePainter({
    required this.breathValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Head
    final headPaint = Paint()..color = color.withValues(alpha: 0.85);
    final headRadius = size.width * 0.09;
    final headCenter = Offset(center.dx, size.height * 0.22);
    canvas.drawCircle(headCenter, headRadius, headPaint);

    // Chest — this is the part that visibly grows on inhale and
    // shrinks on exhale, so the user can watch it "breathe."
    final chestWidthBase = size.width * 0.30;
    final chestWidth = chestWidthBase + (chestWidthBase * 0.35 * breathValue);
    final chestHeight = size.height * 0.30;
    final chestTop = headCenter.dy + headRadius + size.height * 0.03;
    final chestRect = Rect.fromCenter(
      center: Offset(center.dx, chestTop + chestHeight / 2),
      width: chestWidth,
      height: chestHeight,
    );
    final chestPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.4)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(chestRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(chestRect, Radius.circular(chestWidth * 0.35)),
      chestPaint,
    );

    // A faint lower-body hint below the chest, so it reads as a full
    // figure rather than a floating head-and-chest.
    final lowerRect = Rect.fromLTWH(
      center.dx - chestWidthBase * 0.42,
      chestRect.bottom - 4,
      chestWidthBase * 0.84,
      size.height * 0.18,
    );
    final lowerPaint = Paint()..color = color.withValues(alpha: 0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(lowerRect, const Radius.circular(20)),
      lowerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BreathingFigurePainter oldDelegate) {
    return oldDelegate.breathValue != breathValue ||
        oldDelegate.color != color;
  }
}
