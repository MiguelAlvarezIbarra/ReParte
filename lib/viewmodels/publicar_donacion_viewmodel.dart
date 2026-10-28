import 'package:flutter/foundation.dart';
import '../core/utilidades/validadores.dart';
import '../models/donacion.dart';
import '../models/punto_entrega.dart';
import '../repositories/donacion_repository.dart';
import '../services/ubicacion_service.dart';
import 'estado_ui.dart';

/// Lo que el donante captura en el formulario, ya limpio y convertido.
class DatosDonacion {
  const DatosDonacion({
    required this.descripcion,
    required this.cantidadKg,
    required this.caducidad,
    required this.puntoNombre,
    required this.puntoDireccion,
    this.latitud = 0,
    this.longitud = 0,
  });

  final String descripcion;
  final double cantidadKg;

  /// Ultimo instante del dia elegido: la donacion vale todo ese dia.
  final DateTime caducidad;
  final String puntoNombre;
  final String puntoDireccion;
  final double latitud;
  final double longitud;
}

/// Cerebro del formulario de publicar donacion: no sabe nada de widgets.
/// Valida lo capturado, maneja la ubicación/GPS y lo guarda en el repositorio.
class PublicarDonacionViewModel extends ChangeNotifier {
  PublicarDonacionViewModel(
    this._repo, {
    required this.donanteId,
    UbicacionService? ubicacionService,
  }) : _ubicacionService = ubicacionService ?? const GeolocatorUbicacionService();

  final DonacionRepository _repo;
  final String donanteId;
  final UbicacionService _ubicacionService;

  EstadoUI estado = EstadoUI.inicial;
  DatosDonacion? borrador;
  String? mensajeError;

  double? latitud;
  double? longitud;
  bool obteniendoUbicacion = false;

  bool get publicando => estado == EstadoUI.cargando;
  bool get tieneCoordenadas =>
      latitud != null && longitud != null && (latitud != 0 || longitud != 0);

  /// Fija manualmente las coordenadas seleccionadas en el mapa.
  void fijarUbicacion({required double lat, required double lng}) {
    latitud = lat;
    longitud = lng;
    notifyListeners();
  }

  /// Pide permiso y consulta la ubicación actual por GPS.
  /// Devuelve las coordenadas y dirección obtenidas si fue posible.
  Future<({double latitud, double longitud, String? direccion})?>
      obtenerUbicacionActual() async {
    obteniendoUbicacion = true;
    notifyListeners();

    try {
      final posicion = await _ubicacionService.obtenerUbicacionActual();
      if (posicion == null) {
        mensajeError =
            'No se pudo obtener la ubicación. Verifica los permisos de GPS.';
        return null;
      }

      latitud = posicion.latitud;
      longitud = posicion.longitud;
      final direccion = await _ubicacionService.obtenerDireccion(
        posicion.latitud,
        posicion.longitud,
      );
      mensajeError = null;
      return (
        latitud: posicion.latitud,
        longitud: posicion.longitud,
        direccion: direccion,
      );
    } catch (_) {
      mensajeError = 'Error al obtener la ubicación actual';
      return null;
    } finally {
      obteniendoUbicacion = false;
      notifyListeners();
    }
  }

  /// Valida y guarda la donacion con su punto de entrega y coordenadas.
  /// Devuelve true si quedo publicada; si no, deja el motivo en [mensajeError].
  Future<bool> publicar({
    required String descripcion,
    required String cantidad,
    required DateTime? fechaCaducidad,
    required String puntoNombre,
    required String puntoDireccion,
    double? latitud,
    double? longitud,
  }) async {
    if (publicando) return false;
    final lat = latitud ?? this.latitud ?? 0;
    final lng = longitud ?? this.longitud ?? 0;

    final valido = _validar(
      descripcion: descripcion,
      cantidad: cantidad,
      fechaCaducidad: fechaCaducidad,
      puntoNombre: puntoNombre,
      puntoDireccion: puntoDireccion,
      latitud: lat,
      longitud: lng,
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
        latitud: datos.latitud,
        longitud: datos.longitud,
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
    } on ArgumentError catch (e) {
      mensajeError = e.message?.toString() ?? 'Datos de la donación inválidos';
      estado = EstadoUI.error;
      notifyListeners();
      return false;
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
    double? latitud,
    double? longitud,
  }) {
    final ok = _validar(
      descripcion: descripcion,
      cantidad: cantidad,
      fechaCaducidad: fechaCaducidad,
      puntoNombre: puntoNombre,
      puntoDireccion: puntoDireccion,
      latitud: latitud ?? this.latitud ?? 0,
      longitud: longitud ?? this.longitud ?? 0,
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
    double latitud = 0,
    double longitud = 0,
  }) {
    final error = Validadores.obligatorio(
            donanteId, 'Identificador de donante inválido') ??
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
      latitud: latitud,
      longitud: longitud,
    );
    mensajeError = null;
    return true;
  }
}
