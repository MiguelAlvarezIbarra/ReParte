import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/viewmodels/estado_ui.dart';
import 'package:reparte/viewmodels/publicar_donacion_viewmodel.dart';

import '../fakes/donacion_repository_falso.dart';
import '../fakes/ubicacion_service_falso.dart';

void main() {
  late DonacionRepositoryFalso repo;
  late UbicacionServiceFalso ubicacionService;
  late PublicarDonacionViewModel vm;
  final manana = DateTime.now().add(const Duration(days: 1));
  final ayer = DateTime.now().subtract(const Duration(days: 1));

  setUp(() {
    repo = DonacionRepositoryFalso();
    ubicacionService = UbicacionServiceFalso();
    vm = PublicarDonacionViewModel(
      repo,
      donanteId: 'd1',
      ubicacionService: ubicacionService,
    );
  });

  test('con datos validos arma el borrador limpio', () {
    final ok = vm.preparar(
      descripcion: '  20 panes del dia  ',
      cantidad: '2,5',
      fechaCaducidad: manana,
      puntoNombre: ' Panaderia La Espiga ',
      puntoDireccion: ' Calle Hidalgo 12 ',
      latitud: 21.1561,
      longitud: -100.9346,
    );

    expect(ok, isTrue);
    expect(vm.mensajeError, isNull);
    final borrador = vm.borrador!;
    expect(borrador.descripcion, '20 panes del dia');
    expect(borrador.cantidadKg, 2.5);
    expect(borrador.puntoNombre, 'Panaderia La Espiga');
    expect(borrador.puntoDireccion, 'Calle Hidalgo 12');
    expect(borrador.latitud, 21.1561);
    expect(borrador.longitud, -100.9346);
    // La donacion vale todo el dia elegido.
    expect(borrador.caducidad,
        DateTime(manana.year, manana.month, manana.day, 23, 59));
  });

  test('sin descripcion no arma el borrador', () {
    final ok = vm.preparar(
      descripcion: ' ',
      cantidad: '3',
      fechaCaducidad: manana,
      puntoNombre: 'Punto',
      puntoDireccion: 'Calle 1',
    );

    expect(ok, isFalse);
    expect(vm.borrador, isNull);
    expect(vm.mensajeError, 'Describe qué vas a donar');
  });

  test('cantidad invalida y fecha vacia reportan su error', () {
    expect(
      vm.preparar(
        descripcion: 'Pan',
        cantidad: '0',
        fechaCaducidad: manana,
        puntoNombre: 'Punto',
        puntoDireccion: 'Calle 1',
      ),
      isFalse,
    );
    expect(vm.mensajeError, 'La cantidad debe ser mayor a 0');

    expect(
      vm.preparar(
        descripcion: 'Pan',
        cantidad: '3',
        fechaCaducidad: null,
        puntoNombre: 'Punto',
        puntoDireccion: 'Calle 1',
      ),
      isFalse,
    );
    expect(vm.mensajeError, 'Elige la fecha de caducidad');
  });

  test('fecha de caducidad pasada reporta su error (criterio T14)', () {
    final ok = vm.preparar(
      descripcion: 'Pan',
      cantidad: '3',
      fechaCaducidad: ayer,
      puntoNombre: 'Punto',
      puntoDireccion: 'Calle 1',
    );

    expect(ok, isFalse);
    expect(vm.mensajeError, 'Esa fecha ya pasó');
    expect(vm.borrador, isNull);
  });

  test('campos de punto vacios o con solo espacios reportan error (criterio T14)',
      () {
    expect(
      vm.preparar(
        descripcion: 'Pan',
        cantidad: '3',
        fechaCaducidad: manana,
        puntoNombre: '   ',
        puntoDireccion: 'Calle 1',
      ),
      isFalse,
    );
    expect(vm.mensajeError, 'Escribe el nombre del punto de entrega');

    expect(
      vm.preparar(
        descripcion: 'Pan',
        cantidad: '3',
        fechaCaducidad: manana,
        puntoNombre: 'Punto',
        puntoDireccion: '   ',
      ),
      isFalse,
    );
    expect(vm.mensajeError, 'Escribe la dirección de entrega');
  });

  test('donanteId vacio reporta error', () {
    final vmSinDonante = PublicarDonacionViewModel(
      repo,
      donanteId: '   ',
      ubicacionService: ubicacionService,
    );
    expect(
      vmSinDonante.preparar(
        descripcion: 'Pan',
        cantidad: '3',
        fechaCaducidad: manana,
        puntoNombre: 'Punto',
        puntoDireccion: 'Calle 1',
      ),
      isFalse,
    );
    expect(vmSinDonante.mensajeError, 'Identificador de donante inválido');
  });

  test('un intento correcto despues de un error limpia el mensaje', () {
    vm.preparar(
      descripcion: '',
      cantidad: '3',
      fechaCaducidad: manana,
      puntoNombre: 'Punto',
      puntoDireccion: 'Calle 1',
    );
    expect(vm.mensajeError, isNotNull);

    vm.preparar(
      descripcion: 'Pan',
      cantidad: '3',
      fechaCaducidad: manana,
      puntoNombre: 'Punto',
      puntoDireccion: 'Calle 1',
    );
    expect(vm.mensajeError, isNull);
    expect(vm.borrador, isNotNull);
  });

  test('avisa a los oyentes al cambiar', () {
    var avisos = 0;
    vm.addListener(() => avisos++);

    vm.preparar(
      descripcion: '',
      cantidad: '',
      fechaCaducidad: null,
      puntoNombre: '',
      puntoDireccion: '',
    );

    expect(avisos, 1);
  });

  group('ubicacion y mapa (T15)', () {
    test('obtenerUbicacionActual pide permiso y obtiene coordenadas y direccion',
        () async {
      expect(vm.tieneCoordenadas, isFalse);

      final res = await vm.obtenerUbicacionActual();

      expect(ubicacionService.llamadasSolicitarPermiso, 1);
      expect(ubicacionService.llamadasObtenerUbicacion, 1);
      expect(ubicacionService.llamadasObtenerDireccion, 1);
      expect(res, isNotNull);
      expect(res!.latitud, 21.1561);
      expect(res.longitud, -100.9346);
      expect(res.direccion, 'Calle Hidalgo 12, Dolores Hidalgo');
      expect(vm.latitud, 21.1561);
      expect(vm.longitud, -100.9346);
      expect(vm.tieneCoordenadas, isTrue);
      expect(vm.mensajeError, isNull);
    });

    test('sin permiso de ubicacion reporta error y no fija coordenadas',
        () async {
      ubicacionService.permisoConcedido = false;

      final res = await vm.obtenerUbicacionActual();

      expect(res, isNull);
      expect(vm.latitud, isNull);
      expect(vm.tieneCoordenadas, isFalse);
      expect(vm.mensajeError, contains('permisos'));
    });

    test('fijarUbicacion actualiza las coordenadas y avisa a los oyentes', () {
      var notificado = false;
      vm.addListener(() => notificado = true);

      vm.fijarUbicacion(lat: 20.5, lng: -100.2);

      expect(vm.latitud, 20.5);
      expect(vm.longitud, -100.2);
      expect(vm.tieneCoordenadas, isTrue);
      expect(notificado, isTrue);
    });
  });

  group('publicar', () {
    Future<bool> publicarValida({double lat = 21.1561, double lng = -100.9346}) =>
        vm.publicar(
          descripcion: ' 20 panes del dia ',
          cantidad: '2,5',
          fechaCaducidad: manana,
          puntoNombre: 'Panaderia La Espiga',
          puntoDireccion: 'Calle Hidalgo 12',
          latitud: lat,
          longitud: lng,
        );

    test('guarda el punto de entrega con coordenadas y direccion (criterio T15)',
        () async {
      final ok = await publicarValida();

      expect(ok, isTrue);
      expect(vm.estado, EstadoUI.listo);
      final punto = repo.puntosCreados.single;
      expect(punto.donanteId, 'd1');
      expect(punto.nombre, 'Panaderia La Espiga');
      expect(punto.direccion, 'Calle Hidalgo 12');
      expect(punto.latitud, 21.1561);
      expect(punto.longitud, -100.9346);
      final donacion = repo.creadas.single;
      expect(donacion.donanteId, 'd1');
      expect(donacion.descripcion, '20 panes del dia');
      expect(donacion.cantidadKg, 2.5);
      expect(donacion.puntoEntregaId, 'p1');
    });

    test('pasa por cargando antes de quedar publicada', () async {
      final estados = <EstadoUI>[];
      vm.addListener(() => estados.add(vm.estado));

      await publicarValida();

      expect(estados, [EstadoUI.cargando, EstadoUI.listo]);
    });

    test('si falla la conexion avisa y no queda publicada', () async {
      repo.crearFalla = true;

      final ok = await publicarValida();

      expect(ok, isFalse);
      expect(vm.estado, EstadoUI.error);
      expect(vm.mensajeError, contains('No se pudo publicar'));
      expect(vm.publicando, isFalse);
    });

    test('con datos invalidos no llama al repositorio', () async {
      final ok = await vm.publicar(
        descripcion: '',
        cantidad: '0',
        fechaCaducidad: manana,
        puntoNombre: 'Punto',
        puntoDireccion: 'Calle 1',
      );

      expect(ok, isFalse);
      expect(vm.estado, EstadoUI.error);
      expect(repo.creadas, isEmpty);
      expect(repo.puntosCreados, isEmpty);
    });

    test('con fecha de caducidad pasada no guarda nada (criterio T14)',
        () async {
      final ok = await vm.publicar(
        descripcion: 'Pan',
        cantidad: '5',
        fechaCaducidad: ayer,
        puntoNombre: 'Punto',
        puntoDireccion: 'Calle 1',
      );

      expect(ok, isFalse);
      expect(vm.estado, EstadoUI.error);
      expect(vm.mensajeError, 'Esa fecha ya pasó');
      expect(repo.creadas, isEmpty);
      expect(repo.puntosCreados, isEmpty);
    });

    test('con cantidad en cero no guarda nada (criterio T14)', () async {
      final ok = await vm.publicar(
        descripcion: 'Pan',
        cantidad: '0',
        fechaCaducidad: manana,
        puntoNombre: 'Punto',
        puntoDireccion: 'Calle 1',
      );

      expect(ok, isFalse);
      expect(vm.estado, EstadoUI.error);
      expect(vm.mensajeError, 'La cantidad debe ser mayor a 0');
      expect(repo.creadas, isEmpty);
      expect(repo.puntosCreados, isEmpty);
    });
  });
}
