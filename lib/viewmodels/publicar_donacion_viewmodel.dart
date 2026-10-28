import 'package:flutter/foundation.dart';
import '../core/utilidades/validadores.dart';
import '../models/donacion.dart';
import '../models/punto_entrega.dart';
import '../repositories/donacion_repository.dart';
import 'estado_ui.dart';

/// Lo que el donante captura en el formulario, ya limpio y convertido.
class DatosDonacion {
  const DatosDonacion({
    required this.descripcion,
    required this.cantidadKg,
    required this.caducidad,
    required this.puntoNombre,
    required this.puntoDireccion,
  });

  final String descripcion;
  final double cantidadKg;

  /// Ultimo instante del dia elegido: la donacion vale todo ese dia.
  final DateTime caducidad;
  final String puntoNombre;
  final String puntoDireccion;
}

/// Cerebro del formulario de publicar donacion: no sabe nada de widgets.
/// Valida lo capturado y lo guarda en el repositorio a nombre del donante.
class PublicarDonacionViewModel extends ChangeNotifier {
  PublicarDonacionViewModel(this._repo, {required this.donanteId});

  final DonacionRepository _repo;
  final String donanteId;

  EstadoUI estado = EstadoUI.inicial;
  DatosDonacion? borrador;
  String? mensajeError;

  bool get publicando => estado == EstadoUI.cargando;

  /// Valida y guarda la donacion con su punto de entrega.
  /// Devuelve true si quedo publicada; si no, deja el motivo en [mensajeError].
  Future<bool> publicar({
    required String descripcion,
    required String cantidad,
    required DateTime? fechaCaducidad,
    required String puntoNombre,
    required String puntoDireccion,
  }) async {
    if (publicando) return false;
    final valido = _validar(
      descripcion: descripcion,
      cantidad: cantidad,
      fechaCaducidad: fechaCaducidad,
      puntoNombre: puntoNombre,
      puntoDireccion: puntoDireccion,
    );
    if (!valido) {
      estado = EstadoUI.error;
      notifyListeners();
      return false;
    }

    estado = EstadoUI.cargando;
    notifyListeners();
    final datos = borrador!;
    try {
      final puntoId = await _repo.crearPuntoEntrega(PuntoEntrega(
        id: '',
        donanteId: donanteId,
        nombre: datos.puntoNombre,
        direccion: datos.puntoDireccion,
        // TODO(T15): coordenadas reales al elegir el punto en el mapa.
        latitud: 0,
        longitud: 0,
      ));
      await _repo.crear(Donacion(
        id: '',
        donanteId: donanteId,
        descripcion: datos.descripcion,
        cantidadKg: datos.cantidadKg,
        caducidad: datos.caducidad,
        puntoEntregaId: puntoId,
        creadaEn: DateTime.now(),
      ));
      estado = EstadoUI.listo;
      notifyListeners();
      return true;
    } catch (_) {
      mensajeError = 'No se pudo publicar la donación. '
          'Revisa tu conexión e intenta de nuevo.';
      estado = EstadoUI.error;
      notifyListeners();
      return false;
    }
  }

  /// Valida lo capturado y arma los [DatosDonacion].
  /// Devuelve false y deja el motivo en [mensajeError] si algo no cuadra.
  bool preparar({
    required String descripcion,
    required String cantidad,
    required DateTime? fechaCaducidad,
    required String puntoNombre,
    required String puntoDireccion,
  }) {
    final ok = _validar(
      descripcion: descripcion,
      cantidad: cantidad,
      fechaCaducidad: fechaCaducidad,
      puntoNombre: puntoNombre,
      puntoDireccion: puntoDireccion,
    );
    notifyListeners();
    return ok;
  }

  /// Igual que [preparar] pero sin avisar a la vista.
  bool _validar({
    required String descripcion,
    required String cantidad,
    required DateTime? fechaCaducidad,
    required String puntoNombre,
    required String puntoDireccion,
  }) {
    final error =
        Validadores.obligatorio(descripcion, 'Describe qué vas a donar') ??
            Validadores.cantidadKg(cantidad) ??
            Validadores.caducidad(fechaCaducidad) ??
            Validadores.obligatorio(
                puntoNombre, 'Escribe el nombre del punto de entrega') ??
            Validadores.obligatorio(
                puntoDireccion, 'Escribe la dirección de entrega');

    if (error != null) {
      borrador = null;
      mensajeError = error;
      return false;
    }

    final fecha = fechaCaducidad!;
    borrador = DatosDonacion(
      descripcion: descripcion.trim(),
      cantidadKg: Validadores.parsearCantidad(cantidad)!,
      caducidad: DateTime(fecha.year, fecha.month, fecha.day, 23, 59),
      puntoNombre: puntoNombre.trim(),
      puntoDireccion: puntoDireccion.trim(),
    );
    mensajeError = null;
    return true;
  }
}
