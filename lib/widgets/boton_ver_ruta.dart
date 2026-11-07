import 'package:flutter/material.dart';
import '../models/punto_entrega.dart';
import '../views/mapa/ruta_view.dart';
import 'boton_como_llegar.dart';

/// Abre el mapa de ReParte con la ruta dibujada hasta el punto de entrega.
class BotonVerRuta extends StatelessWidget {
  const BotonVerRuta({super.key, required this.punto});

  final PuntoEntrega punto;

  @override
  Widget build(BuildContext context) {
    if (!BotonComoLlegar.tieneUbicacion(punto)) return const SizedBox.shrink();
    return FilledButton.icon(
      onPressed: () => RutaView.abrir(context, punto),
      icon: const Icon(Icons.route_outlined),
      label: const Text('Ver ruta en el mapa'),
    );
  }
}
