import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/viewmodels/detalle_donacion_viewmodel.dart';
import 'package:reparte/viewmodels/estado_ui.dart';

import '../fakes/donacion_repository_falso.dart';
import 'login_viewmodel_test.mocks.dart';

void main() {
  late MockUsuarioRepository usuarios;
  late DonacionRepositoryFalso donaciones;

  setUp(() {
    usuarios = MockUsuarioRepository();
    donaciones = DonacionRepositoryFalso()..punto = puntoDePrueba;
    when(usuarios.obtenerPerfil('d1')).thenAnswer((_) async => donanteDePrueba);
  });

  DetalleDonacionViewModel crear([DonacionRepository? repo]) {
    return DetalleDonacionViewModel(
      donacion: donacionDePrueba('a'),
      donaciones: repo ?? donaciones,
      usuarios: usuarios,
    );
  }

  test('antes de cargar esta en estado inicial y cargando', () {
    final vm = crear();

    expect(vm.estado, EstadoUI.inicial);
    expect(vm.cargando, isTrue);
    expect(vm.donante, isNull);
    expect(vm.punto, isNull);
  });

  test('carga el donante y el punto de entrega', () async {
    final vm = crear();

    await vm.cargar();

    expect(vm.estado, EstadoUI.listo);
    expect(vm.cargando, isFalse);
    expect(vm.donante, donanteDePrueba);
    expect(vm.punto, puntoDePrueba);
    expect(vm.donanteNoDisponible, isFalse);
    expect(vm.puntoNoDisponible, isFalse);
    // Pide el perfil del donante de esa donacion y el punto de esa donacion.
    verify(usuarios.obtenerPerfil('d1')).called(1);
  });

  test('si falla el punto, el donante se muestra igual', () async {
    donaciones.puntoFalla = true;
    final vm = crear();

    await vm.cargar();

    expect(vm.estado, EstadoUI.listo);
    expect(vm.donante, donanteDePrueba);
    expect(vm.punto, isNull);
    expect(vm.puntoNoDisponible, isTrue);
    expect(vm.donanteNoDisponible, isFalse);
  });

  test('si falla el donante, el punto se muestra igual', () async {
    when(usuarios.obtenerPerfil('d1')).thenThrow(Exception('sin conexion'));
    final vm = crear();

    await vm.cargar();

    expect(vm.estado, EstadoUI.listo);
    expect(vm.donante, isNull);
    expect(vm.punto, puntoDePrueba);
    expect(vm.donanteNoDisponible, isTrue);
    expect(vm.puntoNoDisponible, isFalse);
  });

  test('si el perfil ya no existe lo marca como no disponible', () async {
    when(usuarios.obtenerPerfil('d1')).thenAnswer((_) async => null);
    final vm = crear();

    await vm.cargar();

    expect(vm.donanteNoDisponible, isTrue);
  });

  test('con el repositorio sin implementar no truena', () async {
    final vm = crear(DonacionRepository());

    await vm.cargar();

    expect(vm.estado, EstadoUI.listo);
    expect(vm.donante, donanteDePrueba);
    expect(vm.puntoNoDisponible, isTrue);
  });

  test('avisa a los oyentes al empezar y al terminar', () async {
    final vm = crear();
    var avisos = 0;
    vm.addListener(() => avisos++);

    await vm.cargar();

    expect(avisos, 2);
  });

  test('cerrar la pantalla mientras carga no causa errores', () async {
    final vm = crear();

    final carga = vm.cargar();
    vm.dispose();

    await carga;
    expect(vm.estado, EstadoUI.listo);
  });
}
