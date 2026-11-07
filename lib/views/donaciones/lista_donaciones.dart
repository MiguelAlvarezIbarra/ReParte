import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/tema/tema_app.dart';
import '../../core/utilidades/formato.dart';
import '../../repositories/donacion_repository.dart';
import '../../viewmodels/donaciones_viewmodel.dart';
import '../../viewmodels/estado_ui.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/mensaje_error.dart';
import '../../widgets/tarjeta_donacion.dart';
import 'detalle_donacion_view.dart';

/// Lista de donaciones disponibles que se actualiza sola en tiempo real.
/// Se puede poner dentro de cualquier pantalla; trae su propio ViewModel.
/// Necesita un DonacionRepository arriba en el arbol de Provider.
/// Con [asociacionId], el detalle que se abre permite reservar.
class ListaDonaciones extends StatelessWidget {
  const ListaDonaciones({super.key, this.asociacionId});

  final String? asociacionId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          DonacionesViewModel(context.read<DonacionRepository>())..escuchar(),
      child: _Contenido(asociacionId: asociacionId),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({this.asociacionId});

  final String? asociacionId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DonacionesViewModel>();
    switch (vm.estado) {
      case EstadoUI.inicial:
      case EstadoUI.cargando:
        return const Center(child: CircularProgressIndicator());
      case EstadoUI.error:
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.topCenter,
            child: MensajeError(vm.mensajeError ?? 'Ocurrió un error'),
          ),
        );
      case EstadoUI.listo:
        if (vm.donaciones.isEmpty) {
          return const EstadoVacio(
            icono: Icons.volunteer_activism_outlined,
            titulo: 'No hay donaciones disponibles',
            mensaje: 'Aquí verás la comida que publiquen los '
                'restaurantes y supermercados cercanos.',
          );
        }
        final caducanHoy =
            vm.donaciones.where((d) => Formato.esHoy(d.caducidad)).length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            if (caducanHoy > 0) ...[
              _AvisoCaducanHoy(cantidad: caducanHoy),
              const SizedBox(height: 16),
            ],
            for (final donacion in vm.donaciones) ...[
              TarjetaDonacion(
                donacion: donacion,
                alTocar: () => DetalleDonacionView.abrir(
                  context,
                  donacion,
                  asociacionId: asociacionId,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        );
    }
  }
}

/// Franja lima que avisa cuantas donaciones vencen hoy.
class _AvisoCaducanHoy extends StatelessWidget {
  const _AvisoCaducanHoy({required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    final titulo = cantidad == 1
        ? '1 donación caduca hoy'
        : '$cantidad donaciones caducan hoy';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: TemaApp.lima,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: TemaApp.fuenteTitulos,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: TemaApp.verdeOscuro,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Resérvalas antes de que se pierdan',
                  style: TextStyle(color: TemaApp.verdeOscuro),
                ),
              ],
            ),
          ),
          const Icon(Icons.timer_outlined,
              size: 36, color: TemaApp.verdeOscuro),
        ],
      ),
    );
  }
}
