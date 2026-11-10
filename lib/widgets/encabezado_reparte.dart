import 'package:flutter/material.dart';
import '../core/tema/tema_app.dart';
import 'logo_reparte.dart';

/// Logo, nombre de la app y eslogan, comun a las pantallas de acceso.
class EncabezadoReParte extends StatelessWidget {
  const EncabezadoReParte({super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Column(
      children: [
        const LogoReParte(tamano: 88),
        const SizedBox(height: 14),
        Text(
          'ReParte',
          style: texto.displaySmall?.copyWith(
            color: TemaApp.verde,
            fontSize: 36,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'La comida que sobra no se tira: se reparte.',
          textAlign: TextAlign.center,
          style: texto.bodyLarge?.copyWith(color: TemaApp.gris),
        ),
      ],
    );
  }
}
