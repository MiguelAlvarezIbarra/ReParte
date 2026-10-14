import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/models/usuario.dart';
import 'package:reparte/viewmodels/login_viewmodel.dart';
import 'package:reparte/views/auth/registro_view.dart';

import '../viewmodels/login_viewmodel_test.mocks.dart';

void main() {
  late MockUsuarioRepository repo;

  setUp(() => repo = MockUsuarioRepository());

  Future<void> abrirRegistro(WidgetTester tester) {
    return tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LoginViewModel(repo),
        child: MaterialApp(theme: TemaApp.claro, home: const RegistroView()),
      ),
    );
  }

  Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

  testWidgets('muestra los campos del registro', (tester) async {
    await abrirRegistro(tester);

    expect(campo('Nombre del establecimiento u organización'), findsOneWidget);
    expect(campo('Correo'), findsOneWidget);
    expect(campo('Contraseña'), findsOneWidget);
  });

  testWidgets('valida campos vacios y correo invalido', (tester) async {
    await abrirRegistro(tester);

    await tester.enterText(campo('Correo'), 'ana@comedor');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pump();

    expect(find.text('Escribe tu nombre'), findsOneWidget);
    expect(find.text('El correo no es válido'), findsOneWidget);
    expect(find.text('Escribe tu contraseña'), findsOneWidget);
    verifyNever(repo.registrar(
      nombre: anyNamed('nombre'),
      correo: anyNamed('correo'),
      contrasena: anyNamed('contrasena'),
      rol: anyNamed('rol'),
    ));
  });

  testWidgets('exige al menos 6 caracteres de contrasena', (tester) async {
    await abrirRegistro(tester);

    await tester.enterText(campo('Contraseña'), '123');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pump();

    expect(find.text('Usa al menos 6 caracteres'), findsOneWidget);
  });

  testWidgets('con datos validos crea la cuenta', (tester) async {
    when(repo.registrar(
      nombre: anyNamed('nombre'),
      correo: anyNamed('correo'),
      contrasena: anyNamed('contrasena'),
      rol: anyNamed('rol'),
    )).thenAnswer((_) async => const Usuario(
          id: 'u1',
          nombre: 'La Esquina',
          correo: 'laura@restaurante.mx',
          rol: RolUsuario.donante,
        ));
    await abrirRegistro(tester);

    await tester.enterText(
        campo('Nombre del establecimiento u organización'), 'La Esquina');
    await tester.enterText(campo('Correo'), 'laura@restaurante.mx');
    await tester.enterText(campo('Contraseña'), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
    await tester.pump();

    verify(repo.registrar(
      nombre: 'La Esquina',
      correo: 'laura@restaurante.mx',
      contrasena: '123456',
      rol: anyNamed('rol'),
    )).called(1);
  });
}
