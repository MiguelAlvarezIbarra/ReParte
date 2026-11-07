import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/tema/tema_app.dart';
import '../../models/punto_entrega.dart';
import '../../services/rutas_service.dart';
import '../../services/ubicacion_service.dart';
import '../../viewmodels/estado_ui.dart';
import '../../viewmodels/ruta_viewmodel.dart';
import '../../widgets/boton_como_llegar.dart';
import '../../widgets/etiqueta.dart';

/// Mapa con la ruta desde la ubicacion de la asociacion hasta el punto de
/// entrega, con la distancia y el tiempo aproximado (T31).
class RutaView extends StatelessWidget {
  const RutaView({super.key});

  /// Abre la ruta hasta [punto]. Necesita UbicacionService y RutasService
  /// en el Provider.
  static Future<void> abrir(BuildContext context, PuntoEntrega punto) {
    final ubicacion = context.read<UbicacionService>();
    final rutas = context.read<RutasService>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => RutaViewModel(
            destino: punto,
            ubicacion: ubicacion,
            rutas: rutas,
          )..cargar(),
          child: const RutaView(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RutaViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta al punto de entrega')),
      body: switch (vm.estado) {
        EstadoUI.inicial || EstadoUI.cargando => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Calculando la ruta…'),
              ],
            ),
          ),
        EstadoUI.error =>
          _Error(mensaje: vm.mensajeError ?? 'Ocurrió un error'),
        EstadoUI.listo => const _MapaConRuta(),
      },
    );
  }
}

class _MapaConRuta extends StatelessWidget {
  const _MapaConRuta();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RutaViewModel>();
    final ruta = vm.ruta!;
    final origen = LatLng(vm.origen!.latitud, vm.origen!.longitud);
    final destino = LatLng(vm.destino.latitud, vm.destino.longitud);
    final trazo = [for (final p in ruta.trazo) LatLng(p.latitud, p.longitud)];
    final encuadre = trazo.length >= 2 ? trazo : [origen, destino];

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: destino,
            initialZoom: 14,
            initialCameraFit: CameraFit.coordinates(
              coordinates: encuadre,
              padding: const EdgeInsets.fromLTRB(48, 48, 48, 220),
              maxZoom: 17,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.reparte.reparte',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: trazo,
                  strokeWidth: 6,
                  color: TemaApp.verde,
                  borderStrokeWidth: 2,
                  borderColor: Colors.white,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: origen,
                  width: 28,
                  height: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      color: TemaApp.lima,
                      shape: BoxShape.circle,
                      border: Border.all(color: TemaApp.verdeOscuro, width: 3),
                    ),
                  ),
                ),
                Marker(
                  point: destino,
                  width: 48,
                  height: 48,
                  alignment: Alignment.topCenter,
                  child: const Icon(
                    Icons.location_on,
                    size: 48,
                    color: TemaApp.verdeOscuro,
                  ),
                ),
              ],
            ),
            const SimpleAttributionWidget(
              source: Text('OpenStreetMap contributors · OSRM'),
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    vm.destino.nombre,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    vm.destino.direccion,
                    style: const TextStyle(color: TemaApp.gris),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Etiqueta.destacada(
                        ruta.duracionTexto,
                        icono: Icons.directions_car_outlined,
                      ),
                      Etiqueta(ruta.distanciaTexto, icono: Icons.straighten),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BotonComoLlegar(punto: vm.destino, relleno: true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wrong_location_outlined,
                size: 64, color: TemaApp.verde),
            const SizedBox(height: 16),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.read<RutaViewModel>().cargar(),
              child: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }
}
