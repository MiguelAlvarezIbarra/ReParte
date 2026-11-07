import 'package:flutter/material.dart';
import '../core/tema/tema_app.dart';
import '../core/utilidades/formato.dart';
import '../models/donacion.dart';
import 'etiqueta.dart';
import 'ilustracion_alimento.dart';

/// Resumen de una donacion dentro de una lista: ilustracion con los kilos
/// a la izquierda y los datos a la derecha.
/// Si recibe [alTocar], toda la tarjeta se puede presionar.
class TarjetaDonacion extends StatelessWidget {
  const TarjetaDonacion({
    super.key,
    required this.donacion,
    this.alTocar,
    this.mostrarEstado = false,
  });

  final Donacion donacion;
  final VoidCallback? alTocar;

  /// Muestra si esta disponible, reservada o entregada (en "Mis ...").
  final bool mostrarEstado;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              IlustracionAlimento(
                descripcion: donacion.descripcion,
                etiqueta: Formato.kilos(donacion.cantidadKg),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donacion.descripcion,
                      style: texto.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Caduca el ${Formato.fecha(donacion.caducidad)}',
                      style: texto.bodyMedium?.copyWith(color: TemaApp.gris),
                    ),
                    if (mostrarEstado) ...[
                      const SizedBox(height: 8),
                      donacion.estado == EstadoDonacion.reservada
                          ? Etiqueta.destacada(Formato.estado(donacion.estado))
                          : Etiqueta(Formato.estado(donacion.estado)),
                    ] else if (Formato.esHoy(donacion.caducidad)) ...[
                      const SizedBox(height: 8),
                      const Etiqueta.destacada('Caduca hoy'),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: TemaApp.gris),
            ],
          ),
        ),
      ),
    );
  }
}
