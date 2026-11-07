import 'package:flutter/material.dart';
import '../core/tema/tema_app.dart';

/// Pantalla de error con un mensaje claro y el boton para reintentar.
/// Asi ninguna lista se queda en blanco cuando algo falla (T24).
class EstadoError extends StatelessWidget {
  const EstadoError({
    super.key,
    required this.mensaje,
    required this.alReintentar,
  });

  final String mensaje;
  final VoidCallback alReintentar;

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
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(mensaje,
                style: texto.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'Revisa tu conexión a internet e intenta de nuevo.',
              style: texto.bodyMedium?.copyWith(color: TemaApp.gris),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}
