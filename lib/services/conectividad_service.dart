import 'package:connectivity_plus/connectivity_plus.dart';

/// Avisa si el telefono tiene red (wifi o datos).
/// Desacopla el paquete del sistema para poder probar sin red real.
abstract class ConectividadService {
  /// Emite true con red y false sin ella, cada vez que cambia.
  Stream<bool> get enLinea;
}

/// Implementacion con connectivity_plus.
class ConnectivityPlusService implements ConectividadService {
  ConnectivityPlusService({Connectivity? conectividad})
      : _conectividad = conectividad ?? Connectivity();

  final Connectivity _conectividad;

  static bool _hayRed(List<ConnectivityResult> resultados) =>
      resultados.any((r) => r != ConnectivityResult.none);

  @override
  Stream<bool> get enLinea async* {
    yield _hayRed(await _conectividad.checkConnectivity());
    yield* _conectividad.onConnectivityChanged.map(_hayRed);
  }
}
