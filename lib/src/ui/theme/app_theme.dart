import 'package:flutter/material.dart';

import '../../domain/qr_label_type.dart';

/// Paleta y tipografía definidas en `DESIGN.md`. Única fuente de verdad
/// visual: las pantallas no declaran colores ni tamaños de fuente sueltos.
class AppColors {
  const AppColors._();

  static const sello = Color(0xFF0F4C5C);
  static const selloProfundo = Color(0xFF0B3844);
  static const marigold = Color(0xFFE2A33B);
  static const paper = Color(0xFFF7F6F2);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1B2430);
  static const inkMuted = Color(0xFF4B5563);
  static const border = Color(0xFFD8DEDC);
  static const error = Color(0xFFB3261E);
}

/// Grilla de espaciado de 4px de `DESIGN.md`.
class AppSpacing {
  const AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
}

/// Radios de esquina de `DESIGN.md`. Sin píldoras/stadium.
class AppRadius {
  const AppRadius._();

  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
}

const _fontFamily = 'IBM Plex Sans';

/// Color funcional por tipo de QR, para que Maxi distinga cada fila de
/// Inicio de un vistazo. No decorativo: codifica a qué canal lleva cada
/// opción, igual que el ícono que ya usa la etiqueta impresa.
Color qrTypeAccent(QrLabelType type) => switch (type) {
  QrLabelType.whatsapp => const Color(0xFF25D366),
  QrLabelType.instagram => const Color(0xFFC13584),
  QrLabelType.googleReviews => const Color(0xFF4285F4),
  QrLabelType.mercadoPago => AppColors.inkMuted,
};

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.light(
    primary: AppColors.sello,
    onPrimary: Colors.white,
    secondary: AppColors.marigold,
    onSecondary: AppColors.ink,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    error: AppColors.error,
    onError: Colors.white,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
  );

  const outlineBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
    borderSide: BorderSide(color: AppColors.inkMuted),
  );

  final textTheme = const TextTheme(
        titleLarge: TextStyle(
          // Display: títulos de AppBar.
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: AppColors.ink,
        ),
        headlineSmall: TextStyle(
          // Headline: encabezados de sección dentro de una pantalla.
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.25,
          color: AppColors.ink,
        ),
        titleMedium: TextStyle(
          // Title: filas de lista y tarjetas.
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(
          // Body: instrucciones, ayuda, contenido general.
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.45,
          color: AppColors.inkMuted,
        ),
        labelLarge: TextStyle(
          // Label: texto de botones y labels de campo.
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: 0.1,
        ),
      ).apply(fontFamily: _fontFamily);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.paper,
    fontFamily: _fontFamily,
    textTheme: textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.ink,
      iconColor: AppColors.inkMuted,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: AppSpacing.xl,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: outlineBorder,
      enabledBorder: outlineBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        borderSide: BorderSide(color: AppColors.sello, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: TextStyle(color: AppColors.inkMuted),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.sello,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.inkMuted.withValues(alpha: 0.4),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.sello,
        side: const BorderSide(color: AppColors.inkMuted),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.sello,
        minimumSize: const Size(0, 48),
        textStyle: textTheme.labelLarge,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        foregroundColor: AppColors.ink,
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: AppColors.sello,
        side: const BorderSide(color: AppColors.inkMuted),
        textStyle: textTheme.labelLarge,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.sello,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
  );
}
