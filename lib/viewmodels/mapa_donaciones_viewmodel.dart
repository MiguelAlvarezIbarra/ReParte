import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/donacion.dart';
import '../models/punto_entrega.dart';
import '../repositories/donacion_repository.dart';
import 'estado_ui.dart';

/// Una donacion disponible junto con el lugar donde se recoge.
typedef DonacionEnMapa = ({Donacion donacion, PuntoEntrega punto});

/// Cerebro del mapa de donaciones: escucha las disponibles y busca el
/// punto de entrega de cada una para poder ponerlas en el mapa.
class MapaDonacionesViewModel extends ChangeNotifier {
  MapaDonacionesViewModel(this._repo);

  final DonacionRepository _repo;
  StreamSubscription<List<Donacion>>? _suscripcion;
  final _puntos = <String, PuntoEntrega?>{};
  bool _cerrado = false;

  EstadoUI estado = EstadoUI.inicial;
  String? mensajeError;
  List<DonacionEnMapa> enMapa = [];

  /// La que el usuario toco en el mapa.
  DonacionEnMapa? seleccionada;

  void escuchar() {
    _suscripcion?.cancel();
    estado = EstadoUI.cargando;
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

  void seleccionar(DonacionEnMapa? item) {
    seleccionada = item;
    notifyListeners();
  }

  Future<void> _alRecibir(List<Donacion> todas) async {
    final vigentes = todas.where((d) => d.estaDisponible).toList();
    final faltan = vigentes
        .map((d) => d.puntoEntregaId)
        .where((id) => !_puntos.containsKey(id))
        .toSet();
    await Future.wait(faltan.map((id) async {
      try {
        _puntos[id] = await _repo.obtenerPuntoEntrega(id);
      } catch (_) {
        _puntos[id] = null;
      }
    }));
    if (_cerrado) return;
    enMapa = [
      for (final d in vigentes)
        if (_puntos[d.puntoEntregaId] case final punto?)
          // Los puntos viejos sin ubicacion quedaron en 0,0: no se dibujan.
          if (punto.latitud != 0 || punto.longitud != 0)
            (donacion: d, punto: punto),
    ];
    if (seleccionada != null &&
        !enMapa.any((e) => e.donacion.id == seleccionada!.donacion.id)) {
      seleccionada = null;
    }
    estado = EstadoUI.listo;
    notifyListeners();
  }

  void _alFallar() {
    mensajeError = 'No se pudieron cargar las donaciones';
    estado = EstadoUI.error;
    if (!_cerrado) notifyListeners();
  }

  @override
  void dispose() {
    _cerrado = true;
    _suscripcion?.cancel();
    super.dispose();
  }
}
