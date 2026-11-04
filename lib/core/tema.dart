/// Tema visual de la app con la identidad NET_MAX.
library;

import 'package:flutter/material.dart';

import 'marca.dart';

ThemeData temaNetMax() {
  const azul = ColoresNetMax.azul;
  const verde = ColoresNetMax.verde;
  const crema = ColoresNetMax.crema;

  final esquema = ColorScheme.fromSeed(
    seedColor: azul,
    brightness: Brightness.light,
  ).copyWith(
    primary: azul,
    onPrimary: crema,
    primaryContainer: const Color(0xFFDCE3EF),
    onPrimaryContainer: azul,
    secondary: verde,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFCFEBDD),
    onSecondaryContainer: const Color(0xFF053B28),
    tertiary: ColoresNetMax.verdeClaro,
    onTertiary: azul,
    tertiaryContainer: const Color(0xFFE0F3E9),
    onTertiaryContainer: const Color(0xFF053B28),
    surface: crema,
    onSurface: azul,
    onSurfaceVariant: const Color(0xFF4A5568),
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: ColoresNetMax.tarjeta,
    surfaceContainer: const Color(0xFFF8F2E9),
    surfaceContainerHigh: const Color(0xFFEDE5D8),
    surfaceContainerHighest: ColoresNetMax.arena,
    outline: const Color(0xFF9A9A98),
    outlineVariant: ColoresNetMax.linea,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    fontFamily: 'Outfit',
    scaffoldBackgroundColor: crema,
  );

  final texto = base.textTheme.apply(bodyColor: azul, displayColor: azul).copyWith(
        titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: azul),
        titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: azul),
        labelLarge: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      );

  final bordeCampo = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: ColoresNetMax.linea),
  );

  return base.copyWith(
    textTheme: texto,
    appBarTheme: const AppBarTheme(
      backgroundColor: azul,
      foregroundColor: crema,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 21,
        fontWeight: FontWeight.w600,
        color: crema,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: azul,
      indicatorColor: ColoresNetMax.verdeClaro.withValues(alpha: 0.22),
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith(
        (estados) => IconThemeData(
          color: estados.contains(WidgetState.selected)
              ? ColoresNetMax.verdeClaro
              : crema.withValues(alpha: 0.8),
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (estados) => TextStyle(
          fontFamily: 'Outfit',
          fontSize: 12,
          fontWeight: estados.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
          color: estados.contains(WidgetState.selected)
              ? ColoresNetMax.verdeClaro
              : crema.withValues(alpha: 0.8),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: ColoresNetMax.tarjeta,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE6DED0)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: verde,
      foregroundColor: Colors.white,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: verde,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: azul,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: azul),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: verde),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: bordeCampo,
      enabledBorder: bordeCampo,
      focusedBorder: bordeCampo.copyWith(
        borderSide: const BorderSide(color: verde, width: 2),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      selectedColor: esquema.secondaryContainer,
      side: const BorderSide(color: ColoresNetMax.linea),
      labelStyle: const TextStyle(fontFamily: 'Outfit', color: azul),
    ),
    listTileTheme: const ListTileThemeData(iconColor: azul),
    dividerTheme: const DividerThemeData(color: Color(0xFFE6DED0), space: 1),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: azul,
      contentTextStyle: TextStyle(fontFamily: 'Outfit', color: crema),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: verde),
  );
}
