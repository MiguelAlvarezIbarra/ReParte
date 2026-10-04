import 'package:flutter/material.dart';

/// Colores y tipografia de ReParte.
class TemaApp {
  static ThemeData get claro => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      );
}
