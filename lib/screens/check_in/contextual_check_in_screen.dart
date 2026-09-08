import 'package:flutter/material.dart';

import '../../models/personalised_guidance_model.dart';
import '../../services/chat_service.dart';
import '../../utils/app_theme.dart';
import 'personalised_guidance_screen.dart';

/// A short, non-clinical check-in that gives the AI enough context to suggest
/// one safe step. It intentionally asks about the moment, not a diagnosis.
class ContextualCheckInScreen extends StatefulWidget {
  final ChatService? chatService;

  const ContextualCheckInScreen({
    super.key,
    this.chatService,
  });

  @override
  State<ContextualCheckInScreen> createState() =>
      _ContextualCheckInScreenState();
}

class _ContextualCheckInScreenState extends State<ContextualCheckInScreen> {
  static const _feelings = [
    'Low or sad',
    'Anxious or worried',
    'Overwhelmed',
    'Lonely or disconnected',
    'Frustrated or angry',
    'Numb or tired',
    'Okay, but I want to check in',
  ];

  static const _impacts = [
    'School or work',
    'Relationships or family',
    'Money',
    'Sleep or my body',
    'My thoughts',
    'Something else',
    'I am not sure',
  ];

  static const _needs = [
    'Calm my mind',
    'Understand what I am feeling',
    'Get something off my chest',
    'Figure out what to do',
    'Connect with someone',
  ];

  late final ChatService _chatService = widget.chatService ?? ChatService();
  final _contextController = TextEditingController();
  final _contextFocusNode = FocusNode();

  int _step = 0;
  String? _feeling;
  String? _impact;
  String? _need;
  String? _errorText;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contextController.dispose();
    _contextFocusNode.dispose();
    super.dispose();
  }

  String get _stepTitle {
    switch (_step) {
      case 0:
        return 'What feels strongest right now?';
      case 1:
        return 'What is taking the most energy?';
      case 2:
        return 'What would help most right now?';
      default:
        return 'Want to tell MindMate a little more?';
    }
  }

  String get _stepSubtitle {
    switch (_step) {
      case 0:
        return 'There is no wrong answer. Pick what feels closest.';
      case 1:
        return 'You can choose what is closest, even if it is not the whole story.';
      case 2:
        return 'Choose the kind of support that would feel useful.';
      default:
        return 'This is optional. Keep it short and share only what feels okay.';
    }
  }

  String? get _selectedValue {
    switch (_step) {
      case 0:
        return _feeling;
      case 1:
        return _impact;
      case 2:
        return _need;
      default:
        return null;
    }
  }

  List<String> get _options {
    switch (_step) {
      case 0:
        return _feelings;
      case 1:
        return _impacts;
      case 2:
        return _needs;
      default:
        return const [];
    }
  }

  void _select(String value) {
    setState(() {
      _errorText = null;
      switch (_step) {
        case 0:
          _feeling = value;
          break;
        case 1:
          _impact = value;
          break;
        case 2:
          _need = value;
          break;
      }
    });
  }

  void _next() {
    if (_step < 3 && _selectedValue == null) {
      setState(() => _errorText = 'Choose the option that feels closest.');
      return;
    }

    if (_step < 3) {
      setState(() {
        _step++;
        _errorText = null;
      });
      return;
    }

    _submit();
  }

  void _back() {
    if (_isSubmitting) return;
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _step--;
      _errorText = null;
    });
  }

  Future<void> _submit() async {
    final checkIn = ContextualCheckIn(
      feeling: _feeling!,
      impact: _impact!,
      need: _need!,
      context: _contextController.text.trim(),
    );

    setState(() {
      _errorText = null;
      _isSubmitting = true;
    });

    try {
      final result = await _chatService.sendGuidance(checkIn: checkIn);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PersonalisedGuidanceScreen(
            checkIn: checkIn,
            result: result,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorText = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isOptionalStep = _step == 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalised check-in'),
        leading: IconButton(
          onPressed: _isSubmitting ? null : _back,
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'A short pause before your next step.',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${_step + 1} of 4',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / 4,
                  minHeight: 5,
                  backgroundColor: AppTheme.surfaceBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _stepTitle,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _stepSubtitle,
                style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              if (!isOptionalStep)
                ..._options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CheckInOption(
                      label: option,
                      selected: _selectedValue == option,
                      onTap: () => _select(option),
                    ),
                  ),
                )
              else
                TextField(
                  controller: _contextController,
                  focusNode: _contextFocusNode,
                  maxLength: ContextualCheckIn.maxContextCharacters,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'For example: I have three deadlines this week...',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.42),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              if (_errorText != null) ...[
                const SizedBox(height: 4),
                Text(
                  _errorText!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'MindMate will offer support, not a diagnosis. You choose what to do next.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _isSubmitting ? null : _next,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isOptionalStep ? 'Find my next step' : 'Continue'),
              ),
              if (isOptionalStep)
                TextButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: const Text('Skip this question'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CheckInOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primary : AppTheme.surfaceBorder;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.12)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: selected ? 1.8 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: selected ? AppTheme.primary : AppTheme.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
