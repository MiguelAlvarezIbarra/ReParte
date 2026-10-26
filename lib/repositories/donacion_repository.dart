import '../models/donacion.dart';
import '../models/punto_entrega.dart';

/// Fuente unica de verdad de las donaciones.
/// Los ViewModels solo hablan con esta clase, nunca con Firebase.
class DonacionRepository {
  // TODO(T12): recibir FirestoreService por constructor.

  Future<List<Donacion>> obtenerDisponibles() async {
    throw UnimplementedError('Pendiente: tarea T12');
  }

  /// Donaciones en tiempo real: emite la lista completa cada vez que algo
  /// cambia en la base de datos. El ViewModel se encarga de filtrarla.
  Stream<List<Donacion>> observarDisponibles() {
    // TODO(T12): conectar con un stream de Firestore (FirestoreService).
    throw UnimplementedError('Pendiente: tarea T12');
  }

  /// Lugar de entrega de una donacion; null si ya no existe.
  Future<PuntoEntrega?> obtenerPuntoEntrega(String id) async {
    // TODO(T12): leer la coleccion puntos_entrega con FirestoreService.
    throw UnimplementedError('Pendiente: tarea T12');
  }

  Future<void> crear(Donacion donacion) async {
    throw UnimplementedError('Pendiente: tarea T12');
  }
}
