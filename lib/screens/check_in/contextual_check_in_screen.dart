import 'package:flutter/material.dart';
import '../../models/check_in_context_model.dart';
import '../../utils/app_theme.dart';
import 'guidance_loading_screen.dart';

class ContextualCheckInScreen extends StatefulWidget {
  const ContextualCheckInScreen({super.key});

  @override
  State<ContextualCheckInScreen> createState() =>
      _ContextualCheckInScreenState();
}

class _ContextualCheckInScreenState extends State<ContextualCheckInScreen> {
  int _step = 0;
  CheckInFeeling? _feeling;
  CheckInEnergySource? _energy;
  CheckInNeed? _need;
  final TextEditingController _freeTextController = TextEditingController();

  static const int _totalSteps = 4;

  @override
  void dispose() {
    _freeTextController.dispose();
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _feeling != null;
      case 1:
        return _energy != null;
      case 2:
        return _need != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _next() {
    if (!_canContinue) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step--);
    }
  }

  void _submit() {
    if (_feeling == null || _energy == null || _need == null) return;

    final contextModel = CheckInContext(
      feeling: _feeling!,
      energySource: _energy!,
      need: _need!,
      freeText: _freeTextController.text,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GuidanceLoadingScreen(checkInContext: contextModel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check in'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Step ${_step + 1} of $_totalSteps',
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildStepContent(onSurface),
                    const SizedBox(height: 24),
                    const Text(
                      'Your check-in is a reflection, not a diagnosis. MindMate will suggest one safe step, not a label.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: (_step + 1) / _totalSteps,
          minHeight: 5,
          backgroundColor: AppTheme.surfaceBorder,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      ),
    );
  }

  List<Widget> _buildStepContent(Color onSurface) {
    switch (_step) {
      case 0:
        return [
          Text(
            'What feels strongest right now?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pick what feels closest. There is no wrong answer.',
            style: TextStyle(color: AppTheme.textLight, fontSize: 14),
          ),
          const SizedBox(height: 18),
          ...CheckInFeeling.values.map(
            (feeling) => _buildFeelingOption(feeling),
          ),
        ];
      case 1:
        return [
          Text(
            'What is taking the most energy?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'What has been costing you the most lately?',
            style: TextStyle(color: AppTheme.textLight, fontSize: 14),
          ),
          const SizedBox(height: 18),
          ...CheckInEnergySource.values.map(
            (energy) => _buildEnergyOption(energy),
          ),
        ];
      case 2:
        return [
          Text(
            'What would help most right now?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose the kind of support that feels most useful in this moment.',
            style: TextStyle(color: AppTheme.textLight, fontSize: 14),
          ),
          const SizedBox(height: 18),
          ...CheckInNeed.values.map(
            (need) => _buildNeedOption(need),
          ),
        ];
      case 3:
        return [
          Text(
            'Want to tell MindMate a little more?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Optional, bounded, and only used to personalise your next step. Max 500 characters.',
            style: TextStyle(color: AppTheme.textLight, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _freeTextController,
            maxLines: 5,
            maxLength: CheckInContext.maxFreeTextChars,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText:
                  'For example: I have a lot of deadlines and I keep putting things off...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              counterText:
                  '${_freeTextController.text.length}/${CheckInContext.maxFreeTextChars}',
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.secondary.withValues(alpha: 0.30),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 18, color: AppTheme.textLight),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This note is only used for this check-in. It is not saved as a journal entry and not shared.',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildFeelingOption(CheckInFeeling feeling) {
    final isSelected = _feeling == feeling;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _feeling = feeling),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.13)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.surfaceBorder.withValues(alpha: 0.85),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(feeling.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  feeling.displayLabel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyOption(CheckInEnergySource energy) {
    final isSelected = _energy == energy;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _energy = energy),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary.withValues(alpha: 0.13)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary
                  : AppTheme.surfaceBorder.withValues(alpha: 0.85),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _iconForEnergy(energy),
                color: isSelected ? AppTheme.primary : AppTheme.textLight,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  energy.displayLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeedOption(CheckInNeed need) {
    final isSelected = _need == need;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => setState(() => _need = need),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.secondary.withValues(alpha: 0.18)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? AppTheme.secondary
                  : AppTheme.surfaceBorder.withValues(alpha: 0.85),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _iconForNeed(need),
                color: isSelected ? AppTheme.secondary : AppTheme.textLight,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  need.displayLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.secondary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.secondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForEnergy(CheckInEnergySource energy) {
    switch (energy) {
      case CheckInEnergySource.schoolOrWork:
        return Icons.school_outlined;
      case CheckInEnergySource.relationshipsOrFamily:
        return Icons.people_outline_rounded;
      case CheckInEnergySource.money:
        return Icons.account_balance_wallet_outlined;
      case CheckInEnergySource.sleepOrBody:
        return Icons.bedtime_outlined;
      case CheckInEnergySource.myThoughts:
        return Icons.psychology_outlined;
      case CheckInEnergySource.somethingElse:
        return Icons.category_outlined;
      case CheckInEnergySource.notSure:
        return Icons.help_outline_rounded;
    }
  }

  IconData _iconForNeed(CheckInNeed need) {
    switch (need) {
      case CheckInNeed.calmMind:
        return Icons.air_rounded;
      case CheckInNeed.understandFeeling:
        return Icons.lightbulb_outline_rounded;
      case CheckInNeed.getOffChest:
        return Icons.edit_note_rounded;
      case CheckInNeed.figureOut:
        return Icons.checklist_rounded;
      case CheckInNeed.connectSomeone:
        return Icons.favorite_border_rounded;
    }
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: _canContinue ? AppTheme.accentGradient : null,
              color: _canContinue ? null : AppTheme.surfaceBorder,
              borderRadius: BorderRadius.circular(26),
            ),
            child: ElevatedButton(
              onPressed: _canContinue ? _next : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Text(
                _step == _totalSteps - 1 ? 'Find my next step' : 'Continue',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
