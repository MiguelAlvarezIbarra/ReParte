import 'dart:async';
import 'package:reparte/models/donacion.dart';
import 'package:reparte/models/punto_entrega.dart';
import 'package:reparte/models/usuario.dart';
import 'package:reparte/repositories/donacion_repository.dart';

/// Repositorio de mentira para pruebas: las donaciones se "publican" a mano
/// con [emitir], igual que llegarian desde Firestore en tiempo real.
class DonacionRepositoryFalso extends DonacionRepository {
  final controlador = StreamController<List<Donacion>>();

  /// Punto de entrega que devuelve [obtenerPuntoEntrega].
  PuntoEntrega? punto;

  /// Si es true, [obtenerPuntoEntrega] falla como si no hubiera conexion.
  bool puntoFalla = false;

  void emitir(List<Donacion> donaciones) => controlador.add(donaciones);

  void fallar() => controlador.addError(Exception('sin conexion'));

  @override
  Stream<List<Donacion>> observarDisponibles() => controlador.stream;

  @override
  Future<PuntoEntrega?> obtenerPuntoEntrega(String id) async {
    if (puntoFalla) throw Exception('sin conexion');
    return punto;
  }
}

/// Donacion de prueba que caduca dentro de [dias] dias.
Donacion donacionDePrueba(
  String id, {
  String descripcion = 'Pan del dia',
  double cantidadKg = 3,
  int dias = 2,
  EstadoDonacion estado = EstadoDonacion.disponible,
}) {
  return Donacion(
    id: id,
    donanteId: 'd1',
    descripcion: descripcion,
    cantidadKg: cantidadKg,
    caducidad: DateTime.now().add(Duration(days: dias)),
    puntoEntregaId: 'p1',
    creadaEn: DateTime(2026, 10, 1),
    estado: estado,
  );
}

const donanteDePrueba = Usuario(
  id: 'd1',
  nombre: 'La Espiga',
  correo: 'espiga@restaurante.mx',
  rol: RolUsuario.donante,
  telefono: '555 123 4567',
);

const puntoDePrueba = PuntoEntrega(
  id: 'p1',
  donanteId: 'd1',
  nombre: 'Panaderia Central',
  direccion: 'Calle Hidalgo 12',
  latitud: 19.4,
  longitud: -99.1,
  horario: '18:00 a 20:30',
);
