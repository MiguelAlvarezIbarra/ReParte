import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/models/usuario.dart';
import 'package:reparte/viewmodels/login_viewmodel.dart';
import 'package:reparte/views/auth/login_view.dart';
import 'package:reparte/views/inicio/inicio_asociacion_view.dart';
import 'package:reparte/views/inicio/inicio_donante_view.dart';
import 'package:reparte/views/inicio/puerta_acceso.dart';

import '../viewmodels/login_viewmodel_test.mocks.dart';

void main() {
  late MockUsuarioRepository repo;

  const laura = Usuario(
    id: 'u1',
    nombre: 'Laura',
    correo: 'laura@restaurante.mx',
    rol: RolUsuario.donante,
  );
  const ana = Usuario(
    id: 'u2',
    nombre: 'Comedor San José',
    correo: 'ana@comedor.org',
    rol: RolUsuario.asociacion,
  );

  setUp(() => repo = MockUsuarioRepository());

  Future<void> abrirApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LoginViewModel(repo),
        child: MaterialApp(theme: TemaApp.claro, home: const PuertaAcceso()),
      ),
    );
    await tester.pump();
  }

  testWidgets('sin sesion muestra el inicio de sesion', (tester) async {
    when(repo.usuarioActual()).thenAnswer((_) async => null);

    await abrirApp(tester);

    expect(find.byType(LoginView), findsOneWidget);
  });

  testWidgets('la sesion se mantiene: un donante entra directo a su inicio',
      (tester) async {
    when(repo.usuarioActual()).thenAnswer((_) async => laura);

    await abrirApp(tester);

    expect(find.byType(InicioDonanteView), findsOneWidget);
    expect(find.text('Mis donaciones'), findsOneWidget);
    expect(find.text('Hola, Laura'), findsOneWidget);
  });

  testWidgets('una asociacion llega a las donaciones disponibles',
      (tester) async {
    when(repo.usuarioActual()).thenAnswer((_) async => ana);

    await abrirApp(tester);

    expect(find.byType(InicioAsociacionView), findsOneWidget);
    expect(find.text('Donaciones disponibles'), findsOneWidget);
  });

  testWidgets('al iniciar sesion cambia a la pantalla de su rol',
      (tester) async {
    when(repo.usuarioActual()).thenAnswer((_) async => null);
    when(repo.iniciarSesion(any, any)).thenAnswer((_) async => ana);
    await abrirApp(tester);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Correo'), 'ana@comedor.org');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Contraseña'), '123456');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.byType(InicioAsociacionView), findsOneWidget);
  });

  testWidgets('cerrar sesion regresa al login', (tester) async {
    when(repo.usuarioActual()).thenAnswer((_) async => laura);
    when(repo.cerrarSesion()).thenAnswer((_) async {});
    await abrirApp(tester);

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    verify(repo.cerrarSesion()).called(1);
  });
}
