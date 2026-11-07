import 'package:flutter/material.dart';
import '../core/tema/tema_app.dart';

/// Mensaje centrado con icono para listas que aun no tienen datos.
class EstadoVacio extends StatelessWidget {
  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
  });

  final IconData icono;
  final String titulo;
  final String mensaje;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: const BoxDecoration(
                color: TemaApp.verdeClaro,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 52, color: TemaApp.verde),
            ),
            const SizedBox(height: 20),
            Text(titulo, style: texto.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              mensaje,
              style: texto.bodyMedium?.copyWith(color: TemaApp.gris),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
