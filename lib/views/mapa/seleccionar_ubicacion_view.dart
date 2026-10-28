import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/ubicacion_service.dart';

/// Resultado devuelto tras seleccionar una ubicación en el mapa.
class ResultadoUbicacion {
  const ResultadoUbicacion({
    required this.latitud,
    required this.longitud,
    this.direccion,
  });

  final double latitud;
  final double longitud;
  final String? direccion;
}

/// Pantalla con mapa interactivo para seleccionar el punto de entrega.
class SeleccionarUbicacionView extends StatefulWidget {
  const SeleccionarUbicacionView({
    super.key,
    this.latitudInicial,
    this.longitudInicial,
    this.ubicacionService,
  });

  final double? latitudInicial;
  final double? longitudInicial;
  final UbicacionService? ubicacionService;

  /// Abre la pantalla y devuelve las coordenadas y dirección seleccionadas.
  static Future<ResultadoUbicacion?> abrir(
    BuildContext context, {
    double? latitudInicial,
    double? longitudInicial,
    UbicacionService? ubicacionService,
  }) {
    return Navigator.of(context).push<ResultadoUbicacion>(
      MaterialPageRoute(
        builder: (_) => SeleccionarUbicacionView(
          latitudInicial: latitudInicial,
          longitudInicial: longitudInicial,
          ubicacionService: ubicacionService,
        ),
      ),
    );
  }

  @override
  State<SeleccionarUbicacionView> createState() =>
      _SeleccionarUbicacionViewState();
}

class _SeleccionarUbicacionViewState extends State<SeleccionarUbicacionView> {
  // Coordenadas por defecto (Dolores Hidalgo, Cuna de la Independencia).
  static const double _latPorDefecto = 21.1561;
  static const double _lngPorDefecto = -100.9346;

  late double _latitud;
  late double _longitud;
  String? _direccion;
  bool _obteniendoDireccion = false;
  GoogleMapController? _mapController;
  late final UbicacionService _ubicacionService;

  @override
  void initState() {
    super.initState();
    _latitud = widget.latitudInicial ?? _latPorDefecto;
    _longitud = widget.longitudInicial ?? _lngPorDefecto;
    _ubicacionService =
        widget.ubicacionService ?? const GeolocatorUbicacionService();
    _obtenerDireccion(_latitud, _longitud);
  }

  Future<void> _obtenerDireccion(double lat, double lng) async {
    setState(() => _obteniendoDireccion = true);
    final dir = await _ubicacionService.obtenerDireccion(lat, lng);
    if (!mounted) return;
    setState(() {
      _direccion = dir;
      _obteniendoDireccion = false;
    });
  }

  void _onTapMapa(LatLng posicion) {
    setState(() {
      _latitud = posicion.latitude;
      _longitud = posicion.longitude;
    });
    _obtenerDireccion(_latitud, _longitud);
  }

  Future<void> _irAUbicacionActual() async {
    final pos = await _ubicacionService.obtenerUbicacionActual();
    if (pos == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No se pudo obtener tu ubicación actual. Revisa los permisos.'),
          ),
        );
      }
      return;
    }
    setState(() {
      _latitud = pos.latitud;
      _longitud = pos.longitud;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(pos.latitud, pos.longitud)),
    );
    _obtenerDireccion(pos.latitud, pos.longitud);
  }

  void _confirmar() {
    Navigator.of(context).pop(ResultadoUbicacion(
      latitud: _latitud,
      longitud: _longitud,
      direccion: _direccion,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pos = LatLng(_latitud, _longitud);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir punto en el mapa'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            key: const Key('mapa_google_view'),
            initialCameraPosition: CameraPosition(
              target: pos,
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('punto_entrega_marker'),
                position: pos,
                draggable: true,
                onDragEnd: (nuevaPos) => _onTapMapa(nuevaPos),
              ),
            },
            onTap: _onTapMapa,
            onMapCreated: (c) => _mapController = c,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
          Positioned(
            right: 16,
            bottom: 140,
            child: FloatingActionButton(
              key: const Key('boton_mi_ubicacion_mapa'),
              onPressed: _irAUbicacionActual,
              tooltip: 'Mi ubicación',
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _obteniendoDireccion
                                ? 'Obteniendo dirección...'
                                : (_direccion ??
                                    '${_latitud.toStringAsFixed(5)}, ${_longitud.toStringAsFixed(5)}'),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      key: const Key('boton_confirmar_ubicacion_mapa'),
                      onPressed: _confirmar,
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmar este punto de entrega'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
