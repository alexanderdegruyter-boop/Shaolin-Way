import 'package:flutter/material.dart';

/// The visual identity of Shaolin Way: calm, minimal, Zen-inspired.
/// Warm neutrals + deep ink tones with a single jade accent.
class AppTheme {
  AppTheme._();

  // Brand palette
  static const Color accent = Color(0xFF6B8F71); // soft jade
  static const Color accentDark = Color(0xFF8FB597);
  static const Color ink = Color(0xFF2B2A28); // deep warm ink
  static const Color sand = Color(0xFFF4F1EA); // warm paper background
  static const Color sandCard = Color(0xFFFBF9F4);
  static const Color nightBg = Color(0xFF161514);
  static const Color nightCard = Color(0xFF222120);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: accent,
      surface: sandCard,
    );
    return _base(scheme, sand, sandCard, ink);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accentDark,
      surface: nightCard,
    );
    return _base(scheme, nightBg, nightCard, const Color(0xFFEDE9E1));
  }

  static ThemeData _base(
    ColorScheme scheme,
    Color bg,
    Color card,
    Color textColor,
  ) {
    final textTheme = _textTheme(textColor);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: scheme.primary.withOpacity(0.18),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        height: 68,
      ),
      dividerTheme: DividerThemeData(
        color: textColor.withOpacity(0.08),
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.primary.withOpacity(0.10),
        labelStyle: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color color) {
    final faded = color.withOpacity(0.7);
    return TextTheme(
      displaySmall: TextStyle(
        color: color,
        fontSize: 30,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      ),
      headlineSmall: TextStyle(
        color: color,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      titleLarge: TextStyle(
        color: color,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: color, fontSize: 16, height: 1.5),
      bodyMedium: TextStyle(color: faded, fontSize: 14, height: 1.5),
      labelSmall: TextStyle(color: faded, fontSize: 12),
    );
  }
}
