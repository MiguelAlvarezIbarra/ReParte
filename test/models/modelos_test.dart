import 'package:flutter_test/flutter_test.dart';
import 'package:reparte/models/donacion.dart';
import 'package:reparte/models/punto_entrega.dart';
import 'package:reparte/models/usuario.dart';

void main() {
  group('Usuario', () {
    test('convierte a JSON y de regreso sin perder datos', () {
      const original = Usuario(
        id: 'u1',
        nombre: 'Ana Ruiz',
        correo: 'ana@comedor.org',
        rol: RolUsuario.asociacion,
        telefono: '4181234567',
      );

      final copia = Usuario.fromMap('u1', original.toMap());

      expect(copia.nombre, original.nombre);
      expect(copia.correo, original.correo);
      expect(copia.rol, RolUsuario.asociacion);
      expect(copia.telefono, '4181234567');
      expect(copia.esDonante, isFalse);
    });

    test('un perfil sin telefono ni rol valido usa valores por defecto', () {
      final usuario = Usuario.fromMap('u2', {
        'nombre': 'Laura',
        'correo': 'laura@restaurante.mx',
        'rol': 'desconocido',
      });

      expect(usuario.rol, RolUsuario.donante);
      expect(usuario.telefono, '');
    });
  });

  group('Donacion', () {
    final donacion = Donacion(
      id: 'd1',
      donanteId: 'u1',
      descripcion: '12 porciones de comida corrida',
      cantidadKg: 6.5,
      caducidad: DateTime(2026, 10, 20, 20, 30),
      puntoEntregaId: 'p1',
      creadaEn: DateTime(2026, 10, 20, 18, 0),
    );

    test('convierte a JSON y de regreso sin perder datos', () {
      final copia = Donacion.fromMap('d1', donacion.toMap());

      expect(copia.descripcion, donacion.descripcion);
      expect(copia.cantidadKg, 6.5);
      expect(copia.caducidad, donacion.caducidad);
      expect(copia.puntoEntregaId, 'p1');
      expect(copia.creadaEn, donacion.creadaEn);
      expect(copia.estado, EstadoDonacion.disponible);
      expect(copia.asociacionId, isNull);
    });

    test('acepta la cantidad como entero', () {
      final map = donacion.toMap()..['cantidadKg'] = 5;

      expect(Donacion.fromMap('d1', map).cantidadKg, 5.0);
    });

    test('copyWith reserva sin modificar el original', () {
      final reservada = donacion.copyWith(
        estado: EstadoDonacion.reservada,
        asociacionId: 'u9',
      );

      expect(reservada.estado, EstadoDonacion.reservada);
      expect(reservada.asociacionId, 'u9');
      expect(donacion.estado, EstadoDonacion.disponible);
    });

    test('una donacion caducada no esta disponible', () {
      final caducada = Donacion(
        id: 'd2',
        donanteId: 'u1',
        descripcion: 'Pan',
        cantidadKg: 2,
        caducidad: DateTime.now().subtract(const Duration(hours: 1)),
        puntoEntregaId: 'p1',
        creadaEn: DateTime.now().subtract(const Duration(hours: 3)),
      );

      expect(caducada.estaVigente, isFalse);
      expect(caducada.estaDisponible, isFalse);
    });
  });

  group('PuntoEntrega', () {
    test('convierte a JSON y de regreso sin perder datos', () {
      const punto = PuntoEntrega(
        id: 'p1',
        donanteId: 'u1',
        nombre: 'Restaurante La Esquina',
        direccion: 'Av. Universidad 210',
        latitud: 21.1561,
        longitud: -100.9346,
        horario: '18:00 a 20:30',
      );

      final copia = PuntoEntrega.fromMap('p1', punto.toMap());

      expect(copia.nombre, punto.nombre);
      expect(copia.direccion, punto.direccion);
      expect(copia.latitud, 21.1561);
      expect(copia.longitud, -100.9346);
      expect(copia.horario, '18:00 a 20:30');
    });
  });
}
