import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ruta.dart';

/// No se pudo calcular la ruta (sin conexion o el servicio no encontro camino).
class RutaNoDisponible implements Exception {
  const RutaNoDisponible();

  @override
  String toString() => 'No se pudo calcular la ruta';
}

/// Calcula el camino entre dos puntos.
/// Desacopla el proveedor de rutas para poder probar sin internet.
abstract class RutasService {
  /// Lanza [RutaNoDisponible] si no se puede calcular.
  Future<Ruta> calcular(Coordenada origen, Coordenada destino);
}

/// Implementacion con OSRM, el servicio de rutas libre que usa los datos de
/// OpenStreetMap: no necesita API key ni tarjeta.
class OsrmRutasService implements RutasService {
  OsrmRutasService({http.Client? cliente, this.servidor = _servidorPublico})
      : _cliente = cliente;

  static const _servidorPublico = 'router.project-osrm.org';

  final http.Client? _cliente;
  final String servidor;

  /// Direccion de la consulta: OSRM recibe longitud,latitud.
  Uri consulta(Coordenada origen, Coordenada destino) {
    final tramo = '${origen.longitud},${origen.latitud};'
        '${destino.longitud},${destino.latitud}';
    return Uri.https(servidor, '/route/v1/driving/$tramo', {
      'overview': 'full',
      'geometries': 'geojson',
    });
  }

  @override
  Future<Ruta> calcular(Coordenada origen, Coordenada destino) async {
    final cliente = _cliente ?? http.Client();
    try {
      final respuesta = await cliente
          .get(consulta(origen, destino))
          .timeout(const Duration(seconds: 15));
      if (respuesta.statusCode != 200) throw const RutaNoDisponible();
      return leerRespuesta(respuesta.body);
    } on RutaNoDisponible {
      rethrow;
    } catch (_) {
      throw const RutaNoDisponible();
    } finally {
      if (_cliente == null) cliente.close();
    }
  }

  /// Convierte la respuesta JSON de OSRM en una [Ruta].
  static Ruta leerRespuesta(String cuerpo) {
    final json = jsonDecode(cuerpo) as Map<String, dynamic>;
    final rutas = json['routes'] as List<dynamic>?;
    if (json['code'] != 'Ok' || rutas == null || rutas.isEmpty) {
      throw const RutaNoDisponible();
    }
    final ruta = rutas.first as Map<String, dynamic>;
    final puntos = (ruta['geometry']['coordinates'] as List<dynamic>)
        .cast<List<dynamic>>()
        .map((p) => (
              latitud: (p[1] as num).toDouble(),
              longitud: (p[0] as num).toDouble(),
            ))
        .toList();
    return Ruta(
      trazo: puntos,
      distanciaMetros: (ruta['distance'] as num).toDouble(),
      duracionSegundos: (ruta['duration'] as num).toDouble(),
    );
  }
}
