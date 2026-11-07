import 'package:flutter/material.dart';
import '../../core/tema/tema_app.dart';
import '../../core/utilidades/formato.dart';
import '../../models/donacion.dart';
import '../../models/punto_entrega.dart';
import '../../models/usuario.dart';
import '../../widgets/boton_como_llegar.dart';
import '../../widgets/boton_ver_ruta.dart';

/// Festejo al reservar: cuanta comida se rescato y donde recogerla.
/// El punto y el donante pueden faltar si no se alcanzaron a cargar.
class ReservaConfirmadaView extends StatelessWidget {
  const ReservaConfirmadaView({
    super.key,
    required this.donacion,
    this.punto,
    this.donante,
  });

  final Donacion donacion;
  final PuntoEntrega? punto;
  final Usuario? donante;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final punto = this.punto;
    final donante = this.donante;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: const BoxDecoration(
                    color: TemaApp.lima,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    size: 96,
                    color: TemaApp.verde,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Muchas gracias!',
                textAlign: TextAlign.center,
                style: texto.headlineMedium?.copyWith(
                  color: TemaApp.verde,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Acabas de evitar que se desperdicien '
                '${Formato.kilos(donacion.cantidadKg)} de comida',
                textAlign: TextAlign.center,
                style: texto.titleMedium,
              ),
              if (donante != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Le avisaremos a ${donante.nombre} de tu reserva.',
                  textAlign: TextAlign.center,
                  style: texto.bodyMedium?.copyWith(color: TemaApp.gris),
                ),
              ],
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Renglon(
                        icono: Icons.restaurant_outlined,
                        etiqueta: 'Donación',
                        valor: donacion.descripcion,
                      ),
                      if (punto != null) ...[
                        _Renglon(
                          icono: Icons.place_outlined,
                          etiqueta: 'Recoger en',
                          valor: '${punto.nombre}, ${punto.direccion}',
                        ),
                        if (punto.horario.isNotEmpty)
                          _Renglon(
                            icono: Icons.schedule_outlined,
                            etiqueta: 'Horario',
                            valor: punto.horario,
                          ),
                      ],
                      if (donante != null && donante.telefono.isNotEmpty)
                        _Renglon(
                          icono: Icons.phone_outlined,
                          etiqueta: 'Contacto',
                          valor: donante.telefono,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (punto != null && BotonComoLlegar.tieneUbicacion(punto)) ...[
                BotonVerRuta(punto: punto),
                const SizedBox(height: 12),
                BotonComoLlegar(punto: punto),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((ruta) => ruta.isFirst),
                child: const Text('Seguir buscando'),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ver la donación'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Renglon extends StatelessWidget {
  const _Renglon({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: TemaApp.verde),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(fontSize: 13, color: TemaApp.gris),
                ),
                Text(
                  valor,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
