import 'package:flutter/material.dart';

/// Colores y tipografia de ReParte, tomados del prototipo en Figma.
class TemaApp {
  static const naranja = Color(0xFFD9603B);
  static const crema = Color(0xFFFFFBF7);

  static ThemeData get claro => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: naranja,
          primary: naranja,
          surface: crema,
        ),
        scaffoldBackgroundColor: crema,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
