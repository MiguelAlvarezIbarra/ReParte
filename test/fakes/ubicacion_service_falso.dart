import 'package:reparte/services/ubicacion_service.dart';

/// Servicio de ubicación simulado para pruebas de ViewModel y Widgets.
class UbicacionServiceFalso implements UbicacionService {
  UbicacionServiceFalso({
    this.permisoConcedido = true,
    this.posicion = (latitud: 21.1561, longitud: -100.9346),
    this.direccion = 'Calle Hidalgo 12, Dolores Hidalgo',
  });

  bool permisoConcedido;
  ({double latitud, double longitud})? posicion;
  String? direccion;

  int llamadasSolicitarPermiso = 0;
  int llamadasObtenerUbicacion = 0;
  int llamadasObtenerDireccion = 0;

  @override
  Future<bool> solicitarPermiso() async {
    llamadasSolicitarPermiso++;
    return permisoConcedido;
  }

  @override
  Future<({double latitud, double longitud})?> obtenerUbicacionActual() async {
    llamadasObtenerUbicacion++;
    final tienePermiso = await solicitarPermiso();
    if (!tienePermiso) return null;
    return posicion;
  }

  @override
  Future<String?> obtenerDireccion(double latitud, double longitud) async {
    llamadasObtenerDireccion++;
    return direccion;
  }
}
