import 'package:cloud_firestore/cloud_firestore.dart';

/// Acceso generico a la base de datos en la nube.
/// Es la unica capa que conoce el SDK de Firestore.
class FirestoreService {
  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Lee un documento; devuelve null si no existe.
  Future<Map<String, dynamic>?> leerDocumento(
    String coleccion,
    String id,
  ) async {
    final doc = await _db.collection(coleccion).doc(id).get();
    return doc.data();
  }

  /// Crea o reemplaza un documento con el id indicado.
  Future<void> guardarDocumento(
    String coleccion,
    String id,
    Map<String, dynamic> datos,
  ) {
    return _db.collection(coleccion).doc(id).set(datos);
  }

  // TODO(T12): consultas y streams de colecciones para las donaciones.
}
