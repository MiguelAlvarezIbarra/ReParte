import '../core/constantes/colecciones.dart';
import '../models/donacion.dart';
import '../models/punto_entrega.dart';
import '../services/firestore_service.dart';

/// La donacion ya no se puede reservar: otra asociacion la tomo,
/// el donante la cancelo o ya caduco.
class DonacionNoDisponible implements Exception {
  const DonacionNoDisponible();

  String get mensaje => 'Esta donación ya no está disponible';

  @override
  String toString() => mensaje;
}

/// Solo una donacion reservada se puede marcar como entregada.
class DonacionNoEntregable implements Exception {
  const DonacionNoEntregable();

  String get mensaje => 'Solo se puede entregar una donación reservada';

  @override
  String toString() => mensaje;
}

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

  /// Todas las donaciones que publico [donanteId], en tiempo real.
  Stream<List<Donacion>> observarDeDonante(String donanteId) =>
      _observarDonde('donanteId', donanteId);

  /// Las donaciones que reservo [asociacionId], en tiempo real.
  Stream<List<Donacion>> observarReservadasPor(String asociacionId) =>
      _observarDonde('asociacionId', asociacionId);

  Stream<List<Donacion>> _observarDonde(String campo, String valor) {
    return _firestore
        .observarDonde(Colecciones.donaciones, campo: campo, valor: valor)
        .map((docs) => [
              for (final doc in docs)
                if (_aDonacion(doc) case final donacion?) donacion,
            ]);
  }

  /// Reserva [donacion] para [asociacionId] y devuelve la donacion reservada.
  /// Lanza [DonacionNoDisponible] si ya no esta disponible.
  ///
  /// Se hace en una transaccion (T20): el estado se vuelve a leer en el
  /// servidor justo antes de escribir, asi que si dos asociaciones reservan
  /// al mismo tiempo solo una lo logra y la otra recibe el aviso.
  Future<Donacion> reservar(Donacion donacion, String asociacionId) async {
    if (!donacion.estaDisponible) throw const DonacionNoDisponible();
    final reservada = donacion.copyWith(
      estado: EstadoDonacion.reservada,
      asociacionId: asociacionId,
      reservadaEn: DateTime.now(),
    );
    try {
      await _firestore.actualizarEnTransaccion(
        Colecciones.donaciones,
        donacion.id,
        (actual) => cambiosParaReservar(actual, reservada),
      );
    } on CambioRechazado {
      throw const DonacionNoDisponible();
    }
    return reservada;
  }

  /// Campos a escribir para reservar, o null si en el servidor ya no esta
  /// disponible (otra asociacion la tomo, se cancelo o se borro).
  static Map<String, dynamic>? cambiosParaReservar(
    Map<String, dynamic>? actual,
    Donacion reservada,
  ) {
    if (actual == null) return null;
    if (actual['estado'] != EstadoDonacion.disponible.name) return null;
    if (actual['asociacionId'] != null) return null;
    return {
      'estado': reservada.estado.name,
      'asociacionId': reservada.asociacionId,
      'reservadaEn': reservada.reservadaEn!.toIso8601String(),
    };
  }

  /// Cierra la donacion como entregada con la fecha de hoy y la devuelve.
  /// Lanza [DonacionNoEntregable] si no esta reservada.
  Future<Donacion> marcarEntregada(Donacion donacion) async {
    if (donacion.estado != EstadoDonacion.reservada) {
      throw const DonacionNoEntregable();
    }
    final entregada = donacion.copyWith(
      estado: EstadoDonacion.entregada,
      entregadaEn: DateTime.now(),
    );
    await _firestore.actualizarDocumento(
      Colecciones.donaciones,
      donacion.id,
      {
        'estado': entregada.estado.name,
        'entregadaEn': entregada.entregadaEn!.toIso8601String(),
      },
    );
    return entregada;
  }

  /// Lugar de entrega de una donacion; null si ya no existe.
  Future<PuntoEntrega?> obtenerPuntoEntrega(String id) async {
    final datos = await _firestore.leerDocumento(Colecciones.puntosEntrega, id);
    return datos == null ? null : PuntoEntrega.fromMap(id, datos);
  }

  /// Guarda un punto de entrega nuevo y devuelve su id.
  /// Valida que no tenga datos vacíos antes de guardarlo.
  Future<String> crearPuntoEntrega(PuntoEntrega punto) {
    punto.validar();
    return _firestore.agregarDocumento(
      Colecciones.puntosEntrega,
      punto.toMap(),
    );
  }

  /// Publica una donacion y devuelve su id.
  /// Valida los datos antes de guardarla: no se guardan donaciones con campos
  /// vacíos, cantidad en cero o fecha de caducidad pasada.
  Future<String> crear(Donacion donacion) {
    donacion.validar();
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
