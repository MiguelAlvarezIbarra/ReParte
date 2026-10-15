import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/models/usuario.dart';
import 'package:reparte/routes/rutas.dart';
import 'package:reparte/services/auth_service.dart';
import 'package:reparte/viewmodels/login_viewmodel.dart';
import 'package:reparte/views/auth/login_view.dart';
import 'package:reparte/views/auth/registro_view.dart';

import '../viewmodels/login_viewmodel_test.mocks.dart';

void main() {
  late MockUsuarioRepository repo;

  setUp(() => repo = MockUsuarioRepository());

  Future<void> abrirLogin(WidgetTester tester) {
    return tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LoginViewModel(repo),
        child: MaterialApp(
          theme: TemaApp.claro,
          home: const LoginView(),
          routes: {Rutas.registro: (_) => const RegistroView()},
        ),
      ),
    );
  }

  final campoCorreo = find.widgetWithText(TextFormField, 'Correo');
  final campoContrasena = find.widgetWithText(TextFormField, 'Contraseña');

  testWidgets('muestra los campos y los botones', (tester) async {
    await abrirLogin(tester);

    expect(find.text('ReParte'), findsOneWidget);
    expect(campoCorreo, findsOneWidget);
    expect(campoContrasena, findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('valida correo invalido y contrasena vacia', (tester) async {
    await abrirLogin(tester);

    await tester.enterText(campoCorreo, 'laura');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('El correo no es válido'), findsOneWidget);
    expect(find.text('Escribe tu contraseña'), findsOneWidget);
    verifyNever(repo.iniciarSesion(any, any));
  });

  testWidgets('muestra el error del ViewModel con credenciales incorrectas',
      (tester) async {
    when(repo.iniciarSesion(any, any)).thenThrow(
      const AuthException('Correo o contraseña incorrectos'),
    );
    await abrirLogin(tester);

    await tester.enterText(campoCorreo, 'laura@restaurante.mx');
    await tester.enterText(campoContrasena, 'mala');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
  });

  testWidgets('un usuario valido entra', (tester) async {
    when(repo.iniciarSesion('laura@restaurante.mx', '123456')).thenAnswer(
      (_) async => const Usuario(
        id: 'u1',
        nombre: 'Laura',
        correo: 'laura@restaurante.mx',
        rol: RolUsuario.donante,
      ),
    );
    await abrirLogin(tester);

    await tester.enterText(campoCorreo, 'laura@restaurante.mx');
    await tester.enterText(campoContrasena, '123456');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    verify(repo.iniciarSesion('laura@restaurante.mx', '123456')).called(1);
  });

  testWidgets('Crear cuenta abre la pantalla de registro', (tester) async {
    await abrirLogin(tester);

    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(find.byType(RegistroView), findsOneWidget);
  });
}
