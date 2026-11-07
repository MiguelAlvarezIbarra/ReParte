import 'dart:async';
import '../core/utilidades/formato.dart';
import '../models/donacion.dart';
import '../repositories/donacion_repository.dart';
import '../repositories/usuario_repository.dart';
import '../services/notificaciones_service.dart';

/// Escucha en tiempo real las donaciones de un donante y le muestra un
/// aviso en el telefono cuando una asociacion reserva una (T21, H5).
///
/// Funciona mientras la app esta abierta o en segundo plano. Para avisar con
/// la app cerrada haria falta Cloud Functions con FCM (plan Blaze).
class AvisadorReservas {
  AvisadorReservas({
    required DonacionRepository donaciones,
    required UsuarioRepository usuarios,
    required NotificacionesService notificaciones,
    required this.donanteId,
  })  : _donaciones = donaciones,
        _usuarios = usuarios,
        _notificaciones = notificaciones;

  final DonacionRepository _donaciones;
  final UsuarioRepository _usuarios;
  final NotificacionesService _notificaciones;
  final String donanteId;

  StreamSubscription<List<Donacion>>? _suscripcion;

  /// Ultimo estado conocido de cada donacion; null hasta la primera lista,
  /// para no avisar de reservas que ya existian al abrir la app.
  Map<String, EstadoDonacion>? _estados;

  void iniciar() {
    _suscripcion?.cancel();
    _estados = null;
    _suscripcion = _donaciones.observarDeDonante(donanteId).listen(
          _alRecibir,
          // Si falla la escucha no se avisa, pero la app sigue funcionando.
          onError: (_) {},
        );
  }

  Future<void> _alRecibir(List<Donacion> lista) async {
    final anteriores = _estados;
    _estados = {for (final d in lista) d.id: d.estado};
    if (anteriores == null) return;
    for (final d in lista) {
      final antes = anteriores[d.id];
      if (d.estado == EstadoDonacion.reservada &&
          antes != null &&
          antes != EstadoDonacion.reservada) {
        await _avisar(d);
      }
    }
  }

  Future<void> _avisar(Donacion d) async {
    String? quien;
    try {
      final id = d.asociacionId;
      if (id != null) quien = (await _usuarios.obtenerPerfil(id))?.nombre;
    } catch (_) {
      quien = null;
    }
    await _notificaciones.mostrar(
      id: d.id.hashCode,
      titulo: '¡Reservaron tu donación!',
      mensaje: '${quien ?? 'Una asociación'} reservó '
          '"${d.descripcion}" (${Formato.kilos(d.cantidadKg)}). '
          'Prepárala para la entrega.',
    );
  }

  void detener() {
    _suscripcion?.cancel();
    _suscripcion = null;
  }
}
