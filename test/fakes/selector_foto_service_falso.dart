import 'package:reparte/services/selector_foto_service.dart';

/// Falso de [SelectorFotoService] para pruebas unitarias y de widgets (T34).
class SelectorFotoServiceFalso implements SelectorFotoService {
  String? rutaDevuelta = '/tmp/foto_donacion_reducida.jpg';
  bool lanzarError = false;

  int llamadasCamara = 0;
  int llamadasGaleria = 0;
  OrigenFoto? ultimoOrigen;

  @override
  Future<String?> seleccionarFoto(OrigenFoto origen) async {
    ultimoOrigen = origen;
    if (origen == OrigenFoto.camara) {
      llamadasCamara++;
    } else {
      llamadasGaleria++;
    }
    if (lanzarError) throw Exception('error de camara');
    return rutaDevuelta;
  }

  @override
  Future<String?> tomarFoto() => seleccionarFoto(OrigenFoto.camara);

  @override
  Future<String?> elegirDeGaleria() => seleccionarFoto(OrigenFoto.galeria);
}
