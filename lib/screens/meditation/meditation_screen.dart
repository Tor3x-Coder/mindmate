import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meditation_session_model.dart';
import '../../services/app_settings_controller.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

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

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
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
  late AnimationController _pulseController;

  _MeditationType get _selectedType => _types[_selectedTypeIndex];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
      lowerBound: 0.94,
      upperBound: 1.06,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lineTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startSession() {
    final totalSeconds = _selectedDurationMinutes * 60;

    setState(() {
      _isRunning = true;
      _secondsRemaining = totalSeconds;
      _currentLineIndex = 0;
    });
    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsRemaining--);
      if (_secondsRemaining <= 0) {
        _finishSession();
      }
    });

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
    _pulseController.stop();
    setState(() => _isRunning = false);
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    _lineTimer?.cancel();
    _pulseController.stop();

    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final uid = authService.currentUser?.uid;

    if (uid != null) {
      try {
        final session = MeditationSessionModel(
          id: '',
          uid: uid,
          sessionType: _selectedType.name,
          durationMinutes: _selectedDurationMinutes,
          date: DateTime.now(),
        );
        await firestoreService.addMeditationSession(session);
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _isRunning = false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      appBar: AppBar(title: const Text('Meditation')),
      body: SafeArea(
        child: _isRunning ? _buildSessionView() : _buildSelectionView(),
      ),
    );
  }

  Widget _buildSelectionView() {
    final type = _selectedType;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppTheme.textDark;

    return Stack(
      children: [
        const Positioned(
          top: -50,
          right: -50,
          child: _MeditationGlow(size: 190, color: Color(0x229B8ECF)),
        ),
        const Positioned(
          top: 180,
          left: -80,
          child: _MeditationGlow(size: 220, color: Color(0x185B9A8B)),
        ),
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroGradientFor(Theme.of(context).brightness),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meditation room',
                      style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a session mood, settle into the timer, and let the interface stay quiet around your focus.',
                      style: TextStyle(color: textColor.withValues(alpha: 0.74), fontSize: 15),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MeditationPill(icon: type.icon, label: type.name, isDark: isDark),
                        _MeditationPill(
                          icon: Icons.timer_outlined,
                          label: '$_selectedDurationMinutes minute session',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Choose a session', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ...List.generate(_types.length, (index) {
                final loopType = _types[index];
                final isSelected = _selectedTypeIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTypeIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? AppTheme.secondary : AppTheme.surfaceBorder.withValues(alpha: 0.75),
                        width: isSelected ? 1.6 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppTheme.secondary.withValues(alpha: 0.14), blurRadius: 24, spreadRadius: 1)]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Icon(loopType.icon, color: AppTheme.secondary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(loopType.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(loopType.description, style: const TextStyle(fontSize: 13, color: AppTheme.textLight)),
                            ],
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_circle_rounded, color: AppTheme.secondary),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text('Session length', style: Theme.of(context).textTheme.titleLarge),
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
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.accentGradient : null,
                        color: isSelected ? null : AppTheme.surfaceAlt.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : AppTheme.surfaceBorder.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Text(
                        '$minutes min',
                        style: TextStyle(color: Colors.white, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.75)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Preview guidance', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(type.guidingLines.first, style: const TextStyle(color: AppTheme.textLight)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _startSession, child: const Text('Begin session')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSessionView() {
    final settings = context.watch<AppSettingsController>();
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    final timeText = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final totalSeconds = (_selectedDurationMinutes * 60).clamp(1, 9999);
    final progress = 1 - (_secondsRemaining / totalSeconds);
    final pulseScale = 1 + ((_pulseController.value - 1) * settings.animationIntensity);

    return Stack(
      children: [
        Positioned(top: 80, left: -50, child: _MeditationGlow(size: 220, color: AppTheme.secondary.withValues(alpha: 0.16))),
        Positioned(top: 210, right: -50, child: _MeditationGlow(size: 220, color: AppTheme.primary.withValues(alpha: 0.12))),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.8)),
                ),
                child: Row(
                  children: [
                    Expanded(child: _MeditationStat(label: 'Session', value: _selectedType.name)),
                    Expanded(child: _MeditationStat(label: 'Time left', value: timeText)),
                  ],
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: pulseScale,
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size.square(300),
                            painter: _MeditationRingPainter(
                              progress: progress,
                              activeColor: AppTheme.secondary,
                              trackColor: AppTheme.surfaceBorder.withValues(alpha: 0.35),
                            ),
                          ),
                          Container(
                            width: 238,
                            height: 238,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.secondary.withValues(alpha: 0.22),
                                  blurRadius: 30 * settings.animationIntensity,
                                  spreadRadius: 4,
                                ),
                              ],
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.20),
                                  AppTheme.secondary.withValues(alpha: 0.50),
                                  AppTheme.primary.withValues(alpha: 0.24),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 164,
                            height: 164,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF161D2D).withValues(alpha: 0.76),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_selectedType.icon, size: 42, color: Colors.white),
                                const SizedBox(height: 12),
                                Text(
                                  timeText,
                                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w300),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.surfaceBorder.withValues(alpha: 0.8)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Guidance',
                      style: TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      child: Text(
                        _selectedType.guidingLines[_currentLineIndex],
                        key: ValueKey(_currentLineIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17, fontStyle: FontStyle.italic, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(onPressed: _cancelSession, icon: const Icon(Icons.close_rounded), label: const Text('End early')),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeditationPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _MeditationPill({required this.icon, required this.label, required this.isDark});

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
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MeditationStat extends StatelessWidget {
  final String label;
  final String value;

  const _MeditationStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _MeditationGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _MeditationGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _MeditationRingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  const _MeditationRingPainter({required this.progress, required this.activeColor, required this.trackColor});

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
      ..shader = SweepGradient(colors: [AppTheme.primary.withValues(alpha: 0.55), activeColor, Colors.white]).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.5708, 6.28318 * progress.clamp(0, 1), false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _MeditationRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.activeColor != activeColor || oldDelegate.trackColor != trackColor;
  }
}