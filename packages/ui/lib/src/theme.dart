import 'package:flutter/material.dart';

abstract final class TftTheme {
  static const yellow = Color(0xFFFFC800);
  static const ink = Color(0xFF0B0C10);

  static ThemeData light() => _build(
    ColorScheme.fromSeed(seedColor: yellow).copyWith(
      primary: const Color(0xFF8A6400),
      onPrimary: Colors.white,
      primaryContainer: yellow,
      onPrimaryContainer: ink,
      tertiary: const Color(0xFF2F6FDB),
      error: const Color(0xFFD7263D),
      surface: const Color(0xFFF4F5F7),
      onSurface: ink,
      onSurfaceVariant: const Color(0xFF5B5F69),
      surfaceContainerLow: Colors.white,
      surfaceContainer: const Color(0xFFECEDF0),
      surfaceContainerHighest: const Color(0xFFDADCE1),
      outline: const Color(0xFF8D919A),
      outlineVariant: const Color(0xFFD5D7DC),
    ),
  );

  static ThemeData dark() => _build(
    ColorScheme.fromSeed(seedColor: yellow, brightness: Brightness.dark).copyWith(
      primary: yellow,
      onPrimary: ink,
      primaryContainer: yellow,
      onPrimaryContainer: ink,
      tertiary: const Color(0xFF5B9DFF),
      error: const Color(0xFFFF4655),
      surface: ink,
      onSurface: const Color(0xFFF1F2F4),
      onSurfaceVariant: const Color(0xFFA1A5AE),
      surfaceContainerLow: const Color(0xFF111318),
      surfaceContainer: const Color(0xFF15171D),
      surfaceContainerHighest: const Color(0xFF23262E),
      outline: const Color(0xFF6B7079),
      outlineVariant: const Color(0xFF262930),
    ),
  );

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme, fontFamily: 'Inter', package: 'ui');
    const display = TextStyle(fontFamily: 'Anton', package: 'ui');
    final text = base.textTheme;
    final textTheme = text.copyWith(
      displayLarge: text.displayLarge?.merge(display),
      displayMedium: text.displayMedium?.merge(display),
      displaySmall: text.displaySmall?.merge(display),
      headlineLarge: text.headlineLarge?.merge(display),
      headlineMedium: text.headlineMedium?.merge(display),
      headlineSmall: text.headlineSmall?.merge(display),
    );
    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium?.copyWith(color: scheme.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
      ),
    );
  }
}
