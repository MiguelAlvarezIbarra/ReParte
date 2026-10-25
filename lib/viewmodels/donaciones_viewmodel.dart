import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/donacion.dart';
import '../repositories/donacion_repository.dart';
import 'estado_ui.dart';

/// Cerebro de la lista de donaciones: no sabe nada de widgets.
/// Escucha al repositorio en tiempo real y deja lista la lista que se muestra:
/// solo donaciones vigentes, de la que caduca primero a la que caduca despues.
class DonacionesViewModel extends ChangeNotifier {
  DonacionesViewModel(this._repo);

  final DonacionRepository _repo;
  StreamSubscription<List<Donacion>>? _suscripcion;

  EstadoUI estado = EstadoUI.inicial;
  List<Donacion> donaciones = [];
  String? mensajeError;

  /// Empieza a escuchar los cambios. Se puede llamar de nuevo para reintentar.
  void escuchar() {
    _suscripcion?.cancel();
    estado = EstadoUI.cargando;
    mensajeError = null;
    notifyListeners();
    try {
      _suscripcion = _repo.observarDisponibles().listen(
            _alRecibir,
            onError: (_) => _alFallar(),
          );
    } catch (_) {
      _alFallar();
    }
  }

  void _alRecibir(List<Donacion> todas) {
    donaciones = todas.where((d) => d.estaDisponible).toList()
      ..sort((a, b) => a.caducidad.compareTo(b.caducidad));
    mensajeError = null;
    estado = EstadoUI.listo;
    notifyListeners();
  }

  void _alFallar() {
    mensajeError = 'No se pudieron cargar las donaciones';
    estado = EstadoUI.error;
    notifyListeners();
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}
