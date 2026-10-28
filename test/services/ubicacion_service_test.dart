import 'package:flutter_test/flutter_test.dart';
import '../fakes/ubicacion_service_falso.dart';

void main() {
  late UbicacionServiceFalso servicio;

  setUp(() {
    servicio = UbicacionServiceFalso();
  });

  test('solicitarPermiso devuelve el estado del permiso', () async {
    expect(await servicio.solicitarPermiso(), isTrue);
    expect(servicio.llamadasSolicitarPermiso, 1);

    servicio.permisoConcedido = false;
    expect(await servicio.solicitarPermiso(), isFalse);
    expect(servicio.llamadasSolicitarPermiso, 2);
  });

  test('obtenerUbicacionActual devuelve coordenadas si hay permiso', () async {
    final pos = await servicio.obtenerUbicacionActual();
    expect(pos, isNotNull);
    expect(pos!.latitud, 21.1561);
    expect(pos.longitud, -100.9346);

    servicio.permisoConcedido = false;
    expect(await servicio.obtenerUbicacionActual(), isNull);
  });

  test('obtenerDireccion traduce coordenadas a direccion legible', () async {
    final dir = await servicio.obtenerDireccion(21.1561, -100.9346);
    expect(dir, 'Calle Hidalgo 12, Dolores Hidalgo');
    expect(servicio.llamadasObtenerDireccion, 1);
  });
}
