import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Servicio para obtener coordenadas y direcciones legibles.
/// Desacopla la lógica de GPS y geocodificación para permitir pruebas aisladas.
abstract class UbicacionService {
  /// Solicita el permiso de ubicación al usuario.
  Future<bool> solicitarPermiso();

  /// Obtiene la posición actual por GPS si el permiso fue concedido.
  Future<({double latitud, double longitud})?> obtenerUbicacionActual();

  /// Convierte coordenadas geográficas a una dirección legible de texto.
  Future<String?> obtenerDireccion(double latitud, double longitud);
}

/// Implementación real que consulta los sensores del dispositivo con Geolocator
/// y la API de Geocoding.
class GeolocatorUbicacionService implements UbicacionService {
  const GeolocatorUbicacionService({Geocoding? geocoding})
      : _geocoding = geocoding;

  final Geocoding? _geocoding;

  Geocoding get _geocodingInstance => _geocoding ?? Geocoding();

  @override
  Future<bool> solicitarPermiso() async {
    try {
      final servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicioHabilitado) return false;

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
        if (permiso == LocationPermission.denied) return false;
      }
      if (permiso == LocationPermission.deniedForever) return false;

      return permiso == LocationPermission.always ||
          permiso == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<({double latitud, double longitud})?> obtenerUbicacionActual() async {
    final tienePermiso = await solicitarPermiso();
    if (!tienePermiso) return null;

    try {
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return (latitud: posicion.latitude, longitud: posicion.longitude);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> obtenerDireccion(double latitud, double longitud) async {
    try {
      final lugares =
          await _geocodingInstance.placemarkFromCoordinates(latitud, longitud);
      if (lugares.isEmpty) return null;
      final lugar = lugares.first;
      final partes = [
        if (lugar.street != null && lugar.street!.trim().isNotEmpty)
          lugar.street!.trim(),
        if (lugar.subLocality != null && lugar.subLocality!.trim().isNotEmpty)
          lugar.subLocality!.trim(),
        if (lugar.locality != null && lugar.locality!.trim().isNotEmpty)
          lugar.locality!.trim(),
      ];
      return partes.isEmpty ? null : partes.join(', ');
    } catch (_) {
      return null;
    }
  }
}
