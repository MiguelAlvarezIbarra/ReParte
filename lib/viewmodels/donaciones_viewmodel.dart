import 'package:flutter/foundation.dart';
import '../models/donacion.dart';
import '../repositories/donacion_repository.dart';

/// Estados posibles de la pantalla de donaciones.
enum EstadoUI { inicial, cargando, listo, error }

/// Cerebro de la pantalla de donaciones: no sabe nada de widgets.
class DonacionesViewModel extends ChangeNotifier {
  DonacionesViewModel(this._repo);

  final DonacionRepository _repo;

  EstadoUI estado = EstadoUI.inicial;
  List<Donacion> donaciones = [];
  String? mensajeError;

  Future<void> cargarDonaciones() async {
    estado = EstadoUI.cargando;
    notifyListeners();
    try {
      donaciones = await _repo.obtenerDisponibles();
      estado = EstadoUI.listo;
    } catch (e) {
      mensajeError = 'No se pudieron cargar las donaciones';
      estado = EstadoUI.error;
    }
    notifyListeners();
  }
}
