import 'dart:convert';
import 'dart:io';

/// La foto no se puede guardar (no existe, esta vacia o pesa demasiado).
class FotoNoValida implements Exception {
  const FotoNoValida(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Prepara la foto de una donacion para guardarla en la nube (T35).
///
/// Decision del equipo: sin plan Blaze no hay Firebase Storage, asi que la foto
/// ya reducida por [SelectorFotoService] (T34) viaja dentro del documento de la
/// donacion en Firestore, en el campo `fotoUrl`, como imagen en base64
/// (`data:image/jpeg;base64,...`). Asi cualquier telefono o cuenta que lea la
/// donacion recibe tambien la foto. Si algun dia se activa Blaze, solo cambia
/// esta clase: el resto de la app sigue usando `fotoUrl`.
abstract class FotosService {
  /// Devuelve el valor que se guarda en `fotoUrl` para [foto], que puede ser
  /// la ruta de un archivo del telefono. Lanza [FotoNoValida] si no se puede.
  Future<String> prepararParaGuardar(String foto);
}

/// Implementacion real: lee el archivo y lo convierte a base64.
class FotosFirestoreService implements FotosService {
  const FotosFirestoreService({this.maxBytes = pesoMaximoBytes});

  /// Peso maximo de la foto. Un documento de Firestore admite 1 MiB y el
  /// base64 pesa un tercio mas, por eso el limite es de 600 KB.
  static const int pesoMaximoBytes = 600 * 1024;

  final int maxBytes;

  @override
  Future<String> prepararParaGuardar(String foto) async {
    final origen = foto.trim();
    if (origen.isEmpty) {
      throw const FotoNoValida('La foto está vacía');
    }
    // Ya esta lista para guardarse (enlace o imagen en base64).
    if (origen.startsWith('http://') || origen.startsWith('https://')) {
      return origen;
    }
    if (origen.startsWith('data:image')) {
      if (origen.length > _maxCaracteres) throw _demasiadoGrande;
      return origen;
    }

    final archivo = File(origen);
    if (!await archivo.exists()) {
      throw const FotoNoValida('No se encontró la foto en el teléfono');
    }
    final bytes = await archivo.readAsBytes();
    if (bytes.isEmpty) {
      throw const FotoNoValida('La foto está vacía');
    }
    if (bytes.length > maxBytes) throw _demasiadoGrande;
    return 'data:${_tipo(origen)};base64,${base64Encode(bytes)}';
  }

  int get _maxCaracteres => (maxBytes * 4 / 3).ceil() + 64;

  static const _demasiadoGrande =
      FotoNoValida('La foto pesa demasiado. Elige o toma otra');

  static String _tipo(String ruta) {
    final minuscula = ruta.toLowerCase();
    if (minuscula.endsWith('.png')) return 'image/png';
    if (minuscula.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
