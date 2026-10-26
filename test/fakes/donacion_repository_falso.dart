import 'dart:async';
import 'package:reparte/models/donacion.dart';
import 'package:reparte/repositories/donacion_repository.dart';

/// Repositorio de mentira para pruebas: las donaciones se "publican" a mano
/// con [emitir], igual que llegarian desde Firestore en tiempo real.
class DonacionRepositoryFalso extends DonacionRepository {
  final controlador = StreamController<List<Donacion>>();

  void emitir(List<Donacion> donaciones) => controlador.add(donaciones);

  void fallar() => controlador.addError(Exception('sin conexion'));

  @override
  Stream<List<Donacion>> observarDisponibles() => controlador.stream;
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
