import 'dart:async';
import 'package:reparte/models/donacion.dart';
import 'package:reparte/models/punto_entrega.dart';
import 'package:reparte/models/usuario.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/services/firestore_service.dart';

/// Repositorio de mentira para pruebas: las donaciones se "publican" a mano
/// con [emitir], igual que llegarian desde Firestore en tiempo real.
class DonacionRepositoryFalso extends DonacionRepository {
  DonacionRepositoryFalso() : super(firestore: FirestoreQueFalla());

  final controlador = StreamController<List<Donacion>>();

  /// Punto de entrega que devuelve [obtenerPuntoEntrega].
  PuntoEntrega? punto;

  /// Si es true, [obtenerPuntoEntrega] falla como si no hubiera conexion.
  bool puntoFalla = false;

  /// Lo que se publico con [crear] y [crearPuntoEntrega].
  final creadas = <Donacion>[];
  final puntosCreados = <PuntoEntrega>[];

  /// Si es true, publicar falla como si no hubiera conexion.
  bool crearFalla = false;

  void emitir(List<Donacion> donaciones) => controlador.add(donaciones);

  @override
  Future<String> crearPuntoEntrega(PuntoEntrega punto) async {
    punto.validar();
    if (crearFalla) throw Exception('sin conexion');
    puntosCreados.add(punto);
    return 'p${puntosCreados.length}';
  }

  @override
  Future<String> crear(Donacion donacion) async {
    donacion.validar();
    if (crearFalla) throw Exception('sin conexion');
    creadas.add(donacion);
    return 'd${creadas.length}';
  }

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

/// Base de datos sin conexion: toda lectura falla, como sin internet.
class FirestoreQueFalla extends FirestoreService {
  @override
  Future<Map<String, dynamic>?> leerDocumento(String coleccion, String id) =>
      Future.error(Exception('sin conexion'));

  @override
  Stream<List<Documento>> observarDonde(
    String coleccion, {
    required String campo,
    required Object valor,
  }) =>
      Stream.error(Exception('sin conexion'));
}
