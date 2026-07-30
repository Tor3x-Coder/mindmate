import 'dart:async';
import 'package:flutter/material.dart';

// Represents one breathing pattern, e.g. Box Breathing = 4s in, 4s hold,
// 4s out, 4s hold. Each entry in `phaseSeconds` pairs with a label in
// `phaseLabels` at the same position.
class _BreathingPattern {
  final String name;
  final String description;
  final List<String> phaseLabels;
  final List<int> phaseSeconds;

  const _BreathingPattern({
    required this.name,
    required this.description,
    required this.phaseLabels,
    required this.phaseSeconds,
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
    ),
    _BreathingPattern(
      name: '4-7-8 Breathing',
      description: 'A longer exhale helps relax the nervous system before rest.',
      phaseLabels: ['Breathe In', 'Hold', 'Breathe Out'],
      phaseSeconds: [4, 7, 8],
    ),
    _BreathingPattern(
      name: 'Simple Calm',
      description: 'Slow, even in-and-out breathing. Good for beginners.',
      phaseLabels: ['Breathe In', 'Breathe Out'],
      phaseSeconds: [5, 5],
    ),
  ];

  int _selectedPatternIndex = 0;

  bool _isRunning = false;
  int _currentPhaseIndex = 0;
  int _secondsRemainingInPhase = 0;
  int _completedCycles = 0;

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
    setState(() {
      _isRunning = true;
      _currentPhaseIndex = 0;
      _completedCycles = 0;
      _secondsRemainingInPhase = _selectedPattern.phaseSeconds[0];
    });

    _animateCircleForCurrentPhase();
    _tick();
  }

  void _stopSession() {
    _timer?.cancel();
    _circleController.stop();
    setState(() => _isRunning = false);
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

      setState(() {
        _secondsRemainingInPhase--;

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
    });
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose a breathing exercise',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ...List.generate(_patterns.length, (index) {
            final pattern = _patterns[index];
            final isSelected = _selectedPatternIndex == index;

            return GestureDetector(
              onTap: () => setState(() => _selectedPatternIndex = index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5B9A8B).withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF5B9A8B)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pattern.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pattern.description,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _startSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9A8B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // Shown while actively breathing along.
  Widget _buildSessionView() {
    final currentLabel = _selectedPattern.phaseLabels[_currentPhaseIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            _selectedPattern.name,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Cycles completed: $_completedCycles',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const Spacer(),

          // The animated breathing circle.
          AnimatedBuilder(
            animation: _circleController,
            builder: (context, child) {
              // Circle scales between 60% and 100% of its max size.
              final scale = 0.6 + (_circleController.value * 0.4);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF5B9A8B).withValues(alpha: 0.5),
                        const Color(0xFF9B8ECF).withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),
          Text(
            currentLabel,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_secondsRemainingInPhase',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w300,
              color: Color(0xFF5B9A8B),
            ),
          ),

          const Spacer(),

          OutlinedButton(
            onPressed: _stopSession,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Stop'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}