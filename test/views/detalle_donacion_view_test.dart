import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/models/punto_entrega.dart';
import 'package:reparte/models/usuario.dart';
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

  /// Abre el detalle desde un boton, como lo hace la lista.
  Future<void> abrirDetalle(WidgetTester tester) async {
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
                  donacionDePrueba(
                    'a',
                    descripcion: '20 panes del dia',
                    cantidadKg: 2.5,
                  ),
                ),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
  }

  testWidgets('mientras carga muestra la donacion y un indicador',
      (tester) async {
    // El perfil del donante tarda hasta que la prueba lo libere.
    final perfil = Completer<Usuario?>();
    when(usuarios.obtenerPerfil('d1')).thenAnswer((_) => perfil.future);
    await abrirDetalle(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Detalle de la donación'), findsOneWidget);
    expect(find.text('20 panes del dia'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('La Espiga'), findsNothing);

    perfil.complete(donanteDePrueba);
    await tester.pumpAndSettle();

    expect(find.text('La Espiga'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('muestra los datos de la donacion, el donante y la ubicacion',
      (tester) async {
    await abrirDetalle(tester);
    await tester.pumpAndSettle();

    // Donacion
    expect(find.text('20 panes del dia'), findsOneWidget);
    expect(find.text('2.5 kg'), findsOneWidget);
    expect(find.text('Disponible'), findsOneWidget);
    expect(find.text('01/10/2026'), findsOneWidget);
    // Donante
    expect(find.text('La Espiga'), findsOneWidget);
    expect(find.text('555 123 4567'), findsOneWidget);
    expect(find.text('espiga@restaurante.mx'), findsOneWidget);
    // Ubicacion de entrega
    expect(find.text('Panaderia Central'), findsOneWidget);
    expect(find.text('Calle Hidalgo 12'), findsOneWidget);
    expect(find.text('18:00 a 20:30'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('sin telefono ni horario no muestra esas filas', (tester) async {
    when(usuarios.obtenerPerfil('d1')).thenAnswer((_) async => const Usuario(
          id: 'd1',
          nombre: 'La Espiga',
          correo: 'espiga@restaurante.mx',
          rol: RolUsuario.donante,
        ));
    donaciones.punto = const PuntoEntrega(
      id: 'p1',
      donanteId: 'd1',
      nombre: 'Panaderia Central',
      direccion: 'Calle Hidalgo 12',
      latitud: 19.4,
      longitud: -99.1,
    );
    await abrirDetalle(tester);
    await tester.pumpAndSettle();

    expect(find.text('Teléfono'), findsNothing);
    expect(find.text('Horario'), findsNothing);
    expect(find.text('Correo'), findsOneWidget);
  });

  testWidgets('si no se puede leer la ubicacion avisa y muestra lo demas',
      (tester) async {
    donaciones.puntoFalla = true;
    await abrirDetalle(tester);
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar la ubicación de entrega'),
        findsOneWidget);
    expect(find.text('La Espiga'), findsOneWidget);
    expect(find.text('20 panes del dia'), findsOneWidget);
  });

  testWidgets('si no se puede leer el donante avisa y muestra lo demas',
      (tester) async {
    when(usuarios.obtenerPerfil('d1')).thenThrow(Exception('sin conexion'));
    await abrirDetalle(tester);
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar la información del donante'),
        findsOneWidget);
    expect(find.text('Panaderia Central'), findsOneWidget);
  });
}
