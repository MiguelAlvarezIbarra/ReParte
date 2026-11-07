import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/punto_entrega.dart';
import '../services/navegacion_service.dart';

/// Abre la app de mapas con la ruta al punto de entrega.
/// Necesita un NavegacionService arriba en el arbol de Provider.
class BotonComoLlegar extends StatelessWidget {
  const BotonComoLlegar({super.key, required this.punto, this.relleno = false});

  final PuntoEntrega punto;

  /// Boton lleno (en el mapa) o de contorno (en el detalle).
  final bool relleno;

  /// Los puntos viejos sin ubicacion quedaron en 0,0: no hay ruta posible.
  static bool tieneUbicacion(PuntoEntrega punto) =>
      punto.latitud != 0 || punto.longitud != 0;

  Future<void> _abrir(BuildContext context) async {
    final abierta = await context
        .read<NavegacionService>()
        .abrirRuta(punto.latitud, punto.longitud);
    if (abierta || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo abrir la app de mapas')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!tieneUbicacion(punto)) return const SizedBox.shrink();
    const icono = Icon(Icons.directions_outlined);
    const texto = Text('Cómo llegar');
    return relleno
        ? FilledButton.icon(
            onPressed: () => _abrir(context),
            icon: icono,
            label: texto,
          )
        : OutlinedButton.icon(
            onPressed: () => _abrir(context),
            icon: icono,
            label: texto,
          );
  }
}
