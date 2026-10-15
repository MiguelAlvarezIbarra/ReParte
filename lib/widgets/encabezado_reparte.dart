import 'package:flutter/material.dart';

/// Nombre de la app y eslogan, comun a las pantallas de acceso.
class EncabezadoReParte extends StatelessWidget {
  const EncabezadoReParte({super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Column(
      children: [
        Text(
          'ReParte',
          style: texto.displaySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'La comida que sobra no se tira: se reparte.',
          textAlign: TextAlign.center,
          style: texto.bodyLarge?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}
