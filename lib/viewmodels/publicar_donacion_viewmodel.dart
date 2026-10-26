import 'package:flutter/foundation.dart';
import '../core/utilidades/validadores.dart';

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
// TODO(T12): recibir DonacionRepository y guardar la donacion.
class PublicarDonacionViewModel extends ChangeNotifier {
  DatosDonacion? borrador;
  String? mensajeError;

  /// Valida lo capturado y arma los [DatosDonacion].
  /// Devuelve false y deja el motivo en [mensajeError] si algo no cuadra.
  bool preparar({
    required String descripcion,
    required String cantidad,
    required DateTime? fechaCaducidad,
    required String puntoNombre,
    required String puntoDireccion,
  }) {
    final error = Validadores.obligatorio(
            descripcion, 'Describe qué vas a donar') ??
        Validadores.cantidadKg(cantidad) ??
        Validadores.caducidad(fechaCaducidad) ??
        Validadores.obligatorio(
            puntoNombre, 'Escribe el nombre del punto de entrega') ??
        Validadores.obligatorio(
            puntoDireccion, 'Escribe la dirección de entrega');

    if (error != null) {
      borrador = null;
      mensajeError = error;
      notifyListeners();
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
    notifyListeners();
    return true;
  }
}
