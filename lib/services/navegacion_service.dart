import 'package:url_launcher/url_launcher.dart';

/// Abre la app de mapas del telefono con la ruta hasta un punto.
/// ReParte no calcula rutas: se las deja a Google Maps (o la que tenga).
class NavegacionService {
  const NavegacionService();

  /// Direccion web que Google Maps entiende como "como llegar a".
  static Uri rutaHacia(double latitud, double longitud) {
    return Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '$latitud,$longitud',
    });
  }

  /// Devuelve false si el telefono no pudo abrir ninguna app de mapas.
  Future<bool> abrirRuta(double latitud, double longitud) {
    return launchUrl(
      rutaHacia(latitud, longitud),
      mode: LaunchMode.externalApplication,
    );
  }
}
