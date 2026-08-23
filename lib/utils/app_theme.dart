import 'package:flutter/material.dart';

/// MindMate's Option A colour system: Quiet Tide.
///
/// The palette is calm and mature without looking too clinical. Deep ink is
/// used for readable text and dark surfaces, Tide is the primary action colour,
/// Sea Glass is a soft supporting colour, Sand adds warmth, and Coral is
/// reserved for danger or important attention states.
class AppTheme {
  // Quiet Tide palette
  static const Color primary = Color(0xFF2E7D73); // Tide
  static const Color secondary = Color(0xFF78AFA2); // Sea Glass, deepened for UI
  static const Color accent = Color(0xFFD9776A); // Coral

  static const Color background = Color(0xFF12232B); // Dark ink background
  static const Color cardBackground = Color(0xFF1B3238);
  static const Color surfaceAlt = Color(0xFF244047);
  static const Color surfaceBorder = Color(0xFFC9DED8);

  static const Color textDark = Color(0xFF182A35); // Ink
  static const Color textLight = Color(0xFF68767C);
  static const Color textOnDark = Color(0xFFF4F8F6);
  static const Color danger = Color(0xFFD9776A); // Coral
  static const Color success = Color(0xFF4F987E);

  static const Color sand = Color(0xFFF4E7D4);
  static const Color seaGlass = Color(0xFFB8DFD2);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF294B4A),
      Color(0xFF1B343A),
      Color(0xFF12232B),
    ],
  );

  static const LinearGradient heroGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE1F2EC),
      Color(0xFFEAF3F0),
      Color(0xFFF4E7D4),
    ],
  );

  static LinearGradient heroGradientFor(Brightness brightness) {
    return brightness == Brightness.dark ? heroGradient : heroGradientLight;
  }

  // Kept as a gradient for existing UI components, but both stops stay dark
  // enough for white button text to remain readable.
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E7D73),
      Color(0xFF4F987E),
    ],
  );

  static ThemeData get lightTheme {
    return _buildTheme(Brightness.light);
  }

  static ThemeData get darkTheme {
    return _buildTheme(Brightness.dark);
  }

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final backgroundColor = isDark ? background : const Color(0xFFF5F8F6);
    final surfaceColor = isDark ? cardBackground : Colors.white;
    final panelColor = isDark ? surfaceAlt : const Color(0xFFEDF6F2);
    final onSurface = isDark ? textOnDark : textDark;
    final mutedText = isDark ? textLight : const Color(0xFF68767C);
    final dividerColor = isDark ? const Color(0xFF355158) : const Color(0xFFC9DED8);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: textDark,
        error: danger,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: onSurface,
      ),
      fontFamily: 'Poppins',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 68,
        titleSpacing: 20,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: onSurface),
        bodyMedium: TextStyle(color: onSurface),
        bodySmall: TextStyle(color: mutedText),
      ),
      dividerColor: dividerColor,
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.16 : 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: dividerColor.withValues(alpha: 0.75)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: dividerColor),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: panelColor,
        labelStyle: TextStyle(color: mutedText),
        hintStyle: TextStyle(color: mutedText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return mutedText;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        side: BorderSide(color: dividerColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return mutedText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.4);
          }
          return dividerColor;
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF29434A) : textDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
      ),
    );
  }
}
