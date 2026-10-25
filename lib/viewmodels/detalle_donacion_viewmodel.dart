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
class DetalleDonacionViewModel extends ChangeNotifier {
  DetalleDonacionViewModel({
    required this.donacion,
    required DonacionRepository donaciones,
    required UsuarioRepository usuarios,
  })  : _donaciones = donaciones,
        _usuarios = usuarios;

  final Donacion donacion;
  final DonacionRepository _donaciones;
  final UsuarioRepository _usuarios;

  EstadoUI estado = EstadoUI.inicial;
  Usuario? donante;
  PuntoEntrega? punto;
  bool _cerrado = false;

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
