import 'package:flutter/material.dart';
import '../core/tema/tema_app.dart';

/// Logo, nombre de la app y eslogan, comun a las pantallas de acceso.
class EncabezadoReParte extends StatelessWidget {
  const EncabezadoReParte({super.key});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            color: TemaApp.verde,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            size: 42,
            color: TemaApp.lima,
          ),
        ),
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
