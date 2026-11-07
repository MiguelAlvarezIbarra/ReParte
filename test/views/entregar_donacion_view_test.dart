import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/models/donacion.dart';
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

  Future<void> abrirDetalle(
    WidgetTester tester,
    Donacion donacion, {
    String? usuarioId,
  }) async {
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
                  donacion,
                  usuarioId: usuarioId,
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

  final reservada = donacionDePrueba('a', estado: EstadoDonacion.reservada)
      .copyWith(asociacionId: 'as1');
  final botonEntregar =
      find.widgetWithText(FilledButton, 'Marcar como entregada');

  testWidgets('el donante confirma la entrega y la donacion queda cerrada',
      (tester) async {
    await abrirDetalle(tester, reservada, usuarioId: 'd1');
    expect(find.textContaining('La asociación pasará a recogerla'),
        findsOneWidget);

    await tester.tap(botonEntregar);
    await tester.pumpAndSettle();
    expect(find.text('¿Marcar como entregada?'), findsOneWidget);
    await tester.tap(find.text('Sí, se entregó'));
    await tester.pumpAndSettle();

    expect(find.text('Donación entregada. ¡Gracias!'), findsOneWidget);
    expect(find.textContaining('Entregada el 08/11/2026'), findsOneWidget);
    expect(find.text('Entregada'), findsOneWidget);
    expect(botonEntregar, findsNothing);
    expect(donaciones.entregadas, hasLength(1));
  });

  testWidgets('si cancela la confirmacion no cambia nada', (tester) async {
    await abrirDetalle(tester, reservada, usuarioId: 'd1');

    await tester.tap(botonEntregar);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(donaciones.entregadas, isEmpty);
    expect(botonEntregar, findsOneWidget);
  });

  testWidgets('una donacion entregada ya no ofrece acciones', (tester) async {
    final entregada = reservada.copyWith(
      estado: EstadoDonacion.entregada,
      entregadaEn: DateTime(2026, 11, 8),
    );

    await abrirDetalle(tester, entregada, usuarioId: 'd1');

    expect(find.textContaining('Entregada el 08/11/2026'), findsOneWidget);
    expect(botonEntregar, findsNothing);
    expect(
        find.widgetWithText(FilledButton, 'Reservar donación'), findsNothing);
  });
}
