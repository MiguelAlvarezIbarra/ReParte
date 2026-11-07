import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/donacion.dart';
import '../repositories/donacion_repository.dart';
import 'estado_ui.dart';

/// De quien es la lista: lo que publico un donante o lo que reservo
/// una asociacion.
enum DuenoLista { donante, asociacion }

/// Pestanas de la lista: lo que sigue en curso o lo que ya termino.
enum FiltroMisDonaciones { activas, historial }

/// Cerebro de "Mis donaciones" (donante) y "Mis reservas" (asociacion).
/// Escucha en tiempo real y separa las activas del historial.
class MisDonacionesViewModel extends ChangeNotifier {
  MisDonacionesViewModel(
    this._repo, {
    required this.usuarioId,
    required this.dueno,
  });

  final DonacionRepository _repo;
  final String usuarioId;
  final DuenoLista dueno;
  StreamSubscription<List<Donacion>>? _suscripcion;

  EstadoUI estado = EstadoUI.inicial;
  String? mensajeError;
  FiltroMisDonaciones filtro = FiltroMisDonaciones.activas;
  List<Donacion> _todas = [];

  /// Las de la pestana elegida, de la mas reciente a la mas antigua.
  List<Donacion> get donaciones {
    final activas = filtro == FiltroMisDonaciones.activas;
    return _todas.where((d) => _esActiva(d) == activas).toList()
      ..sort((a, b) => b.creadaEn.compareTo(a.creadaEn));
  }

  /// En curso: disponible y vigente, o reservada esperando la entrega.
  static bool _esActiva(Donacion d) =>
      d.estaDisponible || d.estado == EstadoDonacion.reservada;

  void escuchar() {
    _suscripcion?.cancel();
    estado = EstadoUI.cargando;
    mensajeError = null;
    notifyListeners();
    try {
      final flujo = dueno == DuenoLista.donante
          ? _repo.observarDeDonante(usuarioId)
          : _repo.observarReservadasPor(usuarioId);
      _suscripcion = flujo.listen(_alRecibir, onError: (_) => _alFallar());
    } catch (_) {
      _alFallar();
    }
  }

  void elegir(FiltroMisDonaciones nuevo) {
    if (nuevo == filtro) return;
    filtro = nuevo;
    notifyListeners();
  }

  void _alRecibir(List<Donacion> lista) {
    _todas = lista;
    mensajeError = null;
    estado = EstadoUI.listo;
    notifyListeners();
  }

  void _alFallar() {
    mensajeError = dueno == DuenoLista.donante
        ? 'No se pudieron cargar tus donaciones'
        : 'No se pudieron cargar tus reservas';
    estado = EstadoUI.error;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}
