import 'package:flutter/material.dart';

/// Colores y tipografia de ReParte.
/// Paleta propia inspirada en apps de rescate de comida: crema, verde y lima.
class TemaApp {
  static const verde = Color(0xFF1F5C50);
  static const verdeOscuro = Color(0xFF143F37);
  static const verdeClaro = Color(0xFFE6F0EC);
  static const crema = Color(0xFFFAF5EC);
  static const lima = Color(0xFFD9F26B);
  static const texto = Color(0xFF17302B);
  static const gris = Color(0xFF5A6A66);
  static const borde = Color(0xFFE6DED0);
  static const campo = Color(0xFFF0E9DC);

  /// Tipografia de los titulos; el texto corrido usa la del sistema.
  static const fuenteTitulos = 'Poppins';

  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(
      seedColor: verde,
      primary: verde,
      onPrimary: Colors.white,
      primaryContainer: verdeClaro,
      onPrimaryContainer: verdeOscuro,
      secondary: lima,
      onSecondary: verdeOscuro,
      secondaryContainer: lima,
      onSecondaryContainer: verdeOscuro,
      surface: crema,
      onSurface: texto,
      onSurfaceVariant: gris,
      outline: borde,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: esquema);
    final titulos = base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall
          ?.copyWith(fontFamily: fuenteTitulos, fontWeight: FontWeight.w700),
      headlineMedium: base.textTheme.headlineMedium
          ?.copyWith(fontFamily: fuenteTitulos, fontWeight: FontWeight.w700),
      headlineSmall: base.textTheme.headlineSmall
          ?.copyWith(fontFamily: fuenteTitulos, fontWeight: FontWeight.w700),
      titleLarge: base.textTheme.titleLarge
          ?.copyWith(fontFamily: fuenteTitulos, fontWeight: FontWeight.w600),
      titleMedium: base.textTheme.titleMedium
          ?.copyWith(fontFamily: fuenteTitulos, fontWeight: FontWeight.w600),
    );
    const pildora = StadiumBorder();
    final redondeado = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: borde, width: 1.5),
    );

    return base.copyWith(
      scaffoldBackgroundColor: crema,
      textTheme: titulos.apply(bodyColor: texto, displayColor: texto),
      appBarTheme: const AppBarTheme(
        backgroundColor: crema,
        foregroundColor: texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: fuenteTitulos,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: texto,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: redondeado,
        enabledBorder: redondeado,
        focusedBorder: redondeado.copyWith(
          borderSide: const BorderSide(color: verde, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: verde,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: pildora,
          textStyle: const TextStyle(
            fontFamily: fuenteTitulos,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: verde,
          minimumSize: const Size.fromHeight(56),
          shape: pildora,
          side: const BorderSide(color: verde, width: 2),
          textStyle: const TextStyle(
            fontFamily: fuenteTitulos,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: verde,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEDE5D6)),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: lima,
          selectedForegroundColor: verdeOscuro,
          backgroundColor: Colors.white,
          foregroundColor: texto,
          side: const BorderSide(color: borde, width: 1.5),
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lima,
        foregroundColor: verdeOscuro,
        shape: pildora,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: verdeOscuro,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: verde),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: lima,
        surfaceTintColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith(
          (estados) => IconThemeData(
            color: estados.contains(WidgetState.selected) ? verdeOscuro : gris,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => TextStyle(
            fontSize: 12,
            fontWeight: estados.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: estados.contains(WidgetState.selected) ? verde : gris,
          ),
        ),
      ),
    );
  }
}
