import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../repositories/donacion_repository.dart';
import '../../viewmodels/estado_ui.dart';
import '../../viewmodels/mis_donaciones_viewmodel.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/mensaje_error.dart';
import '../../widgets/tarjeta_donacion.dart';
import 'detalle_donacion_view.dart';

/// "Mis donaciones" del donante o "Mis reservas" de la asociacion,
/// con su estado actual y separadas en activas e historial (T22).
/// Necesita un DonacionRepository arriba en el arbol de Provider.
class MisDonacionesView extends StatelessWidget {
  const MisDonacionesView({
    super.key,
    required this.usuarioId,
    required this.dueno,
  });

  final String usuarioId;
  final DuenoLista dueno;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MisDonacionesViewModel(
        context.read<DonacionRepository>(),
        usuarioId: usuarioId,
        dueno: dueno,
      )..escuchar(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MisDonacionesViewModel>();
    final esDonante = vm.dueno == DuenoLista.donante;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: SegmentedButton<FiltroMisDonaciones>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(
                value: FiltroMisDonaciones.activas,
                label: Text('Activas'),
              ),
              ButtonSegment(
                value: FiltroMisDonaciones.historial,
                label: Text('Historial'),
              ),
            ],
            selected: {vm.filtro},
            onSelectionChanged: (s) => vm.elegir(s.first),
          ),
        ),
        Expanded(child: _Lista(esDonante: esDonante)),
      ],
    );
  }
}

class _Lista extends StatelessWidget {
  const _Lista({required this.esDonante});

  final bool esDonante;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MisDonacionesViewModel>();
    switch (vm.estado) {
      case EstadoUI.inicial:
      case EstadoUI.cargando:
        return const Center(child: CircularProgressIndicator());
      case EstadoUI.error:
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: MensajeError(vm.mensajeError ?? 'Ocurrió un error'),
          ),
        );
      case EstadoUI.listo:
        final lista = vm.donaciones;
        if (lista.isEmpty) return _vacio(vm.filtro);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          itemCount: lista.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => TarjetaDonacion(
            donacion: lista[i],
            mostrarEstado: true,
            alTocar: () => DetalleDonacionView.abrir(
              context,
              lista[i],
              asociacionId: esDonante ? null : vm.usuarioId,
              usuarioId: vm.usuarioId,
            ),
          ),
        );
    }
  }

  Widget _vacio(FiltroMisDonaciones filtro) {
    final activas = filtro == FiltroMisDonaciones.activas;
    if (esDonante) {
      return EstadoVacio(
        icono: Icons.inventory_2_outlined,
        titulo: activas
            ? 'No tienes donaciones activas'
            : 'Aún no hay donaciones en tu historial',
        mensaje: activas
            ? 'Cuando te sobre comida en buen estado, publícala '
                'y las asociaciones cercanas podrán recogerla.'
            : 'Aquí quedarán las donaciones entregadas o que ya caducaron.',
      );
    }
    return EstadoVacio(
      icono: Icons.bookmark_border,
      titulo: activas
          ? 'No tienes reservas activas'
          : 'Aún no hay reservas en tu historial',
      mensaje: activas
          ? 'Reserva una donación disponible y aquí verás dónde recogerla.'
          : 'Aquí quedarán las donaciones que ya recogiste.',
    );
  }
}
