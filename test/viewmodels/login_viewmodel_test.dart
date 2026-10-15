import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:reparte/models/usuario.dart';
import 'package:reparte/repositories/usuario_repository.dart';
import 'package:reparte/services/auth_service.dart';
import 'package:reparte/viewmodels/estado_ui.dart';
import 'package:reparte/viewmodels/login_viewmodel.dart';

import 'login_viewmodel_test.mocks.dart';

@GenerateMocks([UsuarioRepository])
void main() {
  late MockUsuarioRepository repo;
  late LoginViewModel vm;

  const laura = Usuario(
    id: 'uid-1',
    nombre: 'Laura',
    correo: 'laura@restaurante.mx',
    rol: RolUsuario.donante,
  );

  setUp(() {
    repo = MockUsuarioRepository();
    vm = LoginViewModel(repo);
  });

  group('iniciarSesion', () {
    test('un usuario valido entra y queda en estado listo', () async {
      when(repo.iniciarSesion('laura@restaurante.mx', '123456'))
          .thenAnswer((_) async => laura);

      final ok = await vm.iniciarSesion(' laura@restaurante.mx ', '123456');

      expect(ok, isTrue);
      expect(vm.estado, EstadoUI.listo);
      expect(vm.usuario, laura);
      expect(vm.mensajeError, isNull);
    });

    test('credenciales incorrectas muestran el mensaje de error', () async {
      when(repo.iniciarSesion(any, any)).thenThrow(
        const AuthException('Correo o contraseña incorrectos'),
      );

      final ok = await vm.iniciarSesion('laura@restaurante.mx', 'mala');

      expect(ok, isFalse);
      expect(vm.estado, EstadoUI.error);
      expect(vm.mensajeError, 'Correo o contraseña incorrectos');
      expect(vm.usuario, isNull);
    });

    test('campos vacios no llaman al repositorio', () async {
      final ok = await vm.iniciarSesion('', '');

      expect(ok, isFalse);
      expect(vm.estado, EstadoUI.error);
      expect(vm.mensajeError, 'Escribe tu correo y tu contraseña');
      verifyNever(repo.iniciarSesion(any, any));
    });

    test('pasa por cargando antes de terminar', () async {
      when(repo.iniciarSesion(any, any)).thenAnswer((_) async => laura);
      final estados = <EstadoUI>[];
      vm.addListener(() => estados.add(vm.estado));

      await vm.iniciarSesion('laura@restaurante.mx', '123456');

      expect(estados, [EstadoUI.cargando, EstadoUI.listo]);
    });

    test('un error inesperado muestra un mensaje generico', () async {
      when(repo.iniciarSesion(any, any)).thenThrow(Exception('red caida'));

      await vm.iniciarSesion('laura@restaurante.mx', '123456');

      expect(vm.estado, EstadoUI.error);
      expect(vm.mensajeError, 'Ocurrió un error inesperado. Intenta de nuevo');
    });
  });

  group('registrar', () {
    test('crea la cuenta con el rol elegido', () async {
      when(repo.registrar(
        nombre: 'Laura',
        correo: 'laura@restaurante.mx',
        contrasena: '123456',
        rol: RolUsuario.donante,
      )).thenAnswer((_) async => laura);

      final ok = await vm.registrar(
        nombre: 'Laura',
        correo: 'laura@restaurante.mx',
        contrasena: '123456',
        rol: RolUsuario.donante,
      );

      expect(ok, isTrue);
      expect(vm.usuario?.rol, RolUsuario.donante);
    });

    test('campos vacios muestran error', () async {
      final ok = await vm.registrar(
        nombre: ' ',
        correo: 'laura@restaurante.mx',
        contrasena: '123456',
        rol: RolUsuario.asociacion,
      );

      expect(ok, isFalse);
      expect(vm.mensajeError, 'Completa todos los campos');
    });
  });

  test('cerrarSesion limpia el usuario', () async {
    when(repo.iniciarSesion(any, any)).thenAnswer((_) async => laura);
    when(repo.cerrarSesion()).thenAnswer((_) async {});
    await vm.iniciarSesion('laura@restaurante.mx', '123456');

    await vm.cerrarSesion();

    expect(vm.usuario, isNull);
    expect(vm.estado, EstadoUI.inicial);
  });
}
