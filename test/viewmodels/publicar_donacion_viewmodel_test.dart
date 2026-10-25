import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/viewmodels/publicar_donacion_viewmodel.dart';

void main() {
  late PublicarDonacionViewModel vm;
  final manana = DateTime.now().add(const Duration(days: 1));

  setUp(() => vm = PublicarDonacionViewModel());

  test('con datos validos arma el borrador limpio', () {
    final ok = vm.preparar(
      descripcion: '  20 panes del dia  ',
      cantidad: '2,5',
      fechaCaducidad: manana,
      puntoNombre: ' Panaderia La Espiga ',
      puntoDireccion: ' Calle Hidalgo 12 ',
    );

    expect(ok, isTrue);
    expect(vm.mensajeError, isNull);
    final borrador = vm.borrador!;
    expect(borrador.descripcion, '20 panes del dia');
    expect(borrador.cantidadKg, 2.5);
    expect(borrador.puntoNombre, 'Panaderia La Espiga');
    expect(borrador.puntoDireccion, 'Calle Hidalgo 12');
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
}
