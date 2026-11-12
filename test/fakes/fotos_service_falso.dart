import 'package:reparte/services/fotos_service.dart';

/// Falso de [FotosService] para pruebas (T35): no lee archivos.
/// Por defecto devuelve la misma foto que recibe.
class FotosServiceFalso implements FotosService {
  /// Si se da, es lo que devuelve en lugar de la foto recibida.
  String? resultado;

  /// Mensaje con el que falla; si es null no falla.
  String? falla;

  final recibidas = <String>[];

  @override
  Future<String> prepararParaGuardar(String foto) async {
    recibidas.add(foto);
    final error = falla;
    if (error != null) throw FotoNoValida(error);
    return resultado ?? foto;
  }
}
