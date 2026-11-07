import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/models/donacion.dart';
import 'package:reparte/models/punto_entrega.dart';
import 'package:reparte/services/navegacion_service.dart';
import 'package:reparte/viewmodels/donaciones_viewmodel.dart';
import 'package:reparte/viewmodels/estado_ui.dart';
import 'package:reparte/viewmodels/mapa_donaciones_viewmodel.dart';
import 'package:reparte/viewmodels/mis_donaciones_viewmodel.dart';

import '../fakes/donacion_repository_falso.dart';

/// Repositorio falso cuyos puntos de entrega dependen del id.
class _RepoConPuntos extends DonacionRepositoryFalso {
  final puntosPorId = <String, PuntoEntrega?>{};

  @override
  Future<PuntoEntrega?> obtenerPuntoEntrega(String id) async => puntosPorId[id];
}

PuntoEntrega _punto(String id, double lat, double lng) => PuntoEntrega(
      id: id,
      donanteId: 'd1',
      nombre: 'Punto $id',
      direccion: 'Calle $id',
      latitud: lat,
      longitud: lng,
    );

Donacion _donacion(
  String id, {
  EstadoDonacion estado = EstadoDonacion.disponible,
  int diasCaducidad = 2,
  DateTime? creadaEn,
  String punto = 'p1',
}) {
  return Donacion(
    id: id,
    donanteId: 'd1',
    descripcion: 'Donacion $id',
    cantidadKg: 2,
    caducidad: DateTime.now().add(Duration(days: diasCaducidad)),
    puntoEntregaId: punto,
    creadaEn: creadaEn ?? DateTime(2026, 11, 1),
    estado: estado,
  );
}

void main() {
  group('MisDonacionesViewModel (T22)', () {
    test('el donante ve sus activas, de la mas nueva a la mas vieja', () async {
      final repo = DonacionRepositoryFalso()
        ..deDonante = [
          _donacion('vieja', creadaEn: DateTime(2026, 11, 1)),
          _donacion('nueva', creadaEn: DateTime(2026, 11, 5)),
          _donacion('reservada', estado: EstadoDonacion.reservada),
          _donacion('entregada', estado: EstadoDonacion.entregada),
          _donacion('caducada', diasCaducidad: -1),
        ];
      final vm = MisDonacionesViewModel(repo,
          usuarioId: 'd1', dueno: DuenoLista.donante)
        ..escuchar();
      await Future<void>.delayed(Duration.zero);

      expect(repo.donanteConsultado, 'd1');
      expect(vm.estado, EstadoUI.listo);
      expect(vm.donaciones.map((d) => d.id), ['nueva', 'vieja', 'reservada']);

      vm.elegir(FiltroMisDonaciones.historial);
      expect(vm.donaciones.map((d) => d.id),
          containsAll(['entregada', 'caducada']));
      expect(vm.donaciones, hasLength(2));
    });

    test('la asociacion consulta las que ella reservo', () async {
      final repo = DonacionRepositoryFalso()
        ..reservadasPorAsociacion = [
          _donacion('r1', estado: EstadoDonacion.reservada),
        ];
      final vm = MisDonacionesViewModel(repo,
          usuarioId: 'as1', dueno: DuenoLista.asociacion)
        ..escuchar();
      await Future<void>.delayed(Duration.zero);

      expect(repo.asociacionConsultada, 'as1');
      expect(vm.donaciones.single.id, 'r1');
    });

    test('si falla muestra un mensaje segun quien es', () async {
      final repo = DonacionRepositoryFalso();
      final vm = MisDonacionesViewModel(
        _RepoQueFalla(repo),
        usuarioId: 'as1',
        dueno: DuenoLista.asociacion,
      )..escuchar();
      await Future<void>.delayed(Duration.zero);

      expect(vm.estado, EstadoUI.error);
      expect(vm.mensajeError, 'No se pudieron cargar tus reservas');
    });
  });

  group('busqueda en DonacionesViewModel', () {
    test('filtra por lo que se dona sin importar mayusculas', () async {
      final repo = DonacionRepositoryFalso();
      final vm = DonacionesViewModel(repo)..escuchar();
      repo.emitir([
        donacionDePrueba('a', descripcion: 'Pan del dia'),
        donacionDePrueba('b', descripcion: 'Frutas y verduras'),
      ]);
      await Future<void>.delayed(Duration.zero);

      vm.buscar('FRUTA');
      expect(vm.donaciones.map((d) => d.id), ['b']);
      expect(vm.sinResultados, isFalse);

      vm.buscar('tortillas');
      expect(vm.donaciones, isEmpty);
      expect(vm.sinResultados, isTrue);

      vm.buscar('');
      expect(vm.donaciones, hasLength(2));
    });
  });

  group('MapaDonacionesViewModel', () {
    test('pone en el mapa solo las disponibles con ubicacion', () async {
      final repo = _RepoConPuntos()
        ..puntosPorId['p1'] = _punto('p1', 21.15, -100.93)
        ..puntosPorId['p0'] = _punto('p0', 0, 0)
        ..puntosPorId['px'] = null;
      final vm = MapaDonacionesViewModel(repo)..escuchar();
      repo.emitir([
        _donacion('con-ubicacion', punto: 'p1'),
        _donacion('punto-viejo', punto: 'p0'),
        _donacion('sin-punto', punto: 'px'),
        _donacion('reservada', punto: 'p1', estado: EstadoDonacion.reservada),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(vm.estado, EstadoUI.listo);
      expect(vm.enMapa.map((e) => e.donacion.id), ['con-ubicacion']);
      expect(vm.enMapa.single.punto.latitud, 21.15);
    });

    test('olvida la seleccion si esa donacion ya no esta', () async {
      final repo = _RepoConPuntos()
        ..puntosPorId['p1'] = _punto('p1', 21.15, -100.93);
      final vm = MapaDonacionesViewModel(repo)..escuchar();
      repo.emitir([_donacion('a')]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      vm.seleccionar(vm.enMapa.single);

      repo.emitir([]);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(vm.seleccionada, isNull);
    });
  });

  test('NavegacionService arma la ruta de Google Maps', () {
    final uri = NavegacionService.rutaHacia(21.156, -100.9318);

    expect(uri.host, 'www.google.com');
    expect(uri.path, '/maps/dir/');
    expect(uri.queryParameters['api'], '1');
    expect(uri.queryParameters['destination'], '21.156,-100.9318');
  });
}

/// Hace fallar las consultas de "Mis ..." como si no hubiera conexion.
class _RepoQueFalla extends DonacionRepositoryFalso {
  _RepoQueFalla(DonacionRepositoryFalso _);

  @override
  Stream<List<Donacion>> observarReservadasPor(String asociacionId) =>
      Stream.error(Exception('sin conexion'));
}
