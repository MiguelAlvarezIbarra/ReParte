import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/tema/tema_app.dart';
import '../../repositories/donacion_repository.dart';
import '../../viewmodels/estado_ui.dart';
import '../../viewmodels/mapa_donaciones_viewmodel.dart';
import '../../widgets/boton_como_llegar.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/estado_error.dart';
import '../../widgets/tarjeta_donacion.dart';
import '../donaciones/detalle_donacion_view.dart';

/// Mapa con las donaciones disponibles; al tocar un marcador aparece su
/// tarjeta para ver el detalle o abrir la ruta.
class MapaDonacionesView extends StatelessWidget {
  const MapaDonacionesView({super.key, this.asociacionId});

  /// Se pasa al detalle para que la asociacion pueda reservar.
  final String? asociacionId;

  /// Centro por defecto: Dolores Hidalgo, Gto.
  static const centroPorDefecto = LatLng(21.1560, -100.9318);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MapaDonacionesViewModel(context.read<DonacionRepository>())
            ..escuchar(),
      child: _Contenido(asociacionId: asociacionId),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({this.asociacionId});

  final String? asociacionId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapaDonacionesViewModel>();
    switch (vm.estado) {
      case EstadoUI.inicial:
      case EstadoUI.cargando:
        return const Center(child: CircularProgressIndicator());
      case EstadoUI.error:
        return EstadoError(
          mensaje: vm.mensajeError ?? 'Ocurrió un error',
          alReintentar: vm.escuchar,
        );
      case EstadoUI.listo:
        if (vm.enMapa.isEmpty) {
          return const EstadoVacio(
            icono: Icons.map_outlined,
            titulo: 'No hay donaciones en el mapa',
            mensaje: 'Cuando un donante publique comida con su ubicación, '
                'aparecerá aquí.',
          );
        }
        return _Mapa(asociacionId: asociacionId);
    }
  }
}

class _Mapa extends StatelessWidget {
  const _Mapa({this.asociacionId});

  final String? asociacionId;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapaDonacionesViewModel>();
    final puntos = [
      for (final e in vm.enMapa) LatLng(e.punto.latitud, e.punto.longitud),
    ];
    final seleccionada = vm.seleccionada;
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: puntos.isEmpty
                ? MapaDonacionesView.centroPorDefecto
                : puntos.first,
            initialZoom: 14,
            initialCameraFit: puntos.length > 1
                ? CameraFit.coordinates(
                    coordinates: puntos,
                    padding: const EdgeInsets.all(64),
                    maxZoom: 16,
                  )
                : null,
            onTap: (_, __) => vm.seleccionar(null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.reparte.reparte',
            ),
            MarkerLayer(
              markers: [
                for (final e in vm.enMapa)
                  Marker(
                    point: LatLng(e.punto.latitud, e.punto.longitud),
                    width: 48,
                    height: 48,
                    child: _Marcador(
                      elegido: seleccionada?.donacion.id == e.donacion.id,
                      descripcion: e.donacion.descripcion,
                      alTocar: () => vm.seleccionar(e),
                    ),
                  ),
              ],
            ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors'),
            ),
          ],
        ),
        if (seleccionada != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TarjetaDonacion(
                  donacion: seleccionada.donacion,
                  alTocar: () => DetalleDonacionView.abrir(
                    context,
                    seleccionada.donacion,
                    asociacionId: asociacionId,
                  ),
                ),
                const SizedBox(height: 8),
                BotonComoLlegar(punto: seleccionada.punto, relleno: true),
              ],
            ),
          ),
      ],
    );
  }
}

class _Marcador extends StatelessWidget {
  const _Marcador({
    required this.elegido,
    required this.descripcion,
    required this.alTocar,
  });

  final bool elegido;
  final String descripcion;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: descripcion,
      child: GestureDetector(
        onTap: alTocar,
        child: Icon(
          Icons.location_on,
          size: 48,
          color: elegido ? TemaApp.verdeOscuro : TemaApp.verde,
          shadows: const [Shadow(blurRadius: 6, color: Colors.black26)],
        ),
      ),
    );
  }
}
