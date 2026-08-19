import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_settings_controller.dart';
import '../../utils/app_theme.dart';

// Represents one breathing pattern, e.g. Box Breathing = 4s in, 4s hold,
// 4s out, 4s hold. Each entry in `phaseSeconds` pairs with a label in
// `phaseLabels` at the same position.
class _BreathingPattern {
  final String name;
  final String description;
  final List<String> phaseLabels;
  final List<int> phaseSeconds;
  final String benefit;

  const _BreathingPattern({
    required this.name,
    required this.description,
    required this.phaseLabels,
    required this.phaseSeconds,
    required this.benefit,
  });
}

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  final List<_BreathingPattern> _patterns = const [
    _BreathingPattern(
      name: 'Box Breathing',
      description: 'Equal counts in, hold, out, hold. Great for calming down fast.',
      phaseLabels: ['Breathe In', 'Hold', 'Breathe Out', 'Hold'],
      phaseSeconds: [4, 4, 4, 4],
      benefit: 'Balanced and steady',
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
  int _currentPhaseIndex = 0;
  int _secondsRemainingInPhase = 0;
  int _secondsRemainingTotal = 0;
  int _completedCycles = 0;
  int _totalSessionSeconds = 0;

  Timer? _timer;

  late AnimationController _circleController;

  _BreathingPattern get _selectedPattern => _patterns[_selectedPatternIndex];

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _circleController.dispose();
    super.dispose();
  }

  void _startSession() {
    final totalSeconds = _selectedDurationMinutes * 60;

    setState(() {
      _isRunning = true;
      _currentPhaseIndex = 0;
      _completedCycles = 0;
      _totalSessionSeconds = totalSeconds;
      _secondsRemainingTotal = totalSeconds;
      _secondsRemainingInPhase = _selectedPattern.phaseSeconds[0];
    });

    _animateCircleForCurrentPhase();
    _tick();
  }

  void _stopSession() {
    _timer?.cancel();
    _circleController.stop();
    setState(() {
      _isRunning = false;
      _secondsRemainingTotal = 0;
    });
  }

  void _finishSession() {
    _timer?.cancel();
    _circleController.stop();
    setState(() => _isRunning = false);

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

  // Grows the circle on "Breathe In", shrinks on "Breathe Out",
  // holds steady on "Hold".
  void _animateCircleForCurrentPhase() {
    final label = _selectedPattern.phaseLabels[_currentPhaseIndex];
    final seconds = _selectedPattern.phaseSeconds[_currentPhaseIndex];

    _circleController.duration = Duration(seconds: seconds);

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
      if (!mounted) return;

      var shouldFinish = false;

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
          _animateCircleForCurrentPhase();
        }
      });

      if (shouldFinish) {
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
                  onTap: () => setState(() => _selectedPatternIndex = index),
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
                onPressed: _startSession,
                child: const Text('Start session'),
              ),
            ],
          ),
        ),
      ],
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
