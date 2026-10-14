import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/core/utilidades/validadores.dart';

void main() {
  group('correo', () {
    test('acepta un correo valido', () {
      expect(Validadores.correo('laura@restaurante.mx'), isNull);
      expect(Validadores.correo('  ana@comedor.org '), isNull);
    });

    test('rechaza vacio y formatos invalidos', () {
      expect(Validadores.correo(''), 'Escribe tu correo');
      expect(Validadores.correo(null), 'Escribe tu correo');
      expect(Validadores.correo('laura'), 'El correo no es válido');
      expect(Validadores.correo('laura@'), 'El correo no es válido');
      expect(Validadores.correo('laura@restaurante'), 'El correo no es válido');
      expect(Validadores.correo('la ura@r.mx'), 'El correo no es válido');
    });
  });

  test('contrasena vacia muestra error', () {
    expect(Validadores.contrasena(''), 'Escribe tu contraseña');
    expect(Validadores.contrasena('x'), isNull);
  });

  test('contrasena nueva exige 6 caracteres', () {
    expect(Validadores.contrasenaNueva('12345'), 'Usa al menos 6 caracteres');
    expect(Validadores.contrasenaNueva('123456'), isNull);
  });

  test('requerido usa el nombre del campo', () {
    expect(Validadores.requerido('  ', 'nombre'), 'Escribe tu nombre');
    expect(Validadores.requerido('Laura', 'nombre'), isNull);
  });
}
