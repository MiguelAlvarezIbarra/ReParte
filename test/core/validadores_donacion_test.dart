import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/core/utilidades/validadores.dart';

void main() {
  group('cantidadKg', () {
    test('acepta numeros con punto o coma', () {
      expect(Validadores.cantidadKg('5'), isNull);
      expect(Validadores.cantidadKg('2.5'), isNull);
      expect(Validadores.cantidadKg('2,5'), isNull);
    });

    test('rechaza vacio, texto y valores menores o iguales a cero', () {
      expect(Validadores.cantidadKg(''), 'Escribe la cantidad');
      expect(Validadores.cantidadKg(null), 'Escribe la cantidad');
      expect(Validadores.cantidadKg('abc'), 'Escribe un número válido');
      expect(Validadores.cantidadKg('0'), 'La cantidad debe ser mayor a 0');
      expect(Validadores.cantidadKg('-3'), 'La cantidad debe ser mayor a 0');
    });

    test('parsearCantidad convierte la coma decimal', () {
      expect(Validadores.parsearCantidad(' 2,5 '), 2.5);
      expect(Validadores.parsearCantidad('x'), isNull);
    });
  });

  group('caducidad', () {
    final hoy = DateTime(2026, 10, 24, 15, 30);

    test('exige una fecha', () {
      expect(Validadores.caducidad(null, ahora: hoy),
          'Elige la fecha de caducidad');
    });

    test('acepta hoy y fechas futuras', () {
      expect(Validadores.caducidad(DateTime(2026, 10, 24), ahora: hoy), isNull);
      expect(Validadores.caducidad(DateTime(2026, 10, 30), ahora: hoy), isNull);
    });

    test('rechaza fechas pasadas', () {
      expect(Validadores.caducidad(DateTime(2026, 10, 23), ahora: hoy),
          'Esa fecha ya pasó');
    });
  });

  test('obligatorio muestra el mensaje cuando va vacio', () {
    expect(Validadores.obligatorio('  ', 'Falta'), 'Falta');
    expect(Validadores.obligatorio(null, 'Falta'), 'Falta');
    expect(Validadores.obligatorio('algo', 'Falta'), isNull);
  });
}
