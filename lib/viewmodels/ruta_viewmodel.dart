import 'package:flutter/foundation.dart';
import '../models/punto_entrega.dart';
import '../models/ruta.dart';
import '../services/rutas_service.dart';
import '../services/ubicacion_service.dart';
import 'estado_ui.dart';

/// Cerebro del mapa con la ruta: toma la ubicacion de la asociacion y
/// calcula el camino hasta el punto de entrega.
class RutaViewModel extends ChangeNotifier {
  RutaViewModel({
    required this.destino,
    required UbicacionService ubicacion,
    required RutasService rutas,
  })  : _ubicacion = ubicacion,
        _rutas = rutas;

  final PuntoEntrega destino;
  final UbicacionService _ubicacion;
  final RutasService _rutas;
  bool _cerrado = false;

  EstadoUI estado = EstadoUI.inicial;
  String? mensajeError;
  Coordenada? origen;
  Ruta? ruta;

  Coordenada get coordenadaDestino =>
      (latitud: destino.latitud, longitud: destino.longitud);

  Future<void> cargar() async {
    estado = EstadoUI.cargando;
    mensajeError = null;
    notifyListeners();

    final aqui = await _ubicacion.obtenerUbicacionActual();
    if (aqui == null) {
      _fallar('Activa tu ubicación y da permiso a ReParte para ver la ruta.');
      return;
    }
    origen = aqui;
    try {
      ruta = await _rutas.calcular(aqui, coordenadaDestino);
      estado = EstadoUI.listo;
      if (!_cerrado) notifyListeners();
    } on RutaNoDisponible {
      _fallar('No se pudo calcular la ruta. Revisa tu conexión e intenta '
          'de nuevo.');
    }
  }

  void _fallar(String mensaje) {
    mensajeError = mensaje;
    estado = EstadoUI.error;
    if (!_cerrado) notifyListeners();
  }

  @override
  void dispose() {
    _cerrado = true;
    super.dispose();
  }
}
