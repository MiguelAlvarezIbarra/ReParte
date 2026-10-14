import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:reparte/models/usuario.dart';
import 'package:reparte/repositories/usuario_repository.dart';
import 'package:reparte/services/auth_service.dart';
import 'package:reparte/services/firestore_service.dart';

import 'usuario_repository_test.mocks.dart';

@GenerateMocks([AuthService, FirestoreService])
void main() {
  late MockAuthService auth;
  late MockFirestoreService firestore;
  late UsuarioRepository repo;

  setUp(() {
    auth = MockAuthService();
    firestore = MockFirestoreService();
    repo = UsuarioRepository(auth: auth, firestore: firestore);
  });

  test('iniciarSesion devuelve el perfil guardado en Firestore', () async {
    when(auth.iniciarSesion('ana@comedor.org', '123456'))
        .thenAnswer((_) async => 'uid-2');
    when(firestore.leerDocumento('usuarios', 'uid-2')).thenAnswer(
      (_) async => {
        'nombre': 'Ana',
        'correo': 'ana@comedor.org',
        'rol': 'asociacion',
      },
    );

    final usuario = await repo.iniciarSesion('ana@comedor.org', '123456');

    expect(usuario.id, 'uid-2');
    expect(usuario.rol, RolUsuario.asociacion);
  });

  test('iniciarSesion sin perfil cierra la sesion y avisa', () async {
    when(auth.iniciarSesion(any, any)).thenAnswer((_) async => 'uid-3');
    when(firestore.leerDocumento(any, any)).thenAnswer((_) async => null);
    when(auth.cerrarSesion()).thenAnswer((_) async {});

    await expectLater(
      repo.iniciarSesion('sin@perfil.mx', '123456'),
      throwsA(isA<AuthException>()),
    );
    verify(auth.cerrarSesion()).called(1);
  });

  test('registrar guarda el perfil con el rol en la coleccion usuarios',
      () async {
    when(auth.registrar('laura@restaurante.mx', '123456'))
        .thenAnswer((_) async => 'uid-1');
    when(firestore.guardarDocumento(any, any, any)).thenAnswer((_) async {});

    final usuario = await repo.registrar(
      nombre: 'Laura',
      correo: 'laura@restaurante.mx',
      contrasena: '123456',
      rol: RolUsuario.donante,
    );

    expect(usuario.id, 'uid-1');
    verify(firestore.guardarDocumento('usuarios', 'uid-1', {
      'nombre': 'Laura',
      'correo': 'laura@restaurante.mx',
      'rol': 'donante',
      'telefono': '',
    })).called(1);
  });

  test('mensajeDeError traduce las credenciales invalidas', () {
    expect(
      AuthService.mensajeDeError('invalid-credential'),
      'Correo o contraseña incorrectos',
    );
    expect(
      AuthService.mensajeDeError('codigo-raro'),
      'No se pudo completar la operación',
    );
  });
}
