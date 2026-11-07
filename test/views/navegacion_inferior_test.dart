import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:reparte/core/tema/tema_app.dart';
import 'package:reparte/models/donacion.dart';
import 'package:reparte/models/usuario.dart';
import 'package:reparte/repositories/donacion_repository.dart';
import 'package:reparte/viewmodels/login_viewmodel.dart';
import 'package:reparte/views/inicio/inicio_asociacion_view.dart';
import 'package:reparte/views/inicio/inicio_donante_view.dart';

import '../fakes/donacion_repository_falso.dart';
import '../viewmodels/login_viewmodel_test.mocks.dart';

void main() {
  const asociacion = Usuario(
    id: 'as1',
    nombre: 'Comedor San José',
    correo: 'ana@comedor.org',
    rol: RolUsuario.asociacion,
  );

  Future<DonacionRepositoryFalso> abrir(WidgetTester tester, Widget inicio,
      {List<Donacion> disponibles = const []}) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = DonacionRepositoryFalso();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => LoginViewModel(MockUsuarioRepository()),
          ),
          Provider<DonacionRepository>.value(value: repo),
        ],
        child: MaterialApp(theme: TemaApp.claro, home: inicio),
      ),
    );
    repo.emitir(disponibles);
    await tester.pump();
    return repo;
  }

  testWidgets('la asociacion busca entre las donaciones disponibles',
      (tester) async {
    await abrir(
      tester,
      const InicioAsociacionView(usuario: asociacion),
      disponibles: [
        donacionDePrueba('a', descripcion: 'Pan del dia'),
        donacionDePrueba('b', descripcion: 'Frutas y verduras'),
      ],
    );

    await tester.enterText(find.byType(TextField), 'pan');
    await tester.pump();

    expect(find.text('Pan del dia'), findsOneWidget);
    expect(find.text('Frutas y verduras'), findsNothing);

    await tester.enterText(find.byType(TextField), 'tortillas');
    await tester.pump();
    expect(find.textContaining('No encontramos donaciones'), findsOneWidget);
  });

  testWidgets('la barra de la asociacion lleva a sus reservas y su perfil',
      (tester) async {
    final repo =
        await abrir(tester, const InicioAsociacionView(usuario: asociacion));
    repo.reservadasPorAsociacion = [
      donacionDePrueba('r',
          descripcion: 'Comida corrida', estado: EstadoDonacion.reservada),
    ];

    await tester.tap(find.text('Mis reservas'));
    await tester.pumpAndSettle();
    expect(find.text('Comida corrida'), findsOneWidget);
    expect(find.text('Reservada'), findsOneWidget);
    expect(repo.asociacionConsultada, 'as1');

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle();
    expect(find.text('ana@comedor.org'), findsOneWidget);
    expect(
        find.widgetWithText(OutlinedButton, 'Cerrar sesión'), findsOneWidget);
  });

  testWidgets('el donante ve sus donaciones con su estado', (tester) async {
    final repo = DonacionRepositoryFalso();
    repo.deDonante = [
      donacionDePrueba('a', descripcion: 'Pan dulce'),
      donacionDePrueba('b',
          descripcion: 'Bolillos', estado: EstadoDonacion.reservada),
    ];
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => LoginViewModel(MockUsuarioRepository()),
          ),
          Provider<DonacionRepository>.value(value: repo),
        ],
        child: MaterialApp(
          theme: TemaApp.claro,
          home: const InicioDonanteView(usuario: donanteDePrueba),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repo.donanteConsultado, donanteDePrueba.id);
    expect(find.text('Pan dulce'), findsOneWidget);
    expect(find.text('Bolillos'), findsOneWidget);
    expect(find.text('Disponible'), findsOneWidget);
    expect(find.text('Reservada'), findsOneWidget);
  });
}
