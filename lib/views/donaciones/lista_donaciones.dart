import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/donacion_repository.dart';
import '../../viewmodels/donaciones_viewmodel.dart';
import '../../viewmodels/estado_ui.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/mensaje_error.dart';
import '../../widgets/tarjeta_donacion.dart';

/// Lista de donaciones disponibles que se actualiza sola en tiempo real.
/// Se puede poner dentro de cualquier pantalla; trae su propio ViewModel.
/// Necesita un DonacionRepository arriba en el arbol de Provider.
class ListaDonaciones extends StatelessWidget {
  const ListaDonaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          DonacionesViewModel(context.read<DonacionRepository>())..escuchar(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

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
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: vm.donaciones.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => TarjetaDonacion(donacion: vm.donaciones[i]),
        );
    }
  }
}
