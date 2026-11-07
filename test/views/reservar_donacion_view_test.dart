import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/repositories/usuario_repository.dart';
import 'package:reparte/views/donaciones/detalle_donacion_view.dart';

import '../fakes/donacion_repository_falso.dart';
import '../viewmodels/login_viewmodel_test.mocks.dart';

void main() {
  late MockUsuarioRepository usuarios;
  late DonacionRepositoryFalso donaciones;

  setUp(() {
    usuarios = MockUsuarioRepository();
    donaciones = DonacionRepositoryFalso()..punto = puntoDePrueba;
    when(usuarios.obtenerPerfil('d1')).thenAnswer((_) async => donanteDePrueba);
  });

  /// Abre el detalle como lo hace la lista; con [asociacionId] permite reservar.
  Future<void> abrirDetalle(WidgetTester tester, {String? asociacionId}) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<DonacionRepository>.value(value: donaciones),
          Provider<UsuarioRepository>.value(value: usuarios),
        ],
        child: MaterialApp(
          theme: TemaApp.claro,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => DetalleDonacionView.abrir(
                  context,
                  donacionDePrueba('a'),
                  asociacionId: asociacionId,
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  final botonReservar = find.widgetWithText(FilledButton, 'Reservar donación');

  testWidgets('sin asociacion no muestra el boton de reservar', (tester) async {
    await abrirDetalle(tester);

    expect(botonReservar, findsNothing);
  });

  testWidgets('la asociacion reserva y ve que es suya', (tester) async {
    await abrirDetalle(tester, asociacionId: 'as1');

    await tester.tap(botonReservar);
    await tester.pumpAndSettle();

    expect(find.text('Donación reservada'), findsOneWidget);
    expect(find.textContaining('Reservada por ti'), findsOneWidget);
    expect(botonReservar, findsNothing);
    expect(donaciones.reservadas.single.asociacionId, 'as1');
  });

  testWidgets('si ya no esta disponible muestra el aviso', (tester) async {
    donaciones.errorAlReservar = const DonacionNoDisponible();
    await abrirDetalle(tester, asociacionId: 'as1');

    await tester.tap(botonReservar);
    await tester.pumpAndSettle();

    expect(find.text('Esta donación ya no está disponible'), findsOneWidget);
    expect(botonReservar, findsOneWidget);
  });
}
