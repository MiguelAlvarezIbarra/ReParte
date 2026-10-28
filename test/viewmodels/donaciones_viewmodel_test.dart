import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/viewmodels/donaciones_viewmodel.dart';
import 'package:reparte/viewmodels/estado_ui.dart';
import 'package:reparte/models/donacion.dart';

import '../fakes/donacion_repository_falso.dart';

void main() {
  late DonacionRepositoryFalso repo;
  late DonacionesViewModel vm;

  setUp(() {
    repo = DonacionRepositoryFalso();
    vm = DonacionesViewModel(repo);
  });

  tearDown(() => vm.dispose());

  test('antes de escuchar esta en estado inicial', () {
    expect(vm.estado, EstadoUI.inicial);
    expect(vm.donaciones, isEmpty);
  });

  test('al escuchar pasa a cargando y luego a listo con los datos', () async {
    vm.escuchar();
    expect(vm.estado, EstadoUI.cargando);

    repo.emitir([donacionDePrueba('a')]);
    await Future<void>.delayed(Duration.zero);

    expect(vm.estado, EstadoUI.listo);
    expect(vm.donaciones.map((d) => d.id), ['a']);
  });

  test('ordena por fecha: primero la que caduca antes', () async {
    vm.escuchar();

    repo.emitir([
      donacionDePrueba('lejana', dias: 5),
      donacionDePrueba('cercana', dias: 1),
      donacionDePrueba('media', dias: 3),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(vm.donaciones.map((d) => d.id), ['cercana', 'media', 'lejana']);
  });

  test('solo muestra donaciones vigentes y disponibles', () async {
    vm.escuchar();

    repo.emitir([
      donacionDePrueba('buena'),
      donacionDePrueba('caducada', dias: -1),
      donacionDePrueba('reservada', estado: EstadoDonacion.reservada),
      donacionDePrueba('entregada', estado: EstadoDonacion.entregada),
      donacionDePrueba('cancelada', estado: EstadoDonacion.cancelada),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(vm.donaciones.map((d) => d.id), ['buena']);
  });

  test('se actualiza en tiempo real cuando llegan cambios', () async {
    vm.escuchar();
    var avisos = 0;
    vm.addListener(() => avisos++);

    repo.emitir([donacionDePrueba('a', dias: 2)]);
    await Future<void>.delayed(Duration.zero);
    expect(vm.donaciones.map((d) => d.id), ['a']);

    repo.emitir(
        [donacionDePrueba('b', dias: 1), donacionDePrueba('a', dias: 2)]);
    await Future<void>.delayed(Duration.zero);
    expect(vm.donaciones.map((d) => d.id), ['b', 'a']);
    expect(avisos, 2);

    // Una donacion que se reserva desaparece de la lista.
    repo.emitir([
      donacionDePrueba('b', dias: 1, estado: EstadoDonacion.reservada),
      donacionDePrueba('a', dias: 2),
    ]);
    await Future<void>.delayed(Duration.zero);
    expect(vm.donaciones.map((d) => d.id), ['a']);
  });

  test('una lista vacia es un estado listo sin donaciones', () async {
    vm.escuchar();

    repo.emitir([]);
    await Future<void>.delayed(Duration.zero);

    expect(vm.estado, EstadoUI.listo);
    expect(vm.donaciones, isEmpty);
  });

  test('si el flujo falla muestra el error y puede recuperarse', () async {
    vm.escuchar();

    repo.fallar();
    await Future<void>.delayed(Duration.zero);
    expect(vm.estado, EstadoUI.error);
    expect(vm.mensajeError, 'No se pudieron cargar las donaciones');

    repo.emitir([donacionDePrueba('a')]);
    await Future<void>.delayed(Duration.zero);
    expect(vm.estado, EstadoUI.listo);
    expect(vm.mensajeError, isNull);
  });

  test('si la base de datos falla muestra el error', () async {
    final sinImplementar = DonacionesViewModel(
      DonacionRepository(firestore: FirestoreQueFalla()),
    );

    sinImplementar.escuchar();
    await Future<void>.delayed(Duration.zero);

    expect(sinImplementar.estado, EstadoUI.error);
    expect(sinImplementar.mensajeError, isNotNull);
    sinImplementar.dispose();
  });

  test('al cerrar el ViewModel deja de escuchar', () {
    vm.escuchar();
    expect(repo.controlador.hasListener, isTrue);

    vm.dispose();

    expect(repo.controlador.hasListener, isFalse);
    // tearDown vuelve a llamar dispose; ChangeNotifier lo permite solo una vez.
    vm = DonacionesViewModel(repo);
  });
}
