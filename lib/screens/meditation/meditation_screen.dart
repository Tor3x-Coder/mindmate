import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meditation_session_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

// NOTE: The original spec asks for guided AUDIO in each session. There's
// no audio package installed and no recorded voice-over files yet, so
// this version uses a silent timer with on-screen guiding text instead.
// If real audio is added later, this is the file to come back to.

class _MeditationType {
  final String name;
  final String description;
  final IconData icon;
  final List<String> guidingLines;

  const _MeditationType({
    required this.name,
    required this.description,
    required this.icon,
    required this.guidingLines,
  });
}

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final List<_MeditationType> _types = const [
    _MeditationType(
      name: 'Stress Relief',
      description: 'Release tension and settle a racing mind.',
      icon: Icons.spa_outlined,
      guidingLines: [
        'Find a comfortable position and let your shoulders drop.',
        'Notice any tension, and breathe into it.',
        'With each breath out, let a little more go.',
        'You don\'t need to fix anything right now. Just be here.',
      ],
    ),
    _MeditationType(
      name: 'Sleep Meditation',
      description: 'Wind down and prepare your mind for rest.',
      icon: Icons.nightlight_outlined,
      guidingLines: [
        'Let your body sink into wherever you\'re lying.',
        'Slow your breathing, a little more with each cycle.',
        'There\'s nothing left to do today.',
        'Let your thoughts drift, without following any of them.',
      ],
    ),
    _MeditationType(
      name: 'Study Focus',
      description: 'Clear mental clutter before a study session.',
      icon: Icons.menu_book_outlined,
      guidingLines: [
        'Sit upright, alert but relaxed.',
        'Take three slow breaths to arrive fully in this moment.',
        'Picture the task ahead, calmly, one step at a time.',
        'You\'re ready to begin when you open your eyes.',
      ],
    ),
    _MeditationType(
      name: 'Morning Meditation',
      description: 'Start the day with a clear, calm mind.',
      icon: Icons.wb_sunny_outlined,
      guidingLines: [
        'Take a deep breath in, welcoming the new day.',
        'Set one small, kind intention for today.',
        'Notice how your body feels, without judgment.',
        'Carry this calm with you as you begin your day.',
      ],
    ),
    _MeditationType(
      name: 'Gratitude Meditation',
      description: 'Shift focus toward what\'s going well.',
      icon: Icons.favorite_outline,
      guidingLines: [
        'Bring to mind one small thing you\'re grateful for.',
        'Let yourself really feel that, even briefly.',
        'Think of a person who has helped you recently.',
        'Notice how gratitude feels in your body right now.',
      ],
    ),
  ];

  final List<int> _durationOptions = const [1, 3, 5];

  int _selectedTypeIndex = 0;
  int _selectedDurationMinutes = 3;

  bool _isRunning = false;
  int _secondsRemaining = 0;
  int _currentLineIndex = 0;
  Timer? _timer;
  Timer? _lineTimer;

  _MeditationType get _selectedType => _types[_selectedTypeIndex];

  @override
  void dispose() {
    _timer?.cancel();
    _lineTimer?.cancel();
    super.dispose();
  }

  void _startSession() {
    final totalSeconds = _selectedDurationMinutes * 60;

    setState(() {
      _isRunning = true;
      _secondsRemaining = totalSeconds;
      _currentLineIndex = 0;
    });

    // Countdown timer for the session itself.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() => _secondsRemaining--);

      if (_secondsRemaining <= 0) {
        _finishSession();
      }
    });

    // Cycles through the guiding text every several seconds so it
    // doesn't feel static during the session.
    final secondsPerLine =
        (totalSeconds / _selectedType.guidingLines.length).floor();
    _lineTimer = Timer.periodic(
      Duration(seconds: secondsPerLine.clamp(3, 999)),
      (timer) {
        if (!mounted) return;
        setState(() {
          _currentLineIndex =
              (_currentLineIndex + 1) % _selectedType.guidingLines.length;
        });
      },
    );
  }

  void _cancelSession() {
    _timer?.cancel();
    _lineTimer?.cancel();
    setState(() => _isRunning = false);
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    _lineTimer?.cancel();

    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid != null) {
      try {
        final session = MeditationSessionModel(
          id: '', // Firestore generates this automatically
          uid: uid,
          sessionType: _selectedType.name,
          durationMinutes: _selectedDurationMinutes,
          date: DateTime.now(),
        );
        await firestoreService.addMeditationSession(session);
      } catch (_) {
        // If saving fails we still let the user finish their session
        // peacefully rather than interrupting them with an error popup.
      }
    }

    if (!mounted) return;

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
          '${_selectedType.name} session.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation'),
      ),
      body: SafeArea(
        child: _isRunning ? _buildSessionView() : _buildSelectionView(),
      ),
    );
  }

  Widget _buildSelectionView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Choose a session',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ...List.generate(_types.length, (index) {
            final type = _types[index];
            final isSelected = _selectedTypeIndex == index;

            return GestureDetector(
              onTap: () => setState(() => _selectedTypeIndex = index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF9B8ECF).withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF9B8ECF)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      type.icon,
                      color: isSelected
                          ? const Color(0xFF9B8ECF)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            type.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
          const Text(
            'Session length',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: _durationOptions.map((minutes) {
              final isSelected = _selectedDurationMinutes == minutes;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedDurationMinutes = minutes),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF9B8ECF)
                          : Colors.grey.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$minutes min',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _startSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B8ECF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Begin Session', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionView() {
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    final timeText =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            _selectedType.name,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const Spacer(),

          // A gently pulsing circle to focus on, similar spirit to the
          // breathing screen but without the phase-based grow/shrink.
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF9B8ECF).withValues(alpha: 0.5),
                  const Color(0xFF5B9A8B).withValues(alpha: 0.25),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                _selectedType.icon,
                size: 48,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 28),
          Text(
            timeText,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w300,
              color: Color(0xFF9B8ECF),
            ),
          ),

          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _selectedType.guidingLines[_currentLineIndex],
              key: ValueKey(_currentLineIndex),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const Spacer(),
          OutlinedButton(
            onPressed: _cancelSession,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('End Early'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}