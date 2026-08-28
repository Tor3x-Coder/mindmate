import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class FloatingTideDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const FloatingTideDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// A calm four-destination bottom bar with one animated Tide orb.
///
/// The orb is decorative: selected icons, labels, semantics, and keyboard
/// focus still communicate state without relying on motion or colour alone.
class FloatingTideNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<FloatingTideDestination> destinations;
  final double animationIntensity;

  const FloatingTideNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.animationIntensity = 1,
  }) : assert(destinations.length > 1);

  static const double _horizontalMargin = 10;
  static const double _orbSize = 48;
  static const double _barHeight = 92;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : Duration(
            milliseconds: (520 / animationIntensity.clamp(0.6, 1.3)).round(),
          );

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: SizedBox(
          height: _barHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth =
                  constraints.maxWidth - (_horizontalMargin * 2);
              final segmentWidth = availableWidth / destinations.length;
              final orbLeft = _horizontalMargin +
                  (segmentWidth * selectedIndex) +
                  ((segmentWidth - _orbSize) / 2);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 4,
                    left: _horizontalMargin,
                    right: _horizontalMargin,
                    bottom: 2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppTheme.surfaceBorder.withValues(
                            alpha: isDark ? 0.28 : 0.72,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.18 : 0.07,
                            ),
                            blurRadius: 22,
                            offset: const Offset(0, 9),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: duration,
                    curve: Curves.easeInOutCubic,
                    left: orbLeft,
                    top: 8,
                    width: _orbSize,
                    height: _orbSize,
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(selectedIndex),
                      duration: duration,
                      tween: Tween(begin: 0, end: 1),
                      builder: (context, value, child) {
                        final hop = reduceMotion
                            ? 0.0
                            : -math.sin(value * math.pi) * 2;
                        return Transform.translate(
                          offset: Offset(0, hop),
                          child: child,
                        );
                      },
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.accentGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    top: 8,
                    left: _horizontalMargin,
                    right: _horizontalMargin,
                    child: Row(
                      children: List.generate(destinations.length, (index) {
                        final destination = destinations[index];
                        final selected = index == selectedIndex;
                        final contentColor = selected
                            ? Colors.white
                            : theme.colorScheme.onSurface.withValues(alpha: 0.58);

                        return Expanded(
                          child: Semantics(
                            button: true,
                            selected: selected,
                            label: destination.label,
                            child: InkWell(
                              onTap: () => onDestinationSelected(index),
                              borderRadius: BorderRadius.circular(22),
                              focusColor: AppTheme.primary.withValues(alpha: 0.12),
                              hoverColor: AppTheme.primary.withValues(alpha: 0.07),
                              splashColor: AppTheme.primary.withValues(alpha: 0.12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: _orbSize,
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: duration,
                                        child: Icon(
                                          selected
                                              ? destination.selectedIcon
                                              : destination.icon,
                                          key: ValueKey(selected),
                                          color: contentColor,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: duration,
                                    style: TextStyle(
                                      color: selected
                                          ? AppTheme.primary
                                          : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.58),
                                      fontSize: 11.5,
                                      fontWeight: selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                    ),
                                    child: Text(
                                      destination.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
