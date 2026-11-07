import 'package:flutter/foundation.dart';
import '../models/donacion.dart';
import '../models/punto_entrega.dart';
import '../models/usuario.dart';
import '../repositories/donacion_repository.dart';
import '../repositories/usuario_repository.dart';
import 'estado_ui.dart';

/// Cerebro de la pantalla de detalle: junta la donacion con quien la publico
/// y el lugar donde se entrega. No sabe nada de widgets.
/// La donacion ya viene en mano; si el donante o el punto no se pueden leer,
/// el resto del detalle se muestra igual.
/// Si lo abre una asociacion ([asociacionId]), tambien puede reservarla.
class DetalleDonacionViewModel extends ChangeNotifier {
  DetalleDonacionViewModel({
    required this.donacion,
    required DonacionRepository donaciones,
    required UsuarioRepository usuarios,
    this.asociacionId,
  })  : _donaciones = donaciones,
        _usuarios = usuarios;

  Donacion donacion;

  /// Asociacion que mira el detalle; null si lo abre otro rol.
  final String? asociacionId;
  final DonacionRepository _donaciones;
  final UsuarioRepository _usuarios;

  EstadoUI estado = EstadoUI.inicial;
  Usuario? donante;
  PuntoEntrega? punto;
  bool _cerrado = false;

  bool reservando = false;
  String? errorReserva;

  bool get puedeReservar =>
      asociacionId != null && donacion.estaDisponible && !reservando;

  /// True si la reservo la asociacion que mira el detalle.
  bool get reservadaPorMi =>
      asociacionId != null &&
      donacion.estado == EstadoDonacion.reservada &&
      donacion.asociacionId == asociacionId;

  bool get cargando =>
      estado == EstadoUI.inicial || estado == EstadoUI.cargando;
  bool get donanteNoDisponible => !cargando && donante == null;
  bool get puntoNoDisponible => !cargando && punto == null;

  Future<void> cargar() async {
    estado = EstadoUI.cargando;
    notifyListeners();

    final resultados = await Future.wait<Object?>([
      _intentar(() => _usuarios.obtenerPerfil(donacion.donanteId)),
      _intentar(() => _donaciones.obtenerPuntoEntrega(donacion.puntoEntregaId)),
    ]);

    donante = resultados[0] as Usuario?;
    punto = resultados[1] as PuntoEntrega?;
    estado = EstadoUI.listo;
    if (!_cerrado) notifyListeners();
  }

  /// Reserva la donacion para la asociacion. Devuelve true si lo logro.
  Future<bool> reservar() async {
    if (!puedeReservar) return false;
    reservando = true;
    errorReserva = null;
    notifyListeners();
    try {
      donacion = await _donaciones.reservar(donacion, asociacionId!);
      return true;
    } on DonacionNoDisponible catch (e) {
      errorReserva = e.mensaje;
      return false;
    } catch (_) {
      errorReserva =
          'No se pudo reservar. Revisa tu conexión e intenta de nuevo.';
      return false;
    } finally {
      reservando = false;
      if (!_cerrado) notifyListeners();
    }
  }

  /// Un dato que falla no tira el resto: se queda en null.
  Future<Object?> _intentar(Future<Object?> Function() accion) async {
    try {
      return await accion();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _cerrado = true;
    super.dispose();
  }
}
