import 'dart:async';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:provider/provider.dart';
import '../../models/meditation_session_model.dart';
import '../../services/app_settings_controller.dart';
import '../../services/audio_guide_service.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/audio_assets.dart';

class _MeditationSession {
  final String name;
  final String description;
  final List<String> guidingLines;
  final String? introAudioAsset;
  final List<String> audioPrompts;

  const _MeditationSession({
    required this.name,
    required this.description,
    required this.guidingLines,
    this.introAudioAsset,
    this.audioPrompts = const [],
  });

  bool get hasIntroAudio => introAudioAsset != null;
  bool get hasGuidedAudio => audioPrompts.length == guidingLines.length;
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
  static const double _narrationSpeed = 0.88;

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
            'Settle into a position that feels easy. Let your hands rest, and allow your shoulders to drop away from your ears.',
            'Notice where your body is holding tension. You do not need to force it away. Breathe gently into that space.',
            'As you breathe out, imagine releasing just a little of the pressure. Nothing else needs to be solved in this moment.',
            'Take one more unhurried breath. Notice any small sense of space you have created, and carry it with you when you are ready.',
          ],
          introAudioAsset: MindMateAudioAssets.quickResetIntro,
          audioPrompts: MindMateAudioAssets.quickResetPrompts,
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
  bool _isPaused = false;
  int _secondsRemaining = 0;
  int _currentLineIndex = 0;
  int _secondsPerLine = 0;
  int _secondsUntilNextLine = 0;
  Timer? _timer;
  AudioGuideService? _audioGuide;
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioGuide ??= context.read<AudioGuideService>();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    final audioGuide = _audioGuide;
    if (audioGuide != null) unawaited(audioGuide.stop());
    super.dispose();
  }

  void _startSession() {
    final session = _selectedSession;
    if (session == null) return;

    final totalSeconds = _selectedDurationMinutes * 60;
    _timer?.cancel();
    _secondsPerLine =
        (totalSeconds / session.guidingLines.length).floor().clamp(3, 999).toInt();

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _secondsRemaining = totalSeconds;
      _currentLineIndex = 0;
      _secondsUntilNextLine = _secondsPerLine;
    });
    _pulseController.repeat(reverse: true);

    if (context.read<AppSettingsController>().soundEnabled &&
        session.hasGuidedAudio) {
      unawaited(_playMeditationPrompt(0, showError: true));
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isPaused) return;

      var shouldFinish = false;
      int? nextPromptIndex;

      setState(() {
        _secondsRemaining--;
        _secondsUntilNextLine--;

        if (_secondsRemaining <= 0) {
          shouldFinish = true;
          return;
        }

        if (_secondsUntilNextLine <= 0 &&
            _currentLineIndex < session.guidingLines.length - 1) {
          _currentLineIndex++;
          _secondsUntilNextLine = _secondsPerLine;
          nextPromptIndex = _currentLineIndex;
        }
      });

      if (nextPromptIndex != null &&
          context.read<AppSettingsController>().soundEnabled &&
          session.hasGuidedAudio) {
        unawaited(_playMeditationPrompt(nextPromptIndex!));
      }

      if (shouldFinish) {
        timer.cancel();
        unawaited(_finishSession());
      }
    });
  }

  Future<void> _playMeditationIntro({bool showError = false}) async {
    final introAsset = _selectedSession?.introAudioAsset;
    final audioGuide = _audioGuide;
    if (introAsset == null || audioGuide == null) return;

    final played = await audioGuide.playAsset(
      introAsset,
      speed: _narrationSpeed,
    );
    if (!played && showError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice preview could not start. The session is still available.'),
        ),
      );
    }
  }

  Future<void> _playMeditationPrompt(
    int index, {
    bool showError = false,
  }) async {
    final session = _selectedSession;
    final audioGuide = _audioGuide;
    if (session == null ||
        audioGuide == null ||
        !session.hasGuidedAudio ||
        index < 0 ||
        index >= session.audioPrompts.length) {
      return;
    }

    final played = await audioGuide.playAsset(
      session.audioPrompts[index],
      speed: _narrationSpeed,
    );
    if (!played && showError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Guided audio could not start. Text guidance is still available.'),
        ),
      );
    }
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

    if (_isRunning && !_isPaused && _selectedSession?.hasGuidedAudio == true) {
      await _playMeditationPrompt(_currentLineIndex, showError: true);
    }
  }

  void _togglePause() {
    if (!_isRunning) return;

    setState(() => _isPaused = !_isPaused);
    final audioGuide = _audioGuide;

    if (_isPaused) {
      _pulseController.stop();
      if (audioGuide != null) unawaited(audioGuide.pause());
    } else {
      _pulseController.repeat(reverse: true);
      if (audioGuide != null &&
          context.read<AppSettingsController>().soundEnabled) {
        if (audioGuide.hasLoadedAudio) {
          unawaited(audioGuide.resume());
        } else {
          unawaited(_playMeditationPrompt(_currentLineIndex, showError: true));
        }
      }
    }
  }

  void _replayCurrentPrompt() {
    final session = _selectedSession;
    if (session?.hasGuidedAudio != true ||
        !context.read<AppSettingsController>().soundEnabled) {
      return;
    }
    unawaited(_playMeditationPrompt(_currentLineIndex, showError: true));
  }

  void _cancelSession() {
    _timer?.cancel();
    _pulseController.stop();
    final audioGuide = _audioGuide;
    if (audioGuide != null) unawaited(audioGuide.stop());
    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    _pulseController.stop();

    final session = _selectedSession;
    final uid = context.read<AuthService>().currentUser?.uid;
    final firestore = context.read<FirestoreService>();
    final category = _openCategory;
    var historySaveFailed = false;

    await _audioGuide?.stop();

    if (uid != null && session != null && category != null) {
      try {
        final log = MeditationSessionModel(
          id: '',
          uid: uid,
          sessionType: '${category.name} — ${session.name}',
          durationMinutes: _selectedDurationMinutes,
          date: DateTime.now(),
        );
        await firestore.addMeditationSession(log);
      } catch (_) {
        historySaveFailed = true;
      }
    }

    if (!mounted) return;
    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

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
                  final audioGuide = _audioGuide;
                  if (audioGuide != null) unawaited(audioGuide.stop());
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
            onTap: () {
              final audioGuide = _audioGuide;
              if (audioGuide != null) unawaited(audioGuide.stop());
              setState(() => _selectedSessionIndex = index - 1);
            },
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
          _buildMeditationAudioCard(session),
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
                  'What to expect',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 9),
                const Text(
                  'A few gentle prompts will appear during the session, with quiet space between them.',
                  style: TextStyle(
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

  Widget _buildMeditationAudioCard(_MeditationSession session) {
    final settings = context.watch<AppSettingsController>();
    final audioGuide = context.watch<AudioGuideService>();
    final hasAudio = session.hasGuidedAudio;
    final previewAsset = session.introAudioAsset;
    final previewPlaying = previewAsset != null &&
        audioGuide.isCurrentAsset(previewAsset) &&
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
            hasAudio ? Icons.graphic_eq_rounded : Icons.subtitles_rounded,
            color: hasAudio ? AppTheme.primary : AppTheme.textLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasAudio ? 'Meet your session guide' : 'Text guidance',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(
                  hasAudio
                      ? 'Hear a short welcome. Guidance begins after you tap Begin.'
                      : 'Natural narration is still being added to this session.',
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (session.hasIntroAudio && settings.soundEnabled)
            IconButton(
              tooltip: previewPlaying ? 'Stop introduction' : 'Meet your guide',
              onPressed: () {
                if (previewPlaying) {
                  unawaited(audioGuide.stop());
                } else {
                  unawaited(_playMeditationIntro(showError: true));
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
          _buildMeditationSessionControls(session, settings),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _cancelSession,
            icon: const Icon(Icons.close_rounded),
            label: const Text('End early'),
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationSessionControls(
    _MeditationSession session,
    AppSettingsController settings,
  ) {
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
        if (session.hasGuidedAudio)
          OutlinedButton.icon(
            onPressed: settings.soundEnabled ? _replayCurrentPrompt : null,
            icon: const Icon(Icons.replay_rounded),
            label: const Text('Replay prompt'),
          ),
        if (session.hasGuidedAudio)
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
