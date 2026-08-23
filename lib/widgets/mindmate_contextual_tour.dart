import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import 'mindmate_guide_figure.dart';

class MindMateTourStep {
  final String label;
  final String title;
  final String message;

  const MindMateTourStep({
    required this.label,
    required this.title,
    required this.message,
  });
}

class MindMateContextualTour extends StatelessWidget {
  final MindMateTourStep step;
  final int stepIndex;
  final int stepCount;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final Duration animationDuration;

  const MindMateContextualTour({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.stepCount,
    required this.onSkip,
    required this.onNext,
    required this.animationDuration,
  });

  bool get _isLastStep => stepIndex == stepCount - 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Semantics(
      liveRegion: true,
      label: '${step.label}. ${step.title}. ${step.message}',
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AnimatedSwitcher(
              duration: animationDuration,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0.04),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey(stepIndex),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppTheme.surfaceBorder.withValues(
                      alpha: isDark ? 0.28 : 0.68,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.28 : 0.13,
                      ),
                      blurRadius: 32,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MindMateGuideFigure(size: 64),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${step.label.toUpperCase()} · ${stepIndex + 1} OF $stepCount',
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                step.title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      step.message,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: onSkip,
                          child: const Text('Skip tour'),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(stepCount, (index) {
                            final selected = index == stepIndex;
                            return AnimatedContainer(
                              duration: animationDuration,
                              width: selected ? 18 : 6,
                              height: 6,
                              margin: const EdgeInsets.only(left: 5),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.surfaceBorder,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(width: 14),
                        FilledButton.icon(
                          onPressed: onNext,
                          icon: Icon(
                            _isLastStep
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            size: 17,
                          ),
                          label: Text(_isLastStep ? 'Got it' : 'Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
