import 'package:flutter/material.dart';
import '../core/utilidades/formato.dart';
import '../models/donacion.dart';

/// Resumen de una donacion dentro de una lista.
/// Si recibe [alTocar], toda la tarjeta se puede presionar.
class TarjetaDonacion extends StatelessWidget {
  const TarjetaDonacion({super.key, required this.donacion, this.alTocar});

  final Donacion donacion;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black12),
      ),
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(donacion.descripcion, style: texto.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.scale_outlined, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(Formato.kilos(donacion.cantidadKg)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.event_outlined, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text('Caduca el ${Formato.fecha(donacion.caducidad)}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
