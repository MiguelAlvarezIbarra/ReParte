import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/core/utilidades/validadores.dart';

void main() {
  group('cantidadKg', () {
    test('acepta numeros con punto o coma', () {
      expect(Validadores.cantidadKg('5'), isNull);
      expect(Validadores.cantidadKg('2.5'), isNull);
      expect(Validadores.cantidadKg('2,5'), isNull);
      expect(Validadores.cantidadKg(' 10.75 '), isNull);
    });

    test('rechaza vacio, espacios, texto y valores no numericos', () {
      expect(Validadores.cantidadKg(''), 'Escribe la cantidad');
      expect(Validadores.cantidadKg('   '), 'Escribe la cantidad');
      expect(Validadores.cantidadKg(null), 'Escribe la cantidad');
      expect(Validadores.cantidadKg('abc'), 'Escribe un número válido');
      expect(Validadores.cantidadKg('NaN'), 'Escribe un número válido');
      expect(Validadores.cantidadKg('Infinity'), 'Escribe un número válido');
    });

    test('rechaza cero y valores negativos (criterio T14)', () {
      expect(Validadores.cantidadKg('0'), 'La cantidad debe ser mayor a 0');
      expect(Validadores.cantidadKg('0.0'), 'La cantidad debe ser mayor a 0');
      expect(Validadores.cantidadKg('0,0'), 'La cantidad debe ser mayor a 0');
      expect(Validadores.cantidadKg('-1'), 'La cantidad debe ser mayor a 0');
      expect(Validadores.cantidadKg('-0.5'), 'La cantidad debe ser mayor a 0');
    });

    test('parsearCantidad convierte la coma decimal', () {
      expect(Validadores.parsearCantidad(' 2,5 '), 2.5);
      expect(Validadores.parsearCantidad('x'), isNull);
    });
  });

  group('caducidad', () {
    final hoy = DateTime(2026, 10, 28, 15, 30);

    test('exige una fecha', () {
      expect(Validadores.caducidad(null, ahora: hoy),
          'Elige la fecha de caducidad');
    });

    test('acepta hoy y fechas futuras', () {
      expect(Validadores.caducidad(DateTime(2026, 10, 28), ahora: hoy), isNull);
      expect(Validadores.caducidad(DateTime(2026, 10, 28, 23, 59), ahora: hoy),
          isNull);
      expect(Validadores.caducidad(DateTime(2026, 10, 30), ahora: hoy), isNull);
    });

    test('rechaza fechas pasadas (criterio T14)', () {
      expect(Validadores.caducidad(DateTime(2026, 10, 27), ahora: hoy),
          'Esa fecha ya pasó');
      expect(Validadores.caducidad(DateTime(2026, 1, 1), ahora: hoy),
          'Esa fecha ya pasó');
      expect(Validadores.caducidad(DateTime(2025, 10, 28), ahora: hoy),
          'Esa fecha ya pasó');
    });
  });

  group('obligatorio', () {
    test('muestra el mensaje cuando va vacio o solo con espacios (criterio T14)',
        () {
      expect(Validadores.obligatorio('', 'Falta'), 'Falta');
      expect(Validadores.obligatorio('  ', 'Falta'), 'Falta');
      expect(Validadores.obligatorio('\n\t  ', 'Falta'), 'Falta');
      expect(Validadores.obligatorio(null, 'Falta'), 'Falta');
      expect(Validadores.obligatorio('algo', 'Falta'), isNull);
    });
  });
}
