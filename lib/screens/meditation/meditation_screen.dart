import 'dart:async';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import '../../models/meditation_session_model.dart';
import '../../services/app_settings_controller.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';

class _MeditationSession {
  final String name;
  final String description;
  final List<String> guidingLines;

  const _MeditationSession({
    required this.name,
    required this.description,
    required this.guidingLines,
  });
}

class _MeditationCategory {
  final String name;
  final String description;
  final IconData icon;
  final List<_MeditationSession> sessions;

  const _MeditationCategory({
    required this.name,
    required this.description,
    required this.icon,
    required this.sessions,
  });
}

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  final List<_MeditationCategory> _categories = const [
    _MeditationCategory(
      name: 'Stress Relief',
      description: 'Release tension and settle a racing mind.',
      icon: Icons.spa_outlined,
      sessions: [
        _MeditationSession(
          name: 'Quick Reset',
          description: 'A short pause to unclench and breathe.',
          guidingLines: [
            'Find a comfortable position and let your shoulders drop.',
            'Notice any tension, and breathe into it.',
            'With each breath out, let a little more go.',
            'You do not need to fix anything right now. Just be here.',
          ],
        ),
        _MeditationSession(
          name: 'Release Tension',
          description: 'Scan through the body and soften what is tight.',
          guidingLines: [
            'Start at your forehead. Let it smooth out.',
            'Move down to your jaw. Unclench it, just slightly.',
            'Notice your hands. Let them go loose and heavy.',
            'Let your whole body feel supported and at ease.',
          ],
        ),
        _MeditationSession(
          name: 'Calm the Storm',
          description: 'For when everything feels like too much at once.',
          guidingLines: [
            'This feeling is loud right now, but you can take one moment at a time.',
            'You do not have to solve everything in this moment.',
            'Just this breath. Just this one.',
            'Let the next few minutes be a pause from the pressure.',
          ],
        ),
      ],
    ),
    _MeditationCategory(
      name: 'Sleep',
      description: 'Wind down and prepare your mind for rest.',
      icon: Icons.nightlight_outlined,
      sessions: [
        _MeditationSession(
          name: 'Wind Down',
          description: 'Ease out of the day and into rest.',
          guidingLines: [
            'Let your body sink into wherever you are lying.',
            'Slow your breathing, a little more with each cycle.',
            'There is nothing else you need to complete right now.',
            'Let your thoughts drift without following them.',
          ],
        ),
        _MeditationSession(
          name: 'Quiet Night',
          description: 'A gentle, story-like wind-down.',
          guidingLines: [
            'Picture a quiet room, softly lit and still.',
            'Every breath out lets you settle a little deeper.',
            'Nothing here needs your attention right now.',
            'Let the quiet hold you until rest arrives.',
          ],
        ),
        _MeditationSession(
          name: 'Deep Rest',
          description: 'For when your mind keeps replaying the day.',
          guidingLines: [
            'The day is over now. It does not need replaying.',
            'Let each thought pass by like a cloud, not a task.',
            'Your body already knows how to rest. Give it time.',
            'Soft breath in. Slow breath out. That is enough for now.',
          ],
        ),
      ],
    ),
    _MeditationCategory(
      name: 'Focus',
      description: 'Clear mental clutter before you begin.',
      icon: Icons.menu_book_outlined,
      sessions: [
        _MeditationSession(
          name: 'Clear Mind',
          description: 'Sweep away distractions before you start.',
          guidingLines: [
            'Sit upright, alert but relaxed.',
            'Take three slow breaths to arrive in this moment.',
            'Notice distracting thoughts, then set them aside for now.',
            'Begin when you feel ready.',
          ],
        ),
        _MeditationSession(
          name: 'Pre-Study Focus',
          description: 'Prime your mind right before studying.',
          guidingLines: [
            'Picture the task ahead calmly, one step at a time.',
            'You do not need to know it all yet. Just the next step.',
            'Let confidence settle in where doubt was sitting.',
            'Start with one clear, manageable action.',
          ],
        ),
        _MeditationSession(
          name: 'Deep Work Prep',
          description: 'For longer, harder focus sessions.',
          guidingLines: [
            'Breathe in for four counts, out for four counts.',
            'Let your mind narrow gently toward one task.',
            'Distractions can wait. This block of time is protected.',
            'Settle into focus now, steady and clear.',
          ],
        ),
      ],
    ),
    _MeditationCategory(
      name: 'Anxiety',
      description: 'Ground yourself when things feel uncertain.',
      icon: Icons.waves_outlined,
      sessions: [
        _MeditationSession(
          name: 'Grounding',
          description: 'Come back to the present moment.',
          guidingLines: [
            'Notice five things you can hear right now.',
            'Feel where your body meets the chair or floor.',
            'Notice the support beneath you in this moment.',
            'One breath at a time is all that is being asked of you.',
          ],
        ),
        _MeditationSession(
          name: 'Steady Breath',
          description: 'Slow the body to help settle the mind.',
          guidingLines: [
            'Breathe in slowly through your nose, four counts.',
            'Hold gently for a moment, without straining.',
            'Breathe out slowly, letting your shoulders drop.',
            'Each cycle can bring a little more steadiness.',
          ],
        ),
        _MeditationSession(
          name: 'Anxious Thoughts, Softened',
          description: 'Notice worry without being pulled into it.',
          guidingLines: [
            'A worried thought is a thought, not a fact.',
            'You can notice it without needing to follow it.',
            'Let it drift past like weather, not a verdict.',
            'Return gently to the breath and the ground beneath you.',
          ],
        ),
      ],
    ),
    _MeditationCategory(
      name: 'Gratitude',
      description: 'Notice small things that are going well.',
      icon: Icons.favorite_outline,
      sessions: [
        _MeditationSession(
          name: 'Small Joys',
          description: 'Notice the little good things.',
          guidingLines: [
            'Bring to mind one small thing you appreciate.',
            'Let yourself really notice it, even briefly.',
            'Notice how that appreciation feels in your body.',
            'Carry a little of that warmth with you today.',
          ],
        ),
        _MeditationSession(
          name: 'Gratitude for People',
          description: 'Reflect on someone who has helped you.',
          guidingLines: [
            'Think of a person who has helped you recently.',
            'Picture their face and notice what comes up.',
            'If you could, what would you want to tell them?',
            'Let that appreciation settle in, unhurried.',
          ],
        ),
        _MeditationSession(
          name: 'End of Day Thanks',
          description: 'Close the day by noticing what went right.',
          guidingLines: [
            'Think back over today. What went okay, even briefly?',
            'You do not need a big win. Small counts too.',
            'Let yourself acknowledge getting through today.',
            'Rest now, knowing today had something good in it.',
          ],
        ),
      ],
    ),
    _MeditationCategory(
      name: 'Morning',
      description: 'Start the day with a clear, calm mind.',
      icon: Icons.wb_sunny_outlined,
      sessions: [
        _MeditationSession(
          name: 'Fresh Start',
          description: 'Begin the day with a clean slate.',
          guidingLines: [
            'Take a deep breath in, welcoming the new day.',
            'Yesterday is over. Today has space in it.',
            'Notice how your body feels without judgment.',
            'Carry this calm with you as you begin.',
          ],
        ),
        _MeditationSession(
          name: 'Set an Intention',
          description: 'Choose one thing to carry through the day.',
          guidingLines: [
            'Set one small, kind intention for today.',
            'It does not need to be big. Just true to you.',
            'Picture yourself carrying it through your day.',
            'Begin with that intention in mind.',
          ],
        ),
        _MeditationSession(
          name: 'Morning Clarity',
          description: 'Clear the fog before the day gets busy.',
          guidingLines: [
            'Notice the quiet of this moment before the day starts.',
            'Breathe in clarity, breathe out leftover grogginess.',
            'Today has space in it, even if it does not feel that way yet.',
            'Start from a clear, steady place.',
          ],
        ),
      ],
    ),
  ];

  final List<int> _durationOptions = const [1, 3, 5];
  int? _openCategoryIndex;
  int? _selectedSessionIndex;
  int _selectedDurationMinutes = 3;
  bool _isRunning = false;
  int _secondsRemaining = 0;
  int _currentLineIndex = 0;
  Timer? _timer;
  Timer? _lineTimer;
  late AnimationController _pulseController;

  _MeditationCategory? get _openCategory => _openCategoryIndex == null
      ? null
      : _categories[_openCategoryIndex!];

  _MeditationSession? get _selectedSession {
    if (_openCategory == null || _selectedSessionIndex == null) return null;
    return _openCategory!.sessions[_selectedSessionIndex!];
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
      lowerBound: 0.97,
      upperBound: 1.03,
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
    final session = _selectedSession;
    if (session == null) return;

    final totalSeconds = _selectedDurationMinutes * 60;
    _timer?.cancel();
    _lineTimer?.cancel();

    setState(() {
      _isRunning = true;
      _secondsRemaining = totalSeconds;
      _currentLineIndex = 0;
    });
    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _secondsRemaining--);
      if (_secondsRemaining <= 0) _finishSession();
    });

    final secondsPerLine =
        (totalSeconds / session.guidingLines.length).floor().clamp(3, 999).toInt();
    _lineTimer = Timer.periodic(
      Duration(seconds: secondsPerLine),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _currentLineIndex =
              (_currentLineIndex + 1) % session.guidingLines.length;
        });
      },
    );
  }

  void _cancelSession() {
    _timer?.cancel();
    _lineTimer?.cancel();
    _pulseController.stop();
    if (!mounted) return;
    setState(() => _isRunning = false);
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    _lineTimer?.cancel();
    _pulseController.stop();

    final session = _selectedSession;
    final uid = context.read<AuthService>().currentUser?.uid;
    var historySaveFailed = false;

    if (uid != null && session != null && _openCategory != null) {
      try {
        final log = MeditationSessionModel(
          id: '',
          uid: uid,
          sessionType: '${_openCategory!.name} — ${session.name}',
          durationMinutes: _selectedDurationMinutes,
          date: DateTime.now(),
        );
        await context.read<FirestoreService>().addMeditationSession(log);
      } catch (_) {
        historySaveFailed = true;
      }
    }

    if (!mounted) return;
    setState(() => _isRunning = false);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Session complete'),
        content: Text(
          historySaveFailed
              ? 'You completed the session. It could not be added to your history this time.'
              : 'You completed a $_selectedDurationMinutes-minute ${session?.name ?? 'meditation'} session.',
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
    final title = _isRunning
        ? (_selectedSession?.name ?? 'Meditation')
        : (_openCategory?.name ?? 'Meditation');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: (!_isRunning && _openCategoryIndex != null)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  setState(() {
                    if (_selectedSessionIndex != null) {
                      _selectedSessionIndex = null;
                    } else {
                      _openCategoryIndex = null;
                    }
                  });
                },
              )
            : null,
      ),
      body: SafeArea(
        child: _isRunning
            ? _buildSessionView()
            : (_openCategoryIndex == null
                ? _buildJourneyView()
                : (_selectedSessionIndex == null
                    ? _buildSessionList()
                    : _buildSessionPreview())),
      ),
    );
  }

  Widget _buildJourneyView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradientLight,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YOUR MOMENT',
                  style: TextStyle(
                    color: Color(0xFF59646F),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'How do you want to feel?',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Pick a path that matches today. You only need one session to begin.',
                  style: TextStyle(
                    color: Color(0xFF59646F),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Choose a path',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          ...List.generate(_categories.length, (index) {
            final category = _categories[index];
            final color = index.isEven ? AppTheme.primary : AppTheme.secondary;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CategoryPathCard(
                category: category,
                color: color,
                onTap: () => setState(() {
                  _openCategoryIndex = index;
                  _selectedSessionIndex = null;
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    final category = _openCategory!;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: category.sessions.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              category.description,
              style: const TextStyle(
                color: AppTheme.textLight,
                fontSize: 14,
              ),
            ),
          );
        }

        final session = category.sessions[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => setState(() => _selectedSessionIndex = index - 1),
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(category.icon, color: AppTheme.secondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          session.description,
                          style: const TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textLight,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionPreview() {
    final session = _selectedSession!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            session.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            session.description,
            style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
          ),
          const SizedBox(height: 20),
          _buildDurationPicker(),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preview guidance',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 9),
                Text(
                  session.guidingLines.first,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Meet your guide',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: const ModelViewer(
              src: 'assets/assets/models/meditation_figure.glb',
              alt: 'A 3D figure representing your meditation guide',
              autoRotate: false,
              cameraControls: false,
              disableZoom: true,
              backgroundColor: Colors.transparent,
              cameraOrbit: '270deg 75deg 105%',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startSession,
            child: const Text('Begin session'),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationPicker() {
    return Row(
      children: [
        const Text(
          'Session length',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: _durationOptions.map((minutes) {
              final selected = _selectedDurationMinutes == minutes;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: SizedBox(
                      width: double.infinity,
                      child: Text('$minutes min', textAlign: TextAlign.center),
                    ),
                    selected: selected,
                    selectedColor: AppTheme.primary.withValues(alpha: 0.18),
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.primary : AppTheme.textLight,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedDurationMinutes = minutes);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionView() {
    final settings = context.watch<AppSettingsController>();
    final session = _selectedSession!;
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    final timeText = '$minutes:$seconds';
    final pulseScale = 1 + ((_pulseController.value - 1) * settings.animationIntensity);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _MeditationStat(label: 'Session', value: session.name)),
                Expanded(child: _MeditationStat(label: 'Time left', value: timeText)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 330,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppTheme.heroGradientLight,
              borderRadius: BorderRadius.circular(28),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: pulseScale,
                  child: const SizedBox(
                    width: 280,
                    height: 300,
                    child: ModelViewer(
                      src: 'assets/assets/models/meditation_figure.glb',
                      alt: 'A 3D figure of your meditation guide',
                      autoRotate: false,
                      cameraControls: false,
                      disableZoom: true,
                      backgroundColor: Colors.transparent,
                      cameraOrbit: '270deg 75deg 105%',
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      timeText,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'GUIDANCE',
                  style: TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  child: Text(
                    session.guidingLines[_currentLineIndex],
                    key: ValueKey(_currentLineIndex),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _cancelSession,
            icon: const Icon(Icons.close_rounded),
            label: const Text('End early'),
          ),
        ],
      ),
    );
  }
}

class _CategoryPathCard extends StatelessWidget {
  final _MeditationCategory category;
  final Color color;
  final VoidCallback onTap;

  const _CategoryPathCard({
    required this.category,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppTheme.surfaceBorder.withValues(alpha: 0.78),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(category.icon, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${category.sessions.length}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textLight,
            ),
          ],
        ),
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
        Text(
          label,
          style: const TextStyle(color: AppTheme.textLight, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
