import '../models/donacion.dart';

/// Fuente unica de verdad de las donaciones.
/// Los ViewModels solo hablan con esta clase, nunca con Firebase.
class DonacionRepository {
  // TODO(T12): recibir FirestoreService por constructor.

  Future<List<Donacion>> obtenerDisponibles() async {
    throw UnimplementedError('Pendiente: tarea T12');
  }

  Future<void> crear(Donacion donacion) async {
    throw UnimplementedError('Pendiente: tarea T12');
  }
}
