import 'package:cloud_firestore/cloud_firestore.dart';

/// Un documento leido de Firestore: su id y sus datos.
typedef Documento = ({String id, Map<String, dynamic> datos});

/// Acceso generico a la base de datos en la nube.
/// Es la unica capa que conoce el SDK de Firestore.
class FirestoreService {
  FirestoreService({FirebaseFirestore? db}) : _dbInyectada = db;

  final FirebaseFirestore? _dbInyectada;

  /// Se pide hasta usarse, asi crear el servicio no exige Firebase listo
  /// (las pruebas pueden construirlo sin inicializar Firebase).
  FirebaseFirestore get _db => _dbInyectada ?? FirebaseFirestore.instance;

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

  /// Crea un documento con id automatico y devuelve ese id.
  Future<String> agregarDocumento(
    String coleccion,
    Map<String, dynamic> datos,
  ) async {
    final ref = await _db.collection(coleccion).add(datos);
    return ref.id;
  }

  /// Documentos cuyo [campo] vale [valor], en tiempo real: emite la lista
  /// completa cada vez que alguno se crea, cambia o se borra.
  Stream<List<Documento>> observarDonde(
    String coleccion, {
    required String campo,
    required Object valor,
  }) {
    return _db
        .collection(coleccion)
        .where(campo, isEqualTo: valor)
        .snapshots()
        .map((consulta) => [
              for (final doc in consulta.docs) (id: doc.id, datos: doc.data()),
            ]);
  }
}
