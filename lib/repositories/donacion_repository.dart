import '../core/constantes/colecciones.dart';
import '../models/donacion.dart';
import '../models/punto_entrega.dart';
import '../services/firestore_service.dart';

/// Fuente unica de verdad de las donaciones.
/// Los ViewModels solo hablan con esta clase, nunca con Firebase.
class DonacionRepository {
  DonacionRepository({required FirestoreService firestore})
      : _firestore = firestore;

  final FirestoreService _firestore;

  /// Donaciones en tiempo real: emite la lista completa cada vez que algo
  /// cambia en la base de datos. El ViewModel se encarga de filtrarla.
  Stream<List<Donacion>> observarDisponibles() {
    return _firestore
        .observarDonde(
          Colecciones.donaciones,
          campo: 'estado',
          valor: EstadoDonacion.disponible.name,
        )
        .map((docs) => [
              for (final doc in docs)
                if (_aDonacion(doc) case final donacion?) donacion,
            ]);
  }

  /// Lugar de entrega de una donacion; null si ya no existe.
  Future<PuntoEntrega?> obtenerPuntoEntrega(String id) async {
    final datos = await _firestore.leerDocumento(Colecciones.puntosEntrega, id);
    return datos == null ? null : PuntoEntrega.fromMap(id, datos);
  }

  /// Guarda un punto de entrega nuevo y devuelve su id.
  Future<String> crearPuntoEntrega(PuntoEntrega punto) {
    return _firestore.agregarDocumento(
      Colecciones.puntosEntrega,
      punto.toMap(),
    );
  }

  /// Publica una donacion y devuelve su id.
  Future<String> crear(Donacion donacion) {
    return _firestore.agregarDocumento(
      Colecciones.donaciones,
      donacion.toMap(),
    );
  }

  /// Un documento mal formado se ignora para no tirar la lista completa.
  Donacion? _aDonacion(Documento doc) {
    try {
      return Donacion.fromMap(doc.id, doc.datos);
    } catch (_) {
      return null;
    }
  }
}
